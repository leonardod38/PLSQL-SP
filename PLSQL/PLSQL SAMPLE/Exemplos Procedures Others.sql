CREATE OR REPLACE PROCEDURE "APAGACALCULO" 
( PCALCULO in MULT_CALCULO.CALCULO%Type,
  PITEM in MULT_CALCULO.ITEM%Type
)
IS
BEGIN
    Delete from Mult_calculo Where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoAces where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoBens where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoCob  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoCobOp  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoCondu  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoPremiosCob  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoPremios  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoCond  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoCondPar  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoQBR  where Calculo = PCALCULO and Item = PITEM;
    Delete from Mult_calculoOcorrencias  where Calculo = PCALCULO and Item = PITEM;
END;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULOACES" 
( PCALCULO in mult_CalculoAces.CALCULO%Type,
  PITEM in mult_CalculoAces.ITEM%Type
)
IS
BEGIN
 update mult_CalculoAces set Valor = 0, tipo = 0
   where (CALCULO = PCALCULO) and (ITEM = PITEM);
END;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULOPREMIOS" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PITEM      MULT_CALCULO.ITEM%Type,
PPRODUTO      MULT_CALCULOPREMIOS.PRODUTO%Type,
PTIPOCOTACAO      MULT_CALCULOPREMIOS.TIPOCOTACAO%Type
) IS
BEGIN
  DELETE FROM MULT_CALCULOPREMIOS
  WHERE CALCULO = PCALCULO
  and ITEM = PITEM
  and PRODUTO = PPRODUTO
  AND TIPOCOTACAO = PTIPOCOTACAO;
end;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULOPREMIOSCOB" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PITEM      MULT_CALCULO.ITEM%Type,
PPRODUTO MULT_CALCULOPREMIOSCOB.PRODUTO%Type
) IS
BEGIN
  DELETE FROM MULT_CALCULOPREMIOSCOB
  WHERE CALCULO = PCALCULO
  and ITEM = PITEM
  and PRODUTO = PPRODUTO;
end;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULOPREMIOSKIT" (
PCALCULO      kit_CALCULO.CALCULO%Type,
PPRODUTO      kit_CALCULOPREMIOS.PRODUTO%Type,
PTIPOCOTACAO  kit_CALCULOPREMIOS.TIPOCOTACAO%Type
) IS
BEGIN
  DELETE FROM kit_CALCULOPREMIOS
  WHERE CALCULO = PCALCULO
  and PRODUTO = PPRODUTO
  AND TIPOCOTACAO = PTIPOCOTACAO;
end;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULO_RENOVACAO" 
( PDATA_INI in DATE, PDATA_FIM in DATE )
IS
BEGIN  
    
    Delete from Mult_calculoAces where Calculo  in (
      Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoBens where Calculo  in  (
    Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoCob  where Calculo  in (
    Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );

    Delete from Mult_calculoCobOp  where Calculo  in (
      Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoCondu  where Calculo  in (
     Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoPremiosCob  where Calculo in (
     Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoPremios  where Calculo in (
     Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoCond  where Calculo  in (
       Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoCondPar  where Calculo in (
      Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoQBR  where Calculo in (
    Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculoOcorrencias  where Calculo in (
         Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
        
    Delete from Mult_calculo where Calculo in (
       Select 
        t.Calculo 
      from 
        Mult_calculo t
      where 
        t.DataCalculo Between PData_Ini and PData_Fim 
        and t.calculoorigem > 0  
      );
END;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULOZERO" 
IS
BEGIN
  DELETE FROM MULT_CALCULO            WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOCOB         WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOPREMIOS     WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOPREMIOSCOB  WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOQBR         WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULODIVISOES    WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOACES        WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOCOBOP       WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOBENS        WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOCOND        WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOCONDPAR     WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOCONDU       WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOCORRETOR    WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOREALCOR     WHERE CALCULO = 0;
  DELETE FROM MULT_CALCULOOCORRENCIAS WHERE CALCULO = 0;
END;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULO2" 
( PCALCULO in MULT_CALCULO.CALCULO%Type)
IS
BEGIN
  Delete from Mult_calculoAces where calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoAces.calculo and mult_calculo.item = Mult_calculoAces.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoBens where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculobens.calculo and mult_calculo.item = Mult_calculoBens.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoCob  where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoCob.calculo and mult_calculo.item = Mult_calculoCob.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoCobOp  where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoCobOp.calculo and mult_calculo.item = Mult_calculoCobOp.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoCondu  where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoCondu.calculo and mult_calculo.item = Mult_calculoCondu.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoPremiosCob  where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoPremioscob.calculo and mult_calculo.item = Mult_calculoPremiosCob.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoPremios  where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoPremios.calculo and mult_calculo.item = Mult_calculoPremios.item and mult_calculo.modelo = 0);
  Delete from Mult_calculoQBR  where Calculo = PCALCULO and
    Exists (Select mult_calculo.calculo from mult_calculo where mult_calculo.calculo = Mult_calculoQBR.calculo and mult_calculo.item = Mult_calculoQbr.item and mult_calculo.modelo = 0);
  Delete from Mult_calculo Where Calculo = PCALCULO and Modelo = 0;
END;
/


CREATE OR REPLACE PROCEDURE "APAGACALCULO3" 
( PCALCULO in MULT_CALCULO.CALCULO%Type,
  PITEM in MULT_CALCULO.ITEM%Type
)
IS
BEGIN
Delete from Mult_calculo Where Calculo = PCALCULO;
    Delete from Mult_calculoCorretor where Calculo = PCALCULO;
    Delete from Mult_calculoRealCor where Calculo = PCALCULO;
    Delete from Mult_calculoAces where Calculo = PCALCULO;
    Delete from Mult_calculoBens where Calculo = PCALCULO;
    Delete from Mult_calculoCob  where Calculo = PCALCULO;
    Delete from Mult_calculoCobOp  where Calculo = PCALCULO;
    Delete from Mult_calculoCondu  where Calculo = PCALCULO;
    Delete from Mult_calculoPremiosCob  where Calculo = PCALCULO;
    Delete from Mult_calculoPremios  where Calculo = PCALCULO;
    Delete from Mult_calculoCond  where Calculo = PCALCULO;
    Delete from Mult_calculoCondPar  where Calculo = PCALCULO;
    Delete from Mult_calculoQBR  where Calculo = PCALCULO;
    Delete from Mult_calculoDivisoes  where Calculo = PCALCULO;
    Delete from Mult_calculoOcorrencias  where Calculo = PCALCULO;
END;
/


CREATE OR REPLACE PROCEDURE "APAGAITEM" 
( PCALCULO in MULT_CALCULO.CALCULO%Type,
  PITEM in MULT_CALCULO.ITEM%Type
)
IS
BEGIN
    Delete from Mult_calculo Where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoAces where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoBens where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoCob  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoCobOp  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoCondu  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoPremiosCob  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoPremios  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoCond  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoCondPar  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoQBR  where Calculo = Pcalculo and Item = Pitem;
    Delete from Mult_calculoOcorrencias  where Calculo = Pcalculo and Item = Pitem;
END;
/


CREATE OR REPLACE PROCEDURE "CARGA_CHASSI" IS
BEGIN
  DECLARE
    LNO_CHASSI VARCHAR2(17);
    Cursor LD_CHASSI Is
       Select
    CHASSI from TABELA_CHASSIRESTRITO_LD;
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DELETE TABELA_CHASSIRESTRITO;
    Open LD_CHASSI;
    Loop
       Begin
          Fetch LD_CHASSI Into LNO_CHASSI;
          Exit When LD_CHASSI%Notfound;
          INSERT INTO TABELA_CHASSIRESTRITO VALUES
          (LNO_CHASSI);
       Exception
          when OTHERS then
             dbms_output.PUT_LINE('Ocorreu um erro ao tentar gravar os chassis restritos: '||TO_CHAR(LNO_CHASSI)||'  -  Mensagem: '||SQLERRM);
       End;
    End Loop;
    Close LD_CHASSI;
    DELETE TABELA_CHASSIRESTRITO_LD;
    COMMIT;
  END;
END;
/


CREATE OR REPLACE PROCEDURE carga_corretores IS
BEGIN
 DECLARE
    LCD_CORR NUMBER(6,0);
    LNM_CORR VARCHAR2(40);
    LCD_CONV VARCHAR2(4);
    LTP_PES VARCHAR2(1);
    LCPF_CGC_CORR NUMBER(15,0);
    RCPF_CGC_CORR VARCHAR2(18);
    LDDD_CORR NUMBER(4,0);
    LFONE_CORR NUMBER(9,0);
    TCORRETOR NUMBER(18);
    VDIVISAO NUMBER(18);
    LPESSOA VARCHAR2(1);
    LESTADO VARCHAR2(2);
    LCIDADE VARCHAR2(20);
    LFORMA_PGTO VARCHAR2(1);
    LFORMA_PGTO_CARGA VARCHAR2(1);
    LFORMA_PGTO_RESIDENCIAL VARCHAR2(1);
    LFORMA_PGTO_EMPRESARIAL VARCHAR2(1);
    LFORMA_PGTO_CONDOMINIO VARCHAR2(1);
	LCOMISSAOMAXPASSEIO NUMBER(8,6);
	LCOMISSAOMINPASSEIO NUMBER(8,6);
	LSINALDESCONTOPASSEIO VARCHAR2(1);
	LDESCONTOMAXPASSEIO NUMBER(8,6);
	LCOMISSAOMAXCARGA NUMBER(8,6);
	LCOMISSAOMINCARGA NUMBER(8,6);
	LSINALDESCONTOCARGA VARCHAR2(1);
	LDESCONTOMAXCARGA NUMBER(8,6);
	LCOMISSAOMAXRESIDENCIAL NUMBER(8,6);
	LCOMISSAOMINRESIDENCIAL NUMBER(8,6);
	LSINALDESCONTORESIDENCIAL VARCHAR2(1);
	LDESCONTOMAXRESIDENCIAL NUMBER(8,6);
	LCOMISSAOMAXEMPRESARIAL NUMBER(8,6);
	LCOMISSAOMINEMPRESARIAL NUMBER(8,6);
	LSINALDESCONTOEMPRESARIAL VARCHAR2(1);
	LDESCONTOMAXEMPRESARIAL NUMBER(8,6);
	LCOMISSAOMAXCONDOMINIO NUMBER(8,6);
	LCOMISSAOMINCONDOMINIO NUMBER(8,6);
	LSINALDESCONTOCONDOMINIO VARCHAR2(1);
	LDESCONTOMAXCONDOMINIO NUMBER(8,6);
	LCOMISSAOPADRAOPASSEIO NUMBER(8,6);
	LCOMISSAOPADRAOCARGA NUMBER(8,6);
	LCOMISSAOPADRAORESIDENCIAL NUMBER(8,6);
	LCOMISSAOPADRAOEMPRESARIAL NUMBER(8,6);
	LCOMISSAOPADRAOCONDOMINIO NUMBER(8,6);
	LCATEGORIATARIFARIA VARCHAR2(1);
	LSUCURSAL NUMBER(10);

    -- campos Tipo Seguro utilizado apenas pelo EMPRESARIAL - Seguro Novo e Renov. Congen
    LDESCONTOMINTIPOSEGURO NUMBER(8,6);
    LDESCONTOMAXTIPOSEGURO NUMBER(8,6);
    LCOMISSAOMINTIPOSEGURO NUMBER(8,6);
    LCOMISSAOMAXTIPOSEGURO NUMBER(8,6);

    -- campos Dt. Vigencia Pacote e Cativo (Inicio e Fim) + CÛd.Corretor Cativo + Perc.Corretor Cativo, para cada Produto
    LDT_INI_VIG_PASSEIO DATE;
    LDT_FIM_VIG_PASSEIO DATE;
    LCD_CORRETOR_CAT_PASSEIO VARCHAR2(6);
    LPERC_CORRETOR_CAT_PASSEIO NUMBER(5);
    LDT_INI_VIG_CAT_PASSEIO DATE;
    LDT_FIM_VIG_CAT_PASSEIO DATE;
    LDT_INI_VIG_CARGA DATE;
    LDT_FIM_VIG_CARGA DATE;
    LCD_CORRETOR_CAT_CARGA VARCHAR2(6);
    LPERC_CORRETOR_CAT_CARGA NUMBER(5);
    LDT_INI_VIG_CAT_CARGA DATE;
    LDT_FIM_VIG_CAT_CARGA DATE;
    LDT_INI_VIG_RESIDENCIAL DATE;
    LDT_FIM_VIG_RESIDENCIAL DATE;
    LCD_CORRETOR_CAT_RESIDENCIAL VARCHAR2(6);
    LPERC_CORRETOR_CAT_RESIDENCIAL NUMBER(5);
    LDT_INI_VIG_CAT_RESIDENCIAL DATE;
    LDT_FIM_VIG_CAT_RESIDENCIAL DATE;
    LDT_INI_VIG_EMPRESARIAL DATE;
    LDT_FIM_VIG_EMPRESARIAL DATE;
    LCD_CORRETOR_CAT_EMPRESARIAL VARCHAR2(6);
    LPERC_CORRETOR_CAT_EMPRESARIAL NUMBER(5);
    LDT_INI_VIG_CAT_EMPRESARIAL DATE;
    LDT_FIM_VIG_CAT_EMPRESARIAL DATE;
    LDT_INI_VIG_CONDOMINIO DATE;
    LDT_FIM_VIG_CONDOMINIO DATE;
    LCD_CORRETOR_CAT_CONDOMINIO VARCHAR2(6);
    LPERC_CORRETOR_CAT_CONDOMINIO NUMBER(5);
    LDT_INI_VIG_CAT_CONDOMINIO DATE;
    LDT_FIM_VIG_CAT_CONDOMINIO DATE;

     Cursor LD_CORRETORES
     Is
     Select CD_CORR,
            NM_CORR,
            CD_CONV,
            TP_PES,
            CPF_CGC_CORR,
            DDD_CORR,
            FONE_CORR,
            ESTADO,
            CIDADE,
            FORMA_PGTO,
            FORMA_PGTO_CARGA,
            FORMA_PGTO_RESIDENCIAL,
            FORMA_PGTO_EMPRESARIAL,
            FORMA_PGTO_CONDOMINIO,
            (TO_NUMBER(COMISSAOPADRAOPASSEIO) / 100) COMISSAOPADRAOPASSEIO,
            (TO_NUMBER(COMISSAOMAXPASSEIO) / 100) COMISSAOMAXPASSEIO,
            (TO_NUMBER(COMISSAOMINPASSEIO) / 100) COMISSAOMINPASSEIO,
            SINALDESCONTOPASSEIO,
            (TO_NUMBER(DESCONTOMAXPASSEIO) / 100) DESCONTOMAXPASSEIO,
            (TO_NUMBER(COMISSAOPADRAOCARGA) / 100) COMISSAOPADRAOCARGA,
            (TO_NUMBER(COMISSAOMAXCARGA) / 100) COMISSAOMAXCARGA,
            (TO_NUMBER(COMISSAOMINCARGA) / 100) COMISSAOMINCARGA,
            SINALDESCONTOCARGA,
            (TO_NUMBER(DESCONTOMAXCARGA) / 100) DESCONTOMAXCARGA,
            (TO_NUMBER(COMISSAOPADRAORESIDENCIAL) / 100) COMISSAOPADRAORESIDENCIAL,
            (TO_NUMBER(COMISSAOMAXRESIDENCIAL) / 100) COMISSAOMAXRESIDENCIAL,
            (TO_NUMBER(COMISSAOMINRESIDENCIAL) / 100) COMISSAOMINRESIDENCIAL,
            SINALDESCONTORESIDENCIAL,
            (TO_NUMBER(DESCONTOMAXRESIDENCIAL) / 100) DESCONTOMAXRESIDENCIAL,
            (TO_NUMBER(COMISSAOPADRAOEMPRESARIAL) / 100) COMISSAOPADRAOEMPRESARIAL,
            (TO_NUMBER(COMISSAOMAXEMPRESARIAL) / 100) COMISSAOMAXEMPRESARIAL,
            (TO_NUMBER(COMISSAOMINEMPRESARIAL) / 100) COMISSAOMINEMPRESARIAL,
            SINALDESCONTOEMPRESARIAL,
            (TO_NUMBER(DESCONTOMAXEMPRESARIAL) / 100) DESCONTOMAXEMPRESARIAL,
            (TO_NUMBER(COMISSAOPADRAOCONDOMINIO) / 100) COMISSAOPADRAOCONDOMINIO,
            (TO_NUMBER(COMISSAOMAXCONDOMINIO) / 100) COMISSAOMAXCONDOMINIO,
            (TO_NUMBER(COMISSAOMINCONDOMINIO) / 100) COMISSAOMINCONDOMINIO,
            SINALDESCONTOCONDOMINIO,
            (TO_NUMBER(DESCONTOMAXCONDOMINIO) / 100)    DESCONTOMAXCONDOMINIO,
            CATEGORIA,
            SUCURSAL,
            (TO_NUMBER(DESCONTOMINTIPOSEGURO) / 100) DESCONTOMINTIPOSEGURO,
            (TO_NUMBER(DESCONTOMAXTIPOSEGURO) / 100) DESCONTOMAXTIPOSEGURO,
            (TO_NUMBER(COMISSAOMINTIPOSEGURO) / 100) COMISSAOMINTIPOSEGURO,
            (TO_NUMBER(COMISSAOMAXTIPOSEGURO) / 100) COMISSAOMAXTIPOSEGURO,
            DT_INI_VIG_PASSEIO,
            DT_FIM_VIG_PASSEIO,
            CD_CORRETOR_CAT_PASSEIO,
            PERC_CORRETOR_CAT_PASSEIO,
            DT_INI_VIG_CAT_PASSEIO,
            DT_FIM_VIG_CAT_PASSEIO,
            DT_INI_VIG_CARGA,
            DT_FIM_VIG_CARGA,
            CD_CORRETOR_CAT_CARGA,
            PERC_CORRETOR_CAT_CARGA,
            DT_INI_VIG_CAT_CARGA,
            DT_FIM_VIG_CAT_CARGA,
            DT_INI_VIG_RESIDENCIAL,
            DT_FIM_VIG_RESIDENCIAL,
            CD_CORRETOR_CAT_RESIDENCIAL,
            PERC_CORRETOR_CAT_RESIDENCIAL,
            DT_INI_VIG_CAT_RESIDENCIAL,
            DT_FIM_VIG_CAT_RESIDENCIAL,
            DT_INI_VIG_EMPRESARIAL,
            DT_FIM_VIG_EMPRESARIAL,
            CD_CORRETOR_CAT_EMPRESARIAL,
            PERC_CORRETOR_CAT_EMPRESARIAL,
            DT_INI_VIG_CAT_EMPRESARIAL,
            DT_FIM_VIG_CAT_EMPRESARIAL,
            DT_INI_VIG_CONDOMINIO,
            DT_FIM_VIG_CONDOMINIO,
            CD_CORRETOR_CAT_CONDOMINIO,
            PERC_CORRETOR_CAT_CONDOMINIO,
            DT_INI_VIG_CAT_CONDOMINIO,
            DT_FIM_VIG_CAT_CONDOMINIO
       FROM REAL_CORRETORES_LD;

     Cursor RE_CORRETORES
     Is
     Select CORRETOR FROM REAL_CORRETORES WHERE CORRETOR = LCD_CORR;

     Cursor TB_DIVISOES
     Is
     Select DIVISAO FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LCD_CORR AND TIPO_DIVISAO = 'E';

     Cursor TB_DIVISOES2
     Is
     Select DIVISAO FROM TABELA_DIVISOESFONES WHERE DIVISAO = VDIVISAO AND DIVISAO_END = 1 AND DIVISAO_FONE = 1;
        --
        V_GPA                   NUMBER;
        v_cont_corretores       NUMBER;
        ct_corretores_incluidos         NUMBER  :=      0;
        ct_corretores_atualizados       NUMBER  :=      0;
        ct_corretores_com_erro          NUMBER  :=      0;
        --
        V_AMBIENTE          VARCHAR2(4000);
        V_FAULT_A        TMS_STORAGE.R_REQUEST_FAULT;
        V_CORRELATION_ID TMS_UTIL.CORRELATION_ID;
        V_BODY           CLOB;
        V_BLOB           BLOB;
        V_FILE           TMS_MAIL.FILE_TYPE;
        V_TO             TMS_MAIL.ADDRESS_TYPE;
        V_CC             TMS_MAIL.ADDRESS_TYPE;
        V_BCC            TMS_MAIL.ADDRESS_TYPE;
        --
  BEGIN

        --      Iniciando o GPA
        --
        BEGIN
                --
                TMS_GPA.INICIAR_PROCESSO('KCW_Carga_Corretores', SUBSTR(USER, 1, 8), '4402');
                --
                V_GPA := TMS_SESSION.GET_GPA_ID;
                --
                DBMS_OUTPUT.PUT_LINE('Processo GPA Iniciado...: ' || V_GPA);
                --
        EXCEPTION
                --
                WHEN OTHERS THEN
                        --
                        V_GPA   :=      1;
                        --
                        DBMS_OUTPUT.PUT_LINE('Erro ao iniciar GPA: ' || SQLERRM);
                        --
        END;
        --
        BEGIN
                --
                V_AMBIENTE := TMS_PARAM.GET_PARAM('RECEPCAO.ELETRONICA.CASOS.ABORTIVOS', 'AMBIENTE');
                --
        EXCEPTION
                --
                WHEN OTHERS THEN
                        --
                        TMS_GPA.ERRO(V_GPA, 'Erro ao buscar ambiente : ' || SQLERRM);
        END;
        --
        SELECT  Count(1)
        INTO    v_cont_corretores
        FROM    REAL_CORRETORES_LD;
        --
        TMS_GPA.INFO(V_GPA, 'Quantidade de Registros: ' || v_cont_corretores, NULL);
    --
    DBMS_OUTPUT.ENABLE(1000000);
    Open LD_CORRETORES;
    Loop
      Begin
         Fetch LD_CORRETORES Into LCD_CORR ,LNM_CORR ,LCD_CONV ,LTP_PES ,LCPF_CGC_CORR ,LDDD_CORR ,LFONE_CORR, LESTADO, LCIDADE,
               LFORMA_PGTO,LFORMA_PGTO_CARGA,LFORMA_PGTO_RESIDENCIAL,LFORMA_PGTO_EMPRESARIAL,LFORMA_PGTO_CONDOMINIO,
               LCOMISSAOPADRAOPASSEIO    , LCOMISSAOMAXPASSEIO    , LCOMISSAOMINPASSEIO    , LSINALDESCONTOPASSEIO    , LDESCONTOMAXPASSEIO,
               LCOMISSAOPADRAOCARGA      , LCOMISSAOMAXCARGA      , LCOMISSAOMINCARGA      , LSINALDESCONTOCARGA      , LDESCONTOMAXCARGA,
               LCOMISSAOPADRAORESIDENCIAL, LCOMISSAOMAXRESIDENCIAL,    LCOMISSAOMINRESIDENCIAL, LSINALDESCONTORESIDENCIAL, LDESCONTOMAXRESIDENCIAL,
               LCOMISSAOPADRAOEMPRESARIAL, LCOMISSAOMAXEMPRESARIAL, LCOMISSAOMINEMPRESARIAL, LSINALDESCONTOEMPRESARIAL, LDESCONTOMAXEMPRESARIAL,
               LCOMISSAOPADRAOCONDOMINIO , LCOMISSAOMAXCONDOMINIO , LCOMISSAOMINCONDOMINIO , LSINALDESCONTOCONDOMINIO , LDESCONTOMAXCONDOMINIO,
               LCATEGORIATARIFARIA, LSUCURSAL, LDESCONTOMINTIPOSEGURO, LDESCONTOMAXTIPOSEGURO, LCOMISSAOMINTIPOSEGURO, LCOMISSAOMAXTIPOSEGURO,
               LDT_INI_VIG_PASSEIO, LDT_FIM_VIG_PASSEIO, LCD_CORRETOR_CAT_PASSEIO, LPERC_CORRETOR_CAT_PASSEIO, LDT_INI_VIG_CAT_PASSEIO, LDT_FIM_VIG_CAT_PASSEIO,
               LDT_INI_VIG_CARGA, LDT_FIM_VIG_CARGA, LCD_CORRETOR_CAT_CARGA, LPERC_CORRETOR_CAT_CARGA, LDT_INI_VIG_CAT_CARGA, LDT_FIM_VIG_CAT_CARGA,
               LDT_INI_VIG_RESIDENCIAL, LDT_FIM_VIG_RESIDENCIAL, LCD_CORRETOR_CAT_RESIDENCIAL, LPERC_CORRETOR_CAT_RESIDENCIAL, LDT_INI_VIG_CAT_RESIDENCIAL, LDT_FIM_VIG_CAT_RESIDENCIAL,
               LDT_INI_VIG_EMPRESARIAL, LDT_FIM_VIG_EMPRESARIAL, LCD_CORRETOR_CAT_EMPRESARIAL, LPERC_CORRETOR_CAT_EMPRESARIAL, LDT_INI_VIG_CAT_EMPRESARIAL, LDT_FIM_VIG_CAT_EMPRESARIAL,
               LDT_INI_VIG_CONDOMINIO, LDT_FIM_VIG_CONDOMINIO, LCD_CORRETOR_CAT_CONDOMINIO, LPERC_CORRETOR_CAT_CONDOMINIO, LDT_INI_VIG_CAT_CONDOMINIO, LDT_FIM_VIG_CAT_CONDOMINIO;

         Exit When LD_CORRETORES%Notfound;
         if LCPF_CGC_CORR > 99999999999 then
            LPESSOA := 'J';
         else
            LPESSOA := 'F';
         end if;

         if LPESSOA = 'J' then
            RCPF_CGC_CORR := TRIM(TO_CHAR(LCPF_CGC_CORR, '999999999999999'));
            RCPF_CGC_CORR := substr(RCPF_CGC_CORR,1,2) || '.' ||
                             substr(RCPF_CGC_CORR,3,3) || '.' ||
                             substr(RCPF_CGC_CORR,6,3) || '/' ||
                             substr(RCPF_CGC_CORR,9,4) || '-' ||
                             substr(RCPF_CGC_CORR,13,2);
         else
            RCPF_CGC_CORR := TRIM(TO_CHAR(LCPF_CGC_CORR, '999999999999'));
            RCPF_CGC_CORR := substr(RCPF_CGC_CORR,1,3) || '.' ||
                             substr(RCPF_CGC_CORR,4,3) || '.' ||
                             substr(RCPF_CGC_CORR,7,3) || '-' ||
                             substr(RCPF_CGC_CORR,10,2);
         end if;

         if (TRIM(LFORMA_PGTO) <> 'P') and (TRIM(LFORMA_PGTO) <> 'V') then
           LFORMA_PGTO := null;
         end if;

         if (LSINALDESCONTOPASSEIO = '-') then
            LDESCONTOMAXPASSEIO := LDESCONTOMAXPASSEIO * -1;
         end if;

         if (LSINALDESCONTOCARGA = '-') then
            LDESCONTOMAXCARGA := LDESCONTOMAXCARGA * -1;
         end if;

         if (LSINALDESCONTORESIDENCIAL = '-') then
            LDESCONTOMAXRESIDENCIAL := LDESCONTOMAXRESIDENCIAL * -1;
         end if;

         if (LSINALDESCONTOEMPRESARIAL = '-') then
            LDESCONTOMAXEMPRESARIAL := LDESCONTOMAXEMPRESARIAL * -1;
         end if;

         if (LSINALDESCONTOCONDOMINIO = '-') then
            LDESCONTOMAXCONDOMINIO := LDESCONTOMAXCONDOMINIO * -1;
         end if;

         Open RE_CORRETORES;
         Fetch RE_CORRETORES Into TCORRETOR;
         if RE_CORRETORES%Notfound THEN
                --
             INSERT INTO REAL_CORRETORES(CORRETOR ,NOME, CPF_CNPJ, CONVENIO, DDD ,TELEFONE, TIPO_PESSOA,
                         FORMA_PGTO,FORMA_PGTO_CARGA,FORMA_PGTO_RESIDENCIAL,FORMA_PGTO_EMPRESARIAL,FORMA_PGTO_CONDOMINIO,
												 COMISSAOPADRAOPASSEIO    , COMISSAOMINPASSEIO    , COMISSAOMAXPASSEIO    , DESCONTOMAXPASSEIO,
												 COMISSAOPADRAOCARGA      , COMISSAOMINCARGA      , COMISSAOMAXCARGA      , DESCONTOMAXCARGA,
												 COMISSAOPADRAORESIDENCIAL, COMISSAOMINRESIDENCIAL, COMISSAOMAXRESIDENCIAL, DESCONTOMAXRESIDENCIAL,
												 COMISSAOPADRAOEMPRESARIAL, COMISSAOMINEMPRESARIAL, COMISSAOMAXEMPRESARIAL, DESCONTOMAXEMPRESARIAL,
												 COMISSAOPADRAOCONDOMINIO , COMISSAOMINCONDOMINIO , COMISSAOMAXCONDOMINIO , DESCONTOMAXCONDOMINIO,
												 CATEGORIA, SUCURSAL, DESCONTOMINTIPOSEGURO, DESCONTOMAXTIPOSEGURO, COMISSAOMINTIPOSEGURO, COMISSAOMAXTIPOSEGURO)

			 VALUES (LCD_CORR ,LNM_CORR, RCPF_CGC_CORR, LCD_CONV, TO_CHAR(LDDD_CORR) ,TO_CHAR(LFONE_CORR), LPESSOA,
			                                     LFORMA_PGTO, LFORMA_PGTO_CARGA, LFORMA_PGTO_RESIDENCIAL, LFORMA_PGTO_EMPRESARIAL, LFORMA_PGTO_CONDOMINIO,
												 LCOMISSAOPADRAOPASSEIO    , LCOMISSAOMINPASSEIO    , LCOMISSAOMAXPASSEIO    , LDESCONTOMAXPASSEIO,
												 LCOMISSAOPADRAOCARGA      , LCOMISSAOMINCARGA      , LCOMISSAOMAXCARGA      , LDESCONTOMAXCARGA,
												 LCOMISSAOPADRAORESIDENCIAL, LCOMISSAOMINRESIDENCIAL, LCOMISSAOMAXRESIDENCIAL, LDESCONTOMAXRESIDENCIAL,
												 LCOMISSAOPADRAOEMPRESARIAL, LCOMISSAOMINEMPRESARIAL, LCOMISSAOMAXEMPRESARIAL, LDESCONTOMAXEMPRESARIAL,
												 LCOMISSAOPADRAOCONDOMINIO , LCOMISSAOMINCONDOMINIO , LCOMISSAOMAXCONDOMINIO , LDESCONTOMAXCONDOMINIO,
												 LCATEGORIATARIFARIA, LSUCURSAL, LDESCONTOMINTIPOSEGURO, LDESCONTOMAXTIPOSEGURO, LCOMISSAOMINTIPOSEGURO,
                         LCOMISSAOMAXTIPOSEGURO);
                --
                TMS_GPA.Info(V_GPA, 'Corretor Incluido: ' || LCD_CORR, LCD_CORR);
                --
                ct_corretores_incluidos :=      ct_corretores_incluidos +       1;
                --
         ELSE
            UPDATE REAL_CORRETORES SET NOME = LNM_CORR,  CPF_CNPJ = RCPF_CGC_CORR, CONVENIO = LCD_CONV, DDD = TO_CHAR(LDDD_CORR),
                     TELEFONE = TO_CHAR(LFONE_CORR), TIPO_PESSOA = LPESSOA, FORMA_PGTO = LFORMA_PGTO,FORMA_PGTO_CARGA = LFORMA_PGTO_CARGA,
									   FORMA_PGTO_RESIDENCIAL = LFORMA_PGTO_RESIDENCIAL,FORMA_PGTO_EMPRESARIAL = LFORMA_PGTO_EMPRESARIAL,FORMA_PGTO_CONDOMINIO = LFORMA_PGTO_CONDOMINIO,
									   COMISSAOPADRAOPASSEIO     = LCOMISSAOPADRAOPASSEIO    , COMISSAOMAXPASSEIO     = LCOMISSAOMAXPASSEIO    , COMISSAOMINPASSEIO     = LCOMISSAOMINPASSEIO    , DESCONTOMAXPASSEIO     = LDESCONTOMAXPASSEIO,
									   COMISSAOPADRAOCARGA       = LCOMISSAOPADRAOCARGA      , COMISSAOMAXCARGA       = LCOMISSAOMAXCARGA      , COMISSAOMINCARGA       = LCOMISSAOMINCARGA      , DESCONTOMAXCARGA       = LDESCONTOMAXCARGA,
									   COMISSAOPADRAORESIDENCIAL = LCOMISSAOPADRAORESIDENCIAL, COMISSAOMAXRESIDENCIAL = LCOMISSAOMAXRESIDENCIAL, COMISSAOMINRESIDENCIAL = LCOMISSAOMINRESIDENCIAL, DESCONTOMAXRESIDENCIAL = LDESCONTOMAXRESIDENCIAL,
									   COMISSAOPADRAOEMPRESARIAL = LCOMISSAOPADRAOEMPRESARIAL, COMISSAOMAXEMPRESARIAL = LCOMISSAOMAXEMPRESARIAL, COMISSAOMINEMPRESARIAL = LCOMISSAOMINEMPRESARIAL, DESCONTOMAXEMPRESARIAL = LDESCONTOMAXEMPRESARIAL,
									   COMISSAOPADRAOCONDOMINIO  = LCOMISSAOPADRAOCONDOMINIO , COMISSAOMAXCONDOMINIO  = LCOMISSAOMAXCONDOMINIO , COMISSAOMINCONDOMINIO  = LCOMISSAOMINCONDOMINIO , DESCONTOMAXCONDOMINIO  = LDESCONTOMAXCONDOMINIO,
									   CATEGORIA        = LCATEGORIATARIFARIA       , SUCURSAL               = LSUCURSAL              , DESCONTOMINTIPOSEGURO  = LDESCONTOMINTIPOSEGURO , DESCONTOMAXTIPOSEGURO  = LDESCONTOMAXTIPOSEGURO,
                     COMISSAOMINTIPOSEGURO     = LCOMISSAOMINTIPOSEGURO    , COMISSAOMAXTIPOSEGURO  = LCOMISSAOMAXTIPOSEGURO
  								   WHERE CORRETOR = TCORRETOR;
                --
                TMS_GPA.Debug(V_GPA, 'Corretor Atualizado: ' || LCD_CORR, LCD_CORR);
                --
                ct_corretores_atualizados       :=      ct_corretores_atualizados       +       1;
                --
         END IF;
         --
         CLOSE RE_CORRETORES;

         -------------------------
         -- KIT0028_CRTOR_PACTE --
         -------------------------
         --(7=AUTO PASSEIO)
         MERGE
          INTO kit0028_crtor_pacte pacte
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_PASSEIO IS NOT NULL) real
            ON (pacte.cd_crtor = real.corretor AND
                pacte.cd_prdut = 7 AND
                pacte.dt_inico_vigen_pacote = LDT_INI_VIG_PASSEIO)
          WHEN MATCHED THEN
            UPDATE SET  pacte.cd_forma_pgto             = LFORMA_PGTO
                       ,pacte.pc_comis_pdrao            = LCOMISSAOPADRAOPASSEIO
                       ,pacte.pc_comis_minma            = LCOMISSAOMINPASSEIO
                       ,pacte.pc_comis_maxma            = LCOMISSAOMAXPASSEIO
                       ,pacte.pc_desct_maxmo            = LDESCONTOMAXPASSEIO
/*
                       ,pacte.pc_desct_minmo_tipo_segur = LDESCONTOMINTIPOSEGURO
                       ,pacte.pc_desct_maxmo_tipo_segur = LDESCONTOMAXTIPOSEGURO
                       ,pacte.pc_comis_minmo_tipo_segur = LCOMISSAOMINTIPOSEGURO
                       ,pacte.pc_comis_maxmo_tipo_segur = LCOMISSAOMAXTIPOSEGURO
*/
                       ,pacte.dt_fim_vigen_pacote       = LDT_FIM_VIG_PASSEIO
          WHEN NOT MATCHED THEN
            INSERT ( pacte.cd_crtor
                    ,pacte.cd_prdut
                    ,pacte.cd_forma_pgto
                    ,pacte.pc_comis_pdrao
                    ,pacte.pc_comis_minma
                    ,pacte.pc_comis_maxma
                    ,pacte.pc_desct_maxmo
/*
                    ,pacte.pc_desct_minmo_tipo_segur
                    ,pacte.pc_desct_maxmo_tipo_segur
                    ,pacte.pc_comis_minmo_tipo_segur
                    ,pacte.pc_comis_maxmo_tipo_segur
*/
                    ,pacte.dt_inico_vigen_pacote
                    ,pacte.dt_fim_vigen_pacote)
            VALUES ( LCD_CORR
                    ,7
                    ,LFORMA_PGTO
                    ,LCOMISSAOPADRAOPASSEIO
                    ,LCOMISSAOMINPASSEIO
                    ,LCOMISSAOMAXPASSEIO
                    ,LDESCONTOMAXPASSEIO
/*
                    ,LDESCONTOMINTIPOSEGURO
                    ,LDESCONTOMAXTIPOSEGURO
                    ,LCOMISSAOMINTIPOSEGURO
                    ,LCOMISSAOMAXTIPOSEGURO
*/
                    ,LDT_INI_VIG_PASSEIO
                    ,LDT_FIM_VIG_PASSEIO);

         --(9=AUTO CARGA)
         MERGE
          INTO kit0028_crtor_pacte pacte
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CARGA IS NOT NULL) real
            ON (pacte.cd_crtor = real.corretor AND
                pacte.cd_prdut = 9 AND
                pacte.dt_inico_vigen_pacote = LDT_INI_VIG_CARGA)
          WHEN MATCHED THEN
            UPDATE SET  pacte.cd_forma_pgto             = LFORMA_PGTO_CARGA
                       ,pacte.pc_comis_pdrao            = LCOMISSAOPADRAOCARGA
                       ,pacte.pc_comis_minma            = LCOMISSAOMINCARGA
                       ,pacte.pc_comis_maxma            = LCOMISSAOMAXCARGA
                       ,pacte.pc_desct_maxmo            = LDESCONTOMAXCARGA
/*
                       ,pacte.pc_desct_minmo_tipo_segur = LDESCONTOMINTIPOSEGURO
                       ,pacte.pc_desct_maxmo_tipo_segur = LDESCONTOMAXTIPOSEGURO
                       ,pacte.pc_comis_minmo_tipo_segur = LCOMISSAOMINTIPOSEGURO
                       ,pacte.pc_comis_maxmo_tipo_segur = LCOMISSAOMAXTIPOSEGURO
*/
                       ,pacte.dt_fim_vigen_pacote       = LDT_FIM_VIG_CARGA
          WHEN NOT MATCHED THEN
            INSERT ( pacte.cd_crtor
                    ,pacte.cd_prdut
                    ,pacte.cd_forma_pgto
                    ,pacte.pc_comis_pdrao
                    ,pacte.pc_comis_minma
                    ,pacte.pc_comis_maxma
                    ,pacte.pc_desct_maxmo
/*
                    ,pacte.pc_desct_minmo_tipo_segur
                    ,pacte.pc_desct_maxmo_tipo_segur
                    ,pacte.pc_comis_minmo_tipo_segur
                    ,pacte.pc_comis_maxmo_tipo_segur
*/
                    ,pacte.dt_inico_vigen_pacote
                    ,pacte.dt_fim_vigen_pacote)
            VALUES ( LCD_CORR
                    ,9
                    ,LFORMA_PGTO_CARGA
                    ,LCOMISSAOPADRAOCARGA
                    ,LCOMISSAOMINCARGA
                    ,LCOMISSAOMAXCARGA
                    ,LDESCONTOMAXCARGA
/*
                    ,LDESCONTOMINTIPOSEGURO
                    ,LDESCONTOMAXTIPOSEGURO
                    ,LCOMISSAOMINTIPOSEGURO
                    ,LCOMISSAOMAXTIPOSEGURO
*/
                    ,LDT_INI_VIG_CARGA
                    ,LDT_FIM_VIG_CARGA);

         --(11=EMPRESARIAL)
         MERGE
          INTO kit0028_crtor_pacte pacte
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_EMPRESARIAL IS NOT NULL) real
            ON (pacte.cd_crtor = real.corretor AND
                pacte.cd_prdut = 11 AND
                pacte.dt_inico_vigen_pacote = LDT_INI_VIG_EMPRESARIAL)
          WHEN MATCHED THEN
            UPDATE SET  pacte.cd_forma_pgto             = LFORMA_PGTO_EMPRESARIAL
                       ,pacte.pc_comis_pdrao            = LCOMISSAOPADRAOEMPRESARIAL
                       ,pacte.pc_comis_minma            = LCOMISSAOMINEMPRESARIAL
                       ,pacte.pc_comis_maxma            = LCOMISSAOMAXEMPRESARIAL
                       ,pacte.pc_desct_maxmo            = LDESCONTOMAXEMPRESARIAL
/*
                       ,pacte.pc_desct_minmo_tipo_segur = LDESCONTOMINTIPOSEGURO
                       ,pacte.pc_desct_maxmo_tipo_segur = LDESCONTOMAXTIPOSEGURO
                       ,pacte.pc_comis_minmo_tipo_segur = LCOMISSAOMINTIPOSEGURO
                       ,pacte.pc_comis_maxmo_tipo_segur = LCOMISSAOMAXTIPOSEGURO
*/
                       ,pacte.dt_fim_vigen_pacote       = LDT_FIM_VIG_EMPRESARIAL
          WHEN NOT MATCHED THEN
            INSERT ( pacte.cd_crtor
                    ,pacte.cd_prdut
                    ,pacte.cd_forma_pgto
                    ,pacte.pc_comis_pdrao
                    ,pacte.pc_comis_minma
                    ,pacte.pc_comis_maxma
                    ,pacte.pc_desct_maxmo
/*
                    ,pacte.pc_desct_minmo_tipo_segur
                    ,pacte.pc_desct_maxmo_tipo_segur
                    ,pacte.pc_comis_minmo_tipo_segur
                    ,pacte.pc_comis_maxmo_tipo_segur
*/
                    ,pacte.dt_inico_vigen_pacote
                    ,pacte.dt_fim_vigen_pacote)
            VALUES ( LCD_CORR
                    ,11
                    ,LFORMA_PGTO_EMPRESARIAL
                    ,LCOMISSAOPADRAOEMPRESARIAL
                    ,LCOMISSAOMINEMPRESARIAL
                    ,LCOMISSAOMAXEMPRESARIAL
                    ,LDESCONTOMAXEMPRESARIAL
/*
                    ,LDESCONTOMINTIPOSEGURO
                    ,LDESCONTOMAXTIPOSEGURO
                    ,LCOMISSAOMINTIPOSEGURO
                    ,LCOMISSAOMAXTIPOSEGURO
*/
                    ,LDT_INI_VIG_EMPRESARIAL
                    ,LDT_FIM_VIG_EMPRESARIAL);

         --(14=RESIDENCIAL)
         MERGE
          INTO kit0028_crtor_pacte pacte
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_RESIDENCIAL IS NOT NULL) real
            ON (pacte.cd_crtor = real.corretor AND
                pacte.cd_prdut = 14 AND
                pacte.dt_inico_vigen_pacote = LDT_INI_VIG_RESIDENCIAL)
          WHEN MATCHED THEN
            UPDATE SET  pacte.cd_forma_pgto             = LFORMA_PGTO_RESIDENCIAL
                       ,pacte.pc_comis_pdrao            = LCOMISSAOPADRAORESIDENCIAL
                       ,pacte.pc_comis_minma            = LCOMISSAOMINRESIDENCIAL
                       ,pacte.pc_comis_maxma            = LCOMISSAOMAXRESIDENCIAL
                       ,pacte.pc_desct_maxmo            = LDESCONTOMAXRESIDENCIAL
/*
                       ,pacte.pc_desct_minmo_tipo_segur = LDESCONTOMINTIPOSEGURO
                       ,pacte.pc_desct_maxmo_tipo_segur = LDESCONTOMAXTIPOSEGURO
                       ,pacte.pc_comis_minmo_tipo_segur = LCOMISSAOMINTIPOSEGURO
                       ,pacte.pc_comis_maxmo_tipo_segur = LCOMISSAOMAXTIPOSEGURO
*/
                       ,pacte.dt_fim_vigen_pacote       = LDT_FIM_VIG_RESIDENCIAL
          WHEN NOT MATCHED THEN
            INSERT ( pacte.cd_crtor
                    ,pacte.cd_prdut
                    ,pacte.cd_forma_pgto
                    ,pacte.pc_comis_pdrao
                    ,pacte.pc_comis_minma
                    ,pacte.pc_comis_maxma
                    ,pacte.pc_desct_maxmo
/*
                    ,pacte.pc_desct_minmo_tipo_segur
                    ,pacte.pc_desct_maxmo_tipo_segur
                    ,pacte.pc_comis_minmo_tipo_segur
                    ,pacte.pc_comis_maxmo_tipo_segur
*/
                    ,pacte.dt_inico_vigen_pacote
                    ,pacte.dt_fim_vigen_pacote)
            VALUES ( LCD_CORR
                    ,14
                    ,LFORMA_PGTO_RESIDENCIAL
                    ,LCOMISSAOPADRAORESIDENCIAL
                    ,LCOMISSAOMINRESIDENCIAL
                    ,LCOMISSAOMAXRESIDENCIAL
                    ,LDESCONTOMAXRESIDENCIAL
/*
                    ,LDESCONTOMINTIPOSEGURO
                    ,LDESCONTOMAXTIPOSEGURO
                    ,LCOMISSAOMINTIPOSEGURO
                    ,LCOMISSAOMAXTIPOSEGURO
*/
                    ,LDT_INI_VIG_RESIDENCIAL
                    ,LDT_FIM_VIG_RESIDENCIAL);

         --(12=CONDOMINIO)
         MERGE
          INTO kit0028_crtor_pacte pacte
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CONDOMINIO IS NOT NULL) real
            ON (pacte.cd_crtor = real.corretor AND
                pacte.cd_prdut = 12 AND
                pacte.dt_inico_vigen_pacote = LDT_INI_VIG_CONDOMINIO)
          WHEN MATCHED THEN
            UPDATE SET  pacte.cd_forma_pgto             = LFORMA_PGTO_CONDOMINIO
                       ,pacte.pc_comis_pdrao            = LCOMISSAOPADRAOCONDOMINIO
                       ,pacte.pc_comis_minma            = LCOMISSAOMINCONDOMINIO
                       ,pacte.pc_comis_maxma            = LCOMISSAOMAXCONDOMINIO
                       ,pacte.pc_desct_maxmo            = LDESCONTOMAXCONDOMINIO
/*
                       ,pacte.pc_desct_minmo_tipo_segur = LDESCONTOMINTIPOSEGURO
                       ,pacte.pc_desct_maxmo_tipo_segur = LDESCONTOMAXTIPOSEGURO
                       ,pacte.pc_comis_minmo_tipo_segur = LCOMISSAOMINTIPOSEGURO
                       ,pacte.pc_comis_maxmo_tipo_segur = LCOMISSAOMAXTIPOSEGURO
*/
                       ,pacte.dt_fim_vigen_pacote       = LDT_FIM_VIG_CONDOMINIO
          WHEN NOT MATCHED THEN
            INSERT ( pacte.cd_crtor
                    ,pacte.cd_prdut
                    ,pacte.cd_forma_pgto
                    ,pacte.pc_comis_pdrao
                    ,pacte.pc_comis_minma
                    ,pacte.pc_comis_maxma
                    ,pacte.pc_desct_maxmo
/*
                    ,pacte.pc_desct_minmo_tipo_segur
                    ,pacte.pc_desct_maxmo_tipo_segur
                    ,pacte.pc_comis_minmo_tipo_segur
                    ,pacte.pc_comis_maxmo_tipo_segur
*/
                    ,pacte.dt_inico_vigen_pacote
                    ,pacte.dt_fim_vigen_pacote)
            VALUES ( LCD_CORR
                    ,12
                    ,LFORMA_PGTO_CONDOMINIO
                    ,LCOMISSAOPADRAOCONDOMINIO
                    ,LCOMISSAOMINCONDOMINIO
                    ,LCOMISSAOMAXCONDOMINIO
                    ,LDESCONTOMAXCONDOMINIO
/*
                    ,LDESCONTOMINTIPOSEGURO
                    ,LDESCONTOMAXTIPOSEGURO
                    ,LCOMISSAOMINTIPOSEGURO
                    ,LCOMISSAOMAXTIPOSEGURO
*/
                    ,LDT_INI_VIG_CONDOMINIO
                    ,LDT_FIM_VIG_CONDOMINIO);

         -------------------------
         -- KIT0029_CRTOR_FRANQ --
         -------------------------
         --(7=AUTO PASSEIO)
         MERGE
          INTO kit0029_crtor_franq franq
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CAT_PASSEIO IS NOT NULL) real
            ON (franq.cd_crtor = real.corretor AND
                franq.cd_prdut = 7 AND
                franq.dt_inico_vigen_franq = LDT_INI_VIG_CAT_PASSEIO)
          WHEN MATCHED THEN
            UPDATE SET  cd_crtor_franq     = LCD_CORRETOR_CAT_PASSEIO
					   ,pc_crtor_franq     = (LPERC_CORRETOR_CAT_PASSEIO / 100)
                       ,dt_fim_vigen_franq = LDT_FIM_VIG_CAT_PASSEIO
          WHEN NOT MATCHED THEN
            INSERT ( franq.cd_crtor
                    ,franq.cd_prdut
					,cd_crtor_franq
					,pc_crtor_franq
                    ,dt_inico_vigen_franq
                    ,dt_fim_vigen_franq)
            VALUES ( LCD_CORR
                    ,7
					,LCD_CORRETOR_CAT_PASSEIO
					,(LPERC_CORRETOR_CAT_PASSEIO / 100)
                    ,LDT_INI_VIG_CAT_PASSEIO
                    ,LDT_FIM_VIG_CAT_PASSEIO);

         --(9=AUTO CARGA)
         MERGE
          INTO kit0029_crtor_franq franq
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CAT_CARGA IS NOT NULL) real
            ON (franq.cd_crtor = real.corretor AND
                franq.cd_prdut = 9 AND
                franq.dt_inico_vigen_franq = LDT_INI_VIG_CAT_CARGA)
          WHEN MATCHED THEN
            UPDATE SET  cd_crtor_franq     = LCD_CORRETOR_CAT_CARGA
					   ,pc_crtor_franq     = (LPERC_CORRETOR_CAT_CARGA / 100)
                       ,dt_fim_vigen_franq = LDT_FIM_VIG_CAT_CARGA
          WHEN NOT MATCHED THEN
            INSERT ( franq.cd_crtor
                    ,franq.cd_prdut
					,cd_crtor_franq
					,pc_crtor_franq
                    ,dt_inico_vigen_franq
                    ,dt_fim_vigen_franq)
            VALUES ( LCD_CORR
                    ,9
					,LCD_CORRETOR_CAT_CARGA
					,(LPERC_CORRETOR_CAT_CARGA / 100)
                    ,LDT_INI_VIG_CAT_CARGA
                    ,LDT_FIM_VIG_CAT_CARGA);

         --(11=EMPRESARIAL)
         MERGE
          INTO kit0029_crtor_franq franq
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CAT_EMPRESARIAL IS NOT NULL) real
            ON (franq.cd_crtor = real.corretor AND
                franq.cd_prdut = 11 AND
                franq.dt_inico_vigen_franq = LDT_INI_VIG_CAT_EMPRESARIAL)
          WHEN MATCHED THEN
            UPDATE SET  cd_crtor_franq     = LCD_CORRETOR_CAT_EMPRESARIAL
					   ,pc_crtor_franq     = (LPERC_CORRETOR_CAT_EMPRESARIAL / 100)
                       ,dt_fim_vigen_franq = LDT_FIM_VIG_CAT_EMPRESARIAL
          WHEN NOT MATCHED THEN
            INSERT ( franq.cd_crtor
                    ,franq.cd_prdut
					,cd_crtor_franq
					,pc_crtor_franq
                    ,dt_inico_vigen_franq
                    ,dt_fim_vigen_franq)
            VALUES ( LCD_CORR
                    ,11
					,LCD_CORRETOR_CAT_EMPRESARIAL
					,(LPERC_CORRETOR_CAT_EMPRESARIAL / 100)
                    ,LDT_INI_VIG_CAT_EMPRESARIAL
                    ,LDT_FIM_VIG_CAT_EMPRESARIAL);

         --(14=RESIDENCIAL)
         MERGE
          INTO kit0029_crtor_franq franq
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CAT_RESIDENCIAL IS NOT NULL) real
            ON (franq.cd_crtor = real.corretor AND
                franq.cd_prdut = 14 AND
                franq.dt_inico_vigen_franq = LDT_INI_VIG_CAT_RESIDENCIAL)
          WHEN MATCHED THEN
            UPDATE SET  cd_crtor_franq     = LCD_CORRETOR_CAT_RESIDENCIAL
					   ,pc_crtor_franq     = (LPERC_CORRETOR_CAT_RESIDENCIAL / 100)
                       ,dt_fim_vigen_franq = LDT_FIM_VIG_CAT_RESIDENCIAL
          WHEN NOT MATCHED THEN
            INSERT ( franq.cd_crtor
                    ,franq.cd_prdut
					,cd_crtor_franq
					,pc_crtor_franq
                    ,dt_inico_vigen_franq
                    ,dt_fim_vigen_franq)
            VALUES ( LCD_CORR
                    ,14
					,LCD_CORRETOR_CAT_RESIDENCIAL
					,(LPERC_CORRETOR_CAT_RESIDENCIAL / 100)
                    ,LDT_INI_VIG_CAT_RESIDENCIAL
                    ,LDT_FIM_VIG_CAT_RESIDENCIAL);

         --(12=CONDOMINIO)
         MERGE
          INTO kit0029_crtor_franq franq
         USING (SELECT corretor
		          FROM real_corretores
				 WHERE corretor = LCD_CORR
				   AND LDT_INI_VIG_CAT_CONDOMINIO IS NOT NULL) real
            ON (franq.cd_crtor = real.corretor AND
                franq.cd_prdut = 12 AND
                franq.dt_inico_vigen_franq = LDT_INI_VIG_CAT_CONDOMINIO)
          WHEN MATCHED THEN
            UPDATE SET  cd_crtor_franq     = LCD_CORRETOR_CAT_CONDOMINIO
					   ,pc_crtor_franq     = (LPERC_CORRETOR_CAT_CONDOMINIO / 100)
                       ,dt_fim_vigen_franq = LDT_FIM_VIG_CAT_CONDOMINIO
          WHEN NOT MATCHED THEN
            INSERT ( franq.cd_crtor
                    ,franq.cd_prdut
					,cd_crtor_franq
					,pc_crtor_franq
                    ,dt_inico_vigen_franq
                    ,dt_fim_vigen_franq)
            VALUES ( LCD_CORR
                    ,12
					,LCD_CORRETOR_CAT_CONDOMINIO
					,(LPERC_CORRETOR_CAT_CONDOMINIO / 100)
                    ,LDT_INI_VIG_CAT_CONDOMINIO
                    ,LDT_FIM_VIG_CAT_CONDOMINIO);

         Open TB_DIVISOES;
         Fetch TB_DIVISOES Into TCORRETOR;
         if TB_DIVISOES%Notfound then
            SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VDIVISAO FROM DUAL;
            INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO, TIPO_PESSOA, CGC_CPF, HOME_PAGE, CONTA_CORRENTE, DIVISAO_SUPERIOR, FOTO, SITUACAO, DATA_INCLUSAO, COD_CONV,  DDD)
                                 VALUES (VDIVISAO,LNM_CORR, 'E', '1', LPESSOA, RCPF_CGC_CORR,            LCIDADE, LESTADO,       LCD_CORR,    1,      'A', sysdate,       LCD_CONV, '0019');
         else
            UPDATE TABELA_DIVISOES SET NOME = LNM_CORR, TIPO_PESSOA = LPESSOA, CGC_CPF = RCPF_CGC_CORR, COD_CONV = LCD_CONV, HOME_PAGE = LCIDADE, CONTA_CORRENTE = LESTADO
            WHERE DIVISAO_SUPERIOR = LCD_CORR AND TIPO_DIVISAO = 'E';
            VDIVISAO := TCORRETOR;
         end if;
         CLOSE TB_DIVISOES;

         Open TB_DIVISOES2;
         Fetch TB_DIVISOES2 Into TCORRETOR;
         if TB_DIVISOES2%Notfound then
            INSERT INTO TABELA_DIVISOESFONES (DIVISAO, DIVISAO_END, DIVISAO_FONE, TELEFONE, DDD, RAMAL, TIPO_TELEFONE, SITUACAO, DATA_INCLUSAO, DATA_ALTERACAO) VALUES
                                             (VDIVISAO, 1, 1, TO_CHAR(LFONE_CORR), TO_CHAR(LDDD_CORR), NULL, 0, NULL, NULL, NULL);
         else
            UPDATE TABELA_DIVISOESFONES SET TELEFONE = TO_CHAR(LFONE_CORR) , DDD = TO_CHAR(LDDD_CORR)
            WHERE DIVISAO = VDIVISAO AND DIVISAO_END = 1 AND DIVISAO_FONE = 1;
         end if;
         CLOSE TB_DIVISOES2;

         COMMIT;

      Exception
        when OTHERS then
        begin
           ROLLBACK;
           if RE_CORRETORES%ISOPEN then
             CLOSE RE_CORRETORES;
           End If;
           if TB_DIVISOES%ISOPEN then
             CLOSE TB_DIVISOES;
           End If;
           if TB_DIVISOES2%ISOPEN then
             CLOSE TB_DIVISOES2;
           End If;
           --
           TMS_GPA.Erro(V_GPA, 'Ocorreu um erro ao tentar gravar o corretor: '||TO_CHAR(LCD_CORR)||'-'||TRIM(LNM_CORR)||'  -  Mensagem: ' || SQLERRM, LCD_CORR);
           --
           ct_corretores_com_erro       :=      ct_corretores_com_erro      +       1;
           --
           --dbms_output.PUT_LINE('Ocorreu um erro ao tentar gravar o corretor: '||TO_CHAR(LCD_CORR)||'-'||TRIM(LNM_CORR)||'  -  Mensagem: '||SQLERRM);
        End;
      End;
    End Loop;
    Close LD_CORRETORES;
    --
        --
        TMS_GPA.Info(V_GPA, 'Qtde Corretores Incluidos: ' || ct_corretores_incluidos, NULL);
        --
        TMS_GPA.Info(V_GPA, 'Qtde Corretores Atualizados: ' || ct_corretores_atualizados, NULL);
        --
        TMS_GPA.Info(V_GPA, 'Qtde Corretores com erro: ' || ct_corretores_com_erro, NULL);
        --
        v_to(1) :=      'edmilson.martins@tokiomarine.com.br';
        --
        v_to(2) :=      'mikal.matsumoto@tokiomarine.com.br';
        --
        v_to(3) :=      'vivian.oliveira@tokiomarine.com.br';
        --
        IF      ct_corretores_com_erro  >       0       THEN
                --
                V_BODY := TO_CLOB('Procedure CARGA_CORRETORES. ' || ct_corretores_com_erro || ' corretores apresentaram erro. Vide GPA ' || v_gpa || '.');
                --
                BEGIN
                        --
                        TMS_MAIL.SEND_HTML('kcw@tokiomarine.com.br', V_TO, V_CC, V_BCC, '[' || V_AMBIENTE || ' - KCW] - Problema na Carga de Corretores'
                        , V_BODY, V_FILE, V_FAULT_A, V_CORRELATION_ID);
                        --
                EXCEPTION
                        --
                        WHEN OTHERS THEN
                                --
                                TMS_GPA.ERRO(V_GPA, 'Erro ao enviar e-mail - corretores com erro: ' || SQLERRM);
                                --
                END;
                --
        END     IF;
        --
        DELETE REAL_CORRETORES_LD;
        --
        TMS_GPA.Info(V_GPA, 'Tabela REAL_CORRETORES_LD excluida.', NULL);
        --
        COMMIT;
        --
        BEGIN
                --
                Utl_File.fremove        ('DIRKIT_DAT'
                                        ,'ssakit09.dat');
                --
                TMS_GPA.Info(V_GPA, 'Arquivo ssakit09.dat excluido.', NULL);
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        TMS_GPA.Erro(V_GPA, 'Problema ao excluir arquivo ssakit09.dat ' || SQLERRM , NULL);
                        --
                        V_BODY := TO_CLOB('Procedure CARGA_CORRETORES. Erro ao excluir arquivo ssakit09.dat. Se o arquivo n„o for excluido o plano do TWS das 16h ler· o mesmo arquivo. Vide GPA ' || v_gpa || '. ' || SQLERRM);
                        --
                        BEGIN
                                --
                                TMS_MAIL.SEND_HTML('kcw@tokiomarine.com.br', V_TO, V_CC, V_BCC, '[' || V_AMBIENTE || ' - KCW] - Problema na Carga de Corretores'
                                , V_BODY, V_FILE, V_FAULT_A, V_CORRELATION_ID);
                                --
                        EXCEPTION
                                --
                                WHEN OTHERS THEN
                                        --
                                        TMS_GPA.ERRO(V_GPA, 'Erro ao enviar e-mail - erro ao excluir arquivo: ' || SQLERRM);
                                        --
                        END;
                        --
        END;
        --
        TMS_GPA.FINALIZAR_PROCESSO;
    --
  END;
END;
/


CREATE OR REPLACE PROCEDURE        CARGA_ESTIPULANTES IS
BEGIN
  DECLARE
    LNO_ESTIPULANTE                                     NUMBER(5);
    LNM_ESTIPULANTE                                     VARCHAR2(40);
    LCD_CORRETOR                                        NUMBER(6);
    LCD_MODULO                                          NUMBER(5);
    LCD_AGE_CAPTADORA1                                  NUMBER(5);
    LCD_AGE_CAPTADORA2                                  NUMBER(5);
    LCD_AGE_CAPTADORA3                                  NUMBER(5);
    LCD_AGE_CAPTADORA4                                  NUMBER(5);
    LCD_AGE_CAPTADORA5                                  NUMBER(5);
    LCD_AGE_CAPTADORA6                                  NUMBER(5);
    LCD_AGE_CAPTADORA7                                  NUMBER(5);
    LCD_AGE_CAPTADORA8                                  NUMBER(5);
    LCD_AGE_CAPTADORA9                                  NUMBER(5);
    LCD_AGE_CAPTADORA10                                 NUMBER(5);
    LCD_AGE_CAPTADORA11                                 NUMBER(5);
    LCD_AGE_CAPTADORA12                                 NUMBER(5);
    LCD_AGE_CAPTADORA13                                 NUMBER(5);
    LCD_AGE_CAPTADORA14                                 NUMBER(5);
    LCD_AGE_CAPTADORA15                                 NUMBER(5);
    LCD_AGE_CAPTADORA16                                 NUMBER(5);
    LCD_AGE_CAPTADORA17                                 NUMBER(5);
    LCD_AGE_CAPTADORA18                                 NUMBER(5);
    LCD_AGE_CAPTADORA19                                 NUMBER(5);
    LCD_AGE_CAPTADORA20                                 NUMBER(5);
    LTX_COMISSAO_PADRAO                                 NUMBER(5);
    LTX_COMISSAO_MINIMA                                 NUMBER(5);
    LTX_COMISSAO_MAXIMA                                 NUMBER(5);
    LTX_PROLABORE                                       NUMBER(5);
    LTX_DESCONTO                                        NUMBER(5);
    LDT_INI_VIG_COMERC                                  DATE;
    LDT_FIM_VIG_COMERC                                  DATE;
    LFINAL_VIGENCIA_OLD                                 DATE;
    TESTIPULANTE NUMBER(18);
    TAGENCIA NUMBER(18);
    VESTIPULANTE NUMBER(18);
    VAGENCIA NUMBER(18);
    LAGENCIA NUMBER(18);
    RCPF_CGC_CORR VARCHAR2(18);
    TTESTE VARCHAR(6);
    LDDD_CORR NUMBER(4,0);
    LFONE_CORR NUMBER(9,0);
    LPESSOA VARCHAR2(1);
    TPRODUTO NUMBER(18);
    TFROTA  NUMBER(8);
    Cursor LD_ESTIPULANTES Is
       Select NO_ESTIPULANTE,NM_ESTIPULANTE, CD_CORRETOR ,CD_MODULO,CD_AGE_CAPTADORA1
       ,CD_AGE_CAPTADORA2,CD_AGE_CAPTADORA3,CD_AGE_CAPTADORA4,CD_AGE_CAPTADORA5
       ,CD_AGE_CAPTADORA6,CD_AGE_CAPTADORA7,CD_AGE_CAPTADORA8,CD_AGE_CAPTADORA9
       ,CD_AGE_CAPTADORA10,CD_AGE_CAPTADORA11,CD_AGE_CAPTADORA12,CD_AGE_CAPTADORA13
       ,CD_AGE_CAPTADORA14,CD_AGE_CAPTADORA15,CD_AGE_CAPTADORA16,CD_AGE_CAPTADORA17
       ,CD_AGE_CAPTADORA18,CD_AGE_CAPTADORA19,CD_AGE_CAPTADORA20,TX_COMISSAO_PADRAO
       ,TX_COMISSAO_MINIMA,TX_COMISSAO_MAXIMA,TX_PROLABORE,TX_DESCONTO,DT_INI_VIG_COMERC
       ,DT_FIM_VIG_COMERC
       FROM TABELA_CARGA_COND_EST_LD;
    Cursor TB_DIVISOES Is
       Select DIVISAO, FINALVIGENCIA FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LNO_ESTIPULANTE AND TIPO_DIVISAO = 'B';
    Cursor TB_DIVISOES2 Is
     Select DIVISAO FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LAGENCIA AND TIPO_DIVISAO = 'A';
    Cursor TB_DIVISOESC Is
       Select DIVISAO FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LAGENCIA AND TIPO_DIVISAO = 'E';
    Cursor TB_DIVISOESCOMER Is
       SELECT DIVISAO FROM TABELA_DIVISOESCOMER
       WHERE DIVISAO = TESTIPULANTE
         AND PRODUTO = TPRODUTO
         AND DIVISAOCOM =  LCD_CORRETOR
         AND INICIOVIGENCIA = LDT_INI_VIG_COMERC;		 
	e_produto_many_rows EXCEPTION;
  BEGIN
   DBMS_OUTPUT.ENABLE(1000000);
   UPDATE TABELA_DIVISOES SET SITUACAO = 'I' WHERE TIPO_DIVISAO = 'B';
   Open LD_ESTIPULANTES;
    Loop
     Begin
        Fetch LD_ESTIPULANTES Into LNO_ESTIPULANTE,LNM_ESTIPULANTE,LCD_CORRETOR,LCD_MODULO,LCD_AGE_CAPTADORA1
            ,LCD_AGE_CAPTADORA2,LCD_AGE_CAPTADORA3,LCD_AGE_CAPTADORA4,LCD_AGE_CAPTADORA5
            ,LCD_AGE_CAPTADORA6,LCD_AGE_CAPTADORA7,LCD_AGE_CAPTADORA8,LCD_AGE_CAPTADORA9
            ,LCD_AGE_CAPTADORA10,LCD_AGE_CAPTADORA11,LCD_AGE_CAPTADORA12,LCD_AGE_CAPTADORA13
            ,LCD_AGE_CAPTADORA14,LCD_AGE_CAPTADORA15,LCD_AGE_CAPTADORA16,LCD_AGE_CAPTADORA17
            ,LCD_AGE_CAPTADORA18,LCD_AGE_CAPTADORA19,LCD_AGE_CAPTADORA20,LTX_COMISSAO_PADRAO
            ,LTX_COMISSAO_MINIMA,LTX_COMISSAO_MAXIMA,LTX_PROLABORE,LTX_DESCONTO,LDT_INI_VIG_COMERC
            ,LDT_FIM_VIG_COMERC;
          Exit When LD_ESTIPULANTES%Notfound;
         Open TB_DIVISOES;
          Fetch TB_DIVISOES Into TESTIPULANTE, LFINAL_VIGENCIA_OLD;
          if TB_DIVISOES%Notfound then
             SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VESTIPULANTE FROM DUAL;
             INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, INICIOVIGENCIA, FINALVIGENCIA)
                                  VALUES (VESTIPULANTE,LNM_ESTIPULANTE, 'B', '1',   LNO_ESTIPULANTE     ,    'A', sysdate, LDT_INI_VIG_COMERC,LDT_FIM_VIG_COMERC);
             TESTIPULANTE := VESTIPULANTE;
          else
            --Se o final de vigencia do registro na base for maior que o que est· vindo no arquivo, mantemos o da base
             IF LFINAL_VIGENCIA_OLD > LDT_FIM_VIG_COMERC THEN
                UPDATE TABELA_DIVISOES SET NOME = LNM_ESTIPULANTE, data_alteracao = sysdate, INICIOVIGENCIA = LDT_INI_VIG_COMERC, FINALVIGENCIA = LFINAL_VIGENCIA_OLD, SITUACAO = 'A'
                WHERE DIVISAO_SUPERIOR = LNO_ESTIPULANTE AND TIPO_DIVISAO = 'B';
             ELSE
                UPDATE TABELA_DIVISOES SET NOME = LNM_ESTIPULANTE, data_alteracao = sysdate, INICIOVIGENCIA = LDT_INI_VIG_COMERC, FINALVIGENCIA = LDT_FIM_VIG_COMERC, SITUACAO = 'A'
                WHERE DIVISAO_SUPERIOR = LNO_ESTIPULANTE AND TIPO_DIVISAO = 'B';
             END IF;
          end if;

         IF LCD_AGE_CAPTADORA1 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA1;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         if LCD_AGE_CAPTADORA2 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA2;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA3 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA3;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         if LCD_AGE_CAPTADORA4 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA4;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA5 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA5;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA6 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA6;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA7 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA7;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA8 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA8;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA9 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA9;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA10 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA10;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA11 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA11;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         if LCD_AGE_CAPTADORA12 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA12;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA13 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA13;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                          VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA14 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA14;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA15 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA15;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA16 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA16;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA17 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA17;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA18 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA18;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA'||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA19 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA19;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         IF LCD_AGE_CAPTADORA20 <> 0 then
            LAGENCIA := LCD_AGE_CAPTADORA20;
            Open TB_DIVISOES2;
            Fetch TB_DIVISOES2 Into TAGENCIA;
            if TB_DIVISOES2%Notfound then
               SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
               INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                           VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAGENCIA), 'A', '1',   LAGENCIA     ,    'A', sysdate, TO_CHAR(LAGENCIA));
               TAGENCIA := VAGENCIA;
            end if;
            BEGIN
              INSERT INTO TABELA_DIVISOESPAI VALUES (TESTIPULANTE, TAGENCIA);
            Exception
              When OTHERS then
                  dbms_output.PUT_LINE('');
            end;
            close TB_DIVISOES2;
         end if;
         --Pegando o codigo do produto
         IF LCD_MODULO = 9 THEN
			TPRODUTO := 11;
		 ELSE
			BEGIN
				SELECT produto 
				  INTO TPRODUTO 
				  FROM mult_produtos 
				 WHERE produtocol = LCD_MODULO;

			EXCEPTION
				WHEN OTHERS THEN
					RAISE e_produto_many_rows;
					--dbms_output.put_line('Erro ao Selecionar o Produto referente ao MÛdulo ' || LCD_MODULO);

			END;
		 END IF;
         if LCD_CORRETOR <> '000435' then
           LAGENCIA := LCD_CORRETOR;
         else
           LAGENCIA := 43551;
         end if;
         Open TB_DIVISOESC;
         Fetch TB_DIVISOESC Into TAGENCIA;
         if TB_DIVISOESC%Notfound then
            LCD_CORRETOR := 0;
         else
            LCD_CORRETOR := TAGENCIA;
         end if;
         close TB_DIVISOESC;
         Open TB_DIVISOESCOMER;
         Fetch TB_DIVISOESCOMER Into TAGENCIA;
         IF TB_DIVISOESCOMER%NOTFOUND THEN
            INSERT INTO TABELA_DIVISOESCOMER (DIVISAO, DIVISAOCOM, PRODUTO, PRO_LABORE, DESCONTO, COMISSAO, COMISSAOMIN, COMISSAOMAX, INICIOVIGENCIA, FINALVIGENCIA) VALUES
                                             (TESTIPULANTE, LCD_CORRETOR, TPRODUTO, LTX_PROLABORE / 100, LTX_DESCONTO / 100, LTX_COMISSAO_PADRAO / 100, LTX_COMISSAO_MINIMA / 100, LTX_COMISSAO_MAXIMA / 100, LDT_INI_VIG_COMERC, LDT_FIM_VIG_COMERC);
            --IF TPRODUTO = 10 THEN
            --   INSERT INTO TABELA_DIVISOESCOMER (DIVISAO, DIVISAOCOM, PRODUTO, PRO_LABORE, DESCONTO, COMISSAO, COMISSAOMIN, COMISSAOMAX, INICIOVIGENCIA, FINALVIGENCIA) VALUES
            --                               (TESTIPULANTE, LCD_CORRETOR, 40, LTX_PROLABORE / 100, LTX_DESCONTO / 100, LTX_COMISSAO_PADRAO / 100, LTX_COMISSAO_MINIMA / 100, LTX_COMISSAO_MAXIMA / 100, LDT_INI_VIG_COMERC, LDT_FIM_VIG_COMERC);
            --else
            --  IF TPRODUTO = 11 THEN
            --    INSERT INTO TABELA_DIVISOESCOMER (DIVISAO, DIVISAOCOM, PRODUTO, PRO_LABORE, DESCONTO, COMISSAO, COMISSAOMIN, COMISSAOMAX, INICIOVIGENCIA, FINALVIGENCIA) VALUES
            --                                 (TESTIPULANTE, LCD_CORRETOR, 41, LTX_PROLABORE / 100, LTX_DESCONTO / 100, LTX_COMISSAO_PADRAO / 100, LTX_COMISSAO_MINIMA / 100, LTX_COMISSAO_MAXIMA / 100, LDT_INI_VIG_COMERC, LDT_FIM_VIG_COMERC);
            --  end if;
            --end if;
         else
            UPDATE TABELA_DIVISOESCOMER SET DIVISAOCOM = LCD_CORRETOR, PRO_LABORE = LTX_PROLABORE / 100, DESCONTO = LTX_DESCONTO / 100, COMISSAO = LTX_COMISSAO_PADRAO / 100, COMISSAOMIN = LTX_COMISSAO_MINIMA / 100, COMISSAOMAX = LTX_COMISSAO_MAXIMA / 100, FINALVIGENCIA = LDT_FIM_VIG_COMERC
            WHERE DIVISAO = TESTIPULANTE AND DIVISAOCOM = LCD_CORRETOR AND PRODUTO = TPRODUTO  AND INICIOVIGENCIA = LDT_INI_VIG_COMERC;
            --if TPRODUTO = 10 then
            --  TFROTA := 0;
            --  SELECT COUNT(*) INTO TFROTA FROM TABELA_DIVISOESCOMER WHERE DIVISAO = TESTIPULANTE AND DIVISAOCOM = LCD_CORRETOR AND PRODUTO = 40  AND INICIOVIGENCIA = LDT_INI_VIG_COMERC;
            --  IF TFROTA > 0 THEN
            --      UPDATE TABELA_DIVISOESCOMER SET DIVISAOCOM = LCD_CORRETOR, PRO_LABORE = LTX_PROLABORE / 100, DESCONTO = LTX_DESCONTO / 100, COMISSAO = LTX_COMISSAO_PADRAO / 100, COMISSAOMIN = LTX_COMISSAO_MINIMA / 100, COMISSAOMAX = LTX_COMISSAO_MAXIMA / 100, FINALVIGENCIA = LDT_FIM_VIG_COMERC
            --      WHERE DIVISAO = TESTIPULANTE AND DIVISAOCOM = LCD_CORRETOR AND PRODUTO = 40  AND INICIOVIGENCIA = LDT_INI_VIG_COMERC;
            --  ELSE
            --      INSERT INTO TABELA_DIVISOESCOMER (DIVISAO, DIVISAOCOM, PRODUTO, PRO_LABORE, DESCONTO, COMISSAO, COMISSAOMIN, COMISSAOMAX, INICIOVIGENCIA, FINALVIGENCIA) VALUES
            --                          (TESTIPULANTE, LCD_CORRETOR, 40, LTX_PROLABORE / 100, LTX_DESCONTO / 100, LTX_COMISSAO_PADRAO / 100, LTX_COMISSAO_MINIMA / 100, LTX_COMISSAO_MAXIMA / 100, LDT_INI_VIG_COMERC, LDT_FIM_VIG_COMERC);
            --  end if;
            --else
            --  if TPRODUTO = 11 then
            --    TFROTA := 0;
            --    SELECT COUNT(*) INTO TFROTA FROM TABELA_DIVISOESCOMER  WHERE DIVISAO = TESTIPULANTE AND DIVISAOCOM = LCD_CORRETOR AND PRODUTO = 41  AND INICIOVIGENCIA = LDT_INI_VIG_COMERC;
            --    IF TFROTA > 0 THEN
            --        UPDATE TABELA_DIVISOESCOMER SET DIVISAOCOM = LCD_CORRETOR, PRO_LABORE = LTX_PROLABORE / 100, DESCONTO = LTX_DESCONTO / 100, COMISSAO = LTX_COMISSAO_PADRAO / 100, COMISSAOMIN = LTX_COMISSAO_MINIMA / 100, COMISSAOMAX = LTX_COMISSAO_MAXIMA / 100, FINALVIGENCIA = LDT_FIM_VIG_COMERC
            --        WHERE DIVISAO = TESTIPULANTE AND DIVISAOCOM = LCD_CORRETOR AND PRODUTO = 41 AND INICIOVIGENCIA = LDT_INI_VIG_COMERC;
            --    ELSE
            --        INSERT INTO TABELA_DIVISOESCOMER (DIVISAO, DIVISAOCOM, PRODUTO, PRO_LABORE, DESCONTO, COMISSAO, COMISSAOMIN, COMISSAOMAX, INICIOVIGENCIA, FINALVIGENCIA) VALUES
            --                          (TESTIPULANTE, LCD_CORRETOR, 41, LTX_PROLABORE / 100, LTX_DESCONTO / 100, LTX_COMISSAO_PADRAO / 100, LTX_COMISSAO_MINIMA / 100, LTX_COMISSAO_MAXIMA / 100, LDT_INI_VIG_COMERC, LDT_FIM_VIG_COMERC);
            --    end if;
            --  end if;
            --end if;
         end if;
       close TB_DIVISOESCOMER;
       CLOSE TB_DIVISOES;
       COMMIT;
   Exception
    When e_produto_many_rows then
		TPRODUTO := NULL;
		dbms_output.put_line('Erro de "Retorno com M˙ltiplas Linhas" ao Selecionar o Produto referente ao MÛdulo ' || LCD_MODULO || '  -  Mensagem: '|| SQLERRM);
		
    When OTHERS then
      begin
        ROLLBACK;
        If TB_DIVISOES%ISOPEN Then
          Close TB_DIVISOES;
        End If;
        IF TB_DIVISOES2%ISOPEN THEN
          Close TB_DIVISOES2;
        End If;
        IF TB_DIVISOESC%ISOPEN THEN
          Close TB_DIVISOESC;
        End If;
        IF TB_DIVISOESCOMER%ISOPEN THEN
          Close TB_DIVISOESCOMER;
        End If;
        dbms_output.PUT_LINE('Ocorreu um erro ao tentar gravar o estipulante: '||TO_CHAR(LNO_ESTIPULANTE)|| '-'||TRIM(LNM_ESTIPULANTE)||'  -  Mensagem: '||SQLERRM);
      end;
   end;
  End Loop;
    Close LD_ESTIPULANTES;
    DELETE TABELA_CARGA_COND_EST_LD;
    COMMIT;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "CARGA_FABRICANTES" IS
BEGIN
  DECLARE
    LNO_ESTIPULANTE NUMBER(5,0);
    LCD_MODULO1 NUMBER(5,0);
    LcD_FABRICANTE1 NUMBER(9,0);
    LCD_MODULO2 NUMBER(5,0);
    LCD_FABRICANTE2 NUMBER(9,0);
    LCD_MODULO3 NUMBER(5,0);
    LCD_FABRICANTE3 NUMBER(9,0);
    LCD_MODULO4 NUMBER(5,0);
    LCD_FABRICANTE4 NUMBER(9,0);
    LCD_MODULO5 NUMBER(5,0);
    LCD_FABRICANTE5 NUMBER(9,0);
    LCD_MODULO6 NUMBER(5,0);
    LCD_FABRICANTE6 NUMBER(9,0);
    LCD_MODULO7 NUMBER(5,0);
    LCD_FABRICANTE7 NUMBER(9,0);
    LCD_MODULO8 NUMBER(5,0);
    LCD_FABRICANTE8 NUMBER(9,0);
    LCD_MODULO9 NUMBER(5,0);
    LCD_FABRICANTE9 NUMBER(9,0);
    LCD_MODULO0 NUMBER(5,0);
    LCD_FABRICANTE0 NUMBER(9,0);
    LDT_INI_VIG  DATE;
    LDT_FIM_VIG  DATE;
    Cursor LD_FABRICANTES Is
       Select
    NO_ESTIPULANTE,CD_MODULO1,
    cD_FABRICANTE1,CD_MODULO2,
    cD_FABRICANTE2,CD_MODULO3,
    cD_FABRICANTE3,CD_MODULO4,
    cD_FABRICANTE4,CD_MODULO5,
    cD_FABRICANTE5,CD_MODULO6,
    cD_FABRICANTE6,CD_MODULO7,
    cD_FABRICANTE7,CD_MODULO8,
    cD_FABRICANTE8,CD_MODULO9,
    cD_FABRICANTE9,CD_MODULO0,
    cD_FABRICANTE0,DT_INI_VIG,DT_FIM_VIG FROM REAL_ESTFAB_LD;
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DELETE REAL_ESTFAB;
    Open LD_FABRICANTES;
    Loop
       Begin
          Fetch LD_FABRICANTES Into LNO_ESTIPULANTE,LCD_MODULO1,
                              LcD_FABRICANTE1,LCD_MODULO2,
                              LcD_FABRICANTE2,LCD_MODULO3,
                              LcD_FABRICANTE3,LCD_MODULO4,
                              LcD_FABRICANTE4,LCD_MODULO5,
                              LcD_FABRICANTE5,LCD_MODULO6,
                              LcD_FABRICANTE6,LCD_MODULO7,
                              LcD_FABRICANTE7,LCD_MODULO8,
                              LcD_FABRICANTE8,LCD_MODULO9,
                              LcD_FABRICANTE9,LCD_MODULO0,
                              LcD_FABRICANTE0,LDT_INI_VIG,LDT_FIM_VIG;
          Exit When LD_FABRICANTES%Notfound;
          INSERT INTO REAL_ESTFAB VALUES
          (LNO_ESTIPULANTE ,LCD_MODULO1,LcD_FABRICANTE1,
                            LCD_MODULO2,LcD_FABRICANTE2,
                            LCD_MODULO3,LcD_FABRICANTE3,
                            LCD_MODULO4,LcD_FABRICANTE4,
                            LCD_MODULO5,LcD_FABRICANTE5,
                            LCD_MODULO6,LcD_FABRICANTE6,
                            LCD_MODULO7,LcD_FABRICANTE7,
                            LCD_MODULO8,LcD_FABRICANTE8,
                            LCD_MODULO9,LcD_FABRICANTE9,
                            LCD_MODULO0,LcD_FABRICANTE0);
       Exception
          when OTHERS then
             dbms_output.PUT_LINE('Ocorreu um erro ao tentar gravar os fabricantes para o estipulante: '||TO_CHAR(LNO_ESTIPULANTE)||'  -  Mensagem: '||SQLERRM);
       End;
    End Loop;
    Close LD_FABRICANTES;
    DELETE REAL_ESTFAB_LD;
    COMMIT;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "CARGA_PLACA" IS
BEGIN
  DECLARE
    LNO_PLACA VARCHAR2(7);
    Cursor LD_PLACA Is
       Select
    PLACA from TABELA_PLACARESTRITA_LD;
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DELETE TABELA_PLACARESTRITA;
    Open LD_PLACA;
    Loop
       Begin
          Fetch LD_PLACA Into LNO_PLACA;
          Exit When LD_PLACA%Notfound;
          INSERT INTO TABELA_PLACARESTRITA VALUES
          (LNO_PLACA);
       Exception
          when OTHERS then
             dbms_output.PUT_LINE('Ocorreu um erro ao tentar gravar os placas restritas: '||TO_CHAR(LNO_PLACA)||'  -  Mensagem: '||SQLERRM);
       End;
    End Loop;
    Close LD_PLACA;
    DELETE TABELA_PLACARESTRITA_LD;
    COMMIT;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "CARGA_USUARIOS" IS
BEGIN
  DECLARE
    LID_USUARIO                                         VARCHAR2(14);
    LNM_USUARIO                                         VARCHAR2(30);
    LCD_CORRETOR_USU                                    NUMBER(6);
    LAG_CAPTADORA_USU                                   NUMBER(5);
    LTP_USUARIO                                         VARCHAR2(1);
    LCD_PADRAO_USU                                      VARCHAR2(1);
    LTB_ESTIPULANTE1                                    NUMBER(5);
    LTB_ESTIPULANTE2                                    NUMBER(5);
    LTB_ESTIPULANTE3                                    NUMBER(5);
    LTB_ESTIPULANTE4                                    NUMBER(5);
    LTB_ESTIPULANTE5                                    NUMBER(5);
    LTB_ESTIPULANTE6                                    NUMBER(5);
    LTB_ESTIPULANTE7                                    NUMBER(5);
    LTB_ESTIPULANTE8                                    NUMBER(5);
    LTB_ESTIPULANTE9                                    NUMBER(5);
    LTB_ESTIPULANTE0                                    NUMBER(5);
    LDT_INI_VIG_USU                                     DATE;
    LDT_FIM_VIG_USU                                     DATE;
    LDT_ULT_ALT_USU                                     DATE;
    LHR_ULT_ALT_USU                                     NUMBER(7);
    LMN_RESP_ULT_ALT_USU                                VARCHAR2(8);
    VAGENCIA NUMBER(8);
    LNO_ESTIPULANTE NUMBER(8);
    TESTIPULANTE NUMBER(8);
    Cursor LD_USUARIOS Is
       Select ID_USUARIO,NM_USUARIO,CD_CORRETOR_USU,AG_CAPTADORA_USU,TP_USUARIO,
             CD_PADRAO_USU,TB_ESTIPULANTE1,TB_ESTIPULANTE2,TB_ESTIPULANTE3,
             TB_ESTIPULANTE4,TB_ESTIPULANTE5,TB_ESTIPULANTE6,TB_ESTIPULANTE7,
             TB_ESTIPULANTE8,TB_ESTIPULANTE9,TB_ESTIPULANTE0,DT_INI_VIG_USU,
             DT_FIM_VIG_USU,DT_ULT_ALT_USU,HR_ULT_ALT_USU,MN_RESP_ULT_ALT_USU
       FROM REAL_USUARIOS_LD;
    Cursor TB_DIVISOES Is
       Select DIVISAO FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LNO_ESTIPULANTE AND TIPO_DIVISAO = 'B';
    Cursor TB_DIVISOESC Is
       Select DIVISAO FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LNO_ESTIPULANTE AND TIPO_DIVISAO = 'E';
    Cursor TB_DIVISOESA Is
       Select DIVISAO FROM TABELA_DIVISOES WHERE DIVISAO_SUPERIOR = LNO_ESTIPULANTE AND TIPO_DIVISAO = 'A';
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DELETE REAL_USUARIOS;
    Open LD_USUARIOS;
    Loop
      Begin
          Fetch LD_USUARIOS Into LID_USUARIO,LNM_USUARIO,LCD_CORRETOR_USU,LAG_CAPTADORA_USU,LTP_USUARIO,
             LCD_PADRAO_USU,LTB_ESTIPULANTE1,LTB_ESTIPULANTE2,LTB_ESTIPULANTE3,
             LTB_ESTIPULANTE4,LTB_ESTIPULANTE5,LTB_ESTIPULANTE6,LTB_ESTIPULANTE7,
             LTB_ESTIPULANTE8,LTB_ESTIPULANTE9,LTB_ESTIPULANTE0,LDT_INI_VIG_USU,
             LDT_FIM_VIG_USU,LDT_ULT_ALT_USU,LHR_ULT_ALT_USU,LMN_RESP_ULT_ALT_USU;
          Exit When LD_USUARIOS%Notfound;
          LNO_ESTIPULANTE := LCD_CORRETOR_USU;
          Open TB_DIVISOESC;
          Fetch TB_DIVISOESC Into TESTIPULANTE;
          if TB_DIVISOESC%Notfound then
             LCD_CORRETOR_USU := 0;
          else
             LCD_CORRETOR_USU := TESTIPULANTE;
          end if;
          close TB_DIVISOESC;

          LNO_ESTIPULANTE := LAG_CAPTADORA_USU;
          if LAG_CAPTADORA_USU <> 0 then
          Open TB_DIVISOESA;
          Fetch TB_DIVISOESA Into TESTIPULANTE;
          if TB_DIVISOESA%Notfound then
             SELECT FUNC_CONTADOR('TABELA_DIVISOES') INTO VAGENCIA FROM DUAL;
             INSERT INTO TABELA_DIVISOES (DIVISAO, NOME, TIPO_DIVISAO, TEM_ENDERECO,  DIVISAO_SUPERIOR,  SITUACAO, DATA_INCLUSAO, COD_CONV)
                         VALUES (VAGENCIA,'AGENCIA '||TO_CHAR(LAG_CAPTADORA_USU), 'A', '1',   LAG_CAPTADORA_USU     ,    'A', sysdate, TO_CHAR(LAG_CAPTADORA_USU));
             LAG_CAPTADORA_USU := VAGENCIA;
          else
             LAG_CAPTADORA_USU := TESTIPULANTE;
          end if;
          close TB_DIVISOESA;
          end if;
          IF LTB_ESTIPULANTE1 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE1;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE1 := 0;
             else
                LTB_ESTIPULANTE1 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE2 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE2;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE2 := 0;
             else
                LTB_ESTIPULANTE2 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE3 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE3;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE3 := 0;
             else
                LTB_ESTIPULANTE3 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE4 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE4;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE4 := 0;
             else
                LTB_ESTIPULANTE4 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE5 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE5;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE5 := 0;
             else
                LTB_ESTIPULANTE5 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE6 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE6;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE6 := 0;
             else
                LTB_ESTIPULANTE6 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE7 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE7;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE7 := 0;
             else
                LTB_ESTIPULANTE7 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE8 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE8;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE8 := 0;
             else
                LTB_ESTIPULANTE8 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          IF LTB_ESTIPULANTE9 <> 0 THEN
             LNO_ESTIPULANTE := LTB_ESTIPULANTE9;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE9 := 0;
             else
                LTB_ESTIPULANTE9 := TESTIPULANTE;
             end if;
             close TB_DIVISOES;
          END IF;
          If LTB_ESTIPULANTE0 <> 0 then
             LNO_ESTIPULANTE := LTB_ESTIPULANTE0;
             Open TB_DIVISOES;
             Fetch TB_DIVISOES Into TESTIPULANTE;
             if TB_DIVISOES%Notfound then
                LTB_ESTIPULANTE0 := 0;
             else
                LTB_ESTIPULANTE0 := TESTIPULANTE;
             End if;
             close TB_DIVISOES;
          End If;

          INSERT INTO REAL_USUARIOS VALUES
            (TRIM(LID_USUARIO),LCD_CORRETOR_USU, LDT_INI_VIG_USU, LNM_USUARIO, LAG_CAPTADORA_USU ,LTP_USUARIO, LCD_PADRAO_USU, LTB_ESTIPULANTE1,LTB_ESTIPULANTE2,LTB_ESTIPULANTE3,
              LTB_ESTIPULANTE4,LTB_ESTIPULANTE5,LTB_ESTIPULANTE6,LTB_ESTIPULANTE7,
               LTB_ESTIPULANTE8,LTB_ESTIPULANTE9,LTB_ESTIPULANTE0, LDT_FIM_VIG_USU);
      Commit;
      Exception
        When OTHERS  then
        Begin
           RollBack;
           if TB_DIVISOES%ISOPEN then
             Close TB_DIVISOES;
           end if;
           if TB_DIVISOESC%ISOPEN then
             Close TB_DIVISOESC;
           end if;
           if TB_DIVISOESA%ISOPEN then
             Close TB_DIVISOESA;
           end if;
           dbms_output.PUT_LINE('Ocorreu um erro ao tentar gravar o usuario: '||TRIM(LID_USUARIO)||'-'||TRIM(LNM_USUARIO)||'  -  Mensagem: '||SQLERRM);
        End;
      End;
    End Loop;
    Close LD_USUARIOS;
    Delete REAL_USUARIOS_LD;
    Commit;
  END;
END;
/


CREATE OR REPLACE PROCEDURE CRIA_BASE_CALCULO IS
  V_PARAMETRO_DIAS      NUMBER;
  V_DATA_CORTE          DATE;
  V_FLAG_ULTIMA_LIMPEZA VARCHAR2(50);

BEGIN

  -- LIMPA OS DADOS DA TABELA TEMPORARIA ----------------------
  EXECUTE IMMEDIATE 'DROP INDEX IDX01_BASE_CALCULO';
  EXECUTE IMMEDIATE 'DROP INDEX IDX02_BASE_CALCULO';

  -- VERIFICA SE ULTIMA LIMPEZE FOI COM SUCESSO
  -- SO APAGA OS CALCULOS SE NAO HOUVE ERRO NO PROCESSAMENTO
  SELECT VALOR
    INTO V_FLAG_ULTIMA_LIMPEZA
    FROM TABELA_CONFIGURACOES_KCW
   WHERE PARAMETRO = 'FLAG_ULTIMA_LIMPEZA';

  IF V_FLAG_ULTIMA_LIMPEZA = 'SUCESSO' THEN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE BASE_CALCULO';
  END IF;

  -- INSERE DADOS PARA DELETAR ----------------------

  -- POLITICA DE DELECAO KCW
  SELECT VALOR
    INTO V_PARAMETRO_DIAS
    FROM TABELA_CONFIGURACOES_KCW
   WHERE PARAMETRO = 'COTACOES_KCW_DIAS_MANTIDOS';

  V_DATA_CORTE := TRUNC(SYSDATE - V_PARAMETRO_DIAS);

  INSERT /*+ APPEND */
  INTO BASE_CALCULO
    (SELECT CALCULO, 0
       FROM MULT_CALCULO
      WHERE SITE = 'P'
        AND DATAPRIMEIROCALCULO < V_DATA_CORTE
        AND SITUACAO IN ('P', 'C'));
  COMMIT;

  -- POLITICA DE DELECAO WS
  SELECT VALOR
    INTO V_PARAMETRO_DIAS
    FROM TABELA_CONFIGURACOES_KCW
   WHERE PARAMETRO = 'COTACOES_WS_DIAS_MANTIDOS';

  V_DATA_CORTE := TRUNC(SYSDATE - V_PARAMETRO_DIAS);

  INSERT /*+ APPEND */
  INTO BASE_CALCULO
    (SELECT CALCULO, 0
       FROM MULT_CALCULO
      WHERE SITE = 'W'
        AND DATAPRIMEIROCALCULO < V_DATA_CORTE
        AND SITUACAO IN ('P', 'C'));
  COMMIT;

  /*  -- POLITICA DE DELECAO RENOVACAO
  SELECT VALOR
    INTO V_PARAMETRO_DIAS
    FROM TABELA_CONFIGURACOES_KCW
   WHERE PARAMETRO = 'COTACOES_REN_DIAS_MANTIDOS';
  
  V_DATA_CORTE := TRUNC(SYSDATE - V_PARAMETRO_DIAS);
  
  INSERT \*+ APPEND *\
  INTO BASE_CALCULO
    (SELECT CALCULO, 0
       FROM MULT_CALCULO
      WHERE SITE IS NULL
        AND INICIOVIGENCIARENOV < v_DATA_CORTE
        AND SITUACAO = 'P'
        AND CALCULOORIGEM > 0);
  COMMIT;*/

  -- AJUSTA OS INDICES DOS CALCULOS ----------------------------
  UPDATE BASE_CALCULO SET LIN_NUM = ROWNUM;
  COMMIT;

  EXECUTE IMMEDIATE 'CREATE INDEX IDX01_BASE_CALCULO ON
                    BASE_CALCULO(CALCULO)';

  EXECUTE IMMEDIATE 'CREATE INDEX IDX02_BASE_CALCULO ON
                    BASE_CALCULO(LIN_NUM)';
END;
/


CREATE OR REPLACE procedure        duplica_calculo (PCALCULO_OLD IN FLOAT,PCALCULO_NEW OUT FLOAT)
IS
BEGIN
    SELECT FUNC_CONTADOR('MULT_CALCULO') INTO PCALCULO_NEW FROM DUAL;

    /*Inserindo Mult_Calculo*/
    INSERT INTO MULT_CALCULO (
			   CALCULO,ITEM,ESTIPULANTE,CLIENTE,GRUPO,PADRAO,FABRICANTE,PROCEDENCIA,MODELO,ANOMODELO,
			   ANOFABRICACAO,ZEROKM,VALORVEICULO,CEP,NIVELDM,NIVELDP,VALORAPPMORTE,VALORAPPINV,VALORAPPDMH,
			   TIPO_COBERTURA,TIPO_FRANQUIA,NIVELBONUSAUTO,NIVELBONUSDM,NIVELBONUSDP,INICIOVIGENCIA,
			   FINALVIGENCIA,DATACALCULO,DATAPRIMEIROCALCULO, QTDDIAS,CONDICAO,COMISSAO,DESCONTOCOMISSAO,CIARENOVA,QTDSINISTROS,
			   ENDERECO,NUMERO,COMPLEMENTO,BAIRRO,CIDADE,ESTADO,ITEMSEGURADO,TIPOPRODUTO,NUMPASSAGEIROS,
			   SITUACAO,PLACA,COD_CIDADE,COD_REFERENCIA,COD_TABELA,VALORBASE,AJUSTE,NOME,VALIDADE,NUMCONDUTORES,
			   NUMDEPENDENTES,CHASSI,TIPODOCUMENTO,CALCULOORIGEM,OBSERVACAO,ITEMORIGEM,CAMPO1,CAMPO2,CAMPO3,
			   CAMPO4,CAMPO5,CAMPO6,NUMEROTITULO,DATAVENCIMENTO,LOTE,DATAEMISSAO,TIPOFROTA,DV,
			   DIFERE,ANGARIADOR,VENDEDOR,QTDANOSRENOVA,SUBSCRICAO,TAXA,TAXA1,TAXA2,TAXA3,TAXA4,TAXA5,VLRFRANQUIASUB,
			   TAXAFRANQUIASUB,VMINFRANQUIASUB,OCOR_SIN,ITEM_SUBST,SENHA_RENOV,DESC_SCORE,ORIGEM_DESC_SCORE,MVERSAO,
			   VALORASS24H,GEROUCROSS,NIVELDMSUB,APOL_REN_TOKIO,ITEM_REN_TOKIO,BONUS_REN_TOKIO,SIN_REN_TOKIO,INDICASUB,
			   P_AJUSTE,NUMPASSAG,TIPO_DESC_SCORE,TIPO_PESSOA,BLINDAGEM,LMI_BLINDAGEM,LMI_KITGAS,MODALIDADE,IDS_ACEITACAO,
			   COD_USUARIO,SITE,O_CT_IDS_,CD_FIPE, IND_RENOVACAO500, VERSAOCALCULO,TIPOUSOVEIC, NOMECONDU, CPFCONDU, CNHCONDU,
			   DTNASCONDU, SEXOCONDU, ESTCVCONDU,PGTO_BANCO_HONDA,PRAZO,COMISSAO_COMP,TIPOSEGURO, CALC_ONLINE, TIPOLOGRADOURO,SEMNUMERO,
		       AGRAVO, CALC_PAI, TIPO_CALCULO, CONDICOES_ESPECIAIS, RETORNOCRIVO, TIPO_CARROCERIA)
    SELECT PCALCULO_NEW as CALCULO, ITEM, ESTIPULANTE,
           CLIENTE, GRUPO, PADRAO, FABRICANTE, PROCEDENCIA, MODELO, ANOMODELO, ANOFABRICACAO,
           ZEROKM,VALORVEICULO, CEP, NIVELDM, NIVELDP, VALORAPPMORTE, VALORAPPINV, VALORAPPDMH,
           TIPO_COBERTURA, TIPO_FRANQUIA, NIVELBONUSAUTO, NIVELBONUSDM, NIVELBONUSDP, INICIOVIGENCIA,
           FINALVIGENCIA,
           TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD'),'YYYY-MM-DD'), TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM-DD'),'YYYY-MM-DD') AS DATAPRIMEIROCALCULO,
		   QTDDIAS, CONDICAO, COMISSAO, DESCONTOCOMISSAO, CIARENOVA,
           QTDSINISTROS, ENDERECO, NUMERO, COMPLEMENTO, BAIRRO, CIDADE, ESTADO, ITEMSEGURADO,
           TIPOPRODUTO, NUMPASSAGEIROS, 'P' as SITUACAO, PLACA, COD_CIDADE, COD_REFERENCIA, COD_TABELA,
           VALORBASE, AJUSTE, NOME, VALIDADE, NUMCONDUTORES, NUMDEPENDENTES, CHASSI, TIPODOCUMENTO,
           0, OBSERVACAO, ITEMORIGEM, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5, CAMPO6,
           null, null as DATAVENCIMENTO, LOTE, DATAEMISSAO, TIPOFROTA, null, DIFERE,
           ANGARIADOR, VENDEDOR, QTDANOSRENOVA, SUBSCRICAO, TAXA, TAXA1, TAXA2, TAXA3, TAXA4, TAXA5,
           VLRFRANQUIASUB, TAXAFRANQUIASUB, VMINFRANQUIASUB, OCOR_SIN, ITEM_SUBST, SENHA_RENOV,DESC_SCORE,
           ORIGEM_DESC_SCORE, MVERSAO, VALORASS24H,GEROUCROSS, NIVELDMSUB, APOL_REN_TOKIO,ITEM_REN_TOKIO,
           BONUS_REN_TOKIO, SIN_REN_TOKIO, INDICASUB, P_AJUSTE, NUMPASSAG, TIPO_DESC_SCORE, TIPO_PESSOA,
           BLINDAGEM,LMI_BLINDAGEM,LMI_KITGAS,MODALIDADE,IDS_ACEITACAO,COD_USUARIO,'P' as SITE,O_CT_IDS_,CD_FIPE, IND_RENOVACAO500,
           VERSAOCALCULO, TIPOUSOVEIC, NOMECONDU, CPFCONDU, CNHCONDU, DTNASCONDU, SEXOCONDU, ESTCVCONDU,PGTO_BANCO_HONDA,PRAZO,
		   COMISSAO_COMP,TIPOSEGURO, CALC_ONLINE, TIPOLOGRADOURO,SEMNUMERO, AGRAVO, PCALCULO_OLD AS CALC_PAI, 1 as TIPO_CALCULO,
		   CONDICOES_ESPECIAIS, RETORNOCRIVO, TIPO_CARROCERIA
    FROM MULT_CALCULO WHERE CALCULO = PCALCULO_OLD;


    /*Inserindo AcessÛrios*/
    INSERT INTO MULT_CALCULOACES (CALCULO,ITEM,ACESSORIO,DESCRICAO,TIPO,SUBTIPO,VALOR,PREMIO)
    SELECT PCALCULO_NEW as CALCULO, ITEM, ACESSORIO, DESCRICAO, TIPO, SUBTIPO, VALOR, PREMIO
    FROM MULT_CALCULOACES WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo bens*/
    INSERT INTO MULT_CALCULOBENS (CALCULO, ITEM, OBJETO, NOME, VALOR,  FRANQUIA, PERCENTUAL,
           IDADE, DATACOMPRA, TIPO, NUMEROSERIE)
    SELECT PCALCULO_NEW as CALCULO, ITEM, OBJETO, NOME, VALOR, FRANQUIA, PERCENTUAL,
           IDADE, DATACOMPRA, TIPO, NUMEROSERIE
    FROM MULT_CALCULOBENS WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Coberturas*/
    INSERT INTO MULT_CALCULOCOB (CALCULO,ITEM,COBERTURA,CONDUTOR,ESCOLHA,VALOR,OPCAO,OBSERVACAO,TIPO,TAXA,FRANQUIA,PREMIO,SOLICITA,PCONDUTOR,SCONDUTOR,DCONDUTOR,MOSTRA)
    SELECT PCALCULO_NEW as CALCULO, ITEM , COBERTURA, CONDUTOR, ESCOLHA, VALOR, OPCAO, OBSERVACAO, TIPO,
           TAXA, FRANQUIA, PREMIO, SOLICITA, PCONDUTOR, SCONDUTOR, DCONDUTOR, MOSTRA
    FROM MULT_CALCULOCOB WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo OpÁıes de Coberturas*/
    INSERT INTO MULT_CALCULOCOBOP (CALCULO,ITEM,COBERTURA,CONDUTOR,OPCAO,ESCOLHA,VALOR)
    SELECT PCALCULO_NEW as CALCULO, ITEM, COBERTURA, CONDUTOR, OPCAO, ESCOLHA, VALOR
    FROM MULT_CALCULOCOBOP WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo CondiÁıes de Pagamento*/
    INSERT INTO MULT_CALCULOCOND (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,CONDICAO,ESCOLHA)
    SELECT PCALCULO_NEW as CALCULO, ITEM, PRODUTO, TIPOCOTACAO, CONDICAO, 'N' as ESCOLHA
    FROM MULT_CALCULOCOND WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Parcelas*/
    INSERT INTO MULT_CALCULOCONDPAR (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,CONDICAO,PARCELAS,VALOR_PRIMEIRA,VALOR_DEMAIS,ESCOLHA,
    IOF, FORMA_PAGAMENTO, VALOR_SEM_JUROS,  PERC_JUROS, VALOR_COM_JUROS)
    SELECT PCALCULO_NEW as CALCULO, ITEM, PRODUTO, TIPOCOTACAO, CONDICAO, PARCELAS,
           VALOR_PRIMEIRA, VALOR_DEMAIS, 'N' as ESCOLHA, IOF, FORMA_PAGAMENTO, VALOR_SEM_JUROS,  PERC_JUROS, VALOR_COM_JUROS
    FROM MULT_CALCULOCONDPAR WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Condutor*/
    INSERT INTO MULT_CALCULOCONDU (CALCULO,ITEM,CONDUTOR,NOME,NASCIMENTO,IDADE,SEXO,DATAHABILITACAO,
           IDADEHABILITACAO,ESTADOCIVIL,OBS,PARENTESCO,PARTICIPACAO,TIPOCONDUTOR,PROPRIOSEGURADO)
    SELECT PCALCULO_NEW as CALCULO, ITEM, CONDUTOR, NOME, NASCIMENTO, IDADE, SEXO,
           DATAHABILITACAO, IDADEHABILITACAO, ESTADOCIVIL, OBS,
           PARENTESCO, PARTICIPACAO, TIPOCONDUTOR, PROPRIOSEGURADO
    FROM MULT_CALCULOCONDU WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo OcorrÍncias*/
    INSERT INTO MULT_CALCULOOCORRENCIAS (CALCULO,ITEM,USER_ID,TIPOOCORRENCIA,DATAOCORRENCIA)
    SELECT PCALCULO_NEW as CALCULO, ITEM, USER_ID, TIPOOCORRENCIA, DATAOCORRENCIA
    FROM MULT_CALCULOOCORRENCIAS WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Premios*/
    INSERT INTO MULT_CALCULOPREMIOS (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,PREMIO_CASCO,PREMIO_ACESSORIOS,PREMIO_AUTO,
           PREMIO_DM,PREMIO_DP,PREMIO_RCF,PREMIO_APP_MORTE,PREMIO_APP_INVALIDEZ,PREMIO_APP,
           PREMIO_OUTROS,PREMIO_LIQUIDO,PREMIO_CUSTO_APOLICE,PREMIO_IOF,PREMIO_TOTAL,FRANQUIAAUTO,
           FRANQUIAACESSORIOS,VALORDM,VALORDP,VALORAPPMORTE,VALORAPPINV,COMISSAO,DESCONTOCOMISSAO,
           BONUS,ERRORMESSAGE,ESCOLHA,VALORVEICULO,AJUSTE,COD_TABELA,MANIPULADO,OBSERVACAO)
    SELECT PCALCULO_NEW as CALCULO,ITEM,PRODUTO,TIPOCOTACAO,PREMIO_CASCO,PREMIO_ACESSORIOS,
           PREMIO_AUTO, PREMIO_DM,PREMIO_DP, PREMIO_RCF,PREMIO_APP_MORTE,
           PREMIO_APP_INVALIDEZ, PREMIO_APP, PREMIO_OUTROS,PREMIO_LIQUIDO,
           PREMIO_CUSTO_APOLICE, PREMIO_IOF, PREMIO_TOTAL, FRANQUIAAUTO,
           FRANQUIAACESSORIOS,VALORDM, VALORDP,VALORAPPMORTE, VALORAPPINV,
           COMISSAO, DESCONTOCOMISSAO, BONUS, ERRORMESSAGE, ESCOLHA,
           VALORVEICULO, AJUSTE, COD_TABELA , MANIPULADO, OBSERVACAO
    FROM MULT_CALCULOPREMIOS WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Valor de Premio das Coberturas*/
    INSERT INTO MULT_CALCULOPREMIOSCOB (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,COBERTURA,VALOR,PREMIO,FRANQUIA,DESCRICAO,TAXA)
    SELECT PCALCULO_NEW as CALCULO, ITEM, PRODUTO, TIPOCOTACAO,COBERTURA, VALOR, PREMIO, FRANQUIA, DESCRICAO, TAXA
    FROM MULT_CALCULOPREMIOSCOB WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Perfil*/
    INSERT INTO MULT_CALCULOQBR (CALCULO,ITEM,QUESTAO,DESCRICAO,RESPOSTA,DESCRICAORESPOSTA,SUBRESPOSTA,DESCRICAOSUBRESPOSTA,
            AGRUPAMENTOREGIAOQBR,VALIDA,IMPRIME,PERCIMPRESSAO,ORDEM,TIPO,SUBRESPOSTA2,DESCRICAOSUBRESPOSTA2,
            RESPOSTA2,DESCRICAORESPOSTA2,GRUPO,VIGENCIA)
    SELECT PCALCULO_NEW as CALCULO, ITEM,QUESTAO,DESCRICAO, RESPOSTA,DESCRICAORESPOSTA,SUBRESPOSTA,DESCRICAOSUBRESPOSTA,
            AGRUPAMENTOREGIAOQBR, VALIDA, IMPRIME, PERCIMPRESSAO,ORDEM,TIPO,SUBRESPOSTA2,DESCRICAOSUBRESPOSTA2,
            RESPOSTA2,DESCRICAORESPOSTA2,GRUPO,VIGENCIA
    FROM MULT_CALCULOQBR WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Dados do Corretor*/
    INSERT INTO MULT_CALCULOCORRETOR (CALCULO,CORRETOR1,PERCENTUAL1,CORRETOR2,PERCENTUAL2,
               CORRETOR3,PERCENTUAL3,CORRETOR4,PERCENTUAL4,CORRETOR5,PERCENTUAL5)
    SELECT PCALCULO_NEW as CALCULO, CORRETOR1, PERCENTUAL1, CORRETOR2, PERCENTUAL2,CORRETOR3,
           PERCENTUAL3, CORRETOR4, PERCENTUAL4, CORRETOR5, PERCENTUAL5
    FROM MULT_CALCULOCORRETOR WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo Divisoes do calculo*/
    INSERT INTO MULT_CALCULODIVISOES (CALCULO,DIVISAO,NIVEL)
    SELECT PCALCULO_NEW as CALCULO, DIVISAO, NIVEL
    FROM MULT_CALCULODIVISOES WHERE CALCULO = PCALCULO_OLD;

    /*Inserindo RealCor*/
    INSERT INTO MULT_CALCULOREALCOR (CALCULO,PERCENTUAL_LOJISTA,CODIGO_PRODUTOR,CENAPE_CONSULTOR,CENAPE_FUNCIONARIO)
    SELECT PCALCULO_NEW as CALCULO, PERCENTUAL_LOJISTA, CODIGO_PRODUTOR, CENAPE_CONSULTOR, CENAPE_FUNCIONARIO
    FROM MULT_CALCULOREALCOR WHERE CALCULO = PCALCULO_OLD;

	/*Inserindo RenovaÁıes MÍs a MÍs do calculo*/
    INSERT INTO MULT_CALCULORENOVACAOMM (CALCULO,APOLICEANTERIOR,BONUS,INADIMPLENTE,ISENCAOPRIMPARCELA,ITSEG,FIMVIGENCIA)
    SELECT PCALCULO_NEW as CALCULO, APOLICEANTERIOR,BONUS,INADIMPLENTE,ISENCAOPRIMPARCELA,ITSEG,FIMVIGENCIA
    FROM MULT_CALCULORENOVACAOMM WHERE CALCULO = PCALCULO_OLD;

	/*Inserindo InformaÁıes Adicionais*/
	INSERT INTO KIT0001_MTCAL_AUTO (NR_CALLO, NR_ITEM, VL_IS_UNIDD_FRIGO, VL_IS_GUNCH, VL_IS_ELEVD_PLATF_CARGA, VL_IS_GUND_MUNCK,
                                    VL_IS_UNIDD_REFRG, VL_IS_ROLON_ROLOF, VL_IS_KIT_BASCL, VL_IS_OUTRO_EQUIP_CARGA, VL_IS_APRLH_SOM,
                                    VL_IS_APRLH_SOM_DVD, VL_IS_ALTO_FLANT, VL_IS_OUTRO_EQUIP_PSSEI, CD_CEP_PRNOI, CD_CHASSI_RMARC,
                                    CD_QURTO_EIXO, CD_CARGA_DSCRG, CD_KM_ADCNL, CD_CBINE_SUPLM, CD_FRANQ_CRROC, VL_IS_CARGA_DSCRG)
	SELECT PCALCULO_NEW as NR_CALLO, NR_ITEM, VL_IS_UNIDD_FRIGO, VL_IS_GUNCH, VL_IS_ELEVD_PLATF_CARGA, VL_IS_GUND_MUNCK,
           VL_IS_UNIDD_REFRG, VL_IS_ROLON_ROLOF, VL_IS_KIT_BASCL, VL_IS_OUTRO_EQUIP_CARGA, VL_IS_APRLH_SOM, VL_IS_APRLH_SOM_DVD,
		   VL_IS_ALTO_FLANT, VL_IS_OUTRO_EQUIP_PSSEI, CD_CEP_PRNOI, CD_CHASSI_RMARC, CD_QURTO_EIXO, CD_CARGA_DSCRG, CD_KM_ADCNL,
		   CD_CBINE_SUPLM, CD_FRANQ_CRROC, VL_IS_CARGA_DSCRG
	FROM KIT0001_MTCAL_AUTO WHERE NR_CALLO = PCALCULO_OLD;
END;
/


CREATE OR REPLACE PROCEDURE envia_arq_ktr_mail2      (p_email_to     IN      VARCHAR2        DEFAULT NULL)   IS
        --
        CURSOR  cr_todos        IS
                --
select  a.ID,a.dt_arquivo, c.nm_completo , flg_enviado, a.arquivo
from    tb_fwt_upload_blob      A,
        tb_fwt_upload_file      B,
        tb_conteudo_proposta    C
WHERE   A.ID    =       B.ID
AND     B.NM_ARQUIVO    =       C.NM_ARQUIVO
AND     C.ds_recibo     IN      
('13294098041224520000'
,'13294141580851935000'
,'13294163804541784000'
,'13294136751078556000'
,'13294198845569116000'
,'13294848728456780000'
,'13294178151018904000'
,'13294229256099040000'
,'13301024890481803000'
,'13293989561253513000'
,'13300262496445323000'
,'13300272201707850000'
,'13300266142015707000'
,'13300282020898085000'
,'13300285369417284000'
,'13299317451719377000'
,'13299992975022200000'
,'13300126860985203000'
,'13300194321373729000'  );
        --
        blob1                   BLOB;
        --
        v_fault_a               admtms.tms_storage.r_request_fault;
        v_correlation_id        admtms.tms_util.correlation_id;
        v_body                  CLOB;
        v_blob                  BLOB;
        v_request_fault         tms_storage.r_request_fault;
        v_file                  admtms.tms_mail.file_type;
        v_to                    admtms.tms_mail.address_type;
        v_cc                    admtms.tms_mail.address_type;
        v_bcc                   admtms.tms_mail.address_type;
        --
        v_qt                    NUMBER;
        v_indx                  NUMBER;
        v_indx2                 NUMBER;
        v_ret                   VARCHAR2(4000);
        v_protocolos            VARCHAR2(4000);
        v_email_to              VARCHAR2(4000);
        --
        TYPE    protocolo       IS      RECORD  (nr_protocolo   NUMBER(38));
        --
        TYPE    t_protocolo     IS      TABLE   OF      protocolo       INDEX   BY      BINARY_INTEGER;
        --
        v_t_protocolo           t_protocolo;
BEGIN
        --
        --      Inicializando as vari·veis
        --
        v_indx          :=      0;
        v_indx2         :=      0;
        v_email_to      :=      p_email_to;
        --
        --      Criando o BLOB tempor·rio
        --
        dbms_lob.createtemporary        (blob1
                                        ,TRUE);
        --
        --      Separando os destinat·rios do e-mail
        --
        WHILE   v_email_to      IS      NOT     NULL    LOOP
                --
                IF      InStr(v_email_to,       ';')    <>      0       THEN
                        --
                        v_indx          :=      v_indx  +       1;
                        --
                        v_to(v_indx)    :=      SubStr(v_email_to, 1,  InStr(v_email_to, ';')-1)||'@tokiomarine.com.br';
                        --
                        v_email_to      :=      SubStr(v_email_to, InStr(v_email_to, ';')+1,Length(v_email_to));
                        --
                ELSE
                        --
                        v_indx          :=      v_indx  +       1;
                        --
                        v_to(v_indx)    :=      SubStr(v_email_to, 1, Length(v_email_to))||'@tokiomarine.com.br';
                        --
                        v_email_to      :=      NULL;
                        --
                END     IF;
                --
        END     LOOP;
        --
        --      Separando os protocolos, caso o par‚metro n„o seja NULL
        --
        v_body  :=      to_clob('Segue o arquivo recuperado do KIT com os protocolos n„o transmitidos atÈ agora.');
        --
        v_qt    :=      0;
        --
        FOR     r_todos IN      cr_todos        LOOP
                --
                v_qt    :=      v_qt    +       1;
                --
                dbms_lob.append (blob1
                                ,r_todos.arquivo);
                --
        END     LOOP;
        --
        IF      v_qt    =       0       THEN
                --
                Dbms_Output.Put_Line(LPad('-',  80,     '-'));
                Dbms_Output.Put_Line(RPad('- N„o existem protocolos n„o transmitidos atÈ o momento.',79,' ')||'-');
                Dbms_Output.Put_Line(LPad('-',  80,     '-'));
                --
        END     IF;
        --
        IF      p_email_to      IS      NOT     NULL    THEN
                --
                --      Enviando o arquivo por e-mail.
                --
                v_file(1)       :=      admtms.tms_file_record  ('recuperado_kit.txt'
                                                                ,blob1);
                --
                IF      v_qt    >       0       THEN
                        --
                        BEGIN
                                --
                                admtms.TMS_MAIL.send_html       ('arquivo.kit@tokiomarine.com.br'
                                                                ,v_to
                                                                ,v_cc
                                                                ,v_bcc
                                                                ,'Arquivo do KIT recuperado'
                                                                ,v_body
                                                                ,v_file
                                                                ,v_fault_a
                                                                ,v_correlation_id);
                                --
                        EXCEPTION
                                --
                                WHEN    OTHERS  THEN
                                        --
                                        Dbms_Output.Put_Line('Erro ao enviar e-mail: '||SQLERRM);
                                        --
                        END;
                        --
                END     IF;
                --
        ELSE
                --
                BEGIN
                        --
                        v_ret   :=      tms_storage.putBlobFile ('/rvs/interf/asr'
                                                                ,'recuperado_kit.txt'
                                                                ,blob1
                                                                ,v_request_fault);
                        --
                        IF      v_request_fault.code    <>      0       THEN
                                --
                                Dbms_Output.Put_Line(v_request_fault.code||' '||v_request_fault.message);
                                --
                        END     IF;
                        --
                EXCEPTION
                        --
                        WHEN    OTHERS  THEN
                                --
                                Dbms_Output.Put_Line('Erro putBlobFile: '||SQLERRM);
                                --
                END;
                --
        END     IF;
        --
        dbms_lob.freetemporary(blob1);
        --
        ROLLBACK;
        --
EXCEPTION
        --
        WHEN    OTHERS  THEN
                --
                Dbms_Output.Put_Line('Erro envia_arq_ktr_mail: '||SQLERRM);
                --
END     envia_arq_ktr_mail2;
/


CREATE OR REPLACE PROCEDURE "EXPURGO" 
IS
  DataExpurgo date;
begin
  DataExpurgo := SYSDATE - 365;

  
	Delete from Mult_calculoAces where Calculo  in (
		Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoBens where Calculo  in  (
	Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoCob  where Calculo  in (
	Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
	
	Delete from Mult_calculoCobOp  where Calculo  in (
		Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoCondu  where Calculo  in (
	 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoPremiosCob  where Calculo in (
	 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoPremios  where Calculo in (
	 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoCond  where Calculo  in (
		 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoCondPar  where Calculo in (
		Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoQBR  where Calculo in (
	Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
	Delete from Mult_calculoOcorrencias  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
			
			
	Delete from Mult_calculoCorretor  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);			
			
	Delete from Mult_calculoSVE  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);			
	
	Delete from mult_calculosvecob  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);		
			
	
	Delete from mult_calculosvecobdepend  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);	
	
	Delete from mult_calculosvecobdepend  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);			
			
	Delete from checa_acesso_crivo  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);	
	
	Delete from checa_acesso_ids  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);	
	
	/*
	Delete from mult_calculoIDS  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
	*/
	
	Delete from mult_calculoDivisoes  where Calculo in (
			 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);		
	
	delete from Mult_CalculoWSCor where Calculo in (
		 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
	
	delete from Mult_CalculoEstatistica where Calculo in (
		 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);	
	
	delete from Mult_CalculoDiferenciais where Calculo in (
		 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);		
	
	Delete from Mult_calculo where Calculo in (
		 Select 
			t.Calculo 
		from 
			Mult_calculo t
		where 
			t.DataPrimeiroCalculo <= DataExpurgo or  t.DataPrimeiroCalculo is null
	);
	
	

	
	/****************************************************************************/
	/**                          REGISTROS ORF√OS                                /
	/****************************************************************************/
	
	
	Delete from Mult_calculoAces a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoBens a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoCob a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
	
	Delete from Mult_calculoCobOp a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoCondu a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoPremiosCob a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoPremios a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoCond a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoCondPar a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoQBR a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
	Delete from Mult_calculoOcorrencias a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
			
			
	Delete from Mult_calculoCorretor a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);			
			
	Delete from Mult_calculoSVE a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);			
	
	Delete from mult_calculosvecob a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);		
			
	
	Delete from mult_calculosvecobdepend a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);	
	
	Delete from mult_calculosvecobdepend a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);			
			
	Delete from checa_acesso_crivo a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);	
	
	Delete from checa_acesso_ids a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);	
	
	
	/*
	Delete from mult_calculoIDS a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);		
 */
	
	Delete from mult_calculoDivisoes a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);		
	
	Delete from Mult_calculo a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
	
	delete from Mult_CalculoWSCor a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);
	
	delete from Mult_CalculoEstatistica a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);	
	
	delete from Mult_CalculoDiferenciais a where not exists (
		Select 
			1
		from 
			Mult_calculo b
		where 
			b.calculo = a.calculo
	);		
	
	
	/****************************************************************************/
	/**                                OUTROS                                  **/
	/****************************************************************************/
	Delete from Log_Erros where data <= DataExpurgo;
	
end;
/


CREATE OR REPLACE PROCEDURE "EXTRAIR_COTACOES" (
  PCORRETOR    IN MULT_CALCULODIVISOES.DIVISAO%TYPE,
  PDATA_INICIO IN MULT_CALCULO.INICIOVIGENCIA%TYPE,
  PDATA_FINAL  IN MULT_CALCULO.FINALVIGENCIA%TYPE,
  PDATASET     OUT TYPES.CURSOR_TYPE
)
  IS
BEGIN
  DECLARE
    /*ARQUIVO               SYS.UTL_FILE.FILE_TYPE;*/
    V_TIPO_DOCUMENTO      VARCHAR2(9);
    V_CALCULO             NUMBER(18);
    V_ITEM                NUMBER(18);
    V_TIPO_PESSOA         VARCHAR2(8);
    V_TIPO_SEGURO         VARCHAR2(25);
    V_NOME_SEGURADO       VARCHAR2(50);
    V_CODIGO_VEICULO      VARCHAR2(9);
    V_CODIGO_MODELO       NUMBER(18,6);
    V_DESCRICAO_VEICULO   VARCHAR2(50);
    V_ZERO_KM             CHAR(5);
    V_ANO_FABRICACAO      NUMBER(18,6);
    V_ANO_MODELO          NUMBER(18,6);
    V_REGIAO_CIRCULACAO   NUMBER(18,6);
    V_DATA_CALCULO        DATE;
    V_INICIO_VIGENCIA     DATE;
    V_COD_CONCESSIONARIA  NUMBER(18);  -- DIVISAO SUPERIOT DO ESTIPULANTE
    V_NOME_CONCESSIONARIA VARCHAR(50); -- NOME ESTIPULANTE
    V_NOME_VENDEDOR       VARCHAR(50); -- NOME USU¡RIO
    V_COMISSAO            NUMBER(18,6);
    V_NOME_USUARIO        VARCHAR2(50);
    V_SEPARADOR           CHAR(1) := ';';
    V_LINHA               VARCHAR(10000);
    /*V_NOME_ARQUIVO        VARCHAR2(50) := 'RELATORIO_GERENCIAL_' || TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS') || '.CSV'; */
    V_CHAVE               NUMBER(18,0);
    V_COD_CORRETOR        NUMBER(18,0);
    V_COD_USUARIO         VARCHAR(10);
    V_CLASSE_BONUS        SMALLINT;
    V_ORDEM               INTEGER;
    V_PREMIO              NUMBER(18,6);
    V_TITULO              VARCHAR2(15);
    V_PGTO_HONDA          VARCHAR2(3);

    /* CURSOR COM OS CALCULOS*/
    CURSOR CURSOR_MULT_CALCULO IS
            SELECT T1.CALCULO, T1.ITEM, T1.DATACALCULO, T1.INICIOVIGENCIA, T1.NOME, T4.NOME NOME_CONCESSIONARIA,
                   T1.TIPO_PESSOA, T5.CD_FIPE, T1.MODELO, T6.DESCRICAO VEICULO, T1.ZEROKM,
                   T1.ANOFABRICACAO, T1.ANOMODELO, T1.COD_CIDADE, T1.COMISSAO, T1.NIVELBONUSAUTO, T1.COD_USUARIO,
                   T1.pgto_banco_honda,T1.numerotitulo,T7.PREMIO_TOTAL
            FROM MULT_CALCULO T1,           -- Calculo
                 MULT_CALCULODIVISOES T2,   --
                 MULT_CALCULODIVISOES T3,   --  Consession·ria
                 TABELA_DIVISOES T4,        -- Pegando o nome da Consession·ria
                 REAL_DEPARAFIPE T5,        -- Pegando Codigo Fipe
                 TABELA_VEICULOMODELO T6,    -- Pegando Descricao Veiculo */
                 MULT_CALCULOPREMIOS T7

            WHERE T1.DATACALCULO BETWEEN PDATA_INICIO AND PDATA_FINAL AND
                  ((PCORRETOR = 0 AND T2.NIVEL = 1) OR (T2.DIVISAO = PCORRETOR AND T2.NIVEL = 1)) AND
                  T2.CALCULO = T1.CALCULO AND
                  T7.CALCULO (+)= T1.CALCULO AND
                  T7.ESCOLHA (+)= 'S' AND
                  T1.PADRAO  in (10, 42) AND
                  T1.SITUACAO IN ('P','C') AND
                  T3.NIVEL  (+)= 4 AND
                  T3.CALCULO (+)= T1.CALCULO AND
                  T4.DIVISAO (+)= T3.DIVISAO AND
                  T5.CD_FAB_REAL = T1.FABRICANTE AND
                  T5.CD_MOD_REAL = T1.MODELO AND
                  T6.FABRICANTE = T1.FABRICANTE AND
                  T6.MODELO = T1.MODELO
            ORDER BY T1.CALCULO;
  BEGIN
    SELECT FUNC_CONTADOR('REAL_REL_GERENCIAL') INTO V_CHAVE FROM DUAL;
    DBMS_OUTPUT.ENABLE(1000000);
  /*  ARQUIVO := SYS.UTL_FILE.FOPEN('ARQUIVO',V_NOME_ARQUIVO,'A'); */
    BEGIN
     V_ORDEM := 1;
     /* Gravando Titulos das colunas*/
      V_LINHA :=  'NR DE COTA«√O;DATA DE COTAC√O;DATA DO INÕCIO DE VIG NCIA;SEGURADO;NOME CONCESSION¡RIA;'||
                  'VENDEDOR;TIPO DE PESSOA;TIPOSEGURO;C”DIGO VEICULO;C”DIGO MODELO;VEICULO;ZEROKM;ANO FABRICA«√O;'||
                  'ANO MODELO;REGI√O CIRCULA«√O;COMISS√O;PAGTO BANCO HONDA;TITULO;PREMIO';
      INSERT INTO REAL_REL_GERENCIAL (CHAVE, LINHA,ORDEM) VALUES (V_CHAVE, V_LINHA, V_ORDEM);

      /* Inserindo titulos no arquivo */
     /* SYS.UTL_FILE.PUT_LINE(ARQUIVO, V_LINHA); */

      OPEN CURSOR_MULT_CALCULO; --Abrindo o Cursor
      LOOP
        FETCH CURSOR_MULT_CALCULO INTO V_CALCULO, V_ITEM, V_DATA_CALCULO, V_INICIO_VIGENCIA, V_NOME_SEGURADO, V_NOME_CONCESSIONARIA, V_TIPO_PESSOA,
                                       V_CODIGO_VEICULO, V_CODIGO_MODELO,  V_DESCRICAO_VEICULO, V_ZERO_KM, V_ANO_FABRICACAO, V_ANO_MODELO,
                                       V_REGIAO_CIRCULACAO, V_COMISSAO, V_CLASSE_BONUS, V_COD_USUARIO, V_PGTO_HONDA, V_TITULO,V_PREMIO;


        /*SAI DO LOOPING CASO SEJA O FIM DO CURSOR*/
        EXIT WHEN CURSOR_MULT_CALCULO%Notfound;

        BEGIN
          SELECT UPPER(DESCRICAORESPOSTA) INTO V_TIPO_SEGURO FROM MULT_CALCULOQBR
          WHERE CALCULO = V_CALCULO AND ITEM = V_ITEM AND QUESTAO = 87;
        EXCEPTION
          WHEN OTHERS THEN
            V_TIPO_SEGURO := '';
        END;

        /*Mudando a descricao do tipo de seguro caso a resposta seja N„o*/
        IF (V_CLASSE_BONUS > 0) AND (V_TIPO_SEGURO = 'N√O') THEN
          V_TIPO_SEGURO := 'RENOVA«√O CONG NERE';
        ELSIF (V_CLASSE_BONUS > 0) AND (V_TIPO_SEGURO <> 'N√O') THEN
          V_TIPO_SEGURO := 'RENOVA«√O TOKIO MARINE';
        ELSE
          V_TIPO_SEGURO := 'SEGURO NOVO';
        END IF;

        IF V_ZERO_KM = 'S' THEN
          V_ZERO_KM := 'SIM';
        ELSE
          V_ZERO_KM := 'N√O';
        END IF;

        IF V_TIPO_PESSOA = 'F' THEN
          V_TIPO_PESSOA := 'FÕSICA';
        ELSIF V_TIPO_PESSOA = 'J' THEN
          V_TIPO_PESSOA := 'JURÕDICA';
        END IF;

        IF V_PGTO_HONDA = 'S' THEN
          V_PGTO_HONDA := 'SIM';
        ELSE
          V_PGTO_HONDA := 'N√O';
        END IF;



        /* Pegar o nome do usu·rio */
        IF PCORRETOR <> 0 THEN
                BEGIN
            SELECT NOMEUSUARIO INTO V_NOME_USUARIO FROM REAL_USUARIOS WHERE CORRETOR = PCORRETOR AND COD_USUARIO = V_COD_USUARIO;
          EXCEPTION
            WHEN OTHERS THEN
              V_NOME_USUARIO := '';
          END;
        ELSE
          BEGIN
            SELECT DIVISAO INTO V_COD_CORRETOR FROM MULT_CALCULODIVISOES WHERE CALCULO = V_CALCULO AND NIVEL = 1;
            SELECT NOMEUSUARIO INTO V_NOME_USUARIO FROM REAL_USUARIOS WHERE CORRETOR = V_COD_CORRETOR AND COD_USUARIO = V_COD_USUARIO;
          EXCEPTION
            WHEN OTHERS THEN
              V_NOME_USUARIO := '';
          END;
        END IF;

        /* MONTANDO LINHA */
        V_LINHA := TO_CHAR(V_CALCULO)                        || V_SEPARADOR ||
                   TO_CHAR(V_DATA_CALCULO,    'DD/MM/YYYY')  || V_SEPARADOR ||
                   TO_CHAR(V_INICIO_VIGENCIA, 'DD/MM/YYYY')  || V_SEPARADOR ||
                   TRIM(V_NOME_SEGURADO)                     || V_SEPARADOR ||
                   TRIM(V_NOME_CONCESSIONARIA)               || V_SEPARADOR ||
                   TRIM(V_NOME_USUARIO)                      || V_SEPARADOR ||
                   TRIM(V_TIPO_PESSOA)                       || V_SEPARADOR ||
                   TRIM(V_TIPO_SEGURO)                       || V_SEPARADOR ||
                   TRIM(V_CODIGO_VEICULO)                    || V_SEPARADOR ||
                   TO_CHAR(V_CODIGO_MODELO)                  || V_SEPARADOR ||
                   TRIM(V_DESCRICAO_VEICULO)                 || V_SEPARADOR ||
                   TRIM(V_ZERO_KM)                           || V_SEPARADOR ||
                   TO_CHAR(V_ANO_FABRICACAO)                 || V_SEPARADOR ||
                   TO_CHAR(V_ANO_MODELO)                     || V_SEPARADOR ||
                   TO_CHAR(V_REGIAO_CIRCULACAO)              || V_SEPARADOR ||
                   TO_CHAR(V_COMISSAO)                       || V_SEPARADOR ||
                   TRIM(V_PGTO_HONDA)                        || V_SEPARADOR ||
                   TRIM(V_TITULO)                            || V_SEPARADOR ||
                   TO_CHAR(V_PREMIO,'FM999999999999.99');


        V_ORDEM := V_ORDEM+1;
        /* Inserindo linha no arquivo */
        INSERT INTO REAL_REL_GERENCIAL (CHAVE, LINHA,ORDEM) VALUES (V_CHAVE, V_LINHA, V_ORDEM);
        /* SYS.UTL_FILE.PUT_LINE(ARQUIVO, V_LINHA); */
      END LOOP;
      CLOSE CURSOR_MULT_CALCULO;
   /* SYS.UTL_FILE.FFLUSH(ARQUIVO);
      SYS.UTL_FILE.FCLOSE(ARQUIVO); */
      OPEN PDATASET FOR SELECT LINHA FROM REAL_REL_GERENCIAL  WHERE CHAVE = V_CHAVE  ORDER BY ORDEM;

      IF NOT PDATASET%ISOPEN THEN /*Caso n„o tenha nenhum registro abre o cursor vazio*/
        OPEN PDATASET FOR SELECT * FROM DUAL WHERE 1=2;
      END IF;

     EXCEPTION
      WHEN OTHERS THEN
      BEGIN
        /*SYS.UTL_FILE.FCLOSE(ARQUIVO); */
        DBMS_OUTPUT.PUT_LINE('Erro o seguinte erro : '||SQLERRM);
      END;
    END;
  END;
END;
/


CREATE OR REPLACE PROCEDURE          EXTRAIR_PROPOSTAS (
  PCORRETOR    IN MULT_CALCULODIVISOES.DIVISAO%TYPE,
  PDATA_INICIO IN MULT_CALCULO.INICIOVIGENCIA%TYPE,
  PDATA_FINAL  IN MULT_CALCULO.FINALVIGENCIA%TYPE,
  PDATASET OUT TYPES.CURSOR_TYPE
)
  IS
BEGIN
  DECLARE
    V_TIPO_DOCUMENTO      VARCHAR2(9);
    V_CALCULO             NUMBER(18);
    V_ITEM                NUMBER(18);
    V_TIPO_PESSOA         VARCHAR2(8);
    V_TIPO_COTACAO        VARCHAR(10);
    V_PADRAO              NUMBER(18,6);
    V_PRODUTO             CHAR(2);
    V_TIPO_SEGURO         VARCHAR2(25);
    V_NOME_SEGURADO       VARCHAR2(50);
    V_CODIGO_VEICULO      VARCHAR2(9);
    V_CODIGO_MODELO       NUMBER(18,6);
    V_DESCRICAO_VEICULO   VARCHAR2(50);
    V_ZERO_KM             CHAR(5);
    V_ANO_FABRICACAO      NUMBER(18,6);
    V_ANO_MODELO          NUMBER(18,6);
    V_CHASSI              VARCHAR2(20);
    V_REGIAO_CIRCULACAO   NUMBER(18,6);
    V_MODALIDADE          VARCHAR(20);
    V_CATEGORIA           VARCHAR(20);
    V_VALOR_BASE          NUMBER(18,6);
    V_VALOR_VEICULO       NUMBER(18,6);
    V_NIVELDM             NUMBER(18,6);
    V_NIVELDP             NUMBER(18,6);
    V_VALORAPPDMH         NUMBER(18,6);
    V_VALORAPPMORTE       NUMBER(18,6);
    V_QBR_RESP1           VARCHAR(100);
    V_QBR_RESP2           VARCHAR(100);
    V_QBR_RESP3           VARCHAR(100);
    V_QBR_RESP4           VARCHAR(100);
    V_QBR_RESP5           VARCHAR(100);
    V_QBR_RESP6           VARCHAR(100);
    V_QBR_RESP7           VARCHAR(100);
    V_TIPO_RECEBIMENTO    VARCHAR(25);
    V_QTD_PRESTACOES      SMALLINT;
    V_DEBITO_EM_CONTA     CHAR(3);
    V_DATA_CALCULO        DATE;
    V_INICIO_VIGENCIA     DATE;
    V_FINAL_VIGENCIA      DATE;
    V_FORMA_PGTO          VARCHAR2(11);
    V_COD_CONCESSIONARIA  NUMBER(18);  -- DIVISAO SUPERIOT DO ESTIPULANTE
    V_NOME_CONCESSIONARIA VARCHAR(50); -- NOME ESTIPULANTE
    V_NOME_VENDEDOR       VARCHAR(50); --NOME USU√ÅRIO
    V_COMISSAO            NUMBER(18,6);
    V_NOME_CORRETOR       VARCHAR(50);
    V_COD_CORRETOR        NUMBER(18,6);
    V_COD_USUARIO         VARCHAR2(8);
    V_NOME_USUARIO        VARCHAR2(50);
    V_SITUACAO            CHAR(1);
    V_VERSAO              NUMBER(18,6);
    V_AUTO                VARCHAR2(5); -- Determina se Contratou cobertura de CASCO
    V_RCFV                VARCHAR2(5); -- Determina se Contratou de RCF
    V_APP                 VARCHAR2(5); -- Determina se Contratou APP
    V_CLASSE_BONUS        SMALLINT;
    V_SEPARADOR           CHAR(1) := ';';
    V_DESC_RESPOSTA       VARCHAR2(350);
    V_DESC_QUESTAO        VARCHAR2(350);
    V_QUESTAO             NUMBER(18,0);
    V_QBR_DESC            VARCHAR2(10000);
    V_LINHA               LONG;
    V_ORDEM               INTEGER;
    V_CHAVE               NUMBER(18,0);
    V_PREMIO              NUMBER(18,6);
    V_TITULO              VARCHAR2(15);
    V_PGTO_HONDA          VARCHAR2(3);
	V_CPFCNPJ             VARCHAR2(18);


    /* CURSOR COM OS CALCULOS*/
    CURSOR CURSOR_MULT_CALCULO IS
           SELECT T1.CALCULO, T1.ITEM, T1.TIPO_PESSOA, T1.PADRAO,  T1.NOME, T9.CGC_CPF,
               T6.CD_FIPE, T1.MODELO, T7.DESCRICAO VEICULO, T1.ZEROKM, T1.ANOFABRICACAO,
               T1.ANOMODELO, T1.CHASSI, T1.COD_CIDADE, T1.MODALIDADE, T1.VALORBASE, T1.DATACALCULO,
               T1.INICIOVIGENCIA, T1.FINALVIGENCIA, T1.COMISSAO, T1.VALORAPPMORTE,
               T3.DIVISAO_SUPERIOR, T3.NOME CORRETOR, T5.DIVISAO_SUPERIOR CONCESSIONARIA,
               T5.NOME NOME_CONCESSIONARIA, T1.VALORVEICULO, T1.NIVELDM, T1.NIVELDP,
               T1.VALORAPPDMH, T1.COD_USUARIO, T1.SITUACAO, T1.MVERSAO, T1.NIVELBONUSAUTO,
               T1.pgto_banco_honda,T1.numerotitulo,T8.PREMIO_TOTAL

            FROM MULT_CALCULO T1,           -- Calculo
                 MULT_CALCULODIVISOES T2,   -- Corretor
                 TABELA_DIVISOES T3,        -- Pegando o nome do corretor
                 MULT_CALCULODIVISOES T4,   --  Consession√°ria
                 TABELA_DIVISOES T5,        -- Pegando o nome da Consession√°ria
                 REAL_DEPARAFIPE T6,        -- Pegando Codigo Fipe
                 TABELA_VEICULOMODELO T7,    -- Pegando Descricao Veiculo */
                 MULT_CALCULOPREMIOS T8,
				 TABELA_CLIENTES T9 --Dados do Cliente
            WHERE T1.DATACALCULO BETWEEN PDATA_INICIO AND PDATA_FINAL AND
                  ((PCORRETOR = 0 AND T2.NIVEL = 1) OR (T2.DIVISAO = PCORRETOR AND T2.NIVEL = 1)) AND
                  T1.CALCULO = T2.CALCULO AND
                  T3.DIVISAO = T2.DIVISAO AND
                  T8.CALCULO (+)= T1.CALCULO AND
                  T8.ESCOLHA (+)= 'S' AND
                  T1.PADRAO  in (10, 42) AND
                  T1.SITUACAO IN ('T','E','A') AND
                  T4.NIVEL  (+)= 4 AND
                  T4.CALCULO (+)= T1.CALCULO AND
                  T5.DIVISAO (+)= T4.DIVISAO AND
                  T6.CD_FAB_REAL = T1.FABRICANTE AND
                  T6.CD_MOD_REAL = T1.MODELO AND
                  T7.FABRICANTE = T1.FABRICANTE AND
                  T7.MODELO = T1.MODELO AND
				  T9.CLIENTE = T1.CLIENTE
            ORDER BY T1.CALCULO;

    /*CURSOR MULT_CALCULOQBR*/
    CURSOR CURSOR_MULT_CALCULOQBR IS
       SELECT DISTINCT
          T3.QUESTAO, T3.DESCRICAO
       FROM MULT_CALCULO T1, MULT_CALCULODIVISOES T2, MULT_CALCULOQBR T3
       WHERE T1.DATACALCULO BETWEEN PDATA_INICIO AND PDATA_FINAL AND
             T1.PADRAO  in (10, 42) AND
             T1.SITUACAO IN ('T','E','A') AND
             T2.CALCULO = T1.CALCULO  AND
             ((PCORRETOR = 0 AND T2.NIVEL = 1) OR (T2.DIVISAO = PCORRETOR AND T2.NIVEL = 1)) AND
             T3.CALCULO = T1.CALCULO AND
             T3.QUESTAO <> 87
      ORDER BY T3.QUESTAO;
BEGIN
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    SELECT FUNC_CONTADOR('REAL_REL_GERENCIAL') INTO V_CHAVE FROM DUAL;
    /*Montando TiTulos com as quest√µes do QBR*/
    OPEN CURSOR_MULT_CALCULOQBR;
    LOOP
      FETCH CURSOR_MULT_CALCULOQBR INTO V_QUESTAO, V_DESC_QUESTAO;
      /*SAI DO LOOPING CASO SEJA O FIM DO CURSOR*/
      EXIT WHEN CURSOR_MULT_CALCULOQBR%Notfound;
      V_QBR_DESC := V_QBR_DESC ||  V_DESC_QUESTAO || V_SEPARADOR;
    END LOOP;
    IF CURSOR_MULT_CALCULOQBR%ISOPEN THEN
       CLOSE CURSOR_MULT_CALCULOQBR;
    END IF;
     V_ORDEM := 1;
     /* Gravando Titulos das colunas*/
      V_LINHA :=  'CORRETOR;TIPO DO DOCUMENTO;NR DE PROPOSTA;ITEM DA COTAC√øO;'||
                  'TIPO DE PESSOA;TIPO DE COTA√ø√øO;CODIGO DO PRODUTO;TIPOSEGURO;'||
                  'SEGURADO; CPF/CNPJ; C√øDIGO VEICULO;C√øDIGO MODELO;VEICULO;ZEROKM;ANO FABRICA√ø√øO;'||
                  'ANO MODELO;CHASSI;REGI√øO CIRCULA√ø√øO;MODALIDADE SEGURO;CATEGORIA TARIF√ÅRIA;'||
                  'AUTO;RCFV;APP;'||UPPER(V_QBR_DESC)||'TIPO DE RECEBIMENDO;'||
                  'QT PREST ;D√øBITO EM CONTA ;FORMA DE PARCELAMENTO ;DATA DA COTA√ø√øO;'||
                  'DATA DO IN√çCIO DE VIG√øNCIA;DATA DA PROPOSTA;CONCESSION√ÅRIA;'||
                  'NOME CONCESSION√ÅRIA;VENDEDOR;COMISS√øO;PAGTO BANCO HONDA;TITULO;PREMIO';

      /* Inserindo titulos no arquivo */
    INSERT INTO REAL_REL_GERENCIAL (CHAVE, LINHA, ORDEM) VALUES (V_CHAVE, V_LINHA, V_ORDEM);

    OPEN CURSOR_MULT_CALCULO; --Abrindo o Cursor
    LOOP
      FETCH CURSOR_MULT_CALCULO INTO V_CALCULO, V_ITEM, V_TIPO_PESSOA, V_PADRAO, V_NOME_SEGURADO, V_CPFCNPJ, V_CODIGO_VEICULO, V_CODIGO_MODELO,
                                     V_DESCRICAO_VEICULO, V_ZERO_KM, V_ANO_FABRICACAO, V_ANO_MODELO, V_CHASSI, V_REGIAO_CIRCULACAO,
                                     V_MODALIDADE, V_VALOR_BASE, V_DATA_CALCULO, V_INICIO_VIGENCIA, V_FINAL_VIGENCIA, V_COMISSAO,
                                     V_VALORAPPMORTE, V_COD_CORRETOR, V_NOME_CORRETOR, V_COD_CONCESSIONARIA, V_NOME_CONCESSIONARIA,
                                     V_VALOR_VEICULO, V_NIVELDM, V_NIVELDP, V_VALORAPPDMH, V_COD_USUARIO, V_SITUACAO, V_VERSAO, V_CLASSE_BONUS,
                                     V_PGTO_HONDA, V_TITULO,V_PREMIO;


      /*SAI DO LOOPING CASO SEJA O FIM DO CURSOR*/
      EXIT WHEN CURSOR_MULT_CALCULO%Notfound;


      /*Tipo de Seguro*/
      BEGIN
        SELECT UPPER(DESCRICAORESPOSTA) INTO V_TIPO_SEGURO FROM MULT_CALCULOQBR
        WHERE CALCULO = V_CALCULO AND ITEM = V_ITEM AND QUESTAO = 87;
      EXCEPTION
        WHEN OTHERS THEN
          V_TIPO_SEGURO := '';
      END;

      IF (V_CLASSE_BONUS > 0) AND (V_TIPO_SEGURO = 'N√øO') THEN
        V_TIPO_SEGURO := 'RENOVA√ø√øO CONG√øNERE';
      ELSIF (V_CLASSE_BONUS > 0) AND (V_TIPO_SEGURO <> 'N√øO') THEN
        V_TIPO_SEGURO := 'RENOVA√ø√øO TOKIO MARINE';
      ELSE
          V_TIPO_SEGURO := 'SEGURO NOVO';
      END IF;

      IF V_ZERO_KM = 'S' THEN
        V_ZERO_KM := 'SIM';
      ELSE
        V_ZERO_KM := 'N√øO';
      END IF;

      IF V_TIPO_PESSOA = 'F' THEN
        V_TIPO_PESSOA := 'F√çSICA';
      ELSIF V_TIPO_PESSOA = 'J' THEN
        V_TIPO_PESSOA := 'JUR√çDICA';
      END IF;

      IF V_PGTO_HONDA = 'S' THEN
        V_PGTO_HONDA := 'SIM';
      ELSE
        V_PGTO_HONDA := 'N√øO';
      END IF;

      IF V_MODALIDADE = 'A' THEN
        V_MODALIDADE := 'VALOR AJUSTADO';
      ELSE
        V_MODALIDADE := 'VALOR DETERMINADO';
      END IF;

      /* Pegar o nome do usu√°rio */
      IF PCORRETOR <> 0 THEN
        BEGIN
          SELECT NOMEUSUARIO INTO V_NOME_USUARIO FROM REAL_USUARIOS WHERE CORRETOR = PCORRETOR AND COD_USUARIO = V_COD_USUARIO;
        EXCEPTION
           WHEN OTHERS THEN
             V_NOME_USUARIO := '';
        END;
      ELSE
        BEGIN
          SELECT DIVISAO INTO V_COD_CORRETOR FROM MULT_CALCULODIVISOES WHERE CALCULO = V_CALCULO AND NIVEL = 1;
          SELECT NOMEUSUARIO INTO V_NOME_USUARIO FROM REAL_USUARIOS WHERE CORRETOR = V_COD_CORRETOR AND COD_USUARIO = V_COD_USUARIO;
        EXCEPTION
          WHEN OTHERS THEN
            V_NOME_USUARIO := '';
        END;
      END IF;

      /*MONTANDO LINHA*/
      V_LINHA := TRIM(V_NOME_CORRETOR)                     || V_SEPARADOR ||
                 TRIM(V_TIPO_DOCUMENTO)                    || V_SEPARADOR ||
                 TO_CHAR(V_CALCULO)                        || V_SEPARADOR ||
                 TO_CHAR(V_ITEM)                           || V_SEPARADOR ||
                 TRIM(V_TIPO_PESSOA)                       || V_SEPARADOR ||
                 TRIM(V_TIPO_COTACAO)                      || V_SEPARADOR ||
                 TRIM(V_PADRAO)                            || V_SEPARADOR ||
                 TRIM(V_TIPO_SEGURO)                       || V_SEPARADOR ||
                 TRIM(V_NOME_SEGURADO)                     || V_SEPARADOR ||
                 TRIM(V_CPFCNPJ)                           || V_SEPARADOR ||
                 TRIM(V_CODIGO_VEICULO)                    || V_SEPARADOR ||
                 TO_CHAR(V_CODIGO_MODELO)                  || V_SEPARADOR ||
                 TRIM(V_DESCRICAO_VEICULO)                 || V_SEPARADOR ||
                 TRIM(V_ZERO_KM)                           || V_SEPARADOR ||
                 TO_CHAR(V_ANO_FABRICACAO)                 || V_SEPARADOR ||
                 TO_CHAR(V_ANO_MODELO)                     || V_SEPARADOR ||
                 TRIM(V_CHASSI)                            || V_SEPARADOR ||
                 TO_CHAR(V_REGIAO_CIRCULACAO)              || V_SEPARADOR ||
                 TRIM(V_MODALIDADE)                        || V_SEPARADOR ||
                 TRIM(V_CATEGORIA)                         || V_SEPARADOR ||
                 TRIM(V_AUTO)                              || V_SEPARADOR ||
                 TRIM(V_RCFV)                              || V_SEPARADOR ||
                 TRIM(V_APP)                               || V_SEPARADOR;


      /*Montando TiTulos com as quest√µes do QBR*/
      V_QBR_DESC := '';
      OPEN CURSOR_MULT_CALCULOQBR;
      LOOP
        FETCH CURSOR_MULT_CALCULOQBR INTO V_QUESTAO, V_DESC_QUESTAO;
        /*SAI DO LOOPING CASO SEJA O FIM DO CURSOR*/
        EXIT WHEN CURSOR_MULT_CALCULOQBR%Notfound;

        BEGIN
          SELECT DESCRICAORESPOSTA INTO V_DESC_RESPOSTA FROM MULT_CALCULOQBR
          WHERE CALCULO = V_CALCULO AND ITEM = V_ITEM AND QUESTAO = V_QUESTAO;
          V_QBR_DESC := V_QBR_DESC || V_DESC_RESPOSTA || V_SEPARADOR;
        EXCEPTION
          WHEN OTHERS THEN
            V_QBR_DESC := V_QBR_DESC || V_SEPARADOR;
        END;
      END LOOP;

      /* Fechando Cursor */
      IF CURSOR_MULT_CALCULOQBR%ISOPEN THEN
         CLOSE CURSOR_MULT_CALCULOQBR;
      END IF;

      V_LINHA :=  V_LINHA ||
                  TRIM(UPPER(V_QBR_DESC)) ||
                  TRIM(V_TIPO_RECEBIMENTO)                  || V_SEPARADOR ||
                  TO_CHAR(V_QTD_PRESTACOES)                 || V_SEPARADOR ||
                  TRIM(V_DEBITO_EM_CONTA)                   || V_SEPARADOR ||
                  TRIM(V_FORMA_PGTO)                        || V_SEPARADOR ||
                  TO_CHAR(V_DATA_CALCULO,    'DD/MM/YYYY')  || V_SEPARADOR ||
                  TO_CHAR(V_INICIO_VIGENCIA, 'DD/MM/YYYY')  || V_SEPARADOR ||
                  TO_CHAR(V_DATA_CALCULO,    'DD/MM/YYYY')  || V_SEPARADOR ||
                  TO_CHAR(V_COD_CONCESSIONARIA)             || V_SEPARADOR ||
                  TRIM(V_NOME_CONCESSIONARIA)               || V_SEPARADOR ||
                  TRIM(V_NOME_USUARIO)                      || V_SEPARADOR ||
                  TO_CHAR(V_COMISSAO)                       || V_SEPARADOR ||
                  TRIM(V_PGTO_HONDA)                        || V_SEPARADOR ||
                  TRIM(V_TITULO)                            || V_SEPARADOR ||
                  TO_CHAR(V_PREMIO,'FM999999999999.99');

      /* Inserindo linha no arquivo */
      V_ORDEM := V_ORDEM + 1;
      INSERT INTO REAL_REL_GERENCIAL (CHAVE, LINHA, ORDEM) VALUES (V_CHAVE, V_LINHA, V_ORDEM);
    END LOOP;

    IF CURSOR_MULT_CALCULO%ISOPEN THEN
       CLOSE CURSOR_MULT_CALCULO;
    END IF;

    OPEN PDATASET FOR SELECT LINHA FROM REAL_REL_GERENCIAL  WHERE CHAVE = V_CHAVE ORDER BY ORDEM;

    IF NOT PDATASET%ISOPEN THEN /*Caso n√£o tenha nenhum registro abre o cursor vazio*/
      OPEN PDATASET FOR SELECT * FROM DUAL WHERE 1=2;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro o seguinte erro : '||SQLERRM);
  END;
END;
END;
/


CREATE OR REPLACE procedure FXX_DelKitLog(
            P_ID_Name IN VARCHAR2, 
            P_TB_Name IN VARCHAR2, 
            P_Dias  IN INTEGER, 
            P_Delta In Integer,
            P_Teste OUT VARCHAR2
)
is
 V_SQL1 VARCHAR2(300);
 V_SQL2 VARCHAR2(300);
 V_MIN  NUMBER(38);
 V_MAX  NUMBER(38);
 V_X    NUMBER(38);
begin
  
  V_SQL1 := 'select min( ' || P_ID_Name || ' ), max( ' || P_ID_Name || 
            ' ) from ' || P_TB_Name || ' where dt_inico_log < Trunc(SysDate - :1 )';

  V_SQL2 := 'DELETE FROM ' || P_TB_Name  || ' WHERE ' || P_ID_Name || ' < :1';
            
  EXECUTE IMMEDIATE V_SQL1 INTO V_MIN, V_MAX  USING P_Dias ;

  V_X := V_MIN;
  WHILE TRUE LOOP
    V_X := V_X + P_Delta;
    IF V_X > V_MAX THEN
       V_X := V_MAX;
    END IF;
    
    begin
    -- EXECUTE IMMEDIATE V_SQL2 USING V_X;
     commit;
    end;
    
    IF (V_X >= V_MAX) THEN
       exit;
    END IF;

  END LOOP;
  
  P_TESTE := ' Min(' || To_Char(V_Min) || ') MAX(' || To_Char(V_Max) || ')';
end;
/


CREATE OR REPLACE PROCEDURE "GERA_STRING_AUTOCARGA_CALC" 
(
    PCalculo IN Mult_Calculo.CALCULO%TYPE,
    PItem IN Mult_Calculo.ITEM%TYPE,
    PProduto IN Mult_Produtos.PRODUTO%TYPE,
    PvarInt1 IN Mult_Calculo.MVERSAO%TYPE,
    PCep IN Mult_Produtos.PRODUTO%TYPE,
    PMODELO IN Mult_Calculo.MODELO%TYPE,
    PFABRICANTE IN Mult_Calculo.FABRICANTE%TYPE,
    PTipo_Cobertura IN Mult_calculo.TIPO_COBERTURA%TYPE,
    PTipo_Franquia IN Mult_calculo.TIPO_FRANQUIA%TYPE,
    PVALORBASE IN Mult_calculo.VALORBASE%TYPE,
    PTipo_Site IN Mult_calculo.PROCEDENCIA%TYPE,
    PANOMODELO IN Mult_calculo.ANOMODELO%TYPE,
    PANOFABRICACAO  IN Mult_calculo.ANOFABRICACAO%TYPE,
    PPROCEDENCIA IN Mult_calculo.PROCEDENCIA%TYPE,
    PZERO IN Mult_calculo.ZEROKM%TYPE,
    PCOD_CIDADE  IN Mult_calculo.COD_CIDADE%TYPE,
    PCALCULOORIGEM IN Mult_calculo.CALCULOORIGEM%TYPE,
    PTIPOFROTA IN Mult_calculo.TIPOFROTA%TYPE,
    PCOD_TABELA IN Mult_calculo.COD_TABELA%TYPE,
    PVALORVEICULO IN Mult_calculo.VALORVEICULO%TYPE,
    PNIVELBONUSAUTO IN Mult_calculo.NIVELBONUSAUTO%TYPE,
    PMODALIDADE IN Mult_calculo.MODALIDADE%TYPE,
    PSUBSCRICAO IN Mult_Calculo.SUBSCRICAO%TYPE,
    PTAXA IN Mult_Calculo.TAXA%TYPE,
    PVLRFRANQUIASUB IN Mult_Calculo.VLRFRANQUIASUB%TYPE,
    PTAXAFRANQUIASUB IN Mult_Calculo.TAXAFRANQUIASUB%TYPE,
    PVMINFRANQUIASUB IN Mult_Calculo.VMINFRANQUIASUB%TYPE,
    PINICIOVIGENCIA IN Mult_Calculo.INICIOVIGENCIA%TYPE,
    PFINALVIGENCIA IN Mult_Calculo.FINALVIGENCIA%TYPE,
    PCOMISSAO IN Mult_Calculo.COMISSAO%TYPE,
    PNIVELDM IN Mult_Calculo.NIVELDM%TYPE,
    PNIVELDP IN Mult_Calculo.NIVELDP%TYPE,
    PVALORAPPDMH IN Mult_Calculo.VALORAPPDMH%TYPE,
    PVALORAPPMORTE IN Mult_Calculo.VALORAPPMORTE%TYPE,
    PVALORAPPINV IN Mult_Calculo.VALORAPPINV%TYPE,
    PLMI_BLINDAGEM IN Mult_Calculo.LMI_BLINDAGEM%TYPE,
    PLMI_KITGAS IN Mult_Calculo.LMI_KITGAS%TYPE,
    PAJUSTE IN Mult_Calculo.AJUSTE%TYPE,
    PP_AJUSTE IN Mult_Calculo.P_AJUSTE%TYPE,
    PESTADO in Mult_Calculo.ESTADO%TYPE,
    PTIPO_PESSOA  in Mult_Calculo.TIPO_PESSOA%TYPE,
    PDIAS IN Mult_Calculo.P_AJUSTE%TYPE,
    PORIGEM_DESC_SCORE  IN Mult_Calculo.ORIGEM_DESC_SCORE%TYPE,
    PINDSINISTRO  IN Mult_Calculo.TIPO_PESSOA%TYPE,
    PDESC_SCORE  IN Mult_Calculo.DESC_SCORE%TYPE,
    PSENHA_RENOV  IN Mult_Calculo.SENHA_RENOV%TYPE,
    PITEM_SUBST  IN Mult_Calculo.ITEM_SUBST%TYPE,
    PCOD_REFERENCIA  IN Mult_Calculo.COD_REFERENCIA%TYPE,
    PBLINDAGEM  IN Mult_Calculo.BLINDAGEM%TYPE,
    PTIPOUSOVEIC IN Mult_Calculo.TIPOUSOVEIC%TYPE,
    PSEXOCONDU IN Mult_Calculo.SEXOCONDU%TYPE,
    PESTCVCONDU IN Mult_Calculo.ESTCVCONDU%TYPE,
    PDTNASCONDU IN Mult_Calculo.DTNASCONDU%TYPE,
    PCODRETURN IN VARCHAR,
    PRETORNOSUBSCR IN VARCHAR,
    PCODOPERACAO IN VARCHAR,
    PCRIVO IN VARCHAR,
    PRetorno OUT TYPES.CURSOR_TYPE)
IS
BEGIN
  declare
    V_TAXA_CASCO REAL_TAXASAUTO.TAXA_CASCO%TYPE;
    V_TAXA_INC REAL_TAXASAUTO.TAXA_INC%TYPE;
    V_TAXA_RINC REAL_TAXASAUTO.TAXA_RINC%TYPE;
    V_FRANQUIA REAL_TAXASAUTO.FRANQUIA%TYPE;
    V_TAXA_FRANQ REAL_TAXASAUTO.TAXA_FRANQ%TYPE;
    V_FRQ_MINIMA REAL_TAXASAUTO.FRQ_MINIMA%TYPE;
    V_TAXA_CASCO_ANT REAL_TAXASAUTO.TAXA_CASCO_ANT%TYPE;
    V_TAXA_INC_ANT REAL_TAXASAUTO.TAXA_INC_ANT%TYPE;
    V_TAXA_RINC_ANT REAL_TAXASAUTO.TAXA_RINC_ANT%TYPE;
    V_FRANQUIA_ANT REAL_TAXASAUTO.FRANQUIA_ANT%TYPE;
    V_TAXA_FRANQ_ANT REAL_TAXASAUTO.TAXA_FRANQ_ANT%TYPE;
    V_FRQ_MINIMA_ANT REAL_TAXASAUTO.FRQ_MINIMA_ANT%TYPE;
    V_SUBSCRICAO REAL_TAXASAUTO.SUBSCRICAO%TYPE;
    V_SUBSCRICAO_ANT REAL_TAXASAUTO.SUBSCRICAO_ANT%TYPE;
    V_RESPOSTA MULT_CALCULOQBR.RESPOSTA%TYPE;
    V_DESCRICAORESPOSTA2 MULT_CALCULOQBR.DESCRICAORESPOSTA2%TYPE;
    V_SUBRESPOSTA MULT_CALCULOQBR.SUBRESPOSTA%TYPE;
    V_SUBRESPOSTA2 MULT_CALCULOQBR.SUBRESPOSTA2%TYPE;
    V_AgrupamentoRegiaoQbr MULT_CALCULOQBR.AgrupamentoRegiaoQbr%TYPE;
    V_PDESC_SCORE Mult_Calculo.DESC_SCORE%TYPE;
    V_COD_REFERENCIA NUMBER(18);
    V_COD_REFERENCIA_INC NUMBER(18);
    V_COD_REFERENCIA_RINC NUMBER(18);
    V_FAMILIA NUMBER(18);
    V_CATEG_TAR1 NUMBER(18);
    V_CATEGORIA NUMBER(18);
    V_PROCEDENCIA VARCHAR(1);
    V_Refer NUMBER(18);
    V_Categ NUMBER(18);
    V_CategT NUMBER(18);
    V_DCategT VARCHAR(40);
    V_CaracRegTar NUMBER(18,6);
    V_VALOR_MEDIO number(16,6);
	V_valor_minimo number(16,6);
	V_VALOR_MEDIO_Ant number(16,6);
	V_valor_minimo_ant number(16,6);
	V_PBONUSCASCO number(6,2);
    V_FAMILIAC NUMBER(18);
    V_Val_Med number(16,6);
    V_ValorMin number(16,6);
    V_Val_Blind NUMBER(18);
    V_M_Regiao NUMBER(18);
    V_Desc  VARCHAR(40);
    V_CodFami  VARCHAR(40);
    V_CategEstat VARCHAR(15);
    V_CategScore VARCHAR(15);
    V_PTIPO_FRANQUIA Mult_Calculo.TIPO_FRANQUIA%TYPE;
    V_TEXTO Mult_PRODUTOSTABRG.TEXTO%TYPE;
    PCampo VARCHAR(4000);
    PCampo_v VARCHAR(1000);
    Vstr VARCHAR(20);
    V_CodCorr Number(10);
    V_AGCapt Number(4);
    V_Str Varchar(20);
    V_LOTACAO Number(2);
    V_DESPESAS NUMBER(2);
    V_IS_DEXTR number(16,6);
    V_Perda number(16,6);
    V_MVALOR1 FLOAT;
    V_OPCAO number(10);
    V_CARAC322 number(10);
    V_MISRes number(10);
    V_SubTxCasco varchar2(20);
    V_Taxa_at number(10,6);
    V_Tx_Fran number(10,6);
    V_Franquia_ number(16,6);
    V_FranqMin number(16,6);
    V_Qtd_Frq1 number(10,6);
    V_MVALOR2 FLOAT;
    V_MVALOR3 number(16,6);
    v_DEstipulante number(10);
    v_MEstipulante number(10);
    v_MProLabore number(10);
    V_TIPO_NEGOCIO VARCHAR(20);
    V_Ajuste number(16,6);
    V_SomaAces number(16,6);
    V_Aces number(16,6);
    V_TREG number(2);
    V_ACESSORIO number(6);
    V_VALOR number(16,6);
    v_questao number(10);
    v_resposta2 number(10);
    V_DescPromo number(16,6);
    V_TipoDescPromo Varchar(2);
    V_CODCOMODATO varchar(30);
    V_CobTokio number(3);
    V_PercCascoA number(6,2);
    V_PercCascoD number(6,2);
    V_PercRCFDMA number(6,2);
    V_PercRCFDMD number(6,2);
    V_PercA number(6,2);
    V_PercD number(6,2);
    V_DescMod number(6,2);
    V_VigTabela number(6);
    V_QTREN number(6);
    V_ZEROKMPROMO number(1);
    V_CobTaxa number(2);
    V_SomaEquip number(16,6);
    V_peso TABELA_VEICULOMODELO.NO_PESO_VEICULO%TYPE;
    V_Potencia TABELA_VEICULOMODELO.NO_POTENCIA_VEICULO%TYPE;
    V_TP_Comb Varchar(2);
    V_TP_Vidro Varchar(2);
    V_Frq_Roubo TABELA_VEICULOMODELO.VL_FRQ_ROUBO_FURTO%TYPE;
    V_Frq_Colisao TABELA_VEICULOMODELO.VL_FRQ_COLISAO%TYPE;
    V_Frq_Gdm TABELA_VEICULOMODELO.VL_FRQ_GDM%TYPE;
    V_Cd_Tipo TABELA_VEICULOMODELO.CD_TIPO_VEICULO%TYPE;
    V_No_Carga TABELA_VEICULOMODELO.NO_CARGA_VEICULO%TYPE;
    V_TpAss24h NUMBER(10);
    V_VlrAss24h NUMBER(10,2);
    v_tipoTabela VARCHAR(1);
    V_VIGENCIA SMALLINT;
    V_CODIGO_QUESTIONARIO VARCHAR(5);
    V_VERSAO_QUESTIONARIO NUMBER(6);
    V_IND_RENOVACAO500 VARCHAR(1);
    V_TIPOSEGURO VARCHAR2(1);
	V_POSSUIDISPOSITIVO	VARCHAR2(5);

    Cursor TCAMPOS Is
       Select VALOR_MEDIO, valor_minimo, VALOR_MEDIO_Ant, valor_minimo_ant, familia from Vw_ValorMercado1
       where Modelo = PMODELO and Tipo_tabela = 'F' and
        Combustivel = PPROCEDENCIA and Ano_Modelo = 9999;
     Cursor TCAMPON Is
       Select VALOR_MEDIO, valor_minimo, VALOR_MEDIO_Ant, valor_minimo_ant, familia from Vw_ValorMercado1
       where Modelo = PMODELO and Tipo_tabela = 'F' and
        Combustivel = PPROCEDENCIA and Ano_Modelo = PANOMODELO;
    Cursor TACES Is
       SELECT ACESSORIO,VALOR FROM MULT_CALCULOACES
       WHERE CALCULO = PCALCULO
       AND ITEM    = PITEM
       AND VALOR   > 0 and (SUBTIPO = 2);
    Cursor TEQP Is
       SELECT ACESSORIO,VALOR FROM MULT_CALCULOACES
       WHERE CALCULO = PCALCULO
       AND ITEM    = PITEM
       AND VALOR   > 0 and (SUBTIPO = 1);
    Cursor TQBR1 is
       Select questao, resposta, subresposta, AgrupamentoRegiaoQbr, RESPOSTA2, GRUPO  from Mult_CalculoQbr
       where calculo = PCALCULO
       and item = PITEM
       and valida = 'S';
begin

/*  Busca codigo do corretor*/
    V_CodCorr := 0;
    Begin
    SELECT T1.DIVISAO_SUPERIOR into V_CodCorr
      FROM TABELA_DIVISOES T1, MULT_CALCULODIVISOES T2
      WHERE T2.CALCULO = Pcalculo
      AND T2.DIVISAO = T1.DIVISAO AND T2.NIVEL = 1 AND T1.TIPO_DIVISAO = 'E';
    Exception
      When OTHERS then
      begin
         V_CodCorr := 0;
      end;
    end;
    V_Str := '0000';
/*  Busca codigo da Agencia Captadora*/
    V_AGCapt := 0;
    Begin
    SELECT T1.COD_CONV into V_Str
      FROM TABELA_DIVISOES T1, MULT_CALCULODIVISOES T2
      WHERE T2.CALCULO = Pcalculo
      AND T2.DIVISAO = T1.DIVISAO AND T2.NIVEL = 2 AND T1.TIPO_DIVISAO = 'A';
      V_AGCapt := SubStr(V_Str,1,4);
    Exception
      When OTHERS then
      begin
         V_Str := '0000';
         V_AGCapt := 0;
      end;
    end;
/*  Obtem dados do Veiculo*/
    begin
    if (PvarInt1 = 1) then
       SELECT COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA, NUMPASSAGEIROS,
              NO_PESO_VEICULO, NO_POTENCIA_VEICULO, TIPO_COMBUSTIVEL, TP_VIDRO, VL_FRQ_ROUBO_FURTO, VL_FRQ_COLISAO, VL_FRQ_GDM, CD_TIPO_VEICULO, NO_CARGA_VEICULO into
              V_COD_REFERENCIA, V_COD_REFERENCIA_INC, V_COD_REFERENCIA_RINC, V_FAMILIA, V_CATEG_TAR1, V_CATEGORIA, V_PROCEDENCIA, V_LOTACAO,
              V_peso, V_Potencia , V_TP_Comb , V_TP_Vidro , V_Frq_Roubo , V_Frq_Colisao, V_Frq_Gdm , V_Cd_Tipo , V_No_Carga
       FROM
              TABELA_VEICULOMODELO WHERE MODELO = PMODELO;
    else
       SELECT COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA, NUMPASSAGEIROS,
              NO_PESO_VEICULO, NO_POTENCIA_VEICULO, TIPO_COMBUSTIVEL, TP_VIDRO, VL_FRQ_ROUBO_FURTO, VL_FRQ_COLISAO, VL_FRQ_GDM, CD_TIPO_VEICULO, NO_CARGA_VEICULO into
              V_COD_REFERENCIA, V_COD_REFERENCIA_INC, V_COD_REFERENCIA_RINC, V_FAMILIA, V_CATEG_TAR1, V_CATEGORIA, V_PROCEDENCIA, V_LOTACAO,
              V_peso, V_Potencia , V_TP_Comb , V_TP_Vidro , V_Frq_Roubo , V_Frq_Colisao, V_Frq_Gdm , V_Cd_Tipo , V_No_Carga
       FROM
              TABELA_VEICULOMODELO_ANT WHERE MODELO = PMODELO;
    end if;
    Exception
      When OTHERS then
       begin
         V_COD_REFERENCIA := 0;
         V_COD_REFERENCIA_INC := 0;
         V_COD_REFERENCIA_RINC := 0;
         V_FAMILIA := 0;
         V_CATEG_TAR1 := 0;
         V_CATEGORIA := 0;
         V_PROCEDENCIA := '';
         V_LOTACAO := 0;
         V_peso := 0;
         V_Potencia := 0;
         V_TP_Comb := '';
         V_TP_Vidro := '';
         V_Frq_Roubo := 0;
         V_Frq_Colisao := 0;
         V_Frq_Gdm := 0;
         V_Cd_Tipo := 0;
         V_No_Carga := 0;
        end;
    end;
    if PPRODUTO = 11 then
        SELECT CHAVE4 AS NO_PESO_VEICULO, CHAVE5 AS NO_POTENCIA_VEICULO, TEXTO AS TIPO_COMBUSTIVEL,
           TEXTO AS TP_VIDRO, VALOR AS VL_FRQ_ROUBO_FURTO, VALOR2 AS VL_FRQ_COLISAO,
           VALOR3 AS VL_FRQ_GDM, VALOR4 AS CD_TIPO_VEICULO, VALOR5 AS NO_CARGA_VEICULO INTO
           V_peso, V_Potencia, V_TP_Comb, V_TP_Vidro, V_Frq_Roubo, V_Frq_Colisao, V_Frq_Gdm , V_Cd_Tipo, V_No_Carga
           FROM VW_TABRG_P11_T8888 WHERE CHAVE1 = PvarInt1
             AND CHAVE2 =PMODELO
             AND CHAVE3 =PFABRICANTE;
      V_TP_Comb := Trim(Substr(V_TP_Comb,1,1));
      V_TP_Vidro := Trim(Substr(V_TP_Vidro,2,1));
    end if;

    if PTipo_Cobertura = 2 then
       V_Refer := V_COD_REFERENCIA_INC;
    else
       if PTipo_Cobertura = 4 then
          V_Refer := V_COD_REFERENCIA_RINC;
       else
          V_Refer := V_COD_REFERENCIA;
       end if;
    end if;
    if (PTipo_Site = 'K') Then
       V_Categ := V_CATEG_TAR1;
    else
       V_Categ := PVALORBASE;
    end if;
    V_CodFami := '';
    if V_Familia = 1 then
       V_CodFami := 'DEMAI';
    end if;
    if V_Familia = 2 then
       V_CodFami := 'BLIND';
    end if;
    if V_Familia = 3 then
       V_CodFami := 'CARGA';
    end if;
    if V_Familia = 4 then
       V_CodFami := 'IMPOR';
    end if;
    if V_Familia = 5 then
       V_CodFami := 'POP';
    end if;
    if V_Familia = 6 then
       V_CodFami := 'DEMSV';
    end if;
    if V_Familia = 7 then
       V_CodFami := 'DEMVB';
    end if;
    if V_Familia = 8 then
       V_CodFami := 'IMPSV';
    end if;
    if V_Familia = 10 then
       V_CodFami := 'AAT';
    end if;
    if V_Familia = 11 then
       V_CodFami := 'ATT';
    end if;
    if V_Familia = 12 then
       V_CodFami := 'IACD';
    end if;
    if V_Familia = 13 then
       V_CodFami := 'IBC';
    end if;
    if V_Familia = 14 then
       V_CodFami := 'LEVEN';
    end if;
    if V_Familia = 15 then
       V_CodFami := 'LEVEI';
    end if;
    if V_Familia = 16 then
       V_CodFami := 'PESAN';
    end if;
    if V_Familia = 17 then
       V_CodFami := 'PESAI';
    end if;
    if V_Familia = 18 then
       V_CodFami := 'REBON';
    end if;
    if V_Familia = 19 then
       V_CodFami := 'REBOI';
    end if;
    begin
    select Valor,Texto into V_CategT, V_DCategT from VW_TABRG_P11_T24 where chave1 = V_Categ and   rownum = 1 ;
/*  Busca regi„o tarifaria*/
    V_M_Regiao := 0;
    V_CaracRegTar := 0;
    Select d1.VALOR4, d1.Chave1 into V_CaracRegTar, V_M_Regiao
    from VW_TABRG_P11_T50 d, VW_TABRG_P11_T25 d1
    where d.chave1  = PVarint1
          and   d.chave2 <= PCep
          and   d.chave3 >= PCep
          and   d1.valor5 = d.valor
          and   rownum = 1
          order by d.chave3 desc;
    Exception
      When OTHERS then
       begin
       V_CategT := 0;
       V_DCategT := '';
       V_CaracRegTar := 0;
       V_M_Regiao := 0;
       end;
    end;
    if V_M_Regiao = 0 then
       V_M_Regiao := PCOD_CIDADE;
    end if;
/*  Busca cotaÁ„o do Veiculo*/
    V_VALOR_MEDIO := 0;
    V_valor_minimo := 0;
    V_valor_medio_ant := 0;
    V_valor_minimo_ant := 0;
    V_FamiliaC := 0;
       v_tipoTabela := 'R';
       IF (PZERO = 'S') then
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
              d1.familia into
              V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
              V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       else
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
                 d1.familia
          into
                 V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
                 V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       end if;
    V_Val_Med := 0;
    V_ValorMin := 0;
    if (PvarInt1 = 2) then
       V_Val_Med := V_Valor_Medio_ant;
        if V_valor_minimo_Ant > 0 then
           V_ValorMin := V_valor_minimo_ant;
        else
           V_ValorMin := V_valor_medio_ant;
        end if;
    else
        V_Val_Med := V_Valor_Medio;
        if V_valor_minimo > 0 then
           V_ValorMin := V_valor_minimo;
        else
           V_ValorMin := V_valor_medio;
        end if;
    end if;
    V_Val_Blind := 1;
    if V_familiaC = 2 then
        begin
        select Valor2 into V_Val_Blind from VW_TABRG_P11_T25 where chave1 = V_M_Regiao and chave2 = 2 and rownum = 1;
        Exception
        When OTHERS then
          begin
             V_Val_Blind := 0;
          end;
        end;
        if V_Val_Blind <> 0 then
           V_Val_Blind := V_Val_Blind / 100;
           V_ValorMin := V_ValorMin * V_Val_Blind;
        end if;
    end if;
    if (V_Val_Med = 0) and (PCALCULOORIGEM > 0) and (PTIPOFROTA = 'D') and (V_ValorMin > 0) then
        V_Val_Med := V_ValorMin;
    end if;
/*  Busca descriÁ„o das categorias tarifarias*/
    begin
    SELECT DISTINCT DESCR_CATEG_ESTAT, DESCR_CATEG_SCORE into V_CategEstat, V_CategScore  FROM MULT_PRODUTOSQBRVEICULOS
    WHERE PRODUTO = PPRODUTO AND
          VIGENCIA = PvarInt1 AND
          MODELO =  PMODELO;
    Exception
    When OTHERS then
      begin
         V_CategEstat := 0;
         V_CategScore := 0;
      end;
    end;
/*  Busca Perda de Faturamento*/
    V_Perda := 0;
    begin
    SELECT VALOR INTO V_Perda FROM MULT_CALCULOCOB
      WHERE CALCULO = PCALCULO
      AND ITEM    = PITEM
      AND COBERTURA = 46;
    Exception
    When OTHERS then
      begin
         V_Perda := 0;
      end;
    end;
/*  Busca coberura de despesas extras*/
    begin
    SELECT OPCAO INTO V_DESPESAS FROM MULT_CALCULOCOB
      WHERE CALCULO = PCALCULO
      AND ITEM    = PITEM
      AND COBERTURA = 54;
    Exception
    When OTHERS then
      begin
         V_DESPESAS := 0;
      end;
    end;
    if V_DESPESAS = 2 then
      V_IS_DEXTR := PVALORVEICULO * 0.1;
      SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T1
           WHERE CHAVE1 = 2;
      if V_IS_DEXTR > V_MVALOR1 then
         V_IS_DEXTR := V_MVALOR1;
      end if;
    end if;
/*  Busca coberura de vidros*/
    V_CARAC322 := 0;
    IF PPRODUTO = 11 Then
       begin
       SELECT OPCAO INTO V_OPCAO FROM MULT_CALCULOCOB
         WHERE CALCULO = PCALCULO
         AND ITEM    = PITEM
         AND COBERTURA = 40;
       Exception
       When OTHERS then
         begin
           V_OPCAO := 0;
         end;
       end;
       if V_OPCAO = 1 then
         V_CARAC322 := 17472;
       end if;
       if V_OPCAO = 2 then
         V_CARAC322 := 17473;
       end if;
    end if;
/*  Busca coberura de carro reserva*/
    V_MISRes := 0;
/*  Busca taxa de casco*/
    V_CobTaxa := 63;
    V_SubTxCasco := '';
    V_Taxa_at := 0;
    if PSUBSCRICAO = 'S' then
       V_Taxa_at := PTAXA;
    else
       BEGIN
       SELECT TAXA_CASCO, TAXA_INC, TAXA_RINC, FRANQUIA, TAXA_FRANQ, FRQ_MINIMA, TAXA_CASCO_ANT, TAXA_INC_ANT, TAXA_RINC_ANT, FRANQUIA_ANT, TAXA_FRANQ_ANT, FRQ_MINIMA_ANT, SUBSCRICAO, SUBSCRICAO_ANT
         INTO V_TAXA_CASCO, V_TAXA_INC, V_TAXA_RINC, V_FRANQUIA, V_TAXA_FRANQ, V_FRQ_MINIMA, V_TAXA_CASCO_ANT, V_TAXA_INC_ANT, V_TAXA_RINC_ANT, V_FRANQUIA_ANT, V_TAXA_FRANQ_ANT, V_FRQ_MINIMA_ANT, V_SUBSCRICAO, V_SUBSCRICAO_ANT
         FROM REAL_TAXASAUTO
         WHERE COD_MODELO = V_Refer
           AND ANO_MODELO = PANOMODELO
           AND ZERO_KM    = PZERO
           AND COD_COB    = V_CobTaxa
           AND COD_REGIAO = V_M_Regiao;
       Exception
       When OTHERS then
         begin
           V_TAXA_CASCO := 0;
           V_TAXA_INC := 0;
           V_TAXA_RINC := 0;
           V_FRANQUIA := 0;
           V_TAXA_FRANQ := 0;
           V_FRQ_MINIMA := 0;
           V_TAXA_CASCO_ANT := 0;
           V_TAXA_INC_ANT := 0;
           V_TAXA_RINC_ANT := 0;
           V_FRANQUIA_ANT := 0;
           V_TAXA_FRANQ_ANT := 0;
           V_FRQ_MINIMA_ANT := 0;
           V_SUBSCRICAO := '';
           V_SUBSCRICAO_ANT := '';
         end;
       end;
       if PVALORVEICULO > 0 then
          if (PvarInt1 = 2) then
             V_SubTxCasco := V_SUBSCRICAO_ANT;
             if PITEM > 0 then
                if PTIPO_COBERTURA = 1 then
                   V_Taxa_at := V_TAXA_CASCO_ANT;
                else
                if PTIPO_COBERTURA = 2 then
                   V_Taxa_at := V_TAXA_INC_ANT;
                else
                   V_Taxa_at := V_TAXA_RINC_ANT;
                end if;
                end if;
            else
                if V_SUBSCRICAO_ANT is Null then
                   if PTIPO_COBERTURA = 1 then
                      V_Taxa_at := V_TAXA_CASCO_ANT;
                   else
                   if PTIPO_COBERTURA = 2 then
                      V_Taxa_at := V_TAXA_INC_ANT;
                   else
                      V_Taxa_at := V_TAXA_RINC_ANT;
                   end if;
                   end if;
                else
                   V_Taxa_at := 0;
                end if;
            end if;
          else
            V_SubTxCasco := V_SUBSCRICAO;
            if PITEM > 0 then
               if PTIPO_COBERTURA = 1 then
                  V_Taxa_at := V_TAXA_CASCO;
               else
               if PTIPO_COBERTURA = 2 then
                  V_Taxa_at := V_TAXA_INC;
               else
                  V_Taxa_at := V_TAXA_RINC;
               end if;
               end if;
            else
               if V_SUBSCRICAO is null then
                  if PTIPO_COBERTURA = 1 then
                     V_Taxa_at := V_TAXA_CASCO;
                  else
                  if PTIPO_COBERTURA = 2 then
                     V_Taxa_at := V_TAXA_INC;
                  else
                     V_Taxa_at := V_TAXA_RINC;
                  end if;
                  end if;
               else
                  V_Taxa_at := 0;
               end if;
            end if;
          end if;
      end if;
      if (PTIPO_COBERTURA = 3) and (PCalculoOrigem <> 0) then
          V_Taxa_at := 0;
      end if;
    end if;
/*  Busca valores de franquia*/
    V_Tx_Fran := 0;
    V_Franquia_ := 0;
    V_FranqMin := 0;
    if PSUBSCRICAO = 'S' then
       V_Franquia_ := PVLRFRANQUIASUB;
       if PTAXAFRANQUIASUB > 0 then
          V_Tx_Fran  := PTAXAFRANQUIASUB;
          V_Franquia_ := PVALORVEICULO * (V_Tx_fran / 100);
       end if;
       V_FranqMin := PVMINFRANQUIASUB;
       if V_Franquia_ < V_FranqMin then
          V_Franquia_ := V_FranqMin;
       end if;
    else
      if (PvarInt1 = 2) then
         V_Franquia_ := V_FRANQUIA_ANT;
         if V_Franquia_ = 0 then
            V_Tx_Fran  := V_TAXA_FRANQ_ANT;
            V_Franquia_ := PVALORVEICULO * (V_Tx_fran / 100);
         end if;
         V_FranqMin := V_FRQ_MINIMA_ANT;
         if V_Franquia_ <  V_FranqMin then
            V_Franquia_ := V_FranqMin;
         end if;
      else
         V_Franquia_ := V_FRANQUIA;
         if V_Franquia_ = 0 then
            V_Tx_Fran  := V_TAXA_FRANQ;
            V_Franquia_ := PVALORVEICULO * (V_Tx_fran / 100);
         end if;
         V_FranqMin := V_FRQ_MINIMA;
         if V_Franquia_ <  V_FranqMin then
            V_Franquia_ := V_FranqMin;
         end if;
      end if;
    end if;
    BEGIN
    SELECT VALOR, VALOR3 INTO V_MVALOR1, V_MVALOR3 FROM VW_TABRG_P11_T11
           WHERE CHAVE1 = PTIPO_FRANQUIA;
    Exception
    When OTHERS then
      begin
        V_MVALOR1 := 0;
        V_MVALOR3 := 0;
      end;
    end;
    if (PvarInt1 = 2) then
       V_Qtd_Frq1 := V_MVALOR3;
    else
       V_Qtd_Frq1 := V_MVALOR1;
    end if;
/*  Busca estipulante*/
    v_DEstipulante := 0;
    v_MEstipulante := 0;
    v_MProLabore   := 0;
    begin
    select d3.Pro_Labore, d4.Divisao_superior, d3.desconto INTO
           v_MProLabore, v_MEstipulante, v_DEstipulante
    from mult_calculodivisoes d, mult_calculodivisoes d2,
           tabela_divisoescomer d3, Tabela_divisoes d4
    where d.calculo = PCALCULO
      and d.nivel = 4
      and d2.calculo = d.calculo
      and d2.nivel = 1
      and d3.divisao = d.Divisao
      and d3.divisaoCom = d2.Divisao
      and d3.produto = PPRODUTO
      and d3.divisao = d4.divisao;
    Exception
      When OTHERS then
      begin
      v_DEstipulante := 0;
      v_MEstipulante := 0;
      v_MProLabore   := 0;
      end;
    end;

/*  ver tipo de negocio*/
    Begin
    SELECT DESCRICAORESPOSTA INTO V_TIPO_NEGOCIO FROM MULT_CALCULOQBR
           WHERE CALCULO = PCALCULO
           AND ITEM    = PITEM
           AND QUESTAO = 222;
    Exception
      When OTHERS then
      begin
      V_TIPO_NEGOCIO := 'Real';
      end;
    end;
    PCampo := '';
    PCampo := PCampo || 'I_CD_PROGRAMA_=KITCALC@';
    PCampo := PCampo || 'I_IND_ROTINA_=K@';

    SELECT TIPOSEGURO INTO V_TIPOSEGURO FROM MULT_CALCULO WHERE CALCULO = PCALCULO;

    if (PCALCULOORIGEM > 0) then
       PCampo := PCampo || 'I_TP_NEGOCIO_=R@';
    else
      if (V_TIPOSEGURO = 1) then
        PCampo := PCampo || 'I_TP_NEGOCIO_=P@';
      else
        if (V_TIPOSEGURO = 2) or (V_TIPOSEGURO = 3) then
          PCampo := PCampo || 'I_TP_NEGOCIO_=C@';
        else
          if (V_TIPOSEGURO = 4) or (V_TIPOSEGURO = 5) then
            PCampo := PCampo || 'I_TP_NEGOCIO_=M@';
          end if;
        end if;
      end if;
    end if;

    PCampo := PCampo || 'I_COD_MOD_PROD_=9@';
    PCampo := PCampo || 'I_NO_CEP_=' || LTrim(TO_CHAR(PCep,'00000000')) || '@';
    PCampo := PCampo || 'I_COD_AGRP_VEIC_=' || TO_CHAR(V_Refer) || '@';
    PCampo := PCampo || 'I_ANO_MODELO_='  ||  TO_CHAR(PANOMODELO) || '@'  ;
    PCampo := PCampo || 'I_ANO_FABRICACAO_='  ||  TO_CHAR(PANOFABRICACAO) || '@'  ;
    PCampo := PCampo || 'I_ID_00K_=' || PZERO || '@';
    PCampo := PCampo || 'I_CD_FABRICANTE_=' || TO_CHAR(PFABRICANTE) || '@';
    PCampo := PCampo || 'I_CD_MARCA_MODELO_=' || TO_CHAR(PMODELO) || '@';
    PCampo := PCampo || 'I_CD_REGIAO_=' || TO_CHAR(v_CaracRegTar) || '@';
    PCampo := PCampo || 'I_COD_FAMILIA_=' || V_CodFami || '@';
    PCampo := PCampo || 'I_NM_CATEG_SCORE_=' || V_CategScore || '@';
    PCampo := PCampo || 'I_CD_CATEG_TARIF_=' || TO_CHAR(v_CategT) || '@';

    if (PCRIVO = 'S') then
      if PCALCULOORIGEM > 0 then
        PCampo := PCampo || 'I_NO_ITEM_=0@';
        PCampo := PCampo || 'I_DESC_CATEGORIA_=0@';
      else
        PCampo := PCampo || 'I_NO_ITEM_='|| PCODRETURN|| '@';
        PCampo := PCampo || 'I_DESC_CATEGORIA_=' ||v_CategT || '@';
      end if;
    else
      PCampo := PCampo || 'I_DESC_CATEGORIA_=' || TO_CHAR(v_CategT) || '@';
    end if;

    PCampo := PCampo || 'I_DS_CATEG_TARIF_=' || V_DCategT || '@';
    if PTIPO_FRANQUIA = 0 then
       V_PTIPO_FRANQUIA := 4;
    else
       V_PTIPO_FRANQUIA := PTIPO_FRANQUIA;
    end if;
    PCampo := PCampo || 'I_TP_FRANQUIA_=' || To_Char(V_PTIPO_FRANQUIA) || '@';
    Vstr := LTrim(TO_CHAR(V_Franquia_,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VAL_FRANQUIA_CA_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(v_MProLabore,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PROLABORE_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(V_FranqMin,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VL_FRANQUIA_MIN_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(V_Tx_Fran,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_FRANQUIA_=' || Vstr || '@';
/*  ver DESCONTO PROMOCIONAL*/
    if PZERO = 'S' then
       V_ZEROKMPROMO := 1;
    else
       V_ZEROKMPROMO := 0;
    end if;
    begin
    if (PvarInt1 = 2) then
      SELECT Valor, texto into V_DescPromo, V_TipoDescPromo FROM MULT_PRODUTOSTABRG WHERE
          PRODUTO = 11
          AND TABELA = 10008
          AND (CHAVE1  = 999999999 OR CHAVE1 = V_CaracRegTar)
          AND (CHAVE2  = 999999999 OR CHAVE2 = V_Refer)
          AND (CHAVE3  = 9999 OR CHAVE3 = PANOMODELO)
          AND (CHAVE4 = V_ZEROKMPROMO)
          AND ROWNUM = 1
          ORDER BY CHAVE1, CHAVE2, CHAVE3;
      V_DescPromo := 0;
      V_TipoDescPromo := '';
    else
      SELECT Valor, texto into V_DescPromo, V_TipoDescPromo FROM VW_TABRG_P11_T8 WHERE
          (CHAVE1  = 999999999 OR CHAVE1 = V_CaracRegTar)
          AND (CHAVE2  = 999999999 OR CHAVE2 = V_Refer)
          AND (CHAVE3  = 9999 OR CHAVE3 = PANOMODELO)
          AND (CHAVE4 = V_ZEROKMPROMO)
          AND ROWNUM = 1
          ORDER BY CHAVE1, CHAVE2, CHAVE3;
    end if;
    Exception
      When OTHERS then
      begin
      V_DescPromo := 0;
      V_TipoDescPromo := '';
      end;
    end;
    Vstr := LTrim(TO_CHAR(V_DescPromo,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_DESC_AGRAV_PROMO_=' || Vstr || '@';
    PCampo := PCampo || 'I_ID_DESC_AGRAV_PROMO_=' || V_TipoDescPromo || '@';
    PCampo := PCampo || 'I_CI_BONUS_=' || To_Char(PNIVELBONUSAUTO) || '@';
    if PCALCULOORIGEM > 0 then
       PCampo := PCampo || 'I_ID_RENOV_AUTOM_=R@';
    else
       PCampo := PCampo || 'I_ID_RENOV_AUTOM_=@';
    end if;
/*  ver Comodato*/
    BEGIN
    SELECT RESPOSTA, DESCRICAORESPOSTA2, SUBRESPOSTA, SUBRESPOSTA2 INTO V_RESPOSTA, V_DESCRICAORESPOSTA2, V_SUBRESPOSTA, V_SUBRESPOSTA2 FROM MULT_CALCULOQBR
       WHERE CALCULO = PCALCULO
       AND ITEM    = PITEM
	   AND (QUESTAO = 243 OR QUESTAO = 244);
       IF (V_RESPOSTA = 586 OR V_RESPOSTA = 585) then
         BEGIN
         SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T305
	         WHERE
	         CHAVE1  = V_RESPOSTA
	         AND CHAVE2  = V_SUBRESPOSTA;
         Exception
         When OTHERS then
         begin
            V_MVALOR1 := 0;
         end;
         end;
         if V_MVALOR1 = 1 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=B@';
         else
         if V_MVALOR1 = 2 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=R@';
         else
         if V_MVALOR1 = 3 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=S@';
         else
         if V_MVALOR1 = 4 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=P@';
         else
         if V_MVALOR1 = 5 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=L@';
         else
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=@';
         end if;
         end if;
         end if;
         end if;
         end if;
         PCampo := PCampo || 'I_CD_GERENC_RISCO_=' || To_Char(V_SUBRESPOSTA2) || '@';                   PCampo := PCampo || 'I_NO_CTO_COMODATO_=' || RTrim(V_DESCRICAORESPOSTA2) || '@';                   V_CodComodato := RTrim(V_DESCRICAORESPOSTA2);
       else
         PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=@';
	     PCampo := PCampo || 'I_CD_GERENC_RISCO_=0@';
         PCampo := PCampo || 'I_NO_CTO_COMODATO_=' || RTrim(V_DESCRICAORESPOSTA2) || '@';                   V_CodComodato := RTrim(V_DESCRICAORESPOSTA2);
       end if;
    Exception
      When OTHERS then
      begin
         PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=@';
	     PCampo := PCampo || 'I_CD_GERENC_RISCO_=0@';
	     PCampo := PCampo || 'I_NO_CTO_COMODATO_=@';
         v_CodComodato := '';
      end;
    end;
/*  ver QBR e Dispositivo de SeguranÁa*/
       if PTipo_Cobertura = 1 then
          V_CobTokio := 63;
       end if;
       if PTipo_Cobertura = 2 then
          V_CobTokio := 64;
       end if;
       if PTipo_Cobertura = 3 then
          V_CobTokio := 0;
       end if;
       if PTipo_Cobertura = 4 then
          V_CobTokio := 158;
       end if;
    if PvarInt1 = 2 then
       V_VigTabela := 10304;
    else
       V_VigTabela := 304;
    end if;
    V_OPCAO := 0;
    V_TReg := 0;
    V_PercCascoA := 0;
    V_PercRcfDmA := 0;
    V_PercCascoD := 0;
    V_PercRcfDmD := 0;
    PCampo_v := 'I_GRUPO_QBR_=';
    Open TQBR1;
    Loop
       Fetch TQBR1 Into v_questao, v_resposta, v_subresposta, V_AgrupamentoRegiaoQbr, V_RESPOSTA2, V_CODIGO_QUESTIONARIO;
       Exit When TQBR1%Notfound;
       V_PercA := 0;
       V_PercD := 0;
       if (V_QUESTAO = 243 OR V_QUESTAO = 244) then
          if (V_RESPOSTA = 586 OR V_RESPOSTA = 585) then
             if V_RESPOSTA2 > 0 then
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=C@I_CD_DISPOSITIVO_=0@';
             else
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=P@I_CD_DISPOSITIVO_=' || V_SUBRESPOSTA || '@';
             end if;
             begin
    	     SELECT T2.RANKING into V_MValor2 FROM MULT_PRODUTOSQBRTIPOSDISP T2, MULT_PRODUTOSQBRDISPSEG T1
	       	        WHERE T2.PRODUTO = PPRODUTO
                    AND T2.VIGENCIA = PVarint1
	       	        AND T1.PRODUTO = T2.PRODUTO
                    AND T1.VIGENCIA = T2.VIGENCIA
	       	        AND T1.TIPO   = T2.TIPO
	       	        AND T1.RESPOSTA  = V_RESPOSTA
	       	        AND T1.DISPOSITIVO  = V_SUBRESPOSTA;
             Exception
             When OTHERS then
             begin
                  V_MValor2 := 0;
             end;
             end;
             PCampo := PCampo || 'I_NO_RANK_SEGURANCA_=' || To_Char(V_MValor2) || '@';
          else
             if V_RESPOSTA2 > 0 then
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=C@I_CD_DISPOSITIVO_=0@';
             else
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=N@I_CD_DISPOSITIVO_=0@';
             end if;
             PCampo := PCampo || 'I_NO_RANK_SEGURANCA_=0@';
          end if;
          V_OPCAO := 1;
          if v_CodComodato <> ' ' then
            if V_QUESTAO = 243 then
              V_RESPOSTA := 633;
            else
              V_RESPOSTA := 636;
            end if;
          end if;
       end if;
       if (v_questao = 87) and (v_resposta = 0) then
          v_resposta := 192;
       end if;
       if PTipo_Cobertura <> 3 then
       begin
          Select PERCENTUAL, TIPOPERCENTUAL into V_MValor1, V_MValor2 from MULT_PRODUTOSQBRRESPOSTAS
               where PRODUTO = PPRODUTO and VIGENCIA = PvarInt1 and Cobertura  = V_CobTokio and QUESTAO = v_questao
                    and AGRUPAMENTO = V_AgrupamentoRegiaoQbr and RESPOSTA  = v_resposta and rownum = 1;
          Exception
          When OTHERS then
          begin
            V_MValor1 := 0;
            V_MValor2 := 0;
          end;
          end;
          if V_MValor2 = 1 then
            V_PercA := V_PercA + V_MValor1;
            V_PercCascoA := V_PercCascoA + V_MValor1;
          else
             V_PercD := V_PercD + V_MValor1;
             V_PercCascoD := V_PercCascoD + V_MValor1;
          end if;
       end if;
       if PNIVELDM > 0 then
       begin
          Select PERCENTUAL, TIPOPERCENTUAL into V_MValor1, V_MValor2 from MULT_PRODUTOSQBRRESPOSTAS
               where PRODUTO = PPRODUTO and VIGENCIA = PvarInt1 and COBERTURA  = 21 and QUESTAO = v_questao
                    and AGRUPAMENTO = V_AgrupamentoRegiaoQbr and RESPOSTA  = v_resposta and rownum = 1;
          Exception
          When OTHERS then
          begin
              V_MValor1 := 0;
              V_MValor2 := 0;
          end;
          end;
          if V_MValor2 = 1 then
             V_PercRcfDmA := V_PercRcfDmA + V_MValor1;
          else
             V_PercRcfDmD := V_PercRcfDmD + V_MValor1;
          end if;
          if PTipo_Cobertura = 3 then
            if V_MValor2 = 1 then
               V_PercA := V_PercA + V_MValor1;
            else
               V_PercD := V_PercD + V_MValor1;
            end if;
          end if;
       end if;
       PCampo_v := PCampo_v || TO_Char(V_questao) || ';' || to_char(V_resposta) || ';' || TO_Char(V_PercD) || ';' || to_char(V_PercA) || '|';
       V_TReg := V_TReg + 1;
    End Loop;
    close TQBR1;
    if V_OPCAO = 0 then
       PCampo := PCampo || 'I_IND_DISPOSITIVO_=N@I_CD_DISPOSITIVO_=0@';
    end if;
    Loop
       Exit When V_TReg = 30;
       PCampo_v := PCampo_v || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;


    PCampo_v := PCampo_v || '@';
    PCampo := PCampo || PCampo_v;
    PCampo := PCampo || 'ACTOCCURSI_GRUPO_QBR=30@';

    V_SomaAces := 0;
    V_SomaEquip := 0;
    if PTIPO_COBERTURA <> 3 then
       V_SomaAces := PLMI_BLINDAGEM + PLMI_KITGAS;
       BEGIN
       SELECT OPCAO INTO V_OPCAO FROM MULT_CALCULOCOB
          WHERE CALCULO = PCALCULO
          AND ITEM    = PITEM
          AND COBERTURA = 979;
        Exception
        When OTHERS then
         begin
           V_OPCAO := 0;
         end;
       end;
       if V_OPCAO = 1 then
          SELECT SUM(VALOR) into V_ACES FROM MULT_CALCULOACES
              WHERE CALCULO = PCALCULO
                AND ITEM    = PITEM
                AND VALOR   > 0 AND (SUBTIPO = 2 and PPRODUTO = 11);
          if V_ACES > 0 then
            V_SomaAces := V_SomaAces + V_ACES;
          end if;
          V_ACES := 0;
          SELECT SUM(VALOR) into V_ACES FROM MULT_CALCULOACES
              WHERE CALCULO = PCALCULO
                AND ITEM    = PITEM
                AND VALOR   > 0 AND (SUBTIPO = 1 AND PPRODUTO = 11);
          if V_ACES > 0 then
            V_SomaEquip := V_SomaEquip + V_ACES;
          end if;
       end if;
       Vstr := LTrim(TO_CHAR(V_SomaAces,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_LIM_ACESSORIA_=' || Vstr || '@';
       Vstr := LTrim(TO_CHAR(V_SomaEquip,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_LMI_EQUIP_=' || Vstr || '@';
       if Pproduto = 11 then
          Vstr := LTrim(TO_CHAR(PCOD_TABELA,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          PCampo := PCampo || 'I_LIM_CARROC_=' || Vstr || '@';
       else
          PCampo := PCampo || 'I_LMI_CARROC_=0,00@';
       end if;
    else
       PCampo := PCampo || 'I_LIM_ACESSORIA_=0,00@';
       PCampo := PCampo || 'I_LMI_EQUIP_=0,00@';
       PCampo := PCampo || 'I_LMI_CARROC_=0,00@';
    end if;
    V_TReg := 0;
    PCampo := PCampo || 'I_GRUPO_ACESSORIO_=';
    if PTIPO_COBERTURA <> 3 then
       if PLMI_BLINDAGEM > 0 then
          Vstr := LTrim(TO_CHAR(PLMI_BLINDAGEM,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          if Pproduto = 11 then
             PCampo := PCampo || '0;' || Vstr || ';';
          else
             PCampo := PCampo || '14249;' || Vstr || ';' ;
          end if;
          Vstr := LTrim(TO_CHAR(V_Taxa_at * 1000000,'000000000'));
          Vstr := translate(Vstr,'.',',');
          PCampo := PCampo || Vstr || ';0|';
  	      V_TReg := V_TReg + 1;
	   end if;
       if PLMI_KITGAS > 0 then
          Vstr := LTrim(TO_CHAR(PLMI_KITGAS,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          if Pproduto = 11 then
             PCampo := PCampo || '14251;' || Vstr || ';';
          else
             PCampo := PCampo || '14250;' || Vstr || ';' ;
          end if;
          Vstr := LTrim(TO_CHAR(V_Taxa_at * 1000000,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          PCampo := PCampo || Vstr || ';0|';
  	      V_TReg := V_TReg + 1;
	   end if;
       if V_OPCAO = 1 then
           Open TACES;
           Loop
              Fetch TACES Into V_ACESSORIO,V_VALOR;
                 Exit When TACES%Notfound;
              PCampo := PCampo || TO_CHAR(V_ACESSORIO) || ';';
              Vstr := LTrim(TO_CHAR(V_VALOR,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';' ;
              BEGIN
                 if (PvarInt1 = 1) then
                    SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T51
                    WHERE CHAVE1 = 69 AND CHAVE2 = V_ACESSORIO;
                 else
                    SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T52
                   WHERE CHAVE1 = 69 AND CHAVE2 = V_ACESSORIO;
                 end if;
              Exception
              When OTHERS then
                begin
                  V_MVALOR1 := 0;
                end;
              end;
              Vstr := LTrim(TO_CHAR(V_Mvalor1 * 1000000,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';0|';
              V_TReg := V_TReg + 1;
           End Loop;
           close TACES;
       end if;
    end if;
    Loop
       Exit When V_TReg = 10;
       PCampo := PCampo || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo := PCampo || '@ACTOCCURSI_GRUPO_ACESSORIO=10@';
    V_TReg := 0;
    PCampo := PCampo || 'I_GRUPO_EQUIPAMENTO_=';
    if PTIPO_COBERTURA <> 3 then
       if V_OPCAO = 1 then
           if PProduto = 11 then
           Open TEQP;
           Loop
              Fetch TEQP Into V_ACESSORIO,V_VALOR;
                 Exit When TEQP%Notfound;
              PCampo := PCampo || TO_CHAR(V_ACESSORIO) || ';';
              Vstr := LTrim(TO_CHAR(V_VALOR,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';' ;
              BEGIN
              if (PvarInt1 = 1) then
                 SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T51
                 WHERE CHAVE1 = 71 AND CHAVE2 = V_ACESSORIO;
              else
                 SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T52
                WHERE CHAVE1 = 71 AND CHAVE2 = V_ACESSORIO;
              end if;
              Exception
              When OTHERS then
                begin
                 V_MVALOR1 := 0;
                end;
              end;
              Vstr := LTrim(TO_CHAR(V_Mvalor1 * 1000000,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';0|';
              V_TReg := V_TReg + 1;
           End Loop;
           close TEQP;
           end if;
       end if;
    end if;
    Loop
       Exit When V_TReg = 10;
       PCampo := PCampo || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo := PCampo || '@ACTOCCURSI_GRUPO_EQUIPAMENTO=10@';
    PCampo := PCampo || 'I_DT_INI_VIGENCIA_=' || TO_CHAR(PINICIOVIGENCIA,'YYYYMMDD') || '@';
    PCampo := PCampo || 'I_DT_FIM_VIGENCIA_=' || TO_CHAR(PFINALVIGENCIA,'YYYYMMDD') || '@';
    PCampo := PCampo || 'I_TP_PESSOA_=' || PTIPO_PESSOA || '@';
    if PCOD_TABELA = 1 then
       PCampo := PCampo || 'I_CD_TAB_ACEITE_=4@';
    else
       PCampo := PCampo || 'I_CD_TAB_ACEITE_=2@';
    end if;
    if PMODALIDADE = 'A' then
       if (PTipo_Site = 'K') Then
          V_Ajuste := PAjuste;
       else
          V_Ajuste := PP_Ajuste;
       end if;
    else
       if V_Val_Med > 0 then
          V_Ajuste := PVALORVEICULO / V_Val_Med * 100;
       else
       if V_ValorMin > 0 then
          V_Ajuste := PVALORVEICULO / V_ValorMin * 100;
       else
          V_Ajuste := 100;
       end if;
       end if;
    end if;
    Vstr := LTrim(TO_CHAR(V_Ajuste,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PER_CONTRATACAO_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(V_Ajuste * 1000000,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_TAB_ACEITE_=' || Vstr || '@';
    PCampo := PCampo || 'I_CD_CORRETOR_=' || TO_CHAR(V_CodCorr) || '@';
    PCampo := PCampo || 'I_NO_ESTIP_=' || to_Char(V_MEstipulante) || '@';
    if PESTADO = 'S' then
       PCampo := PCampo || 'I_TP_ASS_24H_=4485@';
       V_TpAss24h := 4485;
    else
      if PESTADO = 'V' then
        PCampo := PCampo || 'I_TP_ASS_24H_=17474@';
        V_TpAss24h := 17474;
      else
        PCampo := PCampo || 'I_TP_ASS_24H_=4486@';
        V_TpAss24h := 4486;
      end if;
    end if;
    V_VlrAss24h := 0;
    begin
      if (PvarInt1 = 2) then
        SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T13 WHERE CHAVE1 = 1;
      else
        SELECT VALOR2 INTO V_MVALOR1 FROM VW_TABRG_P11_T13 WHERE CHAVE1 = 1;
      end if;
    Exception
      When OTHERS then
      begin
        V_MValor1 := 0;
      end;
    end;

    V_VlrAss24h  := V_MValor1;
    Vstr := LTrim(TO_CHAR(Abs(V_VlrAss24h),'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VL_ASSIST_24H_=' || Vstr || '@';
    if V_MISRes = 1000 then
       PCampo := PCampo || 'I_TP_CARRO_REV_=10752@';
    else
    if V_MISRes = 2000 then
       PCampo := PCampo || 'I_TP_CARRO_REV_=10753@';
    else
       PCampo := PCampo || 'I_TP_CARRO_REV_=4615@';
    end if;
    end if;
        if V_IS_Dextr <> 0 then
            PCampo := PCampo || 'I_TP_COB_EXTRA_=4227@';
        else
            PCampo := PCampo || 'I_TP_COB_EXTRA_=4617@';
        end if;
    PCampo := PCampo || 'I_TP_COB_VIDROS_=' || To_Char(V_Carac322) || '@';
    PCampo := PCampo || 'I_ID_CATEG_SUBSCRICAO_=0@';
    PCampo := PCampo || 'I_CD_CARAC_SUBSCRICAO_=0@';
    PCampo := PCampo || 'I_ID_VEIC_SUBSCRICAO_=' || V_SubTxCasco || '@';
    PCampo := PCampo || 'I_CD_LOTACAO_=' || TO_CHAR(v_Lotacao) || '@';

--Alt REV1208

    V_POSSUIDISPOSITIVO := '0';
    SELECT RESPOSTA INTO V_POSSUIDISPOSITIVO FROM MULT_CALCULOQBR WHERE CALCULO = PCalculo AND QUESTAO = 244;
    if V_POSSUIDISPOSITIVO = '582' then
      PCampo := PCampo || 'I_POSSUI_DISPOSITIVO_=17478@';
    else
      if V_POSSUIDISPOSITIVO = '586' then
        PCampo := PCampo || 'I_POSSUI_DISPOSITIVO_=17479@';
      else
        if V_POSSUIDISPOSITIVO = '633' then
          PCampo := PCampo || 'I_POSSUI_DISPOSITIVO_=17480@';
        else
          if V_POSSUIDISPOSITIVO = '634' then
            PCampo := PCampo || 'I_POSSUI_DISPOSITIVO_=17481@';
		  else
  		    if V_POSSUIDISPOSITIVO = '634' then
			  PCampo := PCampo || 'I_POSSUI_DISPOSITIVO_=17481@';
			end if;
          end if;
        end if;
      end if;
    end if;

    SELECT IND_RENOVACAO500 INTO V_IND_RENOVACAO500 FROM MULT_CALCULO WHERE CALCULO = PCALCULO;

    if (PCRIVO = 'S') then
	    if PRETORNOSUBSCR <> '0' then
        PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_='||PRETORNOSUBSCR||'@';
      else
        PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_='||PCODRETURN||'@';
      end if;
    else
        PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_=0@';
    end if;
    PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_='|| PINDSINISTRO ||'@';



/*    if PCALCULOORIGEM > 0 then
       Vstr := LTrim(TO_CHAR(Abs(V_PDesc_Score),'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_=' || Vstr || '@';
       if V_PDesc_Score < 0 then
          PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_=A@';
       else
       if V_PDesc_Score > 0 then
          PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_=D@';
       else
          PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_=@';
       end if;
       end if;
    else
       PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_=0@';
       PCampo := PCampo ||  'I_IN_DESC_AGRAV_SCORE_=@';
    end if;*/

    if PTIPO_COBERTURA <> 3 then
      Vstr := LTrim(TO_CHAR(v_PercCascoD,'000000000.00'));
      Vstr := translate(Vstr,'.',',');
      PCampo := PCampo || 'I_TX_DESC_QBR_=' || Vstr || '@';
      Vstr := LTrim(TO_CHAR(v_PercCascoA,'000000000.00'));
      Vstr := translate(Vstr,'.',',');
      PCampo := PCampo || 'I_TX_AGRAV_QBR_=' || Vstr || '@';
    else
      Vstr := LTrim(TO_CHAR(v_PercRcfDmD,'000000000.00'));
      Vstr := translate(Vstr,'.',',');
      PCampo := PCampo || 'I_TX_DESC_QBR_=' || Vstr || '@';
      Vstr := LTrim(TO_CHAR(v_PercRcfDmA,'000000000.00'));
      Vstr := translate(Vstr,'.',',');
      PCampo := PCampo || 'I_TX_AGRAV_QBR_=' || Vstr || '@';
    end if;
 /* busca bonus casco*/
    V_PBonusCasco := 0;
    V_QtRen := 0;
    if PvarInt1 = 2 then
       V_VigTabela := 10306;
    else
       V_VigTabela := 306;
    end if;
    if PNIVELBONUSAUTO > 0 then
       if PTIPO_COBERTURA <> 3 then
          BEGIN
          if PNIVELBONUSAUTO > 9 then
            SELECT NIVEL, BONUSAUTO into V_QtRen, V_PBonusCasco FROM MULT_PRODUTOSBONUS
            WHERE PRODUTO = pproduto
            AND NIVEL = 9;
          else
            SELECT NIVEL, BONUSAUTO into V_QtRen, V_PBonusCasco FROM MULT_PRODUTOSBONUS
            WHERE PRODUTO = pproduto
            AND NIVEL = PNIVELBONUSAUTO;
          end if;
          Exception
          When OTHERS then
            begin
              V_QtRen  := 0;
              V_PBonusCasco := 0;
            end;
          end;
          begin
          SELECT PERCDESC into V_MValor1 FROM MULT_PRODUTOSQBRABATBONUS
          WHERE PRODUTO = PPRODUTO
                AND FAMILIA = V_Familia
                AND COBERTURA = V_CobTokio
                AND CLBONUS = V_QTREN
                AND VIGENCIA = PvarInt1
                AND FAIXADESCDE  >= (V_PercCascoD - V_PercCascoA)
                AND FAIXADESCATE  <= (V_PercCascoD - V_PercCascoA);
          Exception
          When OTHERS then
          begin
              V_MValor1 := 0;
          end;
          end;
          V_PBonusCasco := V_PBonusCasco + V_MValor1;
       end if;
    end if;
    Vstr := LTrim(TO_CHAR(V_PBonusCasco,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_DESC_BONUS_=' || Vstr || '@';
    if PTIPO_COBERTURA <> 3 then
       begin
       if PvarInt1 = 1 then
          SELECT VALOR2, TEXTO INTO V_MVALOR2, V_TEXTO FROM VW_TABRG_P11_T9 WHERE
		           CHAVE1  = V_CobTokio
		           AND CHAVE2  = V_CaracRegTar
		           AND CHAVE3  = V_PTIPO_FRANQUIA;
       else
/*
           VERIFICAR
           SELECT VALOR2, TEXTO INTO V_MVALOR2, V_TEXTO FROM VW_TABRG_P11_T10009 WHERE
		           CHAVE1  = V_CobTokio
		           AND CHAVE2  = V_CaracRegTar
		           AND CHAVE3  = V_PTIPO_FRANQUIA;
*/
           V_MValor2 := 0;
           V_TEXTO := 'D';
       end if;
       Exception
       When OTHERS then
       begin
           V_MValor2 := 0;
           V_TEXTO := 'D';
       end;
       end;
       Vstr := LTrim(TO_CHAR(V_MValor2,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_PE_DESC_AGRAV_FRANQ_=' || Vstr || '@';
       PCampo := PCampo || 'I_IN_DESC_AGRAV_FRANQ_=' || V_TEXTO || '@';
    else
       PCampo := PCampo || 'I_PE_DESC_AGRAV_FRANQ_=0,00@';
       PCampo := PCampo || 'I_IN_DESC_AGRAV_FRANQ_=D@';
    end if;
    Vstr := LTrim(TO_CHAR((V_Taxa_at * 100000), '9999999990') || '0');
    PCampo := PCampo || 'I_PE_TAXA_ATUARIAL_=' || Vstr || '@';
    PCampo := PCampo || 'I_TP_RELACIONAMENTO_=C@';
        if PPROCEDENCIA  = 'G' then
            PCampo := PCampo || 'I_CD_COMBUSTIVEL_=2374@';
        else
            if PPROCEDENCIA  = 'A' then
                PCampo := PCampo || 'I_CD_COMBUSTIVEL_=2373@';
            else
                PCampo := PCampo || 'I_CD_COMBUSTIVEL_=2375@';
            end if;
         end if;
    V_DescMod  := 0;
    Vstr := LTrim(TO_CHAR(V_DescMod ,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_TX_DESCONTO_=' || Vstr || '@';
    If PDias < 365 then
       PCampo := PCampo || 'I_CD_PRAZO_CURTO_=S@';
    else
       PCampo := PCampo || 'I_CD_PRAZO_CURTO_=@';
    end if;
    Vstr := LTrim(TO_CHAR(V_DEstipulante,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_DESC_ESTIP_=' ||  Vstr || '@';
    PCampo := PCampo || 'I_AGRAV_ESTIP_=0@';
    /*if V_DEstipulante = 0 then*/
       Vstr := LTrim(TO_CHAR(Abs(PCOD_REFERENCIA),'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_PE_DESC_AGRAV_COMERCIAL_=' || Vstr || '@';
    /*else
       PCampo := PCampo || 'I_PE_DESC_AGRAV_COMERCIAL_=0@';
    end if;*/
    /*if V_DEstipulante = 0 then */
       if PCOD_REFERENCIA > 0 then
          PCampo := PCampo || 'I_IN_DESC_AGRAV_COMERCIAL_=D@';
       else
          PCampo := PCampo || 'I_IN_DESC_AGRAV_COMERCIAL_=A@';
       end if;
    /*else
       PCampo := PCampo || 'I_IN_DESC_AGRAV_COMERCIAL_=A@';
    end if;*/
    Vstr := LTrim(TO_CHAR(PCOMISSAO,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_COMISS_COMISSAO_=' || Vstr || '@';
    PCampo_V := 'I_GRUPO_COBERTURA_=';
    v_TReg := 0;
    If PValorVeiculo > 0 then
       Vstr := LTrim(TO_CHAR(PValorVeiculo,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || to_char(V_CobTokio) || ';' || Vstr || ';0;0|';
       PCampo := PCampo || 'I_LMI_CASCO_=' || Vstr || '@';
       V_TReg := V_TReg + 1;
    end if;
    if PCOD_TABELA > 0 then
          Vstr := LTrim(TO_CHAR(PCOD_TABELA,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          PCampo_v := PCampo_v || '70' || ';' || Vstr || ';0;0|';
          V_TReg := V_TReg + 1;
    end if;
    If V_SomaAces > 0 then
       Vstr := LTrim(TO_CHAR(V_SomaAces,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '69' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
    end if;
    If V_SomaEquip > 0 then
       Vstr := LTrim(TO_CHAR(V_SomaEquip,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '71' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
    end if;
    If PNivelDm > 0 then
       Vstr := LTrim(TO_CHAR(PNivelDm,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '65' || ';' || Vstr || ';0;0|';
       PCampo := PCampo || 'I_LIM_RCF_DM_=' || Vstr || '@';
       V_TReg := V_TReg + 1;
    end if;
    If PNivelDp > 0 then
       Vstr := LTrim(TO_CHAR(PNivelDp,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '66' || ';' || Vstr || ';0;0|';
       PCampo := PCampo || 'I_LIM_RCF_DC_=' || Vstr || '@';
       V_TReg := V_TReg + 1;
    end if;
     If (V_Carac322 = 17473) then
         begin
         SELECT VALOR2 INTO V_MVALOR2 FROM VW_TABRG_P11_T6666 WHERE
             CHAVE1  = 1 AND CHAVE2 = 280;
         Exception
         When OTHERS then
         begin
            V_MValor2 := 0;
         end;
         end;
         Vstr := LTrim(TO_CHAR(V_MValor2,'000000000.00'));
         Vstr := translate(Vstr,'.',',');
         PCampo_v := PCampo_v || '280' || ';' || Vstr || ';0;0|';
         V_TReg := V_TReg + 1;
     end if;
    if PValorAppMorte > 0 then
       Vstr := LTrim(TO_CHAR(PValorAppMorte,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
         PCampo_v := PCampo_v || '67' || ';' || Vstr || ';0;0|';
         V_TReg := V_TReg + 1;
         PCampo_v := PCampo_v || '68' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
       PCampo := PCampo || 'I_LIM_APP_MORTE_=' || Vstr || '@';
       PCampo := PCampo || 'I_LIM_APP_INVAL_=' || Vstr || '@';
    end if;
    IF PValorAppDMH <> 0 then
       Vstr := LTrim(TO_CHAR(PValorAppDMH,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
         PCampo_v := PCampo_v || '246' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
       PCampo := PCampo || 'I_LIM_RCF_DMO_=' || Vstr || '@';
    end if;
    if V_IS_Dextr <> 0 then
       Vstr := LTrim(TO_CHAR(V_IS_Dextr,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '159' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
       PCampo := PCampo || 'I_LIM_DESP_EXTRASA_=' || Vstr || '@';
    end if;
    if V_Perda <> 0 then
       Vstr := LTrim(TO_CHAR(V_Perda,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '277' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
    end if;
    if V_MISRes > 0 then
       Vstr := LTrim(TO_CHAR(V_MISRes,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || '70' || ';' || Vstr || ';0;0|';
       V_TReg := V_TReg + 1;
    end if;
    Loop
       Exit When V_TReg = 30;
       PCampo_v := PCampo_v || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo_v := PCampo_v || '@ACTOCCURSI_GRUPO_COBERTURA=30@';
    PCampo := PCampo || PCampo_v;
    PCampo := PCampo || 'I_NO_PESO_VEICULO_=' || to_char(v_Peso) ||'@';
    PCampo := PCampo || 'I_NO_POTENCIA_VEICULO_=' || to_char(V_Potencia) || '@';
    PCampo := PCampo || 'I_TP_COMBUSTIVEL_=' || V_TP_Comb || '@';
    PCampo := PCampo || 'I_TP_VIDRO_=' || V_TP_Vidro || '@';
    PCampo := PCampo || 'I_CLUS_MOD_FREQROFU_=' || to_char(V_Frq_Roubo) || '@';
    PCampo := PCampo || 'I_CLUS_MOD_FREQCOL_=' || to_char(V_Frq_Colisao) || '@';
    PCampo := PCampo || 'I_CLUS_MOD_GDM_=' || to_char(V_Frq_Gdm) || '@';
    PCampo := PCampo || 'I_CD_TIPO_VEICULO_=' || to_char(V_Cd_Tipo) || '@';
    PCampo := PCampo || 'I_NO_CARGA_VEICULO_=' || to_Char(v_No_Carga) ||'@';
    PCampo := PCampo || 'I_COD_AG_CAPTADORA_=' || TO_CHAR(V_AGCapt) || '@';
    PCampo := PCampo || 'I_COD_AGRP_REG_=' || TO_CHAR(V_CaracRegTar) || '@';
    PCampo := PCampo || 'I_COD_CATEGORIA_=' || V_CategEstat || '@';

    if (PMODALIDADE = 'A')  then
        PCampo := PCampo || 'I_MOD_SEGURO_=3@';
    else
        PCampo := PCampo || 'I_MOD_SEGURO_=1@';
    end if;
    PCampo := PCampo || 'I_COD_COBERT_BAS_='|| TO_CHAR(V_CobTokio) || '@';
    PCampo := PCampo || 'I_CD_CAPITACAO_=0@';
    PCampo := PCampo || 'I_COD_CONGENERE_=0@';
    PCampo := PCampo || 'I_DT_NASCIMENTO_=0@';
    PCampo := PCampo || 'I_NO_CEP_CLI_=0@';

    if (PCRIVO = 'N') then
      PCampo := PCampo || 'I_NO_ITEM_=0@';
    end if;

    PCampo := PCampo || 'I_NO_ENDOSSO_=0@';
    PCampo := PCampo || 'I_CD_CLIENTE_=0@';
    PCampo := PCampo || 'I_PE_COMIS_REPASSE_=0@';
    PCampo := PCampo || 'I_TIPO_TABELA_='|| v_tipoTabela || '@';

    /*Novos campos*/
    if PItem = 0 then
      PCampo := PCampo || 'I_IN_FROTA_=N@';
    else
      PCampo := PCampo || 'I_IN_FROTA_=S@';
    end if;

    PCampo := PCampo || 'I_CD_QUESTIONARIO_='|| V_CODIGO_QUESTIONARIO || '@';

    SELECT VERSAO INTO V_VERSAO_QUESTIONARIO FROM MULT_PRODUTOSQBRGRUPOS
       WHERE PRODUTO = PPRODUTO AND VIGENCIA = PvarInt1 AND CODIGO = V_CODIGO_QUESTIONARIO;



    PCampo := PCampo || 'I_VERSAO_QUESTIONARIO_='|| V_VERSAO_QUESTIONARIO || '@';

    /*Dados do Condutor*/
    PCampo := PCampo || 'I_NO_CPF_COND_=0@';
    PCampo := PCampo || 'I_NO_CNH_COND_=0@';
    PCampo := PCampo || 'I_SEXO_COND_='|| PSEXOCONDU || '@';
    PCampo := PCampo || 'I_ESTADO_CIVIL_COND_='|| PESTCVCONDU || '@';
    if (PDTNASCONDU IS NOT NULL) then
      PCampo := PCampo || 'I_DT_NASC_COND_='|| TO_CHAR(PDTNASCONDU,'YYYYMMDD') || '@';
    else
      PCampo := PCampo || 'I_DT_NASC_COND_=@';
    end if;

    /*Tipo de Uso do Veiculo*/
    PCampo := PCampo || 'I_TP_USO_VEICULO_='|| PTIPOUSOVEIC || '@';

    --dbms_output.put_line( PCampo );

    open PRetorno for
        SELECT PCampo as conteudo from dual;



end;
end;
/


CREATE OR REPLACE PROCEDURE "GERA_STRING_AUTOPASSEIO" 
(
    PProduto IN Mult_Produtos.PRODUTO%TYPE,
    PvarInt1 IN Mult_Calculo.MVERSAO%TYPE,
    PCep IN Mult_Produtos.PRODUTO%TYPE,
    PMODELO IN Mult_Calculo.MODELO%TYPE,
    PFABRICANTE IN Mult_Calculo.FABRICANTE%TYPE,
    PTipo_Cobertura IN Mult_calculo.TIPO_COBERTURA%TYPE,
    PVALORBASE IN Mult_calculo.VALORBASE%TYPE,
    PTipo_Site IN Mult_calculo.PROCEDENCIA%TYPE,
    PANOMODELO IN Mult_calculo.ANOMODELO%TYPE,
    PPROCEDENCIA IN Mult_calculo.PROCEDENCIA%TYPE,
    PZERO IN Mult_calculo.ZEROKM%TYPE,
    PCOD_CIDADE  IN Mult_calculo.COD_CIDADE%TYPE,
    PCALCULOORIGEM IN Mult_calculo.CALCULOORIGEM%TYPE,
    PTIPOFROTA IN Mult_calculo.TIPOFROTA%TYPE,
    PCOD_TABELA IN Mult_calculo.COD_TABELA%TYPE,
    PVALORVEICULO IN Mult_calculo.VALORVEICULO%TYPE,
    PNIVELBONUSAUTO IN Mult_calculo.NIVELBONUSAUTO%TYPE,
    PMODALIDADE IN Mult_calculo.MODALIDADE%TYPE,
    PRetorno OUT TYPES.CURSOR_TYPE)
IS
BEGIN
  declare
    V_COD_REFERENCIA NUMBER(18);
    V_COD_REFERENCIA_INC NUMBER(18);
    V_COD_REFERENCIA_RINC NUMBER(18);
    V_FAMILIA NUMBER(18);
    V_CATEG_TAR1 NUMBER(18);
    V_CATEGORIA NUMBER(18);
    V_PROCEDENCIA VARCHAR(1);
    V_Refer NUMBER(18);
    V_Categ NUMBER(18);
    V_CategT NUMBER(18);
    V_DCategT VARCHAR(40);
    V_CaracRegTar NUMBER(18,6);
    V_VALOR_MEDIO number(16,6);
	V_valor_minimo number(16,6);
	V_VALOR_MEDIO_Ant number(16,6);
	V_valor_minimo_ant number(16,6);
    V_FAMILIAC NUMBER(18);
    V_Val_Med number(16,6);
    V_ValorMin number(16,6);
    V_Val_Blind NUMBER(18);
    V_M_Regiao NUMBER(18);
    V_Desc  VARCHAR(40);
    V_CodFami  VARCHAR(40);
    V_CategEstat VARCHAR(15);
    V_CategScore VARCHAR(15);
    PCampo VARCHAR(4000);
    Vstr VARCHAR(20);
     Cursor TCAMPOS Is
       Select VALOR_MEDIO, valor_minimo, VALOR_MEDIO_Ant, valor_minimo_ant, familia from Vw_ValorMercado1
       where Modelo = PMODELO and Tipo_tabela = 'F' and
        Combustivel = PPROCEDENCIA and Ano_Modelo = 9999;
     Cursor TCAMPON Is
       Select VALOR_MEDIO, valor_minimo, VALOR_MEDIO_Ant, valor_minimo_ant, familia from Vw_ValorMercado1
       where Modelo = PMODELO and Tipo_tabela = 'F' and
        Combustivel = PPROCEDENCIA and Ano_Modelo = PANOMODELO;
BEGIN
    begin
    if (PvarInt1 = 1) then
        select COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA INTO
               V_COD_REFERENCIA, V_COD_REFERENCIA_INC, V_COD_REFERENCIA_RINC, V_FAMILIA, V_CATEG_TAR1, V_CATEGORIA, V_PROCEDENCIA
        from VW_VEICULOMODELO2
        where MODELO = PMODELO;
    else
        select COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA INTO
               V_COD_REFERENCIA, V_COD_REFERENCIA_INC, V_COD_REFERENCIA_RINC, V_FAMILIA, V_CATEG_TAR1, V_CATEGORIA, V_PROCEDENCIA
        from VW_VEICULOMODELO3
        where MODELO = PMODELO;
    end if;
    Exception
      When OTHERS then
       begin
         V_COD_REFERENCIA := 0;
         V_COD_REFERENCIA_INC := 0;
         V_COD_REFERENCIA_RINC := 0;
         V_FAMILIA := 0;
         V_CATEG_TAR1 := 0;
         V_CATEGORIA := 0;
         V_PROCEDENCIA := '';
       end;
    end;
    if PTipo_Cobertura = 2 then
       V_Refer := V_COD_REFERENCIA_INC;
    else
       if PTipo_Cobertura = 4 then
          V_Refer := V_COD_REFERENCIA_RINC;
       else
          V_Refer := V_COD_REFERENCIA;
       end if;
    end if;
    if (PTipo_Site = 'K') Then
       V_Categ := V_CATEG_TAR1;
    else
       V_Categ := PVALORBASE;
    end if;
    V_CodFami := '';
    if V_Familia = 1 then
       V_CodFami := 'DEMAI';
    end if;
    if V_Familia = 2 then
       V_CodFami := 'BLIND';
    end if;
    if V_Familia = 3 then
       V_CodFami := 'CARGA';
    end if;
    if V_Familia = 4 then
       V_CodFami := 'IMPOR';
    end if;
    if V_Familia = 5 then
       V_CodFami := 'POP';
    end if;
    if V_Familia = 6 then
       V_CodFami := 'DEMSV';
    end if;
    if V_Familia = 7 then
       V_CodFami := 'DEMVB';
    end if;
    if V_Familia = 8 then
       V_CodFami := 'IMPSV';
    end if;
    if V_Familia = 10 then
       V_CodFami := 'AAT';
    end if;
    if V_Familia = 11 then
       V_CodFami := 'ATT';
    end if;
    if V_Familia = 12 then
       V_CodFami := 'IACD';
    end if;
    if V_Familia = 13 then
       V_CodFami := 'IBC';
    end if;
    begin
    select Valor,Texto into V_CategT, V_DCategT from VW_TABRG_P10_T24
    where chave1 = V_Categ and rownum = 1;
    Select d1.VALOR4, d1.Chave1 into V_CaracRegTar, V_M_Regiao
    from VW_TABRG_P10_T50 d, VW_TABRG_P10_T25 d1
    where d.chave1  = PVarint1
          and   d.chave2 <= PCep
          and   d.chave3 >= PCep
          and   d1.valor5 = d.valor
          and   rownum = 1
          order by d.chave3 desc;
    Exception
      When OTHERS then
       begin
       V_CategT := 0;
       V_DCategT := '';
       V_CaracRegTar := 0;
       V_M_Regiao := 0;
       end;
    end;
    V_VALOR_MEDIO := 0;
    V_valor_minimo := 0;
    V_valor_medio_ant := 0;
    V_valor_minimo_ant := 0;
    V_FamiliaC := 0;
    IF PPRODUTO = 10 Then
      IF (PZERO = 'S') then
         Open TCAMPOS;
         Fetch TCAMPOS Into V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant, V_FamiliaC;
         Close TCAMPOS;
   	  else
         Open TCAMPON;
         Fetch TCAMPON Into V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant, V_FamiliaC;
         Close TCAMPON;
      end if;
      if (V_VALOR_MEDIO = 0 and V_valor_minimo = 0 and V_VALOR_MEDIO_Ant = 0 and V_valor_minimo_ant = 0) then
       IF (PZERO = 'S') then
          begin
            Select VALOR_MEDIO, valor_minimo, VALOR_MEDIO_Ant, valor_minimo_ant, familia
            into   V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant, V_familiac
            from Vw_ValorMercado1
            where Modelo = PMODELO and Tipo_tabela = 'R' and
                Combustivel = PPROCEDENCIA and Ano_Modelo = 9999
                and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       else
          begin
            Select VALOR_MEDIO, valor_minimo, VALOR_MEDIO_Ant, valor_minimo_ant, familia
            into   V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant, V_familiac
            from Vw_ValorMercado1
            where Modelo = PMODELO and Tipo_tabela = 'R' and
                Combustivel = PPROCEDENCIA and Ano_Modelo = PANOMODELO
                and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       end if;
      end if;
    else
       IF (PZERO = 'S') then
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
              d1.familia into
              V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
              V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       else
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
                 d1.familia
          into
                 V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
                 V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       end if;
    end if;
    V_Val_Med := 0;
    V_ValorMin := 0;
    if (PvarInt1 = 2) then
       V_Val_Med := V_Valor_Medio_ant;
        if V_valor_minimo_Ant > 0 then
           V_ValorMin := V_valor_minimo_ant;
        else
           V_ValorMin := V_valor_medio_ant;
        end if;
    else
        V_Val_Med := V_Valor_Medio;
        if V_valor_minimo > 0 then
           V_ValorMin := V_valor_minimo;
        else
           V_ValorMin := V_valor_medio;
        end if;
    end if;
    V_Val_Blind := 1;
    V_M_Regiao := 0;
    if V_M_Regiao = 0 then
       V_M_Regiao := PCOD_CIDADE;
    end if;
    if V_familiaC = 2 then
        begin
        select Valor2 into V_Val_Blind from VW_TABRG_P10_T25 where chave1 = V_M_Regiao and chave2 = 2 and rownum = 1;
        Exception
          When OTHERS then
          begin
             V_Val_Blind := 0;
          end;
        end;
        if V_Val_Blind <> 0 then
           V_Val_Blind := V_Val_Blind / 100;
           V_ValorMin := V_ValorMin * V_Val_Blind;
        end if;
    end if;
    if (V_Val_Med = 0) and (PCALCULOORIGEM > 0) and (PTIPOFROTA = 'D') and (V_ValorMin > 0) then
        V_Val_Med := V_ValorMin;
    end if;
    /*  Busca descriÁ„o das categorias tarifarias*/
    begin
    SELECT DISTINCT DESCR_CATEG_ESTAT, DESCR_CATEG_SCORE into V_CategEstat, V_CategScore  FROM MULT_PRODUTOSQBRVEICULOS
    WHERE PRODUTO = PProduto AND
          VIGENCIA = PvarInt1 AND
          MODELO =  PMODELO;
    Exception
      When OTHERS then
       begin
       V_CategEstat := 0;
       V_CategScore := 0;
       end;
    end;
    PCampo := '';
    if (PTipo_Site = 'K') Then
       PCampo := PCampo || 'I_IND_ROTINA_=I@';
    else
       PCampo := PCampo || 'I_IND_ROTINA_=K@';
    end if;
    if PCOD_TABELA = 1 then
       PCampo := PCampo || 'I_COD_TAB_ACEITE_=4@';
    else
       PCampo := PCampo || 'I_COD_TAB_ACEITE_=2@';
    end if;
    PCampo := PCampo || 'I_COD_AGRP_VEIC_=' || TO_CHAR(V_Refer) || '@';
    PCampo := PCampo || 'I_COD_AGRP_REG_=' || TO_CHAR(V_CaracRegTar) || '@'  ;
    PCampo := PCampo || 'I_COD_FAMILIA_=' || V_CodFami || '@'                        ;
    Vstr := LTrim(TO_CHAR(V_Val_Med,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VAL_COT_TAB_=' || Vstr || '@'   ;
    Vstr := LTrim(TO_CHAR(PVALORVEICULO,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VAL_COT_REG_=' ||  Vstr || '@'  ;
    PCampo := PCampo || 'I_ANO_MODELO_='  ||  TO_CHAR(PANOMODELO) || '@'  ;
    PCampo := PCampo || 'I_DESC_CATEGORIA_=' || TO_CHAR(v_CategT) || '@'           ;
    PCampo := PCampo || 'I_NO_CEP_=' || LTrim(TO_CHAR(PCep,'00000000')) || '@'               ;
    PCampo := PCampo || 'I_IND_0KM_=' || PZERO || '@';
    PCampo := PCampo || 'I_CI_BONUS_=' ||  TO_CHAR(PNIVELBONUSAUTO) || '@';
    PCampo := PCampo || 'I_COD_CATEGORIA_=' || V_CategEstat || '@';
    if (PMODALIDADE = 'A') OR (PMODALIDADE = '') then
       PCampo := PCampo || 'I_COD_MOD_SEGURO_=3@';
    else
       PCampo := PCampo || 'I_COD_MOD_SEGURO_=1@';
    end if;
    if PProduto = 10 then
       PCampo := PCampo || 'I_COD_MOD_PRODUTO_=7@';
    else
       PCampo := PCampo || 'I_COD_MOD_PRODUTO_=9@';
    end if;
    open PRetorno for
         SELECT PCampo as conteudo from dual;
end;
end;
/


CREATE OR REPLACE PROCEDURE "GERA_STRING_AUTOPASSEIO_KIT" 
(
    PCalculo IN KIT_Calculo.CALCULO%TYPE,
    PiTEM IN KIT_Calculo.CALCULO%TYPE,
    PProduto IN Mult_Produtos.PRODUTO%TYPE,
    PvarInt1 IN Mult_Produtos.PRODUTO%TYPE,
    PCep IN Mult_Produtos.PRODUTO%TYPE,
    PMODELO IN KIT_Calculo.MODELO%TYPE,
    PFABRICANTE IN KIT_Calculo.FABRICANTE%TYPE,
    PTipo_Cobertura IN KIT_Calculo.TIPO_COBERTURA%TYPE,
    PTipo_Franquia IN KIT_Calculo.TIPO_FRANQUIA%TYPE,
    PVALORBASE IN KIT_Calculo.VALORBASE%TYPE,
    PTipo_Site IN KIT_Calculo.PROCEDENCIA%TYPE,
    PANOMODELO IN KIT_Calculo.ANOMODELO%TYPE,
    PANOFABRICACAO  IN KIT_Calculo.ANOFABRICACAO%TYPE,
    PPROCEDENCIA IN KIT_Calculo.PROCEDENCIA%TYPE,
    PZERO IN KIT_Calculo.ZEROKM%TYPE,
    PCOD_CIDADE  IN KIT_Calculo.COD_CIDADE%TYPE,
    PCALCULOORIGEM IN Mult_Produtos.PRODUTO%TYPE,
    PTIPOFROTA IN KIT_Calculo.ZEROKM%TYPE,
    PCOD_TABELA IN KIT_Calculo.COD_TABELA%TYPE,
    PVALORVEICULO IN KIT_Calculo.VALORVEICULO%TYPE,
    PNIVELBONUSAUTO IN KIT_Calculo.NIVELBONUSAUTO%TYPE,
    PMODALIDADE IN KIT_Calculo.MODALIDADE%TYPE,
    PSUBSCRICAO IN KIT_Calculo.ZEROKM%TYPE,
    PTAXA IN KIT_Calculo.TAXA%TYPE,
    PVLRFRANQUIASUB IN KIT_Calculo.TAXA%TYPE,
    PTAXAFRANQUIASUB IN KIT_Calculo.TAXA%TYPE,
    PVMINFRANQUIASUB IN KIT_Calculo.TAXA%TYPE,
    PINICIOVIGENCIA IN KIT_Calculo.INICIOVIGENCIA%TYPE,
    PFINALVIGENCIA IN KIT_Calculo.FINALVIGENCIA%TYPE,
    PCOMISSAO IN KIT_Calculo.COMISSAO%TYPE,
    PNIVELDM IN KIT_Calculo.NIVELDM%TYPE,
    PNIVELDP IN KIT_Calculo.NIVELDP%TYPE,
    PVALORAPPDMH IN KIT_Calculo.VALORAPPDMH%TYPE,
    PVALORAPPMORTE IN KIT_Calculo.VALORAPPMORTE%TYPE,
    PVALORAPPINV IN KIT_Calculo.VALORAPPMORTE%TYPE,
    PLMI_BLINDAGEM IN KIT_Calculo.LMI_BLINDAGEM%TYPE,
    PLMI_KITGAS IN KIT_Calculo.LMI_KITGAS%TYPE,
    PAJUSTE IN KIT_Calculo.AJUSTE%TYPE,
    PESTADO in KIT_Calculo.ESTADO%TYPE,
    PTIPO_PESSOA  in KIT_Calculo.TIPO_PESSOA%TYPE,
    PDIAS IN KIT_Calculo.AJUSTE%TYPE,
    PORIGEM_DESC_SCORE  IN KIT_Calculo.TIPO_PESSOA%TYPE,
    PTIPO_DESC_SCORE  IN KIT_Calculo.TIPO_PESSOA%TYPE,
    PDESC_SCORE  IN  KIT_Calculo.AJUSTE%TYPE,
    PSENHA_RENOV  IN KIT_Calculo.TIPO_PESSOA%TYPE,
    PITEM_SUBST  IN  KIT_Calculo.AJUSTE%TYPE,
    PCOD_REFERENCIA  IN KIT_Calculo.AJUSTE%TYPE,
    PBLINDAGEM  IN KIT_Calculo.BLINDAGEM%TYPE,
    PTIPOUSOVEIC IN KIT_Calculo.TIPOUSOVEIC%TYPE,
    PSEXOCONDU IN KIT_Calculo.SEXOCONDU%TYPE,
    PESTCVCONDU IN KIT_Calculo.ESTCVCONDU%TYPE,
    PDTNASCONDU IN KIT_Calculo.DTNASCONDU%TYPE,
    PRetorno OUT TYPES.CURSOR_TYPE)
IS
BEGIN
  declare
    V_TAXA_CASCO REAL_TAXASAUTO.TAXA_CASCO%TYPE;
    V_TAXA_INC REAL_TAXASAUTO.TAXA_INC%TYPE;
    V_TAXA_RINC REAL_TAXASAUTO.TAXA_RINC%TYPE;
    V_FRANQUIA REAL_TAXASAUTO.FRANQUIA%TYPE;
    V_TAXA_FRANQ REAL_TAXASAUTO.TAXA_FRANQ%TYPE;
    V_FRQ_MINIMA REAL_TAXASAUTO.FRQ_MINIMA%TYPE;
    V_TAXA_CASCO_ANT REAL_TAXASAUTO.TAXA_CASCO_ANT%TYPE;
    V_TAXA_INC_ANT REAL_TAXASAUTO.TAXA_INC_ANT%TYPE;
    V_TAXA_RINC_ANT REAL_TAXASAUTO.TAXA_RINC_ANT%TYPE;
    V_FRANQUIA_ANT REAL_TAXASAUTO.FRANQUIA_ANT%TYPE;
    V_TAXA_FRANQ_ANT REAL_TAXASAUTO.TAXA_FRANQ_ANT%TYPE;
    V_FRQ_MINIMA_ANT REAL_TAXASAUTO.FRQ_MINIMA_ANT%TYPE;
    V_SUBSCRICAO REAL_TAXASAUTO.SUBSCRICAO%TYPE;
    V_SUBSCRICAO_ANT REAL_TAXASAUTO.SUBSCRICAO_ANT%TYPE;
    V_RESPOSTA KIT_CalculoQBR.RESPOSTA%TYPE;
    V_DESCRICAORESPOSTA2 KIT_CalculoQBR.DESCRICAORESPOSTA2%TYPE;
    V_SUBRESPOSTA KIT_CalculoQBR.SUBRESPOSTA%TYPE;
    V_SUBRESPOSTA2 KIT_CalculoQBR.SUBRESPOSTA2%TYPE;
    V_AgrupamentoRegiaoQbr KIT_CalculoQBR.AgrupamentoRegiaoQbr%TYPE;
    V_PDESC_SCORE NUMBER(18,6);
    V_COD_REFERENCIA NUMBER(18);
    V_COD_REFERENCIA_INC NUMBER(18);
    V_COD_REFERENCIA_RINC NUMBER(18);
    V_FAMILIA NUMBER(18);
    V_CATEG_TAR1 NUMBER(18);
    V_CATEGORIA NUMBER(18);
    V_PROCEDENCIA VARCHAR(1);
    V_Refer NUMBER(18);
    V_Categ NUMBER(18);
    V_CategT NUMBER(18);
    V_DCategT VARCHAR(40);
    V_CaracRegTar NUMBER(18,6);
    V_VALOR_MEDIO number(16,6);
	V_valor_minimo number(16,6);
	V_VALOR_MEDIO_Ant number(16,6);
	V_valor_minimo_ant number(16,6);
	V_PBONUSCASCO number(6,2);
    V_FAMILIAC NUMBER(18);
    V_Val_Med number(16,6);
    V_ValorMin number(16,6);
    V_Val_Blind NUMBER(18);
    V_M_Regiao NUMBER(18);
    V_Desc  VARCHAR(40);
    V_CodFami  VARCHAR(40);
    V_CategEstat VARCHAR(15);
    V_CategScore VARCHAR(15);
    V_PTIPO_FRANQUIA KIT_Calculo.TIPO_FRANQUIA%TYPE;
    V_TEXTO Mult_PRODUTOSTABRG.TEXTO%TYPE;
    PCampo VARCHAR(4000);
    PCampo_v VARCHAR(1000);
    Vstr VARCHAR(20);
    V_CodCorr Number(10);
    V_AGCapt Number(4);
    V_Str Varchar(20);
    V_LOTACAO Number(2);
    V_DESPESAS NUMBER(2);
    V_IS_DEXTR number(16,6);
    V_MVALOR1 FLOAT;
    V_OPCAO number(10);
    V_CARAC049 number(10);
    V_MISRes number(10);
    V_SubTxCasco varchar2(20);
    V_Taxa_at number(10,6);
    V_Tx_Fran number(10,6);
    V_Franquia_ number(16,6);
    V_FranqMin number(16,6);
    V_Qtd_Frq1 number(10,6);
    V_MVALOR2 FLOAT;
    V_MVALOR3 number(16,6);
    v_DEstipulante number(10);
    v_MEstipulante number(10);
    v_MProLabore number(10);
    V_TIPO_NEGOCIO VARCHAR(20);
    V_Ajuste number(16,6);
    V_SomaAces number(16,6);
    V_Aces number(16,6);
    V_TREG number(2);
    V_ACESSORIO number(6);
    V_VALOR number(16,6);
    v_questao number(10);
    v_resposta2 number(10);
    V_DescPromo number(16,6);
    V_TipoDescPromo Varchar(2);
    V_CODCOMODATO varchar(30);
    V_CobTokio number(3);
    V_PercCascoA number(6,2);
    V_PercCascoD number(6,2);
    V_PercRCFDMA number(6,2);
    V_PercRCFDMD number(6,2);
    V_PercA number(6,2);
    V_PercD number(6,2);
    V_DescMod number(6,2);
    V_VigTabela number(6);
    V_QTREN number(6);
    V_ZEROKMPROMO number(1);
    V_CobTaxa number(2);
    V_SomaEquip number(16,6);
    V_peso TABELA_VEICULOMODELO.NO_PESO_VEICULO%TYPE;
    V_Potencia TABELA_VEICULOMODELO.NO_POTENCIA_VEICULO%TYPE;
    V_TP_Comb Varchar(2);
    V_TP_Vidro Varchar(2);
    V_Frq_Roubo TABELA_VEICULOMODELO.VL_FRQ_ROUBO_FURTO%TYPE;
    V_Frq_Colisao TABELA_VEICULOMODELO.VL_FRQ_COLISAO%TYPE;
    V_Frq_Gdm TABELA_VEICULOMODELO.VL_FRQ_GDM%TYPE;
    V_Cd_Tipo TABELA_VEICULOMODELO.CD_TIPO_VEICULO%TYPE;
    V_No_Carga TABELA_VEICULOMODELO.NO_CARGA_VEICULO%TYPE;
    V_TpAss24h NUMBER(10);
    V_VlrAss24h NUMBER(10,2);
    v_tipoTabela VARCHAR(1);
    V_VIGENCIA SMALLINT;
    V_CODIGO_QUESTIONARIO VARCHAR(5);
    V_VERSAO_QUESTIONARIO NUMBER(6);


    Cursor TCAMPOS Is
       SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant
       FROM real_COTASAUTO D, TABELA_VEICULOMODELO D1
       WHERE D1.MODELO     = PMODELO
       AND D.COD_MODELO  = D1.MODELO
       AND D.TIPO_TABELA = 'F'
       AND D.ANO_MODELO = 9999
       AND D.COMBUSTIVEL = PPROCEDENCIA;
    Cursor TCAMPON Is
       SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant
       FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
       WHERE D1.MODELO     = PMODELO
       AND D.COD_MODELO  = D1.MODELO
       AND D.TIPO_TABELA = 'F'
       AND D.ANO_MODELO = PANOMODELO
       AND D.COMBUSTIVEL = PPROCEDENCIA;
    Cursor TACES Is
       SELECT ACESSORIO,VALOR FROM KIT_CALCULOACES
       WHERE CALCULO = PCALCULO
       AND VALOR   > 0 and (SUBTIPO = 2 OR PPRODUTO = 10);
    Cursor TEQP Is
       SELECT ACESSORIO,VALOR FROM KIT_CALCULOACES
       WHERE CALCULO = PCALCULO
       AND VALOR   > 0 and (SUBTIPO = 1 AND PPRODUTO = 11);
    Cursor TQBR1 is
       Select questao, resposta, subresposta, AgrupamentoRegiaoQbr, RESPOSTA2, GRUPO  from KIT_CalculoQbr
       where calculo = PCALCULO
       and valida = 'S';
BEGIN
/*  Busca codigo do corretor*/
    V_CodCorr := 0;
    V_Str := '0000';
/*  Busca codigo da Agencia Captadora*/
    V_AGCapt := 0;
/*  Obtem dados do Veiculo*/
    if (PvarInt1 = 1) then
       SELECT COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA, NUMPASSAGEIROS,
              NO_PESO_VEICULO, NO_POTENCIA_VEICULO, TIPO_COMBUSTIVEL, TP_VIDRO, VL_FRQ_ROUBO_FURTO, VL_FRQ_COLISAO, VL_FRQ_GDM, CD_TIPO_VEICULO, NO_CARGA_VEICULO into
              V_COD_REFERENCIA, V_COD_REFERENCIA_INC, V_COD_REFERENCIA_RINC, V_FAMILIA, V_CATEG_TAR1, V_CATEGORIA, V_PROCEDENCIA, V_LOTACAO,
              V_peso, V_Potencia , V_TP_Comb , V_TP_Vidro , V_Frq_Roubo , V_Frq_Colisao, V_Frq_Gdm , V_Cd_Tipo , V_No_Carga
       FROM
              TABELA_VEICULOMODELO WHERE MODELO = PMODELO;
    else
       SELECT COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA, NUMPASSAGEIROS,
              NO_PESO_VEICULO, NO_POTENCIA_VEICULO, TIPO_COMBUSTIVEL, TP_VIDRO, VL_FRQ_ROUBO_FURTO, VL_FRQ_COLISAO, VL_FRQ_GDM, CD_TIPO_VEICULO, NO_CARGA_VEICULO into
              V_COD_REFERENCIA, V_COD_REFERENCIA_INC, V_COD_REFERENCIA_RINC, V_FAMILIA, V_CATEG_TAR1, V_CATEGORIA, V_PROCEDENCIA, V_LOTACAO,
              V_peso, V_Potencia , V_TP_Comb , V_TP_Vidro , V_Frq_Roubo , V_Frq_Colisao, V_Frq_Gdm , V_Cd_Tipo , V_No_Carga
       FROM
              TABELA_VEICULOMODELO_ANT WHERE MODELO = PMODELO;
    end if;
    if PPRODUTO = 11 then
        SELECT CHAVE4 AS NO_PESO_VEICULO, CHAVE5 AS NO_POTENCIA_VEICULO, TEXTO AS TIPO_COMBUSTIVEL,
           TEXTO AS TP_VIDRO, VALOR AS VL_FRQ_ROUBO_FURTO, VALOR2 AS VL_FRQ_COLISAO,
           VALOR3 AS VL_FRQ_GDM, VALOR4 AS CD_TIPO_VEICULO, VALOR5 AS NO_CARGA_VEICULO INTO
           V_peso, V_Potencia, V_TP_Comb, V_TP_Vidro, V_Frq_Roubo, V_Frq_Colisao, V_Frq_Gdm , V_Cd_Tipo, V_No_Carga
           FROM VW_TABRG_P11_T8888 WHERE CHAVE1 = PvarInt1
             AND CHAVE2 =PMODELO
             AND CHAVE3 =PFABRICANTE;
      V_TP_Comb := Trim(Substr(V_TP_Comb,1,1));
      V_TP_Vidro := Trim(Substr(V_TP_Vidro,2,1));
    end if;

    if PTipo_Cobertura = 2 then
       V_Refer := V_COD_REFERENCIA_INC;
    else
       if PTipo_Cobertura = 4 then
          V_Refer := V_COD_REFERENCIA_RINC;
       else
          V_Refer := V_COD_REFERENCIA;
       end if;
    end if;
    if (PTipo_Site = 'K') Then
       V_Categ := V_CATEG_TAR1;
    else
       V_Categ := PVALORBASE;
    end if;
    V_CodFami := '';
    if V_Familia = 1 then
       V_CodFami := 'DEMAI';
    end if;
    if V_Familia = 2 then
       V_CodFami := 'BLIND';
    end if;
    if V_Familia = 3 then
       V_CodFami := 'CARGA';
    end if;
    if V_Familia = 4 then
       V_CodFami := 'IMPOR';
    end if;
    if V_Familia = 5 then
       V_CodFami := 'POP';
    end if;
    if V_Familia = 6 then
       V_CodFami := 'DEMSV';
    end if;
    if V_Familia = 7 then
       V_CodFami := 'DEMVB';
    end if;
    if V_Familia = 8 then
       V_CodFami := 'IMPSV';
    end if;
    if V_Familia = 10 then
       V_CodFami := 'AAT';
    end if;
    if V_Familia = 11 then
       V_CodFami := 'ATT';
    end if;
    if V_Familia = 12 then
       V_CodFami := 'IACD';
    end if;
    if V_Familia = 13 then
       V_CodFami := 'IBC';
    end if;
    select Valor,Texto into V_CategT, V_DCategT from Mult_produtostabrg where produto = PPRODUTO and tabela = 24 and chave1 = V_Categ and   rownum = 1 ;
/*  Busca regi„o tarifaria*/
    V_M_Regiao := 0;
    V_CaracRegTar := 0;
    Select d1.VALOR4, d1.Chave1 into V_CaracRegTar, V_M_Regiao
    from mult_produtostabrg d, mult_produtostabrg d1
    where d.Produto = Pproduto
          and   d.tabela  = 50
          and   d.chave1  = PVarint1
          and   d.chave2 <= PCep
          and   d.chave3 >= PCep
          and   d1.produto = d.Produto and d1.tabela = 25 and d1.valor5 = d.valor
          and   rownum = 1
          order by d.chave3 desc;
    if V_M_Regiao = 0 then
       V_M_Regiao := PCOD_CIDADE;
    end if;
/*  Busca cotaÁ„o do Veiculo*/
    V_VALOR_MEDIO := 0;
    V_valor_minimo := 0;
    V_valor_medio_ant := 0;
    V_valor_minimo_ant := 0;
    V_FamiliaC := 0;
    IF PPRODUTO = 10 Then
    IF (PZERO = 'S') then
       Open TCAMPOS;
       Fetch TCAMPOS Into V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant;
       Close TCAMPOS;
	else
       Open TCAMPON;
       Fetch TCAMPON Into V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant;
       Close TCAMPON;
    end if;
    if (V_VALOR_MEDIO = 0 and V_valor_minimo = 0 and V_VALOR_MEDIO_Ant = 0 and V_valor_minimo_ant = 0) then
       IF (PZERO = 'S') then
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
              d1.familia into
              V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
              V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       else
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
                 d1.familia
          into
                 V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
                 V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       end if;
       v_tipoTabela := 'R';
	else
      IF (PZERO = 'S') Then
       begin
       SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
              d1.familia into
              V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
              V_familiac
       FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
       WHERE D1.MODELO     = PMODELO
             AND D.COD_MODELO  = D1.MODELO
             AND D.TIPO_TABELA = 'F'
             AND D.ANO_MODELO = 9999
             AND D.COMBUSTIVEL = PPROCEDENCIA
             and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
    else
       begin
       SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
              d1.familia into
              V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
              V_familiac
       FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
       WHERE D1.MODELO     = PMODELO
            AND D.COD_MODELO  = D1.MODELO
            AND D.TIPO_TABELA = 'F'
            AND D.ANO_MODELO = PANOMODELO
            AND D.COMBUSTIVEL = PPROCEDENCIA
            and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
      end if;
       v_tipoTabela := 'F';
    end if;
    else
       v_tipoTabela := 'R';
       IF (PZERO = 'S') then
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
              d1.familia into
              V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
              V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       else
          begin
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
                 d1.familia
          into
                 V_VALOR_MEDIO, V_valor_minimo, V_VALOR_MEDIO_Ant, V_valor_minimo_ant,
                 V_familiac
          FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA
          and rownum = 1;
          Exception
            When OTHERS then
            begin
               V_VALOR_MEDIO := 0;
            end;
          end;
       end if;
    end if;
    V_Val_Med := 0;
    V_ValorMin := 0;
    if (PvarInt1 = 2) then
       V_Val_Med := V_Valor_Medio_ant;
        if V_valor_minimo_Ant > 0 then
           V_ValorMin := V_valor_minimo_ant;
        else
           V_ValorMin := V_valor_medio_ant;
        end if;
    else
        V_Val_Med := V_Valor_Medio;
        if V_valor_minimo > 0 then
           V_ValorMin := V_valor_minimo;
        else
           V_ValorMin := V_valor_medio;
        end if;
    end if;
    V_Val_Blind := 1;
    if V_familiaC = 2 then
        select Valor2 into V_Val_Blind from mult_produtostabrg where produto = PPRODUTO and tabela = 25 and chave1 = V_M_Regiao and chave2 = 2 and rownum = 1;
        if V_Val_Blind <> 0 then
           V_Val_Blind := V_Val_Blind / 100;
           V_ValorMin := V_ValorMin * V_Val_Blind;
        end if;
    end if;
    if (V_Val_Med = 0) and (PCALCULOORIGEM > 0) and (PTIPOFROTA = 'D') and (V_ValorMin > 0) then
        V_Val_Med := V_ValorMin;
    end if;
/*  Busca descriÁ„o das categorias tarifarias*/
    SELECT DISTINCT DESCR_CATEG_ESTAT, DESCR_CATEG_SCORE into V_CategEstat, V_CategScore  FROM MULT_PRODUTOSQBRVEICULOS
    WHERE PRODUTO = PPRODUTO AND
          VIGENCIA = PvarInt1 AND
          MODELO =  PMODELO;

/*  Busca coberura de despesas extras*/
    SELECT OPCAODESPESAS INTO V_DESPESAS FROM KIT_CALCULO
      WHERE CALCULO = PCALCULO;
    if V_DESPESAS = 2 then
      V_IS_DEXTR := PVALORVEICULO * 0.1;
      SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
           WHERE PRODUTO = pproduto AND TABELA = 1 AND CHAVE1 = 2;
      if V_IS_DEXTR > V_MVALOR1 then
         V_IS_DEXTR := V_MVALOR1;
      end if;
    end if;
/*  Busca coberura de vidros*/
    V_CARAC049 := 0;
    IF PPRODUTO = 10 Then
       SELECT OPCAOVIDROS INTO V_OPCAO FROM KIT_CALCULO
         WHERE CALCULO = PCALCULO;
       if V_OPCAO = 1 then
         V_CARAC049 := 12385;
       end if;
       if V_OPCAO = 2 then
         V_CARAC049 := 12384;
       end if;
       if V_OPCAO = 3 then
         V_CARAC049 := 12383;
       end if;
    end if;
/*  Busca coberura de carro reserva*/
    V_MISRes := 0;
    if pproduto = 10 then
       SELECT OPCAOCARRORESERVA INTO V_OPCAO FROM KIT_CALCULO
         WHERE CALCULO = PCALCULO;
       if V_OPCAO = 2 then
         V_MISRes := 1000;
       end if;
       if V_OPCAO = 3 then
         V_MISRes := 2000;
       end if;
    end if;
/*  Busca taxa de casco*/
    if PProduto = 10 then
       V_CobTaxa := 17;
    else
       V_CobTaxa := 63;
    end if;
    V_SubTxCasco := '';
    V_Taxa_at := 0;
    if PSUBSCRICAO = 'S' then
       V_Taxa_at := PTAXA;
    else
       SELECT TAXA_CASCO, TAXA_INC, TAXA_RINC, FRANQUIA, TAXA_FRANQ, FRQ_MINIMA, TAXA_CASCO_ANT, TAXA_INC_ANT, TAXA_RINC_ANT, FRANQUIA_ANT, TAXA_FRANQ_ANT, FRQ_MINIMA_ANT, SUBSCRICAO, SUBSCRICAO_ANT
         INTO V_TAXA_CASCO, V_TAXA_INC, V_TAXA_RINC, V_FRANQUIA, V_TAXA_FRANQ, V_FRQ_MINIMA, V_TAXA_CASCO_ANT, V_TAXA_INC_ANT, V_TAXA_RINC_ANT, V_FRANQUIA_ANT, V_TAXA_FRANQ_ANT, V_FRQ_MINIMA_ANT, V_SUBSCRICAO, V_SUBSCRICAO_ANT
         FROM REAL_TAXASAUTO
         WHERE COD_MODELO = V_Refer
           AND ANO_MODELO = PANOMODELO
           AND ZERO_KM    = PZERO
           AND COD_COB    = V_CobTaxa
           AND COD_REGIAO = V_M_Regiao;
       if PVALORVEICULO > 0 then
          if (PvarInt1 = 2) then
             V_SubTxCasco := V_SUBSCRICAO_ANT;
             if PITEM > 0 then
                if PTIPO_COBERTURA = 1 then
                   V_Taxa_at := V_TAXA_CASCO_ANT;
                else
                if PTIPO_COBERTURA = 2 then
                   V_Taxa_at := V_TAXA_INC_ANT;
                else
                   V_Taxa_at := V_TAXA_RINC_ANT;
                end if;
                end if;
            else
                if V_SUBSCRICAO_ANT is Null then
                   if PTIPO_COBERTURA = 1 then
                      V_Taxa_at := V_TAXA_CASCO_ANT;
                   else
                   if PTIPO_COBERTURA = 2 then
                      V_Taxa_at := V_TAXA_INC_ANT;
                   else
                      V_Taxa_at := V_TAXA_RINC_ANT;
                   end if;
                   end if;
                else
                   V_Taxa_at := 0;
                end if;
            end if;
          else
            V_SubTxCasco := V_SUBSCRICAO;
            if PITEM > 0 then
               if PTIPO_COBERTURA = 1 then
                  V_Taxa_at := V_TAXA_CASCO;
               else
               if PTIPO_COBERTURA = 2 then
                  V_Taxa_at := V_TAXA_INC;
               else
                  V_Taxa_at := V_TAXA_RINC;
               end if;
               end if;
            else
               if V_SUBSCRICAO is null then
                  if PTIPO_COBERTURA = 1 then
                     V_Taxa_at := V_TAXA_CASCO;
                  else
                  if PTIPO_COBERTURA = 2 then
                     V_Taxa_at := V_TAXA_INC;
                  else
                     V_Taxa_at := V_TAXA_RINC;
                  end if;
                  end if;
               else
                  V_Taxa_at := 0;
               end if;
            end if;
          end if;
      end if;
      if (PTIPO_COBERTURA = 3) and (PCalculoOrigem <> 0) then
          V_Taxa_at := 0;
      end if;
    end if;
/*  Busca valores de franquia*/
    V_Tx_Fran := 0;
    V_Franquia_ := 0;
    V_FranqMin := 0;
    if PSUBSCRICAO = 'S' then
       V_Franquia_ := PVLRFRANQUIASUB;
       if PTAXAFRANQUIASUB > 0 then
          V_Tx_Fran  := PTAXAFRANQUIASUB;
          V_Franquia_ := PVALORVEICULO * (V_Tx_fran / 100);
       end if;
       V_FranqMin := PVMINFRANQUIASUB;
       if V_Franquia_ < V_FranqMin then
          V_Franquia_ := V_FranqMin;
       end if;
    else
      if (PvarInt1 = 2) then
         V_Franquia_ := V_FRANQUIA_ANT;
         if V_Franquia_ = 0 then
            V_Tx_Fran  := V_TAXA_FRANQ_ANT;
            V_Franquia_ := PVALORVEICULO * (V_Tx_fran / 100);
         end if;
         V_FranqMin := V_FRQ_MINIMA_ANT;
         if V_Franquia_ <  V_FranqMin then
            V_Franquia_ := V_FranqMin;
         end if;
      else
         V_Franquia_ := V_FRANQUIA;
         if V_Franquia_ = 0 then
            V_Tx_Fran  := V_TAXA_FRANQ;
            V_Franquia_ := PVALORVEICULO * (V_Tx_fran / 100);
         end if;
         V_FranqMin := V_FRQ_MINIMA;
         if V_Franquia_ <  V_FranqMin then
            V_Franquia_ := V_FranqMin;
         end if;
      end if;
    end if;
    SELECT VALOR, VALOR3 INTO V_MVALOR1, V_MVALOR3 FROM MULT_PRODUTOSTABRG
           WHERE PRODUTO = PPRODUTO AND TABELA = 11 AND CHAVE1 = PTIPO_FRANQUIA;
    if (PvarInt1 = 2) then
       V_Qtd_Frq1 := V_MVALOR3;
    else
       V_Qtd_Frq1 := V_MVALOR1;
    end if;
/*  Busca estipulante*/
    v_DEstipulante := 0;
    v_MEstipulante := 0;
    v_MProLabore   := 0;
/*  Ver desconto/Agravo Score*/
    V_PDesc_Score := 0;
    if PORIGEM_DESC_SCORE = 'A' then
       V_PDesc_Score := PDESC_SCORE;
       if PTIPO_DESC_SCORE = 'A' then
          if V_PDesc_Score > 0 then
             V_PDesc_Score := V_PDesc_Score * (-1);
          end if;
       end if;
    else
    if PORIGEM_DESC_SCORE = 'M' then
       if (PSENHA_RENOV is not null) and (PITEM_SUBST is not null) then
          V_PDesc_Score := PDESC_SCORE;
          if V_PDesc_Score > 0 then
             if Substr(LTrim(TO_CHAR(V_PDesc_Score,'00.00')),5,1) = '1' then
                V_PDesc_Score := V_PDesc_Score - 0.01;
                V_PDesc_Score := V_PDesc_Score * (-1);
             end if;
          end if;
       else
          V_PDesc_Score := 0;
       end if;
    else
        V_PDesc_Score := 0;
    end if;
    end if;
/*  ver tipo de negocio*/
    Begin
    if PProduto = 10 then
    SELECT DESCRICAORESPOSTA INTO V_TIPO_NEGOCIO FROM KIT_CALCULOQBR
           WHERE CALCULO = PCALCULO
           AND QUESTAO = 87;
    else
    SELECT DESCRICAORESPOSTA INTO V_TIPO_NEGOCIO FROM KIT_CALCULOQBR
           WHERE CALCULO = PCALCULO
           AND QUESTAO = 222;
    end if;
    Exception
      When OTHERS then
      begin
      V_TIPO_NEGOCIO := 'Real';
      end;
    end;
    PCampo := '';
    PCampo := PCampo || 'I_CD_PROGRAMA_=KITCALC@';
    PCampo := PCampo || 'I_IND_ROTINA_=K@';
    if (PCALCULOORIGEM > 0) or (RTrim(V_TIPO_NEGOCIO) = 'Real') then
       PCampo := PCampo || 'I_TP_NEGOCIO_=R@';
    else
       PCampo := PCampo || 'I_TP_NEGOCIO_=P@';
    end if;
    IF PPRODUTO = 10 THEN
       PCampo := PCampo || 'I_COD_MOD_PROD_=7@';
    ELSE
       PCampo := PCampo || 'I_COD_MOD_PROD_=9@';
    END IF;
    PCampo := PCampo || 'I_NO_CEP_=' || LTrim(TO_CHAR(PCep,'00000000')) || '@';
    PCampo := PCampo || 'I_COD_AGRP_VEIC_=' || TO_CHAR(V_Refer) || '@';
    PCampo := PCampo || 'I_ANO_MODELO_='  ||  TO_CHAR(PANOMODELO) || '@'  ;
    PCampo := PCampo || 'I_ANO_FABRICACAO_='  ||  TO_CHAR(PANOFABRICACAO) || '@'  ;
    PCampo := PCampo || 'I_ID_00K_=' || PZERO || '@';
    PCampo := PCampo || 'I_CD_FABRICANTE_=' || TO_CHAR(PFABRICANTE) || '@';
    PCampo := PCampo || 'I_CD_MARCA_MODELO_=' || TO_CHAR(PMODELO) || '@';
    PCampo := PCampo || 'I_CD_REGIAO_=' || TO_CHAR(v_CaracRegTar) || '@';
    PCampo := PCampo || 'I_COD_FAMILIA_=' || V_CodFami || '@';
    PCampo := PCampo || 'I_NM_CATEG_SCORE_=' || V_CategScore || '@';
    PCampo := PCampo || 'I_DESC_CATEGORIA_=' || TO_CHAR(v_CategT) || '@';
    PCampo := PCampo || 'I_DS_CATEG_TARIF_=' || V_DCategT || '@';
    if PTIPO_FRANQUIA = 0 then
       V_PTIPO_FRANQUIA := 4;
    else
       V_PTIPO_FRANQUIA := PTIPO_FRANQUIA;
    end if;
    PCampo := PCampo || 'I_TP_FRANQUIA_=' || To_Char(V_PTIPO_FRANQUIA) || '@';
    Vstr := LTrim(TO_CHAR(V_Franquia_,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VAL_FRANQUIA_CA_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(v_MProLabore,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PROLABORE_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(V_FranqMin,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VL_FRANQUIA_MIN_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(V_Tx_Fran,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_FRANQUIA_=' || Vstr || '@';
/*  ver DESCONTO PROMOCIONAL*/
    if PZERO = 'S' then
       V_ZEROKMPROMO := 1;
    else
       V_ZEROKMPROMO := 0;
    end if;
    begin
    if (PvarInt1 = 2) then
    SELECT Valor, texto into V_DescPromo, V_TipoDescPromo FROM MULT_PRODUTOSTABRG WHERE PRODUTO = PPRODUTO AND TABELA = 10008
        AND (CHAVE1  = 99 OR CHAVE1 = V_CaracRegTar)
        AND (CHAVE2  = 999999999 OR CHAVE2 = V_Refer)
        AND (CHAVE3  = 9999 OR CHAVE3 = PANOMODELO)
        AND (CHAVE4 = V_ZEROKMPROMO)
        AND ROWNUM = 1
        ORDER BY CHAVE1, CHAVE2, CHAVE3;
    else
    SELECT Valor, texto into V_DescPromo, V_TipoDescPromo FROM MULT_PRODUTOSTABRG WHERE PRODUTO = PPRODUTO AND TABELA = 8
        AND (CHAVE1  = 99 OR CHAVE1 = V_CaracRegTar)
        AND (CHAVE2  = 999999999 OR CHAVE2 = V_Refer)
        AND (CHAVE3  = 9999 OR CHAVE3 = PANOMODELO)
        AND (CHAVE4 = V_ZEROKMPROMO)
        AND ROWNUM = 1
        ORDER BY CHAVE1, CHAVE2, CHAVE3;
    end if;
    Exception
      When OTHERS then
      begin
      V_DescPromo := 0;
      V_TipoDescPromo := '';
      end;
    end;
    Vstr := LTrim(TO_CHAR(V_DescPromo,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_DESC_AGRAV_PROMO_=' || Vstr || '@';
    PCampo := PCampo || 'I_ID_DESC_AGRAV_PROMO_=' || V_TipoDescPromo || '@';
    PCampo := PCampo || 'I_CI_BONUS_=' || To_Char(PNIVELBONUSAUTO) || '@';
    if PCALCULOORIGEM > 0 then
       PCampo := PCampo || 'I_ID_RENOV_AUTOM_=R@';
    else
       PCampo := PCampo || 'I_ID_RENOV_AUTOM_=@';
    end if;
/*  ver Comodato*/
    BEGIN
    SELECT RESPOSTA, DESCRICAORESPOSTA2, SUBRESPOSTA, SUBRESPOSTA2 INTO V_RESPOSTA, V_DESCRICAORESPOSTA2, V_SUBRESPOSTA, V_SUBRESPOSTA2 FROM KIT_CALCULOQBR
       WHERE CALCULO = PCALCULO
	   AND (QUESTAO = 243 OR QUESTAO = 244);
       IF (V_RESPOSTA = 586 OR V_RESPOSTA = 585) then
         BEGIN
         SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
	         WHERE PRODUTO = PPRODUTO AND TABELA = 305
	         AND CHAVE1  = V_RESPOSTA
	         AND CHAVE2  = V_SUBRESPOSTA;
         Exception
         When OTHERS then
         begin
            V_MVALOR1 := 0;
         end;
         end;
         if V_MVALOR1 = 1 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=B@';
         else
         if V_MVALOR1 = 2 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=R@';
         else
         if V_MVALOR1 = 3 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=S@';
         else
         if V_MVALOR1 = 4 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=P@';
         else
         if V_MVALOR1 = 5 then
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=L@';
         else
            PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=@';
         end if;
         end if;
         end if;
         end if;
         end if;
         PCampo := PCampo || 'I_CD_GERENC_RISCO_=' || To_Char(V_SUBRESPOSTA2) || '@';                   PCampo := PCampo || 'I_NO_CTO_COMODATO_=' || RTrim(V_DESCRICAORESPOSTA2) || '@';                   V_CodComodato := RTrim(V_DESCRICAORESPOSTA2);
       else
         PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=@';
	     PCampo := PCampo || 'I_CD_GERENC_RISCO_=0@';
         PCampo := PCampo || 'I_NO_CTO_COMODATO_=' || RTrim(V_DESCRICAORESPOSTA2) || '@';                   V_CodComodato := RTrim(V_DESCRICAORESPOSTA2);
       end if;
    Exception
      When OTHERS then
      begin
         PCampo := PCampo || 'I_TP_DISP_SEGURANCA_=@';
	     PCampo := PCampo || 'I_CD_GERENC_RISCO_=0@';
	     PCampo := PCampo || 'I_NO_CTO_COMODATO_=@';
         v_CodComodato := '';
      end;
    end;
/*  ver QBR e Dispositivo de SeguranÁa*/
    if Pproduto = 10 then
       if PTipo_Cobertura = 1 then
          V_CobTokio := 17;
       end if;
       if PTipo_Cobertura = 2 then
          V_CobTokio := 18;
       end if;
       if PTipo_Cobertura = 4 then
          V_CobTokio := 156;
       end if;
       if PTipo_Cobertura = 3 then
          V_CobTokio := 0;
       end if;
    else
       if PTipo_Cobertura = 1 then
          V_CobTokio := 63;
       end if;
       if PTipo_Cobertura = 2 then
          V_CobTokio := 64;
       end if;
       if PTipo_Cobertura = 3 then
          V_CobTokio := 0;
       end if;
       if PTipo_Cobertura = 4 then
          V_CobTokio := 158;
       end if;
    end if;
    if PvarInt1 = 2 then
       V_VigTabela := 10304;
    else
       V_VigTabela := 304;
    end if;
    V_OPCAO := 0;
    V_TReg := 0;
    V_PercCascoA := 0;
    V_PercRcfDmA := 0;
    V_PercCascoD := 0;
    V_PercRcfDmD := 0;
    PCampo_v := 'I_GRUPO_QBR_=';
    Open TQBR1;
    Loop
       Fetch TQBR1 Into v_questao, v_resposta, v_subresposta, V_AgrupamentoRegiaoQbr, V_RESPOSTA2, V_CODIGO_QUESTIONARIO;
       Exit When TQBR1%Notfound;
       V_PercA := 0;
       V_PercD := 0;
       if (V_QUESTAO = 243 OR V_QUESTAO = 244) then
          if (V_RESPOSTA = 586 OR V_RESPOSTA = 585) then
             if V_RESPOSTA2 > 0 then
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=C@I_CD_DISPOSITIVO_=0@';
             else
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=P@I_CD_DISPOSITIVO_=' || V_SUBRESPOSTA || '@';
             end if;
             begin
    	     SELECT T2.RANKING into V_MValor2 FROM MULT_PRODUTOSQBRTIPOSDISP T2, MULT_PRODUTOSQBRDISPSEG T1
	       	        WHERE T2.PRODUTO = PPRODUTO
                    AND T2.VIGENCIA = PVarint1
	       	        AND T1.PRODUTO = T2.PRODUTO
                    AND T1.VIGENCIA = T2.VIGENCIA
	       	        AND T1.TIPO   = T2.TIPO
	       	        AND T1.RESPOSTA  = V_RESPOSTA
	       	        AND T1.DISPOSITIVO  = V_SUBRESPOSTA;
             Exception
             When OTHERS then
             begin
                  V_MValor2 := 0;
             end;
             end;
             PCampo := PCampo || 'I_NO_RANK_SEGURANCA_=' || To_Char(V_MValor2) || '@';
          else
             if V_RESPOSTA2 > 0 then
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=C@I_CD_DISPOSITIVO_=0@';
             else
                PCampo := PCampo || 'I_IND_DISPOSITIVO_=N@I_CD_DISPOSITIVO_=0@';
             end if;
             PCampo := PCampo || 'I_NO_RANK_SEGURANCA_=0@';
          end if;
          V_OPCAO := 1;
          if v_CodComodato <> ' ' then
            if V_QUESTAO = 243 then
              V_RESPOSTA := 633;
            else
              V_RESPOSTA := 636;
            end if;
          end if;
       end if;
       if (v_questao = 87) and (v_resposta = 0) then
          v_resposta := 192;
       end if;
       if PTipo_Cobertura <> 3 then
       begin
          Select PERCENTUAL, TIPOPERCENTUAL into V_MValor1, V_MValor2 from MULT_PRODUTOSQBRRESPOSTAS
               where PRODUTO = PPRODUTO and VIGENCIA = PvarInt1 and Cobertura  = V_CobTokio and QUESTAO = v_questao
                    and AGRUPAMENTO = V_AgrupamentoRegiaoQbr and RESPOSTA  = v_resposta and rownum = 1;
          Exception
          When OTHERS then
          begin
            V_MValor1 := 0;
            V_MValor2 := 0;
          end;
          end;
          if V_MValor2 = 1 then
            V_PercA := V_PercA + V_MValor1;
            V_PercCascoA := V_PercCascoA + V_MValor1;
          else
             V_PercD := V_PercD + V_MValor1;
             V_PercCascoD := V_PercCascoD + V_MValor1;
          end if;
       end if;
       if PNIVELDM > 0 then
       begin
          Select PERCENTUAL, TIPOPERCENTUAL into V_MValor1, V_MValor2 from MULT_PRODUTOSQBRRESPOSTAS
               where PRODUTO = PPRODUTO and VIGENCIA = PvarInt1 and COBERTURA  = 21 and QUESTAO = v_questao
                    and AGRUPAMENTO = V_AgrupamentoRegiaoQbr and RESPOSTA  = v_resposta and rownum = 1;
          Exception
          When OTHERS then
          begin
              V_MValor1 := 0;
              V_MValor2 := 0;
          end;
          end;
          if V_MValor2 = 1 then
             V_PercRcfDmA := V_PercRcfDmA + V_MValor1;
          else
             V_PercRcfDmD := V_PercRcfDmD + V_MValor1;
          end if;
          if PTipo_Cobertura = 3 then
            if V_MValor2 = 1 then
               V_PercA := V_PercA + V_MValor1;
            else
               V_PercD := V_PercD + V_MValor1;
            end if;
          end if;
       end if;
       PCampo_v := PCampo_v || TO_Char(V_questao) || ';' || to_char(V_resposta) || ';' || TO_Char(V_PercD) || ';' || to_char(V_PercA) || '|';
       V_TReg := V_TReg + 1;
    End Loop;
    close TQBR1;
    if V_OPCAO = 0 then
       PCampo := PCampo || 'I_IND_DISPOSITIVO_=N@I_CD_DISPOSITIVO_=0@';
    end if;
    Loop
       Exit When V_TReg = 30;
       PCampo_v := PCampo_v || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo_v := PCampo_v || '@';
    PCampo := PCampo || PCampo_v;
    PCampo := PCampo || 'ACTOCCURSI_GRUPO_QBR=30@';

    V_SomaAces := 0;
    V_SomaEquip := 0;
    if PTIPO_COBERTURA <> 3 then
       V_SomaAces := PLMI_BLINDAGEM + PLMI_KITGAS;
       SELECT TEMACESSORIOS INTO V_OPCAO FROM KIT_CALCULO
          WHERE CALCULO = PCALCULO;
       if V_OPCAO = 1 then
          SELECT SUM(VALOR) into V_ACES FROM KIT_CALCULOACES
              WHERE CALCULO = PCALCULO
                AND VALOR   > 0 AND (SUBTIPO = 2 OR PPRODUTO = 10);
          V_SomaAces := V_SomaAces + V_ACES;
          SELECT SUM(VALOR) into V_ACES FROM KIT_CALCULOACES
              WHERE CALCULO = PCALCULO
                AND VALOR   > 0 AND (SUBTIPO = 1 AND PPRODUTO = 11);
          V_SomaEquip := V_SomaEquip + V_ACES;
       end if;
       Vstr := LTrim(TO_CHAR(V_SomaAces,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_LIM_ACESSORIA_=' || Vstr || '@';
       Vstr := LTrim(TO_CHAR(V_SomaEquip,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_LMI_EQUIP_=' || Vstr || '@';
       if Pproduto = 11 then
          Vstr := LTrim(TO_CHAR(PCOD_TABELA,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          PCampo := PCampo || 'I_LIM_CARROC_=' || Vstr || '@';
       else
          PCampo := PCampo || 'I_LMI_CARROC_=0,00@';
       end if;
    else
       PCampo := PCampo || 'I_LIM_ACESSORIA_=0,00@';
       PCampo := PCampo || 'I_LMI_EQUIP_=0,00@';
       PCampo := PCampo || 'I_LMI_CARROC_=0,00@';
    end if;
    V_TReg := 0;
    PCampo := PCampo || 'I_GRUPO_ACESSORIO_=';
    if PTIPO_COBERTURA <> 3 then
       if PLMI_BLINDAGEM > 0 then
          Vstr := LTrim(TO_CHAR(PLMI_BLINDAGEM,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          if Pproduto = 11 then
             PCampo := PCampo || '0;' || Vstr || ';';
          else
             PCampo := PCampo || '14249;' || Vstr || ';' ;
          end if;
          Vstr := LTrim(TO_CHAR(V_Taxa_at * 1000000,'000000000'));
          Vstr := translate(Vstr,'.',',');
          PCampo := PCampo || Vstr || ';0|';
  	      V_TReg := V_TReg + 1;
	   end if;
       if PLMI_KITGAS > 0 then
          Vstr := LTrim(TO_CHAR(PLMI_KITGAS,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          if Pproduto = 11 then
             PCampo := PCampo || '14251;' || Vstr || ';';
          else
             PCampo := PCampo || '14250;' || Vstr || ';' ;
          end if;
          Vstr := LTrim(TO_CHAR(V_Taxa_at * 1000000,'000000000.00'));
          Vstr := translate(Vstr,'.',',');
          PCampo := PCampo || Vstr || ';0|';
  	      V_TReg := V_TReg + 1;
	   end if;
       if V_OPCAO = 1 then
           Open TACES;
           Loop
              Fetch TACES Into V_ACESSORIO,V_VALOR;
                 Exit When TACES%Notfound;
              PCampo := PCampo || TO_CHAR(V_ACESSORIO) || ';';
              Vstr := LTrim(TO_CHAR(V_VALOR,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';' ;
              IF PPRODUTO = 10 THEN
                 if (PvarInt1 = 1) then
                    SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
                    WHERE PRODUTO = PPRODUTO AND TABELA = 51 AND CHAVE1 = 48 AND CHAVE2 = V_ACESSORIO;
                 else
                    SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
                   WHERE PRODUTO = PPRODUTO AND TABELA = 52 AND CHAVE1 = 48 AND CHAVE2 = V_ACESSORIO;
                 end if;
              else
                 if (PvarInt1 = 1) then
                    SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
                    WHERE PRODUTO = PPRODUTO AND TABELA = 51 AND CHAVE1 = 69 AND CHAVE2 = V_ACESSORIO;
                 else
                    SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
                   WHERE PRODUTO = PPRODUTO AND TABELA = 52 AND CHAVE1 = 69 AND CHAVE2 = V_ACESSORIO;
                 end if;
              end if;
              Vstr := LTrim(TO_CHAR(V_Mvalor1 * 1000000,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';0|';
              V_TReg := V_TReg + 1;
           End Loop;
           close TACES;
       end if;
    end if;
    Loop
       Exit When V_TReg = 10;
       PCampo := PCampo || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo := PCampo || '@ACTOCCURSI_GRUPO_ACESSORIO=10@';
    V_TReg := 0;
    PCampo := PCampo || 'I_GRUPO_EQUIPAMENTO_=';
    if PTIPO_COBERTURA <> 3 then
       if V_OPCAO = 1 then
           if PProduto = 11 then
           Open TEQP;
           Loop
              Fetch TEQP Into V_ACESSORIO,V_VALOR;
                 Exit When TEQP%Notfound;
              PCampo := PCampo || TO_CHAR(V_ACESSORIO) || ';';
              Vstr := LTrim(TO_CHAR(V_VALOR,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';' ;
              if (PvarInt1 = 1) then
                 SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
                 WHERE PRODUTO = PPRODUTO AND TABELA = 51 AND CHAVE1 = 71 AND CHAVE2 = V_ACESSORIO;
              else
                 SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
                WHERE PRODUTO = PPRODUTO AND TABELA = 52 AND CHAVE1 = 71 AND CHAVE2 = V_ACESSORIO;
              end if;
              Vstr := LTrim(TO_CHAR(V_Mvalor1 * 1000000,'000000000.00'));
              Vstr := translate(Vstr,'.',',');
              PCampo := PCampo || Vstr || ';0|';
              V_TReg := V_TReg + 1;
           End Loop;
           close TEQP;
           end if;
       end if;
    end if;
    Loop
       Exit When V_TReg = 10;
       PCampo := PCampo || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo := PCampo || '@ACTOCCURSI_GRUPO_EQUIPAMENTO=10@';
    PCampo := PCampo || 'I_DT_INI_VIGENCIA_=' || TO_CHAR(PINICIOVIGENCIA,'YYYYMMDD') || '@';
    PCampo := PCampo || 'I_DT_FIM_VIGENCIA_=' || TO_CHAR(PFINALVIGENCIA,'YYYYMMDD') || '@';
    PCampo := PCampo || 'I_TP_PESSOA_=' || PTIPO_PESSOA || '@';
    if PCOD_TABELA = 1 then
       PCampo := PCampo || 'I_CD_TAB_ACEITE_=4@';
    else
       PCampo := PCampo || 'I_CD_TAB_ACEITE_=2@';
    end if;
    if PMODALIDADE = 'A' then
       V_Ajuste := PAjuste;
    else
       if V_Val_Med > 0 then
          V_Ajuste := PVALORVEICULO / V_Val_Med * 100;
       else
       if V_ValorMin > 0 then
          V_Ajuste := PVALORVEICULO / V_ValorMin * 100;
       else
          V_Ajuste := 100;
       end if;
       end if;
    end if;
    Vstr := LTrim(TO_CHAR(V_Ajuste,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PER_CONTRATACAO_=' || Vstr || '@';
    Vstr := LTrim(TO_CHAR(V_Ajuste * 1000000,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_TAB_ACEITE_=' || Vstr || '@';
    PCampo := PCampo || 'I_CD_CORRETOR_=' || TO_CHAR(V_CodCorr) || '@';
    PCampo := PCampo || 'I_NO_ESTIP_=' || to_Char(V_MEstipulante) || '@';
    if PTIPO_COBERTURA =  3 then
       PCampo := PCampo || 'I_TP_ASS_24H_=0@';
    else
    if PProduto = 10 then
       if (PTipo_Site = 'K') Then
          PCampo := PCampo || 'I_TP_ASS_24H_=12392@';
          V_TpAss24h := 12392;
       else
       if PESTADO = 'C' then
          PCampo := PCampo || 'I_TP_ASS_24H_=12392@';
          V_TpAss24h := 12392;
       else
          PCampo := PCampo || 'I_TP_ASS_24H_=12391@';
          V_TpAss24h := 12391;
       end if;
       end if;
    else
    if PProduto = 11 then
       if PESTADO = 'S' then
          PCampo := PCampo || 'I_TP_ASS_24H_=4485@';
          V_TpAss24h := 4485;
       else
          PCampo := PCampo || 'I_TP_ASS_24H_=4486@';
          V_TpAss24h := 4486;
       end if;
    end if;
    end if;
    end if;
    V_VlrAss24h := 0;
    if PTIPO_COBERTURA <> 3 then
       BEGIN
      if PPRODUTO = 10 then
          if (PvarInt1 = 2) then
              SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
              WHERE PRODUTO = PPRODUTO AND TABELA = 10308 AND CHAVE1 = PANOMODELO AND CHAVE2 = 7 AND CHAVE3 = V_TpAss24h AND CHAVE4 = v_M_Regiao AND CHAVE5 = V_CategT;
          else
              SELECT VALOR INTO V_MVALOR1 FROM MULT_PRODUTOSTABRG
              WHERE PRODUTO = PPRODUTO AND TABELA = 308 AND CHAVE1 = PANOMODELO AND CHAVE2 = 7 AND CHAVE3 = V_TpAss24h AND CHAVE4 = v_M_Regiao AND CHAVE5 = V_CategT;
          end if;
      else
          if (PvarInt1 = 2) then
              SELECT VALOR INTO V_MVALOR1 FROM VW_TABRG_P11_T13 WHERE CHAVE1 = 1;
          else
              SELECT VALOR2 INTO V_MVALOR1 FROM VW_TABRG_P11_T13 WHERE CHAVE1 = 1;
          end if;
       end if;
       Exception
       When OTHERS then
       begin
           V_MValor1 := 0;
       end;
       end;
       V_VlrAss24h  := V_MValor1;
    end if;
    Vstr := LTrim(TO_CHAR(Abs(V_VlrAss24h),'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_VL_ASSIST_24H_=' || Vstr || '@';
    if V_MISRes = 1000 then
       PCampo := PCampo || 'I_TP_CARRO_REV_=10752@';
    else
    if V_MISRes = 2000 then
       PCampo := PCampo || 'I_TP_CARRO_REV_=10753@';
    else
       PCampo := PCampo || 'I_TP_CARRO_REV_=4615@';
    end if;
    end if;
    if PPRODUTO = 10 then
        if V_IS_Dextr <> 0 then
            PCampo := PCampo || 'I_TP_COB_EXTRA_=4160@';
        else
            PCampo := PCampo || 'I_TP_COB_EXTRA_=4616@';
        end if;
     else
        if V_IS_Dextr <> 0 then
            PCampo := PCampo || 'I_TP_COB_EXTRA_=4227@';
        else
            PCampo := PCampo || 'I_TP_COB_EXTRA_=4617@';
        end if;
    end if;
    PCampo := PCampo || 'I_TP_COB_VIDROS_=' || To_Char(V_Carac049) || '@';
    PCampo := PCampo || 'I_ID_CATEG_SUBSCRICAO_=0@';
    PCampo := PCampo || 'I_CD_CARAC_SUBSCRICAO_=0@';
    PCampo := PCampo || 'I_ID_VEIC_SUBSCRICAO_=' || V_SubTxCasco || '@';
    PCampo := PCampo || 'I_CD_LOTACAO_=' || TO_CHAR(v_Lotacao) || '@';
    if PCALCULOORIGEM > 0 then
       Vstr := LTrim(TO_CHAR(Abs(V_PDesc_Score),'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_=' || Vstr || '@';
       if V_PDesc_Score < 0 then
          PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_=A@';
       else
       if V_PDesc_Score > 0 then
          PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_=D@';
       else
          PCampo := PCampo || 'I_IN_DESC_AGRAV_SCORE_=@';
       end if;
       end if;
    else
       PCampo := PCampo || 'I_PE_DESC_AGRAV_SCORE_=0@';
       PCampo := PCampo ||  'I_IN_DESC_AGRAV_SCORE_=@';
    end if;
    if PTIPO_COBERTURA <> 3 then
       Vstr := LTrim(TO_CHAR(v_PercCascoD,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_TX_DESC_QBR_=' || Vstr || '@';
       Vstr := LTrim(TO_CHAR(v_PercCascoA,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_TX_AGRAV_QBR_=' || Vstr || '@';
    else
       Vstr := LTrim(TO_CHAR(v_PercRcfDmD,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_TX_DESC_QBR_=' || Vstr || '@';
       Vstr := LTrim(TO_CHAR(v_PercRcfDmA,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_TX_AGRAV_QBR_=' || Vstr || '@';
    end if;
 /* busca bonus casco*/
    V_PBonusCasco := 0;
    V_QtRen := 0;
    if PvarInt1 = 2 then
       V_VigTabela := 10306;
    else
       V_VigTabela := 306;
    end if;
    if PNIVELBONUSAUTO > 0 then
       if PTIPO_COBERTURA <> 3 then
          if PNIVELBONUSAUTO > 9 then
            SELECT NIVEL, BONUSAUTO into V_QtRen, V_PBonusCasco FROM MULT_PRODUTOSBONUS
            WHERE PRODUTO = pproduto
            AND NIVEL = 9;
          else
            SELECT NIVEL, BONUSAUTO into V_QtRen, V_PBonusCasco FROM MULT_PRODUTOSBONUS
            WHERE PRODUTO = pproduto
            AND NIVEL = PNIVELBONUSAUTO;
          end if;
          begin
          SELECT PERCDESC into V_MValor1 FROM MULT_PRODUTOSQBRABATBONUS
          WHERE PRODUTO = PPRODUTO
                AND FAMILIA = V_Familia
                AND COBERTURA = V_CobTokio
                AND CLBONUS = V_QTREN
                AND VIGENCIA = PvarInt1
                AND FAIXADESCDE  >= (V_PercCascoD - V_PercCascoA)
                AND FAIXADESCATE  <= (V_PercCascoD - V_PercCascoA);
          Exception
          When OTHERS then
          begin
              V_MValor1 := 0;
          end;
          end;
          V_PBonusCasco := V_PBonusCasco + V_MValor1;
       end if;
    end if;
    Vstr := LTrim(TO_CHAR(V_PBonusCasco,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_PE_DESC_BONUS_=' || Vstr || '@';
    if PTIPO_COBERTURA <> 3 then
       begin
       if PvarInt1 = 1 then
          SELECT VALOR2, TEXTO INTO V_MVALOR2, V_TEXTO FROM MULT_PRODUTOSTABRG WHERE PRODUTO = PPRODUTO AND TABELA = 9
		           AND CHAVE1  = V_CobTokio
		           AND CHAVE2  = V_CaracRegTar
		           AND CHAVE3  = V_PTIPO_FRANQUIA;
       else
          SELECT VALOR2, TEXTO INTO V_MVALOR2, V_TEXTO FROM MULT_PRODUTOSTABRG WHERE PRODUTO = PPRODUTO AND TABELA = 10009
		           AND CHAVE1  = V_CobTokio
		           AND CHAVE2  = V_CaracRegTar
		           AND CHAVE3  = V_PTIPO_FRANQUIA;
       end if;
       Exception
       When OTHERS then
       begin
           V_MValor2 := 0;
           V_TEXTO := 'D';
       end;
       end;
       Vstr := LTrim(TO_CHAR(V_MValor2,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_PE_DESC_AGRAV_FRANQ_=' || Vstr || '@';
       PCampo := PCampo || 'I_IN_DESC_AGRAV_FRANQ_=' || V_TEXTO || '@';
    else
       PCampo := PCampo || 'I_PE_DESC_AGRAV_FRANQ_=0,00@';
       PCampo := PCampo || 'I_IN_DESC_AGRAV_FRANQ_=D@';
    end if;
    Vstr := LTrim(TO_CHAR((V_Taxa_at * 100000), '9999999990') || '0');
    PCampo := PCampo || 'I_PE_TAXA_ATUARIAL_=' || Vstr || '@';
    PCampo := PCampo || 'I_TP_RELACIONAMENTO_=R@';
    if PProduto = 10 then
        if PPROCEDENCIA  = 'G' then
            PCampo := PCampo || 'I_CD_COMBUSTIVEL_=14@';
        else
            if PPROCEDENCIA  = 'A' then
                PCampo := PCampo || 'I_CD_COMBUSTIVEL_=13@';
            else
                PCampo := PCampo || 'I_CD_COMBUSTIVEL_=15@';
            end if;
        end if;
     else
        if PPROCEDENCIA  = 'G' then
            PCampo := PCampo || 'I_CD_COMBUSTIVEL_=2374@';
        else
            if PPROCEDENCIA  = 'A' then
                PCampo := PCampo || 'I_CD_COMBUSTIVEL_=2373@';
            else
                PCampo := PCampo || 'I_CD_COMBUSTIVEL_=2375@';
            end if;
         end if;
      end if;
/*  obtem desconto de modulo*/
    V_DescMod  := 0;
    Vstr := LTrim(TO_CHAR(V_DescMod ,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_TX_DESCONTO_=' || Vstr || '@';
    If PDias < 365 then
       PCampo := PCampo || 'I_CD_PRAZO_CURTO_=S@';
    else
       PCampo := PCampo || 'I_CD_PRAZO_CURTO_=@';
    end if;
    Vstr := LTrim(TO_CHAR(V_DEstipulante,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_DESC_ESTIP_=' ||  Vstr || '@';
    PCampo := PCampo || 'I_AGRAV_ESTIP_=0@';
    if V_DEstipulante = 0 then
       Vstr := LTrim(TO_CHAR(Abs(PCOD_REFERENCIA),'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo := PCampo || 'I_PE_DESC_AGRAV_COMERCIAL_=' || Vstr || '@';
    else
       PCampo := PCampo || 'I_PE_DESC_AGRAV_COMERCIAL_=0@';
    end if;
    if V_DEstipulante = 0 then
       if PCOD_REFERENCIA > 0 then
          PCampo := PCampo || 'I_IN_DESC_AGRAV_COMERCIAL_=D@';
       else
          PCampo := PCampo || 'I_IN_DESC_AGRAV_COMERCIAL_=A@';
       end if;
    else
       PCampo := PCampo || 'I_IN_DESC_AGRAV_COMERCIAL_=A@';
    end if;
    Vstr := LTrim(TO_CHAR(PCOMISSAO,'000000000.00'));
    Vstr := translate(Vstr,'.',',');
    PCampo := PCampo || 'I_COMISS_COMISSAO_=' || Vstr || '@';
    PCampo_V := 'I_GRUPO_COBERTURA_=';
    v_TReg := 0;
    If PValorVeiculo > 0 then
       Vstr := LTrim(TO_CHAR(PValorVeiculo,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       PCampo_v := PCampo_v || to_char(V_CobTokio) || ';' || Vstr || ';0;0|';
       PCampo := PCampo || 'I_LMI_CASCO_=' || Vstr || '@';
       V_TReg := V_TReg + 1;
    end if;
    If V_SomaAces > 0 then
       Vstr := LTrim(TO_CHAR(V_SomaAces,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
          PCampo_v := PCampo_v || '48' || ';' || Vstr || ';0;0|';
       else
          PCampo_v := PCampo_v || '69' || ';' || Vstr || ';0;0|';
       end if;
       V_TReg := V_TReg + 1;
    end if;
    If PNivelDm > 0 then
       Vstr := LTrim(TO_CHAR(PNivelDm,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
         PCampo_v := PCampo_v || '21' || ';' || Vstr || ';0;0|';
       else
         PCampo_v := PCampo_v || '65' || ';' || Vstr || ';0;0|';
       end if;
       PCampo := PCampo || 'I_LIM_RCF_DM_=' || Vstr || '@';
       V_TReg := V_TReg + 1;
    end if;
    If PNivelDp > 0 then
       Vstr := LTrim(TO_CHAR(PNivelDp,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
         PCampo_v := PCampo_v || '57' || ';' || Vstr || ';0;0|';
       else
         PCampo_v := PCampo_v || '66' || ';' || Vstr || ';0;0|';
       end if;
       PCampo := PCampo || 'I_LIM_RCF_DC_=' || Vstr || '@';
       V_TReg := V_TReg + 1;
    end if;
    If PBLINDAGEM <> 'S' then
       If (V_Carac049 = 12384) or (V_Carac049 = 12385) then
           begin
           SELECT VALOR2 INTO V_MVALOR2 FROM MULT_PRODUTOSTABRG WHERE PRODUTO = PPRODUTO AND TABELA = 6666
		           AND CHAVE1  = 1 AND CHAVE2 = 272;
           Exception
           When OTHERS then
           begin
              V_MValor2 := 0;
           end;
           end;
           Vstr := LTrim(TO_CHAR(V_MValor2,'000000000.00'));
           Vstr := translate(Vstr,'.',',');
           PCampo_v := PCampo_v || '272' || ';' || Vstr || ';0;0|';
           V_TReg := V_TReg + 1;
       end if;
    end if;
    if PValorAppMorte > 0 then
       Vstr := LTrim(TO_CHAR(PValorAppMorte,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
         PCampo_v := PCampo_v || '24' || ';' || Vstr || ';0;0|';
         V_TReg := V_TReg + 1;
         PCampo_v := PCampo_v || '27' || ';' || Vstr || ';0;0|';
       else
         PCampo_v := PCampo_v || '67' || ';' || Vstr || ';0;0|';
         V_TReg := V_TReg + 1;
         PCampo_v := PCampo_v || '68' || ';' || Vstr || ';0;0|';
       end if;
       V_TReg := V_TReg + 1;
       PCampo := PCampo || 'I_LIM_APP_MORTE_=' || Vstr || '@';
       PCampo := PCampo || 'I_LIM_APP_INVAL_=' || Vstr || '@';
    end if;
    IF PValorAppDMH <> 0 then
       Vstr := LTrim(TO_CHAR(PValorAppDMH,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
         PCampo_v := PCampo_v || '243' || ';' || Vstr || ';0;0|';
       else
         PCampo_v := PCampo_v || '246' || ';' || Vstr || ';0;0|';
       end if;
       V_TReg := V_TReg + 1;
       PCampo := PCampo || 'I_LIM_RCF_DMO_=' || Vstr || '@';
    end if;
    if V_IS_Dextr <> 0 then
       Vstr := LTrim(TO_CHAR(V_IS_Dextr,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
          PCampo_v := PCampo_v || '157' || ';' || Vstr || ';0;0|';
       else
          PCampo_v := PCampo_v || '159' || ';' || Vstr || ';0;0|';
       end if;
       V_TReg := V_TReg + 1;
       PCampo := PCampo || 'I_LIM_DESP_EXTRASA_=' || Vstr || '@';
    end if;
    if V_MISRes > 0 then
       Vstr := LTrim(TO_CHAR(V_MISRes,'000000000.00'));
       Vstr := translate(Vstr,'.',',');
       if PPRODUTO = 10 then
          PCampo_v := PCampo_v || '155' || ';' || Vstr || ';0;0|';
       else
          PCampo_v := PCampo_v || '70' || ';' || Vstr || ';0;0|';
       end if;
       V_TReg := V_TReg + 1;
    end if;
    Loop
       Exit When V_TReg = 30;
       PCampo_v := PCampo_v || '0;0;0;0|';
       V_TReg := V_TReg + 1;
    end Loop;
    PCampo_v := PCampo_v || '@ACTOCCURSI_GRUPO_COBERTURA=30@';
    PCampo := PCampo || PCampo_v;
    PCampo := PCampo || 'I_NO_PESO_VEICULO_=' || to_char(v_Peso) ||'@';
    PCampo := PCampo || 'I_NO_POTENCIA_VEICULO_=' || to_char(V_Potencia) || '@';
    PCampo := PCampo || 'I_TP_COMBUSTIVEL_=' || V_TP_Comb || '@';
    PCampo := PCampo || 'I_TP_VIDRO_=' || V_TP_Vidro || '@';
    PCampo := PCampo || 'I_CLUS_MOD_FREQROFU_=' || to_char(V_Frq_Roubo) || '@';
    PCampo := PCampo || 'I_CLUS_MOD_FREQCOL_=' || to_char(V_Frq_Colisao) || '@';
    PCampo := PCampo || 'I_CLUS_MOD_GDM_=' || to_char(V_Frq_Gdm) || '@';
    PCampo := PCampo || 'I_CD_TIPO_VEICULO_=' || to_char(V_Cd_Tipo) || '@';
    PCampo := PCampo || 'I_NO_CARGA_VEICULO_=' || to_Char(v_No_Carga) ||'@';
    PCampo := PCampo || 'I_COD_AG_CAPTADORA_=' || TO_CHAR(V_AGCapt) || '@';
    PCampo := PCampo || 'I_COD_AGRP_REG_=' || TO_CHAR(V_CaracRegTar) || '@'  ;
    PCampo := PCampo || 'I_COD_CATEGORIA_=' || V_CategEstat || '@';
    if (PMODALIDADE = 'A') OR (PMODALIDADE is null) then
        PCampo := PCampo || 'I_MOD_SEGURO_=3@';
    else
        PCampo := PCampo || 'I_MOD_SEGURO_=1@';
    end if;
    PCampo := PCampo || 'I_COD_COBERT_BAS_='|| TO_CHAR(V_CobTokio) || '@';
    PCampo := PCampo || 'I_CD_CAPITACAO_=0@';
    PCampo := PCampo || 'I_COD_CONGENERE_=0@';
    PCampo := PCampo || 'I_DT_NASCIMENTO_=0@';
    PCampo := PCampo || 'I_NO_CEP_CLI_=0@';
    PCampo := PCampo || 'I_NO_ITEM_=0@';
    PCampo := PCampo || 'I_NO_ENDOSSO_=0@';
    PCampo := PCampo || 'I_CD_CLIENTE_=0@';
    PCampo := PCampo || 'I_PE_COMIS_REPASSE_=0@';
    PCampo := PCampo || 'I_TIPO_TABELA_='|| v_tipoTabela || '@';

    /*Novos campos*/
    if PItem = 0 then
      PCampo := PCampo || 'I_IN_FROTA_=N@';
    else
      PCampo := PCampo || 'I_IN_FROTA_=S@';
    end if;

    PCampo := PCampo || 'I_CD_QUESTIONARIO_='|| V_CODIGO_QUESTIONARIO || '@';

    SELECT VERSAO INTO V_VERSAO_QUESTIONARIO FROM MULT_PRODUTOSQBRGRUPOS
       WHERE PRODUTO = PPRODUTO AND VIGENCIA = PvarInt1 AND CODIGO = V_CODIGO_QUESTIONARIO;

    PCampo := PCampo || 'I_VERSAO_QUESTIONARIO_='|| V_VERSAO_QUESTIONARIO || '@';

    /*Dados do Condutor*/
    PCampo := PCampo || 'I_NO_CPF_COND_=0@';
    PCampo := PCampo || 'I_NO_CNH_COND_=0@';
    PCampo := PCampo || 'I_SEXO_COND_='|| PSEXOCONDU || '@';
    PCampo := PCampo || 'I_ESTADO_CIVIL_COND_='|| PESTCVCONDU || '@';
    if (PDTNASCONDU IS NOT NULL) then
      PCampo := PCampo || 'I_DT_NASC_COND_='|| TO_CHAR(PDTNASCONDU,'YYYYMMDD') || '@';
    else
      PCampo := PCampo || 'I_DT_NASC_COND_=@';
    end if;

    /*Tipo de Uso do Veiculo*/
    PCampo := PCampo || 'I_TP_USO_VEICULO_='|| PTIPOUSOVEIC || '@';

    open PRetorno for
        SELECT PCampo as conteudo from dual;
end;
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_CALCULO_KIT" (
PCALCULO   kit_CALCULO.CALCULO%Type,
PPRODUTO   kit_CALCULOPREMIOSCOB.PRODUTO%Type,
PFRANQUIA  kit_CALCULOPREMIOSCOB.FRANQUIA%Type,
pTipo_Cobertura int,
pValorVeiculo number,
pPr_Casco number,
pTaxa_at  number,
pIS_Acess number,
pPr_Acess number,
pIS_RcfDM number,
pPr_RcfDM number,
pTaxadm   number,
pIS_DMO   number,
pPr_DMO   number,
pTaxadmo  number,
pIS_AppM  number,
pPr_App   number,
pTaxaapp  number,
pIS_RcfDP number,
pPr_rcfdpMes number,
pPr_RcfDP number,
pTaxadp number,
pM_PrRes number,
pIS_Dextr number,
pM_Dextr number,
pCarac049 number,
pM_PrVidr number,
pMDias number,
pPr_cascomm number,
pPr_Acessmm number,
pPr_RcfDMmm number,
pPr_RcfDPmm number,
pPr_DMOmm number,
pPr_Appmm number,
pPr_cascoMes number,
pPr_acessMes number,
pPr_rcfdmMes number,
pPr_dmoMes number,
pPr_appMes number,
pPr_CarMes number,
pPr_DexMes number,
pPr_VidrMes number,
pMEstipulante number,
pModalidade varchar,
pTemCepGo int,       /* 0 = True  1 = False */
pCodTabela varchar,
pDescricaoAjuste varchar,
pAjuste number,
pIND_RENOVACAO500 number,
pFINALVIGENCIA date,
pINICIOVIGENCIA date,
pCondicao2 number,
pMTPREL number,
OPCAORESERVA number
)
IS
BEGIN
  declare
      vMVersao smallint;
      VMValidade date;
      VMValidade_Anterior date;
      vMIsRes  int;
      vMVALOR1 number(18,6);
      vMVALOR2 number(18,6);
      vMVALOR3 number(18,6);
      vMVALOR4 number(18,6);
      vMVALOR5 number(18,6);
      vMQtdP   number(18,6);
      vMVMin   number(18,6);
      vMPrLiq  number(18,6);
      vMPrIof  number(18,6);
      vMPrTot  number(18,6);
      vMParc   int;
      vMJuros  number(18,6);
      vMVParc  number(18,6);
      vErro    varchar(1000);
      Vstr     varchar(20);
  begin
    /* REMOVER NO PROXIMO MES 0109K1                           */
    SELECT VALIDADE,VALIDADEANTERIOR into VMValidade,VMValidade_Anterior from mult_produtos where produto = 10;
    if pINICIOVIGENCIA < VMValidade and  VMValidade_Anterior <> '' then
      vMVERSAO := 2;
    else
      vMVERSAO := 1;
    end if;
      if (pTIPO_COBERTURA<> 3) then
        Vstr := to_char(pFranquia,'999,999,990.00');
        Vstr := translate(Vstr,'.','@');
        Vstr := translate(Vstr,',','.');
        Vstr := translate(Vstr,'@',',');
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>1,
                          PVALOR=>pValorVeiculo , PPREMIO=>pPr_Casco, PFRANQUIA=>0 , PTAXA=>pTaxa_at, PDESCRICAO=>' R$ ' || Vstr );
/*        AtualizarCoberturas(1, 1, pValorVeiculo, Pr_Casco, 0, Taxa_at, ' R$ ' + FormatFloat('###0.00', Franquia)) */
      else
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>1,
                          PVALOR=>0 , PPREMIO=>0, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'' );
/*        AtualizarCoberturas(1, 1, 0, 0, 0, 0, ' '); */
      end if;

      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>1002,
                        PVALOR=>pIS_Acess , PPREMIO=>pPR_Acess, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'' );
/*      AtualizarCoberturas(1, 1002, IS_Acess, Pr_Acess, 0, 0, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>4,
                        PVALOR=>pIS_RcfDM , PPREMIO=>pPr_RcfDM, PFRANQUIA=>0 , PTAXA=>pTaxadm, PDESCRICAO=>'' );
/*      AtualizarCoberturas(1, 4, IS_RcfDM, Pr_RcfDM, 0, Taxadm, ''); */

      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>5,
                        PVALOR=>pIS_RcfDP , PPREMIO=>pPr_RcfDP, PFRANQUIA=>0 , PTAXA=>pTaxadp, PDESCRICAO=>'' );
/*      AtualizarCoberturas(1, 5, IS_RcfDP, Pr_RcfDP, 0, Taxadp, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>64,
                        PVALOR=>pIS_DMO , PPREMIO=>pPr_DMO, PFRANQUIA=>0 , PTAXA=>pTaxadmo, PDESCRICAO=>'' );
/*      AtualizarCoberturas(1, 64, IS_DMO, Pr_DMO, 0, Taxadmo, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>33,
                        PVALOR=>pIS_AppM , PPREMIO=>pPr_App, PFRANQUIA=>0 , PTAXA=>pTaxaapp, PDESCRICAO=>'' );
/*      AtualizarCoberturas(1, 33, IS_AppM, Pr_App, 0, Taxaapp, ''); */

      if OPCAORESERVA = 2 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'08 dias + 7 gr·tis' );
/*        AtualizarCoberturas(1, 1001, 0, M_PrRes, 0, 0, '08 dias + 7 gr·tis') */
      elsif OPCAORESERVA = 3 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'23 dias + 7 gr·tis' );
/*        AtualizarCoberturas(1, 1001, 0, M_PrRes, 0, 0, '23 dias + 7 gr·tis') */
      elsif pTIPO_COBERTURA = 3 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'S/ cobertura' );
/*        AtualizarCoberturas(1, 1001, 0, M_PrRes, 0, 0, 'S/ cobertura') */
      else
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'7 di·rias gratuitas' );
/*        AtualizarCoberturas(1, 1001, 0, M_PrRes, 0, 0, '7 di·rias gratuitas'); */
      end if;

      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>1000,
                        PVALOR=>pIS_Dextr , PPREMIO=>pM_Dextr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'' );
/*      AtualizarCoberturas(1, 1000, IS_Dextr, M_Dextr, 0, 0, ''); */

      if pCarac049 = 12385 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>28,
                          PVALOR=>0 , PPREMIO=>pM_PrVidr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'Completo' );
/*        AtualizarCoberturas(1, 28, 0, M_PrVidr, 0, 0, 'Completo') */
      elsif pCarac049 = 12384 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>1, PCOBERTURA=>28,
                          PVALOR=>0 , PPREMIO=>pM_PrVidr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'B·sico' );
/*        AtualizarCoberturas(1, 28, 0, M_PrVidr, 0, 0, 'B·sico') */
      elsif pCarac049 = 12383 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>1, PCOBERTURA=>28,
                          PVALOR=>0 , PPREMIO=>pM_PrVidr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'S/ cobertura' );
/*        AtualizarCoberturas(1, 28, 0, M_PrVidr, 0, 0, 'S/ cobertura'); */
      end if;

   /*-------------------------------------------------------- Atualiza IS e PrÍmios das Coberturas 2 ----------*/
      if (pMDias <= 366) then

        if pTIPO_COBERTURA <> 3 then
          Vstr := to_char(pFranquia,'999,999,990.00');
          Vstr := translate(Vstr,'.','@');
          Vstr := translate(Vstr,',','.');
          Vstr := translate(Vstr,'@',',');
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>2, PCOBERTURA=>1,
                            PVALOR=>pValorVeiculo , PPREMIO=>pPr_cascomm, PFRANQUIA=>0 , PTAXA=>ptaxa_At, PDESCRICAO=>' R$ ' || vStr );
/*          AtualizarCoberturas(2, 1, Mult_Calculo.FieldByName('VALORVEICULO').asFloat, Pr_cascomm, 0, taxa_At, ' R$ ' + FormatFloat('###0.00', Franquia)); */
        else
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>1,
                            PVALOR=>0 , PPREMIO=>0, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>' ' );
/*          AtualizarCoberturas(2, 1, 0, 0, 0, 0, ''); */
        end if;

        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>1002,
                          PVALOR=>pIS_Acess , PPREMIO=>pPr_Acessmm, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(2, 1002, IS_Acess, Pr_Acessmm, 0, 0, ''); */
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>4,
                          PVALOR=>pIS_RcfDM , PPREMIO=>pPr_RcfDMmm, PFRANQUIA=>0 , PTAXA=>pTaxaDm, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(2, 4, IS_RcfDM, Pr_RcfDMmm, 0, TaxaDm, ''); */
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>5,
                          PVALOR=>pIS_RcfDP , PPREMIO=>pPr_RcfDPmm, PFRANQUIA=>0 , PTAXA=>pTaxaDp, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(2, 5, IS_RcfDP, Pr_RcfDPmm, 0, TaxaDp, ''); */
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>64,
                          PVALOR=>pIS_DMO , PPREMIO=>pPr_DMOmm, PFRANQUIA=>0 , PTAXA=>pTaxaDmo, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(2, 64, IS_DMO, Pr_DMOmm, 0, TaxaDmo, ''); */
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>33,
                          PVALOR=>pIS_AppM , PPREMIO=>pPr_Appmm, PFRANQUIA=>0 , PTAXA=>pTaxaApp, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(2, 33, IS_AppM, Pr_Appmm, 0, TaxaApp, ''); */

        if OPCAORESERVA = 2 then
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>1001,
                            PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'08 dias + 7 gr·tis' );
/*          AtualizarCoberturas(2, 1001, 0, M_PrRes, 0, 0, '08 dias + 7 gr·tis') */
        elsif OPCAORESERVA = 3 then
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>1001,
                            PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'23 dias + 7 gr·tis' );
/*          AtualizarCoberturas(2, 1001, 0, M_PrRes, 0, 0, '23 dias + 7 gr·tis')  */
        elsif pTIPO_COBERTURA = 3 then
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>1001,
                            PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'S/ cobertura' );
/*          AtualizarCoberturas(2, 1001, 0, M_PrRes, 0, 0, 'S/ cobertura') */
        else
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>2, PCOBERTURA=>1001,
                            PVALOR=>0 , PPREMIO=>pM_PrRes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'7 di·rias gratuitas' );
/*          AtualizarCoberturas(2, 1001, 0, M_PrRes, 0, 0, '7 di·rias gratuitas'); */
        end if;

        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>2, PCOBERTURA=>1000,
                          PVALOR=>pIS_Dextr , PPREMIO=>pM_Dextr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(2, 1000, IS_Dextr, M_Dextr, 0, 0, ''); */
    /* ---------------------------------------------------------------------------------*/
        if pCarac049 = 12385 then
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>28,
                            PVALOR=>0 , PPREMIO=>pM_PrVidr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'Completo' );
/*          AtualizarCoberturas(2, 28, 0, M_PrVidr, 0, 0, 'Completo')   */
       elsif pCarac049 = 12384 then
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo,  PPRODUTO=>2, PCOBERTURA=>28,
                            PVALOR=>0 , PPREMIO=>pM_PrVidr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'B·sico' );
/*          AtualizarCoberturas(2, 28, 0, M_PrVidr, 0, 0, 'B·sico')  */
       elsif pCarac049 = 12383 then
          GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>2, PCOBERTURA=>28,
                            PVALOR=>0 , PPREMIO=>pM_PrVidr, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'S/ cobertura' );
/*          AtualizarCoberturas(2, 28, 0, M_PrVidr, 0, 0, 'S/ cobertura'); */
       end if;

      end if;
   /*-------------------------------------------------------- Atualiza IS e PrÍmios das Coberturas 3 ----------*/
      if pTIPO_COBERTURA <> 3 then
        Vstr := to_char(pFranquia,'999,999,990.00');
        Vstr := translate(Vstr,'.','@');
        Vstr := translate(Vstr,',','.');
        Vstr := translate(Vstr,'@',',');
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1,
                          PVALOR=>pValorVeiculo , PPREMIO=>pPr_cascoMes, PFRANQUIA=>0 , PTAXA=>pTaxa_At, PDESCRICAO=>' R$ ' || Vstr );
/*        AtualizarCoberturas(3, 1, Mult_Calculo.FieldByName('VALORVEICULO').asFloat, Pr_cascoMes, 0, Taxa_At, ' R$ ' + FormatFloat('###0.00', Franquia)); */
      else
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1,
                          PVALOR=>0 , PPREMIO=>0, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>' ' );
/*        AtualizarCoberturas(3, 1, 0, 0, 0, 0, ''); */
      end if;
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1002,
                        PVALOR=>pIS_Acess , PPREMIO=>pPr_acessMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>' ' );
/*      AtualizarCoberturas(3, 1002, IS_Acess, Pr_acessMes, 0, 0, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>4,
                        PVALOR=>pIS_RcfDM , PPREMIO=>pPr_rcfdmMes, PFRANQUIA=>0 , PTAXA=>pTaxaDm, PDESCRICAO=>' ' );
/*      AtualizarCoberturas(3, 4, IS_RcfDM, Pr_rcfdmMes, 0, TaxaDm, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>5,
                        PVALOR=>pIS_RcfDP , PPREMIO=>pPr_rcfdpMes, PFRANQUIA=>0 , PTAXA=>pTaxaDp, PDESCRICAO=>' ' );
/*      AtualizarCoberturas(3, 5, IS_RcfDP, Pr_rcfdpMes, 0, TaxaDp, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>64,
                        PVALOR=>pIS_DMO , PPREMIO=>pPr_dmoMes, PFRANQUIA=>0 , PTAXA=>pTaxaDmo, PDESCRICAO=>' ' );
/*      AtualizarCoberturas(3, 64, IS_DMO, Pr_dmoMes, 0, TaxaDmo, ''); */
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>33,
                        PVALOR=>pIS_AppM , PPREMIO=>pPr_appMes, PFRANQUIA=>0 , PTAXA=>pTaxaApp, PDESCRICAO=>' ' );
/*      AtualizarCoberturas(3, 33, IS_AppM, Pr_appMes, 0, TaxaApp, ''); */
      if OPCAORESERVA = 2 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pPr_CarMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'08 dias + 7 gr·tis' );
/*        AtualizarCoberturas(3, 1001, 0, Pr_CarMes, 0, 0, '08 dias + 7 gr·tis') */
      elsif OPCAORESERVA = 3 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pPr_CarMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'23 dias + 7 gr·tis' );
/*        AtualizarCoberturas(3, 1001, 0, Pr_CarMes, 0, 0, '23 dias + 7 gr·tis') */
      elsif pTIPO_COBERTURA = 3 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pPr_CarMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'S/ cobertura' );
/*        AtualizarCoberturas(3, 1001, 0, Pr_CarMes, 0, 0, 'S/ cobertura') */
      else
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1001,
                          PVALOR=>0 , PPREMIO=>pPr_CarMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'7 di·rias gratuitas' );
/*        AtualizarCoberturas(3, 1001, 0, Pr_CarMes, 0, 0, '7 di·rias gratuitas'); */
      end if;
      GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>1001,
                        PVALOR=>pIS_Dextr , PPREMIO=>pPr_DexMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'' );
/*      AtualizarCoberturas(3, 1000, IS_Dextr, Pr_DexMes, 0, 0, ''); */
      if pCarac049 = 12385 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>28,
                          PVALOR=>0 , PPREMIO=>pPr_VidrMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'Completo' );
/*        AtualizarCoberturas(3, 28, 0, Pr_VidrMes, 0, 0, 'Completo')  */
     elsif pCarac049 = 12384 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>28,
                          PVALOR=>0 , PPREMIO=>pPr_VidrMes, PFRANQUIA=>0, PTAXA=>0, PDESCRICAO=>'B·sico' );
/*        AtualizarCoberturas(3, 28, 0, Pr_VidrMes, 0, 0, 'B·sico')  */
     elsif pCarac049 = 12383 then
        GRAVA_PREMIOSKIT1(PCALCULO=>pCalculo, PPRODUTO=>3, PCOBERTURA=>28,
                          PVALOR=>0 , PPREMIO=>pPr_VidrMes, PFRANQUIA=>0 , PTAXA=>0, PDESCRICAO=>'S/ cobertura' );
/*        AtualizarCoberturas(3, 28, 0, Pr_VidrMes, 0, 0, 'S/ cobertura'); */
     end if;
     LISTA_TAB1_2(PPRODUTO=>10 ,PTABELA=>19 ,PCHAVE1=>0, PCHAVE2=>0 ,PCHAVE3=>0 ,PCHAVE4=>0 ,PCHAVE5=>0,
                  PVALOR1=>vMVALOR1 ,PVALOR2=>vMVALOR2 ,PVALOR3=>vMVALOR3 ,PVALOR4=>vMVALOR4 ,PVALOR5=>vMVALOR5 );
/*     BuscaTabelas(19, 0, 0, 0, 0, 0); */
     if pMEstipulante = 4381 then
       vMQtdP := 10;
     else
       if pMDias < 365 then
         vMQtdP := vMValor1 - (vMValor1 - (pMDias / 30)) - 1;
       else
         vMQtdP := vMValor1;
       end if;
     end if;
     vMVMin := vMValor2;
     if ((pMEstipulante = 4381) or (pMEstipulante = 4353) or
         (pMEstipulante = 6928) or (pMEstipulante = 9019)) then
       DELETE FROM KIT_CALCULOPREMIOSCOB
            WHERE CALCULO = pCALCULO
              AND PRODUTO = 10;
     end if;
     if ((pModalidade = 'A') or (pModalidade = '' )) then
       APAGACALCULOPREMIOSKIT( PCALCULO=>pCalculo, PPRODUTO=>pProduto, PTIPOCOTACAO=>2 );
       /*------------------------------------- Grava PrÍmio e Formas de Pagamento do Valor Ajustado ---------- */
       vMPrLiq := pPr_Casco + pPr_Acess + pPr_RcfDM + pPr_RcfDP + pPr_App + pPr_DMO + pM_Dextr + pM_PrRes + pM_PrVidr;
       vMPrIof := vMPrLiq * 0.0738;
       vMPrTot := vMPrLiq + vMPrIof;
       /* COME«A A FAZER O CALCULO DO PREMIO */
       if (pTemCepGO = 0) then /* 0606k1 */
         APAGACALCULOPREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,PTIPOCOTACAO=>1);
       else
         if (pCODTABELA = 'R') then
           GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                          PCASCO=>0, PACESS=>0, PRCFDM=>0, PRCFDP=>0, PAPP=>0,  PDMO=>0 ,PDextr=>0,pRes=>0 ,PVidr=>0 ,
                          PLIQ=>0, PIOF=>0, PTOT=>0, PFRANQ=>0, PCOTAC=>1, AJUSTE=>0, TAXA=>0, DESCRICAO=>pDescricaoAjuste);
/*           AtualizaPremio(0, 0, 0, 0, 0,   0,0,0,0,   0, 0, 0, 0, 1, 0, 0, DescricaoAjuste)*/
         else
           GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                          PCASCO=>pPr_Casco, PACESS=>pPr_Acess, PRCFDM=>pPr_RcfDM, PRCFDP=>pPr_RcfDP, PAPP=>pPr_App,
                          PDMO=>pPr_DMO ,PDextr=>pM_Dextr,pRes=>pM_PrRes ,PVidr=>pM_PrVidr,
                          PLIQ=>vMPrLiq,PIOF=>vMPrIof,PTOT=>vMPrTot,PFRANQ=>pFranquia,PCOTAC=>1,AJUSTE=>pAjuste,TAXA=>pTaxa_at,DESCRICAO=>pDescricaoAjuste);
/*           AtualizaPremio(Pr_Casco, Pr_Acess, Pr_RcfDM, Pr_RcfDP, Pr_App, Pr_DMO, M_Dextr, M_PrRes,  M_PrVidr, MPrLiq, MPrIof, MPrTot, Franquia, 1, Ajuste, Taxa_at, DescricaoAjuste);*/

           vMParc := 1;
           while vMParc <= vMQtdP
           loop
              /*  Busca tabela vai trazer o valor de juros e quantidade de parcelas
                  baseado no valor passado como parametro */
              LISTA_TAB1_2(PPRODUTO=>10 ,PTABELA=>15 ,PCHAVE1=>vMParc, PCHAVE2=>0 ,PCHAVE3=>0 ,PCHAVE4=>0 ,PCHAVE5=>0,
                           PVALOR1=>vMVALOR1 ,PVALOR2=>vMVALOR2 ,PVALOR3=>vMVALOR3 ,PVALOR4=>vMVALOR4 ,PVALOR5=>vMVALOR5 );
/*               BuscaTabelas(15, Round(MParc), 0, 0, 0, 0); */
              vMJuros := vMValor1;
              /* REMOVER NO PROXIMO MES 0109K1                           */
              if vMVersao = 1 then
                vMVParc := ((vMPrLiq * vMValor1) * 1.0738) / vMParc;
              else
                vMVParc := ((vMPrLiq * vMValor3) * 1.0738) / vMParc;
              end if;
               if ((((pFINALVIGENCIA - pINICIOVIGENCIA) / 30)) < vMParc) then
                 if (vMParc = 1) then
                   GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                   PCOND=>1 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>vMVParc ,PDEMA=>0 );
 /*                      GravaParcela(1, MParc, 1, MVParc, 0) */
                 else
                   GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                   PCOND=>1 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>0 ,PDEMA=>0 );
 /*                      GravaParcela(1, MParc, 1, 0, 0) */
                 end if;
               elsif (vMVParc >= vMVMin) then
                 if (vMParc = 1) then
                   GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                   PCOND=>1 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>vMVParc ,PDEMA=>0 );
 /*                  GravaParcela(1, MParc, 1, MVParc, 0) */
                 else
                   GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                   PCOND=>1 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>vMVParc ,PDEMA=>vMVParc );
 /*                  GravaParcela(1, MParc, 1, MVParc, MVParc); */
                 end if;
               end if;
               if ((pCondicao2 = 2) or (pMEstipulante = 4381) or (pMEstipulante = 6928) or (pMEstipulante = 9019) or
                   (pMEstipulante = 4353)) then
                 if pMTPREL = 2 then
                   GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                   PCOND=>2 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>0 ,PDEMA=>0 );
 /*                  GravaParcela(2, MParc, 1, 0, 0) */
                 else
                  /* REMOVER NO PROXIMO MES 0109K1                           */
                   if vMVersao = 1 then
                     vMVParc := ((vMPrLiq * vMValor2) * 1.0738) / vMParc;
                   else
                     vMVParc := ((vMPrLiq * vMValor4) * 1.0738) / vMParc;
                   end if;

              if ((((pFINALVIGENCIA - pINICIOVIGENCIA) / 30) - 1) < vMParc) then
                     GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                     PCOND=>2 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>0 ,PDEMA=>0 );
 /*                    GravaParcela(2, MParc, 1, 0, 0) */
                   elsif (vMVParc >= vMVMin) then
                      if (vMParc = 1) then
                        GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                        PCOND=>2 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>vMVParc ,PDEMA=>0 );
 /*                       GravaParcela(2, MParc, 1, MVParc, 0) */
                      else
                        GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                        PCOND=>2 ,PPARC=>vMParc ,PTCOT=>1 ,PPRIM=>vMVParc ,PDEMA=>vMVParc );
 /*                       GravaParcela(2, MParc, 1, MVParc, MVParc); */
                      end if;
                   end if;
                 end if;
               end if;
/*             end if; */
             vMParc := vMParc + 1;
           end loop;
         end if;
       end if;
   /*------------------------------------- Grava PrÍmio e Formas de Pagamento do Valor Determinado ---------- */
     elsif (pModalidade='D') then
       APAGACALCULOPREMIOSKIT( PCALCULO=>pCalculo, PPRODUTO=>pProduto, PTIPOCOTACAO=>1);
/*       ApagaPremio(1); */
       vMPrLiq := pPr_cascomm + pPr_Acessmm + pPr_RcfDMmm + pPr_RcfDPmm + pPr_Appmm + pPr_DMOmm + pM_Dextr + pM_PrRes + pM_PrVidr;
       vMPrIof := vMPrLiq * 0.0738;
       vMPrTot := vMPrLiq + vMPrIof;
       if (pMDias > 366) then
        GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                       PCASCO=>0, PACESS=>0, PRCFDM=>0, PRCFDP=>0, PAPP=>0, PDMO=>0 ,PDextr=>0,pRes=>0 ,PVidr=>0,
                       PLIQ=>0,PIOF=>0,PTOT=>0,PFRANQ=>0,PCOTAC=>2,AJUSTE=>0,TAXA=>0,DESCRICAO=>'Valor Determinado N„o Permite seguros plurianual');
/*            AtualizaPremio(0, 0, 0, 0, 0,   0,0,0,0,   0, 0, 0, 0, 2, 0, 0, 'Valor Determinado N„o Permite seguros plurianual') */
       else
         GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                        PCASCO=>pPr_Cascomm, PACESS=>pPr_Acessmm, PRCFDM=>pPr_RcfDMmm, PRCFDP=>pPr_RcfDPmm, PAPP=>pPr_Appmm,
                        PDMO=>pPr_DMOmm ,PDextr=>pM_Dextr,pRes=>pM_PrRes ,PVidr=>pM_PrVidr,
                        PLIQ=>vMprLiq,PIOF=>vMPrIof,PTOT=>vMPrTot,PFRANQ=>pFranquia,PCOTAC=>2,AJUSTE=>pAjuste,TAXA=>pTaxa_at,DESCRICAO=>'Valor Determinado');
/*            AtualizaPremio(Pr_Cascomm, Pr_Acessmm, Pr_RcfDMmm, Pr_RcfDPmm, Pr_Appmm, Pr_DMOmm, M_Dextr, M_PrRes, M_PrVidr, MPrLiq, MPrIof, MPrTot, Franquia, 2, Ajuste, Taxa_at, 'Valor Determinado');*/
         vMParc := 1;
         while vMParc <= vMQtdP
         loop
           LISTA_TAB1_2(PPRODUTO=>10 ,PTABELA=>15 ,PCHAVE1=>vMParc, PCHAVE2=>0 ,PCHAVE3=>0 ,PCHAVE4=>0 ,PCHAVE5=>0,
                        PVALOR1=>vMVALOR1 ,PVALOR2=>vMVALOR2 ,PVALOR3=>vMVALOR3 ,PVALOR4=>vMVALOR4 ,PVALOR5=>vMVALOR5 );
/*              BuscaTabelas(15, Round(MParc), 0, 0, 0, 0); */
           vMJuros := vMValor1;
           /* REMOVER NO PROXIMO MES 0109K1                           */
            if vMVersao = 1 then
               vMVParc := ((vMPrLiq * vMValor1) * 1.0738) / vMParc;
            else
              vMVParc := ((vMPrLiq * vMValor3) * 1.0738) / vMParc;
            end if;

            if ((((pFINALVIGENCIA - pINICIOVIGENCIA) / 30)) < vMParc) then
              if (vMParc = 1) then
                GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                PCOND=>1 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>vMVParc ,PDEMA=>0 );
 /*                  GravaParcela(1, MParc, 2, MVParc, 0) */
              else
                GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                PCOND=>1 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>0 ,PDEMA=>0 );
 /*                  GravaParcela(1, MParc, 2, 0, 0) */
              end if;
            elsif (vMVParc >= vMVMin) then
              if (vMParc = 1) then
                GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                PCOND=>1 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>vMVParc ,PDEMA=>0 );
 /*                  GravaParcela(1, MParc, 2, MVParc, 0) */
              else
                GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                PCOND=>1 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>vMVParc ,PDEMA=>vMVParc );
 /*                  GravaParcela(1, MParc, 2, MVParc, MVParc); */
              end if;
            end if;
    /*  --------------------------------------- 1a. 30 dias --- */
            if ((pCondicao2 = 2) or
                (pMEstipulante = 4381) or (pMEstipulante = 6928) or (pMEstipulante = 9019) or (pMEstipulante = 4353)) then
              if (pMTPREL = 2) then
                GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                PCOND=>2 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>0 ,PDEMA=>0 );
 /*                    GravaParcela(2, MParc, 2, 0, 0) */
              else
                  /* REMOVER NO PROXIMO MES 0109K1                           */
                   if vMVersao = 1 then
                     vMVParc := ((vMPrLiq * vMValor2) * 1.0738) / vMParc;
                   else
                     vMVParc := ((vMPrLiq * vMValor4) * 1.0738) / vMParc;
                   end if;
                if ((((pFINALVIGENCIA - pINICIOVIGENCIA) / 30) - 1) < vMParc) then
                  GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                  PCOND=>2 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>0 ,PDEMA=>0 );
 /*                      GravaParcela(2, MParc, 2, 0, 0) */
                elsif (vMVParc >= vMVMin) then
                  if (vMParc = 1) then
                    GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                    PCOND=>2 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>vMVParc ,PDEMA=>0 );
 /*                      GravaParcela(2, MParc, 2, MVParc, 0) */
                  else
                    GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                                    PCOND=>2 ,PPARC=>vMParc ,PTCOT=>2 ,PPRIM=>vMVParc ,PDEMA=>vMVParc );
 /*                      GravaParcela(2, MParc, 2, MVParc, MVParc); */
                  end if;
                end if;
              end if;
            end if;
            vMParc := vMParc + 1;
/*          end if; */
         end loop;
       end if;
     end if;
   /* ------------------------------------ Grava PrÍmio e Forma de Pagamento do MÍs a MÍs --------------------- */
     if ((pModalidade = 'A') or (pModalidade = '')) then
       vMPrLiq := pPr_cascoMes + pPr_acessMes + pPr_rcfdmMes + pPr_rcfdpMes + pPr_appMes + pPr_dmoMes + pPr_DexMes + pPr_CarMes + pPr_VidrMes;
       vMPrIof := vMPrLiq * 0.0738;
       if (pTemCepGO = 0) then /* 0606K1 */
         APAGACALCULOPREMIOSKIT( PCALCULO=>pCalculo, PPRODUTO=>pProduto, PTIPOCOTACAO=>3);
/*          ApagaPremio(3); */
       else
           LISTA_TAB1_2(PPRODUTO=>10 ,PTABELA=>15 ,PCHAVE1=>12, PCHAVE2=>0 ,PCHAVE3=>0 ,PCHAVE4=>0 ,PCHAVE5=>0,
                        PVALOR1=>vMVALOR1 ,PVALOR2=>vMVALOR2 ,PVALOR3=>vMVALOR3 ,PVALOR4=>vMVALOR4 ,PVALOR5=>vMVALOR5 );
/*          BuscaTabelas(15, 12, 0, 0, 0, 0); */
          vMJuros := vMValor1;
          vMPrTot := ((vMPrLiq * vMValor1) * 1.0738) / 12;
          if (pCODTABELA = 'R') then
            GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                           PCASCO=>0, PACESS=>0, PRCFDM=>0, PRCFDP=>0, PAPP=>0,  PDMO=>0 ,PDextr=>0,pRes=>0 ,PVidr=>0 ,
                           PLIQ=>0, PIOF=>0, PTOT=>0, PFRANQ=>0, PCOTAC=>3, AJUSTE=>0, TAXA=>0, DESCRICAO=>pDescricaoAjuste);
/*            AtualizaPremio(0, 0, 0, 0, 0,  0,0,0,0,  0, 0, 0, 0, 3, 0, 0, DescricaoAjuste) */
          elsif ((pTIPO_COBERTURA = 3) or (pMDias < 365) or (pMDias > 366)) then
            GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                           PCASCO=>0, PACESS=>0, PRCFDM=>0, PRCFDP=>0, PAPP=>0,  PDMO=>0 ,PDextr=>0,pRes=>0 ,PVidr=>0 ,
                           PLIQ=>0, PIOF=>0, PTOT=>0, PFRANQ=>0, PCOTAC=>3, AJUSTE=>0, TAXA=>0, DESCRICAO=>'');
/*            AtualizaPremio(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, ''); */
            GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                            PCOND=>1 ,PPARC=>12 ,PTCOT=>3 ,PPRIM=>0 ,PDEMA=>0 );
/*            GravaParcela(1, 12, 3, 0, 0); */
          else
            GRAVA_PREMIOSKIT(PCALCULO=>pCalculo,PPRODUTO=>pProduto,
                           PCASCO=>pPr_CascoMes, PACESS=>pPr_AcessMes, PRCFDM=>pPr_RcfdmMes, PRCFDP=>pPr_RcfDPMes, PAPP=>pPr_AppMes,
                           PDMO=>pPr_dmoMes ,PDextr=>pPr_DexMes,pRes=>pPr_CarMes ,PVidr=>pPr_VidrMes,
                           PLIQ=>vMprLiq,PIOF=>vMPrIof,PTOT=>vMPrTot,PFRANQ=>pFranquia,PCOTAC=>3,AJUSTE=>pAjuste,TAXA=>pTaxa_at,DESCRICAO=>pDescricaoAjuste);
/*            AtualizaPremio(Pr_cascoMes, Pr_acessMes, Pr_rcfdmMes, Pr_rcfdpMes, Pr_appMes, Pr_dmoMes, Pr_DexMes, Pr_CarMes, Pr_VidrMes, MPrLiq, MPrIof, MPrTot, Franquia, 3, Ajuste, Taxa_at, DescricaoAjuste); */
            GRAVA_PARCELASKIT(PCALCULO=>pCALCULO ,PPRODUTO=>pPRODUTO ,
                            PCOND=>1 ,PPARC=>12 ,PTCOT=>3 ,PPRIM=>vMPrTot ,PDEMA=>vMPrTot );
/*            GravaParcela(1, 12, 3, MPrTot, MPrTot); */
          end if;
       end if;
     end if; /* modalidade */
  /* fim */
  end;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_COBERTURASOP1" 
( PCALCULO in MULT_CALCULO.CALCULO%Type,
  PITEM    in MULT_CALCULO.ITEM%Type,
  PPRODUTO in Mult_ProdutosCobPerOpc.PRODUTO%Type
)
IS
BEGIN
Insert into Mult_calculocobop
Select distinct Pcalculo as Calculo,PItem as Item, d1.Cobertura, 0 as Condutor, d2.Opcao, 'N' as Escolha, 0 as Valor
from Mult_CobPerDic d ,Mult_ProdutosCobPerOpc d2 , Mult_ProdutosCobPer d1
Where
     d.produto = Pproduto
     and d.Mostra = 'S'
     and d.Escolha = 'N'
     and d2.Produto = d.Produto
     and d2.cobertura = d.cobertura
     and d2.Opcao = d.Opcao
     and (d1.Tipo = 'M' or d1.Tipo = 'P' or d1.Tipo = 'C')
     and d1.cobertura = d.cobertura
     and d1.Produto = d.Produto
     and (d.Solicita = 'M' or d.Solicita = 'N');
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_COBERTURASPR1" 
( PCALCULO in MULT_CALCULO.CALCULO%Type,
  PITEM    in MULT_CALCULO.ITEM%Type,
  PPRODUTO  in Mult_ProdutosCobPerOpc.PRODUTO%Type
)
IS
BEGIN
  Insert into Mult_CalculoPremiosCob
  Select distinct Pcalculo as Calculo,Pitem as Item, d.produto, 1 AS TipoCotacao, d.Cobertura,  0 as Valor, 0 as Premio, 0 as franquia, '' as Descricao, 0 AS TAXA
  from Mult_CobPerDic d, Mult_ProdutosCobPer d1
    Where
      d.produto = PProduto and
      d.Mostra = 'S'and
      d.Escolha = 'N'and
      d.produto = d1.produto and
      d.Cobertura = d1.cobertura and
      (d1.Tipo = 'C' or d1.Tipo = 'A') ;
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_COBERTURAS1" 
( PCALCULO in MULT_CALCULO.CALCULO%Type,
  PITEM    in MULT_CALCULO.ITEM%Type,
  PPRODUTO  in Mult_ProdutosCobPerOpc.PRODUTO%Type
)
IS
BEGIN
Insert into Mult_calculocob
Select distinct Pcalculo as Calculo,
                Pitem as Item, d1.Cobertura, 0 as Condutor, d.Escolha, 0 as Valor,
                d2.Opcao as Opcao, '' as Observacao, d1.Tipo, 0 as Taxa, 0 as Franquia, 0 as Premio, d.solicita,
                d1.Pcondutor, d1.Scondutor, d1.DCondutor, d.Mostra, null
from Mult_CobPerDic d,
     Mult_ProdutosCobPerOpc d2,
     Mult_ProdutosCobPer d1
Where
     (d2.Produto(+) = d.Produto and
     d2.cobertura(+) = d.cobertura and
     d2.Preferida = 'S') and
     d.produto = Pproduto
     and d.Mostra = 'S'
     and d.Escolha = 'N'
     and (d1.Tipo = 'M' or d1.Tipo = 'P' or d1.Tipo = 'C')
     and d1.cobertura = d.cobertura
     and d1.Produto = d.Produto
     and (d.Solicita = 'M' or d.Solicita = 'U' or d.Solicita = 'T' or d.Solicita = 'O' or d.Solicita = 'C' or d.Solicita = 'V');
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_DIVISOES1" 
( PCalculo in Mult_CalculoDivisoes.Calculo%Type,
  PDivisao in Mult_CalculoDivisoes.Divisao%Type,
  PNivel   in Mult_CalculoDivisoes.Nivel%Type
)
IS
BEGIN
  Insert into Mult_CalculoDivisoes values (PCalculo,PDivisao,PNivel);
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_ESCOLHA1" 
( PCALCULO in Mult_CalculoCobOp.CALCULO%Type,
  PITEM in Mult_CalculoCobOp.ITEM%Type,
  PCOBERTURA in Mult_CalculoCobOp.COBERTURA%Type,
  POPCAO in Mult_CalculoCobOp.OPCAO%Type,
  PESCOLHA in Mult_CalculoCobOp.ESCOLHA%Type
)
IS
BEGIN
  Update Mult_CalculoCobOp set Escolha = PESCOLHA
  Where
    Calculo = PCALCULO And
    Item = PITEM And
    Condutor = 0 And
    Cobertura = PCOBERTURA And
    Opcao = POPCAO;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_MENSAGEM" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PITEM      MULT_CALCULO.ITEM%Type,
PMENSAGEM MULT_CALCULOPREMIOS.ERRORMESSAGE%Type
) IS
BEGIN
  UPDATE MULT_CALCULOPREMIOS SET ERRORMESSAGE = PMensagem
     WHERE CALCULO = PCALCULO
     AND ITEM    = PITEM;
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_OBSERVACAO1" 
( PCALCULO    in Mult_CalculoCob.CALCULO%Type,
  PITEM       in Mult_CalculoCob.ITEM%Type,
  PCOBERTURA  in Mult_CalculoCob.COBERTURA%Type,
  POBSERVACAO in Mult_CalculoCob.OBSERVACAO%Type
)
IS
BEGIN
    Update Mult_CalculoCob set OBSERVACAO = POBSERVACAO
      Where Calculo = Pcalculo and
            Item = Pitem and
            Condutor = 0 and
            Cobertura = Pcobertura;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_OPCAO1" 
( PCALCULO    in Mult_CalculoCob.CALCULO%Type,
  PITEM       in Mult_CalculoCob.ITEM%Type,
  PCOBERTURA  in Mult_CalculoCob.COBERTURA%Type,
  POPCAO      in Mult_CalculoCob.OPCAO%Type
)
IS
BEGIN
  Update Mult_CalculoCob set Opcao = Popcao
    Where Calculo = Pcalculo and
          Item = Pitem and
          Condutor = 0 and
          Cobertura = Pcobertura;

END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PARCELASKIT" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PPRODUTO      MULT_CALCULOCONDPAR.PRODUTO%Type,
PTCOT  MULT_CALCULOCONDPAR.TIPOCOTACAO%Type,
PCOND MULT_CALCULOCONDPAR.CONDICAO%Type,
PPARC  MULT_CALCULOCONDPAR.PARCELAS%Type,
PPRIM  MULT_CALCULOCONDPAR.VALOR_PRIMEIRA%Type,
PDEMA  MULT_CALCULOCONDPAR.VALOR_DEMAIS%Type
) IS
BEGIN
  DECLARE
       CCALCULO number(16);
       Cursor T_COND Is
       SELECT CALCULO FROM KIT_CALCULOCOND
          WHERE CALCULO = PCALCULO
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PTCot
          AND CONDICAO = PCond;
       Cursor T_COND2 Is
       SELECT CALCULO FROM KIT_CALCULOCONDPAR
          WHERE CALCULO  = PCALCULO
          AND PRODUTO  = PPRODUTO
          AND TIPOCOTACAO = PTCot
          AND CONDICAO    = PCond
          AND PARCELAS    = PParc;
  BEGIN
       Open T_COND;
       Fetch T_COND Into CCALCULO;
       if T_COND%Notfound Then
          INSERT INTO KIT_CALCULOCOND
          (CALCULO,PRODUTO,TIPOCOTACAO,CONDICAO,ESCOLHA)
          VALUES (PCALCULO, PPRODUTO, PTCot, PCond, 'N');
       end if;
       Close T_COND;
       Open T_COND2;
       Fetch T_COND2 Into CCALCULO;
       if T_COND2%Notfound Then
          INSERT INTO KIT_CALCULOCONDPAR (CALCULO,PRODUTO,TIPOCOTACAO,CONDICAO,
          PARCELAS,VALOR_PRIMEIRA,VALOR_DEMAIS,ESCOLHA)
          VALUES (PCALCULO,PPRODUTO,PTCot,PCond,PParc,PPrim,PDema,'N');
       else
          UPDATE KIT_CALCULOCONDPAR
          SET VALOR_PRIMEIRA= PPrim,
              VALOR_DEMAIS  = PDema
          WHERE CALCULO       = PCALCULO
              AND PRODUTO       = PPRODUTO
              AND TIPOCOTACAO   = PTCot
              AND CONDICAO      = PCond
              AND PARCELAS      = PParc;
       end if;
       Close T_COND2;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PARCELAS1" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PITEM      MULT_CALCULO.ITEM%Type,
PPRODUTO      MULT_CALCULOCONDPAR.PRODUTO%Type,
PTCOT  MULT_CALCULOCONDPAR.TIPOCOTACAO%Type,
PCOND MULT_CALCULOCONDPAR.CONDICAO%Type,
Pparc  Mult_Calculocondpar.Parcelas%Type,
PPRIM  MULT_CALCULOCONDPAR.VALOR_PRIMEIRA%Type,
Pdema  Mult_Calculocondpar.Valor_Demais%Type,
PIOF  MULT_CALCULOCONDPAR.IOF%Type,
PFPGTO MULT_CALCULOCONDPAR.FORMA_PAGAMENTO%Type,
PVSJUROS MULT_CALCULOCONDPAR.VALOR_SEM_JUROS%Type,
PPJUROS MULT_CALCULOCONDPAR.PERC_JUROS%Type,
PVCJUROS MULT_CALCULOCONDPAR.VALOR_COM_JUROS%Type
) IS
BEGIN
  DECLARE
       CCALCULO number(16);
       Cursor T_COND Is
       SELECT CALCULO FROM MULT_CALCULOCOND
          WHERE CALCULO = PCALCULO
          AND ITEM    = PITEM
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PTCot
          AND CONDICAO = PCond;
       Cursor T_COND2 Is
       SELECT CALCULO FROM MULT_CALCULOCONDPAR
          WHERE CALCULO   = PCALCULO
          AND ITEM        = PITEM
          AND PRODUTO     = PPRODUTO
          AND TIPOCOTACAO = PTCot
          AND CONDICAO    = PCond
          AND PARCELAS    = PParc
          AND FORMA_PAGAMENTO = PFPGTO;
  BEGIN
       Open T_Cond;
       Dbms_Output.Enable( 1000000 );
       Dbms_Output.Put_Line('PVSJUROS '||PVSJUROS);
       Fetch T_Cond Into Ccalculo;

       if T_COND%Notfound Then
          INSERT INTO MULT_CALCULOCOND
          (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,CONDICAO,ESCOLHA)
          VALUES (PCALCULO, PITEM, PPRODUTO, PTCot, PCond, 'N');
       end if;
       Close T_COND;
       Open T_COND2;
       Fetch T_COND2 Into CCALCULO;
       If T_Cond2%Notfound Then
          Insert Into Mult_Calculocondpar (Calculo,Item,Produto,Tipocotacao,Condicao,
          Parcelas,Valor_Primeira,Valor_Demais,Escolha, Iof, Forma_Pagamento, valor_sem_juros, perc_juros, valor_com_juros )
          Values (Pcalculo,Pitem,Pproduto,Ptcot,Pcond,Pparc,Pprim,Pdema,'N', Piof, Pfpgto, PVSJUROS, PPJUROS, PVCJUROS);
       else
          UPDATE MULT_CALCULOCONDPAR
          SET VALOR_PRIMEIRA   = PPrim,
              Valor_Demais     = Pdema,
              IOF              = PIOF,
              VALOR_SEM_JUROS  = PVSJUROS,
              PERC_JUROS       = PPJUROS,
              VALOR_COM_JUROS  = PVCJUROS
          WHERE CALCULO           = PCALCULO
              AND ITEM            = PITEM
              And Produto         = Pproduto
              AND TIPOCOTACAO     = PTCot
              And Condicao        = Pcond
              And Parcelas        = Pparc
              And FORMA_PAGAMENTO = PFPGTO;
       end if;
       Close T_COND2;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PARCELAS2" 
( PCALCULO in Mult_CALCULOCONDPAR.CALCULO%Type
)
IS
BEGIN
  Update Mult_CALCULOCONDPAR set Valor_Primeira = 0, Valor_Demais = 0, Escolha = 'N'
    where Calculo = PCalculo;

END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PREMIOSCOB1" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PITEM      MULT_CALCULO.ITEM%Type,
PPRODUTO      MULT_CALCULOPREMIOSCOB.PRODUTO%Type,
PCOBERTURA MULT_CALCULOPREMIOSCOB.COBERTURA%Type,
PVALOR MULT_CALCULOPREMIOSCOB.VALOR%Type,
PPREMIO  MULT_CALCULOPREMIOSCOB.PREMIO%Type,
PFRANQUIA  MULT_CALCULOPREMIOSCOB.FRANQUIA%Type,
PTAXA  MULT_CALCULOPREMIOSCOB.TAXA%Type,
PDESCRICAO MULT_CALCULOPREMIOSCOB.DESCRICAO%Type
) IS
BEGIN
  DECLARE
       CCALCULO number(18,6);
       Cursor T_COND Is
       SELECT cALCULO FROM MULT_CALCULOPREMIOSCOB where CALCULO = PCALCULO
           AND ITEM = PITEM
           AND PRODUTO = PPRODUTO
           AND COBERTURA  = PCOBERTURA;
  BEGIN
       Open T_COND;
       Fetch T_COND Into CCALCULO;
       if T_COND%Notfound Then
          INSERT INTO MULT_CALCULOPREMIOSCOB (CALCULO,ITEM,PRODUTO,TIPOCOTACAO, COBERTURA,VALOR,PREMIO,FRANQUIA,DESCRICAO,TAXA) VALUES
          (pcalculo,pitem,pproduto,1, pCobertura,pValor,pPremio,pFranquia,pDescricao,pTaxa);
       else
          UPDATE MULT_CALCULOPREMIOSCOB
            SET VALOR = pValor,
                PREMIO = pPremio,
                FRANQUIA = pFranquia,
                TAXA = pTaxa,
                DESCRICAO = pdescricao
            WHERE CALCULO   = pcalculo
                AND ITEM      = pitem
                AND PRODUTO = pproduto
                AND COBERTURA = pcobertura;
          if pTaxa <> 0 then
            UPDATE MULT_CALCULOCOB
              SET  TAXA = pTaxa
              WhERE CALCULO   = pCALCULO
                AND ITEM      = pITEM
                AND COBERTURA = pCOBERTURA;
          end if;
       end if;
       Close T_COND;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PREMIOSCOB3" 
( PCALCULO  in Mult_CalculoPremios.CALCULO%Type,
  PITEM     in Mult_CalculoPremios.ITEM%Type,
  PPRODUTO  in Mult_CalculoPremios.PRODUTO%Type,
  PTIPO1    in Mult_CalculoPremios.TipoCotacao%Type,
  PTIPO2    in Mult_CalculoPremios.TipoCotacao%Type
)
IS
BEGIN
  Insert into Mult_CalculoPremios (Calculo,Item,Produto,TipoCotacao,Escolha,Cod_Tabela)
   Values (PCALCULO,PITEM,PPRODUTO,PTIPO1,'N',PTIPO2);

END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PREMIOSKIT" 
(
PCALCULO  MULT_CALCULO.CALCULO%Type,
PPRODUTO  MULT_CALCULOPREMIOS.PRODUTO%Type,

PCOTAC    MULT_CALCULOPREMIOS.TIPOCOTACAO%Type,
PCASCO    MULT_CALCULOPREMIOS.PREMIO_CASCO%Type,
PACESS    MULT_CALCULOPREMIOS.PREMIO_ACESSORIOS%Type,
PRCFDM    MULT_CALCULOPREMIOS.PREMIO_DM%Type,
PRCFDP    MULT_CALCULOPREMIOS.PREMIO_DP%Type,
PAPP      MULT_CALCULOPREMIOS.PREMIO_APP%Type,

PDMO      NUMBER,
PDextr    NUMBER,
PRes      NUMBER,
PVidr     NUMBER,

PLIQ      MULT_CALCULOPREMIOS.PREMIO_LIQUIDO%Type,
PIOF      MULT_CALCULOPREMIOS.PREMIO_IOF%Type,
PTOT      MULT_CALCULOPREMIOS.PREMIO_TOTAL%Type,
PFRANQ    MULT_CALCULOPREMIOS.FRANQUIAAUTO%Type,
AJUSTE    MULT_CALCULOPREMIOS.AJUSTE%Type,
TAXA      MULT_CALCULOPREMIOS.DESCONTOCOMISSAO%Type,
DESCRICAO MULT_CALCULOPREMIOS.OBSERVACAO%Type
) IS
BEGIN
  DECLARE
       CCALCULO number(16);
       MAPP     number(18,6);
       MRCF     number(18,6);
       MOUT     number(18,6);
       Cursor T_COND Is
          SELECT CALCULO FROM KIT_CALCULOPREMIOS
          WHERE CALCULO = PCALCULO
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PCotac;
  BEGIN

       MRcf := PRcfDM + PRcfDP;
       MApp := PApp / 2;
       MOut := PDMO + PDextr + PRes + PVidr;

       Open T_COND;
       Fetch T_COND Into CCALCULO;
       if T_COND%Notfound Then
          INSERT INTO KIT_CALCULOPREMIOS
          (CALCULO,PRODUTO,TIPOCOTACAO,ESCOLHA,COD_TABELA,PREMIO_CASCO,
          PREMIO_ACESSORIOS,PREMIO_AUTO,PREMIO_DM,PREMIO_DP,PREMIO_APP_MORTE,
          PREMIO_APP_INVALIDEZ,PREMIO_APP,PREMIO_RCF,PREMIO_OUTROS,
          PREMIO_LIQUIDO,PREMIO_IOF,PREMIO_TOTAL,FRANQUIAAUTO,AJUSTE,DESCONTOCOMISSAO,OBSERVACAO)
          VALUES (Pcalculo,PPRODUTO,PCotac,'N',9,PCasco,PAcess,PCasco,PRcfDM,PRcfDP,MApp,MApp,
                  PApp,MRcf,MOut,PLiq,PIof,PTot,PFranq,Ajuste,taxa,Descricao);

       else
          UPDATE KIT_CALCULOPREMIOS
          SET PREMIO_CASCO      = PCasco,
          PREMIO_ACESSORIOS = PAcess,
          PREMIO_AUTO       = PCasco,
          PREMIO_DM         = PRcfDM,
          PREMIO_DP         = PRcfDP,
          PREMIO_APP_MORTE     = MApp,
          PREMIO_APP_INVALIDEZ = MApp,
          PREMIO_APP        = PApp,
          PREMIO_RCF        = MRcf,
          PREMIO_OUTROS     = MOut,
          PREMIO_LIQUIDO    = PLiq,
          PREMIO_IOF        = PIof,
          PREMIO_TOTAL      = PTot,
          FRANQUIAAUTO      = PFranq,
          AJUSTE            = Ajuste,
          DESCONTOCOMISSAO  = Taxa,
          OBSERVACAO        = Descricao
          WHERE CALCULO = PCALCULO
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PCotac;
       end if;
       Close T_COND;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PREMIOSKIT1" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PPRODUTO      MULT_CALCULOPREMIOSCOB.PRODUTO%Type,
PCOBERTURA MULT_CALCULOPREMIOSCOB.COBERTURA%Type,
PVALOR MULT_CALCULOPREMIOSCOB.VALOR%Type,
PPREMIO  MULT_CALCULOPREMIOSCOB.PREMIO%Type,
PFRANQUIA  MULT_CALCULOPREMIOSCOB.FRANQUIA%Type,
PTAXA  MULT_CALCULOPREMIOSCOB.TAXA%Type,
PDESCRICAO MULT_CALCULOPREMIOSCOB.DESCRICAO%Type
) IS
BEGIN
  DECLARE
       CCALCULO number(18,6);
       Cursor T_COND Is
       SELECT cALCULO FROM kit_CALCULOPREMIOSCOB where CALCULO = PCALCULO
           AND PRODUTO = PPRODUTO
           AND COBERTURA  = PCOBERTURA;
  BEGIN
       Open T_COND;
       Fetch T_COND Into CCALCULO;
       if T_COND%Notfound Then
          INSERT INTO kit_CALCULOPREMIOSCOB (CALCULO,PRODUTO,COBERTURA,VALOR,PREMIO,FRANQUIA,DESCRICAO,TAXA) VALUES
          (pcalculo,pproduto,pCobertura,pValor,pPremio,pFranquia,pDescricao,pTaxa);
       else
          UPDATE kit_CALCULOPREMIOSCOB
            SET VALOR = pValor,
                PREMIO = pPremio,
                FRANQUIA = pFranquia,
                TAXA = pTaxa,
                DESCRICAO = pdescricao
            WHERE CALCULO   = pcalculo
                AND PRODUTO = pproduto
                AND COBERTURA = pcobertura;
       end if;
       Close T_COND;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PREMIOS1" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PITEM      MULT_CALCULO.ITEM%Type,
PPRODUTO      MULT_CALCULOPREMIOS.PRODUTO%Type,
PCOTAC MULT_CALCULOPREMIOS.TIPOCOTACAO%Type,
PCASCO MULT_CALCULOPREMIOS.PREMIO_CASCO%Type,
PACESS MULT_CALCULOPREMIOS.PREMIO_ACESSORIOS%Type,
PRCFDM MULT_CALCULOPREMIOS.PREMIO_DM%Type,
PRCFDP MULT_CALCULOPREMIOS.PREMIO_DP%Type,
MAPP MULT_CALCULOPREMIOS.PREMIO_APP_MORTE%Type,
PAPP MULT_CALCULOPREMIOS.PREMIO_APP%Type,
MRCF MULT_CALCULOPREMIOS.PREMIO_RCF%Type,
MOUT MULT_CALCULOPREMIOS.PREMIO_OUTROS%Type,
PLIQ MULT_CALCULOPREMIOS.PREMIO_LIQUIDO%Type,
PIOF MULT_CALCULOPREMIOS.PREMIO_IOF%Type,
PTOT MULT_CALCULOPREMIOS.PREMIO_TOTAL%Type,
PFRANQ MULT_CALCULOPREMIOS.FRANQUIAAUTO%Type,
AJUSTE MULT_CALCULOPREMIOS.AJUSTE%Type,
TAXA MULT_CALCULOPREMIOS.DESCONTOCOMISSAO%Type,
DESCRICAO MULT_CALCULOPREMIOS.OBSERVACAO%Type) IS
BEGIN
  DECLARE
       CCALCULO number(16);
       Cursor T_COND Is
          SELECT CALCULO FROM MULT_CALCULOPREMIOS
          WHERE CALCULO = PCALCULO
          AND ITEM    = PITEM
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PCotac;
  BEGIN
       Open T_COND;
       Fetch T_COND Into CCALCULO;
       if T_COND%Notfound Then
          INSERT INTO MULT_CALCULOPREMIOS
          (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,ESCOLHA,COD_TABELA,PREMIO_CASCO,
          PREMIO_ACESSORIOS,PREMIO_AUTO,PREMIO_DM,PREMIO_DP,PREMIO_APP_MORTE,
          PREMIO_APP_INVALIDEZ,PREMIO_APP,PREMIO_RCF,PREMIO_OUTROS,
          PREMIO_LIQUIDO,PREMIO_IOF,PREMIO_TOTAL,FRANQUIAAUTO,AJUSTE,DESCONTOCOMISSAO,OBSERVACAO)
          VALUES (Pcalculo,Pitem,PPRODUTO,PCotac,'N',9,PCasco,PAcess,PCasco,PRcfDM,PRcfDP,MApp,MApp,
                  PApp,MRcf,MOut,PLiq,PIof,PTot,PFranq,Ajuste,taxa,Descricao);

       else
          UPDATE MULT_CALCULOPREMIOS
          SET PREMIO_CASCO      = PCasco,
          PREMIO_ACESSORIOS = PAcess,
          PREMIO_AUTO       = PCasco,
          PREMIO_DM         = PRcfDM,
          PREMIO_DP         = PRcfDP,
          PREMIO_APP_MORTE     = MApp,
          PREMIO_APP_INVALIDEZ = MApp,
          PREMIO_APP        = PApp,
          PREMIO_RCF        = MRcf,
          PREMIO_OUTROS     = MOut,
          PREMIO_LIQUIDO    = PLiq,
          PREMIO_IOF        = PIof,
          PREMIO_TOTAL      = PTot,
          FRANQUIAAUTO      = PFranq,
          AJUSTE            = Ajuste,
          DESCONTOCOMISSAO  = Taxa,
          OBSERVACAO        = Descricao
          WHERE CALCULO = PCALCULO
          AND ITEM    = PITEM
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PCotac;
       end if;
       Close T_COND;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_PREMIOS2" 
(
PCALCULO  MULT_CALCULO.CALCULO%Type,
PITEM     MULT_CALCULO.ITEM%Type,
PPRODUTO  MULT_CALCULOPREMIOS.PRODUTO%Type,

PCOTAC    MULT_CALCULOPREMIOS.TIPOCOTACAO%Type,
PCASCO    MULT_CALCULOPREMIOS.PREMIO_CASCO%Type,
PACESS    MULT_CALCULOPREMIOS.PREMIO_ACESSORIOS%Type,
PRCFDM    MULT_CALCULOPREMIOS.PREMIO_DM%Type,
PRCFDP    MULT_CALCULOPREMIOS.PREMIO_DP%Type,
PAPP      MULT_CALCULOPREMIOS.PREMIO_APP%Type,

PDMO      NUMBER,
PDextr    NUMBER,
PRes      NUMBER,
PVidr     NUMBER,

PLIQ      MULT_CALCULOPREMIOS.PREMIO_LIQUIDO%Type,
PIOF      MULT_CALCULOPREMIOS.PREMIO_IOF%Type,
PTOT      MULT_CALCULOPREMIOS.PREMIO_TOTAL%Type,
PFRANQ    MULT_CALCULOPREMIOS.FRANQUIAAUTO%Type,
AJUSTE    MULT_CALCULOPREMIOS.AJUSTE%Type,
TAXA      MULT_CALCULOPREMIOS.DESCONTOCOMISSAO%Type,
DESCRICAO MULT_CALCULOPREMIOS.OBSERVACAO%Type
) IS
BEGIN
  DECLARE
       CCALCULO number(16);
       MAPP     number(18,6);
       MRCF     number(18,6);
       MOUT     number(18,6);
       Cursor T_COND Is
          SELECT CALCULO FROM MULT_CALCULOPREMIOS
          WHERE CALCULO = PCALCULO
          AND ITEM    = PITEM
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PCotac;
  BEGIN

       MRcf := PRcfDM + PRcfDP;
       MApp := PApp / 2;
       MOut := PDMO + PDextr + PRes + PVidr;

       Open T_COND;
       Fetch T_COND Into CCALCULO;
       if T_COND%Notfound Then
          INSERT INTO MULT_CALCULOPREMIOS
          (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,ESCOLHA,COD_TABELA,PREMIO_CASCO,
          PREMIO_ACESSORIOS,PREMIO_AUTO,PREMIO_DM,PREMIO_DP,PREMIO_APP_MORTE,
          PREMIO_APP_INVALIDEZ,PREMIO_APP,PREMIO_RCF,PREMIO_OUTROS,
          PREMIO_LIQUIDO,PREMIO_IOF,PREMIO_TOTAL,FRANQUIAAUTO,AJUSTE,DESCONTOCOMISSAO,OBSERVACAO)
          VALUES (Pcalculo,Pitem,PPRODUTO,PCotac,'N',9,PCasco,PAcess,PCasco,PRcfDM,PRcfDP,MApp,MApp,
                  PApp,MRcf,MOut,PLiq,PIof,PTot,PFranq,Ajuste,taxa,Descricao);

       else
          UPDATE MULT_CALCULOPREMIOS
          SET PREMIO_CASCO      = PCasco,
          PREMIO_ACESSORIOS = PAcess,
          PREMIO_AUTO       = PCasco,
          PREMIO_DM         = PRcfDM,
          PREMIO_DP         = PRcfDP,
          PREMIO_APP_MORTE     = MApp,
          PREMIO_APP_INVALIDEZ = MApp,
          PREMIO_APP        = PApp,
          PREMIO_RCF        = MRcf,
          PREMIO_OUTROS     = MOut,
          PREMIO_LIQUIDO    = PLiq,
          PREMIO_IOF        = PIof,
          PREMIO_TOTAL      = PTot,
          FRANQUIAAUTO      = PFranq,
          AJUSTE            = Ajuste,
          DESCONTOCOMISSAO  = Taxa,
          OBSERVACAO        = Descricao
          WHERE CALCULO = PCALCULO
          AND ITEM    = PITEM
          AND PRODUTO = PPRODUTO
          AND TIPOCOTACAO = PCotac;
       end if;
       Close T_COND;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_QBR2" 
( PCALCULO    in Mult_calculoQbr.CALCULO%Type,
  PITEM       in Mult_calculoQbr.ITEM%Type
)
IS
BEGIN
  Update Mult_calculoQbr set valida = 'N'
  where
    calculo = PCalculo and Item = PItem;
END;
/


CREATE OR REPLACE PROCEDURE "GRAVA_QBR3" 
(
  PCALCULO  in Mult_calculoQbr.CALCULO%Type,
  PITEM in Mult_calculoQbr.ITEM%Type,
  PQUESTAO in Mult_calculoQbr.QUESTAO%Type,
  PDESCRICAO in Mult_calculoQbr.DESCRICAO%Type,
  PORDEM in Mult_calculoQbr.ORDEM%Type,
  PTIPO in Mult_calculoQbr.TIPO%Type)
IS
begin
  DECLARE
    Cob number(18);
    Cursor T_qbr Is
       Select Questao from  Mult_calculoQbr where
           calculo = PCalculo
           and Item = PItem
           and Questao = PQuestao;

  BEGIN
  cob := 0;
  Open T_qbr;
  Fetch T_qbr Into cob;
  Close T_qbr;
  if (cob > 0) then
   Update Mult_calculoQbr set valida = 'S' where
      calculo = PCalculo
      and Item = PItem
      and Questao = PQuestao;
  else
     Insert into Mult_calculoQbr (Calculo, Item, Questao, Descricao, Resposta, DescricaoResposta,
 SubResposta, DescricaoSubResposta,
	AgrupamentoRegiaoQBR, Valida, Imprime, PercImpressao, Ordem, Tipo, SubResposta2,
	DescricaoSubResposta2, Resposta2, DescricaoResposta2) values
      (PCalculo,PItem,PQuestao,PDescricao,
           0,'',0,'',0,'S',0,0,PORDEM,PTIPO ,0,'',0,'');
  end IF;
  END;
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_SITUACAO2" 
(
  PCALCULO  in Mult_Calculo.CALCULO%Type,
  PSITUACAO in Mult_calculo.SITUACAO%Type
)
IS
begin
Update Mult_Calculo set Situacao = PSituacao
where Calculo = PCalculo;
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_TIPODOCUMENTO2" (
    PCALCULO in Mult_Calculo.CALCULO%Type,
    PTIPO in Mult_Calculo.TipoDocumento%Type)

IS
begin
  Update Mult_Calculo set TipoDocumento = PTipo
    where Calculo = PCalculo;
end;
/


CREATE OR REPLACE PROCEDURE "GRAVA_VALOR1" 
(
    PCALCULO IN Mult_CalculoCob.CALCULO%Type,
    PITEM IN Mult_CalculoCob.ITEM%Type,
    PCOBERTURA IN Mult_CalculoCob.COBERTURA%Type,
    PVALOR IN Mult_CalculoCob.VALOR%Type)
IS
begin
  Update Mult_CalculoCob set VALOR = PVALOR
   Where Calculo = Pcalculo
    And Item = Pitem
    And Condutor = 0
    And Cobertura = Pcobertura;
end;
/


CREATE OR REPLACE PROCEDURE "KIT_GRAVAPAGINA3" (
PCALCULO      KIT_CALCULO.CALCULO%Type,
PTIPO_COBERTURA      KIT_CALCULO.TIPO_COBERTURA%Type,
PVALORVEICULO        KIT_CALCULO.VALORVEICULO%Type,
PAJUSTE       KIT_CALCULO.AJUSTE%Type,
PNIVELDM       KIT_CALCULO.NIVELDM%Type,
PNIVELDP       KIT_CALCULO.NIVELDP%Type,
PVALORAPPDMH        KIT_CALCULO.VALORAPPDMH%Type,
PVALORAPPMORTE       KIT_CALCULO.VALORAPPMORTE%Type,
PCB000054       KIT_CALCULO.AJUSTE%Type,
PCB000945       KIT_CALCULO.AJUSTE%Type,
PCB000979       KIT_CALCULO.AJUSTE%Type,
PCB000040       KIT_CALCULO.AJUSTE%Type,
PTEMASSISTENCIA  KIT_CALCULO.TEMASSISTENCIA%Type,
PACE0092       KIT_CALCULO.AJUSTE%Type,
PACE0093       KIT_CALCULO.AJUSTE%Type,
PACE0098       KIT_CALCULO.AJUSTE%Type,
PACE1026       KIT_CALCULO.AJUSTE%Type,
PACE1027       KIT_CALCULO.AJUSTE%Type,
PACE1028       KIT_CALCULO.AJUSTE%Type,
PACE1029       KIT_CALCULO.AJUSTE%Type) IS
BEGIN
   DECLARE
       PAcessorio number(16,6);
       Cursor T_ACE Is
   		   Select Acessorio from kit_calculoAces where calculo = PCalculo;
   BEGIN
   Update kit_calculo set TIPO_COBERTURA = PTIPO_COBERTURA,
                           VALORVEICULO = PVALORVEICULO,
			   AJUSTE = PAJUSTE,
			   NIVELDM = PNIVELDM,
			   NIVELDP = PNIVELDP,
			   VALORAPPDMH = PVALORAPPDMH,
			   VALORAPPMORTE = PVALORAPPMORTE,
               OPCAODESPESAS = PCB000054,
               OPCAOCARRORESERVA = PCB000945,
               TEMACESSORIOS =  PCB000979,
               TEMASSISTENCIA = PTEMASSISTENCIA,
               OPCAOVIDROS = PCB000040
   where calculo = PCalculo;
   Open T_ACE;
   Fetch T_ACE Into PAcessorio;
   if T_ACE%Notfound Then
      if Pace0092 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,92,'',92,0,Pace0092,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,92,'',0,0,0,0);
	  end if;
      if Pace0093 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,93,'',93,0,Pace0093,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,93,'',0,0,0,0);
	  end if;
      if Pace0098 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,98,'',98,0,Pace0098,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,98,'',0,0,0,0);
	  end if;
      if Pace1026 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,1026,'',1026,0,Pace1026,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,1026,'',0,0,0,0);
	  end if;
      if Pace1027 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,1027,'',1027,0,Pace1027,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,1027,'',0,0,0,0);
	  end if;
      if Pace1028 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,1028,'',1028,0,Pace1028,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,1028,'',0,0,0,0);
	  end if;
      if Pace1029 <> 0 then
         Insert into KIT_CALCULOAces values (PCalculo,1029,'',1029,0,Pace1029,0);
	  else
         Insert into KIT_CALCULOAces values (PCalculo,1029,'',0,0,0,0);
	  end if;
   else
      if Pace0092 <> 0 then
         Update KIT_CALCULOAces set valor = Pace0092, tipo = 92 where calculo = PCalculo and acessorio = 92;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 92;
	  end if;
      if Pace0093 <> 0 then
         Update KIT_CALCULOAces set valor = Pace0093, tipo = 93 where calculo = PCalculo and acessorio = 93;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 93;
	  end if;
      if Pace0098 <> 0 then
         Update KIT_CALCULOAces set valor = Pace0098, tipo = 98 where calculo = PCalculo and acessorio = 98;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 98;
	  end if;
      if Pace1026 <> 0 then
         Update KIT_CALCULOAces set valor = Pace1026, tipo = 1026 where calculo = PCalculo and acessorio = 1026;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1026;
	  end if;
      if Pace1027 <> 0 then
         Update KIT_CALCULOAces set valor = Pace1027, tipo = 1027 where calculo = PCalculo and acessorio = 1027;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1027;
	  end if;
      if Pace1028 <> 0 then
         Update KIT_CALCULOAces set valor = Pace1028, tipo = 1028 where calculo = PCalculo and acessorio = 1028;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1028;
	  end if;
      if Pace1029 <> 0 then
         Update KIT_CALCULOAces set valor = Pace1029, tipo = 1029 where calculo = PCalculo and acessorio = 1029;
	  else
         Update KIT_CALCULOAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1029;
	  end if;
   end if;
   Close T_ACE;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "KIT_GRAVAPAGINA7" (
PCALCULO      KIT_CALCULO.CALCULO%Type,
PNOME      KIT_CALCULO.NOME%Type,
PCGC_CPF        KIT_CALCULO.CGC_CPF%Type,
PDDDTELEFONE       KIT_CALCULO.DDDTELEFONE%Type,
PTELEFONE       KIT_CALCULO.TELEFONE%Type,
PHORATELEFONE       KIT_CALCULO.HORATELEFONE%Type,
PDDDCELULAR       KIT_CALCULO.DDDCELULAR%Type,
PCELULAR       KIT_CALCULO.CELULAR%Type,
PHORACELULAR       KIT_CALCULO.HORACELULAR%Type,
PDDDTELCOMERCIAL       KIT_CALCULO.DDDTELCOMERCIAL%Type,
PTELCOMERCIAL       KIT_CALCULO.TELCOMERCIAL%Type,
PHORATELCOMERCIAL       KIT_CALCULO.HORATELCOMERCIAL%Type,
PRAMALCOMERCIAL       KIT_CALCULO.RAMALCOMERCIAL%Type,
PDDDFAX     KIT_CALCULO.DDDFAX%Type,
PFAX     KIT_CALCULO.FAX%Type,
PHORAFAX     KIT_CALCULO.HORAFAX%Type,
PEMAIL       KIT_CALCULO.EMAIL%Type,
PAUTORIZAEMAIL    KIT_CALCULO.AUTORIZAEMAIL%Type,
PNOMECONDU     KIT_CALCULO.NOMECONDU%Type,
PCPFCONDU     KIT_CALCULO.CPFCONDU%Type,
PCNHCONDU     KIT_CALCULO.CNHCONDU%Type,
PESTADOCORRETOR     KIT_CALCULO.ESTADOCORRETOR%Type,
PCIDADECORRETOR     KIT_CALCULO.CIDADECORRETOR%Type,
PCORRETOR     KIT_CALCULO.CORRETOR%Type) IS
BEGIN
   Update KIT_calculo set NOME = PNOME,
                           CGC_CPF = PCGC_CPF,
                           DDDTELEFONE = PDDDTELEFONE,
                           TELEFONE = PTELEFONE,
                           HORATELEFONE = PHORATELEFONE,
                           DDDCELULAR = PDDDCELULAR,
                           CELULAR = PCELULAR,
                           HORACELULAR = PHORACELULAR,
                           DDDTELCOMERCIAL = PDDDTELCOMERCIAL,
                           TELCOMERCIAL = PTELCOMERCIAL,
                           HORATELCOMERCIAL = PHORATELCOMERCIAL,
                           RAMALCOMERCIAL = PRAMALCOMERCIAL,
                           DDDFAX = PDDDFAX,
                           FAX = PFAX,
                           HORAFAX = PHORAFAX,
                           EMAIL = PEMAIL,
                           AUTORIZAEMAIL = PAUTORIZAEMAIL,
                           NOMECONDU = PNOMECONDU,
                           CPFCONDU = PCPFCONDU,
                           CNHCONDU = PCNHCONDU,
                           ESTADOCORRETOR = PESTADOCORRETOR,
                           CIDADECORRETOR = PCIDADECORRETOR,
						   CORRETOR = PCORRETOR
   where calculo = PCalculo;
END;
/


CREATE OR REPLACE PROCEDURE "KIT_GRAVAPAGINA9" (
PCALCULO      kit_CALCULO.CALCULO%Type,
PTIPO_FRANQUIA      kit_CALCULO.TIPO_FRANQUIA%Type,
PPRODUTO      kit_CALCULOCONDPAR.PRODUTO%Type,
PTIPOCOTACAO      kit_CALCULOCONDPAR.TIPOCOTACAO%Type,
PCONDICAO      kit_CALCULOCONDPAR.CONDICAO%Type,
PPARCELAS      kit_CALCULOCONDPAR.PARCELAS%Type) IS
BEGIN
   Update kit_calculo set TIPO_FRANQUIA = PTIPO_FRANQUIA
   where calculo = PCalculo;
   if PProduto <> 0 then
      Update kit_CalculoPremios set Escolha = 'N'
      Where Calculo = PCALCULO;
      Update kit_CalculoPremios set Escolha = 'S'
      Where Calculo = PCALCULO
      and Produto = PPRODUTO
      and TipoCotacao = PTIPOCOTACAO;
      Update kit_CalculoCond set Escolha = 'N'
      Where Calculo = PCALCULO;
      Update kit_CalculoCond set Escolha = 'S'
      Where Calculo = PCALCULO
      and Produto = PPRODUTO
      and TipoCotacao = PTIPOCOTACAO
      and Condicao = PCONDICAO;
      Update kit_CalculoCondpar set Escolha = 'N'
      Where Calculo = PCALCULO;
      Update kit_CalculoCondpar set Escolha = 'S'
      Where Calculo = PCALCULO
      and Produto = PPRODUTO
      and TipoCotacao = PTIPOCOTACAO
      and parcelas = PPARCELAS
      and Condicao = PCONDICAO;
      Update kit_Calculo set Situacao = 'I'
      Where Calculo = PCALCULO;
   end if;
END;
/


CREATE OR REPLACE PROCEDURE "KIT_INCLUICALCULO" (
PCalculo      KIT_CALCULO.CALCULO%Type,
PPadrao      KIT_CALCULO.PADRAO%Type) IS
BEGIN
  DECLARE
    PDESC VARCHAR2(40);
    PPRODUTO NUMBER(18,6);
    PUTILIZACAO NUMBER(18,6);
    PNIVELDM NUMBER(18,6);
    PNIVELDP NUMBER(18,6);
    PVALORAPPMORTE NUMBER(18,6);
    PFRANQUIA NUMBER(18,6);
    PCONDICAO NUMBER(18,6);
    PCOBERTURA NUMBER(18,6);
    PCOMISSAO NUMBER(18,6);
    PDESCONTOCOMERCIAL NUMBER(18,6);
    PTIPOAPOLICE NUMBER(18,6);
    PDATA date := sysdate;
  BEGIN
    SELECT UTILIZACAO, NIVELDM, NIVELDP, VALORAPPMORTE, COBERTURA,
       FRANQUIA, CONDICAO,
       COMISSAO, DESCONTOCOMERCIAL, TIPOAPOLICE
       Into PUTILIZACAO, PNIVELDM, PNIVELDP, PVALORAPPMORTE,
       PCOBERTURA, PFRANQUIA, PCONDICAO,
       PCOMISSAO, PDESCONTOCOMERCIAL, PTIPOAPOLICE
       FROM MULT_PADRAO WHERE PADRAO = PPADRAO;
    INSERT INTO KIT_CALCULO (CALCULO, PADRAO,
       FABRICANTE, MODELO, ANOMODELO, ANOFABRICACAO, ZEROKM,
       VALORVEICULO, CEP, NIVELDM, NIVELDP, VALORAPPMORTE,
       VALORAPPDMH, TIPO_COBERTURA, TIPO_FRANQUIA,
       NIVELBONUSAUTO, INICIOVIGENCIA, FINALVIGENCIA,
       DATACALCULO, COMISSAO, DESCONTOCOMISSAO,
       NUMPASSAGEIROS, SITUACAO, COD_CIDADE,
       COD_TABELA, VALORBASE, AJUSTE,
       VALORMINIMO, VALORMAXIMO,
	   TEMACESSORIOS,OPCAOVIDROS,OPCAODESPESAS,OPCAOCARRORESERVA,TEMASSISTENCIA,ESTADOCORRETOR,CIDADECORRETOR
	   )
    VALUES
       (PCALCULO,PPADRAO,PUTILIZACAO,
       0,0,0,'N',0,'',PNIVELDM,PNIVELDP,10000,0,
       PCOBERTURA,PFRANQUIA,0,PDATA,PDATA+365,
       PDATA,PCOMISSAO - PDESCONTOCOMERCIAL,PDESCONTOCOMERCIAL,
       5,'P',0,
       PTIPOAPOLICE,0,0,0,0,'2',1,1,1,'C','SP','S√O PAULO');
   END;
END;
/


CREATE OR REPLACE PROCEDURE "KITP_LOG_CARGA_EXC" 

AS
BEGIN
	DELETE FROM KIT_LOG_CARGA;

	COMMIT;

	EXCEPTION WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20000, 'KITP_Log_Carga_Exc: '||SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE "KITP_LOG_CARGA_INC" ( pDS_LOG KIT_LOG_CARGA.DS_LOG%TYPE )
	/* pDS_LOG	= par‚metro de entrada com a descriÁ„o da log a ser gravada na tabela */
AS
BEGIN
	INSERT INTO KIT_LOG_CARGA (ts_log, ds_log) VALUES (SYSDATE, pDS_LOG);

	COMMIT;

	EXCEPTION WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20000, 'KITP_Log_Carga_Inc: '||SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE     KITPR0001_WS_INFOR_ASSUMIDA  (
  p_NumeroCalculo               IN      NUMBER,
  p_CodigoProduto               IN      NUMBER,
  p_TipoInformacaoAssumida      IN      NUMBER,
  p_TagAlterada                 IN      VARCHAR2,
  p_CodigoInformacaoEnviada     IN      VARCHAR2,
  p_DescricaoInformacaoEnviada  IN      VARCHAR2,
  p_CodigoInformacaoAssumida    IN      VARCHAR2,
  p_DescricaoInformacaoAssumida IN      VARCHAR2,
  p_CodigoRetorno               OUT     NUMBER,
  p_MensagemRetorno             OUT     VARCHAR2
)
IS
--
v_id_log        NUMBER;
--
BEGIN
        --
        p_CodigoRetorno :=      0;
        --
        -- Grava Log de Chamadas
        --
        BEGIN
                --
                BEGIN
                        --
                        SELECT  KITSQ0012_WS_INFOR_ASMDA.NEXTVAL
                        INTO    v_id_log
                        FROM    dual;
                        --
                EXCEPTION
                        --
                        WHEN    OTHERS  THEN
                                --
                                p_CodigoRetorno         :=      1;
                                p_MensagemRetorno       :=      'Problema sequence KITSQ0012_WS_INFOR_ASMDA - ' || SQLERRM;
                        --
                END;
                --
                INSERT  INTO    KIT0012_WS_INFOR_ASMDA
                                (id_ws_infor_asmda
                                ,nr_callo
                                ,cd_prdut
                                ,tp_infor_asmda
                                ,tag_alter
                                ,cd_infor_envda
                                ,ds_infor_envda
                                ,cd_infor_asmda
                                ,ds_infor_asmda
                                )
                        VALUES  (v_id_log
                                ,p_NumeroCalculo
                                ,p_CodigoProduto
                                ,p_TipoInformacaoAssumida
                                ,p_TagAlterada
                                ,p_CodigoInformacaoEnviada
                                ,p_DescricaoInformacaoEnviada
                                ,p_CodigoInformacaoAssumida
                                ,p_DescricaoInformacaoAssumida
                                );
               --

                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                                --
                                p_CodigoRetorno         :=      2;
                                p_MensagemRetorno       :=      'Problema insert KITSQ0012_WS_INFOR_ASMDA - ' || SQLERRM;
                        --
                        -- TO-DO: Gravar GPA com os dados de entrada em caso de erro. Enviar e-mail?
                --
        END;
        --
END;
/


CREATE OR REPLACE PROCEDURE        KITPR0002_VENCTO_PRIM_PARC(
  p_NumeroCalculo       IN  NUMBER,
  p_DataSugerida        OUT DATE,
  p_DataMaximaPermitida OUT DATE,
  p_DataVencimento      OUT DATE,
  p_IndBloqueio         OUT VARCHAR2,
  p_mens_erro           OUT VARCHAR2
  )
IS
--
    v_tiposeguro        MULT_CALCULO.TIPOSEGURO%TYPE;
    v_dia_anter         NUMBER;
    v_dia_atual         NUMBER;         
    v_datatransmissao   MULT_CALCULO.DATATRANSMISSAO%TYPE;
    v_iniciovigencia    MULT_CALCULO.INICIOVIGENCIA%TYPE;
    v_forma_pagamento   MULT_CALCULOCONDPAR.FORMA_PAGAMENTO%TYPE;
    v_data_boa          DATE;
    v_observacao        NUMBER;
    v_padrao            NUMBER;
    v_apolice_anterior  NUMBER;
    v_dia1              NUMBER;
    v_dia2              NUMBER;
    v_data_boa_mes      DATE;
    date_exception      EXCEPTION;
    v_prox_mes_aux      DATE;
    v_maior_data_mais_7 DATE;
    v_maior_data        DATE;
    v_gpa_id            NUMBER;
    --
    --------------------------------------------------------------------------
    --      RETORNA_GPA_ID: RETORNA O ID DO GPA QUE FOI INICIADO PELO       --
    --                      GERENCIADOR ONLINE ANTERIORMENTE.               --
    --------------------------------------------------------------------------
    FUNCTION RETORNA_GPA_ID RETURN NUMBER 
    IS
      --
      V_GPA         NUMBER;
      V_DT_UTLM_GPA VARCHAR2(4000);
      --
    BEGIN
      --
      V_DT_UTLM_GPA := TMS_PARAM.GET_PARAM('KCW.DATA.PA', 'DT_ULTMO_GPA');
      --
      V_GPA := TMS_PARAM.GET_PARAM('KCW.DATA.PA', 'SESSAO_GPA');
      --
      IF V_DT_UTLM_GPA <> '0' AND V_GPA <> '0' THEN
        --
        IF V_DT_UTLM_GPA <> TO_CHAR(SYSDATE, 'DD/MM/YYYY') THEN
          --
          TMS_GPA.FINALIZAR_PROCESSO(V_GPA);
          --
          TMS_GPA.INICIAR_PROCESSO('KCW_DATA_PA', SUBSTR(USER, 1, 8), '4402');
          --
          V_GPA := TMS_SESSION.GET_GPA_ID;
          --
          BEGIN
            --
            UPDATE SSV9099_PARAM_SSV
               SET VL_PARAM_SSV = V_GPA
             WHERE CD_GRP_PARAM_SSV = 992
               AND CD_PARAM_SSV = 'SESSAO_GPA';
            --
            UPDATE SSV9099_PARAM_SSV
               SET VL_PARAM_SSV = TO_CHAR(SYSDATE, 'DD/MM/YYYY')
             WHERE CD_GRP_PARAM_SSV = 992
               AND CD_PARAM_SSV = 'DT_ULTMO_GPA';
            --
          EXCEPTION
            --
            WHEN OTHERS THEN
              --
              DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
              --
          END;
          --
          RETURN V_GPA;
          --
        ELSE
          --
          RETURN V_GPA;
          --
        END IF;
        --
      ELSE
        --
        TMS_GPA.INICIAR_PROCESSO('KCW_DATA_PA', SUBSTR(USER, 1, 8), '4402');
        --
        V_GPA := TMS_SESSION.GET_GPA_ID;
        --
        BEGIN
          --
          UPDATE SSV9099_PARAM_SSV
             SET VL_PARAM_SSV = V_GPA
           WHERE CD_GRP_PARAM_SSV = 992
             AND CD_PARAM_SSV = 'SESSAO_GPA';
          --
          UPDATE SSV9099_PARAM_SSV
             SET VL_PARAM_SSV = TO_CHAR(SYSDATE, 'DD/MM/YYYY')
           WHERE CD_GRP_PARAM_SSV = 992
             AND CD_PARAM_SSV = 'DT_ULTMO_GPA';
          --
        EXCEPTION
          --
          WHEN OTHERS THEN
            --
            DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
            --
        END;
        --
        RETURN V_GPA;
        --
      END IF;
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
        --
        DBMS_OUTPUT.PUT_LINE('ERRO RETORNA_GPA_ID: ' || SQLERRM);
        --
        RETURN NULL;
        --
    END RETORNA_GPA_ID;
    --
    --
    --
    PROCEDURE KIT_PRC_GPA ( P_GPA_ID IN NUMBER,
                            --P_GPA_MODULO VARCHAR2,
                            P_TIPO_GPA IN CHAR,
                            P_TEXTO_GPA IN VARCHAR ) IS
    BEGIN
    DECLARE
        --   p_gpa_id    NUMBER;
        --   v_gpa_local varchar2(30)     := '4402';
        --   p_gpa_modulo VARCHAR2(30)    := 'KCW - RECEP«√O DE RENOVA«√O';
        BEGIN
            ------------------------------------------------------------------
            --      Gravando Log                                            --
            ------------------------------------------------------------------
            CASE UPPER(P_TIPO_GPA)

              WHEN 'E' THEN    --    Gravando Log de Erro
                  TMS_GPA.ERRO (P_GPA_ID  ,P_TEXTO_GPA ,NULL);
              WHEN 'I' THEN    --    Gravando Log de InformaÁ„o
                  TMS_GPA.INFO (P_GPA_ID  ,P_TEXTO_GPA ,NULL);
              WHEN 'F' THEN    --    Gravando Log Fatal
                  TMS_GPA.FATAL (P_GPA_ID ,P_TEXTO_GPA ,NULL);
                  TMS_GPA.ABORTAR_PROCESSO (P_GPA_ID, 'Erro ao executar ' /*|| P_GPA_MODULO*/, P_TEXTO_GPA );
              WHEN 'D' THEN    --    Gravando Log de Debug
                TMS_GPA.DEBUG (P_GPA_ID, P_TEXTO_GPA ,NULL);

            END CASE;

        END;

    END;
    --
BEGIN

        -- TO_DO: COLOCAR REGRA APARTADA PARA VIDA (PADRAO 12 E 13)

        -- 
        v_datatransmissao := sysdate;
        v_data_boa_mes    := null;
        --
        BEGIN
                --
                SELECT CALC.TIPOSEGURO, COB.OBSERVACAO, COB.VALOR, CALC.INICIOVIGENCIA, CONDPAR.FORMA_PAGAMENTO, CALC.PADRAO, CALC.CAMPO1
                  INTO v_tiposeguro, v_dia1, v_dia2, v_iniciovigencia, v_forma_pagamento, v_padrao, v_apolice_anterior
                  FROM mult_calculo calc,
                       MULT_CALCULOCONDPAR condpar,
                       MULT_CALCULOCOB cob
                 WHERE CALC.CALCULO =  CONDPAR.CALCULO
                   AND CALC.CALCULO = COB.CALCULO
                   AND COB.COBERTURA = 987
                   AND CONDPAR.ESCOLHA = 'S'
                   AND CALC.CALCULO = p_NumeroCalculo;
                  
                 
                IF v_padrao in (1,  2,  4) THEN
                        
                        BEGIN 
                        
                            SELECT COB2.OBSERVACAO
                              INTO v_apolice_anterior
                              FROM MULT_CALCULOCOB COB2
                             WHERE COB2.CALCULO = p_NumeroCalculo
                               AND COB2.COBERTURA = 17;
                        
                        EXCEPTION
                            WHEN  OTHERS  THEN 
                                  --
                                  
                                            
                                  p_DataSugerida                := trunc(SYSDATE) + 7;
                                  p_DataMaximaPermitida         := trunc(SYSDATE) + 7;
                                  p_DataVencimento              := trunc(SYSDATE) + 7;
                                  p_IndBloqueio                 := 'N';
                                  p_mens_erro                   := '01-Erro na busca da apolice anterior';

                                  --Grava na tabela ADMSSV.SSV4221_LOG_PROCM_ASSCN
                                  v_gpa_id := retorna_gpa_id;
                                  
                                  --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN
                                  kit_prc_gpa ( v_gpa_id,
                                                'E',
                                                'Calculo: ' || p_NumeroCalculo);
                                            
                                  --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN                                        
                                  kit_prc_gpa ( v_gpa_id,
                                                'E',
                                                'Mensagem de Erro: ' || p_mens_erro);
                                  --
                        
                        END;
                        
                END IF;
                
                IF  v_padrao in (11,14,15) THEN
                    --                 
                    v_dia_atual := v_dia2;
                    -- 
                ELSE  
                    --
                    v_dia_atual := v_dia1; 
                    --                    
                END IF;
                
                BEGIN
                        
                     IF v_padrao in (10,42,11,14,15) THEN
                        
                        SELECT MDULO.NR_DIA_PAGTO_FTURA
                          INTO v_dia_anter
                          FROM SSV0007_APOLI APOLI,
                               SSV0081_MDULO_NGOCO MDULO 
                         WHERE APOLI.CD_NGOCO = MDULO.CD_NGOCO
                           AND APOLI.TP_HISTO_NGOCO = MDULO.TP_HISTO
                           AND APOLI.CD_APOLI_SUSEP = v_apolice_anterior
                           AND MDULO.TP_HISTO = '0'
                           AND APOLI.CD_RMSEG = 312;
                     
                     ELSIF v_padrao = 1 THEN
                     
                        SELECT MDULO.NR_DIA_PAGTO_FTURA
                          INTO v_dia_anter
                          FROM SSV0007_APOLI APOLI,
                               SSV0081_MDULO_NGOCO MDULO 
                         WHERE APOLI.CD_NGOCO = MDULO.CD_NGOCO
                           AND APOLI.TP_HISTO_NGOCO = MDULO.TP_HISTO
                           AND APOLI.CD_APOLI_SUSEP = v_apolice_anterior
                           AND MDULO.TP_HISTO = '0'
                           AND APOLI.CD_RMSEG = 140;
                     
                     ELSIF v_padrao = 2 THEN
                     
                        SELECT MDULO.NR_DIA_PAGTO_FTURA
                          INTO v_dia_anter
                          FROM SSV0007_APOLI APOLI,
                               SSV0081_MDULO_NGOCO MDULO 
                         WHERE APOLI.CD_NGOCO = MDULO.CD_NGOCO
                           AND APOLI.TP_HISTO_NGOCO = MDULO.TP_HISTO
                           AND APOLI.CD_APOLI_SUSEP = v_apolice_anterior
                           AND MDULO.TP_HISTO = '0'
                           AND APOLI.CD_RMSEG = 160;
                     
                     ELSIF v_padrao = 4 THEN
                     
                        SELECT MDULO.NR_DIA_PAGTO_FTURA
                          INTO v_dia_anter
                          FROM SSV0007_APOLI APOLI,
                               SSV0081_MDULO_NGOCO MDULO 
                         WHERE APOLI.CD_NGOCO = MDULO.CD_NGOCO
                           AND APOLI.TP_HISTO_NGOCO = MDULO.TP_HISTO
                           AND APOLI.CD_APOLI_SUSEP = v_apolice_anterior
                           AND MDULO.TP_HISTO = '0'
                           AND APOLI.CD_RMSEG = 180;
                     
                     END IF;        
               
                EXCEPTION
                   WHEN OTHERS THEN
                        --
                        p_DataSugerida                := trunc(SYSDATE) + 7;
                        p_DataMaximaPermitida         := trunc(SYSDATE) + 7;
                        p_DataVencimento              := trunc(SYSDATE) + 7;
                        p_IndBloqueio                 := 'N';
                        p_mens_erro                   := '02-Erro na busca dia pagto fatura ssv';
                        --
                        
                        --Grava na tabela ADMSSV.SSV4221_LOG_PROCM_ASSCN
                        v_gpa_id := retorna_gpa_id;

                        --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN
                        kit_prc_gpa ( v_gpa_id,
                                    'E',
                                    'Calculo: ' || p_NumeroCalculo);
                                
                        --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN                                        
                        kit_prc_gpa ( v_gpa_id,
                                    'E',
                                    'Mensagem de Erro: ' || p_mens_erro);
               
                END;
                   
                IF v_padrao in (12, 13) THEN
                    --
                    IF v_datatransmissao >= v_iniciovigencia THEN
                              --                   
                              p_DataSugerida                := v_datatransmissao + 7;
                              p_DataMaximaPermitida         := v_datatransmissao + 7;
                              p_DataVencimento              := v_datatransmissao + 7;
                              p_IndBloqueio                 := 'S';
                              --   
                           ELSE
                              --
                              p_DataSugerida                := v_iniciovigencia + 7;
                              p_DataMaximaPermitida         := v_iniciovigencia + 7;
                              p_DataVencimento              := v_iniciovigencia + 7;
                              p_IndBloqueio                 := 'S';                   
                              --
                    END IF;  
                    --
                ELSE
                    --
                    IF v_forma_pagamento = 'F' THEN
                           --
                           IF v_datatransmissao >= v_iniciovigencia THEN
                              --                   
                              p_DataSugerida                := v_datatransmissao + 7;
                              p_DataMaximaPermitida         := v_datatransmissao + 7;
                              p_DataVencimento              := v_datatransmissao + 7;
                              p_IndBloqueio                 := 'S';
                              --   
                           ELSE
                              --
                              p_DataSugerida                := v_iniciovigencia + 7;
                              p_DataMaximaPermitida         := v_iniciovigencia + 7;
                              p_DataVencimento              := v_iniciovigencia + 7;
                              p_IndBloqueio                 := 'S';                   
                              --
                           END IF;                   
                        --   
                        ELSIF v_forma_pagamento  = 'D' THEN
                        --
                            IF   v_tiposeguro = 1 THEN
                                                            
                                  IF v_datatransmissao >= v_iniciovigencia THEN
                                     --  
                                     p_DataSugerida                := v_datatransmissao + 7;
                                     p_DataMaximaPermitida         := v_datatransmissao + 7;
                                     p_DataVencimento              := v_datatransmissao + 7;
                                     p_IndBloqueio                 := 'S';
                                     --
                                  ELSE
                                     --
                                     p_DataSugerida                := v_iniciovigencia + 7;
                                     p_DataMaximaPermitida         := v_iniciovigencia + 7;
                                     p_DataVencimento              := v_iniciovigencia + 7;
                                     p_IndBloqueio                 := 'S';                   
                                     --
                                  END IF;      
                                          
                            ELSIF v_tiposeguro IN (2, 3) THEN
                            
                                  IF v_datatransmissao >= v_iniciovigencia THEN
                                     --
                                     p_DataSugerida                := v_datatransmissao + 7;
                                     p_DataMaximaPermitida         := v_datatransmissao + 15;
                                     p_DataVencimento              := p_DataMaximaPermitida;
                                     p_IndBloqueio                 := 'N';
                                     --
                                  ELSE
                                     --
                                     p_DataSugerida                := v_iniciovigencia + 7;
                                     p_DataMaximaPermitida         := v_iniciovigencia + 15;
                                     p_DataVencimento              := p_DataMaximaPermitida;
                                     p_IndBloqueio                 := 'N';                   
                                     --
                                  END IF;      
                            
                            ELSIF v_tiposeguro IN (4, 5) THEN
                            
                                  IF v_dia_anter <> v_dia_atual THEN
                                      
                                      IF v_datatransmissao >= v_iniciovigencia THEN
                                         --
                                         p_DataSugerida                := v_datatransmissao + 7;
                                         p_DataMaximaPermitida         := v_datatransmissao + 15;
                                         p_DataVencimento              := p_DataMaximaPermitida;
                                         p_IndBloqueio                 := 'N';
                                         -- 
                                      ELSE
                                         --
                                         p_DataSugerida                := v_iniciovigencia + 7;
                                         p_DataMaximaPermitida         := v_iniciovigencia + 15;
                                         p_DataVencimento              := p_DataMaximaPermitida;
                                         p_IndBloqueio                 := 'N';                   
                                         --
                                      END IF;
                                    
                                  ELSE      
                                      
                                      IF v_datatransmissao >= v_iniciovigencia THEN
                                         --
                                         v_maior_data                  := v_datatransmissao;
                                         v_maior_data_mais_7           := v_datatransmissao + 7;
                                         --
                                      ELSE                                      
                                         --
                                         v_maior_data                  := v_iniciovigencia;
                                         v_maior_data_mais_7           := v_iniciovigencia + 7;
                                         --
                                      END IF;
                                  
                                      v_prox_mes_aux                   := ADD_MONTHS (v_maior_data, 1);                  
                                      
                                                                              
                                      BEGIN
                                          --
                                          v_data_boa := TO_DATE (LPAD (v_dia_atual, 2, '0')|| TO_CHAR (v_maior_data, 'MMYYYY'),'DDMMYYYY');
                                          --
                                      EXCEPTION
                                      --
                                         WHEN others THEN
                                              --                                              
                                              v_data_boa        := TO_DATE ('01' || TO_CHAR (v_prox_mes_aux, 'MMYYYY'),'DDMMYYYY');
                                              v_data_boa_mes    := TO_DATE (LPAD (v_dia_atual, 2, '0')|| TO_CHAR (v_prox_mes_aux, 'MMYYYY'),'DDMMYYYY');
                                              --

                                              --?? gravar log?
                                              --mensagem - erro na formatacao da data boa

                                              --Grava na tabela ADMSSV.SSV4221_LOG_PROCM_ASSCN
                                              v_gpa_id := retorna_gpa_id;
                                              
                                              --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN
                                              kit_prc_gpa ( v_gpa_id,
                                                            'E',
                                                            'Calculo: ' || p_NumeroCalculo);

                                              --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN                                        
                                              kit_prc_gpa ( v_gpa_id,
                                                            'E',
                                                            'Mensagem de Erro: Erro na FormataÁ„o da Data Boa');
                                                --
                                      END;

                                      IF v_data_boa_mes is not null THEN
                                         --
                                         IF v_data_boa < v_maior_data_mais_7 THEN
                                            --
                                            v_data_boa      := v_data_boa_mes;
                                            --
                                         END IF;
                                         --
                                      ELSE
                                         --
                                         IF v_data_boa < v_maior_data_mais_7 THEN
                                         
                                            v_data_boa      := ADD_MONTHS (v_data_boa, 1);
                                      
                                         END IF;
                                         --
                                      END IF;
                                      
                                        
                                      p_DataSugerida                := v_data_boa;
                                      p_DataMaximaPermitida         := v_data_boa;
                                      p_DataVencimento              := v_data_boa;
                                      p_IndBloqueio                 := 'S';    
                                      
                                        
                                  END IF;
                        
                            END IF;
                           
                        END IF;
                        
                END IF;        
                        
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                                --
                                p_DataSugerida                := trunc(SYSDATE) + 7;
                                p_DataMaximaPermitida         := trunc(SYSDATE) + 7;
                                p_DataVencimento              := trunc(SYSDATE) + 7;
                                p_IndBloqueio                 := 'N';
                                p_mens_erro                   := '03-Erro no Calculo da Data';
                                --
                                
                                --Grava na tabela ADMSSV.SSV4221_LOG_PROCM_ASSCN
                                v_gpa_id := retorna_gpa_id;

                                --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN
                                kit_prc_gpa ( v_gpa_id,
                                            'E',
                                            'Calculo: ' || p_NumeroCalculo);
                                        
                                --Grava na tabela ADMSSV.SSV4222_LOG_DETAL_PROCM_ASSCN                                        
                                kit_prc_gpa ( v_gpa_id,
                                            'E',
                                            'Mensagem de Erro: ' || p_mens_erro);
                --
        END;
        --
END;
/


CREATE OR REPLACE procedure        KITPR001_servico_p10_cotacao (
  p_calculo        IN   NUMBER,
  P_RESULTADO      OUT  TYPES.CURSOR_TYPE
) IS
--
v_946   NUMBER(3)       :=      946;
v_10    NUMBER(3)       :=      10;
v_40    NUMBER(3)       :=      40;
--
CURSOR  c1      is
SELECT c.calculo,
    /*****
    Assistencia 24 horas
    *****/
    c.estado AS assistencia24h,
    c.estado,
    /*****
    KM de Reboque
    *****/
    '200 Km (Padr„o)' AS km_reboque_padrao,
    kmadic.descricao
    || ' (Adicional)' AS km_reboque_adicional,
    opcv.opcao        AS vidrosopc
  FROM mult_calculo c
    /*****
    KM de Reboque
    *****/
  LEFT JOIN mult_calculocob kma
  ON kma.calculo    = c.calculo
  AND kma.cobertura = v_946
  LEFT JOIN mult_produtoscobperopc kmadic
  ON kmadic.cobertura  = v_946
  AND kmadic.produto   = v_10
  AND kmadic.opcao     = kma.opcao
  AND kmadic.cobertura = v_946
    /*****
    Vidros
    *****/
  LEFT JOIN mult_calculocob cv
  ON cv.calculo    = c.calculo
  AND cv.cobertura = v_40
  INNER JOIN mult_produtoscobperopc opcv
  ON opcv.opcao      = cv.opcao
  AND opcv.produto   = v_10
  AND opcv.cobertura = v_40
  where c.calculo = p_calculo;
--
v_assistencia24h        VARCHAR2(400);
v_km_reboque_padrao     VARCHAR2(400);
v_km_reboque_adicional  VARCHAR2(400);
v_vidrosopc             VARCHAR2(400);

BEGIN
--
FOR     r1      IN      c1      LOOP
        --
        IF      r1.estado       =       'N'     THEN
                --
                v_km_reboque_padrao     :=      'N√£o possui';
                --
        ELSE
                --
                v_km_reboque_padrao     :=      r1.km_reboque_padrao;
                --
        END     IF;
        --
        v_assistencia24h        :=      r1.assistencia24h;
        v_km_reboque_adicional  :=      r1.km_reboque_adicional;
        v_vidrosopc             :=      r1.vidrosopc;
        --
END     LOOP;
--
OPEN    P_RESULTADO       FOR
        --
        SELECT  v_assistencia24h   assistencia24h
                ,v_km_reboque_padrao   km_reboque_padrao
                ,v_km_reboque_adicional  km_reboque_adicional
                ,v_vidrosopc vidrosopc
        FROM    dual;


--
NULL;
--
END;
/


CREATE OR REPLACE PROCEDURE     KITPR001_Ws_Infor_Assumida  (
  p_NumeroCalculo               NUMBER,  
  p_CodigoProduto               NUMBER,  
  p_TipoInformacaoAssumida      NUMBER,
  p_TagAlterada                 VARCHAR2,
  p_CodigoInformacaoEnviada     VARCHAR2,
  p_DescricaoInformacaoEnviada  VARCHAR2,
  p_CodigoInformacaoAssumida    VARCHAR2,
  p_DescricaoInformacaoAssumida VARCHAR2,
  p_CodigoRetorno               NUMBER,
  p_MensagemRetorno             VARCHAR2
)
IS
--
v_id_log        NUMBER;
--
BEGIN

        --
        -- Grava Log de Chamadas
        --
        BEGIN
                SELECT  kitsq0005_CNSLT_VALOR_MRCDO.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
                INSERT  INTO    KIT0012_WS_INFOR_ASMDA
                                (id_ws_infor_asmda     
                                ,nr_callo      
                                ,cd_prdut      
                                ,tp_infor_asmda
                                ,tag_alter     
                                ,cd_infor_envda
                                ,ds_infor_envda
                                ,cd_infor_asmda
                                ,ds_infor_asmda 
                                )
                        VALUES  (v_id_log
                                ,p_NumeroCalculo                 
                                ,p_CodigoProduto                 
                                ,p_TipoInformacaoAssumida      
                                ,p_TagAlterada                 
                                ,p_CodigoInformacaoEnviada     
                                ,p_DescricaoInformacaoEnviada  
                                ,p_CodigoInformacaoAssumida    
                                ,p_DescricaoInformacaoAssumida 
                                );
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

end;
/


CREATE OR REPLACE PROCEDURE "LISTA_ANODE1" (
    PMODELO in REAL_ANOSAUTO.MODELO%Type,
    PPROCEDENCIA in REAL_ANOSAUTO.TIPO_COMBUSTIVEL%Type,
    PANOFABRICACAO in REAL_ANOSAUTO.ANODE%Type,
    PCAMPO out Types.cursor_type)
IS
BEGIN
 OPEN PCAMPO FOR

   SELECT ANODE FROM REAL_ANOSAUTO WHERE MODELO = PMODELO
               AND TIPO_COMBUSTIVEL = PPROCEDENCIA
               AND ANODE = PANOFABRICACAO
               AND SOFAB = 'N';
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_ANOMODELO" (
    PMODELO1 IN REAL_ANOSAUTO.MODELO%Type,
    PTIPO_COMBUSTIVEL IN REAL_ANOSAUTO.TIPO_COMBUSTIVEL%Type,
    PPRODUTO IN MULT_PRODUTOS.PRODUTO%Type,
    PCAMPO out Types.cursor_type)
IS
BEGIN
 OPEN PCAMPO FOR
   SELECT D.MODELO, D.TIPO_COMBUSTIVEL as PROCEDENCIA , D.ANODE as DESCRICAO, D.ANODE as ANOFABRICACAO
   FROM REAL_ANOSAUTO D, MULT_PRODUTOS D1
   WHERE D.MODELO = PMODELO1 AND D.TIPO_COMBUSTIVEL = PTIPO_COMBUSTIVEL
     AND D1.PRODUTO = PPRODUTO
     AND D.ANODE <= D1.ANOREFERENCIA ORDER BY DESCRICAO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_ATIVIDADES" (
    PSHOP IN Mult_Calculo.CALCULO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin

OPEN PCAMPO FOR
   Select  d.chave3 as AnoModelo, d.Texto as descricao, d.valor, d.chave2 as CodAtiv
   from mult_produtostabrg d, mult_produtostabrg d1
   where
   d.produto = 4 and d.tabela = 103 and d.chave1 = 1
   and d1.produto = 4 and d1.tabela = 104 and d1.chave1 = 1 and d1.Chave3 = d.chave2
   and (d1.chave2 = PSHOP or (PSHOP = 0 AND d1.chave2 <> 3)) and d.valor = 0
  union
   Select all d.chave3 as AnoModelo, d.Texto as descricao, d.valor,  d.chave2 as CodAtiv
   from mult_produtostabrg d
   where
   d.produto = 4 and d.tabela = 103 and d.chave1 = 1 and d.valor = 1
  ORDER BY descricao;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_CALCULOESTIP" (
    PDATADE in Mult_calculo.DataCalculo%Type,
    PDATAATE in Mult_calculo.DataCalculo%Type,
    PCORRETOR in Mult_CalculoDivisoes.Divisao%Type,
    PCAMPO out TYPES.CURSOR_TYPE)
IS
begin
  Open PCAMPO for
SELECT  T04.Divisao_Superior,
        T04.Nome,
        T03.Divisao,
        T05.PadraoUsuario,
        count(*) as QTDE
FROM Mult_Calculo T01

INNER  JOIN Mult_CalculoDivisoes T02
  ON   T01.Calculo = T02.Calculo
  AND  T02.Nivel   = 1

LEFT   JOIN Mult_CalculoDivisoes T03
  ON   T01.Calculo = T03.Calculo
  AND  T03.Nivel   = 4

LEFT  JOIN Tabela_Divisoes T04
  on  T03.Divisao = T04.Divisao

INNER JOIN real_usuarios T05
  ON  T05.COD_USUARIO = T01.COD_USUARIO
  AND T05.CORRETOR    = T02.DIVISAO
  AND T05.INICIOVIGENCIA =
            (
               select  max(RC1.INICIOVIGENCIA)
               from real_usuarios RC1
               where RC1.COD_USUARIO = T01.COD_USUARIO
                 AND RC1.CORRETOR    = T02.DIVISAO
            )


where  T01.DataCalculo between PDATADE and PDATAATE + 1 and
       T01.Situacao in ('E', 'T') and
       T02.Divisao = PCORRETOR


group by
        T04.Divisao_Superior,
        T04.Nome,
        T03.Divisao,
        T05.PadraoUsuario;

end;
/


CREATE OR REPLACE PROCEDURE "LISTA_CALCULOS" 
(
  PNOME IN MULT_CALCULO.NOME%Type,
  PSITUACAO IN MULT_CALCULO.SITUACAO%Type,
  PPADRAO IN MULT_CALCULO.PADRAO%Type,
  PNUMTITULO IN MULT_CALCULO.NUMEROTITULO%Type,
  PDIGITO IN MULT_CALCULO.DV%Type,
  PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN

OPEN PCAMPO FOR

SELECT CALCULO, NOME, DATACALCULO , ITEM, PADRAO, SITUACAO
  FROM MULT_CALCULO
 WHERE
   (NOME LIKE PNome OR Pnome = '')
   AND (PADRAO = PPadrao or PPadrao = 0)
   AND (PSITUACAO = 'P' OR PSITUACAO = 'X')
   AND (SITUACAO = 'C')
   AND (NUMEROTITULO = Pnumtitulo OR Pnumtitulo = '')
   AND (DV = Pdigito OR Pdigito = '')
   AND (ITEM = 1 OR ITEM = 0)
union all
SELECT CALCULO, NOME, DATACALCULO , ITEM, PADRAO, SITUACAO
  FROM MULT_CALCULO
 WHERE
   (NOME LIKE PNome OR Pnome = '')
   AND (PADRAO = PPadrao or PPadrao = 0)
   AND (PSITUACAO = 'P' OR PSITUACAO = 'X')
   AND (SITUACAO = 'P')
   AND (NUMEROTITULO = Pnumtitulo OR Pnumtitulo = '')
   AND (DV = Pdigito OR Pdigito = '')
   AND (ITEM = 1 OR ITEM = 0)
union all
SELECT CALCULO, NOME, DATACALCULO , ITEM, PADRAO, SITUACAO
  FROM MULT_CALCULO
 WHERE
   (NOME LIKE PNome OR Pnome = '')
   AND (PADRAO = PPadrao or PPadrao = 0)
   AND (PSITUACAO = 'P' OR PSITUACAO = 'X')
   AND (SITUACAO = 'A' or SITUACAO = 'E')
   AND (NUMEROTITULO = Pnumtitulo OR Pnumtitulo = '')
   AND (DV = Pdigito OR Pdigito = '')
   AND (ITEM = 1 OR ITEM = 0)
union all
SELECT CALCULO, NOME, DATACALCULO, ITEM, PADRAO, SITUACAO
  FROM MULT_CALCULO
 WHERE
   (NOME LIKE PNome OR Pnome = '')
   AND (PADRAO = PPadrao or PPadrao = 0)
   AND (PSITUACAO = 'T' OR PSITUACAO = 'X')
   AND (SITUACAO = 'T')
   AND (NUMEROTITULO = Pnumtitulo OR Pnumtitulo = '')
   AND (DV = Pdigito OR Pdigito = '')
   AND (ITEM = 1 OR ITEM = 0);
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_CLASSES" 
   (PCAMPO OUT TYPES.CURSOR_TYPE)
IS
begin
open PCAMPO for
   Select Opcao, Descricao
   from Mult_ProdutosCobPerOpc where Produto = 3 and cobertura = 979;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_CLIENTES" 
   (PCAMPO OUT TYPES.CURSOR_TYPE)
IS
BEGIN
open PCAMPO for
  select d.Cliente, d.Nome, d.Cgc_Cpf as CNPJ_CPF, 'FÌsica  ' as Tipo_Pessoa, d1.Endereco, d1.numero, d1.complemento, d1.bairro, d1.Cep, d1.Cidade, d1.Estado, 'Masculino' as Sexo, d.Data_Nascimento
  from Tabela_clientes d, tabela_clientender d1 where d.Cliente = d1.Cliente and d1.Cliente_end = 1 and d.Tipo_Pessoa = 'F' and d.Sexo = 'M'

  union

  select d.Cliente, d.Nome, d.Cgc_Cpf as CNPJ_CPF, 'FÌsica  ' as Tipo_Pessoa, d1.Endereco, d1.numero, d1.complemento, d1.bairro, d1.Cep, d1.Cidade, d1.Estado, 'Feminino ' as Sexo, d.Data_Nascimento
  from Tabela_clientes d, tabela_clientender d1 where d.Cliente = d1.Cliente and d1.Cliente_end = 1 and d.Tipo_Pessoa = 'F' and d.Sexo = 'F'

  union

  select d.Cliente, d.Nome, d.Cgc_Cpf as CNPJ_CPF, 'JurÌdica' as Tipo_Pessoa, d1.Endereco, d1.numero, d1.complemento, d1.bairro, d1.Cep, d1.Cidade, d1.Estado, '         ' as Sexo, d.Data_Nascimento
  from Tabela_clientes d, tabela_clientender d1 where d.Cliente = d1.Cliente and d1.Cliente_end = 1 and d.Tipo_Pessoa = 'J';
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_COBOPC1" (
    PPRODUTO IN Mult_ProdutosCobPerOpc.PRODUTO%TYPE,
    PCOBERTURA IN Mult_ProdutosCobPerOpc.COBERTURA%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE)
IS
begin
 OPEN PCAMPO FOR
  Select Descricao, Opcao, Ordem from Mult_ProdutosCobPerOpc
  where Produto = PPRODUTO
  and cobertura = PCOBERTURA Order by Ordem;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_COBPEROPC1" 
(
 PPRODUTO   in Mult_ProdutosCobPerOpc.PRODUTO%Type,
 PCOBERTURA in Mult_ProdutosCobPerOpc.COBERTURA%Type,
 POPCAO     in Mult_ProdutosCobPerOpc.OPCAO%Type,
 PCAMPO     out Types.cursor_type
)
IS
begin
OPEN PCAMPO FOR
  select Valor from Mult_ProdutosCobPerOpc
  where
    Produto = PProduto
    and Cobertura = PCobertura
    and Opcao = POpcao;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_COB1" (
    PCALCULO IN Mult_CalculoCob.CALCULO%TYPE,
    PITEM    IN Mult_CalculoCob.ITEM%TYPE,
    PPRODUTO IN Mult_CobPerDic.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin

OPEN PCAMPO FOR
select distinct d.Cobertura, d.Valor, d.Opcao, d.Observacao, d2.Descricao, d1.Ordem, d1.Solicita, d1.Tela
from Mult_CalculoCob d, Mult_CobPerDic d1, Mult_ProdutosCobPer d2
  Where d.Calculo= Pcalculo
    and d.Item= Pitem
    and d.Condutor= 0
    and d1.Produto = Pproduto
    and d1.Cobertura = d.Cobertura
    and d1.Escolha = 'N'
    and d1.Mostra = 'S'
    and d1.Solicita <> 'A'
    and (d.Tipo = 'P' or d.Tipo = 'M' or d.Tipo = 'C')
    and d2.Produto = d1.Produto
    and d2.Cobertura = d.Cobertura order by d1.ordem;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_CODIGOCOBERTURA1" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type
,PCOBERTURA in MULT_CALCULOCOB.COBERTURA%Type
,PPRODUTO in MULT_COBPERDIC.PRODUTO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      SELECT D1.CODIGO FROM MULT_CALCULOCOB D, Mult_cobPerDic d1
      WHERE D.CALCULO = PCALCULO
      AND D.ITEM = PITEM
      and D.Cobertura = PCOBERTURA
      and D1.Cobertura = D.Cobertura
      and D1.Opcao = D.OPCAO
      and D1.Produto = PPRODUTO;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_CODIGOOPCAOCOBERTURA1" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type
,PCOBERTURA in MULT_CALCULOCOB.COBERTURA%Type
,POPCAO in MULT_CALCULOCOBOP.OPCAO%Type
,PPRODUTO in MULT_COBPERDIC.PRODUTO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
     SELECT D1.CODIGO FROM MULT_CALCULOCOBOP D, Mult_cobPerDic d1
       WHERE D.CALCULO = PCALCULO
       AND D.ITEM = PITEM
       and D.Cobertura = PCOBERTURA
       and D1.Cobertura = D.cOBERTURA
       and D1.Opcao = POPCAO
       and D.Opcao = D1.oPCAO
       and D1.Produto = PPRODUTO
       and D.ESCOLHA = 'S';
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_DESCRICAOCOBERTURA1" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type
,PCOBERTURA in MULT_CALCULOCOB.COBERTURA%Type
,PPRODUTO in MULT_COBPERDIC.PRODUTO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
SELECT d1.descricao FROM MULT_CALCULOCOB d,  Mult_ProdutosCobPerOpc d1
WHERE d.CALCULO = PCALCULO
AND d.ITEM    = PITEM
AND d.COBERTURA = PCOBERTURA
AND d1.produto = PPRODUTO
AND D1.COBERTURA = D.COBERTURA
AND D1.OPCAO = D.OPCAO;
END;
/


CREATE OR REPLACE PROCEDURE        LISTA_ESTIPULANTES
(
    PLOGIN  IN REAL_USUARIOS.COD_USUARIO%TYPE,
    PCORRETOR  IN REAL_USUARIOS.CORRETOR%TYPE,
    PPRODUTO IN MULT_PRODUTOS.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
  DECLARE
    V_PADRAO_USUARIO VARCHAR2(1);
    V_QTDE NUMBER(8);
    V_DIVISAO_SUPERIOR NUMBER(8);
    V_CORRETOR NUMBER(8);
    CURSOR TEM_EST IS
      SELECT T1.DIVISAO FROM TABELA_DIVISOES T1, TABELA_DIVISOESCOMER T2
         WHERE  T2.DIVISAOCOM = V_CORRETOR AND  T1.DIVISAO = T2.DIVISAO  AND  T1.SITUACAO = 'A' AND (PPRODUTO = 0 OR T2.PRODUTO = PPRODUTO);
BEGIN

  V_CORRETOR := PCORRETOR;
  begin
    SELECT PADRAOUSUARIO INTO V_PADRAO_USUARIO FROM REAL_USUARIOS
     WHERE COD_USUARIO = PLOGIN
       AND CORRETOR = PCORRETOR
       AND INICIOVIGENCIA = (SELECT MAX(INICIOVIGENCIA) AS INICIOVIGENCIA FROM REAL_USUARIOS
                              WHERE COD_USUARIO = PLOGIN
                                AND CORRETOR = PCORRETOR);
  exception
    when others then
      V_PADRAO_USUARIO := 'C';
  end;

  SELECT DIVISAO_SUPERIOR INTO V_DIVISAO_SUPERIOR FROM TABELA_DIVISOES WHERE DIVISAO = PCORRETOR;

  IF SUBSTR(TO_CHAR(V_DIVISAO_SUPERIOR,'000000'),1,5) = '0435' THEN
   V_CORRETOR := 43551;
  END IF;

  IF (V_PADRAO_USUARIO = 'R') THEN
     OPEN PCAMPO FOR
      SELECT 0 AS DIVISAO,' ' AS NOME FROM DUAL
      UNION
      SELECT
        DISTINCT T1.DIVISAO, T1.NOME
       FROM
         TABELA_DIVISOES T1, TABELA_DIVISOESCOMER T2
       WHERE
        (T1.TIPO_DIVISAO = 'B' AND T1.SITUACAO = 'A') AND
        (T1.DIVISAO IN ( SELECT ESTIPULANTE
                         FROM VW_ESTIP_USUARIOS
                         WHERE COD_USUARIO = PLOGIN AND
                               CORRETOR = V_CORRETOR AND
                               INICIOVIGENCIA = (
                                    SELECT MAX(INICIOVIGENCIA) AS INICIOVIGENCIA FROM REAL_USUARIOS
                                         WHERE COD_USUARIO = PLOGIN AND
                                          CORRETOR = PCORRETOR))) AND
        (T2.DIVISAO = T1.DIVISAO) AND
        (PPRODUTO = 0 OR T2.PRODUTO = PPRODUTO)
       ORDER BY NOME;
  ELSE
    OPEN TEM_EST;
      FETCH TEM_EST INTO V_QTDE;
      IF TEM_EST%NOTFOUND THEN
        V_QTDE := 0;
      ELSE
        V_QTDE := 1;
      END IF;
    CLOSE TEM_EST;
    IF (V_QTDE <> 0) THEN
      OPEN PCAMPO FOR
      SELECT 0 AS DIVISAO,' ' AS NOME FROM DUAL
      UNION
      SELECT ALL
        T1.DIVISAO, T1.NOME
      FROM
        TABELA_DIVISOES T1, TABELA_DIVISOESCOMER T2
      WHERE
        T2.DIVISAOCOM = V_CORRETOR AND
        T1.DIVISAO = T2.DIVISAO  AND
        T1.SITUACAO = 'A' AND
        (PPRODUTO = 0 OR T2.PRODUTO = PPRODUTO)
      ORDER BY NOME;
    END IF;
    IF NOT PCAMPO%ISOPEN THEN
      OPEN PCAMPO FOR SELECT * FROM DUAL WHERE 1=2;
    END IF;
  END IF;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_ESTIPULANTES_PORTAL" 
(
    PCORRETOR  IN REAL_USUARIOS.CORRETOR%TYPE,
    PESTIPULANTES OUT NOCOPY ESTIPULANTE_TYPE
)
IS
BEGIN
  DECLARE
    I  PLS_INTEGER;
    V_PADRAO_USUARIO VARCHAR2(1);
    V_COUNT NUMBER(8);
    V_DIVISAO NUMBER(8);
    V_EST_CODE NUMBER(18);
    V_EST_NAME VARCHAR2(40);
    V_EST_REC ESTIPULANTE_REC;

    CURSOR DIV_CONVERT IS
      SELECT divisao FROM tabela_divisoes
      WHERE divisao_superior = PCORRETOR
      AND   tipo_divisao = 'E';

    CURSOR DIV_LIST IS
      SELECT DISTINCT T1.DIVISAO, T1.NOME
      FROM
        TABELA_DIVISOES T1, TABELA_DIVISOESCOMER T2
      WHERE
        T2.DIVISAOCOM = V_DIVISAO AND
        T1.DIVISAO = T2.DIVISAO   AND
        T1.SITUACAO = 'A';

  BEGIN

    PESTIPULANTES := ESTIPULANTE_TYPE();

    OPEN DIV_CONVERT;
      FETCH DIV_CONVERT INTO V_DIVISAO;
      IF DIV_CONVERT%NOTFOUND THEN
          V_DIVISAO := 0;
          V_EST_CODE := -1;
          V_EST_NAME := 'Corretor (' ||  TO_CHAR(PCORRETOR) || ') n„o cadastrado no KCW';
          PESTIPULANTES.EXTEND;
          PESTIPULANTES(1) := ESTIPULANTE_REC(V_EST_CODE, V_EST_NAME);
      else
          I := 1;
          OPEN DIV_LIST;
            loop
              FETCH DIV_LIST INTO V_EST_CODE, V_EST_NAME;
              exit when DIV_LIST%notfound;
              PESTIPULANTES.EXTEND;
              PESTIPULANTES(I) := ESTIPULANTE_REC(V_EST_CODE, V_EST_NAME);
              I := I + 1;
            end loop;
          CLOSE DIV_LIST;
      END IF;
    CLOSE DIV_CONVERT;

  END;

END;
/


CREATE OR REPLACE PROCEDURE "LISTA_FABRICANTE" 
(
    PTIPO  IN TABELA_VEICULOFABRIC.SITUACAO%TYPE,
    PESTIPULANTE  IN REAL_ESTFAB.ESTIPULANTE%TYPE,
    PCORRETOR IN FLOAT,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
  declare
    V_DIVISAO_SUPERIOR_ESTIPULANTE NUMBER(8);
    V_DIVISAO_SUPERIOR_CORRETOR NUMBER(8);
BEGIN
  /**/
  BEGIN
    Select DIVISAO_SUPERIOR INTO V_DIVISAO_SUPERIOR_CORRETOR from TABELA_DIVISOES where DIVISAO = PESTIPULANTE;
  EXCEPTION
    WHEN OTHERS THEN
      V_DIVISAO_SUPERIOR_ESTIPULANTE := 0;
  END;

  BEGIN
    Select DIVISAO_SUPERIOR INTO V_DIVISAO_SUPERIOR_CORRETOR from TABELA_DIVISOES where DIVISAO = PCORRETOR;
  EXCEPTION
    WHEN OTHERS THEN
      V_DIVISAO_SUPERIOR_CORRETOR := 0;
  END;

  if (V_DIVISAO_SUPERIOR_ESTIPULANTE = 0) then
    if (V_DIVISAO_SUPERIOR_CORRETOR = 98626) then
      OPEN PCAMPO FOR
         SELECT NOME AS DESCRICAO, FABRICANTE
         FROM TABELA_VEICULOFABRIC
         WHERE SITUACAO = PTIPO AND FABRICANTE = 572 order by DESCRICAO;
    else
      OPEN PCAMPO FOR
         SELECT NOME AS DESCRICAO, FABRICANTE
         FROM TABELA_VEICULOFABRIC
         WHERE SITUACAO = PTIPO order by DESCRICAO;
    end if;
  else
    if (V_DIVISAO_SUPERIOR_CORRETOR = 98626) then
      OPEN PCAMPO FOR
         SELECT NOME AS DESCRICAO, FABRICANTE
         FROM TABELA_VEICULOFABRIC
         WHERE SITUACAO = PTIPO AND FABRICANTE = 572 order by DESCRICAO;
    else
      OPEN PCAMPO FOR
      select NOME AS DESCRICAO, FABRICANTE
      from TABELA_VEICULOFABRIC
      where SITUACAO = PTIPO and
           ((FABRICANTE  = (Select distinct COD_FABRICANTE1 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE2 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE3 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE4 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE5 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE6 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE7 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE8 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE9 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            FABRICANTE   = (Select distinct COD_FABRICANTE0 from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE) or
            not exists (Select distinct ESTIPULANTE from REAL_ESTFAB where ESTIPULANTE = V_DIVISAO_SUPERIOR_ESTIPULANTE)))
       order by DESCRICAO;
     end if;
  end if;
end;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_LIMITECOM1" 
(
    PCALCULO IN mult_calculodivisoes.CALCULO%TYPE,
    PPRODUTO IN tabela_divisoescomer.PRODUTO%TYPE,
    PINICIOVIGENCIA IN  mult_calculo.iniciovigencia%type,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin

  OPEN PCAMPO FOR
   select d3.Desconto,
          d3.Comissao,
          d3.ComissaoMin,
          d3.ComissaoMax
   from mult_calculodivisoes d,
        mult_calculodivisoes d2,
        tabela_divisoescomer d3
   where
     d.calculo = Pcalculo
     and d.nivel = 4
     and d2.calculo = d.calculo
     and d2.nivel = 1
     and d3.divisao = d.Divisao
     and d3.divisaoCom = d2.Divisao
     and d3.produto = Pproduto 
     and PInicioVigencia Between d3.InicioVigencia and d3.finalvigencia;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_LIMITEDMO1" 
(PPRODUTO in MULT_PRODUTOSRCF_VALORES.PRODUTO%Type
,PNIVELDM in MULT_PRODUTOSRCF_VALORES.NIVEL%Type
,PNIVELDP in MULT_PRODUTOSRCF_VALORES.NIVEL%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
     SELECT (D1.VALOR + D2.VALOR) * 0.10 AS TOTRC
     FROM MULT_PRODUTOSRCF_VALORES D1, MULT_PRODUTOSRCF_VALORES D2
     WHERE D1.PRODUTO = PPRODUTO AND D2.PRODUTO = PPRODUTO
     AND D1.NIVEL   = PNIVELDM
     AND D2.NIVEL   = PNIVELDP;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_MODELOSCARGA1" (
    PMODELO1      IN REAL_ANOSAUTO.MODELO%TYPE,
    PPROCEDENCIA1 IN REAL_ANOSAUTO.TIPO_COMBUSTIVEL%TYPE,
    PANOFABRICACAO1 IN REAL_ANOSAUTO.ANODE%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin

OPEN PCAMPO FOR
  SELECT MODELO, TIPO_COMBUSTIVEL AS PROCEDENCIA , ANODE AS DESCRICAO , ANODE AS ANOMODELO , ANODE AS ANOFABRICACAO FROM REAL_ANOSAUTO
  WHERE
    MODELO = PMODELO1 AND
    TIPO_COMBUSTIVEL = PPROCEDENCIA1 AND
    SOFAB = 'N' AND
    ANODE >= PAnoFabricacao1 AND
    ANODE < PAnoFabricacao1 + 2
  ORDER BY DESCRICAO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_MODELO1" 
(
    PFABRICANTE1 IN TABELA_VEICULOMODELO.FABRICANTE%TYPE,
    PCORRETOR FLOAT,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
DECLARE
  V_DIVISAO FLOAT;
  CURSOR TB_DIVISAO_SUPERIOR IS
      SELECT DIVISAO_SUPERIOR FROM TABELA_DIVISOES WHERE DIVISAO = PCORRETOR;

BEGIN
    Open TB_DIVISAO_SUPERIOR;  FETCH TB_DIVISAO_SUPERIOR INTO V_DIVISAO;
        IF TB_DIVISAO_SUPERIOR%Notfound THEN
            V_DIVISAO := 0;
        END IF;
    CLOSE TB_DIVISAO_SUPERIOR;

    IF V_DIVISAO <> 98626 THEN
        OPEN PCAMPO FOR
            SELECT DESCRICAO, MODELO, FABRICANTE
                FROM TABELA_VEICULOMODELO
                WHERE FABRICANTE = PFABRICANTE1 AND FABRICANTE > 0 ORDER BY DESCRICAO;
     ELSE
        OPEN PCAMPO FOR
            SELECT DESCRICAO, MODELO, FABRICANTE
                FROM TABELA_VEICULOMODELO
                WHERE FABRICANTE = 572 AND FABRICANTE > 0
                AND (CATEG_TAR1 NOT IN (9,10)) AND (CATEG_TAR2 NOT IN (9,10))
                ORDER BY DESCRICAO;
    END IF;
END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_MODELO2" (
    PMVERSAO1    IN MULT_PRODUTOSTABRG.CHAVE1%TYPE,
    PFABRICANTE1 IN MULT_PRODUTOSTABRG.CHAVE3%TYPE,
    PVALORBASE1  IN TABELA_VEICULOMODELO.CATEG_TAR1%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin

OPEN PCAMPO FOR
SELECT
   PMVERSAO1 AS MVERSAO1,
   D.DESCRICAO,
   D.MODELO,
   Pvalorbase1 AS CATEGORIA,
   D2.CHAVE3 AS FABRICANTE ,
   Pvalorbase1 AS VALORBASE
FROM MULT_PRODUTOSTABRG D2, TABELA_VEICULOMODELO D
WHERE
(D2.PRODUTO = 11) AND
(D2.TABELA = 8888) AND
(D2.CHAVE1 = 1) AND
(D2.CHAVE2 = D.MODELO) AND
(D2.CHAVE3 = PFABRICANTE1) AND
(((D.CATEG_TAR1  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR11 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR2  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR12 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR3  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR13 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR4  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR14 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR5  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR15 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR6  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR16 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR7  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR17 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR8  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR18 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR9  = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR19 = PVALORBASE1 AND PMVERSAO1 = 2)) OR
 ((D.CATEG_TAR10 = PVALORBASE1 AND PMVERSAO1 = 1) OR (D.CATEG_TAR20 = PVALORBASE1 AND PMVERSAO1 = 2)))
order by d.DESCRICAO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVEISDIV2" 
(
    PNIVEL1 IN Mult_padraoNiveis.NIVEL%TYPE,
    PPADRAO IN Mult_padraoNiveis.PADRAO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
Select d4.Divisao,
       d4.Divisao_Superior,
       d4.Nome,
       d4.UserName,
       d4.foto,
       d.Nivel,
       d2.NivelPai,
       d2.DivisaoPai
from
    Mult_padraoNiveis d,
    Tabela_NiveisHierarq d1,
    Mult_PadraoDivisoes d2,
    Tabela_NiveisDivisao d3,
    Tabela_Divisoes d4
where d.Nivel = d1.Nivel
  and d.Nivel = PNivel1
  and d.padrao = PPadrao
  and d2.Padrao = d.Padrao
  and d2.Nivel = d.Nivel
  and d3.Nivel = d2.Nivel
  and d3.Divisao = d2.Divisao
  and d4.Divisao = d3.Divisao;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVEISDIV3" 
(
    PNIVEL1 IN Mult_padraoNiveis.NIVEL%TYPE,
    PPADRAO IN Mult_padraoNiveis.PADRAO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
Select d4.Divisao,
       d4.Divisao_Superior,
       d4.Nome,
       d4.UserName,
       d4.foto,
       d.Nivel,
       d2.NivelPai,
       d2.DivisaoPai
from Mult_padraoNiveis d,
     Tabela_NiveisHierarq d1,
     Mult_PadraoDivisoes d2,
     Tabela_NiveisDivisao d3,
     Tabela_Divisoes d4
where d.Nivel = d1.Nivel
  and d.Nivel = PNivel1
  and d.padrao = PPadrao
  and d4.Foto <> 0
  and d2.Padrao = d.Padrao
  and d2.Nivel = d.Nivel
  and d3.Nivel = d2.Nivel
  and d3.Divisao = d2.Divisao
  and d4.Divisao = d3.Divisao;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVEISDIV4" 
(
    PCALCULO IN Mult_CalculoDivisoes.CALCULO%TYPE,
    PDIVISAO IN Mult_CalculoDivisoes.DIVISAO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
  Select Nivel from Mult_CalculoDivisoes where Calculo = PCalculo
  and Divisao = PDivisao;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVEISDIV5" 
(
    PNIVEL1   IN Mult_padraoNiveis.NIVEL%TYPE,
    PPADRAO   IN Mult_padraoNiveis.PADRAO%TYPE,
    PDIVISAO2 IN Tabela_NiveisDivisao.DIVISAO%TYPE,
    PDIVISAO3 IN Tabela_NiveisDivisao.DIVISAO%TYPE,
    PPRODUTO  IN MULT_PRODUTOS.PRODUTO%TYPE,
    PCAMPO   OUT TYPES.CURSOR_TYPE
)
IS
begin

OPEN PCAMPO FOR
    Select d4.Divisao, d4.Divisao_Superior, d4.Nome, d4.UserName, d.Nivel, d2.NivelPai, d2.DivisaoPai
    from Mult_padraoNiveis d, Tabela_NiveisHierarq d1, Mult_PadraoDivisoes d2, Tabela_NiveisDivisao d3, Tabela_Divisoes d4, Tabela_Divisoespai d5, Tabela_Divisoescomer d6
    where d.Nivel = d1.Nivel
    and d.Nivel = PNivel1
    and d.padrao = PPadrao
    and d2.Padrao = d.Padrao
    and d2.Nivel = d.Nivel
    and d3.Nivel = d2.Nivel
    and d3.Divisao = d2.Divisao
    and d4.Divisao = d3.Divisao
    and d5.divisao = d4.divisao
    And d4.Divisao_Superior <> 4449 and d4.Divisao_Superior <> 4450 and d4.Divisao_Superior <> 4451 and d4.Divisao_Superior <> 4452 and d4.Divisao_Superior <> 4453 and d4.Divisao_Superior <> 4454
    And d4.Divisao_Superior <> 4455 and d4.Divisao_Superior <> 4456 and d4.Divisao_Superior <> 4457 and d4.Divisao_Superior <> 3407 and d4.Divisao_Superior <> 3408 and d4.Divisao_Superior <> 3411
    And d4.Divisao_Superior <> 3409 and d4.Divisao_Superior <> 2912 and d4.Divisao_Superior <> 2919 and d4.Divisao_Superior <> 2918 and d4.Divisao_Superior <> 2917 and d4.Divisao_Superior <> 3926
    And d4.Divisao_Superior <> 3927 and d4.Divisao_Superior <> 3413 and d4.Divisao_Superior <> 3412 and d4.Divisao_Superior <> 3866 and d4.Divisao_Superior <> 5514 and d4.Divisao_Superior <> 3934
    And d4.Divisao_Superior <> 5808 and d4.Divisao_Superior <> 5599
    and (d5.divisaopai = PDivisao2 or PDivisao2 = 0)
    and d6.divisao = d4.divisao
    and (d6.divisaocom = PDivisao3 or PDivisao3 = 0)
    and d6.produto = PProduto
    Union all
    Select d4.Divisao, d4.Divisao_Superior, d4.Nome, d4.UserName, d.Nivel, d2.NivelPai, d2.DivisaoPai
    from Mult_padraoNiveis d, Tabela_NiveisHierarq d1, Mult_PadraoDivisoes d2, Tabela_NiveisDivisao d3, Tabela_Divisoes d4, Tabela_Divisoescomer d6
    where d.Nivel = d1.Nivel
    and d.Nivel = Pnivel1
    and d.padrao = PPadrao
    and d2.Padrao = d.Padrao
    and d2.Nivel = d.Nivel
    and d3.Nivel = d2.Nivel
    and d3.Divisao = d2.Divisao
    and d4.Divisao = d3.Divisao
    And (d4.Divisao_Superior = 4449 or d4.Divisao_Superior = 4450 or d4.Divisao_Superior = 4451 or d4.Divisao_Superior = 4452 or d4.Divisao_Superior = 4453 or d4.Divisao_Superior = 4454
    or d4.Divisao_Superior = 4455 or d4.Divisao_Superior = 4456 or d4.Divisao_Superior = 4457 or d4.Divisao_Superior = 3407 or d4.Divisao_Superior = 3408 or d4.Divisao_Superior = 3411
       or d4.Divisao_Superior = 3409 or d4.Divisao_Superior = 2912 or d4.Divisao_Superior = 2919 or d4.Divisao_Superior = 2918 or d4.Divisao_Superior = 2917 or d4.Divisao_Superior = 3926
           or d4.Divisao_Superior = 3927 or d4.Divisao_Superior = 3413 or d4.Divisao_Superior = 3412 or d4.Divisao_Superior = 3866 or d4.Divisao_Superior = 5514 or d4.Divisao_Superior = 3934
           or d4.Divisao_Superior = 5808 or d4.Divisao_Superior = 5599)
    and d6.divisao = d4.divisao
    and (d6.divisaocom = PDivisao3 or PDivisao3 = 0)
    and d6.produto = PProduto;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVEISDIV6" (
    PNIVEL1 in Mult_padraoNiveis.NIVEL%type,
    PPADRAO in Mult_padraoNiveis.PADRAO%type,
    PDIVISAO3 in Tabela_NiveisDivisao.DIVISAO%type,
    PPRODUTO in Tabela_Divisoescomer.PRODUTO%type,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin

OPEN PCAMPO FOR
  Select d4.Divisao,
         d4.Divisao_Superior,
         d4.Nome,
         d4.UserName,
         d.Nivel,
         d2.NivelPai,
         d2.DivisaoPai
  from Mult_padraoNiveis d,
       Tabela_NiveisHierarq d1,
       Mult_PadraoDivisoes d2,
       Tabela_NiveisDivisao d3,
       Tabela_Divisoes d4,
       Tabela_Divisoescomer d6
  where d.Nivel = d1.Nivel
    and d.Nivel = Pnivel1
    and d.padrao = PPadrao
    and d2.Padrao = d.Padrao
    and d2.Nivel = d.Nivel
    and d3.Nivel = d2.Nivel
    and d3.Divisao = d2.Divisao
    and d4.Divisao = d3.Divisao
    and d6.divisao = d4.divisao
    and (d6.divisaocom = PDivisao3 or PDivisao3 = 0)
    and d6.produto = PProduto;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVEISDIV7" 
(
    PNIVEL1  in Mult_padraoNiveis.NIVEL%type,
    PPADRAO  in Mult_padraoNiveis.PADRAO%type,
    PPRODUTO in Tabela_Divisoescomer.PRODUTO%type,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
  Select d4.Divisao
  from Mult_padraoNiveis d,
       Tabela_NiveisHierarq d1,
       Mult_PadraoDivisoes d2,
       Tabela_NiveisDivisao d3,
       Tabela_Divisoes d4,
       Tabela_Divisoescomer d6
  where d.Nivel = d1.Nivel
     and d.Nivel = Pnivel1
     and d.padrao = PPadrao
     and d2.Padrao = d.Padrao
     and d2.Nivel = d.Nivel
     and d3.Nivel = d2.Nivel
     and d3.Divisao = d2.Divisao
     and d4.Divisao = d3.Divisao
     and d6.divisao = d4.divisao
     and d6.produto = PProduto;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVELBONUSAUTO" 
(
    PPRODUTO IN MULT_PRODUTOS.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT NIVEL, NIVEL AS DESCRICAO, NIVEL AS NIVELBONUSAUTO FROM MULT_PRODUTOSBONUS  WHERE PRODUTO = PPRODUTO ORDER BY NIVEL, DESCRICAO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVELBONUSTOKIO" 
(
    PPRODUTO IN MULT_PRODUTOS.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
SELECT NIVEL AS DESCRICAO, BONUS AS BONUS_REN_TOKIO, BONUS
  FROM MULT_PRODUTOSBONUSTOKIO
 WHERE PRODUTO = PPRODUTO
 ORDER BY NIVEL;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVELDM" (
    PPRODUTO IN MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT CHAVE1, TEXTO AS DESCRICAO, CHAVE1 AS NIVELDM
  FROM MULT_PRODUTOSTABRG
  WHERE PRODUTO = PPRODUTO AND TABELA = 21 AND VALOR < 1000001;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_NIVELDP" (
    PPRODUTO IN MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT CHAVE1, TEXTO AS DESCRICAO, CHAVE1 AS NIVELDP
  FROM MULT_PRODUTOSTABRG
  WHERE PRODUTO = PPRODUTO AND TABELA = 22 AND VALOR < 1000001;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_OBSCOBERTURA1" 
(
    PCALCULO IN MULT_CALCULOCOB.CALCULO%TYPE,
    PITEM IN MULT_CALCULOCOB.ITEM%TYPE,
    PCOBERTURA IN MULT_CALCULOCOB.COBERTURA%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT OBSERVACAO as OBS FROM MULT_CALCULOCOB
  WHERE CALCULO = PCALCULO
  AND ITEM    = PITEM
  AND COBERTURA = PCOBERTURA;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_OPCAOCOBERTURA1" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type
,PCOBERTURA in MULT_CALCULOCOB.COBERTURA%Type,
 PCAMPO OUT Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      SELECT OPCAO FROM MULT_CALCULOCOB
      WHERE CALCULO = PCALCULO
      AND ITEM    = PITEM
      AND COBERTURA = PCOBERTURA;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_PADRAONIVEIS1" 
(
   PNIVELEXCLUI IN Mult_padraoNiveis.nivel%TYPE,
   PPADRAO IN Mult_padraoNiveis.PADRAO%TYPE,
   PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  select d.Nivel, d1.Descricao from Mult_padraoNiveis d, Tabela_NiveisHierarq d1
  where d.Nivel = d1.Nivel
    and d.nivel <> Pnivelexclui
    and d.padrao = Ppadrao;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_PRODUTOBONUS1" 
(PPRODUTO in MULT_PRODUTOSBONUS.PRODUTO%Type
,PNIVEL in MULT_PRODUTOSBONUS.NIVEL%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
     SELECT NIVEL, BONUSAUTO FROM MULT_PRODUTOSBONUS
     WHERE PRODUTO = pproduto
     AND NIVEL = pnivel;
END;
/


CREATE OR REPLACE procedure LISTA_PROLABORE1
(PCALCULO in mult_calculodivisoes.CALCULO%Type
,PPRODUTO in tabela_divisoescomer.PRODUTO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
    select d3.divisao, d3.Pro_Labore, d4.Divisao_superior,
          d4.InicioVigencia, d4.FinalVigencia, d3.desconto
   from mult_calculodivisoes d, mult_calculodivisoes d2,
        tabela_divisoescomer d3, Tabela_divisoes d4, 
        mult_calculo d5
   where d.calculo = PCALCULO
      and d.nivel = 4
      and d2.calculo = d.calculo
      and d2.nivel = 1
      and d3.divisao = d.Divisao
      and d3.divisaoCom = d2.Divisao
      and d3.produto = PPRODUTO
      and d3.divisao = d4.divisao
      and d5.calculo = d.calculo
      and d5.iniciovigencia between d3.iniciovigencia and d3.finalvigencia;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_PROLABORE2" 
(PCALCULO in mult_calculodivisoes.CALCULO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
    select d.Divisao from mult_calculodivisoes d
    where
    d.calculo = PCALCULO
    and d.nivel = 4;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRMAPADADOS" (
    PPRODUTO     IN Mult_produtosTabrg.PRODUTO%TYPE,
    PVIGENCIA    IN INTEGER,
    PGRUPO       IN VARCHAR2,
    PQUESTAO     IN FLOAT,
    PCAMPO       OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
    OPEN PCAMPO FOR
        SELECT T3.RESPOSTANIVEL1, T3.QUESTAONIVEL2, T3.MAPADADOS
        FROM MULT_PRODUTOSQBRNIVEL1 T1, MULT_PRODUTOSQBRRESPOSTAS T2, MULT_PRODUTOSQBRNIVEL2 T3
        WHERE T1.PRODUTO     =   PPRODUTO          AND
            T1.VIGENCIA    =   PVIGENCIA         AND
            T1.CODIGO      =   PGRUPO            AND
            T1.QUESTAO     =   PQUESTAO          AND
            T2.QUESTAO     =   T1.QUESTAO        AND
            ((T2.COBERTURA =   17 AND PPRODUTO = 10) OR (T2.COBERTURA = 63 AND PPRODUTO = 11)) AND
            T2.VIGENCIA    =   T1.VIGENCIA       AND
            T2.PRODUTO     =   10                AND
            T2.RESPOSTA    =   T3.RESPOSTANIVEL1 AND
            T3.CODIGO      =   T1.CODIGO         AND
            T3.VIGENCIA    =   T1.VIGENCIA       AND
            T3.PRODUTO     =   PPRODUTO          AND
            T3.MAPADADOS IS NOT NULL;
    IF NOT PCAMPO%ISOPEN THEN
        OPEN PCAMPO FOR
             SELECT NULL RESPOSTANIVEL1, NULL QUESTAONIVEL2, NULL MAPADADOS FROM DUAL WHERE 1=2;
    END IF;
END;
/


CREATE OR REPLACE PROCEDURE LISTA_QBRRESP1 (
    PPRODUTO     IN Mult_produtosTabrg.PRODUTO%TYPE,
    PVIGENCIA    IN INTEGER,
    PREGIAO      IN INTEGER,
    PQUESTAO     IN INTEGER,
    PCAMPO       OUT TYPES.CURSOR_TYPE
)
IS
v_0     NUMBER  :=      0;
v_1     NUMBER  :=      1;
v_10    NUMBER  :=      10;
v_11    NUMBER  :=      11;
v_17    NUMBER  :=      17;
v_63    NUMBER  :=      63;
v_633   NUMBER  :=      633;
v_636   NUMBER  :=      636;
--

BEGIN
    OPEN PCAMPO FOR
        SELECT T2.RESPOSTA, T2.DESCRICAO AS DESCRICAORESPOSTA, T2.DESCRICAO2 DESCRICAORESPOSTA2,
            T1.AGRUPAMENTO AS AGRUPAMENTOREGIAOQBR, T2.INDIMPRESSAO AS IMPRIME, T2.PERCIMPRESSAO
        FROM MULT_PRODUTOSQBRAGRUPREG T1, MULT_PRODUTOSQBRRESPOSTAS T2
        WHERE T1.PRODUTO  = PPRODUTO    AND
            T1.VIGENCIA = PVIGENCIA   AND
            T1.REGIAO   = PREGIAO     AND
            T2.QUESTAO  = PQUESTAO    AND
            T2.PRODUTO  = v_10          AND
            T2.VIGENCIA = T1.VIGENCIA AND
            T2.RESPOSTA <> v_633        AND
            T2.RESPOSTA <> v_636        AND
            T2.MOSTRA   = v_1           AND
            (T2.AGRUPAMENTO = T1.AGRUPAMENTO OR T2.AGRUPAMENTO = v_0) AND
            ((T2.COBERTURA  = v_17 AND PPRODUTO = v_10) OR (T2.COBERTURA = v_63 AND PPRODUTO = v_11))
            ORDER BY DESCRICAORESPOSTA;
 END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRRESP2" 
(PCALCULO in Mult_CalculoQbr.CALCULO%Type
,PITEM in Mult_CalculoQbr.ITEM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
    Select questao, resposta, subresposta, agrupamentoregiaoqbr  from Mult_CalculoQbr
    where calculo = PCALCULO
    and item = PITEM
    and valida = 'S';
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRSUBQUEST1" (
    PPRODUTO    IN MULT_PRODUTOS.PRODUTO%TYPE,
    PVIGENCIA   IN INTEGER,
    PGRUPO      IN VARCHAR2,
    PRESPOSTA   IN INTEGER,
    PNIVEL      IN INTEGER,
    PSUBQUESTAO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
    IF PNIVEL = 1 THEN
        OPEN PSUBQUESTAO FOR
            SELECT DISTINCT T1.QUESTAONIVEL2 AS SUBQUESTAO, T1.MAPADADOS
            FROM MULT_PRODUTOSQBRNIVEL2 T1
            WHERE T1.PRODUTO   =  PPRODUTO  AND
                  T1.VIGENCIA  = PVIGENCIA   AND
                  T1.CODIGO    = PGRUPO AND
                  T1.RESPOSTANIVEL1 = PRESPOSTA;
    ELSIF PNIVEL = 2 THEN
        OPEN PSUBQUESTAO FOR
            SELECT DISTINCT  T1.QUESTAONIVEL3 AS SUBQUESTAO, T1.MAPADADOS
            FROM MULT_PRODUTOSQBRNIVEL3 T1
            WHERE T1.PRODUTO   =  PPRODUTO  AND
                  T1.VIGENCIA  = PVIGENCIA   AND
                  T1.CODIGO    = PGRUPO AND
                  T1.RESPOSTANIVEL2 = PRESPOSTA;
    END IF;
    IF NOT PSUBQUESTAO%ISOPEN THEN
      OPEN PSUBQUESTAO FOR SELECT 0 SUBQUESTAO FROM DUAL WHERE 1=2;
    END IF;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRSUBRESPDISP" (
    PPRODUTO IN FLOAT,
    PVIGENCIA IN INTEGER,
    PRESPOSTA IN INTEGER,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
    OPEN PCAMPO FOR
        SELECT T1.DISPOSITIVO, T1.TIPO, T1.DESCRICAO, T1.INDGERENCIADORA
        FROM MULT_PRODUTOSQBRDISPSEG T1
        WHERE T1.PRODUTO  = PPRODUTO  AND
            T1.VIGENCIA = PVIGENCIA AND
            T1.RESPOSTA = PRESPOSTA
        ORDER BY T1.DESCRICAO;
 END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRSUBRESPGERENC" (
    PPRODUTO IN FLOAT,
    PVIGENCIA IN INTEGER,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
    OPEN PCAMPO FOR
        SELECT GERENCIADORA, DESCRICAO
        FROM MULT_PRODUTOSQBRGERENCIADORAS T1
        WHERE PRODUTO  = PPRODUTO  AND T1.VIGENCIA = PVIGENCIA
        ORDER BY DESCRICAO;
 END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRSUBRESP1" (
    PPRODUTO   IN Mult_ProdutosTabRg.PRODUTO%TYPE,
    PTABELA    IN Mult_ProdutosTabRg.TABELA%TYPE,
    PRESPOSTA1 IN Mult_ProdutosTabRg.chave1%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  select Chave1 as RESPOSTA, chave2 as SUBRESPOSTA, texto as DescricaosubResposta from mult_produtostabrg
  where Produto = Pproduto
   and   tabela  = Ptabela
   and   chave1 = Presposta1
  order by DescricaosubResposta;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRSUBRESP2" (
    PPRODUTO   IN Mult_ProdutosTabRg.PRODUTO%TYPE,
    PTABELA    IN Mult_ProdutosTabRg.TABELA%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  select Chave1 as SUBRESPOSTA, texto as DescricaosubResposta from mult_produtostabrg
  where Produto = Pproduto
   and   tabela  = Ptabela;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBRSUBRESP3" (
    PPRODUTO      IN Mult_ProdutosTabRg.PRODUTO%TYPE,
    PVIGENCIA     IN INTEGER,
    PRESPOSTA     IN INTEGER,
    PDISPOSITIVO  IN INTEGER,
    PCAMPO        OUT TYPES.CURSOR_TYPE
 )
IS
BEGIN
    OPEN PCAMPO FOR
        SELECT D2.RANKING, D1.INDGERENCIADORA
        FROM MULT_PRODUTOSQBRTIPOSDISP D2, MULT_PRODUTOSQBRDISPSEG D1
        WHERE D2.PRODUTO     = 10          AND
            D2.VIGENCIA    = D1.VIGENCIA AND
            D2.TIPO        = D1.TIPO     AND
            D1.PRODUTO     = PPRODUTO    AND
            D1.VIGENCIA    = PVIGENCIA   AND
            D1.RESPOSTA    = PRESPOSTA   AND
            D1.DISPOSITIVO = PDISPOSITIVO;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBR2" (
    PPRODUTO     IN Mult_produtosTabrg.PRODUTO%TYPE,
    PVIGENCIA    IN INTEGER,
    PCANALVENDA  IN INTEGER,
    PTIPOPROD    IN VARCHAR2,
    PTIPOPESSOA  IN VARCHAR2,
    PCATEGVEIC   IN INTEGER,
    PTIPOVEICULO IN INTEGER,
    PTIPOUSOVEIC IN VARCHAR2,
    PINICIOVIGENCIA IN DATE,
    PCAMPO       OUT TYPES.CURSOR_TYPE
)
IS
begin
    OPEN PCAMPO FOR
        SELECT T1.CODIGO AS GRUPO,T1.INDTEXTO,T1.DESCRICAO AS DESCRGRUPO, T3.DESCRICAO,  T2.QUESTAO, T2.ORDEM * 1000000 AS ORDEM, MAPADADOS
        FROM MULT_PRODUTOSQBRGRUPOS T1, MULT_PRODUTOSQBRNIVEL1 T2, MULT_PRODUTOSQBRQUESTOES T3
        WHERE T1.PRODUTO    = PPRODUTO    AND
            T1.VIGENCIA   = PVIGENCIA   AND
            T1.CANALVENDA = PCANALVENDA AND
            T1.TIPOPROD   = PTIPOPROD   AND
            T1.TIPOPESSOA = PTIPOPESSOA AND
            ((T1.CATEGVEIC  = PCATEGVEIC AND T1.CD_TIPO_VEICU = 0)  OR (T1.CATEGVEIC = 0 AND T1.CD_TIPO_VEICU = PTIPOVEICULO)) AND
            T1.TIPOUSOVEIC  = PTIPOUSOVEIC  AND
            T2.PRODUTO    = T1.PRODUTO  AND
            T2.VIGENCIA   = T1.VIGENCIA AND
            T2.CODIGO     = T1.CODIGO   AND
            T2.VERSAO     = T1.VERSAO   AND
            T3.PRODUTO    = T1.PRODUTO  AND
            T3.VIGENCIA   = T1.VIGENCIA AND
            ((T3.COBERTURA  = 17 AND PPRODUTO = 10) OR (T3.COBERTURA = 63 AND PPRODUTO = 11)) AND
            T3.QUESTAO    = T2.QUESTAO AND
            PINICIOVIGENCIA BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN
        UNION
        SELECT T1.CODIGO AS GRUPO,T1.INDTEXTO,T1.DESCRICAO AS DESCRGRUPO, T6.DESCRICAO, T3.QUESTAONIVEL2 AS QUESTAO, (T2.ORDEM * 1000000) + (T3.QUESTAONIVEL2 * 1000)  AS ORDEM, T3.MAPADADOS
        FROM MULT_PRODUTOSQBRGRUPOS T1, MULT_PRODUTOSQBRNIVEL1 T2, MULT_PRODUTOSQBRNIVEL2 T3, MULT_PRODUTOSQBRRESPOSTAS T5, MULT_PRODUTOSQBRQUESTOES T6
        WHERE T1.PRODUTO    = PPRODUTO     AND
            T1.VIGENCIA   = PVIGENCIA    AND
            T1.CANALVENDA = PCANALVENDA  AND
            T1.TIPOPROD   = PTIPOPROD    AND
            T1.TIPOPESSOA = PTIPOPESSOA  AND
            ((T1.CATEGVEIC  = PCATEGVEIC AND T1.CD_TIPO_VEICU = 0)  OR (T1.CATEGVEIC = 0 AND T1.CD_TIPO_VEICU = PTIPOVEICULO)) AND
            T1.TIPOUSOVEIC  = PTIPOUSOVEIC  AND
            T2.PRODUTO    = T1.PRODUTO   AND
            T2.VIGENCIA   = T1.VIGENCIA  AND
            T2.CODIGO     = T1.CODIGO    AND
            T2.VERSAO     = T1.VERSAO    AND
            T3.PRODUTO    = T1.PRODUTO   AND
            T3.VIGENCIA   = T1.VIGENCIA  AND
            T3.CODIGO     = T1.CODIGO    AND
            T3.VERSAO     = T1.VERSAO    AND
            T5.PRODUTO    = 10           AND
            T5.VIGENCIA   = T1.VIGENCIA  AND
            ((T5.COBERTURA  = 17 AND PPRODUTO = 10) OR (T5.COBERTURA = 63 AND PPRODUTO = 11)) AND
            T5.RESPOSTA   = T3.RESPOSTANIVEL1 AND
            T5.QUESTAO    =  T2.QUESTAO  AND
            T6.PRODUTO    = T1.PRODUTO   AND
            T6.VIGENCIA   = T1.VIGENCIA  AND
            T6.COBERTURA  = T5.COBERTURA AND
            T6.QUESTAO    = T3.QUESTAONIVEL2 AND
            PINICIOVIGENCIA BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN
        UNION
        SELECT T1.CODIGO AS GRUPO,T1.INDTEXTO,T1.DESCRICAO AS DESCRGRUPO, T7.DESCRICAO, T4.QUESTAONIVEL3 AS QUESTAO,(T2.ORDEM * 1000000) + (T3.QUESTAONIVEL2 * 1000) + T4.QUESTAONIVEL3  AS ORDEM, T3.MAPADADOS
        FROM MULT_PRODUTOSQBRGRUPOS T1, MULT_PRODUTOSQBRNIVEL1 T2, MULT_PRODUTOSQBRNIVEL2 T3, MULT_PRODUTOSQBRNIVEL3 T4, MULT_PRODUTOSQBRRESPOSTAS T5 , MULT_PRODUTOSQBRRESPOSTAS T6, MULT_PRODUTOSQBRQUESTOES T7
        WHERE T1.PRODUTO    = PPRODUTO    AND
            T1.VIGENCIA   = PVIGENCIA   AND
            T1.CANALVENDA = PCANALVENDA AND
            T1.TIPOPROD   = PTIPOPROD   AND
            T1.TIPOPESSOA = PTIPOPESSOA AND
            ((T1.CATEGVEIC  = PCATEGVEIC AND T1.CD_TIPO_VEICU = 0)  OR (T1.CATEGVEIC = 0 AND T1.CD_TIPO_VEICU = PTIPOVEICULO)) AND
            T1.TIPOUSOVEIC  = PTIPOUSOVEIC  AND
            T2.PRODUTO    = T1.PRODUTO  AND
            T2.VIGENCIA   = T1.VIGENCIA AND
            T2.CODIGO     = T1.CODIGO   AND
            T2.VERSAO     = T1.VERSAO   AND
            T3.PRODUTO    = T1.PRODUTO  AND
            T3.VIGENCIA   = T1.VIGENCIA AND
            T3.CODIGO     = T1.CODIGO   AND
            T3.VERSAO     = T1.VERSAO   AND
            T4.PRODUTO    = T1.PRODUTO  AND
            T4.VIGENCIA   = T1.VIGENCIA AND
            T4.CODIGO     = T1.CODIGO   AND
            T4.VERSAO     = T1.VERSAO   AND
            T5.PRODUTO    = 10          AND
            T5.VIGENCIA   = T1.VIGENCIA AND
            ((T5.COBERTURA = 17 AND PPRODUTO = 10) OR (T5.COBERTURA = 63 AND PPRODUTO = 11)) AND
            T5.RESPOSTA   = T3.RESPOSTANIVEL1 AND
            T5.QUESTAO    = T2.QUESTAO  AND
            T6.PRODUTO = T1.PRODUTO AND
             T6.VIGENCIA   = T4.VIGENCIA  AND
            T6.COBERTURA  = T5.COBERTURA AND
            T6.RESPOSTA   = T4.RESPOSTANIVEL2 AND
            T6.QUESTAO    = T3.QUESTAONIVEL2  AND
            T7.PRODUTO    = T1.PRODUTO  AND
            T7.VIGENCIA   = T1.VIGENCIA AND
            T7.COBERTURA  = T5.COBERTURA AND
            T7.QUESTAO    = T4.QUESTAONIVEL3 AND
            PINICIOVIGENCIA BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN
   ORDER BY ORDEM;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBR3" (
    PMODELO  IN Tabela_veiculomodelo.MODELO%TYPE,
    PPRODUTO IN Mult_produtosTabrg.PRODUTO%TYPE,
    PVERSAO  IN Mult_produtosTabrg.TABELA%TYPE,
    PVERSAO2 IN Mult_produtosTabrg.TABELA%TYPE,
    PVERSAO3 IN Mult_produtosTabrg.TABELA%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
  select d2.Chave2 as Questao, d2.texto as Descricao from Tabela_veiculomodelo d,
    Mult_produtosTabrg d1, Mult_ProdutosTabRg d2
  where d.modelo = PMODELO
      and d1.produto = PPRODUTO
      and d1.tabela = PVERSAO
      and d1.Chave1 = d.modelo
      and (d1.valor = 1 or d2.Chave2 = 222)
      and d2.produto = d1.produto
      and d2.tabela = PVERSAO2
      and d2.valor = 0
      and d2.chave1 = 63
Union all
  select d2.Chave2 as Questao, d2.texto as Descricao from Tabela_veiculomodelo d,
    Mult_produtosTabrg d1, Mult_ProdutosTabRg d2, Mult_ProdutosTabRg d3
  where d.modelo = PMODELO
      and d1.produto = PPRODUTO
      and d1.tabela = PVERSAO
      and d1.Chave1 = d.modelo
      and d1.valor = 1
      and d2.produto = d1.produto
      and d2.tabela = PVERSAO2
      and d2.valor = 1
      and d3.produto = d1.produto
      and d3.tabela = PVERSAO3
      and d3.chave1 = d2.chave2
      and (d3.chave2 = d.cod_referencia or d3.chave2 = 12)
      and d2.chave1 = 63;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBR4" (
    PPRODUTO     IN Mult_produtosTabrg.PRODUTO%TYPE,
    PVIGENCIA    IN INTEGER,
    PQUESTAO      IN INTEGER,
    PMODELO      IN INTEGER,
    PREGIAO      IN INTEGER,
    PANOMODELO   IN INTEGER,
    PCAMPO       OUT TYPES.CURSOR_TYPE
)
IS
begin
    OPEN PCAMPO FOR
        SELECT DISTINCT D4.DESCRICAO AS DISPOSITIVO, D4.TIPO,D4.RANKING, D3.RESPCOMODATO, D3.RESPNAOCOMODATO, D3.CODCOMODATO
        FROM MULT_PRODUTOSQBRTIPOSDISP D4, MULT_PRODUTOSQBROFERTACOMODATO D3, MULT_PRODUTOSTABRG D2, TABELA_VEICULOMODELO D1
        WHERE D4.PRODUTO        = 10               AND
                D4.VIGENCIA     = PVIGENCIA        AND
                D3.PRODUTO      = PPRODUTO         AND
                D3.VIGENCIA     = D4.VIGENCIA      AND
                D3.QUESTAO      = PQUESTAO         AND
                D1.MODELO       = PMODELO          AND
                D3.AGRUPVEIC    = D1.COD_REFERENCIA AND
                D2.PRODUTO      = PPRODUTO          AND
                D2.TABELA       = 25                AND
                D2.VALOR4       = PREGIAO           AND
                D3.AGRUPREGIAO  = D2.CHAVE1         AND
                D3.AGRUPANOMOD  = PANOMODELO        AND
                D3.TIPODISP     = D4.TIPO;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QBR5" (
    PPRODUTO     IN INTEGER,
    PVIGENCIA    IN INTEGER,
    PCODCOMODATO IN VARCHAR,
    PCALCULO     IN MULT_CALCULO.CALCULO%TYPE,
    PITEM        IN MULT_CALCULO.ITEM%TYPE,
    PCAMPO       OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
    OPEN PCAMPO FOR
        SELECT T1.DESCRICAO, T2.TIPODISP AS TIPO
        FROM MULT_PRODUTOSQBRDISPCOMODATO T1,
             MULT_PRODUTOSQBROFERTACOMODATO T2,
             MULT_CALCULO T3,
             TABELA_VEICULOMODELO T4
        WHERE T1.PRODUTO      =  10
            AND T1.VIGENCIA     =  PVIGENCIA
            AND T1.CODCOMODATO  =  PCODCOMODATO
            AND T2.PRODUTO      =  PPRODUTO
            AND T2.VIGENCIA     =  T1.VIGENCIA
            AND T2.CODCOMODATO  =  T1.CODCOMODATO
            AND T2.AGRUPREGIAO  =  T3.COD_CIDADE
            AND T3.CALCULO      =  PCALCULO
            AND T3.ITEM         =  PITEM
            AND T4.MODELO       =  T3.MODELO
            AND T2.AGRUPVEIC    =  T4.COD_REFERENCIA
            AND T2.AGRUPANOMOD  =  T3.ANOMODELO;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_QTDCOB1" 
(
    PCALCULO IN Mult_calculoCob.CALCULO%TYPE,
    PITEM IN Mult_calculoCob.ITEM%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  Select Count(*) AS TOTAL from Mult_calculoCob where
   Calculo= PCalculo
   and Item= PItem;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_REGIAOPORCEP1" 
(PPRODUTO in mult_produtostabrg.PRODUTO%Type
,PCHAVE1 in mult_produtostabrg.CHAVE1%Type
,PCHAVE2 in mult_produtostabrg.CHAVE2%Type
,PCHAVE3 in mult_produtostabrg.CHAVE3%Type
,PVIGENCIA IN DATE
,PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
         Select d1.VALOR4
     from mult_produtostabrg d, mult_produtostabrg d1
     where d.Produto = Pproduto
     and   d.tabela  = 50
     and   d.chave1  = Pchave1
     and   d.chave2 <= Pchave2
     and   d.chave3 >= Pchave3
     and   PVigencia between d.dt_inico_vigen and d.dt_fim_vigen
     and   d1.produto = d.Produto and d1.tabela = 25 and d1.valor5 = d.valor
     and   PVigencia between d1.dt_inico_vigen and d1.dt_fim_vigen
     order by d.chave3 desc;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_REGIAOPORCEP2" 
( PPRODUTO in mult_produtostabrg.PRODUTO%Type
,PCHAVE1 in mult_produtostabrg.CHAVE1%Type
,PCHAVE2 in mult_produtostabrg.CHAVE2%Type
,PCHAVE3 in mult_produtostabrg.CHAVE3%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
     Select d1.Chave1, d.chave3
     from mult_produtostabrg d, mult_produtostabrg d1
     where d.Produto = Pproduto
       and   d.tabela  = 50
       and   d.chave1  = Pchave1
       and   d.chave2 <= Pchave2
       and   d.chave3 >= Pchave3
       and   d1.produto = D.PRODUTO and d1.tabela = 25 and d1.valor5 = d.valor
     order by d.chave3 desc;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_REGIAOPORCEP3" (
    PPRODUTO IN mult_produtostabrg.PRODUTO%TYPE,
    PVERSAO  IN mult_produtostabrg.CHAVE1%TYPE,
    PCHAVE2  IN mult_produtostabrg.CHAVE2%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  Select d.valor from mult_produtostabrg d
  where d.produto = PPRODUTO and d.tabela = 50
    and d.chave1 = PVERSAO
    and d.chave2 <= PCHAVE2
    and d.chave3 >= PCHAVE2
  order by d.chave3 desc;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_TAB1" 
(PPRODUTO in MULT_PRODUTOSTABRG.PRODUTO%Type
,PTABELA in MULT_PRODUTOSTABRG.TABELA%Type
,PCHAVE1 in MULT_PRODUTOSTABRG.CHAVE1%Type
,PCHAVE2 in MULT_PRODUTOSTABRG.CHAVE2%Type
,PCHAVE3 in MULT_PRODUTOSTABRG.CHAVE3%Type
,PCHAVE4 in MULT_PRODUTOSTABRG.CHAVE4%Type
,Pchave5 In Mult_Produtostabrg.Chave5%Type
,PVIGENCIA in MULT_PRODUTOSTABRG.DT_INICO_VIGEN%Type
,PCAMPO out Types.cursor_type)
IS
BEGIN
	DECLARE
	   V_SELECT VARCHAR2(255);
	BEGIN
	  V_SELECT := 'SELECT VALOR,VALOR2,VALOR3,VALOR4,VALOR5 FROM VW_TABRG_P'||TO_CHAR(PPRODUTO)||'_T'||TO_CHAR(PTABELA)||
				  '   WHERE CHAVE1  = '||TO_CHAR(PCHAVE1) ||
				  '   AND CHAVE2    = '||TO_CHAR(PCHAVE2) ||
				  '   AND CHAVE3    = '||TO_CHAR(PCHAVE3) ||
				  '   AND CHAVE4    = '||TO_CHAR(PCHAVE4) ||
				  '   AND CHAVE5    = '||To_Char(Pchave5) ||
				  '   AND TO_DATE('''|| To_Char(Pvigencia,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')' ||
				  '       BETWEEN DT_INICO_VIGEN AND DT_FIM_VIGEN';
			   
		OPEN PCAMPO FOR V_SELECT;
	END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_TAB1_2" 
(PPRODUTO in MULT_PRODUTOSTABRG.PRODUTO%Type
,PTABELA in MULT_PRODUTOSTABRG.TABELA%Type
,PCHAVE1 in MULT_PRODUTOSTABRG.CHAVE1%Type
,PCHAVE2 in MULT_PRODUTOSTABRG.CHAVE2%Type
,PCHAVE3 in MULT_PRODUTOSTABRG.CHAVE3%Type
,PCHAVE4 in MULT_PRODUTOSTABRG.CHAVE4%Type
,PCHAVE5 in MULT_PRODUTOSTABRG.CHAVE5%Type
,PVALOR1 out NUMBER
,PVALOR2 out NUMBER
,PVALOR3 out NUMBER
,PVALOR4 out NUMBER
,PVALOR5 out NUMBER
)
IS
BEGIN
  DECLARE
     V_SELECT VARCHAR2(255);
     PCAMPO Types.Cursor_Type;
  BEGIN
    V_SELECT := 'SELECT VALOR,VALOR2,VALOR3,VALOR4,VALOR5 FROM VW_TABRG_P'||TO_CHAR(PPRODUTO)||'_T'||TO_CHAR(PTABELA)||
                '   WHERE CHAVE1  = '||TO_CHAR(PCHAVE1) ||
                '   AND CHAVE2    = '||TO_CHAR(PCHAVE2) ||
                '   AND CHAVE3    = '||TO_CHAR(PCHAVE3) ||
                '   AND CHAVE4    = '||TO_CHAR(PCHAVE4) ||
                '   AND CHAVE5    = '||TO_CHAR(PCHAVE5);
    OPEN PCAMPO FOR V_SELECT;
    if PCAMPO%NOTFOUND then
      PVALOR1 := 0;
      PVALOR2 := 0;
      PVALOR3 := 0;
      PVALOR4 := 0;
      PVALOR5 := 0;
    else
      FETCH PCAMPO INTO PVALOR1, PVALOR2, PVALOR3, PVALOR4, PVALOR5;
    end if;
  END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_TAB2" 
(PPRODUTO in MULT_PRODUTOSTABRG.PRODUTO%Type
,PTABELA in MULT_PRODUTOSTABRG.TABELA%Type
,PCHAVE1 in MULT_PRODUTOSTABRG.CHAVE1%Type
,PCHAVE2 in MULT_PRODUTOSTABRG.CHAVE2%Type
,PCHAVE3 in MULT_PRODUTOSTABRG.CHAVE3%Type
,PCHAVE4 in MULT_PRODUTOSTABRG.CHAVE4%Type
,PCHAVE5 in MULT_PRODUTOSTABRG.CHAVE5%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
  DECLARE
    V_SELECT VARCHAR2(255);
BEGIN
  V_SELECT := 'SELECT VALOR,VALOR2,VALOR3,VALOR4,VALOR5 FROM VW_TABRG_P'||TO_CHAR(PPRODUTO)||'_T'||TO_CHAR(PTABELA)||
              '   WHERE CHAVE1  =  '||TO_CHAR(PCHAVE1) ||
              '   AND CHAVE2    =  '||TO_CHAR(PCHAVE2) ||
              '   AND CHAVE3    =  '||TO_CHAR(PCHAVE3) ||
              '   AND CHAVE4    <= '||TO_CHAR(PCHAVE4) ||
              '   AND CHAVE5    >= '||TO_CHAR(PCHAVE5);
   OPEN PCAMPO FOR V_SELECT;
END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_TAB3" (
    PPRODUTO IN mult_produtostabrg.PRODUTO%TYPE,
    PTABELA IN mult_produtostabrg.TABELA%TYPE,
    PDATAVIGEN1 IN mult_produtostabrg.DT_INICO_VIGEN%TYPE,
		PDATAVIGEN2 IN mult_produtostabrg.DT_FIM_VIGEN%TYPE,
    PTEXTO IN mult_produtostabrg.TEXTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
  DECLARE
    V_SELECT VARCHAR2(255);
BEGIN
  V_SELECT := 'SELECT VALOR FROM VW_TABRG_P'||TO_CHAR(PPRODUTO)||'_T'||TO_CHAR(PTABELA)||
              ' WHERE DT_INICO_VIGEN <= TO_DATE('''|| TO_CHAR(PDATAVIGEN1,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')'||
							' AND DT_FIM_VIGEN >= TO_DATE('''|| TO_CHAR(PDATAVIGEN2,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')'||
              ' AND TEXTO = '||TRIM(PTEXTO);
  OPEN PCAMPO FOR V_SELECT;
END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_TAB4" (
    PPRODUTO IN mult_produtostabrg.PRODUTO%TYPE,
    PTABELA IN mult_produtostabrg.TABELA%TYPE,
    PDATAVIGEN1 IN mult_produtostabrg.DT_INICO_VIGEN%TYPE,
		PDATAVIGEN2 IN mult_produtostabrg.DT_FIM_VIGEN%TYPE,
    PCHAVE2 IN mult_produtostabrg.CHAVE2%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
  DECLARE
    V_SELECT VARCHAR2(1000);
BEGIN
  V_SELECT := 'SELECT CHAVE3, CHAVE4, CHAVE5, VALOR FROM VW_TABRG_P'||TO_CHAR(PPRODUTO)||'_T'||TO_CHAR(PTABELA)||
              ' WHERE DT_INICO_VIGEN <= TO_DATE('''|| TO_CHAR(PDATAVIGEN1,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')'||
							' AND DT_FIM_VIGEN >= TO_DATE('''|| TO_CHAR(PDATAVIGEN2,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')'||
              ' AND CHAVE2  = '||TO_CHAR(PCHAVE2);
  OPEN PCAMPO FOR V_SELECT;
END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_TAXA1" 
(PCOD_MODELO in REAL_TAXASAUTO.COD_MODELO%Type
,PANO_MODELO in REAL_TAXASAUTO.ANO_MODELO%Type
,PZERO_KM in REAL_TAXASAUTO.ZERO_KM%Type
,PCOD_COB in REAL_TAXASAUTO.COD_COB%Type
,PCOD_REGIAO in REAL_TAXASAUTO.COD_REGIAO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
       SELECT TAXA_CASCO, TAXA_INC, TAXA_RINC, FRANQUIA, TAXA_FRANQ, FRQ_MINIMA, TAXA_CASCO_ANT, TAXA_INC_ANT, TAXA_RINC_ANT, FRANQUIA_ANT, TAXA_FRANQ_ANT, FRQ_MINIMA_ANT, SUBSCRICAO, SUBSCRICAO_ANT
     FROM REAL_TAXASAUTO
     WHERE COD_MODELO = PCOD_MODELO
       AND ANO_MODELO = PANO_MODELO
       AND ZERO_KM    = PZERO_KM
       AND COD_COB    = PCOD_COB
       AND COD_REGIAO = PCOD_REGIAO;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_TIPO_COBERTURA" 
(
    PPRODUTO IN MULT_PRODUTOSTIPOCOBERTURAS.PRODUTO%TYPE,
    PCAMPO   OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
  SELECT NOME AS DESCRICAO, TIPO_COBERTURA
  FROM MULT_PRODUTOSTIPOCOBERTURAS
  WHERE
    PRODUTO = PPRODUTO and TIPO_COBERTURA = 1

  UNION ALL

  SELECT NOME AS DESCRICAO, TIPO_COBERTURA
  FROM MULT_PRODUTOSTIPOCOBERTURAS
  WHERE
    PRODUTO = PPRODUTO and TIPO_COBERTURA = 2

  UNION ALL

  SELECT NOME AS DESCRICAO, TIPO_COBERTURA
  FROM MULT_PRODUTOSTIPOCOBERTURAS
  WHERE
    PRODUTO = PPRODUTO and TIPO_COBERTURA = 4

  UNION ALL

  SELECT NOME AS DESCRICAO, TIPO_COBERTURA
  FROM MULT_PRODUTOSTIPOCOBERTURAS
  WHERE
    PRODUTO = PPRODUTO and TIPO_COBERTURA = 3;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_TIPO_FRANQUIA" (
    PPRODUTO IN MULT_PRODUTOSTIPOSFRANQUIA.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
SELECT DESCRICAO, TIPO_FRANQUIA
  FROM MULT_PRODUTOSTIPOSFRANQUIA
 WHERE PRODUTO = PPRODUTO ORDER BY DESCRICAO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_USUARIOS" (
  PUSUARIO  IN REAL_USUARIOS.COD_USUARIO%TYPE,
  PCORRETOR IN REAL_USUARIOS.CORRETOR%TYPE,
  PCAMPO OUT TYPES.CURSOR_TYPE)
  IS
BEGIN
   DECLARE
    V_PADRAO_USUARIO  CHAR(1);
BEGIN
  SELECT PADRAOUSUARIO INTO V_PADRAO_USUARIO FROM REAL_USUARIOS
  WHERE COD_USUARIO = PUSUARIO AND
        CORRETOR = PCORRETOR AND
        INICIOVIGENCIA = (
                SELECT MAX(INICIOVIGENCIA) AS INICIOVIGENCIA FROM REAL_USUARIOS
                   WHERE COD_USUARIO = PUSUARIO AND
                         CORRETOR = PCORRETOR);


  IF V_PADRAO_USUARIO = 'C' THEN /* Se o usu·rio È padrao corretor ent„o */
    OPEN PCAMPO FOR              /* listar todos os usu·rios */
      SELECT DISTINCT T1.COD_USUARIO, T1.NOMEUSUARIO
      FROM REAL_USUARIOS T1 WHERE T1.CORRETOR = PCORRETOR AND
           T1.INICIOVIGENCIA = (
                SELECT MAX(T2.INICIOVIGENCIA) AS INICIOVIGENCIA FROM REAL_USUARIOS T2
                   WHERE T2.COD_USUARIO = T1.COD_USUARIO AND
                         T2.CORRETOR = PCORRETOR) ORDER BY T1.COD_USUARIO; 
  ELSIF V_PADRAO_USUARIO = 'R' THEN /* Caso contr·rio, listar apenas os */
    OPEN PCAMPO FOR                 /* usu·rios da mesma concession·ria */
      SELECT  T1.COD_USUARIO, T1.NOMEUSUARIO
      FROM  REAL_USUARIOS T1
      WHERE T1.CORRETOR = PCORRETOR AND
            T1.INICIOVIGENCIA = (
                SELECT MAX(INICIOVIGENCIA) AS INICIOVIGENCIA FROM REAL_USUARIOS T2
                   WHERE T2.COD_USUARIO = T1.COD_USUARIO AND
                         T2.CORRETOR = PCORRETOR) AND
            T1.COD_USUARIO IN (SELECT T3.COD_USUARIO
                            FROM VW_ESTIP_USUARIOS T3
                            WHERE T3.CORRETOR = PCORRETOR AND
                                  T3.ESTIPULANTE IN (SELECT ESTIPULANTE
                                                  FROM VW_ESTIP_USUARIOS T4
                                                  WHERE T4.COD_USUARIO = PUSUARIO AND
                                                        T4.CORRETOR = PCORRETOR))  ORDER BY T1.COD_USUARIO; 


  END IF;
END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES1" 
(
    PCALCULO IN Mult_calculoAces.CALCULO%TYPE,
    PITEM IN Mult_calculoAces.ITEM%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
Select Valor from Mult_calculoAces where
       Calculo = PCalculo
       and Item = PItem
       and Valor <> 0;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES2" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      Select Valor from Mult_calculoAces where
       Calculo = pCalculo
       and Item = pItem
       and TIPO > 0 AND Valor < 1;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES3" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      Select Valor from Mult_calculoAces where
       Calculo = pCalculo
       and Item = pItem
       and TIPO > 0 AND Valor > 1;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES4" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      Select Valor from Mult_calculoAces where
       Calculo = pCalculo
       and Item = pItem
       and TIPO = 1911 AND Valor > 0;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES5" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      Select Valor from Mult_calculoAces where
       Calculo = pCalculo
       and Item = pItem
       and (TIPO = 1884 OR TIPO = 1885 OR TIPO = 1886 OR TIPO = 1887 OR TIPO = 1904) AND Valor > 0;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES6" 
    (PCALCULO in MULT_CALCULOCOB.CALCULO%Type
     ,PITEM in MULT_CALCULOCOB.ITEM%Type,
      PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      Select sum(Valor) as VALOR  from Mult_calculoAces where
       Calculo = pCalculo
       and Item = pItem
       and (TIPO = 1884 OR TIPO = 1885 OR TIPO = 1886 OR TIPO = 1887 OR TIPO = 1904) AND Valor > 0;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORACES7" 
(PCALCULO in MULT_CALCULOCOB.CALCULO%Type
,PITEM in MULT_CALCULOCOB.ITEM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
      Select Sum(Valor) as valor from Mult_calculoAces where
       Calculo = pCalculo
       and Item = pItem
       and (TIPO <> 1884 and TIPO <> 1885 and TIPO <> 1886 and TIPO <> 1887 and TIPO <> 1904) AND Valor > 0;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORAPPDMH" (
    PPRODUTO IN MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT CHAVE1, TEXTO AS DESCRICAO, VALOR AS VALORAPPDMH
  FROM MULT_PRODUTOSTABRG
  WHERE PRODUTO = PPRODUTO AND TABELA = 20 AND CHAVE1 < 23;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORAPPDMH2" (
    PPRODUTO IN MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PVERSAO IN MULT_PRODUTOSTABRG.CHAVE1%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
SELECT CHAVE1, TEXTO AS DESCRICAO, VALOR AS VALORAPPDMH
  FROM MULT_PRODUTOSTABRG
 WHERE PRODUTO = PPRODUTO AND TABELA = 20
   AND ((PVERSAO = 1 AND CHAVE1 < 23) OR (PVERSAO = 2));
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORBASE1" (
    PMVERSAO1 MULT_PRODUTOSTABRG.CHAVE2%TYPE,
    PPRODUTO MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT T1.CHAVE2 AS MVERSAO, T1.CHAVE1,T1.TEXTO AS DESCRICAO, T1.CHAVE1 AS VALORBASE
  FROM MULT_PRODUTOSTABRG T1
  WHERE T1.PRODUTO = PPRODUTO AND T1.chave2 = PMVERSAO1 AND TABELA = 24;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORBASE2" (
    PMVERSAO1 IN MULT_PRODUTOSTABRG.TABELA%TYPE,
    PNMOD     IN TABELA_VEICULOMODELO.MODELO%TYPE,
    PCAMPO   OUT TYPES.CURSOR_TYPE
)
IS
begin
OPEN PCAMPO FOR
  SELECT PMVERSAO1,T2.MODELO,T1.CHAVE1,T1.TEXTO AS DESCRICAO, T1.CHAVE1 AS VALORBASE
  FROM MULT_PRODUTOSTABRG T1, tabela_veiculomodelo T2
  WHERE T1.TABELA = 24 AND
       T1.PRODUTO = 10 AND
       T2.MODELO = PNMOD AND
       ((T1.chave1 = T2.categ_tar1  AND PMVERSAO1 = 1) OR
        (T1.chave1 = T2.categ_tar11 AND PMVERSAO1 = 2))
 union

  SELECT PMVERSAO1,T2.MODELO,T1.CHAVE1,T1.TEXTO AS DESCRICAO, T1.CHAVE1 AS VALORBASE
  FROM MULT_PRODUTOSTABRG T1, tabela_veiculomodelo T2
  WHERE T1.TABELA = 24 AND
       T1.PRODUTO = 10 AND
       T2.MODELO = PNMOD AND
       ((T1.chave1 = T2.categ_tar2  AND PMVERSAO1 = 1) OR
        (T1.chave1 = T2.categ_tar12 AND PMVERSAO1 = 2))
 UNION

  SELECT PMVERSAO1,T2.MODELO,T1.CHAVE1,T1.TEXTO AS DESCRICAO, T1.CHAVE1 AS VALORBASE
  FROM MULT_PRODUTOSTABRG T1, tabela_veiculomodelo T2
  WHERE T1.TABELA = 24 AND
       T1.PRODUTO = 10 AND
       T2.MODELO = PNMOD AND
       ((T1.chave1 = T2.categ_tar3  AND PMVERSAO1 = 1) OR
        (T1.chave1 = T2.categ_tar13 AND PMVERSAO1 = 2))
 UNION

  SELECT PMVERSAO1,T2.MODELO,T1.CHAVE1,T1.TEXTO AS DESCRICAO, T1.CHAVE1 AS VALORBASE
  FROM MULT_PRODUTOSTABRG T1, tabela_veiculomodelo T2
  WHERE T1.TABELA = 24 AND
       T1.PRODUTO = 10 AND
       T2.MODELO = PNMOD AND
       ((T1.chave1 = T2.categ_tar4  AND PMVERSAO1 = 1) OR
        (T1.chave1 = T2.categ_tar14 AND PMVERSAO1 = 2))
 UNION

  SELECT PMVERSAO1,T2.MODELO,T1.CHAVE1,T1.TEXTO AS DESCRICAO, T1.CHAVE1 AS VALORBASE
  FROM MULT_PRODUTOSTABRG T1, tabela_veiculomodelo T2
 WHERE T1.TABELA = 24 AND
       T1.PRODUTO = 10 AND
       T2.MODELO = PNMOD AND
       ((T1.chave1 = T2.categ_tar5  AND PMVERSAO1 = 1) OR
        (T1.chave1 = T2.categ_tar15 AND PMVERSAO1 = 2))
  ORDER BY DESCRICAO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORCOBERTURA1" (
    PCALCULO IN MULT_CALCULOCOB.CALCULO%TYPE,
    PITEM IN MULT_CALCULOCOB.ITEM%TYPE,
    PCOBERTURA IN MULT_CALCULOCOB.COBERTURA%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  SELECT VALOR FROM MULT_CALCULOCOB
  WHERE CALCULO   = PCALCULO
    AND ITEM      = PITEM
    AND COBERTURA = PCOBERTURA;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORDEFAULT" (
    PPRODUTO IN Mult_CobPerDic.PRODUTO%TYPE,
    PCOBERTURA IN Mult_CobPerDic.COBERTURA%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  select ValorDefault from Mult_CobPerDic
   where
    Produto = PProduto
    and Cobertura = PCobertura;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORDMO1" (
    PPRODUTO IN MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PTABELA IN MULT_PRODUTOSTABRG.TABELA%TYPE,
    PVALOR IN MULT_PRODUTOSTABRG.VALOR%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
SELECT CHAVE1 FROM MULT_PRODUTOSTABRG
    WHERE PRODUTO = PPRODUTO
    AND TABELA = PTABELA
    AND VALOR   = PVALOR;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORMERCADO1" 
( PMODELO in Mult_calculo.MODELO%Type
,PANOMODELO in Mult_calculo.ANOMODELO%Type
,PPROCEDENCIA in Mult_calculo.PROCEDENCIA%Type
,PZERO in Mult_calculo.ZEROKM%Type
,PCAMPO out Types.cursor_type)
IS
BEGIN
   DECLARE
     PVALOR_MEDIO number(16,6);
	 Pvalor_minimo number(16,6);
	 PVALOR_MEDIO_Ant number(16,6);
	 Pvalor_minimo_ant number(16,6);
     Cursor TCAMPOS Is
       SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant
       FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
       WHERE D1.MODELO     = PMODELO
       AND D.COD_MODELO  = D1.MODELO
       AND D.TIPO_TABELA = 'F'
       AND D.ANO_MODELO = 9999
       AND D.COMBUSTIVEL = PPROCEDENCIA;
     Cursor TCAMPON Is
       SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant
       FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
       WHERE D1.MODELO     = PMODELO
       AND D.COD_MODELO  = D1.MODELO
       AND D.TIPO_TABELA = 'F'
       AND D.ANO_MODELO = PANOMODELO
       AND D.COMBUSTIVEL = PPROCEDENCIA;

    BEGIN
    pVALOR_MEDIO := 0;
    pvalor_minimo := 0;
    pvalor_medio_ant := 0;
    pvalor_minimo_ant := 0;
    IF (PZERO = 'S') then
       Open TCAMPOS;
       Fetch TCAMPOS Into PVALOR_MEDIO, Pvalor_minimo, PVALOR_MEDIO_Ant, Pvalor_minimo_ant;
       Close TCAMPOS;
	else
       Open TCAMPON;
       Fetch TCAMPON Into PVALOR_MEDIO, Pvalor_minimo, PVALOR_MEDIO_Ant, Pvalor_minimo_ant;
       Close TCAMPON;
    end if;
    if (PVALOR_MEDIO = 0 and Pvalor_minimo = 0 and PVALOR_MEDIO_Ant = 0 and Pvalor_minimo_ant = 0) then
       IF (PZERO = 'S') then
          open PCAMPO for
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
          D.tipo_tabela, d1.familia FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA;
       else
          open PCAMPO for
          SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
                 D.tipo_tabela, d1.familia FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA;
       end if;
	else
       IF (PZERO = 'S') Then
         open PCAMPO for
         SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
           D.tipo_tabela, d1.familia FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
           WHERE D1.MODELO     = PMODELO
           AND D.COD_MODELO  = D1.MODELO
           AND D.TIPO_TABELA = 'F'
           AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA;
       else
         open PCAMPO for
         SELECT D.VALOR_MEDIO, D.valor_minimo, D.VALOR_MEDIO_Ant, D.valor_minimo_ant,
          D.tipo_tabela, d1.familia FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.TIPO_TABELA = 'F'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA;
       end if;
	end if;
     END;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORMERCADO2" 
(PMODELO in Mult_calculo.MODELO%Type
,PFABRICANTE in Mult_calculo.FABRICANTE%Type
,PANOMODELO in Mult_calculo.ANOMODELO%Type
,PPROCEDENCIA in Mult_calculo.PROCEDENCIA%Type
,PZERO in Mult_calculo.ZEROKM%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
   IF (PZERO = 'S') then
          open PCAMPO for
          SELECT distinct D.VALOR_MEDIO, D.valor_minimo, D.valor_Maximo,
          D.VALOR_MEDIO_Ant, D.valor_minimo_ant, D.valor_Maximo_ant,
            D.tipo_tabela, d1.familia FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = 9999
          AND D.COMBUSTIVEL = PPROCEDENCIA;
     else
          open PCAMPO for
          SELECT distinct D.VALOR_MEDIO, D.valor_minimo, D.valor_Maximo,
          D.VALOR_MEDIO_Ant, D.valor_minimo_ant, D.valor_Maximo_ant,
            D.tipo_tabela, d1.familia FROM REAL_COTASAUTO D, TABELA_VEICULOMODELO D1
          WHERE D1.MODELO     = PMODELO
          AND D.COD_MODELO  = D1.MODELO
          AND D.COD_FABRIC = PFABRICANTE
          AND D.TIPO_TABELA = 'R'
          AND D.ANO_MODELO = PANOMODELO
          AND D.COMBUSTIVEL = PPROCEDENCIA;
    end if;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORRCF1" (
    PPRODUTO IN MULT_PRODUTOSRCF_VALORES.PRODUTO%TYPE,
    PNIVEL   IN MULT_PRODUTOSRCF_VALORES.NIVEL%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
SELECT VALOR FROM MULT_PRODUTOSRCF_VALORES
     WHERE PRODUTO = 10
     AND NIVEL     = PNIVEL;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VALORRCF2" 
(
    PPRODUTO IN MULT_PRODUTOSTABRG.PRODUTO%TYPE,
    PTABELA  IN MULT_PRODUTOSTABRG.TABELA%TYPE,
    PCHAVE1  IN MULT_PRODUTOSTABRG.CHAVE1%TYPE,
    PTEXTO   IN MULT_PRODUTOSTABRG.TEXTO%TYPE,
    PCAMPO   OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
SELECT VALOR, Chave2 FROM MULT_PRODUTOSTABRG
    WHERE
    PRODUTO = PPRODUTO
    and Tabela = PTABELA
    and chave1 = PCHAVE1
    AND TEXTO   = PTEXTO;
end;
/


CREATE OR REPLACE PROCEDURE "LISTA_VEICULOMODELO2" 
(PMODELO in TABELA_VEICULOMODELO.MODELO%Type,
 PCAMPO out Types.cursor_type)
IS
BEGIN
    OPEN PCAMPO FOR
       SELECT COD_REFERENCIA, COD_REFERENCIA_INC, COD_REFERENCIA_RINC, FAMILIA, CATEG_TAR1, CATEGORIA, PROCEDENCIA FROM TABELA_VEICULOMODELO
       WHERE MODELO = PMODELO;
END;
/


CREATE OR REPLACE PROCEDURE "LISTA_VEICULOMODELO3" (
    PMODELO IN TABELA_VEICULOMODELO_ANT.MODELO%type,
    PCAMPO OUT TYPES.CURSOR_TYPE)
IS
BEGIN
  OPEN PCAMPO FOR
    SELECT COD_REFERENCIA,
           COD_REFERENCIA_INC,
           COD_REFERENCIA_RINC,
           FAMILIA,
           CATEG_TAR1,
           CATEGORIA,
           PROCEDENCIA
    FROM TABELA_VEICULOMODELO_ANT
    WHERE MODELO = PMODELO;
END;
/


CREATE OR REPLACE PROCEDURE "OBTEM_CODFIPE" (
    PMODELO IN TABELA_VEICULOMODELO.MODELO%TYPE,
    PCOD_FIPE OUT REAL_DEPARAFIPE.CD_FIPE%TYPE
)
IS
BEGIN
  SELECT CD_FIPE INTO PCOD_FIPE FROM real_deparafipe T1, tabela_veiculomodelo T2
  WHERE T2.modelo = PMODELO AND T2.MODELO = T1.cd_mod_real;
END;
/


CREATE OR REPLACE PROCEDURE "P_EXPURGO_FWT" (P_QTD_DIAS in NUMBER, P_BLOCO_COMMIT in NUMBER) IS

--Procedure respons·vel por expurgar os dados das tabelas do FWTStorageDB
--@author F·bio Souza - Oracle Consullting

    TYPE ARRAY_TABELAS_1 IS VARRAY(2) OF VARCHAR2(25);
	TYPE ARRAY_TABELAS_2 IS VARRAY(4) OF VARCHAR2(25);
    --
    FILE_HANDLE                 UTL_FILE.FILE_TYPE;
    DIR_NAME                    VARCHAR2(40) := 'LOG_DIR';
    FILE_NAME                   VARCHAR2(40) := 'log_expurgo_fwt.txt';
    --
    G_DATA_CORTE                 DATE := TRUNC(SYSDATE) - P_QTD_DIAS;
    G_QTD_LINHAS                 NUMBER;
    G_QTD_EXCLUSOES              NUMBER;
    G_QTD_LINHAS_APOS_EXCLUSOES  NUMBER;
    G_TABELAS_EXPURGO_1          ARRAY_TABELAS_1 := ARRAY_TABELAS_1('TB_ARQ_MAINFRAME_UP', 'TB_ARQ_MAINFRAME_DOWN');
	  G_TABELAS_EXPURGO_2          ARRAY_TABELAS_2 := ARRAY_TABELAS_2('TB_ARQUSER_UP', 'TB_ARQUSER_TITULO', 'TB_ARQUSER_PROP', 'TB_ARQUSER_ADMIN');
    G_TABELA                     VARCHAR2(25);
    G_BLOCO_COMMIT_CALCULADO     NUMBER;
    --

	-- DefiniÁ„o das procedures de auxÌlio
    PROCEDURE P_EXPURGAR_TABELA (P_COLUNA_DATA IN VARCHAR2, P_BLOCO_COMMIT IN NUMBER, X_LINHAS_EXCLUIDAS OUT NUMBER) IS
      TYPE tCursorType  IS REF CURSOR;
      --
      L_SQL_CURSOR        tCursorType;
      L_SQL_STATEMENT     VARCHAR2(120) := 'SELECT ROWID FROM ' || G_TABELA || ' WHERE TRUNC(' || P_COLUNA_DATA || ') < :G_DATA_CORTE';
      L_ID_LINHAS         DBMS_SQL.VARCHAR2_TABLE;

    BEGIN
      X_LINHAS_EXCLUIDAS := 0;
      OPEN L_SQL_CURSOR FOR L_SQL_STATEMENT USING G_DATA_CORTE ;
        LOOP
          FETCH L_SQL_CURSOR BULK COLLECT INTO L_ID_LINHAS LIMIT P_BLOCO_COMMIT;
          EXIT  WHEN L_ID_LINHAS.COUNT = 0;
          FORALL i
            IN L_ID_LINHAS.FIRST .. L_ID_LINHAS.LAST
            EXECUTE IMMEDIATE 'DELETE from ' || G_TABELA || ' WHERE ROWID = :1' USING L_ID_LINHAS(i);
          UTL_FILE.PUT_LINE(FILE_HANDLE,'Executando commit. Linhas processadas: ' || L_ID_LINHAS.COUNT);
          COMMIT;
          X_LINHAS_EXCLUIDAS := X_LINHAS_EXCLUIDAS + L_ID_LINHAS.COUNT;
          L_ID_LINHAS.DELETE;
        END LOOP;
      CLOSE L_SQL_CURSOR;
    END;

	PROCEDURE P_EXPURGAR_CONTEUDO_PROPOSTA (P_BLOCO_COMMIT IN NUMBER, X_LINHAS_EXCLUIDAS OUT NUMBER) IS
      TYPE tCursorType  IS REF CURSOR;
      --
      L_SQL_CURSOR        tCursorType;
      L_SQL_STATEMENT     VARCHAR2(350) := 'SELECT ROWID FROM   TB_CONTEUDO_PROPOSTA CP
			WHERE  EXISTS ( SELECT *
					FROM TB_ARQUSER_UP AU
					WHERE AU.DT_ENTRADA = CP.DT_ENTRADA
					AND AU.NM_ARQUIVO = AU.NM_ARQUIVO
					AND AU.CD_COD_INTERNO = CP.CD_COD_INTERNO
					AND AU.CD_PLUG = CP.CD_PLUG
					AND TRUNC(AU.DT_PROCESSAMENTO) < :G_DATA_CORTE)';
      L_ID_LINHAS         DBMS_SQL.VARCHAR2_TABLE;

    BEGIN
      X_LINHAS_EXCLUIDAS := 0;
      OPEN L_SQL_CURSOR FOR L_SQL_STATEMENT USING G_DATA_CORTE ;
        LOOP
          FETCH L_SQL_CURSOR BULK COLLECT INTO L_ID_LINHAS LIMIT P_BLOCO_COMMIT;
          EXIT  WHEN L_ID_LINHAS.COUNT = 0;
          FORALL i
            IN L_ID_LINHAS.FIRST .. L_ID_LINHAS.LAST
            EXECUTE IMMEDIATE 'DELETE from TB_CONTEUDO_PROPOSTA WHERE ROWID = :1' USING L_ID_LINHAS(i);
            dbms_output.put_line('antes Executando commi');
          UTL_FILE.PUT_LINE(FILE_HANDLE,'Executando commit. Linhas processadas: ' || L_ID_LINHAS.COUNT);
          COMMIT;
          X_LINHAS_EXCLUIDAS := X_LINHAS_EXCLUIDAS + L_ID_LINHAS.COUNT;
          L_ID_LINHAS.DELETE;
        END LOOP;
      CLOSE L_SQL_CURSOR;
    END;


-- InÌcio da Procedure
BEGIN
    --Abre o arquivo para escrita de log
    dbms_output.put_line('antes open file ' || DIR_NAME || ' ' || FILE_NAME);
    FILE_HANDLE := UTL_FILE.FOPEN(DIR_NAME,FILE_NAME,'a');

    --GERA RELAT”RIO DE LOG'S
    dbms_output.put_line('antes inicia limpeza');
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Iniciando limpeza da base FWT: ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Ser„o excluÌdos os registros com data inferior a ' || TO_CHAR(G_DATA_CORTE,'DD/MM/YYYY'));

	-- Processando as tabelas que possuem a coluna DT_PROC
    FOR ELEM IN 1 .. G_TABELAS_EXPURGO_1.COUNT LOOP
        G_TABELA := G_TABELAS_EXPURGO_1(ELEM);
        dbms_output.put_line('antes processa tabela');
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Processando a tabela ' || G_TABELA);

        EXECUTE IMMEDIATE 'SELECT count(1) from ' || G_TABELA into G_QTD_LINHAS;
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros antes do expurgo: ' || G_QTD_LINHAS);

        IF(P_BLOCO_COMMIT = 0) THEN
            G_BLOCO_COMMIT_CALCULADO := G_QTD_LINHAS;
        ELSE
            G_BLOCO_COMMIT_CALCULADO := P_BLOCO_COMMIT;
        END IF;

        G_QTD_EXCLUSOES := 0;

        IF(G_BLOCO_COMMIT_CALCULADO <> 0) THEN
            P_EXPURGAR_TABELA('DT_PROC', G_BLOCO_COMMIT_CALCULADO, G_QTD_EXCLUSOES);
        END IF;

        G_QTD_LINHAS_APOS_EXCLUSOES := G_QTD_LINHAS - G_QTD_EXCLUSOES;

        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de linhas excluÌdas: ' || G_QTD_EXCLUSOES);
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros apÛs o expurgo: ' || G_QTD_LINHAS_APOS_EXCLUSOES);
        UTL_FILE.PUT_LINE(FILE_HANDLE,G_TABELA || ' processada.');

    END LOOP;

	-- Processando a tabela TB_CONTEUDO_PROPOSTA
	  G_TABELA := 'TB_CONTEUDO_PROPOSTA';
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Processando a tabela ' || G_TABELA);

    SELECT COUNT(1) INTO G_QTD_LINHAS FROM TB_CONTEUDO_PROPOSTA;
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros antes do expurgo: ' || G_QTD_LINHAS);

    IF(P_BLOCO_COMMIT = 0) THEN
        G_BLOCO_COMMIT_CALCULADO := G_QTD_LINHAS;
    ELSE
        G_BLOCO_COMMIT_CALCULADO := P_BLOCO_COMMIT;
    END IF;

    G_QTD_EXCLUSOES := 0;

    IF(G_BLOCO_COMMIT_CALCULADO <> 0) THEN
	    P_EXPURGAR_CONTEUDO_PROPOSTA (G_BLOCO_COMMIT_CALCULADO, G_QTD_EXCLUSOES);
    END IF;

    G_QTD_LINHAS_APOS_EXCLUSOES := G_QTD_LINHAS - G_QTD_EXCLUSOES;

    UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de linhas excluÌdas: ' || G_QTD_EXCLUSOES);
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros apÛs o expurgo: ' || G_QTD_LINHAS_APOS_EXCLUSOES);
    UTL_FILE.PUT_LINE(FILE_HANDLE,G_TABELA || ' processada.');

	-- Processando as tabelas que possuem a coluna DT_PROCESSAMENTO
    FOR ELEM IN 1 .. G_TABELAS_EXPURGO_2.COUNT LOOP
        G_TABELA := G_TABELAS_EXPURGO_2(ELEM);
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Processando a tabela ' || G_TABELA);

        EXECUTE IMMEDIATE 'SELECT count(1) from ' || G_TABELA into G_QTD_LINHAS;
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros antes do expurgo: ' || G_QTD_LINHAS);

        IF(P_BLOCO_COMMIT = 0) THEN
            G_BLOCO_COMMIT_CALCULADO := G_QTD_LINHAS;
        ELSE
            G_BLOCO_COMMIT_CALCULADO := P_BLOCO_COMMIT;
        END IF;

        G_QTD_EXCLUSOES := 0;

        IF(G_BLOCO_COMMIT_CALCULADO <> 0) THEN
            P_EXPURGAR_TABELA('DT_PROCESSAMENTO', G_BLOCO_COMMIT_CALCULADO, G_QTD_EXCLUSOES);
        END IF;

        G_QTD_LINHAS_APOS_EXCLUSOES := G_QTD_LINHAS - G_QTD_EXCLUSOES;

        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de linhas excluÌdas: ' || G_QTD_EXCLUSOES);
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros apÛs o expurgo: ' || G_QTD_LINHAS_APOS_EXCLUSOES);
        UTL_FILE.PUT_LINE(FILE_HANDLE,G_TABELA || ' processada.');

    END LOOP;

    -- FINALIZANDO GERA«√O DE RELAT”RIO
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Finalizando Limpeza da base FWT: ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(FILE_HANDLE,'===========================================================================================================================');

    --Fecha o arquivo
    UTL_FILE.FCLOSE(FILE_HANDLE);

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
	      UTL_FILE.FCLOSE(FILE_HANDLE);
        RAISE_APPLICATION_ERROR(-20001,'Erro gerado pelo expurgo do FWT: '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE "P_EXPURGO_FWTSTORAGEDB" (P_QTD_DIAS in NUMBER, P_BLOCO_COMMIT in NUMBER) IS

--Procedure respons·vel por expurgar os dados das tabelas do FWTStorageDB
--@author F·bio Souza - Oracle Consullting

    TYPE ARRAY_TABELAS IS VARRAY(6) OF VARCHAR2(18);
    --
    FILE_HANDLE                 UTL_FILE.FILE_TYPE;
    DIR_NAME                    VARCHAR2(40) := 'LOG_DIR';
    FILE_NAME                   VARCHAR2(40) := 'log_expurgo_fwtstoragedb.txt';
    --
    G_DATA_CORTE                 DATE := TRUNC(SYSDATE) - P_QTD_DIAS;
    G_QTD_LINHAS                 NUMBER;
    G_QTD_EXCLUSOES              NUMBER;
    G_QTD_LINHAS_APOS_EXCLUSOES  NUMBER;
    G_TABELAS_EXPURGO            ARRAY_TABELAS := ARRAY_TABELAS('TB_FWT_BKP_UP', 'TB_FWT_UPLOAD_BLOB', 'TB_FWT_UPLOAD_FILE', 'TB_FWT_FBKP_DOWN', 'TB_FWT_DOWN_BLOB', 'TB_FWT_DOWN_FILE');
    G_TABELA                     VARCHAR2(18);
    G_BLOCO_COMMIT_CALCULADO     NUMBER;
    --
    PROCEDURE P_EXPURGAR_TABELA (P_BLOCO_COMMIT IN NUMBER, X_LINHAS_EXCLUIDAS OUT NUMBER) IS
      TYPE tCursorType  IS REF CURSOR;
      --
      L_SQL_CURSOR        tCursorType;
      L_SQL_STATEMENT     VARCHAR2(120) := 'SELECT ROWID FROM ' || G_TABELA || ' WHERE TRUNC(DT_ARQUIVO) < :G_DATA_CORTE';
      L_ID_LINHAS         DBMS_SQL.VARCHAR2_TABLE;

    BEGIN
      X_LINHAS_EXCLUIDAS := 0;
      OPEN L_SQL_CURSOR FOR L_SQL_STATEMENT USING G_DATA_CORTE ;
        LOOP
          FETCH L_SQL_CURSOR BULK COLLECT INTO L_ID_LINHAS LIMIT P_BLOCO_COMMIT;
          EXIT  WHEN L_ID_LINHAS.COUNT = 0;
          FORALL i
            IN L_ID_LINHAS.FIRST .. L_ID_LINHAS.LAST
            EXECUTE IMMEDIATE 'DELETE from ' || G_TABELA || ' WHERE ROWID = :1' USING L_ID_LINHAS(i);
          UTL_FILE.PUT_LINE(FILE_HANDLE,'Executando commit. Linhas processadas: ' || L_ID_LINHAS.COUNT);
          COMMIT;
          X_LINHAS_EXCLUIDAS := X_LINHAS_EXCLUIDAS + L_ID_LINHAS.COUNT;
          L_ID_LINHAS.DELETE;
        END LOOP;
      CLOSE L_SQL_CURSOR;
    END;

BEGIN
    --Abre o arquivo para escrita de log
    FILE_HANDLE := UTL_FILE.FOPEN(DIR_NAME,FILE_NAME,'a');

    --GERA RELAT”RIO DE LOG'S
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Iniciando limpeza da base FWTStorageDB: ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Ser„o excluÌdos os registros com data inferior a ' || TO_CHAR(G_DATA_CORTE,'DD/MM/YYYY'));

    FOR ELEM IN 1 .. G_TABELAS_EXPURGO.COUNT LOOP
        G_TABELA := G_TABELAS_EXPURGO(ELEM);
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Processando a tabela ' || G_TABELA);

        EXECUTE IMMEDIATE 'SELECT count(1) from ' || G_TABELA into G_QTD_LINHAS;
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros antes do expurgo: ' || G_QTD_LINHAS);

        IF(P_BLOCO_COMMIT = 0) THEN
            G_BLOCO_COMMIT_CALCULADO := G_QTD_LINHAS;
        ELSE
            G_BLOCO_COMMIT_CALCULADO := P_BLOCO_COMMIT;
        END IF;

        G_QTD_EXCLUSOES := 0;

        IF(G_BLOCO_COMMIT_CALCULADO <> 0) THEN
            P_EXPURGAR_TABELA(G_BLOCO_COMMIT_CALCULADO, G_QTD_EXCLUSOES);
        END IF;

        G_QTD_LINHAS_APOS_EXCLUSOES := G_QTD_LINHAS - G_QTD_EXCLUSOES;

        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de linhas excluÌdas: ' || G_QTD_EXCLUSOES);
        UTL_FILE.PUT_LINE(FILE_HANDLE,'Total de registros apÛs o expurgo: ' || G_QTD_LINHAS_APOS_EXCLUSOES);
        UTL_FILE.PUT_LINE(FILE_HANDLE,G_TABELA || ' processada.');

    END LOOP;

    -- FINALIZANDO GERA«√O DE RELAT”RIO
    UTL_FILE.PUT_LINE(FILE_HANDLE,'Finalizando Limpeza da base FWTStorageDB: ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(FILE_HANDLE,'===========================================================================================================================');

    --Fecha o arquivo
    UTL_FILE.FCLOSE(FILE_HANDLE);

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
	      UTL_FILE.FCLOSE(FILE_HANDLE);
        RAISE_APPLICATION_ERROR(-20001,'Erro gerado pelo expurgo do FWTStorageDB: '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE "PRC_ALTERALOGINUSUARIO" (
   lid_usuario         IN       real_usuarios.cod_usuario%TYPE,
   lcd_corretor_usu    IN       real_usuarios.corretor%TYPE,
   lid_usuario_novo    IN       real_usuarios.cod_usuario%TYPE)
IS
BEGIN
  UPDATE
   REAL_USUARIOS U
  SET
   U.cod_usuario = lid_usuario_novo
  WHERE
   U.COD_USUARIO = LID_USUARIO AND
   U.CORRETOR = (SELECT
                  D.DIVISAO
                 FROM
                  TABELA_DIVISOES D
                 WHERE
                  D.DIVISAO_SUPERIOR = LCD_CORRETOR_USU AND
                  D.TIPO_DIVISAO = 'E');
end;
/


CREATE OR REPLACE PROCEDURE "PRC_APAGAUSUARIO" (
   lid_usuario         IN       real_usuarios.cod_usuario%TYPE,
   lcd_corretor_usu    IN       real_usuarios.corretor%TYPE)
IS
BEGIN
  DELETE FROM
   REAL_USUARIOS U
  WHERE
   U.COD_USUARIO = LID_USUARIO AND
   U.CORRETOR = (SELECT
                  D.DIVISAO
                 FROM
                  TABELA_DIVISOES D
                 WHERE
                  D.DIVISAO_SUPERIOR = LCD_CORRETOR_USU AND
                  D.TIPO_DIVISAO = 'E');
end;
/


CREATE OR REPLACE PROCEDURE "PRC_ATUALIZA_DADOS_USUARIOS" (
   lcd_corretor_usu    IN       real_usuarios.corretor%TYPE,
   lag_captadora_usu   IN       real_usuarios.agencia%TYPE,
   ltp_usuario         IN       real_usuarios.tipousuario%TYPE,
   lcd_padrao_usu      IN       real_usuarios.padraousuario%TYPE,
   ltb_estipulante1    IN       real_usuarios.estipulante1%TYPE,
   ltb_estipulante2    IN      real_usuarios.estipulante2%TYPE,
   ltb_estipulante3    IN      real_usuarios.estipulante3%TYPE,
   ltb_estipulante4    IN      real_usuarios.estipulante4%TYPE,
   ltb_estipulante5    IN      real_usuarios.estipulante5%TYPE,
   ltb_estipulante6    IN      real_usuarios.estipulante6%TYPE,
   ltb_estipulante7    IN      real_usuarios.estipulante7%TYPE,
   ltb_estipulante8    IN      real_usuarios.estipulante8%TYPE,
   ltb_estipulante9    IN      real_usuarios.estipulante9%TYPE,
   ltb_estipulante0    IN      real_usuarios.estipulante0%TYPE)
IS
BEGIN
  UPDATE REAL_USUARIOS U
  SET
    U.agencia = lag_captadora_usu,
    U.tipousuario = ltp_usuario,
    U.padraousuario =  lcd_padrao_usu,
    U.estipulante1 =  ltb_estipulante1,
    U.estipulante2 =  ltb_estipulante2,
    U.estipulante3 =  ltb_estipulante3,
    U.estipulante4 =  ltb_estipulante4,
    U.estipulante5 =  ltb_estipulante5,
    U.estipulante6 =  ltb_estipulante6,
    U.estipulante7 =  ltb_estipulante7,
    U.estipulante8 =  ltb_estipulante8,
    U.estipulante9 =  ltb_estipulante9,
    U.estipulante0 = ltb_estipulante0
  WHERE
   U.CORRETOR = (SELECT
                  D.DIVISAO
                 FROM
                  TABELA_DIVISOES D
                 WHERE
                  D.DIVISAO_SUPERIOR = LCD_CORRETOR_USU AND
                  D.TIPO_DIVISAO = 'E');
end;
/


CREATE OR REPLACE procedure prc_consulta_propostas (
    P_CALCULO                   IN MULT_CALCULO.CALCULO%TYPE,
    P_CORRETOR               IN REAL_USUARIOS.CORRETOR%TYPE,
    P_PADRAOUSUARIO  IN REAL_USUARIOS.PADRAOUSUARIO%TYPE,
    P_PRODUTO        IN VARCHAR2,
    P_CPF_CNPJ       IN TABELA_CLIENTES.CGC_CPF%TYPE,
    P_NUMERO_TITULO  IN MULT_CALCULO.NUMEROTITULO%TYPE,
    P_USUARIO        IN REAL_USUARIOS.COD_USUARIO%TYPE,
    P_ESTIPULANTE    IN TABELA_DIVISOES.DIVISAO%TYPE,
    P_NOME           IN MULT_CALCULO.NOME%TYPE,
    P_SITUACAO       IN MULT_CALCULO.SITUACAO%TYPE,
    P_TIPO_PERIODO   IN INTEGER,
    P_PERIODO        IN INTEGER,
    P_PERIODO_INICIO IN MULT_CALCULO.DATACALCULO%TYPE,
    P_PERIODO_FIM    IN MULT_CALCULO.DATACALCULO%TYPE,
    P_TIPO_CONSULTA  IN INTEGER,
    P_ORDEM          IN VARCHAR2,
    P_RELATORIO      IN INTEGER,
    P_ACESSORIA      IN VARCHAR2,
    P_USUARIO_LOGADO IN VARCHAR2,
    P_TIPO_DESCONTO  IN INTEGER,
    P_DATASERVER     IN DATE,
    P_SQL_GERADO     OUT LONG,
    P_RESULTADO      OUT TYPES.CURSOR_TYPE)
IS
    v_url_link_resid_facil VARCHAR2(4000) := '';
    v_Estipulante1            NUMBER;
    v_Estipulante2            NUMBER;
    v_Estipulante3            NUMBER;
    v_Estipulante4            NUMBER;
    v_Estipulante5            NUMBER;
    v_Estipulante6            NUMBER;
    v_Estipulante7            NUMBER;
    v_Estipulante8            NUMBER;
    v_Estipulante9            NUMBER;
    v_Estipulante0            NUMBER;
    v_Estipulantes            VARCHAR(1000);
    v_count_estip           NUMBER;


    v_0_char                   VARCHAR2(1):=  '0';
    ---
    v_7                           NUMBER(2)   :=   7;
    v_20                         NUMBER(2)   :=  20;
    v_21                         NUMBER(2)   :=   21;
    v_Ren                       VARCHAR2(3):= 'REN';
    v_Grd                       VARCHAR2(3) := 'GRD';
    v_Lib                        VARCHAR2(3) := 'LIB';
    v_Apo                      VARCHAR2(3) := 'APO';
    v_Lip                        VARCHAR2(3):= 'LIP';
    v_R                          VARCHAR2(1):= 'R';
    v_pro                       VARCHAR2(3):='PRO';
    v_52                        NUMBER(2)    := 52;
    v_C                         CHAR(1)        := 'C';
    v_258                      NUMBER        := 258;
    v_289                      NUMBER        := 289;
    v_699                      NUMBER        := 699;
    v_813                      NUMBER        := 813;
    v_700                      NUMBER        := 700;
    v_814                      NUMBER        := 814;
    v_701                      NUMBER        := 701;
    v_815                     NUMBER         := 815;
    v_D                         VARCHAR2(1):= 'D';
    v_14                        NUMBER(2)   :=  14;


    PROCEDURE Busca_Por_CPF (v_cpf_cnpj     IN      VARCHAR2
                            ,v_corretor     IN      NUMBER
                            ,v_CorretorTMS  IN      NUMBER
                            ,v_assessoria   IN      VARCHAR2
                            ,v_RESULTADO    OUT     SYS_REFCURSOR) IS
            --
            --
            v_cpf_cnpj_somente_numeros NUMBER;
            --v_cpf_cnpj VARCHAR2(100) := '739.263.967-68';
            --v_corretor    NUMBER := 309;
            --v_CorretorTMS NUMBER := 20401;
            --v_assessoria  NUMBER := NULL;
            v_1_ano_para_tras       DATE;
            V_B1                    VARCHAR2(02)    :=      'B1';
            v_D1                    VARCHAR2(02)    :=      'D1';
            v_E                     VARCHAR2(1)     :=      'E';
            v_T                     VARCHAR2(1)     :=      'T';
            v_C                     VARCHAR2(1)     :=      'C';
            v_S                     VARCHAR2(1)     :=      'S';
            v_N                     VARCHAR2(1)     :=      'N';
            v_0_char                VARCHAR2(1)     :=      '0';
            v_1                     NUMBER(2)       :=      1;
            v_2                     NUMBER(2)       :=      2;
            v_3                     NUMBER(2)       :=      3;
            v_4                     NUMBER(1)       :=      4;
            v_5                     NUMBER(2)       :=      5;
            v_6                     NUMBER(2)       :=      6;
            v_7                     NUMBER(2)       :=      7;
            v_8                     NUMBER(2)       :=      8;
            v_9                     NUMBER(2)       :=      9;
            v_10                    NUMBER(2)       :=      10;
            v_11                    NUMBER(2)       :=      11;
            v_12                    NUMBER(2)       :=      12;
            v_13                    NUMBER(2)       :=      13;
            v_14                    NUMBER(02)      :=      14;
            v_15                    NUMBER(2)       :=      15;
            v_16                    NUMBER(2)       :=      16;
            v_17                    NUMBER(2)       :=      17;
            v_18                    NUMBER(2)       :=      18;
            v_19                    NUMBER(2)       :=      19;
            v_20                    NUMBER(2)       :=      20;
            v_21                    NUMBER(2)       :=      21;
            v_22                    NUMBER(2)       :=      22;
            v_23                    NUMBER(2)       :=      23;
            v_24                    NUMBER(2)       :=      24;
            v_25                    NUMBER(2)       :=      25;
            v_26                    NUMBER(2)       :=      26;
            v_27                    NUMBER(2)       :=      27;
            v_28                    NUMBER(2)       :=      28;
            v_29                    NUMBER(2)       :=      29;
            v_30                    NUMBER(2)       :=      30;
            v_99                    NUMBER(2)       :=      99;
            v_1806                  NUMBER(4)       :=      1806;
            v_7187                  NUMBER(4)       :=      7187;
            v_3001                  NUMBER(4)       :=      3001;
            v_6709                  NUMBER(4)       :=      6709;
            v_5121                  NUMBER(4)       :=      5121;

v_REN                       VARCHAR2(3)    :=     'REN';
V_GRD                      VARCHAR2(3)  :=    'GRD';
V_LIB                       VARCHAR2(3)    :=    'LIB';
V_APO                      VARCHAR2(3)  :=    'APO';
V_LIP                       VARCHAR2(3)    :=    'LIP';

V_R                       VARCHAR2(1)    :=    'R';
V_PRO                   VARCHAR2(3)    :=    'PRO';
V_52                      NUMBER(2)       :=  52;
V_258                    NUMBER := 258;
V_289                    NUMBER := 289;

V_699                    NUMBER := 699;
V_813                    NUMBER := 813;
V_700                    NUMBER := 700;
V_814                    NUMBER := 814;
V_701                    NUMBER := 701;
V_815                    NUMBER := 815;
V_D                       VARCHAR2(1)    :=    'D';


            l_tab KITTY004_BUSCA_TABLE := KITTY004_BUSCA_TABLE();

            CURSOR c_busca_cpf
            IS
            SELECT CALC.CALCULO
                  ,CALC.ITEM
                  ,CALC.NOME
                  ,CLIE.CGC_CPF
                  ,ESTI.NOME NOMEESTIPULANTE
                  ,CALC.DATACALCULO
                  ,RESDL.URL URL_RESID_FACIL
                  ,CASE
                           WHEN CALC.SITUACAO = v_E
                                AND CALC.TIPODOCUMENTO <> v_N THEN
                            'Efetivado'
                           WHEN CALC.SITUACAO = v_E
                                AND CALC.TIPODOCUMENTO = v_N THEN
                            'Finalizado sem transmiss„o'
                           WHEN CALC.SITUACAO = v_T THEN
                            'Transmitido'
                           WHEN CALC.SITUACAO = v_C THEN
                            'Calculado'
                           ELSE
                            'Pendente'
                   END SITUACAO
                  ,CALC.SITUACAO COD_SITUACAO
                  ,CALC.CALCULOORIGEM
                  ,CALC.COD_USUARIO
                  ,PROD.DESCRICAO AS PRODUTO
                  ,CALC.PADRAO
                  ,CALC.DATAEMISSAO
                  ,CALC.DATATRANSMISSAO
                  ,CALC.VALIDADO
                  ,trunc(calc.datavalidade) - trunc(SYSDATE) DIAS
                  ,CALC.PROTOCOLOTRANS
                  ,CALC.ESTIPULANTE COD_ESTIPULANTE
                  --,RELAC_ESTI.DIVISAO COD_ESTIPULANTE
                  ,CALC.PADRAO COD_PRODUTO
                  ,CALC.INICIOVIGENCIA
                  ,TO_NUMBER(NVL(CALC.NUMEROTITULO, '0')) NUMEROTITULO
                  ,'KCW' SISTEMA
                  ,0 CORR_TMS
                  ,0 CORR_TMB
                  ,' ' CORR_ASER
                  ,RT.TIPO_OFERTA
                  ,RT.VALOR_PREMIO_ORIGINAL VALOR_DE
                  ,RT.VALOR_PREMIO_REALTIME VALOR_PARA
            FROM   MULT_CALCULO CALC
            --LEFT   OUTER JOIN SSV0011_OFERT_RESDL RESDL
            --ON (CALC.CALCULOORIGEM = RESDL.CD_NGOCO_AUTO AND RESDL.IC_OFERT = 'S')
left outer join
(
select N.CD_NGOCO, N.CD_CRTOR_SEGUR_PRCPA, REPLACE(REPLACE(PARAM.VL_PARAM_SSV, '#CODIGO_NEGOCIO#', N.CD_NGOCO), '#USUARIO#', C.CD_CONVO) as URL
FROM SSV0084_NGOCO n, SSV0081_MDULO_NGOCO mn, SSV9099_PARAM_SSV PARAM, SSV5046_CONVO c, SSV0076_ITSEG i
WHERE
        N.CD_NGOCO = MN.CD_NGOCO
        AND I.CD_NGOCO = N.CD_NGOCO
        AND I.TP_HISTO_ITSEG = v_0_char
        AND N.TP_HISTO = v_0_char
        AND MN.TP_HISTO = v_0_char
        AND MN.CD_MDUPR IN (v_7,v_20,v_21)
        AND (N.CD_SITUC_NGOCO IN (v_REN, v_GRD, v_LIB, v_APO) OR (N.TP_RENOV_NGOCO = v_R AND N.CD_SITUC_NGOCO = v_PRO))
        AND N.DT_CANCL_NGOCO IS NULL
        AND MN.DT_FIM_VIGEN >= TRUNC(SYSDATE)
        AND PARAM.CD_GRP_PARAM_SSV = v_52
        AND PARAM.CD_PARAM_SSV = 'URL.BASE.EMISSAO.RESIDENCIAL.FACIL'
        AND C.CD_ITRNO_CONVO = N.CD_CRTOR_SEGUR_PRCPA
        AND C.TP_CONVO = v_C
        -- CORRETORES N√O OFERTA
        AND N.CD_CRTOR_SEGUR_PRCPA NOT IN
        (SELECT TO_NUMBER(regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = v_52 AND PARAM.CD_PARAM_SSV = 'CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL'),'[^,]+', 1, level)) from dual connect by regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = v_52 AND PARAM.CD_PARAM_SSV = 'CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL'), '[^,]+', 1, level) is not null)
        -- CLIENTE N√O POSSUI SEGURO RESIDENCIAL ATIVO
        AND NOT EXISTS (
                SELECT 1
                FROM SSV0081_MDULO_NGOCO MN1, SSV0084_NGOCO N1
                WHERE
                N1.CD_NGOCO = MN1.CD_NGOCO
                AND N1.TP_HISTO = v_0_char
                AND MN1.TP_HISTO = v_0_char
                AND MN1.CD_MDUPR = v_14
                AND N1.DT_CANCL_NGOCO IS NULL
                AND N1.CD_CLIEN = N.CD_CLIEN
                AND N1.CD_SITUC_NGOCO IN (v_REN, v_LIB, v_LIP, v_GRD, v_APO)
                AND SYSDATE BETWEEN MN1.DT_INICO_VIGEN AND MN1.DT_FIM_VIGEN
        )
        -- QBR APARTAMENTO OU CASA
        AND EXISTS (
            SELECT 1
            FROM SSV0104_QUEST_RESIT QBR
            WHERE
                QBR.NR_ITSEG = I.NR_ITSEG
                AND QBR.CD_QBR IN (v_258, v_289)
                AND QBR.CD_RESPT_QBR IN (v_699, v_13, v_700, v_814, v_701, v_815)
        )
) RESDL
ON (CALC.NUMERONEGOCIORESERVADO = RESDL.CD_NGOCO)
INNER  JOIN MULT_PADRAO PROD
            ON     PROD.PADRAO = CALC.PADRAO
            INNER  JOIN TABELA_CLIENTES CLIE
            ON     CLIE.CLIENTE = CALC.CLIENTE
            --LEFT   OUTER JOIN MULT_CALCULODIVISOES RELAC_ESTI
            --ON     RELAC_ESTI.CALCULO = CALC.CALCULO
            --AND    RELAC_ESTI.NIVEL = v_4
            --AND    RELAC_ESTI.DIVISAO IN (SELECT cd_estip FROM TABLE (KITFC002_ESTIP_TABLE (v_Estipulantes)))
            INNER  JOIN TABELA_DIVISOES ESTI
            ON     ESTI.DIVISAO = CALC.ESTIPULANTE
            --LEFT   OUTER JOIN TABELA_DIVISOES ESTI
            --ON     ESTI.DIVISAO = RELAC_ESTI.DIVISAO
            INNER  JOIN MULT_CALCULODIVISOES RELAC_CORR
            ON     RELAC_CORR.CALCULO = CALC.CALCULO
            AND    RELAC_CORR.NIVEL = v_1
            AND    RELAC_CORR.DIVISAO = p_corretor
            LEFT   OUTER JOIN TABELA_CALCULOS_REALTIME RT
            ON     RT.CALCULO = CALC.CALCULO
            AND    RT.ITEM = CALC.ITEM
            WHERE  (NVL(CALC.DATAVERSAO, SYSDATE) >= v_1_ano_para_tras)
            AND    (CALC.CEP IS NOT NULL OR calc.padrao IN (v_12, v_13))
            AND    CLIE.CGC_CPF = p_cpf_cnpj
            /********************* Fim do Trecho de Pesquisa do KCW  **********************/
            /********************* Inicio do Trecho de Pesquisa do KME  *******************/
            UNION ALL
            --
            SELECT CALC.NR_CALLO CALCULO
                  ,0 ITEM
                  ,CALC.NM_SGRDO NOME
                  --,TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO) CGC_CPF
                  ,CASE
                           WHEN LENGTH(NVL(CALC.NR_CPF_CNPJ_SGRDO,0)) > 11 THEN -- CNPJ
                                DECODE(CALC.NR_CPF_CNPJ_SGRDO,NULL,NULL,REPLACE(REPLACE(REPLACE(TO_CHAR(LPAD(REPLACE(CALC.NR_CPF_CNPJ_SGRDO,''),14 ,'0'),'00,000,000,0000,00'),',','.'),' ') ,'.'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(CALC.NR_CPF_CNPJ_SGRDO,14,'0'),1000000)/100),'0000'))||'.' ,'/'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(CALC.NR_CPF_CNPJ_SGRDO,14,'0'),1000000)/100) ,'0000'))||'-'))
                           WHEN LENGTH(NVL(CALC.NR_CPF_CNPJ_SGRDO,0)) > 0 THEN -- CPF
                                TRIM(DECODE(CALC.NR_CPF_CNPJ_SGRDO, NULL,NULL,TRANSLATE(TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO/100,'000,000,000.00'),',.','.-')))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL NOMEESTIPULANTE
                  ,CALC.DT_HORA_CALLO_COTAC DATACALCULO
                  ,NULL URL
                  ,CASE
                           WHEN CALC.CD_SITUC_NGOCO = v_E THEN
                            'Efetivado'
                           WHEN CALC.CD_SITUC_NGOCO = v_T THEN
                            'Transmitido'
                           WHEN CALC.CD_SITUC_NGOCO = v_C THEN
                            'Calculado'
                           ELSE
                            'Pendente'
                   END SITUACAO
                  ,CALC.CD_SITUC_NGOCO COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,CALC.CD_USURO_ULTMA_ATULZ COD_USUARIO
                  ,CASE
                           WHEN CALC.CD_PRDUT_PLATF = v_1806 THEN
                            'Empresarial MÈdias Empresas'
                           WHEN CALC.CD_PRDUT_PLATF = v_3001 THEN
                            'AgronegÛcio'
                           WHEN CALC.CD_PRDUT_PLATF = v_6709 THEN
                            'Riscos de Engenharia'
                           WHEN CALC.CD_PRDUT_PLATF = v_7187 THEN
                            'RD Equipamentos'
                           WHEN CALC.CD_PRDUT_PLATF = v_5121 THEN
                            'RC Obras'
                           ELSE
                           ' '
                   END PRODUTO
                  ,0 AS PADRAO
                  ,CALC.DT_HORA_ATULZ_STATU DATAEMISSAO
                  ,CALC.DT_HORA_ATULZ_STATU DATATRANSMISSAO
                  ,CALC.IC_VALDC_ONLIN VALIDADO
                  ,NULL AS DIAS
                  ,TO_CHAR(CALC.NR_PROTC_TRNSM) PROTOCOLOTRANS
                  ,NULL COD_ESTIPULANTE
                  ,CALC.CD_PRDUT_PLATF COD_PRODUTO
                  ,CALC.DT_INICO_VIGEN_SEGUR INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'KME' SISTEMA
                  ,NVL(CALC.CD_CRTOR_PLATF, 0) CORR_TMS
                  ,NVL(ACESS.CD_CRTOR_TMB, 0) CORR_TMB
                  ,NVL(To_Char(v_assessoria), v_N) CORR_ASER
                  ,' ' TIPO_OFERTA
                  ,0 VALOR_DE
                  ,0 VALOR_PARA
            FROM   ADMKME.KME0091_SUMAR_COTAC CALC
            INNER  JOIN ADMKME.KME0092_ACSSO_KIT_KME_WEB ACESS
            ON     ACESS.CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
            WHERE  (CALC.DT_HORA_CALLO_COTAC >= v_1_ano_para_tras)
            AND    CALC.CD_CRTOR_PLATF = v_CorretorTMS
            AND    EXISTS (SELECT 1
                    FROM   ADMKME.KME0092_ACSSO_KIT_KME_WEB
                    WHERE  ((CD_PRDUT_PLATF = v_1806 AND CD_PERFL_PRDUT IN (v_99, v_1, v_3, v_5, v_7, v_9, v_11, v_13, v_15, v_17, v_19, v_21, v_23, v_25, v_27, v_29)) OR
                           (CD_PRDUT_PLATF = v_7187 AND CD_PERFL_PRDUT IN (v_99, v_2, v_3, v_6, v_7, v_10, v_11, v_14, v_15, v_18, v_19, v_22, v_23, v_26, v_27, v_30)) OR
                           (CD_PRDUT_PLATF = v_3001 AND CD_PERFL_PRDUT IN (v_99, v_4, v_5, v_6, v_7, v_12, v_13, v_14, v_15, v_20, v_21, v_22, v_23, v_28, v_29, v_30)) OR
                           (CD_PRDUT_PLATF = v_6709 AND CD_PERFL_PRDUT IN (v_99, v_8, v_9, v_10, v_11, v_12, v_13, v_14, v_15, v_24, v_25, v_26, v_27, v_28, v_29, v_30)) OR
                           (CD_PRDUT_PLATF = v_5121 AND CD_PERFL_PRDUT IN (v_99, v_16, v_17, v_18, v_19, v_20, v_21, v_22, v_23, v_24, v_25, v_26, v_27, v_28, v_29, v_30)))
                    AND    ((NVL(v_assessoria, v_N) <> v_S AND IC_CRTOR_ASRDO = v_N) OR (IC_CRTOR_ASRDO = v_S))
                    AND    IC_CRTOR_ATIVO = v_S
                    AND    CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
                    AND    CALC.NR_CPF_CNPJ_SGRDO = v_cpf_cnpj_somente_numeros)
            /********************* Fim do Trecho de Pesquisa do KME  *******************/
            /********************* Inicio do Trecho de Pesquisa do Residencial F·cil  *******************/
            --
            UNION ALL
            --
            SELECT N.Cd_ngoco AS CALCULO
                  ,It.Nr_itseg AS ITEM
                  ,C.NM_CLIEN AS NOME
                  ,p_cpf_cnpj
                  ,NULL AS NOMEESTIPULANTE
                  ,N.DT_EMISS_NGOCO AS DATACALCULO
                  ,NULL URL
                  ,'Transmitido' AS SITUACAO
                  ,'T' AS COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,N.CD_USURO_CADMT_PPOTA AS COD_USUARIO
                  ,'Residencial F·cil' AS PRODUTO
                  ,0 AS PADRAO
                  ,n.DT_EMISS_NGOCO AS DATAEMISSAO
                  ,n.DT_EMISS_NGOCO AS DATATRANSMISSAO
                  ,NULL AS VALIDADO
                  ,NULL AS DIAS
                  ,NULL AS PROTOCOLOTRANS
                  ,NULL AS COD_ESTIPULANTE
                  ,1 AS COD_PRODUTO
                  ,Mn.DT_INICO_VIGEN AS INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'SSV' AS SISTEMA
                  ,N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS
                  ,0 AS CORR_TMB
                  ,NULL AS CORR_ASER
                  ,NULL AS TIPO_OFERTA
                  ,0 AS VALOR_DE
                  ,0 AS VALOR_PARA
            FROM   Ssv0084_ngoco       N
                  ,Ssv0081_mdulo_ngoco Mn
                  ,Ssv0076_itseg       It
                  ,SSV4002_CLIEN       C
                  ,SSV4006_CLIEN_PESSF PessoaFisica
            WHERE  It.Tp_histo_itseg = v_0_char
            AND    ((It.Cd_agatv = v_B1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_B1
                                                           AND    a.CD_MDUPR = v_14)) OR
                  (It.Cd_agatv = v_D1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_D1
                                                           AND    a.CD_MDUPR = v_14)))
            AND    it.CD_MDUPR = v_14
            AND    N.Cd_ngoco = It.Cd_ngoco
            AND    N.DT_EMISS_NGOCO >= v_1_ano_para_tras
            AND    N.Tp_histo = v_0_char
            AND    Mn.Cd_ngoco = it.CD_NGOCO
            AND    Mn.Tp_histo = v_0_char
            AND    Mn.Cd_mdupr = v_14
            AND    C.CD_CLIEN = N.CD_CLIEN
            AND    n.CD_CRTOR_SEGUR_PRCPA = v_CorretorTMS
            AND    c.cd_clien = PessoaFisica.cd_clien
            AND    PessoaFisica.nr_cpf = v_cpf_cnpj_somente_numeros
            --
            UNION ALL
            --
            SELECT N.Cd_ngoco AS CALCULO
                  ,It.Nr_itseg AS ITEM
                  ,C.NM_CLIEN AS NOME
                  ,p_cpf_cnpj
                  ,NULL AS NOMEESTIPULANTE
                  ,N.DT_EMISS_NGOCO AS DATACALCULO
                  ,NULL URL
                  ,'Transmitido' AS SITUACAO
                  ,'T' AS COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,N.CD_USURO_CADMT_PPOTA AS COD_USUARIO
                  ,'Residencial F·cil' AS PRODUTO
                  ,0 AS PADRAO
                  ,n.DT_EMISS_NGOCO AS DATAEMISSAO
                  ,n.DT_EMISS_NGOCO AS DATATRANSMISSAO
                  ,NULL AS VALIDADO
                  ,NULL AS DIAS
                  ,NULL AS PROTOCOLOTRANS
                  ,NULL AS COD_ESTIPULANTE
                  ,1 AS COD_PRODUTO
                  ,Mn.DT_INICO_VIGEN AS INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'SSV' AS SISTEMA
                  ,N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS
                  ,0 AS CORR_TMB
                  ,NULL AS CORR_ASER
                  ,NULL AS TIPO_OFERTA
                  ,0 AS VALOR_DE
                  ,0 AS VALOR_PARA
            FROM   Ssv0084_ngoco       N
                  ,Ssv0081_mdulo_ngoco Mn
                  ,Ssv0076_itseg       It
                  ,SSV4002_CLIEN       C
                  ,SSV4007_CLIEN_PESSJ PessoaJuridica
            WHERE  It.Tp_histo_itseg = v_0_char
            AND    ((It.Cd_agatv = v_B1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_B1
                                                           AND    a.CD_MDUPR = v_14)) OR
                  (It.Cd_agatv = v_D1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_D1
                                                           AND    a.CD_MDUPR = v_14)))
            AND    it.CD_MDUPR = v_14
            AND    N.Cd_ngoco = It.Cd_ngoco
            AND    N.DT_EMISS_NGOCO >= v_1_ano_para_tras
            AND    N.Tp_histo = v_0_char
            AND    Mn.Cd_ngoco = it.CD_NGOCO
            AND    Mn.Tp_histo = v_0_char
            AND    Mn.Cd_mdupr = v_14
            AND    C.CD_CLIEN = N.CD_CLIEN
            AND    n.CD_CRTOR_SEGUR_PRCPA = v_CorretorTMS
            AND    c.cd_clien = PessoaJuridica.cd_clien
            AND    PessoaJuridica.nr_cnpj = v_cpf_cnpj_somente_numeros;

    BEGIN
            --
            BEGIN
                    --
                    SELECT regexp_replace(v_cpf_cnpj, '[^[:digit:]]', NULL)
                    INTO   v_cpf_cnpj_somente_numeros
                    FROM   dual;
                    --
            EXCEPTION
                    WHEN OTHERS THEN
                            --
                            v_cpf_cnpj_somente_numeros      :=      NULL;
                            --
            END;
            --
            v_1_ano_para_tras       :=      SYSDATE -       365;
            --
            --Dbms_Output.Put_Line('v_cpf_cnpj_somente_numeros:' || p_cpf_cnpj_somente_numeros);
            --
            FOR rec IN c_busca_cpf
            LOOP
                IF P_PADRAOUSUARIO = 'R' THEN
                    BEGIN
                        SELECT COUNT(1)
                          INTO v_count_estip
                          FROM TABLE (KITFC002_ESTIP_TABLE (v_Estipulantes))
                         WHERE cd_estip = rec.COD_ESTIPULANTE;

                    EXCEPTION
                        WHEN OTHERS THEN
                            v_count_estip := 0;

                    END;
                END IF;

                IF P_PADRAOUSUARIO <> 'R' OR
                   v_count_estip <> 0 THEN

                    l_tab.EXTEND;
                    l_tab(l_tab.LAST) := KITTY003_BUSCA_ROW( rec.CALCULO
                                                            ,rec.ITEM
                                                            ,rec.NOME
                                                            ,rec.CGC_CPF
                                                            ,rec.NOMEESTIPULANTE
                                                            ,rec.DATACALCULO
                                                            ,rec.URL_RESID_FACIL
                                                            ,rec.SITUACAO
                                                            ,rec.COD_SITUACAO
                                                            ,rec.CALCULOORIGEM
                                                            ,rec.COD_USUARIO
                                                            ,rec.PRODUTO
                                                            ,rec.PADRAO
                                                            ,rec.DATAEMISSAO
                                                            ,rec.DATATRANSMISSAO
                                                            ,rec.VALIDADO
                                                            ,rec.DIAS
                                                            ,rec.PROTOCOLOTRANS
                                                            ,rec.COD_ESTIPULANTE
                                                            ,rec.COD_PRODUTO
                                                            ,rec.INICIOVIGENCIA
                                                            ,rec.NUMEROTITULO
                                                            ,rec.SISTEMA
                                                            ,rec.CORR_TMS
                                                            ,rec.CORR_TMB
                                                            ,rec.CORR_ASER
                                                            ,rec.TIPO_OFERTA
                                                            ,rec.VALOR_DE
                                                            ,rec.VALOR_PARA );

                END IF;

            END LOOP;
            --
            OPEN v_RESULTADO FOR SELECT * FROM TABLE (l_tab);

    END Busca_Por_CPF;

    PROCEDURE Busca_Por_Calculo (v_calculo      IN      NUMBER
                                ,v_corretor     IN      NUMBER
                                ,v_CorretorTMS  IN      NUMBER
                                ,v_assessoria   IN      VARCHAR2
                                ,v_RESULTADO    OUT     SYS_REFCURSOR) IS
            --
            --
            --v_corretor    NUMBER := 309;
            --v_CorretorTMS NUMBER := 20401;
            --v_assessoria  NUMBER := NULL;
            v_1_ano_para_tras       DATE;
            V_B1                    VARCHAR2(02)    :=      'B1';
            v_D1                    VARCHAR2(02)    :=      'D1';
            v_E                     VARCHAR2(1)     :=      'E';
            v_T                     VARCHAR2(1)     :=      'T';
            v_C                     VARCHAR2(1)     :=      'C';
            v_S                     VARCHAR2(1)     :=      'S';
            v_N                     VARCHAR2(1)     :=      'N';
            v_0_char                VARCHAR2(1)     :=      '0';
            v_1                     NUMBER(2)       :=      1;
            v_2                     NUMBER(2)       :=      2;
            v_3                     NUMBER(2)       :=      3;
            v_4                     NUMBER(1)       :=      4;
            v_5                     NUMBER(2)       :=      5;
            v_6                     NUMBER(2)       :=      6;
            v_7                     NUMBER(2)       :=      7;
            v_8                     NUMBER(2)       :=      8;
            v_9                     NUMBER(2)       :=      9;
            v_10                    NUMBER(2)       :=      10;
            v_11                    NUMBER(2)       :=      11;
            v_12                    NUMBER(2)       :=      12;
            v_13                    NUMBER(2)       :=      13;
            v_14                    NUMBER(02)      :=      14;
            v_15                    NUMBER(2)       :=      15;
            v_16                    NUMBER(2)       :=      16;
            v_17                    NUMBER(2)       :=      17;
            v_18                    NUMBER(2)       :=      18;
            v_19                    NUMBER(2)       :=      19;
            v_20                    NUMBER(2)       :=      20;
            v_21                    NUMBER(2)       :=      21;
            v_22                    NUMBER(2)       :=      22;
            v_23                    NUMBER(2)       :=      23;
            v_24                    NUMBER(2)       :=      24;
            v_25                    NUMBER(2)       :=      25;
            v_26                    NUMBER(2)       :=      26;
            v_27                    NUMBER(2)       :=      27;
            v_28                    NUMBER(2)       :=      28;
            v_29                    NUMBER(2)       :=      29;
            v_30                    NUMBER(2)       :=      30;
            v_99                    NUMBER(2)       :=      99;
            v_1806                  NUMBER(4)       :=      1806;
            v_7187                  NUMBER(4)       :=      7187;
            v_3001                  NUMBER(4)       :=      3001;
            v_6709                  NUMBER(4)       :=      6709;
            v_5121                  NUMBER(4)       :=      5121;
v_REN                       VARCHAR2(3)    :=     'REN';
V_GRD                      VARCHAR2(3)  :=    'GRD';
V_LIB                       VARCHAR2(3)    :=    'LIB';
V_APO                      VARCHAR2(3)  :=    'APO';
V_LIP                       VARCHAR2(3)    :=    'LIP';

V_R                       VARCHAR2(1)    :=    'R';
V_PRO                   VARCHAR2(3)    :=    'PRO';
V_52                      NUMBER(2)       :=  52;
V_258                    NUMBER := 258;
V_289                    NUMBER := 289;

V_699                    NUMBER := 699;
V_813                    NUMBER := 813;
V_700                    NUMBER := 700;
V_814                    NUMBER := 814;
V_701                    NUMBER := 701;
V_815                    NUMBER := 815;
V_D                       VARCHAR2(1)    :=    'D';


            l_tab KITTY004_BUSCA_TABLE := KITTY004_BUSCA_TABLE();

            CURSOR c_busca_calculo
            IS
            SELECT CALC.CALCULO
                  ,CALC.ITEM
                  ,CALC.NOME
                  ,CLIE.CGC_CPF
                  ,ESTI.NOME NOMEESTIPULANTE
                  ,CALC.DATACALCULO
                  ,RESDL.URL URL_RESID_FACIL
                  ,CASE
                           WHEN CALC.SITUACAO = v_E
                                AND CALC.TIPODOCUMENTO <> v_N THEN
                            'Efetivado'
                           WHEN CALC.SITUACAO = v_E
                                AND CALC.TIPODOCUMENTO = v_N THEN
                            'Finalizado sem transmiss„o'
                           WHEN CALC.SITUACAO = v_T THEN
                            'Transmitido'
                           WHEN CALC.SITUACAO = v_C THEN
                            'Calculado'
                           ELSE
                            'Pendente'
                   END SITUACAO
                  ,CALC.SITUACAO COD_SITUACAO
                  ,CALC.CALCULOORIGEM
                  ,CALC.COD_USUARIO
                  ,PROD.DESCRICAO AS PRODUTO
                  ,CALC.PADRAO
                  ,CALC.DATAEMISSAO
                  ,CALC.DATATRANSMISSAO
                  ,CALC.VALIDADO
                  ,trunc(calc.datavalidade) - trunc(SYSDATE) DIAS
                  ,CALC.PROTOCOLOTRANS
                  ,CALC.ESTIPULANTE COD_ESTIPULANTE
                  --,RELAC_ESTI.DIVISAO COD_ESTIPULANTE
                  ,CALC.PADRAO COD_PRODUTO
                  ,CALC.INICIOVIGENCIA
                  ,TO_NUMBER(NVL(CALC.NUMEROTITULO, '0')) NUMEROTITULO
                  ,'KCW' SISTEMA
                  ,0 CORR_TMS
                  ,0 CORR_TMB
                  ,' ' CORR_ASER
                  ,RT.TIPO_OFERTA
                  ,RT.VALOR_PREMIO_ORIGINAL VALOR_DE
                  ,RT.VALOR_PREMIO_REALTIME VALOR_PARA
            FROM   MULT_CALCULO CALC
            --LEFT   OUTER JOIN SSV0011_OFERT_RESDL RESDL
            --ON (CALC.CALCULOORIGEM = RESDL.CD_NGOCO_AUTO AND RESDL.IC_OFERT = 'S')
left outer join
(
select N.CD_NGOCO, N.CD_CRTOR_SEGUR_PRCPA, REPLACE(REPLACE(PARAM.VL_PARAM_SSV, '#CODIGO_NEGOCIO#', N.CD_NGOCO), '#USUARIO#', C.CD_CONVO) as URL
FROM SSV0084_NGOCO n, SSV0081_MDULO_NGOCO mn, SSV9099_PARAM_SSV PARAM, SSV5046_CONVO c, SSV0076_ITSEG i
WHERE
        N.CD_NGOCO = MN.CD_NGOCO
        AND I.CD_NGOCO = N.CD_NGOCO
        AND I.TP_HISTO_ITSEG =v_0_char
        AND N.TP_HISTO = v_0_char
        AND MN.TP_HISTO = v_0_char
        AND MN.CD_MDUPR IN (v_7,v_20,v_21)
        AND (N.CD_SITUC_NGOCO IN (v_REN, v_GRD, v_LIB,v_APO) OR (N.TP_RENOV_NGOCO = v_R AND N.CD_SITUC_NGOCO = v_PRO))
        AND N.DT_CANCL_NGOCO IS NULL
        AND MN.DT_FIM_VIGEN >= TRUNC(SYSDATE)
        AND PARAM.CD_GRP_PARAM_SSV = v_52
        AND PARAM.CD_PARAM_SSV = 'URL.BASE.EMISSAO.RESIDENCIAL.FACIL'
        AND C.CD_ITRNO_CONVO = N.CD_CRTOR_SEGUR_PRCPA
        AND C.TP_CONVO = v_C
        -- CORRETORES N√O OFERTA
        AND N.CD_CRTOR_SEGUR_PRCPA NOT IN
        (SELECT TO_NUMBER(regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = 52 AND PARAM.CD_PARAM_SSV = 'CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL'),'[^,]+', 1, level)) from dual connect by regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = 52 AND PARAM.CD_PARAM_SSV = 'CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL'), '[^,]+', 1, level) is not null)
        -- CLIENTE N√O POSSUI SEGURO RESIDENCIAL ATIVO
        AND NOT EXISTS (
                SELECT 1
                FROM SSV0081_MDULO_NGOCO MN1, SSV0084_NGOCO N1
                WHERE
                N1.CD_NGOCO = MN1.CD_NGOCO
                AND N1.TP_HISTO = v_0_char
                AND MN1.TP_HISTO = v_0_char
                AND MN1.CD_MDUPR = v_14
                AND N1.DT_CANCL_NGOCO IS NULL
                AND N1.CD_CLIEN = N.CD_CLIEN
                AND N1.CD_SITUC_NGOCO IN (v_REN, v_LIB, v_LIP, v_GRD, v_APO)
                AND SYSDATE BETWEEN MN1.DT_INICO_VIGEN AND MN1.DT_FIM_VIGEN
        )
        -- QBR APARTAMENTO OU CASA
        AND EXISTS (
            SELECT 1
            FROM SSV0104_QUEST_RESIT QBR
            WHERE
                QBR.NR_ITSEG = I.NR_ITSEG
                AND QBR.CD_QBR IN (v_258, v_289)
                AND QBR.CD_RESPT_QBR IN (v_699, v_813, v_700, v_814, v_701, v_815)
        )
) RESDL
ON (CALC.NUMERONEGOCIORESERVADO = RESDL.CD_NGOCO)
 INNER  JOIN MULT_PADRAO PROD
            ON     PROD.PADRAO = CALC.PADRAO
            INNER  JOIN TABELA_CLIENTES CLIE
            ON     CLIE.CLIENTE = CALC.CLIENTE
            --LEFT   OUTER JOIN MULT_CALCULODIVISOES RELAC_ESTI
            --ON     RELAC_ESTI.CALCULO = CALC.CALCULO
            --AND    RELAC_ESTI.NIVEL = v_4
            --AND    RELAC_ESTI.DIVISAO IN (SELECT cd_estip FROM TABLE (KITFC002_ESTIP_TABLE (v_Estipulantes)))
            INNER JOIN TABELA_DIVISOES ESTI
            ON     ESTI.DIVISAO = CALC.ESTIPULANTE
            --LEFT   OUTER JOIN TABELA_DIVISOES ESTI
            --ON     ESTI.DIVISAO = RELAC_ESTI.DIVISAO
            INNER JOIN MULT_CALCULODIVISOES RELAC_CORR
            ON     RELAC_CORR.CALCULO = CALC.CALCULO
            AND    RELAC_CORR.NIVEL = v_1
            AND    RELAC_CORR.DIVISAO = p_corretor
            LEFT   OUTER JOIN TABELA_CALCULOS_REALTIME RT
            ON     RT.CALCULO = CALC.CALCULO
            AND    RT.ITEM = CALC.ITEM
            WHERE  (NVL(CALC.DATAVERSAO, SYSDATE) >= v_1_ano_para_tras)
            AND    (CALC.CEP IS NOT NULL OR calc.padrao IN (v_12, v_13))
            AND CALC.CALCULO = v_calculo
            /********************* Fim do Trecho de Pesquisa do KCW  **********************/
            /********************* Inicio do Trecho de Pesquisa do KME  *******************/
            UNION ALL
            --
            SELECT CALC.NR_CALLO CALCULO
                  ,0 ITEM
                  ,CALC.NM_SGRDO NOME
                  --,TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO) CGC_CPF
                  ,CASE
                           WHEN LENGTH(NVL(CALC.NR_CPF_CNPJ_SGRDO,0)) > 11 THEN -- CNPJ
                                DECODE(CALC.NR_CPF_CNPJ_SGRDO,NULL,NULL,REPLACE(REPLACE(REPLACE(TO_CHAR(LPAD(REPLACE(CALC.NR_CPF_CNPJ_SGRDO,''),14 ,'0'),'00,000,000,0000,00'),',','.'),' ') ,'.'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(CALC.NR_CPF_CNPJ_SGRDO,14,'0'),1000000)/100),'0000'))||'.' ,'/'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(CALC.NR_CPF_CNPJ_SGRDO,14,'0'),1000000)/100) ,'0000'))||'-'))
                           WHEN LENGTH(NVL(CALC.NR_CPF_CNPJ_SGRDO,0)) > 0 THEN -- CPF
                                TRIM(DECODE(CALC.NR_CPF_CNPJ_SGRDO, NULL,NULL,TRANSLATE(TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO/100,'000,000,000.00'),',.','.-')))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL NOMEESTIPULANTE
                  ,CALC.DT_HORA_CALLO_COTAC DATACALCULO
                  ,NULL URL
                  ,CASE
                           WHEN CALC.CD_SITUC_NGOCO = v_E THEN
                            'Efetivado'
                           WHEN CALC.CD_SITUC_NGOCO = v_T THEN
                            'Transmitido'
                           WHEN CALC.CD_SITUC_NGOCO = v_C THEN
                            'Calculado'
                           ELSE
                            'Pendente'
                   END SITUACAO
                  ,CALC.CD_SITUC_NGOCO COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,CALC.CD_USURO_ULTMA_ATULZ COD_USUARIO
                  ,CASE
                           WHEN CALC.CD_PRDUT_PLATF = v_1806 THEN
                            'Empresarial MÈdias Empresas'
                           WHEN CALC.CD_PRDUT_PLATF = v_3001 THEN
                            'AgronegÛcio'
                           WHEN CALC.CD_PRDUT_PLATF = v_6709 THEN
                            'Riscos de Engenharia'
                           WHEN CALC.CD_PRDUT_PLATF = v_7187 THEN
                            'RD Equipamentos'
                           WHEN CALC.CD_PRDUT_PLATF = v_5121 THEN
                            'RC Obras'
                           ELSE
                           ' '
                   END PRODUTO
                  ,0 AS PADRAO
                  ,CALC.DT_HORA_ATULZ_STATU DATAEMISSAO
                  ,CALC.DT_HORA_ATULZ_STATU DATATRANSMISSAO
                  ,CALC.IC_VALDC_ONLIN VALIDADO
                  ,NULL AS DIAS
                  ,TO_CHAR(CALC.NR_PROTC_TRNSM) PROTOCOLOTRANS
                  ,NULL COD_ESTIPULANTE
                  ,CALC.CD_PRDUT_PLATF COD_PRODUTO
                  ,CALC.DT_INICO_VIGEN_SEGUR INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'KME' SISTEMA
                  ,NVL(CALC.CD_CRTOR_PLATF, 0) CORR_TMS
                  ,NVL(ACESS.CD_CRTOR_TMB, 0) CORR_TMB
                  ,NVL(To_Char(v_assessoria), v_N) CORR_ASER
                  ,' ' TIPO_OFERTA
                  ,0 VALOR_DE
                  ,0 VALOR_PARA
            FROM   ADMKME.KME0091_SUMAR_COTAC CALC
            INNER  JOIN ADMKME.KME0092_ACSSO_KIT_KME_WEB ACESS
            ON     ACESS.CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
            WHERE  (CALC.DT_HORA_CALLO_COTAC >= v_1_ano_para_tras)
            AND    CALC.CD_CRTOR_PLATF = v_CorretorTMS
            AND    EXISTS (SELECT 1
                    FROM   ADMKME.KME0092_ACSSO_KIT_KME_WEB
                    WHERE  ((CD_PRDUT_PLATF = v_1806 AND CD_PERFL_PRDUT IN (v_99, v_1, v_3, v_5, v_7, v_9, v_11, v_13, v_15, v_17, v_19, v_21, v_23, v_25, v_27, v_29)) OR
                           (CD_PRDUT_PLATF = v_7187 AND CD_PERFL_PRDUT IN (v_99, v_2, v_3, v_6, v_7, v_10, v_11, v_14, v_15, v_18, v_19, v_22, v_23, v_26, v_27, v_30)) OR
                           (CD_PRDUT_PLATF = v_3001 AND CD_PERFL_PRDUT IN (v_99, v_4, v_5, v_6, v_7, v_12, v_13, v_14, v_15, v_20, v_21, v_22, v_23, v_28, v_29, v_30)) OR
                           (CD_PRDUT_PLATF = v_6709 AND CD_PERFL_PRDUT IN (v_99, v_8, v_9, v_10, v_11, v_12, v_13, v_14, v_15, v_24, v_25, v_26, v_27, v_28, v_29, v_30)) OR
                           (CD_PRDUT_PLATF = v_5121 AND CD_PERFL_PRDUT IN (v_99, v_16, v_17, v_18, v_19, v_20, v_21, v_22, v_23, v_24, v_25, v_26, v_27, v_28, v_29, v_30)))
                    AND    ((NVL(v_assessoria, v_N) <> v_S AND IC_CRTOR_ASRDO = v_N) OR (IC_CRTOR_ASRDO = v_S))
                    AND    IC_CRTOR_ATIVO = v_S
                    AND    CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
                    AND CALC.NR_CALLO = v_calculo)
            /********************* Fim do Trecho de Pesquisa do KME  *******************/
            /********************* Inicio do Trecho de Pesquisa do Residencial F·cil  *******************/
            UNION ALL
            SELECT N.Cd_ngoco AS CALCULO
                  ,It.Nr_itseg AS ITEM
                  ,C.NM_CLIEN AS NOME
                  --,p_cpf_cnpj
                  ,CASE
                           WHEN LENGTH(NVL(PessoaFisica.NR_CPF,0)) > 0 THEN -- CPF
                                TRIM(DECODE(PessoaFisica.NR_CPF, NULL,NULL,TRANSLATE(TO_CHAR(PessoaFisica.NR_CPF/100,'000,000,000.00'),',.','.-')))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL AS NOMEESTIPULANTE
                  ,N.DT_EMISS_NGOCO AS DATACALCULO
                  ,NULL URL
                  ,'Transmitido' AS SITUACAO
                  ,'T' AS COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,N.CD_USURO_CADMT_PPOTA AS COD_USUARIO
                  ,'Residencial F·cil' AS PRODUTO
                  ,0 AS PADRAO
                  ,n.DT_EMISS_NGOCO AS DATAEMISSAO
                  ,n.DT_EMISS_NGOCO AS DATATRANSMISSAO
                  ,NULL AS VALIDADO
                  ,NULL AS DIAS
                  ,NULL AS PROTOCOLOTRANS
                  ,NULL AS COD_ESTIPULANTE
                  ,1 AS COD_PRODUTO
                  ,Mn.DT_INICO_VIGEN AS INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'SSV' AS SISTEMA
                  ,N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS
                  ,0 AS CORR_TMB
                  ,NULL AS CORR_ASER
                  ,NULL AS TIPO_OFERTA
                  ,0 AS VALOR_DE
                  ,0 AS VALOR_PARA
            FROM   Ssv0084_ngoco       N
                  ,Ssv0081_mdulo_ngoco Mn
                  ,Ssv0076_itseg       It
                  ,SSV4002_CLIEN       C
                  ,SSV4006_CLIEN_PESSF PessoaFisica
            WHERE  It.Tp_histo_itseg = v_0_char
            AND    ((It.Cd_agatv = v_B1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_B1
                                                           AND    a.CD_MDUPR = v_14)) OR
                  (It.Cd_agatv = v_D1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_D1
                                                           AND    a.CD_MDUPR = v_14)))
            AND    it.CD_MDUPR = v_14
            AND    N.Cd_ngoco = It.Cd_ngoco
            AND    N.DT_EMISS_NGOCO >= v_1_ano_para_tras
            AND    N.Tp_histo = v_0_char
            AND    Mn.Cd_ngoco = it.CD_NGOCO
            AND    Mn.Tp_histo = v_0_char
            AND    Mn.Cd_mdupr = v_14
            AND    C.CD_CLIEN = N.CD_CLIEN
            AND    n.CD_CRTOR_SEGUR_PRCPA = v_CorretorTMS
            AND    c.cd_clien = PessoaFisica.cd_clien
            AND    N.Cd_ngoco = v_calculo
            --
            UNION ALL
            --
            SELECT N.Cd_ngoco AS CALCULO
                  ,It.Nr_itseg AS ITEM
                  ,C.NM_CLIEN AS NOME
                  --,p_cpf_cnpj
                  ,CASE
                           WHEN LENGTH(NVL(PessoaJuridica.NR_CNPJ,0)) > 0 THEN -- CNPJ
                                DECODE(PessoaJuridica.NR_CNPJ,NULL,NULL,REPLACE(REPLACE(REPLACE(TO_CHAR(LPAD(REPLACE(PessoaJuridica.NR_CNPJ,''),14 ,'0'),'00,000,000,0000,00'),',','.'),' ') ,'.'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(PessoaJuridica.NR_CNPJ,14,'0'),1000000)/100),'0000'))||'.' ,'/'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(PessoaJuridica.NR_CNPJ,14,'0'),1000000)/100) ,'0000'))||'-'))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL AS NOMEESTIPULANTE
                  ,N.DT_EMISS_NGOCO AS DATACALCULO
                  ,NULL URL
                  ,'Transmitido' AS SITUACAO
                  ,'T' AS COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,N.CD_USURO_CADMT_PPOTA AS COD_USUARIO
                  ,'Residencial F·cil' AS PRODUTO
                  ,0 AS PADRAO
                  ,n.DT_EMISS_NGOCO AS DATAEMISSAO
                  ,n.DT_EMISS_NGOCO AS DATATRANSMISSAO
                  ,NULL AS VALIDADO
                  ,NULL AS DIAS
                  ,NULL AS PROTOCOLOTRANS
                  ,NULL AS COD_ESTIPULANTE
                  ,1 AS COD_PRODUTO
                  ,Mn.DT_INICO_VIGEN AS INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'SSV' AS SISTEMA
                  ,N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS
                  ,0 AS CORR_TMB
                  ,NULL AS CORR_ASER
                  ,NULL AS TIPO_OFERTA
                  ,0 AS VALOR_DE
                  ,0 AS VALOR_PARA
            FROM   Ssv0084_ngoco       N
                  ,Ssv0081_mdulo_ngoco Mn
                  ,Ssv0076_itseg       It
                  ,SSV4002_CLIEN       C
                  ,SSV4007_CLIEN_PESSJ PessoaJuridica
            WHERE  It.Tp_histo_itseg = v_0_char
            AND    ((It.Cd_agatv = v_B1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_B1
                                                           AND    a.CD_MDUPR = v_14)) OR
                  (It.Cd_agatv = v_D1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_D1
                                                           AND    a.CD_MDUPR = v_14)))
            AND    it.CD_MDUPR = v_14
            AND    N.Cd_ngoco = It.Cd_ngoco
            AND    N.DT_EMISS_NGOCO >= v_1_ano_para_tras
            AND    N.Tp_histo = v_0_char
            AND    Mn.Cd_ngoco = it.CD_NGOCO
            AND    Mn.Tp_histo = v_0_char
            AND    Mn.Cd_mdupr = v_14
            AND    C.CD_CLIEN = N.CD_CLIEN
            AND    n.CD_CRTOR_SEGUR_PRCPA = v_CorretorTMS
            AND    c.cd_clien = PessoaJuridica.cd_clien
            AND    N.Cd_ngoco = v_calculo;

    BEGIN
            v_1_ano_para_tras       :=      SYSDATE -       365;
            --
            FOR rec IN c_busca_calculo
            LOOP
                IF P_PADRAOUSUARIO = 'R' THEN
                    BEGIN
                        SELECT COUNT(1)
                          INTO v_count_estip
                          FROM TABLE (KITFC002_ESTIP_TABLE (v_Estipulantes))
                         WHERE cd_estip = rec.COD_ESTIPULANTE;

                    EXCEPTION
                        WHEN OTHERS THEN
                            v_count_estip := 0;

                    END;
                END IF;

                IF P_PADRAOUSUARIO <> 'R' OR
                   v_count_estip <> 0 THEN

                    l_tab.EXTEND;
                    l_tab(l_tab.LAST) := KITTY003_BUSCA_ROW( rec.CALCULO
                                                            ,rec.ITEM
                                                            ,rec.NOME
                                                            ,rec.CGC_CPF
                                                            ,rec.NOMEESTIPULANTE
                                                            ,rec.DATACALCULO
                                                            ,rec.URL_RESID_FACIL
                                                            ,rec.SITUACAO
                                                            ,rec.COD_SITUACAO
                                                            ,rec.CALCULOORIGEM
                                                            ,rec.COD_USUARIO
                                                            ,rec.PRODUTO
                                                            ,rec.PADRAO
                                                            ,rec.DATAEMISSAO
                                                            ,rec.DATATRANSMISSAO
                                                            ,rec.VALIDADO
                                                            ,rec.DIAS
                                                            ,rec.PROTOCOLOTRANS
                                                            ,rec.COD_ESTIPULANTE
                                                            ,rec.COD_PRODUTO
                                                            ,rec.INICIOVIGENCIA
                                                            ,rec.NUMEROTITULO
                                                            ,rec.SISTEMA
                                                            ,rec.CORR_TMS
                                                            ,rec.CORR_TMB
                                                            ,rec.CORR_ASER
                                                            ,rec.TIPO_OFERTA
                                                            ,rec.VALOR_DE
                                                            ,rec.VALOR_PARA );

                END IF;

            END LOOP;
            --
            OPEN v_RESULTADO FOR SELECT * FROM TABLE (l_tab);

    END Busca_Por_Calculo;

    PROCEDURE Busca_Por_DataCalculo (v_periodo      IN      NUMBER
                                    ,v_corretor     IN      NUMBER
                                    ,v_CorretorTMS  IN      NUMBER
                                    ,v_assessoria   IN      VARCHAR2
                                    ,v_RESULTADO    OUT     SYS_REFCURSOR) IS
            --
            --
            --v_corretor    NUMBER := 309;
            --v_CorretorTMS NUMBER := 20401;
            --v_assessoria  NUMBER := NULL;
            V_B1                    VARCHAR2(02)    :=      'B1';
            v_D1                    VARCHAR2(02)    :=      'D1';
            v_E                     VARCHAR2(1)     :=      'E';
            v_T                     VARCHAR2(1)     :=      'T';
            v_C                     VARCHAR2(1)     :=      'C';
            v_S                     VARCHAR2(1)     :=      'S';
            v_N                     VARCHAR2(1)     :=      'N';
            v_0_char                VARCHAR2(1)     :=      '0';
            v_1                     NUMBER(2)       :=      1;
            v_2                     NUMBER(2)       :=      2;
            v_3                     NUMBER(2)       :=      3;
            v_4                     NUMBER(1)       :=      4;
            v_5                     NUMBER(2)       :=      5;
            v_6                     NUMBER(2)       :=      6;
            v_7                     NUMBER(2)       :=      7;
            v_8                     NUMBER(2)       :=      8;
            v_9                     NUMBER(2)       :=      9;
            v_10                    NUMBER(2)       :=      10;
            v_11                    NUMBER(2)       :=      11;
            v_12                    NUMBER(2)       :=      12;
            v_13                    NUMBER(2)       :=      13;
            v_14                    NUMBER(02)      :=      14;
            v_15                    NUMBER(2)       :=      15;
            v_16                    NUMBER(2)       :=      16;
            v_17                    NUMBER(2)       :=      17;
            v_18                    NUMBER(2)       :=      18;
            v_19                    NUMBER(2)       :=      19;
            v_20                    NUMBER(2)       :=      20;
            v_21                    NUMBER(2)       :=      21;
            v_22                    NUMBER(2)       :=      22;
            v_23                    NUMBER(2)       :=      23;
            v_24                    NUMBER(2)       :=      24;
            v_25                    NUMBER(2)       :=      25;
            v_26                    NUMBER(2)       :=      26;
            v_27                    NUMBER(2)       :=      27;
            v_28                    NUMBER(2)       :=      28;
            v_29                    NUMBER(2)       :=      29;
            v_30                    NUMBER(2)       :=      30;
            v_99                    NUMBER(2)       :=      99;
            v_1806                  NUMBER(4)       :=      1806;
            v_7187                  NUMBER(4)       :=      7187;
            v_3001                  NUMBER(4)       :=      3001;
            v_6709                  NUMBER(4)       :=      6709;
            v_5121                  NUMBER(4)       :=      5121;
            v_datacalculo_inicio     DATE             :=         TRUNC(p_periodo_inicio - v_periodo);
            v_datacalculo_fim         DATE             :=         TRUNC(p_periodo_fim + 1);
v_REN                       VARCHAR2(3)    :=     'REN';
V_GRD                      VARCHAR2(3)  :=    'GRD';
V_LIB                       VARCHAR2(3)    :=    'LIB';
V_APO                      VARCHAR2(3)  :=    'APO';
V_LIP                       VARCHAR2(3)    :=    'LIP';

V_R                       VARCHAR2(1)    :=    'R';
V_PRO                   VARCHAR2(3)    :=    'PRO';
V_52                      NUMBER(2)       :=  52;
V_258                    NUMBER := 258;
V_289                    NUMBER := 289;

V_699                    NUMBER := 699;
V_813                    NUMBER := 813;
V_700                    NUMBER := 700;
V_814                    NUMBER := 814;
V_701                    NUMBER := 701;
V_815                    NUMBER := 815;
V_D                       VARCHAR2(1)    :=    'D';


            l_tab KITTY004_BUSCA_TABLE := KITTY004_BUSCA_TABLE();

            CURSOR c_busca_datacalculo
            IS
            SELECT CALC.CALCULO
                  ,CALC.ITEM
                  ,CALC.NOME
                  ,CLIE.CGC_CPF
                  ,ESTI.NOME NOMEESTIPULANTE
                  ,CALC.DATACALCULO
                  ,RESDL.URL    URL_RESID_FACIL
                  ,CASE
                           WHEN CALC.SITUACAO = v_E
                                AND CALC.TIPODOCUMENTO <> v_N THEN
                            'Efetivado'
                           WHEN CALC.SITUACAO = v_E
                                AND CALC.TIPODOCUMENTO = v_N THEN
                            'Finalizado sem transmiss„o'
                           WHEN CALC.SITUACAO = v_T THEN
                            'Transmitido'
                           WHEN CALC.SITUACAO = v_C THEN
                            'Calculado'
                           ELSE
                            'Pendente'
                   END SITUACAO
                  ,CALC.SITUACAO COD_SITUACAO
                  ,CALC.CALCULOORIGEM
                  ,CALC.COD_USUARIO
                  ,PROD.DESCRICAO AS PRODUTO
                  ,CALC.PADRAO
                  ,CALC.DATAEMISSAO
                  ,CALC.DATATRANSMISSAO
                  ,CALC.VALIDADO
                  ,trunc(calc.datavalidade) - trunc(SYSDATE) DIAS
                  ,CALC.PROTOCOLOTRANS
                  ,CALC.ESTIPULANTE COD_ESTIPULANTE
                  --,RELAC_ESTI.DIVISAO COD_ESTIPULANTE
                  ,CALC.PADRAO COD_PRODUTO
                  ,CALC.INICIOVIGENCIA
                  ,TO_NUMBER(NVL(CALC.NUMEROTITULO, '0')) NUMEROTITULO
                  ,'KCW' SISTEMA
                  ,0 CORR_TMS
                  ,0 CORR_TMB
                  ,' ' CORR_ASER
                  ,RT.TIPO_OFERTA
                  ,RT.VALOR_PREMIO_ORIGINAL VALOR_DE
                  ,RT.VALOR_PREMIO_REALTIME VALOR_PARA
            FROM   MULT_CALCULO CALC
            --LEFT   OUTER JOIN SSV0011_OFERT_RESDL RESDL
            --ON (CALC.CALCULOORIGEM = RESDL.CD_NGOCO_AUTO AND RESDL.IC_OFERT = 'S')
left outer join
(
select N.CD_NGOCO, N.CD_CRTOR_SEGUR_PRCPA, REPLACE(REPLACE(PARAM.VL_PARAM_SSV, '#CODIGO_NEGOCIO#', N.CD_NGOCO), '#USUARIO#', C.CD_CONVO) as URL
FROM SSV0084_NGOCO n, SSV0081_MDULO_NGOCO mn, SSV9099_PARAM_SSV PARAM, SSV5046_CONVO c, SSV0076_ITSEG i
WHERE
        N.CD_NGOCO = MN.CD_NGOCO
        AND I.CD_NGOCO = N.CD_NGOCO
        AND I.TP_HISTO_ITSEG = v_0_char
        AND N.TP_HISTO =v_0_char
        AND MN.TP_HISTO =v_0_char
        AND MN.CD_MDUPR IN (v_7,v_20,v_21)
        AND (N.CD_SITUC_NGOCO IN (v_REN, v_GRD, v_LIB, v_APO) OR (N.TP_RENOV_NGOCO = v_R AND N.CD_SITUC_NGOCO = v_PRO))
        AND N.DT_CANCL_NGOCO IS NULL
        AND MN.DT_FIM_VIGEN >= TRUNC(SYSDATE)
        AND PARAM.CD_GRP_PARAM_SSV = v_52
        AND PARAM.CD_PARAM_SSV = 'URL.BASE.EMISSAO.RESIDENCIAL.FACIL'
        AND C.CD_ITRNO_CONVO = N.CD_CRTOR_SEGUR_PRCPA
        AND C.TP_CONVO = v_C
        -- CORRETORES N√O OFERTA
        AND N.CD_CRTOR_SEGUR_PRCPA NOT IN
        (SELECT TO_NUMBER(regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = v_52 AND PARAM.CD_PARAM_SSV = 'CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL'),'[^,]+', 1, level)) from dual connect by regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = v_52 AND PARAM.CD_PARAM_SSV = 'CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL'), '[^,]+', 1, level) is not null)
        -- CLIENTE N√O POSSUI SEGURO RESIDENCIAL ATIVO
        AND NOT EXISTS (
                SELECT 1
                FROM SSV0081_MDULO_NGOCO MN1, SSV0084_NGOCO N1
                WHERE
                N1.CD_NGOCO = MN1.CD_NGOCO
                AND N1.TP_HISTO = v_0_char
                AND MN1.TP_HISTO = v_0_char
                AND MN1.CD_MDUPR = v_14
                AND N1.DT_CANCL_NGOCO IS NULL
                AND N1.CD_CLIEN = N.CD_CLIEN
                AND N1.CD_SITUC_NGOCO IN (v_REN, v_LIB, v_LIP, v_GRD, v_APO)
                AND SYSDATE BETWEEN MN1.DT_INICO_VIGEN AND MN1.DT_FIM_VIGEN
        )
        -- QBR APARTAMENTO OU CASA
        AND EXISTS (
            SELECT 1
            FROM SSV0104_QUEST_RESIT QBR
            WHERE
                QBR.NR_ITSEG = I.NR_ITSEG
                AND QBR.CD_QBR IN (v_258, v_289)
                AND QBR.CD_RESPT_QBR IN (v_699, v_813, v_700, v_814, v_701, v_815)
        )
) RESDL
ON (CALC.NUMERONEGOCIORESERVADO = RESDL.CD_NGOCO)
INNER  JOIN MULT_PADRAO PROD
            ON     PROD.PADRAO = CALC.PADRAO
            INNER  JOIN TABELA_CLIENTES CLIE
            ON     CLIE.CLIENTE = CALC.CLIENTE
            --LEFT   OUTER JOIN MULT_CALCULODIVISOES RELAC_ESTI
            --ON     RELAC_ESTI.CALCULO = CALC.CALCULO
            --AND    RELAC_ESTI.NIVEL = v_4
            --AND    RELAC_ESTI.DIVISAO IN (SELECT cd_estip FROM TABLE (KITFC002_ESTIP_TABLE (v_Estipulantes)))
            INNER JOIN TABELA_DIVISOES ESTI
            ON     ESTI.DIVISAO = CALC.ESTIPULANTE
            --LEFT   OUTER JOIN TABELA_DIVISOES ESTI
            --ON     ESTI.DIVISAO = RELAC_ESTI.DIVISAO
            INNER JOIN MULT_CALCULODIVISOES RELAC_CORR
            ON     RELAC_CORR.CALCULO = CALC.CALCULO
            AND    RELAC_CORR.NIVEL = v_1
            AND    RELAC_CORR.DIVISAO = p_corretor
            LEFT   OUTER JOIN TABELA_CALCULOS_REALTIME RT
            ON     RT.CALCULO = CALC.CALCULO
            AND    RT.ITEM = CALC.ITEM
            WHERE  (CALC.CEP IS NOT NULL OR calc.padrao IN (v_12, v_13))
            AND    CALC.DATACALCULO >= v_datacalculo_inicio
            AND    CALC.DATACALCULO < v_datacalculo_fim
            /********************* Fim do Trecho de Pesquisa do KCW  **********************/
            /********************* Inicio do Trecho de Pesquisa do KME  *******************/
            UNION ALL
            --
            SELECT CALC.NR_CALLO CALCULO
                  ,0 ITEM
                  ,CALC.NM_SGRDO NOME
                  --,TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO) CGC_CPF
                  ,CASE
                           WHEN LENGTH(NVL(CALC.NR_CPF_CNPJ_SGRDO,0)) > 11 THEN -- CNPJ
                                DECODE(CALC.NR_CPF_CNPJ_SGRDO,NULL,NULL,REPLACE(REPLACE(REPLACE(TO_CHAR(LPAD(REPLACE(CALC.NR_CPF_CNPJ_SGRDO,''),14 ,'0'),'00,000,000,0000,00'),',','.'),' ') ,'.'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(CALC.NR_CPF_CNPJ_SGRDO,14,'0'),1000000)/100),'0000'))||'.' ,'/'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(CALC.NR_CPF_CNPJ_SGRDO,14,'0'),1000000)/100) ,'0000'))||'-'))
                           WHEN LENGTH(NVL(CALC.NR_CPF_CNPJ_SGRDO,0)) > 0 THEN -- CPF
                                TRIM(DECODE(CALC.NR_CPF_CNPJ_SGRDO, NULL,NULL,TRANSLATE(TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO/100,'000,000,000.00'),',.','.-')))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL NOMEESTIPULANTE
                  ,CALC.DT_HORA_CALLO_COTAC DATACALCULO
                  ,NULL URL
                  ,CASE
                           WHEN CALC.CD_SITUC_NGOCO = v_E THEN
                            'Efetivado'
                           WHEN CALC.CD_SITUC_NGOCO = v_T THEN
                            'Transmitido'
                           WHEN CALC.CD_SITUC_NGOCO = v_C THEN
                            'Calculado'
                           ELSE
                            'Pendente'
                   END SITUACAO
                  ,CALC.CD_SITUC_NGOCO COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,CALC.CD_USURO_ULTMA_ATULZ COD_USUARIO
                  ,CASE
                           WHEN CALC.CD_PRDUT_PLATF = v_1806 THEN
                            'Empresarial MÈdias Empresas'
                           WHEN CALC.CD_PRDUT_PLATF = v_3001 THEN
                            'AgronegÛcio'
                           WHEN CALC.CD_PRDUT_PLATF = v_6709 THEN
                            'Riscos de Engenharia'
                           WHEN CALC.CD_PRDUT_PLATF = v_7187 THEN
                            'RD Equipamentos'
                           WHEN CALC.CD_PRDUT_PLATF = v_5121 THEN
                            'RC Obras'
                           ELSE
                           ' '
                   END PRODUTO
                  ,0 AS PADRAO
                  ,CALC.DT_HORA_ATULZ_STATU DATAEMISSAO
                  ,CALC.DT_HORA_ATULZ_STATU DATATRANSMISSAO
                  ,CALC.IC_VALDC_ONLIN VALIDADO
                  ,NULL AS DIAS
                  ,TO_CHAR(CALC.NR_PROTC_TRNSM) PROTOCOLOTRANS
                  ,NULL COD_ESTIPULANTE
                  ,CALC.CD_PRDUT_PLATF COD_PRODUTO
                  ,CALC.DT_INICO_VIGEN_SEGUR INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'KME' SISTEMA
                  ,NVL(CALC.CD_CRTOR_PLATF, 0) CORR_TMS
                  ,NVL(ACESS.CD_CRTOR_TMB, 0) CORR_TMB
                  ,NVL(To_Char(v_assessoria), v_N) CORR_ASER
                  ,' ' TIPO_OFERTA
                  ,0 VALOR_DE
                  ,0 VALOR_PARA
            FROM   ADMKME.KME0091_SUMAR_COTAC CALC
            INNER  JOIN ADMKME.KME0092_ACSSO_KIT_KME_WEB ACESS
            ON     ACESS.CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
            WHERE  CALC.CD_CRTOR_PLATF = v_CorretorTMS
            AND    EXISTS (SELECT 1
                    FROM   ADMKME.KME0092_ACSSO_KIT_KME_WEB
                    WHERE  ((CD_PRDUT_PLATF = v_1806 AND CD_PERFL_PRDUT IN (v_99, v_1, v_3, v_5, v_7, v_9, v_11, v_13, v_15, v_17, v_19, v_21, v_23, v_25, v_27, v_29)) OR
                           (CD_PRDUT_PLATF = v_7187 AND CD_PERFL_PRDUT IN (v_99, v_2, v_3, v_6, v_7, v_10, v_11, v_14, v_15, v_18, v_19, v_22, v_23, v_26, v_27, v_30)) OR
                           (CD_PRDUT_PLATF = v_3001 AND CD_PERFL_PRDUT IN (v_99, v_4, v_5, v_6, v_7, v_12, v_13, v_14, v_15, v_20, v_21, v_22, v_23, v_28, v_29, v_30)) OR
                           (CD_PRDUT_PLATF = v_6709 AND CD_PERFL_PRDUT IN (v_99, v_8, v_9, v_10, v_11, v_12, v_13, v_14, v_15, v_24, v_25, v_26, v_27, v_28, v_29, v_30)) OR
                           (CD_PRDUT_PLATF = v_5121 AND CD_PERFL_PRDUT IN (v_99, v_16, v_17, v_18, v_19, v_20, v_21, v_22, v_23, v_24, v_25, v_26, v_27, v_28, v_29, v_30)))
                    AND    ((NVL(v_assessoria, v_N) <> v_S AND IC_CRTOR_ASRDO = v_N) OR (IC_CRTOR_ASRDO = v_S))
                    AND    IC_CRTOR_ATIVO = v_S
                    AND    CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
                    AND    CALC.DT_HORA_CALLO_COTAC >= v_datacalculo_inicio
                    AND    CALC.DT_HORA_CALLO_COTAC < v_datacalculo_fim)
            /********************* Fim do Trecho de Pesquisa do KME  *******************/
            /********************* Inicio do Trecho de Pesquisa do Residencial F·cil  *******************/
            UNION ALL
            SELECT N.Cd_ngoco AS CALCULO
                  ,It.Nr_itseg AS ITEM
                  ,C.NM_CLIEN AS NOME
                  --,p_cpf_cnpj
                  ,CASE
                           WHEN LENGTH(NVL(PessoaFisica.NR_CPF,0)) > 0 THEN -- CPF
                                TRIM(DECODE(PessoaFisica.NR_CPF, NULL,NULL,TRANSLATE(TO_CHAR(PessoaFisica.NR_CPF/100,'000,000,000.00'),',.','.-')))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL AS NOMEESTIPULANTE
                  ,N.DT_EMISS_NGOCO AS DATACALCULO
                  ,NULL URL
                  ,'Transmitido' AS SITUACAO
                  ,'T' AS COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,N.CD_USURO_CADMT_PPOTA AS COD_USUARIO
                  ,'Residencial F·cil' AS PRODUTO
                  ,0 AS PADRAO
                  ,n.DT_EMISS_NGOCO AS DATAEMISSAO
                  ,n.DT_EMISS_NGOCO AS DATATRANSMISSAO
                  ,NULL AS VALIDADO
                  ,NULL AS DIAS
                  ,NULL AS PROTOCOLOTRANS
                  ,NULL AS COD_ESTIPULANTE
                  ,1 AS COD_PRODUTO
                  ,Mn.DT_INICO_VIGEN AS INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'SSV' AS SISTEMA
                  ,N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS
                  ,0 AS CORR_TMB
                  ,NULL AS CORR_ASER
                  ,NULL AS TIPO_OFERTA
                  ,0 AS VALOR_DE
                  ,0 AS VALOR_PARA
            FROM   Ssv0084_ngoco       N
                  ,Ssv0081_mdulo_ngoco Mn
                  ,Ssv0076_itseg       It
                  ,SSV4002_CLIEN       C
                  ,SSV4006_CLIEN_PESSF PessoaFisica
            WHERE  It.Tp_histo_itseg = v_0_char
            AND    ((It.Cd_agatv = v_B1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_B1
                                                           AND    a.CD_MDUPR = v_14)) OR
                  (It.Cd_agatv = v_D1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_D1
                                                           AND    a.CD_MDUPR = v_14)))
            AND    it.CD_MDUPR = v_14
            AND    N.Cd_ngoco = It.Cd_ngoco
            AND    N.Tp_histo = v_0_char
            AND    Mn.Cd_ngoco = it.CD_NGOCO
            AND    Mn.Tp_histo = v_0_char
            AND    Mn.Cd_mdupr = v_14
            AND    C.CD_CLIEN = N.CD_CLIEN
            AND    n.CD_CRTOR_SEGUR_PRCPA = v_CorretorTMS
            AND    c.cd_clien = PessoaFisica.cd_clien
            AND       N.DT_EMISS_NGOCO IS NOT NULL
            AND    N.DT_EMISS_NGOCO >= v_datacalculo_inicio
            AND    N.DT_EMISS_NGOCO < v_datacalculo_fim
            --
            UNION ALL
            --
            SELECT N.Cd_ngoco AS CALCULO
                  ,It.Nr_itseg AS ITEM
                  ,C.NM_CLIEN AS NOME
                  --,p_cpf_cnpj
                  ,CASE
                           WHEN LENGTH(NVL(PessoaJuridica.NR_CNPJ,0)) > 0 THEN -- CNPJ
                                DECODE(PessoaJuridica.NR_CNPJ,NULL,NULL,REPLACE(REPLACE(REPLACE(TO_CHAR(LPAD(REPLACE(PessoaJuridica.NR_CNPJ,''),14 ,'0'),'00,000,000,0000,00'),',','.'),' ') ,'.'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(PessoaJuridica.NR_CNPJ,14,'0'),1000000)/100),'0000'))||'.' ,'/'||TRIM(TO_CHAR(TRUNC(MOD(LPAD(PessoaJuridica.NR_CNPJ,14,'0'),1000000)/100) ,'0000'))||'-'))
                           ELSE
                                NULL
                   END CGC_CPF
                  ,NULL AS NOMEESTIPULANTE
                  ,N.DT_EMISS_NGOCO AS DATACALCULO
                  ,NULL URL
                  ,'Transmitido' AS SITUACAO
                  ,'T' AS COD_SITUACAO
                  ,0 AS CALCULOORIGEM
                  ,N.CD_USURO_CADMT_PPOTA AS COD_USUARIO
                  ,'Residencial F·cil' AS PRODUTO
                  ,0 AS PADRAO
                  ,n.DT_EMISS_NGOCO AS DATAEMISSAO
                  ,n.DT_EMISS_NGOCO AS DATATRANSMISSAO
                  ,NULL AS VALIDADO
                  ,NULL AS DIAS
                  ,NULL AS PROTOCOLOTRANS
                  ,NULL AS COD_ESTIPULANTE
                  ,1 AS COD_PRODUTO
                  ,Mn.DT_INICO_VIGEN AS INICIOVIGENCIA
                  ,0 AS NUMEROTITULO
                  ,'SSV' AS SISTEMA
                  ,N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS
                  ,0 AS CORR_TMB
                  ,NULL AS CORR_ASER
                  ,NULL AS TIPO_OFERTA
                  ,0 AS VALOR_DE
                  ,0 AS VALOR_PARA
            FROM   Ssv0084_ngoco       N
                  ,Ssv0081_mdulo_ngoco Mn
                  ,Ssv0076_itseg       It
                  ,SSV4002_CLIEN       C
                  ,SSV4007_CLIEN_PESSJ PessoaJuridica
            WHERE  It.Tp_histo_itseg = v_0_char
            AND    ((It.Cd_agatv = v_B1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_B1
                                                           AND    a.CD_MDUPR = v_14)) OR
                  (It.Cd_agatv = v_D1 AND it.SQ_AGATV = (SELECT a.SQ_AGATV
                                                           FROM   SSV2005_AGATV a
                                                           WHERE  a.CD_AGATV = v_D1
                                                           AND    a.CD_MDUPR = v_14)))
            AND    it.CD_MDUPR = v_14
            AND    N.Cd_ngoco = It.Cd_ngoco
            AND    N.Tp_histo = v_0_char
            AND    Mn.Cd_ngoco = it.CD_NGOCO
            AND    Mn.Tp_histo = v_0_char
            AND    Mn.Cd_mdupr = v_14
            AND    C.CD_CLIEN = N.CD_CLIEN
            AND    n.CD_CRTOR_SEGUR_PRCPA = v_CorretorTMS
            AND    c.cd_clien = PessoaJuridica.cd_clien
            AND       N.DT_EMISS_NGOCO IS NOT NULL
            AND    N.DT_EMISS_NGOCO >= v_datacalculo_inicio
            AND    N.DT_EMISS_NGOCO < v_datacalculo_fim;

    BEGIN
            --
            FOR rec IN c_busca_datacalculo
            LOOP
                IF P_PADRAOUSUARIO = 'R' THEN
                    BEGIN
                        SELECT COUNT(1)
                          INTO v_count_estip
                          FROM TABLE (KITFC002_ESTIP_TABLE (v_Estipulantes))
                         WHERE cd_estip = rec.COD_ESTIPULANTE;

                    EXCEPTION
                        WHEN OTHERS THEN
                            v_count_estip := 0;

                    END;
                END IF;

                IF P_PADRAOUSUARIO <> 'R' OR
                   v_count_estip <> 0 THEN

                    l_tab.EXTEND;
                    l_tab(l_tab.LAST) := KITTY003_BUSCA_ROW( rec.CALCULO
                                                            ,rec.ITEM
                                                            ,rec.NOME
                                                            ,rec.CGC_CPF
                                                            ,rec.NOMEESTIPULANTE
                                                            ,rec.DATACALCULO
                                                            ,rec.URL_RESID_FACIL
                                                            ,rec.SITUACAO
                                                            ,rec.COD_SITUACAO
                                                            ,rec.CALCULOORIGEM
                                                            ,rec.COD_USUARIO
                                                            ,rec.PRODUTO
                                                            ,rec.PADRAO
                                                            ,rec.DATAEMISSAO
                                                            ,rec.DATATRANSMISSAO
                                                            ,rec.VALIDADO
                                                            ,rec.DIAS
                                                            ,rec.PROTOCOLOTRANS
                                                            ,rec.COD_ESTIPULANTE
                                                            ,rec.COD_PRODUTO
                                                            ,rec.INICIOVIGENCIA
                                                            ,rec.NUMEROTITULO
                                                            ,rec.SISTEMA
                                                            ,rec.CORR_TMS
                                                            ,rec.CORR_TMB
                                                            ,rec.CORR_ASER
                                                            ,rec.TIPO_OFERTA
                                                            ,rec.VALOR_DE
                                                            ,rec.VALOR_PARA );

                END IF;

            END LOOP;
            --
            OPEN v_RESULTADO FOR SELECT * FROM TABLE (l_tab);

    END Busca_Por_DataCalculo;

begin
   declare
      v_SqlConsulta LONG(15000);
      v_lf varchar(2);
      v_CorretorTMS number;
      v_nm_arq varchar2(500);
      arquivo         utl_file.file_type;

   begin
        --
        BEGIN
            SELECT valor
              INTO v_url_link_resid_facil
              FROM admkit.tabela_configuracoes_kcw
             WHERE parametro = 'URL_LINK_RESID_FACIL';

        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro ao Selecionar na Tabela ADMKIT.TABELA_CONFIGURACOES_KCW o Par‚metro "URL_LINK_RESID_FACIL" - Mensagem: ' || SQLERRM);

        END;
        --
    v_lf := CHR (13) || CHR (10);
   --dbms_output.enable( 1000000 );

/****************** Inicio do Trecho de Pesquisa do KCW  **********************/
    select
      Divisao_Superior into v_CorretorTMS
    from
      Tabela_Divisoes
    where
      Divisao = p_corretor and Tipo_Divisao = 'E';

    --dbms_output.put_line('Padrao Corretor '||p_padraousuario || ' Corretor '||p_corretor);
    --Se for um Corretor do Padrøo 'R' sø pode exibir cølculo dos estipulantes dele
    if p_padraousuario = 'R' then
        begin
          SELECT NVL(ESTIPULANTE1,0), NVL(ESTIPULANTE2,0), NVL(ESTIPULANTE3,0), NVL(ESTIPULANTE4,0),
                 NVL(ESTIPULANTE5,0), NVL(ESTIPULANTE6,0), NVL(ESTIPULANTE7,0), NVL(ESTIPULANTE8,0),
                 NVL(ESTIPULANTE9,0), NVL(ESTIPULANTE0,0)
            INTO v_Estipulante1, v_Estipulante2, v_Estipulante3, v_Estipulante4,
                 v_Estipulante5, v_Estipulante6, v_Estipulante7, v_Estipulante8,
                 v_Estipulante9, v_Estipulante0
            FROM REAL_USUARIOS
           WHERE CORRETOR = P_CORRETOR
             AND COD_USUARIO = P_USUARIO_LOGADO
             AND INICIOVIGENCIA <= SYSDATE
             AND PADRAOUSUARIO = 'R'
           ORDER BY INICIOVIGENCIA DESC;
        Exception
          when OTHERS then
          begin
            v_Estipulante1 := 0;
            v_Estipulante2 := 0;
            v_Estipulante3 := 0;
            v_Estipulante4 := 0;
            v_Estipulante5 := 0;
            v_Estipulante6 := 0;
            v_Estipulante7 := 0;
            v_Estipulante8 := 0;
            v_Estipulante9 := 0;
            v_Estipulante0 := 0;
          end;
        end;
    end if;

    /* Montando Lista de Estipulantes */
    v_Estipulantes := ' ';
    if v_Estipulante1 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante1;
    end if;
    if v_Estipulante2 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante2;
    end if;
    if v_Estipulante3 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante3;
    end if;
    if v_Estipulante4 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante4;
    end if;
    if v_Estipulante5 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante5;
    end if;
    if v_Estipulante6 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante6;
    end if;
    if v_Estipulante7 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante7;
    end if;
    if v_Estipulante8 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante8;
    end if;
    if v_Estipulante9 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante9;
    end if;
    if v_Estipulante0 > 0 then
      v_Estipulantes := v_Estipulantes ||','|| v_Estipulante0;
    end if;

    if v_Estipulantes <> ' ' then
      v_Estipulantes := SubStr(Trim(v_Estipulantes),2);
    end if;
    --
        --      Se Consulta R·pida por CPF/CNPJ, usar query prÈ-montada, em vez de ser query din‚mica
        --
        IF      p_tipo_consulta = 1
        AND     p_cpf_cnpj      <>      '0' THEN
                --
                Busca_por_CPF   (p_cpf_cnpj
                                ,p_corretor
                                ,v_CorretorTMS
                                ,p_acessoria
                                ,p_resultado    );
                --
        ELSIF     p_tipo_consulta = 1
        AND     p_calculo        <>         '0' THEN
                --
                Busca_por_Calculo    (p_calculo
                                    ,p_corretor
                                    ,v_CorretorTMS
                                    ,p_acessoria
                                    ,p_resultado    );
                --
        ELSIF     p_tipo_consulta = 3            THEN
                --
                Busca_por_DataCalculo    (p_periodo
                                        ,p_corretor
                                        ,v_CorretorTMS
                                        ,p_acessoria
                                        ,p_resultado    );
                --
        ELSE
        --
        --      Busca GenÈrica
        --

    v_SqlConsulta := 'SELECT * FROM ( '||
     ' SELECT CALC.CALCULO,
              CALC.ITEM,
              CALC.NOME,
              CLIE.CGC_CPF,
              ESTI.NOME NOMEESTIPULANTE,
              CALC.DATACALCULO,
              RESDL.URL URL_RESID_FACIL,
              CASE
                WHEN CALC.SITUACAO = ''E'' AND CALC.TIPODOCUMENTO <> ''N'' THEN ''Efetivado''
                WHEN CALC.SITUACAO = ''E'' AND CALC.TIPODOCUMENTO =  ''N'' THEN ''Finalizado sem transmissøo''
                WHEN CALC.SITUACAO = ''T''                                 THEN ''Transmitido''
                WHEN CALC.SITUACAO = ''C''                                 THEN ''Calculado''
                ELSE ''Pendente''
              END SITUACAO,
              CALC.SITUACAO COD_SITUACAO,
              CALC.CALCULOORIGEM,
              CALC.COD_USUARIO,
              PROD.DESCRICAO as PRODUTO,
              CALC.PADRAO,
              CALC.DATAEMISSAO,
              CALC.DATATRANSMISSAO,
              CALC.VALIDADO,
              calc.datavalidade - trunc(SYSDATE) DIAS,';
              /*
              CASE
              WHEN calc.situacao = ''E'' THEN
                TO_CHAR(TRUNC(PKG_KCWUTILS.GETVALIDADE(CALC.CALCULO, TO_DATE('''||TO_CHAR(P_DATASERVER,'DD/MM/YYYY')||''',''DD/MM/YYYY''), ''E'') - TO_DATE('''||TO_CHAR(P_DATASERVER,'DD/MM/YYYY')||''',''DD/MM/YYYY'')))
              WHEN calc.situacao = ''T'' THEN
                NULL
              ELSE
                TO_CHAR(TRUNC(PKG_KCWUTILS.GETVALIDADE(CALC.CALCULO, TO_DATE('''||TO_CHAR(P_DATASERVER,'DD/MM/YYYY')||''',''DD/MM/YYYY''), ''C'') - TO_DATE('''||TO_CHAR(P_DATASERVER,'DD/MM/YYYY')||''',''DD/MM/YYYY'')))
              END AS DIAS,
              */
        v_SqlConsulta := v_SqlConsulta || '
              CALC.PROTOCOLOTRANS,
              RELAC_ESTI.DIVISAO COD_ESTIPULANTE,
              CALC.PADRAO COD_PRODUTO,
              CALC.INICIOVIGENCIA,
              TO_NUMBER(NVL(CALC.NUMEROTITULO,''0'')) NUMEROTITULO,
              ''KCW'' SISTEMA,
              0 CORR_TMS,
              0 CORR_TMB,
              '' '' CORR_ASER,
              RT.TIPO_OFERTA,
              RT.VALOR_PREMIO_ORIGINAL VALOR_DE,
              RT.VALOR_PREMIO_REALTIME VALOR_PARA
       FROM MULT_CALCULO CALC
       /*LEFT OUTER JOIN SSV0011_OFERT_RESDL RESDL ON (CALC.CALCULOORIGEM = RESDL.CD_NGOCO_AUTO AND RESDL.IC_OFERT = ''S'')*/
      /* LEFT OUTER JOIN VW_RESDL RESDL ON (CALC.CALCULOORIGEM = RESDL.CD_NGOCO)*/

left outer join
(
select N.CD_NGOCO, N.CD_CRTOR_SEGUR_PRCPA, REPLACE(REPLACE(PARAM.VL_PARAM_SSV, ''#CODIGO_NEGOCIO#'', N.CD_NGOCO), ''#USUARIO#'', C.CD_CONVO) as URL
FROM SSV0084_NGOCO n, SSV0081_MDULO_NGOCO mn, SSV9099_PARAM_SSV PARAM, SSV5046_CONVO c, SSV0076_ITSEG i, SSV4015_FORMA_COBRC FC
WHERE
        N.CD_NGOCO = MN.CD_NGOCO
        AND I.CD_NGOCO = N.CD_NGOCO
        AND I.TP_HISTO_ITSEG = ''0''
        AND N.TP_HISTO = ''0''
        AND MN.TP_HISTO = ''0''
        AND N.ID_FORMA_COBRC = FC.ID_FORMA_COBRC
        AND FC.TP_COBRC = ''D''
        AND FC.CD_CLIEN = N.CD_CLIEN
        AND MN.CD_MDUPR IN (7,20,21)
        AND (N.CD_SITUC_NGOCO IN (''REN'', ''GRD'', ''LIB'', ''APO'') OR (N.TP_RENOV_NGOCO = ''R'' AND N.CD_SITUC_NGOCO = ''PRO''))
        AND N.DT_CANCL_NGOCO IS NULL
        AND MN.DT_FIM_VIGEN >= TRUNC(SYSDATE)
        AND PARAM.CD_GRP_PARAM_SSV = 52
        AND PARAM.CD_PARAM_SSV = ''URL.BASE.EMISSAO.RESIDENCIAL.FACIL''
        AND C.CD_ITRNO_CONVO = N.CD_CRTOR_SEGUR_PRCPA
        AND C.TP_CONVO = ''C''
        -- CORRETORES N√O OFERTA
        AND N.CD_CRTOR_SEGUR_PRCPA NOT IN
        (SELECT TO_NUMBER(regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = 52 AND PARAM.CD_PARAM_SSV = ''CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL''),''[^,]+'', 1, level)) from dual connect by regexp_substr((SELECT PARAM.VL_PARAM_SSV FROM SSV9099_PARAM_SSV param WHERE PARAM.CD_GRP_PARAM_SSV = 52 AND PARAM.CD_PARAM_SSV = ''CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL''), ''[^,]+'', 1, level) is not null)
        -- CLIENTE N√O POSSUI SEGURO RESIDENCIAL ATIVO
        AND NOT EXISTS (
                SELECT 1
                FROM SSV0081_MDULO_NGOCO MN1, SSV0084_NGOCO N1
                WHERE
                N1.CD_NGOCO = MN1.CD_NGOCO
                AND N1.TP_HISTO = ''0''
                AND MN1.TP_HISTO = ''0''
                AND MN1.CD_MDUPR = 14
                AND N1.DT_CANCL_NGOCO IS NULL
                AND N1.CD_CLIEN = N.CD_CLIEN
                AND N1.CD_SITUC_NGOCO IN (''REN'', ''LIB'', ''LIP'', ''GRD'', ''APO'')
                AND SYSDATE BETWEEN MN1.DT_INICO_VIGEN AND MN1.DT_FIM_VIGEN
        )
        -- QBR APARTAMENTO OU CASA
        AND EXISTS (
            SELECT 1
            FROM SSV0104_QUEST_RESIT QBR
            WHERE
                QBR.NR_ITSEG = I.NR_ITSEG
                AND QBR.CD_QBR IN (258, 289)
                AND QBR.CD_RESPT_QBR IN (699, 813, 700, 814, 701, 815)
        )
) RESDL
ON (CALC.CALCULOORIGEM = RESDL.CD_NGOCO)
       INNER JOIN MULT_PADRAO PROD ON PROD.PADRAO = CALC.PADRAO
       LEFT OUTER JOIN TABELA_CLIENTES CLIE ON CLIE.CLIENTE = CALC.CLIENTE
       LEFT OUTER JOIN MULT_CALCULODIVISOES RELAC_ESTI ON RELAC_ESTI.CALCULO = CALC.CALCULO AND RELAC_ESTI.NIVEL = 4
       LEFT OUTER JOIN TABELA_DIVISOES ESTI ON ESTI.DIVISAO = RELAC_ESTI.DIVISAO
       LEFT OUTER JOIN MULT_CALCULODIVISOES RELAC_CORR ON RELAC_CORR.CALCULO = CALC.CALCULO AND RELAC_CORR.NIVEL = 1
       LEFT OUTER JOIN TABELA_CALCULOS_REALTIME RT ON RT.CALCULO = CALC.CALCULO AND RT.ITEM = CALC.ITEM
     WHERE (NVL(CALC.DATAVERSAO,SYSDATE) >= (SYSDATE - 365))
         AND (  CALC.CEP IS NOT NULL or calc.padrao in (12,13) )
         AND RELAC_CORR.DIVISAO = '||p_corretor || v_lf;

/********************* Fim do Trecho de Pesquisa do KCW  **********************/

/********************* Inicio do Trecho de Pesquisa do KME  *******************/
    v_SqlConsulta := v_SqlConsulta || v_lf || 'UNION ALL';

    v_SqlConsulta := v_SqlConsulta || '
    SELECT CALC.NR_CALLO CALCULO,
           0 ITEM,
           CALC.NM_SGRDO NOME,
           TO_CHAR(CALC.NR_CPF_CNPJ_SGRDO) CGC_CPF,
           NULL NOMEESTIPULANTE,
           CALC.DT_HORA_CALLO_COTAC DATACALCULO,
           NULL URL,
           CASE
             WHEN CALC.CD_SITUC_NGOCO = ''E'' THEN ''Efetivado''
             WHEN CALC.CD_SITUC_NGOCO = ''T'' THEN ''Transmitido''
             WHEN CALC.CD_SITUC_NGOCO = ''C'' THEN ''Calculado''
             ELSE ''Pendente''
           END SITUACAO,
           CALC.CD_SITUC_NGOCO COD_SITUACAO,
           0 AS CALCULOORIGEM,
           CALC.CD_USURO_ULTMA_ATULZ COD_USUARIO,
                      CASE
                               WHEN CALC.CD_PRDUT_PLATF = 1806 THEN
                                ''Empresarial MÈdias Empresas''
                               WHEN CALC.CD_PRDUT_PLATF = 3001 THEN
                                ''AgronegÛcio''
                               WHEN CALC.CD_PRDUT_PLATF = 6709 THEN
                                ''Riscos de Engenharia''
                               WHEN CALC.CD_PRDUT_PLATF = 7187 THEN
                                ''RD Equipamentos''
                               WHEN CALC.CD_PRDUT_PLATF = 5121 THEN
                                ''RC Obras''
                               ELSE
                               '' ''
                       END PRODUTO,
           0 AS PADRAO,
           CALC.DT_HORA_ATULZ_STATU DATAEMISSAO,
           CALC.DT_HORA_ATULZ_STATU DATATRANSMISSAO,
           CALC.IC_VALDC_ONLIN  VALIDADO,
           NULL AS DIAS,
           TO_CHAR(CALC.NR_PROTC_TRNSM) PROTOCOLOTRANS,
           NULL COD_ESTIPULANTE,
           CALC.CD_PRDUT_PLATF COD_PRODUTO,
           CALC.DT_INICO_VIGEN_SEGUR INICIOVIGENCIA,
           0 AS NUMEROTITULO,
           ''KME'' SISTEMA,
           NVL( CALC.CD_CRTOR_PLATF, 0 ) CORR_TMS,
           NVL( ACESS.CD_CRTOR_TMB, 0 ) CORR_TMB,
           ''' || NVL(P_ACESSORIA, 'N') || ''' CORR_ASER, ' ||
           ' '' '' TIPO_OFERTA,
           0 VALOR_DE,
           0 VALOR_PARA
     FROM ADMKME.KME0091_SUMAR_COTAC CALC
     INNER JOIN ADMKME.KME0092_ACSSO_KIT_KME_WEB ACESS ON  ACESS.CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF
     WHERE (CALC.DT_HORA_CALLO_COTAC >= (SYSDATE - 365))
     AND CALC.CD_CRTOR_PLATF = '||v_CorretorTMS || v_lf;

     v_SqlConsulta := v_SqlConsulta ||
     'AND EXISTS (SELECT 1 FROM  ADMKME.KME0092_ACSSO_KIT_KME_WEB
WHERE ((CD_PRDUT_PLATF  = 1806 AND CD_PERFL_PRDUT in (99,1,3,5,7,9,11,13,15,17,19,21,23,25,27,29)   ) OR
                 (CD_PRDUT_PLATF  = 7187 AND CD_PERFL_PRDUT in (99,2,3,6,7,10,11,14,15,18,19,22,23,26,27,30)  ) OR
                 (CD_PRDUT_PLATF  = 3001 AND CD_PERFL_PRDUT in (99,4,5,6,7,12,13,14,15,20,21,22,23,28,29,30)  ) OR
                 (CD_PRDUT_PLATF  = 6709 AND CD_PERFL_PRDUT in (99,8,9,10,11,12,13,14,15,24,25,26,27,28,29,30)) OR
                 (CD_PRDUT_PLATF  = 5121 AND CD_PERFL_PRDUT in (99,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)))
                    AND (('''||NVL(P_ACESSORIA,'N')||''' <> ''S'' AND
                        IC_CRTOR_ASRDO = ''N'') OR
                       (IC_CRTOR_ASRDO = ''S'')) AND
                        IC_CRTOR_ATIVO = ''S'' AND
                        CD_CRTOR_TMS = CALC.CD_CRTOR_PLATF)';

/********************* Fim do Trecho de Pesquisa do KME  *******************/

/********************* Inicio do Trecho de Pesquisa do Residencial F·cil  *******************/

    v_SqlConsulta := v_SqlConsulta || v_lf || 'UNION ALL';

    v_SqlConsulta := v_SqlConsulta || '
        SELECT N.Cd_ngoco             AS CALCULO,
               It.Nr_itseg            AS ITEM,
               C.NM_CLIEN             AS NOME,
               CASE
                WHEN C.TP_PESOA = ''F'' THEN (select trim(Decode(NR_CPF, NULL,NULL,Translate(To_Char(NR_CPF/100,''000,000,000.00''),'',.'',''.-''))) from SSV4006_CLIEN_PESSF Cf where Cf.CD_CLIEN = n.CD_CLIEN )
                WHEN C.TP_PESOA = ''J'' THEN (select Decode(NR_CNPJ,NULL,NULL,REPLACE(REPLACE(REPLACE(To_Char(LPad(REPLACE(NR_CNPJ,''''),14 ,''0''),''00,000,000,0000,00''),'','',''.''),'' '') ,''.''||Trim(To_Char(Trunc(Mod(LPad(NR_CNPJ,14,''0''),1000000)/100),''0000''))||''.'' ,''/''||Trim(To_Char(Trunc(Mod(LPad(NR_CNPJ,14,''0''),1000000)/100) ,''0000''))||''-'')) from SSV4007_CLIEN_PESSJ Cj where Cj.CD_CLIEN = n.CD_CLIEN )
               END                    AS CGC_CPF,
               NULL                   AS NOMEESTIPULANTE,
               N.DT_EMISS_NGOCO        AS DATACALCULO,
               NULL                   AS URL,
               ''Transmitido''          AS SITUACAO,
               ''T''                      AS COD_SITUACAO,
               0                      AS CALCULOORIGEM,
               N.CD_USURO_CADMT_PPOTA AS COD_USUARIO,
               ''Residencial F·cil''    AS PRODUTO,
               0                      AS PADRAO,
               n.DT_EMISS_NGOCO       AS DATAEMISSAO,
               n.DT_EMISS_NGOCO       AS DATATRANSMISSAO,
               NULL                   AS VALIDADO,
               NULL                   AS DIAS,
               NULL                   AS PROTOCOLOTRANS,
               NULL                   AS COD_ESTIPULANTE,
               1                      AS COD_PRODUTO,
               Mn.DT_INICO_VIGEN      AS INICIOVIGENCIA,
               0                      AS NUMEROTITULO,
               ''SSV''                  AS SISTEMA,
               N.CD_CRTOR_SEGUR_PRCPA AS CORR_TMS,
               0                      AS CORR_TMB,
               NULL                   AS CORR_ASER,
               NULL                   AS TIPO_OFERTA,
               0                      AS VALOR_DE,
               0                      AS VALOR_PARA
          FROM Ssv0084_ngoco N,
               Ssv0081_mdulo_ngoco Mn,
               Ssv0076_itseg It,
               SSV4002_CLIEN C
        WHERE It.Tp_histo_itseg = ''0''
           AND ((It.Cd_agatv = ''B1'' and it.SQ_AGATV = (select a.SQ_AGATV from SSV2005_AGATV a where a.CD_AGATV = ''B1'' and a.CD_MDUPR = 14 ))
                or (It.Cd_agatv = ''D1'' and it.SQ_AGATV = (select a.SQ_AGATV from SSV2005_AGATV a where a.CD_AGATV = ''D1'' and a.CD_MDUPR = 14 )))
           AND it.CD_MDUPR = 14
           AND N.Cd_ngoco = It.Cd_ngoco
           AND N.DT_EMISS_NGOCO >= (SYSDATE - 365)
           AND N.Tp_histo = ''0''
           AND Mn.Cd_ngoco = it.CD_NGOCO
           AND Mn.Tp_histo = ''0''
           AND Mn.Cd_mdupr = 14
           AND C.CD_CLIEN = N.CD_CLIEN
           AND n.CD_CRTOR_SEGUR_PRCPA = ' || v_CorretorTMS ;


/********************* Fim do Trecho de Pesquisa do Residencial F·cil  *******************/

    v_SqlConsulta := v_SqlConsulta || ') ';

    if p_relatorio = 0 then
      v_SqlConsulta := v_SqlConsulta || ' WHERE ROWNUM <= 1000 ';
    else
      v_SqlConsulta := v_SqlConsulta || ' WHERE 1 = 1 ';  -- Apenas para que a clausa where seja adicionada
    end if;

    case
        when p_tipo_consulta = 1 then /*  Consulta Røpida  */
          /* Filtrando o CPF/CNPJ escolhido */
          if p_cpf_cnpj <> '0' then
            v_SqlConsulta := v_SqlConsulta || 'AND  (CGC_CPF = ''' ||p_cpf_cnpj|| ''''
        || ' OR CGC_CPF = ''' || TO_CHAR(TO_NUMBER(REPLACE(REPLACE(REPLACE(p_cpf_cnpj,'.'),'-'),'/'))) ||''')'|| v_lf;
          end if;

          /* Filtrando o TITULO escolhido */
          if p_numero_titulo <> ' ' or p_numero_titulo <> '0' then
            v_SqlConsulta := v_SqlConsulta || 'AND  NUMEROTITULO = ' ||p_numero_titulo|| v_lf;
          end if;

          /* Filtrando o TITULO escolhido */
          if p_calculo <> 0 then
            v_SqlConsulta := v_SqlConsulta || 'AND  CALCULO = ' ||p_calculo|| v_lf;
          end if;

          if v_Estipulantes <> ' ' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_ESTIPULANTE IN ('||v_Estipulantes||')'|| v_lf;
          end if;

        when p_tipo_consulta = 2 then  /* Consulta Avanøada por Perøodo */

          /* Filtrando o PRODUTO escolhido */
          if p_produto <> '0' and p_produto <> 'Auto' and p_produto <> '99' then
             v_SqlConsulta := v_SqlConsulta || ' AND COD_PRODUTO = '||p_produto;
          elsif p_produto = 'Auto' then
             --v_SqlConsulta := v_SqlConsulta || ' AND COD_PRODUTO in (10, 11, 42) '|| v_lf;
             v_SqlConsulta := v_SqlConsulta || ' AND COD_PRODUTO in (10, 11, 14, 15, 42) '|| v_lf;
          end if;

          /* Filtrando o USUARIO escolhido */
          if p_usuario <> 'TODOS' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_USUARIO = '''||p_usuario||'''';
          end if;

          /* Filtrando o NOME escolhido */
          if p_nome <> ' ' then
            v_SqlConsulta := v_SqlConsulta || ' AND UPPER(NOME) LIKE '''||UPPER(p_nome) || '%'''|| v_lf;
          end if;

          /* Filtrando o SITUACAO escolhido */
          if p_situacao = '2' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_SITUACAO = ''C'''|| v_lf;
          elsif p_situacao = '3' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_SITUACAO IN (''E'',''A'')'|| v_lf;
          elsif p_situacao = '4' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_SITUACAO = ''T'''|| v_lf;
          elsif p_situacao = '5' then
            v_SqlConsulta := v_SqlConsulta || ' AND (COD_SITUACAO = ''P'' AND CALCULOORIGEM > 0)'|| v_lf;
          end if;

          /* Filtrando o ESTIPULANTE  escolhido */
          if p_estipulante <> 0 then
             v_SqlConsulta := v_SqlConsulta || ' AND COD_ESTIPULANTE = '||p_estipulante|| v_lf;
          elsif v_Estipulantes <> ' ' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_ESTIPULANTE IN ('||v_Estipulantes||')'|| v_lf;
          end if;


          /* Filtrando o PERøODO escolhido*/
          if (((p_periodo  = 99) and (p_periodo_inicio is not null)) or (p_periodo <> 99))  then
            if p_tipo_periodo = 1 then
              if p_periodo = 99 then
                v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
                  TO_DATE('''||TO_CHAR(p_periodo_inicio,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
                  TO_DATE('''||TO_CHAR(p_periodo_fim   ,'DD/MM/YYYY') || ' 23:59:59'', ''DD/MM/YYYY HH24:MI:SS'') '|| v_lf;
              elsif p_periodo = 1 then
                v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
                  TO_DATE('''||TO_CHAR(p_periodo_inicio - 1,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
                  TO_DATE('''||TO_CHAR(p_periodo_fim - 1,'DD/MM/YYYY') || ' 23:59:59'', ''DD/MM/YYYY HH24:MI:SS'') '|| v_lf;
              else
                v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
                  TO_DATE('''||TO_CHAR(p_periodo_inicio - p_periodo,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
                  TO_DATE('''||TO_CHAR(p_periodo_fim ,'DD/MM/YYYY HH24:MI:SS') ||  ''', ''DD/MM/YYYY HH24:MI:SS'')'|| v_lf;
              end if;
            else
              if p_periodo = 99 then
                v_SqlConsulta := v_SqlConsulta || '  AND INICIOVIGENCIA BETWEEN
                  TO_DATE('''||TO_CHAR(p_periodo_inicio,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
                  TO_DATE('''||TO_CHAR(p_periodo_fim   ,'DD/MM/YYYY') || ' 23:59:59'', ''DD/MM/YYYY HH24:MI:SS'') '|| v_lf;
              elsif p_periodo = 1 then
                v_SqlConsulta := v_SqlConsulta || '  AND INICIOVIGENCIA BETWEEN
                  TO_DATE('''||TO_CHAR(p_periodo_inicio - 1,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
                  TO_DATE('''||TO_CHAR(p_periodo_fim - 1,'DD/MM/YYYY') || ' 23:59:59'', ''DD/MM/YYYY HH24:MI:SS'') '|| v_lf;
              else
                v_SqlConsulta := v_SqlConsulta || '  AND INICIOVIGENCIA BETWEEN
                  TO_DATE('''||TO_CHAR(p_periodo_inicio - p_periodo,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
                  TO_DATE('''||TO_CHAR(p_periodo_fim ,'DD/MM/YYYY HH24:MI:SS') ||  ''', ''DD/MM/YYYY HH24:MI:SS'')'|| v_lf;
              end if;
            end if;
          end if;
        when p_tipo_consulta = 4 then  /* Consulta Tipo Oferta */
          CASE
          WHEN P_TIPO_DESCONTO = 1 then
            V_SQLCONSULTA := V_SQLCONSULTA || ' and tipo_oferta in(''SD'',''DA'') ' || V_LF;
          WHEN P_TIPO_DESCONTO = 2 then
            V_SQLCONSULTA := V_SQLCONSULTA || ' and tipo_oferta in(''SC'',''CA'') '|| V_LF;
          end case;
          V_SQLCONSULTA := V_SQLCONSULTA || ' AND TO_NUMBER(NVL(DIAS,''0'')) >= 0 '|| V_LF;
          V_SQLCONSULTA := V_SQLCONSULTA || ' AND NVL(DATACALCULO,SYSDATE) >= (SYSDATE - 30)'|| V_LF;
          V_SQLCONSULTA := V_SQLCONSULTA || ' AND COD_SITUACAO<>''T''   '|| V_LF;

          if v_Estipulantes <> ' ' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_ESTIPULANTE IN ('||v_Estipulantes||')'|| v_lf;
          end if;
        else
          if v_Estipulantes <> ' ' then
            v_SqlConsulta := v_SqlConsulta || ' AND COD_ESTIPULANTE IN ('||v_Estipulantes||')'|| v_lf;
          end if;

          if p_periodo = 0 then
            v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
              TO_DATE('''||TO_CHAR(p_periodo_inicio,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
              TO_DATE('''||TO_CHAR(p_periodo_fim ,'DD/MM/YYYY HH24:MI:SS') ||  ''', ''DD/MM/YYYY HH24:MI:SS'')'|| v_lf;
          elsif p_periodo = 1 then
            v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
              TO_DATE('''||TO_CHAR(p_periodo_inicio - 1,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
              TO_DATE('''||TO_CHAR(p_periodo_fim ,'DD/MM/YYYY HH24:MI:SS') ||  ''', ''DD/MM/YYYY HH24:MI:SS'')'|| v_lf;
          elsif p_periodo = 3 then
            v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
              TO_DATE('''||TO_CHAR(p_periodo_inicio - 3,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
              TO_DATE('''||TO_CHAR(p_periodo_fim ,'DD/MM/YYYY HH24:MI:SS') ||  ''', ''DD/MM/YYYY HH24:MI:SS'')'|| v_lf;
          elsif p_periodo = 7 then
            v_SqlConsulta := v_SqlConsulta || '  AND DATACALCULO BETWEEN
              TO_DATE('''||TO_CHAR(p_periodo_inicio - 7,'DD/MM/YYYY') || ' 00:00:00'', ''DD/MM/YYYY HH24:MI:SS'') AND
              TO_DATE('''||TO_CHAR(p_periodo_fim ,'DD/MM/YYYY HH24:MI:SS') ||  ''', ''DD/MM/YYYY HH24:MI:SS'')'|| v_lf;
          end if;
    end case;

    if ((p_ordem = ' ') or (p_ordem is null)) then
      v_SqlConsulta := v_SqlConsulta || ' ORDER BY case when nvl(DIAS,0) <= 0 then ' || v_lf ||
                                        '             9999                 ' || v_lf ||
                                        '           else                   ' || v_lf ||
                                        '             To_Number(DIAS)      ' || v_lf ||
                                        '           end,                   ' || v_lf ||
                                        '           DATACALCULO DESC ';
    else
      v_SqlConsulta := v_SqlConsulta || ' ORDER BY case when nvl(DIAS,0) <= 0 then ' || v_lf ||
                                        '             9999                 ' || v_lf ||
                                        '           else                   ' || v_lf ||
                                        '             To_Number(DIAS)      ' || v_lf ||
                                        '           end                    ' || v_lf || p_ordem;
    end if;

    P_SQL_GERADO := v_SqlConsulta;

        /*
        v_nm_arq        :=      'KCW_Consulta.sql';
        --
        arquivo :=      utl_file.fopen  ('DIR_RECEPCAO'
                                        ,v_nm_arq
                                        ,'W'
                                        ,32000);
        DECLARE
        --
        l_clob_len      NUMBER;
        l_pos           NUMBER := 1;
        l_text          VARCHAR2(4000);
        --
        BEGIN
                --
                L_CLOB_LEN := DBMS_LOB.GETLENGTH(v_SqlConsulta);
                --
                --Dbms_Output.Put_Line('L_CLOB_LEN' || L_CLOB_LEN);
                --
                WHILE L_POS < L_CLOB_LEN LOOP
                        L_TEXT:= Substrb(v_SqlConsulta, L_POS, 1000);
                --
                utl_file.put(arquivo, L_TEXT);
                UTL_FILE.FFLUSH(arquivo);
                L_POS := L_POS + 1000;
                --
                END LOOP;
                --
        END;
        --
        Utl_File.fclose(arquivo);
        */

BEGIN
        --
    open P_RESULTADO for v_SqlConsulta;
    --
EXCEPTION
        WHEN    OTHERS  THEN
                --
                NULL;

        v_nm_arq        :=      'KCW_Consulta_Erro.sql';
        --
        arquivo :=      utl_file.fopen  ('DIR_RECEPCAO'
                                        ,v_nm_arq
                                        ,'W'
                                        ,32000);
      --
        DECLARE
        --
        l_clob_len      NUMBER;
        l_pos           NUMBER := 1;
        l_text          VARCHAR2(4000);
        --
        BEGIN
                --
                L_CLOB_LEN := DBMS_LOB.GETLENGTH(v_SqlConsulta);
                --
                --Dbms_Output.Put_Line('L_CLOB_LEN' || L_CLOB_LEN);
                --
                WHILE L_POS < L_CLOB_LEN LOOP
                        L_TEXT:= Substrb(v_SqlConsulta, L_POS, 1000);
                --
                utl_file.put(arquivo, L_TEXT);
                UTL_FILE.FFLUSH(arquivo);
                L_POS := L_POS + 1000;
                --
                END LOOP;
                --
        END;
        --
        Utl_File.fclose(arquivo);





END;

    if not P_RESULTADO%ISOPEN then
      open P_RESULTADO for select 1 from DUAL where 1=2;
    end if;
   END IF;
end;
end;
/


CREATE OR REPLACE PROCEDURE        prc_cotacao_carga( p_calculo in mult_calculo.calculo%type,
                             p_cprc_cotacao_carga out types.cursor_type ) is
begin

      open p_cprc_cotacao_carga for
            select mult.calculo,
                                                        mult.dataversao,
                            mult.mversao,
                            mult.item,
                            mult.modalidade,
                            mult.nome as proponente,
                            mult.iniciovigencia,
                            case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
                            mult.finalvigencia,
                            mult.tipo_cobertura,
                            mult.datacalculo,
                            mult.tiposeguro,
                            mult.cep,
                            mult.cod_tabela,
                            mult.valorbase,
                            fab.nome as fabricante,
                            modelo.descricao as modelo,
                            mult.numpassag as numpassageiros,
                            mult.procedencia,
                            mult.zerokm,
                            tf.TEXTO as descricao,
                            mp.franquiaauto as valor_franquia,
                            mult.nivelbonusauto,
                            div2.divisao_superior,
                            div2.nome as estipulante,
                            qbr.descricaoresposta,
                            mp.premio_auto as valor_ajustado,
                            mult.niveldm,
                            mp.premio_dm,
                            mult.niveldp,
                            mp.premio_dp,
                            mult.valorappdmh,
                            nvl(mpc.premio,0) as premio,
                            mult.valorappmorte,
                            mult.Tipo_Oferta,
                            mp.premio_app_morte,
                            mp.premio_app_invalidez,
                            mult.valorveiculo,
                            mult.p_ajuste as vl_veic_calc,
                            vwt1.valor valor_desp_ext,
                            nvl(mpc3.premio,0) as premio_extra,
                            mpc46.premio as premio_perda,
                            mpc46.valor as is_perda,
                            mpc951.valor as is_kitgas,
                            mpc951.premio as premio_kitgas,
                            mp.observacao,
                            mult.estado as servicos,
                            div3.divisao_superior as corretora,
                            div3.nome as nome_corretora,
                            rc.ddd as ddd_corretora,
                            rc.telefone as fone_corretora,
                            mult.versaocalculo,
                            (select nvl(sum(aces.valor),0)as valor
                             from mult_calculoaces aces
                             where aces.calculo = mult.calculo and aces.subtipo = 2
                                   and aces.valor > 0) + mult.lmi_kitgas as vl_acessorios,
                            (select nvl(sum(aces.valor),0)as valor
                             from mult_calculoaces aces
                             where aces.calculo = mult.calculo and aces.subtipo = 1
                                   and aces.valor > 0) + mult.lmi_kitgas as vl_equipamentos,
            (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 7) as premio_assistencia,
            (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 50) as premio_equipamentos,
            (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 3) as premio_acessorios,
            (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 2) as premio_carroceria,                mult.dtnascondu,
                            mult.sexocondu,
                            mult.estcvcondu,
                            cp2.parcelas,
                            cp2.valor_primeira,
                            mult.anofabricacao,
                            qbr2.descricaosubresposta,
                            qbr2.descricaosubresposta2,
                            qbr2.resposta2,
                            qbr2.subresposta,
                            qbr2.descricaoresposta2,
                            qbr2.imprime,
                            mult.comissao,
                            mult.o_ct_ids_,
                            div_com.desconto as desconto_ref,
                            div_com.pro_labore as prolabore_ref,
                            disp.tipo,
                            t2.subresposta2,
                            mult.cod_referencia,
                            round(mp.descontocomissao,2)as descontocomissao,
                            mp.tipocotacao,
                            cp2.condicao,
                            mult.tipo_pessoa,
                            usu.tipousuario,
                            usu.padraousuario,
                            mult.tipousoveic,
                            mult.desc_score,
                            mult.tipo_desc_score,
                            mult.calculoorigem,
                            mult.retornocrivo,
                            mult.placa,
                            mult.chassi,
                            mult.nomecondu,
                            mult.cpfcondu,
                            mult.cnhcondu,
                            cli.cgc_cpf,
                            mult.situacao,
                            mult.calc_online,
                            mult.validado,
                            mult.anomodelo,
                    mult.agravo,
                    mult.o_versaoids,
                    mc_vidros.opcao as opcao_vidros,
                    mult.desconto_cc,
                    mult.agravo_cc,
                    MULT.NUMERONEGOCIORESERVADO,
                    MULT.NUMEROITEMRESERVADO,
                    mult.Valor_custo_Emissao,
                                         tv.descricao as tipoveiculo,
                                carroce.texto as carroceria,
                                        tabrg.texto as combustivel,
                                        nvl(mult.calc_pai,0) as calc_pai,
                                        rmm.nr_cpf_cnpj,
                                        ids.cod_batente,
                                        mult.campo1

                    from  mult_calculo mult,tabela_veiculofabric fab,tabela_veiculomodelo modelo, vw_tabrg_p11_t80 tf,
                            mult_calculopremios mp,
                            tabela_divisoes div2,
                            mult_calculoqbr qbr,
                            mult_calculopremioscob mpc,
                            mult_calculoqbr qbr2,
                            vw_tabrg_p11_t1 vwt1,
                            mult_calculopremioscob mpc3,
                            mult_calculopremioscob mpc46,
                            tabela_divisoes div3,
                            mult_calculodivisoes md3,
                            real_corretores rc,
                            mult_calculocondpar cp2,
                            tabela_divisoescomer div_com,
                            mult_calculodivisoes mdref,mult_calculodivisoes mdref2,
                            mult_produtosqbrdispseg disp,mult_calculoqbr t2,
                            real_usuarios usu,tabela_clientes cli,
                            mult_calculodivisoes md2,
                            mult_calculocob mc_vidros,
                                                        VW_VALORBASE_CARGA tv,
                                                        mult_produtostabrg carroce,
                                                        real_anosauto aa,
                                                        mult_produtostabrg tabrg,
                            mult_produtos produtos,
                            mult_calculopremioscob mpc951,
                                                        Mult_CalculoRenovacaoMM McRMM,
                                                        tb_carga_renov_mm rmm,
                                                        mult_calculoids ids
            where mult.modelo = modelo.modelo(+)
                  and mult.fabricante = fab.fabricante(+)
                  and mult.iniciovigencia between tf.dt_inico_vigen and tf.dt_fim_vigen
                  and ((mult.tipo_franquia = tf.CHAVE2)and(tf.CHAVE1 = 1))
                  and ((mult.calculo = mp.calculo(+))and(mp.premio_liquido <> 0))
                  and ((mult.calculo = md2.calculo(+))and(md2.nivel (+)= 4)and(div2.divisao (+)= md2.divisao))
                  and ((mult.calculo = md3.calculo(+))and(md3.nivel (+)= 1)and(div3.divisao (+)= md3.divisao))
                  and ((mult.calculo = qbr.calculo(+)) and (qbr.questao (+)= 222))
                  and ((mult.calculo = mpc.calculo(+))and(mpc.cobertura (+)= 64)and(mpc.produto (+)= 11))
                  and ((mult.calculo = mpc3.calculo(+))and(mpc3.cobertura (+)= 1000)and(mpc3.produto (+)= 11))
                  and ((mult.calculo = mpc46.calculo(+))and(mpc46.cobertura (+)= 46)and(mpc46.produto (+)= 11))
                  and ((mult.calculo = mc_vidros.calculo(+))and(mc_vidros.cobertura (+)= 40))
                  and ((mult.calculo = qbr2.calculo(+)) and (qbr2.questao (+)= 244)and(qbr2.valida (+)= 'S'))
                  and vwt1.chave1 (+)= 2
                  and mult.cliente = cli.cliente(+)
                  and rc.corretor = div3.divisao_superior
                  and ((mult.calculo = cp2.calculo(+)) and (cp2.item (+)= 0)and(cp2.produto (+)= 11)and(cp2.tipocotacao (+)= 1))
                  and ((mult.calculo = mdref.calculo(+))and(mdref2.calculo (+)= mdref.calculo)and(div_com.divisao (+)= mdref.divisao)
                  and (mdref.nivel (+)= 4)and (mdref2.nivel (+)= 1)and(div_com.produto (+)= 11)
                  and ((mult.dataversao between div_com.iniciovigencia and div_com.finalvigencia) OR (div_com.desconto is null)))
                  and ((disp.produto (+)= 11) and (disp.vigencia (+)= 1) and (disp.dispositivo (+)= qbr2.subresposta))
                  and ((mult.item (+)= 0)and(mult.calculo = t2.calculo(+))and(mult.item = t2.item(+))and(t2.questao (+)= 244))
                  and ((usu.cod_usuario = mult.cod_usuario) and (usu.corretor = div3.divisao)and (usu.iniciovigencia = (select max(iniciovigencia)
                        from real_usuarios where cod_usuario = mult.cod_usuario and corretor = div3.divisao)))
                  and mult.calculo = p_calculo
                                    and tv.valorbase = mult.valorbase
                     and ((nvl(mult.tipo_carroceria,0) = 0) or
                  (carroce.chave2 = mult.tipo_carroceria and
                   carroce.TABELA = 333 and
                  TABRG.PRODUTO = 11 and
                   MULT.INICIOVIGENCIA between CARROCE.DT_INICO_VIGEN and CARROCE.DT_FIM_VIGEN))
                                    and aa.modelo = mult.modelo
                                    and aa.anode = mult.anomodelo
                                    and tabrg.chave2 = aa.codigo_combustivel
                                    and tabrg.produto = 11
                                    and tabrg.tabela = 181
                                    and mult.iniciovigencia between tabrg.dt_inico_vigen and tabrg.dt_fim_vigen
                  and ((mult.calculo = mpc951.calculo(+))and(mpc951.cobertura (+)= 951)and(mpc951.produto (+)= 11))
                  and mult.padrao =  produtos.produto
                                    and McRMM.calculo (+)= mult.Calculo
                                    and rmm.CD_APOLI_SUSEP (+)= McRMM.apoliceanterior
                                    and ids.calculo = mult.calculo


                  and rownum = 1;

        exception
            when others then
                raise;

end;
/


CREATE OR REPLACE procedure        prc_cotacao_condominio( p_calculo mult_calculo.calculo%type,
                                  p_ccotacao_condominio out types.cursor_type ) is
begin

    open p_ccotacao_condominio for
        select
        mult.calculo,
        mult.nome,
        mult.iniciovigencia,
		case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
        mult.finalvigencia,
        opc_tipocobertura.descricao as tipocondominio,
        opc_regiao.descricao as regiao,
        mult.datacalculo,
        mult.ciarenova,
        qtdeanos2.opcao qtdanos2,
        mult.cep,
        desccongenere.texto congenere,
        numeronegocio2.observacao no_negocio2,
        estipulantes.divisao_superior cod_estipulante,
        estipulantes.nome nome_estipulante,
        mult.versaocalculo,
        mult.cod_referencia,
        mult.comissao,
        mult.calculoorigem,
        mult.retornocrivo,
        mult.fabricante,
        corretores.divisao_superior cod_corretor,
        corretores.nome nome_corretor,
        corretores_fones.ddd ddd_corretor,
        CASE  WHEN    corretores.divisao_superior    =  98626  or corretores.divisao_superior    =  88626
        THEN   '0800 727 2900'
        ELSE     '('||corretores_fones.ddd||') ' || substr(corretores_fones.telefone,1,4) ||'-'|| substr(corretores_fones.telefone,5,4)
        END AS   telefone_corretor,
        --corretores_fones.telefone telefone_corretor,
        qtdeanos.opcao qtdanos,
        numeronegocio.observacao no_negocio,
        taxas.taxa * 10000000 taxa,
        estipulantes_com.pro_labore,
        estipulantes_com.desconto,
        mult.validado,
        mult.valorbase,
        mult.agravo,
        produtos.validade,
        produtos.versao,
        mult.campo2 as vencimentocongenere,
        tbsinistralidade.valor as sinistralidade,
        mult.desconto_cc,
        mult.agravo_cc,
        mult.numeronegocioreservado,
        mult.numeroitemreservado,
        cobtpseguro.opcao as tiposeguro,
		    mult.Valor_custo_Emissao,
        clientes.tipo_pessoa,
        clientes.cgc_cpf cnpj_cpf
        from
        mult_calculo mult,
        mult_calculodivisoes mult_estip,
        tabela_divisoes estipulantes,
        tabela_divisoescomer estipulantes_com,
        mult_calculodivisoes mult_corretor,
        tabela_divisoes corretores,
        tabela_divisoesfones corretores_fones,
        mult_calculocob tipocondominio,
        mult_calculocob regiao,
        mult_calculocob qtdeanos,
        mult_calculocob numeronegocio,
        mult_calculocob qtdeanos2,
        mult_calculocob numeronegocio2,
        vw_tabrg_p0_t1 desccongenere,
        mult_calculocob taxas,
        mult_produtoscobperopc opc_tipocobertura,
        mult_produtoscobperopc opc_regiao,
        mult_produtos produtos,
        mult_calculocob tbsinistralidade,
        mult_calculocob cobtpseguro,
        tabela_clientes clientes
		where
        --MULT.CALCULO = 4428757 AND
        mult_estip.calculo(+) = mult.calculo
        and mult_estip.nivel(+) = 4
        and estipulantes.divisao(+) = mult_estip.divisao
        and mult_corretor.calculo = mult.calculo
        and mult_corretor.nivel = 1
        and corretores.divisao = mult_corretor.divisao
        and corretores_fones.divisao(+) = corretores.divisao
        and (estipulantes.divisao is null or estipulantes_com.divisaocom = mult_corretor.divisao or mult.calculo > 0)
        and estipulantes_com.divisao(+) = mult_estip.divisao
        and estipulantes_com.produto(+) = 4
        and qtdeanos.calculo(+) = mult.calculo
        and qtdeanos.cobertura = 981
        and cobtpseguro.calculo(+) = mult.calculo
        and cobtpseguro.cobertura = 962
        and numeronegocio.calculo(+) = mult.calculo
        and numeronegocio.cobertura(+) = 70
        and qtdeanos2.calculo(+) = mult.calculo
        and qtdeanos2.cobertura = 972
        and numeronegocio2.calculo(+) = mult.calculo
        and numeronegocio2.cobertura(+) = 17
        and taxas.calculo = mult.calculo
        and taxas.cobertura = 19
        and desccongenere.valor = mult.ciarenova
        and tipocondominio.calculo = mult.calculo
        and tipocondominio.cobertura = 986
        and opc_tipocobertura.opcao = tipocondominio.opcao
        and opc_tipocobertura.cobertura = tipocondominio.cobertura
        and opc_tipocobertura.produto = 2
        and regiao.calculo = mult.calculo
        and regiao.cobertura = 985
        and opc_regiao.opcao = regiao.opcao
        and opc_regiao.cobertura = regiao.cobertura
        and opc_regiao.produto = 2
        and produtos.produto = mult.padrao
        and tbsinistralidade.calculo(+) = mult.calculo
        and tbsinistralidade.cobertura(+) = 996
        and clientes.cliente = mult.cliente
        and mult.calculo = p_calculo
		and rownum = 1;

        exception
            when others then
                raise;

end;
/


CREATE OR REPLACE PROCEDURE        prc_cotacao_empresarial( p_calculo mult_calculo.calculo%type,
                                   p_ccotacao_empresarial out types.cursor_type ) is
begin

    open p_ccotacao_empresarial for
        select distinct
        mult.calculo,
        mult.nome,
		cli.CGC_CPF as CNPJ_CPF,
		Mult.Tipo_Pessoa,
        mult.datacalculo,
        mult.cep,
        mult.versaocalculo,
        mult.cod_referencia,
        mult.comissao,
        mult.calculoorigem,
        mult.retornocrivo,
        mult.iniciovigencia,
		case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
        mult.finalvigencia,
        grupos.texto grupo,
        mult.fabricante cod_atividade,
        atividades.texto atividade,
        corretores.divisao_superior cod_corretor,
        corretores.nome nome_corretor,
        corretores_fones.ddd ddd_corretor,
        CASE  WHEN    corretores.divisao_superior    =  98626  or corretores.divisao_superior    =  88626
        THEN   '0800 727 2900'
        ELSE     '('||corretores_fones.ddd||') ' || substr(corretores_fones.telefone,1,4) ||'-'|| substr(corretores_fones.telefone,5,4)
        END AS   telefone_corretor,
        --corretores_fones.telefone telefone_corretor,
        estipulantes.divisao_superior cod_estipulante,
        estipulantes.nome nome_estipulante,
        qtdeanos.opcao qtdanos,
        numeronegocio.observacao no_negocio,
        taxas.taxa * 10000000 taxa,
        estipulantes_com.pro_labore,
        estipulantes_com.desconto,
        produtos.validade,
        mult.validado,
        mult.valorappmorte valor_declarado,
        mult.valorbase,
        descontomodulos.valor desconto_modulo,
        qtdeanos2.opcao qtdanos2,
        numeronegocio2.observacao no_negocio2,
        desccongenere.texto congenere,
        mult.ciarenova,
        mult.agravo,
        mult.campo2 as vencimentocongenere,
        tbsinistralidade.valor as sinistralidade,
        cobtpseguro.opcao as tiposeguro,
		    mult.valor_custo_emissao,
		    calccob.opcao as shopinsn,
        nvl(percbatente.valor1,0) as percbatente,
        mult.desconto_cc,
        mult.agravo_cc,
        mult.numeronegocioreservado,
        mult.numeroitemreservado
        from
				mult_calculocob calccob,
        mult_calculo mult,
        vw_tabrg_p4_t10 grupos,
        vw_tabrg_p4_t104 atividades,
        mult_calculodivisoes mult_estip,
        tabela_divisoes estipulantes,
        tabela_divisoescomer estipulantes_com,
        mult_calculodivisoes mult_corretor,
        tabela_divisoes corretores,
        tabela_divisoesfones corretores_fones,
        mult_calculocob qtdeanos,
        mult_calculocob numeronegocio,
        mult_calculocob qtdeanos2,
        mult_calculocob numeronegocio2,
        vw_tabrg_p0_t1 desccongenere,
        mult_calculopremioscob taxas ,
        mult_produtos produtos,
        mult_calculocob mult_descontomodulos,
        vw_tabrg_p4_t6 descontomodulos,
        mult_calculocob tbsinistralidade,
        mult_calculocob cobtpseguro,
        mult_calculoBatenteControle percbatente,
	    	Tabela_Clientes cli
        where
        --MULT.CALCULO = 4420427 AND
        grupos.chave2  = mult.modelo
        and atividades.chave1 = 1
        and atividades.chave3 = mult.fabricante
        and mult_estip.calculo(+) = mult.calculo
        and mult_estip.nivel(+) = 4
        and estipulantes.divisao(+) = mult_estip.divisao
        and mult_corretor.calculo = mult.calculo
        and mult_corretor.nivel = 1
        and corretores.divisao = mult_corretor.divisao
        and corretores_fones.divisao(+) = corretores.divisao
        and (estipulantes.divisao is null or estipulantes_com.divisaocom = mult_corretor.divisao)
        and estipulantes_com.divisao(+) = mult_estip.divisao
        and estipulantes_com.produto(+) = 4
        and qtdeanos.calculo(+) = mult.calculo
        and qtdeanos.cobertura = 981
        and cobtpseguro.calculo(+) = mult.calculo
        and cobtpseguro.cobertura = 962
        and numeronegocio.calculo(+) = mult.calculo
        and numeronegocio.cobertura(+) = 70
        and qtdeanos2.calculo(+) = mult.calculo
        and qtdeanos2.cobertura = 972
        and numeronegocio2.calculo(+) = mult.calculo
        and numeronegocio2.cobertura(+) = 17
        and taxas.calculo = mult.calculo
        and taxas.cobertura = 19
        and produtos.produto = mult.padrao
        and mult_descontomodulos.calculo(+) = mult.calculo
        and mult_descontomodulos.cobertura(+) = 994
        and descontomodulos.chave1(+) = mult_descontomodulos.opcao
        and desccongenere.valor = mult.ciarenova
        and tbsinistralidade.calculo(+) = mult.calculo
        and tbsinistralidade.cobertura(+) = 996
        and percbatente.calculo(+) = mult.calculo
        and percbatente.sequencia(+) = 20
        and mult.calculo = p_calculo
		and cli.cliente = mult.cliente
		and mult.padrao = produtos.produto
		and calccob.calculo = mult.calculo
				and calccob.cobertura = 1004
        and rownum = 1;

        exception
            when others then
                raise;


end;
/


CREATE OR REPLACE procedure PRC_COTACAO_RESIDENCIAL( P_CALCULO in MULT_CALCULO.CALCULO%type,
                                                     p_ccontacao_residencial out types.cursor_type ) is
begin
    open p_ccontacao_residencial for
        select
        mult.calculo,
        mult.item,
        mult.nome,
        mult.datacalculo,
        mult.iniciovigencia,
        case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
        mult.finalvigencia,
        mult.cod_cidade,
        mult.cep,
        case when mult.InicioVigencia < PRODUTOS.VALIDADE then
          PRODUTOS.banco_veic
        else
          PRODUTOS.VERSAO
        end versaocalculo,
        mult.comissao,
        mult.cod_referencia,
        mult.apol_ren_tokio,
        mult.item_ren_tokio,
        mult.bonus_ren_tokio,
        '2' as tipo_relacionamento,
        imoveldesc.descricao tipo_imovel,
        ocupacaodesc.descricao tipo_ocupacao,
        construcao.opcao tipo_construcao,
        cobertura.opcao tipo_cobertura,
        condominio.opcao tipo_condominio,
        assitencia.opcao assistencia_24h,
        corretordesc.divisao_superior,
        to_char(corretordesc.divisao_superior) || ' ' || corretordesc.nome as corretor,
        to_char(estipdesc.divisao_superior) || ' ' || estipdesc.nome as estipulante,
        estipcom.desconto,
        estipcom.pro_labore,
        produtos.versao,
        produtos.validade,
        CASE  WHEN    corretordesc.divisao_superior    =  98626  or corretordesc.divisao_superior    =  88626
        THEN   '0800 727 2900'
        ELSE     '('||fonecorretor.ddd||') ' || substr(fonecorretor.telefone,1,4) ||'-'|| substr(fonecorretor.telefone,5,4)
        END AS   telefone,
        desccongenere.texto congenere,
        descapoliceant.observacao apoliceanterior,
        descrenovcongenere.opcao descontorenovcongenere,
        descnorenov.observacao numeronegociorenovacao,
        descrenovreal.opcao descontorenovreal,
        desctaxa.taxa * 10000000 taxa,
        mult.calculoorigem,
        mult.retornocrivo,
        mult.validado,
        mult.agravo,
        mult.campo2 as vencimentocongenere,
        tbsinistralidade.valor as sinistralidade,
        mult.desconto_cc,
        mult.agravo_cc,
        mult.numeronegocioreservado,
        mult.numeroitemreservado,
        cobtpseguro.opcao as tiposeguro,
		    mult.valor_custo_emissao,
        clientes.tipo_pessoa,
        clientes.cgc_cpf cnpj_cpf
        from
        mult_calculo mult,
        mult_calculocob imovel,
        mult_produtoscobperopc imoveldesc,
        mult_calculocob ocupacao,
        mult_produtoscobperopc ocupacaodesc,
        mult_calculocob construcao,
        mult_calculocob cobertura,
        mult_calculocob condominio,
        mult_calculodivisoes estip,
        mult_calculodivisoes corretor,
        tabela_divisoes corretordesc,
        tabela_divisoes estipdesc,
        tabela_divisoesfones fonecorretor,
        tabela_divisoescomer estipcom,
        mult_produtos produtos,
        vw_tabrg_p0_t1 desccongenere,
        mult_calculocob descapoliceant,
        mult_calculocob descrenovcongenere,
        mult_calculocob descnorenov,
        mult_calculocob descrenovreal,
        mult_calculocob desctaxa,
        mult_calculocob assitencia,
        mult_calculocob tbsinistralidade,
        mult_calculocob cobtpseguro,
        tabela_clientes clientes
        where
        imovel.calculo(+) = mult.calculo  /*Pega Tipo Imovel*/
        and imovel.item(+) = mult.item
        and imovel.cobertura = 998
        and imoveldesc.cobertura = imovel.cobertura
        and imoveldesc.opcao = imovel.opcao
        and ocupacao.calculo(+) = mult.calculo  /*Pega Tipo Ocupacao*/
        and ocupacao.item(+) = mult.item
        and ocupacao.cobertura = 999
        and cobtpseguro.calculo(+) = mult.calculo
        and cobtpseguro.cobertura = 962
        and ocupacaodesc.cobertura = ocupacao.cobertura
        and ocupacaodesc.opcao = ocupacao.opcao
        and construcao.calculo(+) = mult.calculo
        and construcao.item(+) = mult.item
        and construcao.cobertura = 986
        and cobertura.calculo(+) = mult.calculo
        and cobertura.item(+) = mult.item
        and cobertura.cobertura = 975
        and condominio.calculo(+) = mult.calculo
        and condominio.item(+) = mult.item
        and condominio.cobertura = 1004
        and corretor.calculo(+) = mult.calculo
        and corretor.nivel = 1
        and corretordesc.divisao =  corretor.divisao
        and fonecorretor.divisao = corretordesc.divisao
        and estip.calculo(+) = mult.calculo
        and estip.nivel(+) = 4
        and estipdesc.divisao(+) = estip.divisao
        and estipdesc.tipo_divisao(+) = 'B'
		and ((estip.divisao is null) or
            ((estipcom.divisaocom = corretor.divisao) and
            (mult.iniciovigencia between estipcom.iniciovigencia and estipcom.finalvigencia)))
        and estipcom.divisao(+) = estip.divisao
        and estipcom.produto(+) = 1
        and produtos.produto = 1
        and desccongenere.valor = mult.ciarenova
        and descnorenov.calculo = mult.calculo
        and descnorenov.cobertura = 70
        and descapoliceant.calculo = mult.calculo
        and descapoliceant.cobertura = 17
        and descrenovcongenere.calculo = mult.calculo
        and descrenovcongenere.cobertura = 972
        and descrenovreal.calculo = mult.calculo
        and descrenovreal.cobertura = 981
        and desctaxa.calculo = mult.calculo
        and desctaxa.cobertura = 19
        and assitencia.calculo = mult.calculo
        and assitencia.cobertura = 46
        and tbsinistralidade.calculo(+) = mult.calculo
        and tbsinistralidade.cobertura(+) = 996
        and clientes.cliente = mult.cliente
        and mult.calculo = p_calculo
        and rownum = 1;

        exception
            when others then
                raise;
end;
/


CREATE OR REPLACE procedure        PRC_GERA_CALCULOS_REALTIME(p_DataServer in varchar2, p_gpa_id in number, p_gpa_modulo in varchar2) as
begin
  declare
    VFILTRO number(30);
    SQL_ORIGIN LONG(7000);
    arquivo         utl_file.file_type; --SAF37847

    CEPS_ORIGIN CONSTANT varchar2(100) := '(to_number(SUBSTR(MC.CEP,1,5) || SUBSTR(MC.CEP,7,3)) between #CEPINI# and #CEPFIM#)';
    AGRUPAMENTO_VEIC CONSTANT VARCHAR2(200) := 'and VM.VALOR3 in(#COD_REF#) ';

    SQL_DYNAMIC LONG(15000); --SAF37847
    VDATAVERSAO_REALTIME DATE;
    VDATAVERSAO_ORIGINAL date;
    vDATAVALIDADE_ORIGINAL date;
    vTIPOCC VARCHAR2(2);
    VCEPS varchar2(3500);
    VCEPS_2LOG varchar2(1500);
    VPRODUTOS varchar2(100);
    VMODULOS varchar2(100);
    VAGRUPAMENTO_VEIC VARCHAR2(1500);
    VVALIDADE VARCHAR2(1000);
    VVALIDADE_2LOG varchar2(100);
    VTIPOSEGURO varchar2(100);
    VCALCULO number(18);
    VCALCULO_NEW number(18);
    VITEM number(18);
    VVALORPREMIO number(18,6);
    VCOD_INTERNO NUMBER(18,6);
    VDIVISAO_SUPERIOR_EST NUMBER(18);
    VNOME_SEGURADO varchar2(50);
    VVEICULO varchar2(50);
    VFABRICANTE varchar2(50);
    VMODULOPRODUTO smallint;
    vQtdes_calculo number(30);
    vEmail varchar2(4000);
    vModuloDesc varchar2(80);
    vSituacaoDesc varchar2(80);
    vTipoSeguroDesc VARCHAR2(255);
    vFiltroRange VARCHAR2(255);
    vfCOMISSAO number(10,2);
    vfCGC_CPF varchar2(20);
    vfNOMEESTIPULANTE varchar2(80);
    vfCEP varchar2(20);
    vfINICIOVIGENCIA date;
    vfAGRUP_VEICULO number(10);
    vfDESC_TIPOSEGURO varchar2(20);
    vfSITUACAO varchar2(50);
    vfDESC_VALIDACAO varchar2(50);
    vfCOD_USUARIO varchar2(50);
    vfVALIDADE varchar2(20);
    vfDIAS varchar2(20);
    vDescProduto varchar2(50);

    v_ambiente varchar2(50);
    v_preenche_borda  VARCHAR2(4000) := 'thin';
    vLinha integer;

    v_nm_arq varchar2(500);
    v_blob BLOB;
    v_file tms_mail.file_type;

    --Cursor para a Buscar os critÈrios agendado para hoje
    cursor C_FILTRO_REALTIME is
      SELECT *
        FROM TABELA_FILTRO_REALTIME
       WHERE SITUACAO='PG'
         --AND TRUNC(DATA_EXECUCAO_AGENDADA) = TO_DATE(P_DATASERVER,'dd/mm/yyyy') --Comentado somente para testes
       ORDER BY FILTRO DESC;
       --for update of situacao;
    --Cursor para Busca da Faixa de CEPs cadastrados para o critÈrio
    cursor C_FILTRO_CEPS(VFILTRO TABELA_FILTRO_REALTIME.FILTRO%type) is
      select *
        from TABELA_FILTRO_REALTIME_CEP
       where FILTRO = VFILTRO;
    --Cursor para Busca de Dias cadastrados para o critÈrio
    cursor C_FILTRO_DIAS(VFILTRO TABELA_FILTRO_REALTIME.FILTRO%type) is
      select *
        from TABELA_FILTRO_REALTIME_DIAS
       where FILTRO = VFILTRO;
    --Cursor para gravar C·lculos encontrados conforme o critÈrio
    type T_CALCULO_CURTYP is ref cursor;
    C_CALCULOS_TOINSERT T_CALCULO_CURTYP;

  BEGIN
    v_ambiente := tms_param.get_param('RECEPCAO.ELETRONICA.CASOS.ABORTIVOS', 'AMBIENTE');
    if (C_FILTRO_CEPS%isopen) then
      close C_FILTRO_CEPS;
    end if;
    if (C_FILTRO_REALTIME%isopen) then
      close C_FILTRO_REALTIME;
    end if;
    if (C_CALCULOS_TOINSERT%isopen) then
      close C_CALCULOS_TOINSERT;
    end if;

    PRC_SQL_SELECAO_REALTIME(p_DataServer, 'PROC', SQL_ORIGIN);

		--Transfere Dados Para
		/*insert into TABELA_CALCULOS_REALTIME_HISTO
		select CALCULO,ITEM,FILTRO,VALOR_PREMIO_ORIGINAL,VALOR_PREMIO_REALTIME,DATA_CALCULO,SITUACAO,
			COD_INTERNO, COD_ASSESSORIA, NOME_SEGURADO, DATAVALIDADE_REALTIME, FABRICANTE, VEICULO,
			TIPO_OFERTA, MODULOPRODUTO, MENSAGEM_ERRO, SYSDATE
		from TABELA_CALCULOS_REALTIME where situacao <> 'EX';
		*/
		--Exclui todos os registros da tabela TABELA_CALCULOS_REALTIME (Obs.: ¿ partir da vers„o 0613K1 os registros n„o ser„o excluÌdos
		--delete from TABELA_CALCULOS_REALTIME; --where situacao <> 'EX';

    vFiltroRange := '';
    vLinha := 0;
    -- Monta filtro para buscar c·lculo conforme critÈrio salvo em TABELA_FILTRO_REALTIME
    for FILTRO_REC in C_FILTRO_REALTIME
    LOOP
      if vFiltroRange <> ' ' then
        vFiltroRange := vFiltroRange || ', ';
      END IF;
      vFiltroRange :=  vFiltroRange || FILTRO_REC.FILTRO;

      SQL_DYNAMIC := SQL_ORIGIN;
      VVALIDADE := ' ';
      VPRODUTOS := ' ';
      VVALIDADE_2LOG := ' ';
      VTIPOSEGURO := ' ';
      VCEPS := ' ';
      VCEPS_2LOG := ' ';
      vTipoSeguroDesc := ' ';
      vSituacaoDesc := ' ';
      vModuloDesc := ' ';

      --Substitui substring pelo Produto encontrado
      if FILTRO_REC.AUTOCLASSICO = 'S' then
        if VPRODUTOS <> ' ' then
          VPRODUTOS := VPRODUTOS || ', ';
        end if;
        VPRODUTOS :=  VPRODUTOS || '42';
      end if;
      if FILTRO_REC.AUTOPASSEIO = 'S' then
        if VPRODUTOS <> ' ' then
          VPRODUTOS := VPRODUTOS || ', ';
        end if;
        VPRODUTOS :=  VPRODUTOS || '10';
      end if;
      if FILTRO_REC.AUTOCARGA = 'S' then
        if VPRODUTOS <> ' ' then
          VPRODUTOS := VPRODUTOS || ', ';
        end if;
        VPRODUTOS :=  VPRODUTOS || '11,14,15';
      end if;
      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#PRODUTO#', VPRODUTOS);

      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#DataServidor#', p_DataServer);

      --Cria Filtro para o Tipo de Seguro da seleÁ„o da CotaÁ„o
      if FILTRO_REC.TIPO_SEGURO_NOVO = 'S' then
        if VTIPOSEGURO <> ' ' then
          VTIPOSEGURO := VTIPOSEGURO || ', ';
        end if;
        VTIPOSEGURO :=  VTIPOSEGURO || '1';
        vTipoSeguroDesc := vTipoSeguroDesc || 'Novo';
      end if;
      if FILTRO_REC.TIPO_SEGURO_CONGE_COM_SIN = 'S' then
        if VTIPOSEGURO <> ' ' then
          VTIPOSEGURO := VTIPOSEGURO || ', ';
          vTipoSeguroDesc := vTipoSeguroDesc || ', ';
        end if;
        VTIPOSEGURO :=  VTIPOSEGURO || '2';
        vTipoSeguroDesc := vTipoSeguroDesc || 'CongÍnere com sinistro';
      end if;
      if FILTRO_REC.TIPO_SEGURO_CONGE_SEM_SIN = 'S' then
        if VTIPOSEGURO <> ' ' then
          VTIPOSEGURO := VTIPOSEGURO || ', ';
          vTipoSeguroDesc := vTipoSeguroDesc || ', ';
        end if;
        VTIPOSEGURO :=  VTIPOSEGURO || '3';
        vTipoSeguroDesc := vTipoSeguroDesc || 'CongÍnere sem sinistro';
      end if;
      if FILTRO_REC.TIPO_SEGURO_TOKIO_COM_SIN = 'S' then
        if VTIPOSEGURO <> ' ' then
          VTIPOSEGURO := VTIPOSEGURO || ', ';
          vTipoSeguroDesc := vTipoSeguroDesc || ', ';
        end if;
        VTIPOSEGURO :=  VTIPOSEGURO || '4';
        vTipoSeguroDesc := vTipoSeguroDesc || 'Tokio com sinistro';
      end if;
      if FILTRO_REC.TIPO_SEGURO_TOKIO_SEM_SIN = 'S' then
        if VTIPOSEGURO <> ' ' then
          VTIPOSEGURO := VTIPOSEGURO || ', ';
          vTipoSeguroDesc := vTipoSeguroDesc || ', ';
        end if;
        VTIPOSEGURO :=  VTIPOSEGURO || '5';
        vTipoSeguroDesc := vTipoSeguroDesc || 'Tokio sem sinistro';
      end if;
      --Substitui substring pelo Tipo de Seguro encontrado
      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#TIPOSEGURO#', VTIPOSEGURO);

      --Cria Filtro para Agrupamento de VeÌculo da seleÁ„o da CotaÁ„o
      if FILTRO_REC.AGRUPAMENTO_VEIC <> ' ' then
        VAGRUPAMENTO_VEIC := AGRUPAMENTO_VEIC;
        VAGRUPAMENTO_VEIC := replace(VAGRUPAMENTO_VEIC, '#COD_REF#', FILTRO_REC.AGRUPAMENTO_VEIC);
      end if;
      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#AGRUPAMENTO_VEIC#', VAGRUPAMENTO_VEIC);

      --Substitui substring Validade pelos Dias encontrados
      for DIAS_REC in C_FILTRO_DIAS(FILTRO_REC.FILTRO)
      LOOP
        if VVALIDADE <> ' ' then
          VVALIDADE := VVALIDADE || ', ';
          VVALIDADE_2LOG := VVALIDADE_2LOG || ', ';
        END IF;
        VVALIDADE := VVALIDADE || DIAS_REC.DIAS;
        VVALIDADE_2LOG := VVALIDADE_2LOG || DIAS_REC.DIAS;
      end LOOP;
      --Substitui substring pela Validade encontrada
      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#VALIDADE#', VVALIDADE);

      --Substitui substring CEP pelos ceps encontrados
      for CEPS_REC in C_FILTRO_CEPS(FILTRO_REC.FILTRO)
      LOOP
        if VCEPS <> ' ' then
          VCEPS := VCEPS || ' OR ';
        else
          VCEPS := VCEPS || ' AND(';
        end if;
        VCEPS := VCEPS || CEPS_ORIGIN;
        VCEPS := replace(VCEPS, '#CEPINI#', CEPS_REC.CEP_INICIO);
        VCEPS := replace(VCEPS, '#CEPFIM#', CEPS_REC.CEP_FINAL);
        if VCEPS_2LOG <> ' ' then
          VCEPS_2LOG := VCEPS_2LOG || ' e ';
        end if;
        VCEPS_2LOG := VCEPS_2LOG || CEPS_REC.CEP_INICIO || ' a ' || CEPS_REC.CEP_FINAL;
      end LOOP;
      if VCEPS <> ' ' then
        VCEPS := VCEPS || ')';
      end if;
      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#CEPS#', VCEPS);

      SQL_DYNAMIC := replace(SQL_DYNAMIC, '#FILTRO#', FILTRO_REC.FILTRO);

      vModuloDesc := REPLACE(VPRODUTOS,   '42', '20 - Auto Cl·ssico');
      vModuloDesc := REPLACE(vModuloDesc, '10', '7 - Auto Passeio');
      vModuloDesc := REPLACE(vModuloDesc, '11,14,15', '9 - Auto Carga');

      if FILTRO_REC.SITUACAO = 'PD' then
        vSituacaoDesc := 'Pendente (PD)';
      else
        if FILTRO_REC.SITUACAO = 'PG' then
          vSituacaoDesc := 'Programado (PG)';
        else
          if FILTRO_REC.SITUACAO = 'EX' then
            vSituacaoDesc := 'Em ExecuÁ„o (EX)';
          else
            if FILTRO_REC.SITUACAO = 'ES' then
              vSituacaoDesc := 'Executado com sucesso (ES)';
            else
              if FILTRO_REC.SITUACAO = 'EE' then
                vSituacaoDesc := 'Executado com Erro (EE)';
              else
                if FILTRO_REC.SITUACAO = 'CA' then
                  vSituacaoDesc := 'Cancelado (CA)';
                end if;
              end if;
            end if;
          end if;
        end if;
      end if;

      VMODULOS := REPLACE(VPRODUTOS, '42', '20');
      VMODULOS := replace(VMODULOS,  '10', '7');
      VMODULOS := REPLACE(VMODULOS,  '11', '9');

      VDATAVERSAO_REALTIME := FILTRO_REC.DATAVERSAO;

      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'ExibiÁ„o dos CritÈrios(ID='||To_Char(FILTRO_REC.FILTRO)||') de SeleÁ„o ');
      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'InÌcio ExecuÁ„o: ' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));
      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Data Vers„o utilizada: ' || FILTRO_REC.DATAVERSAO);
      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Expira em (dias): ' || VVALIDADE_2LOG);
      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Tipo de Seguro: ' || vTipoSeguroDesc);
      if FILTRO_REC.AGRUPAMENTO_VEIC is null then
        PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Agrupamento VeÌculo: N„o h· agrupamentos(s) cadastrado(s)');
      else
        PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Agrupamento VeÌculo: ' || FILTRO_REC.AGRUPAMENTO_VEIC);
      end if;
      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'MÛdulo: ' || vModuloDesc);
      if TRIM(VCEPS_2LOG) is null then
        PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Faixa(s) CEP(s): N„o h· faixa(s) cadastrada(s)');
      else
        PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Faixa(s) CEP(s): ' || VCEPS_2LOG);
      end if;

      vEmail := vEmail ||
                'ExibiÁ„o dos CritÈrios(ID='||To_Char(FILTRO_REC.FILTRO)||') de SeleÁ„o:<br /> ' ||
                '------------------------------------------------------------------------------'||'<br />' ||
                ' InÌcio ExecuÁ„o: ' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || '<br />' ||
                ' Data Vers„o utilizada: ' || FILTRO_REC.DATAVERSAO || '<br />' ||
                ' Expira em (dias): ' || VVALIDADE_2LOG || '<br />' ||
                ' Tipo de Seguro: ' || vTipoSeguroDesc || '<br />';
      if FILTRO_REC.AGRUPAMENTO_VEIC is null then
        vEmail := vEmail || ' Agrupamento VeÌculo: N„o h· agrupamentos(s) cadastrado(s)' || '<br />';
      else
        vEmail := vEmail || ' Agrupamento VeÌculo: ' || FILTRO_REC.AGRUPAMENTO_VEIC || '<br />';
      end if;
      vEmail := vEmail || ' MÛdulo: ' || vModuloDesc || '<br />';
      if TRIM(VCEPS_2LOG) is null then
        vEmail := vEmail || ' Faixa(s) CEP(s): N„o h· faixa(s) cadastrada(s)' || '<br />';
      else
        vEmail := vEmail || ' Faixa(s) CEP(s): ' || VCEPS_2LOG || '<br />';
      end if;
      vQtdes_calculo := 0;
        -- SAF37847 inicio
        v_nm_arq        :=      'Select_Quadro_Filtro_'|| filtro_rec.filtro ||'.txt';
        --
        arquivo :=      utl_file.fopen  ('DIR_RECEPCAO'
                                        ,v_nm_arq
                                        ,'W'
                                        ,32000);
      --
        DECLARE
        --
        l_clob_len      NUMBER;
        l_pos           NUMBER := 1;
        l_text          VARCHAR2(4000);
        --
        BEGIN
                --
                L_CLOB_LEN := DBMS_LOB.GETLENGTH(SQL_DYNAMIC);
                --
                --Dbms_Output.Put_Line('L_CLOB_LEN' || L_CLOB_LEN);
                --
                WHILE L_POS < L_CLOB_LEN LOOP
                        L_TEXT:= Substrb(SQL_DYNAMIC, L_POS, 1000);
                --
                utl_file.put(arquivo, L_TEXT);
                UTL_FILE.FFLUSH(arquivo);
                L_POS := L_POS + 1000;
                --
                END LOOP;
                --
        END;
        --
        Utl_File.fclose(arquivo);
        -- SAF37847 fim

      open C_CALCULOS_TOINSERT for SQL_DYNAMIC;
      LOOP
        FETCH C_CALCULOS_TOINSERT into VCALCULO, VITEM, VVALORPREMIO, VCOD_INTERNO, VDIVISAO_SUPERIOR_EST, VNOME_SEGURADO, VVEICULO,
		                               VFABRICANTE, VMODULOPRODUTO, vDescProduto, VFILTRO, VDATAVERSAO_ORIGINAL, vDATAVALIDADE_ORIGINAL,
                                   vfCOMISSAO, vfCGC_CPF, vfNOMEESTIPULANTE, vfCEP, vfINICIOVIGENCIA, vfAGRUP_VEICULO, vfDESC_TIPOSEGURO,
                                   vfSITUACAO, vfDESC_VALIDACAO, vfCOD_USUARIO, vfVALIDADE, vfDIAS, vTIPOCC;
        EXIT when C_CALCULOS_TOINSERT%NOTFOUND;

        vLinha := vLinha + 1;

        INSERT INTO TABELA_CALCULOS_REALTIME (CALCULO, ITEM, FILTRO, VALOR_PREMIO_ORIGINAL, COD_INTERNO, DIVISAO_SUPERIOR_EST, NOME_SEGURADO, VEICULO, FABRICANTE, MODULOPRODUTO, SITUACAO, DATAVERSAO_REALTIME, DATAVERSAO_ORIGINAL, DATAVALIDADE_ORIGINAL, CONTACORRENTE_ANT)
           VALUES(VCALCULO, VITEM, VFILTRO, VVALORPREMIO, VCOD_INTERNO, VDIVISAO_SUPERIOR_EST, VNOME_SEGURADO, VVEICULO, VFABRICANTE, VMODULOPRODUTO, 'EX', VDATAVERSAO_REALTIME, VDATAVERSAO_ORIGINAL, vDATAVALIDADE_ORIGINAL, vTIPOCC); --EX=Em ExecuÁ„o

        VQTDES_CALCULO := VQTDES_CALCULO + 1;

        --Criando Planilha para enviar como anexo no e-mail
        if vLinha = 1 then
          ssvrppa0026_001.new_sheet('C·lculos Selecionados ' || To_Char(sysdate, 'DD-MM-YYYY'));
          ssvrppa0026_001.cell(1, vLinha, 'Filtro', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(2, vLinha, 'Nome', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(3, vLinha, 'CPF/CNPJ', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(4, vLinha, 'CEP', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(5, vLinha, 'Produto', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(6, vLinha, 'C·lculo', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(7, vLinha, 'Corretor', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(8, vLinha, 'Comiss„o', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(9, vLinha, 'Empresa Parceira', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(10, vLinha, 'Data PSI', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(11, vLinha, 'InÌcio VigÍncia', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(12, vLinha, 'Tipo Seguro', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(13, vLinha, 'Agrupamento VeÌculo', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(14, vLinha, 'SituaÁ„o', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(15, vLinha, 'ValidaÁ„o', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(16, vLinha, 'Usu·rio', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(17, vLinha, 'Data Validade', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          ssvrppa0026_001.cell(18, vLinha, 'Expira em', p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
          vLinha := vLinha + 1;
        end if;
        ssvrppa0026_001.cell(1, vLinha, VFILTRO, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(2, vLinha, VNOME_SEGURADO, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(3, vLinha, vfCGC_CPF, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(4, vLinha, vfCEP, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(5, vLinha, vDescProduto, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(6, vLinha, To_Char(VCALCULO), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(7, vLinha, To_Char(VCOD_INTERNO), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(8, vLinha, To_Char(vfCOMISSAO), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(9, vLinha, vfNOMEESTIPULANTE, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(10, vLinha, To_Char(VDATAVERSAO_ORIGINAL, 'DD/MM/YYYY'), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(11, vLinha, To_Char(vfINICIOVIGENCIA, 'DD/MM/YYYY'), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(12, vLinha, vfDESC_TIPOSEGURO, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(13, vLinha, To_Char(vfAGRUP_VEICULO), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(14, vLinha, vfSITUACAO, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(15, vLinha, vfDESC_VALIDACAO, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(16, vLinha, vfCOD_USUARIO, p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(17, vLinha, To_Char(vDATAVALIDADE_ORIGINAL, 'DD/MM/YYYY'), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
        ssvrppa0026_001.cell(18, vLinha, To_Char(vfDIAS), p_fontId => ssvrppa0026_001.get_font('Calibri', p_bold => TRUE), p_alignment => ssvrppa0026_001.get_alignment(p_vertical => 'center', p_horizontal => 'center'), p_borderId => ssvrppa0026_001.Get_border(v_preenche_borda, v_preenche_borda, v_preenche_borda, v_preenche_borda));
      end LOOP;
      PKG_KCWUTILS.Log_Info(p_gpa_id, p_gpa_modulo, 'Quantidade de cotaÁıes a serem processadas: ' || vQtdes_calculo);

      vEmail := vEmail || 'Quantidade de cotaÁıes a serem processadas: ' || vQtdes_calculo|| '<br />' ||
                          '------------------------------------------------------------------------------<br/><br/><br/><br/>';
      UPDATE TABELA_FILTRO_REALTIME SET SITUACAO = 'EX' WHERE FILTRO = VFILTRO; --SituaÁ„o EX=Em execuÁ„o
    END LOOP;
    if vLinha > 0 then
     v_nm_arq := 'CalculosSelecionadosQuadro_' || To_Char(SYSDATE, 'DD-MM-YYYY') || '.xlsx';
     ssvrppa0026_001.save('DIR_RECEPCAO', v_nm_arq);
     v_blob := tms_storage.readFileAndLoadAsBLOB('DIR_RECEPCAO', v_nm_arq);
     v_file(1) := TMS_FILE_RECORD(v_nm_arq, v_blob);
	 BEGIN
      PKG_KCWUTILS.SendMailwFile('InÌcio execuÁ„o Quadro de Oportunidades - ID='||vFiltroRange||' - ['|| v_ambiente ||']',
                             vEmail, '', 'DEST_QUADRO', v_file);
     EXCEPTION WHEN OTHERS THEN
      PKG_KCWUTILS.LOG_INFO(P_GPA_ID, P_GPA_MODULO, 'Ocorreu um erro ao tentar enviar e-mail.');
     END;
	end if;
  END;
end PRC_GERA_CALCULOS_REALTIME;
/


CREATE OR REPLACE PROCEDURE prc_gera_imp_cotacao
(
     PCALCULO      IN  number,
     PCAMPO        OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO for

SELECT MULT.CALCULO ,
                MULT.MVERSAO,
                MULT.ITEM,
                MULT.MODALIDADE,
                MULT.NOME AS PROPONENTE,
                MULT.INICIOVIGENCIA,
				case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao, 
                MULT.FINALVIGENCIA,
                MULT.TIPO_COBERTURA,
                MULT.DATACALCULO,
                MULT.CEP,
                FAB.NOME AS FABRICANTE,
                MODELO.DESCRICAO AS MODELO,
                MULT.ANOFABRICACAO,
                MULT.ANOMODELO,
                MODELO.NUMPASSAGEIROS,
                MULT.PROCEDENCIA,
                VW.TEXTO AS CATEGORIA,
                MULT.ZEROKM,
                vw_franq.FRANQUIA as Descricao,
                MP.FRANQUIAAUTO AS VALOR_FRANQUIA,
                V.VALOR,
                MULT.NIVELBONUSAUTO,
                DIV2.DIVISAO_SUPERIOR,
                DIV2.NOME AS ESTIPULANTE,
                QBR.DESCRICAORESPOSTA,
                RD.CD_FIPE,
               MP.PREMIO_AUTO AS VALOR_AJUSTADO,
                MULT.NIVELDM,
                MP.PREMIO_DM,
                MULT.NIVELDP,
                MP.PREMIO_DP,
                MULT.VALORAPPDMH,
                MPC.PREMIO,
                MULT.VALORAPPMORTE,
                MP.PREMIO_APP_MORTE,
                MP.PREMIO_APP_INVALIDEZ,
                MULT.VALORVEICULO,
                MULT.P_AJUSTE AS VL_VEIC_CALC,
                VWT1.VALOR VALOR_DESP_EXT,
                MPC3.PREMIO AS PREMIO_EXTRA,
                PER.DESCRICAO AS CARRORESERVA,
                MPC4.PREMIO AS VL_PREMIO_CAR_RES,
                MP.PREMIO_ACESSORIOS,
                COB_VIDROS.OPCAO AS OPCAO_VIDROS,
                MP.OBSERVACAO,
                MPC2.PREMIO AS VL_PREMIO_VIDROS,
                MULT.ESTADO AS SERVICOS,
                DIV3.DIVISAO_SUPERIOR AS CORRETORA,
                DIV3.NOME AS NOME_CORRETORA,
                RC.DDD AS DDD_CORRETORA,
                RC.TELEFONE AS FONE_CORRETORA,
                MULT.VERSAOCALCULO,
                Nvl(ACE.valor,0)  + Nvl(MULT.LMI_KITGAS,0) + Nvl(MULT.LMI_BlINDAGEM,0) AS VL_ACESSORIOS,
                MULT.DTNASCONDU,
                MULT.SEXOCONDU,
                MULT.ESTCVCONDU,
                QBR2.DESCRICAOSUBRESPOSTA,
                QBR2.DESCRICAOSUBRESPOSTA2,
                QBR2.RESPOSTA2,
                QBR2.SUBRESPOSTA,
                QBR2.DESCRICAORESPOSTA2,
                QBR2.IMPRIME,
                DISP.TIPO,
                COB_DES.OPCAO AS OPCAO_DES,
                MULT.COMISSAO,
                DIV_COM.DESCONTO AS DESCONTO_REF,
                DIV_COM.PRO_LABORE AS PROLABORE_REF,
                MULT.O_CT_IDS_,
                T2.SUBRESPOSTA2,
                mult.cod_referencia,
                ROUND(mp.descontocomissao,2)AS descontocomissao,
                D.VALOR_MEDIO,
                D.valor_minimo,
                D.VALOR_MEDIO_Ant,
                D.valor_minimo_ant,
                DR.VALOR_MEDIO AS VALOR_MEDIO2,
                DR.valor_minimo AS valor_minimo2,
                DR.VALOR_MEDIO_Ant AS VALOR_MEDIO_Ant2,
                DR.valor_minimo_ant AS valor_minimo_ant2,
                MP.TIPOCOTACAO,
                CP.CONDICAO,
                mult.TIPO_PESSOA,
                USU.TIPOUSUARIO,
                USU.PADRAOUSUARIO,
                mult.TIPOUSOVEIC,
                mult.DESC_SCORE,
                mult.tipo_desc_score,
                mult.calculoorigem,
                mult.retornocrivo,
                mult.PLACA,
                mult.CHASSI,
                mult.NOMECONDU,
                mult.CPFCONDU,
                mult.CNHCONDU,
                cli.CGC_CPF,
                mult.SITUACAO,
                mult.CALC_ONLINE,
                mult.VALIDADO,
				MULT.TIPOSEGURO,
				MULT.AGRAVO,
				MULT.O_VERSAOIDS,
                MULT.PGTO_BANCO_HONDA,
				MULT.VALOR_CUSTO_EMISSAO,
                MULT.VALOR_IOF_CUSTO,
                MULT.RETORNODECODIFICADOR,
				PRODUTOS.NOMEPRODUTO,
				MULT.KITGAS,
				PRIMEIO_SINISTRO_DESC.DESCRICAO  AS PRIM_SINISTRO,
				KM_ADICIONAL_DESC.DESCRICAO AS KM_ADIC,
				AR_DIRECAO_DESC.DESCRICAO AS AR_DH,
				OFICINA_REFERENCIADA_DESC.DESCRICAO AS OFICINA_REF ,
				MULT.BLINDAGEM,
				MULT.VALORBASE,
				MULT.DESCONTO_CC,
				MULT.AGRAVO_CC,
				MULT.NUMERONEGOCIORESERVADO,
				MULT.NUMEROITEMRESERVADO,
        MULT.CONDICOES_ESPECIAIS,
				tabrg.texto as combustivel,
				mult.condicoes_especiais
from mult_Calculo MULT
left join  (
                SELECT calculo, nvl(sum(VALOR),0) AS VALOR
                FROM   mult_calculoaces
                where  valor > 0
                group by calculo
              ) ACE
  on  ACE.calculo = MULT.CALCULO
inner join mult_calculodivisoes MCDV
  on  MCDV.CALCULO = MULT.CALCULO
  and MCDV.NIVEL   = 1 

inner join  real_usuarios USU
  on  USU.COD_USUARIO = MULT.COD_USUARIO
  and USU.CORRETOR    = MCDV.DIVISAO
  AND USU.INICIOVIGENCIA =
            (
               select  max(RC1.INICIOVIGENCIA)
               from real_usuarios RC1
               where RC1.COD_USUARIO = MULT.COD_USUARIO
                 AND RC1.CORRETOR    = MCDV.DIVISAO
            )

left join TABELA_CLIENTES cli
  on  mult.cliente = cli.cliente


inner join TABELA_VEICULOFABRIC FAB
  on  mult.fabricante = fab.fabricante

inner join TABELA_VEICULOMODELO MODELO
  on  mult.modelo = modelo.modelo

left join REAL_DEPARAFIPE RD
  on  MULT.FABRICANTE = RD.CD_FAB_REAL
  and MULT.MODELO = RD.CD_MOD_REAL

left join MULT_CALCULOCOB COB_OBS
  on  MULT.CALCULO = COB_OBS.CALCULO
  AND COB_OBS.COBERTURA = 70

left join MULT_CALCULOCOB COB_DES
  on  MULT.CALCULO = COB_DES.CALCULO
  and COB_DES.COBERTURA = 994

left join VW_TABRG_P10_T24 VW
  on  MULT.VALORBASE = VW.CHAVE1

left join VW_TABRG_P10_T1 VWT1
  on  VWT1.CHAVE1 = 2

left join VW_TABRG_P10_T23 V
  on COB_DES.OPCAO = V.CHAVE1

left join vw_tabrg_p10_t80 vw_franq
  ON  vw_franq.Tipo_Franquia = Mult.Tipo_Franquia
  AND vw_franq.MVersao = Mult.MVersao

inner join MULT_CALCULOPREMIOS MP
  on  MULT.CALCULO = MP.CALCULO
  AND MP.PREMIO_LIQUIDO <> 0
  AND MP.PRODUTO = NVL(MULT.PADRAO,10)
  AND ((MULT.MODALIDADE = 'A' AND MP.TIPOCOTACAO = 1) OR
      (MULT.MODALIDADE = 'D' AND MP.TIPOCOTACAO = 2))

inner join MULT_CALCULOCONDPAR CP
  on  MULT.CALCULO = CP.CALCULO
  AND CP.PARCELAS = 1
  AND CP.CONDICAO = MULT.CONDICAO
  AND CP.TIPOCOTACAO = MP.TIPOCOTACAO
  AND CP.FORMA_PAGAMENTO = 'F'
  AND CP.PRODUTO = NVL(MULT.PADRAO,10)

left join MULT_CALCULODIVISOES MD
  ON  MD.CALCULO = MULT.CALCULO
  AND MD.NIVEL = 2

left join TABELA_DIVISOES DIV
  ON  DIV.DIVISAO = MD.DIVISAO
  AND DIV.TIPO_DIVISAO = 'A'

left join MULT_CALCULODIVISOES MD2
  on  MULT.CALCULO = MD2.CALCULO
  AND MD2.NIVEL = 4

left join TABELA_DIVISOES DIV2
  ON  MD2.DIVISAO = DIV2.DIVISAO

left join MULT_CALCULODIVISOES MD3
  ON  MULT.CALCULO = MD3.CALCULO
  AND MD3.NIVEL = 1

left join TABELA_DIVISOES DIV3
  ON  DIV3.DIVISAO = MD3.DIVISAO

left join MULT_CALCULOPREMIOS MP2
  on  MULT.CALCULO = MP2.CALCULO
  AND MP2.ESCOLHA = 'S'

left join MULT_CALCULOPREMIOS MP3  --join serve apenas para uso no where, trazer mÍs a mÍs
  on  MULT.CALCULO = MP3.CALCULO
  AND MP3.ESCOLHA = 'S' AND MP3.TIPOCOTACAO = 3

left join MULT_CALCULOPREMIOSCOB MPC
  ON  MULT.CALCULO  = MPC.CALCULO
  AND MPC.COBERTURA = 64
  AND ((MULT.MODALIDADE = 'A' AND MPC.TIPOCOTACAO = 1) OR
      (MULT.MODALIDADE = 'D' AND MPC.TIPOCOTACAO = 2))
  AND MPC.PRODUTO = NVL(MULT.PADRAO,10)

left join Tabela_Produtos d3
  ON  d3.produto = mp2.produto

left join MULT_CALCULOCOB COB_DESP
  ON  MULT.CALCULO = COB_DESP.CALCULO
  AND COB_DESP.COBERTURA = 54

left join MULT_CALCULOPREMIOSCOB MPC2
  ON  MPC2.CALCULO   = MULT.CALCULO
  and mpc2.cobertura = 28
  AND ((MULT.MODALIDADE = 'A' AND MPC2.TIPOCOTACAO = 1) OR
      (MULT.MODALIDADE = 'D' AND MPC2.TIPOCOTACAO = 2))
  AND MPC2.PRODUTO = NVL(MULT.PADRAO,10)


left join MULT_CALCULOPREMIOSCOB MPC3
  ON  MPC3.CALCULO   = MULT.CALCULO
  and mpc3.cobertura = 1000
  AND ((MULT.MODALIDADE = 'A' AND MPC3.TIPOCOTACAO = 1) OR
      (MULT.MODALIDADE = 'D' AND MPC3.TIPOCOTACAO = 2))
  AND MPC3.PRODUTO = NVL(MULT.PADRAO,10)

left join MULT_CALCULOPREMIOSCOB MPC4
  ON  MPC4.CALCULO   = MULT.CALCULO
  and mpc4.cobertura = 1001
  AND ((MULT.MODALIDADE = 'A' AND MPC4.TIPOCOTACAO = 1) OR
      (MULT.MODALIDADE = 'D' AND MPC4.TIPOCOTACAO = 2))
  AND MPC4.PRODUTO = NVL(MULT.PADRAO,10)

left join MULT_CALCULOCOB COB_CAR_RES
  ON  COB_CAR_RES.CALCULO   = MULT.CALCULO
  AND COB_CAR_RES.COBERTURA = 1001

left join MULT_CALCULOCOB COB_CAR_RES_DESC
  ON  COB_CAR_RES_DESC.CALCULO   = MULT.CALCULO
  AND COB_CAR_RES_DESC.COBERTURA = 945
  AND COB_CAR_RES_DESC.CONDUTOR  = 0

left join MULT_CALCULOCOB COB_VIDROS
  ON  COB_VIDROS.CALCULO   = MULT.CALCULO
  AND COB_VIDROS.COBERTURA = 40

left join MULT_CALCULOQBR QBR
  ON  QBR.CALCULO  = MULT.CALCULO
  AND QBR.QUESTAO  = 87
left join MULT_CALCULOQBR QBR2
  ON  QBR2.CALCULO = MULT.CALCULO
  AND QBR2.QUESTAO = 243
  AND QBR2.VALIDA = 'S'

left join REAL_CORRETORES RC
  ON  RC.CORRETOR = DIV3.DIVISAO_SUPERIOR

left join MULT_PRODUTOSCOBPEROPC PER
  ON  PER.OPCAO     = COB_CAR_RES_DESC.OPCAO
  AND PER.PRODUTO        = 10
  AND PER.COBERTURA = 945

left join MULT_PRODUTOSQBRDISPSEG DISP
  ON  DISP.PRODUTO  = 10
  AND DISP.VIGENCIA = 1
  AND DISP.DISPOSITIVO = QBR2.SUBRESPOSTA

left join mult_calculodivisoes mdref
  ON  mdref.calculo  = mult.calculo
  and mdref.nivel    = 4

left join mult_calculodivisoes mdref2
  ON  mdref2.calculo  = mult.calculo
  and mdref2.nivel    = 1

left join tabela_divisoescomer div_com
  ON  div_com.divisao = mdref.Divisao
  and div_com.divisaoCom = mdref2.Divisao
  and div_com.produto = 10

left join MULT_CALCULOQBR T2
  ON  T2.CALCULO = MULT.CALCULO
  AND T2.ITEM    = MULT.ITEM
  AND T2.QUESTAO = 243

left join REAL_COTASAUTO D
  ON  D.COD_MODELO = MULT.MODELO
  AND D.ANO_MODELO = 9999
  AND D.COMBUSTIVEL = MULT.PROCEDENCIA
	and D.ic_zero_km  = mult.zerokm
	AND mult.iniciovigencia BETWEEN D.dt_inico_vigen and D.dt_fim_vigen

left join TABELA_VEICULOMODELO D1
  ON  D1.MODELO = MULT.MODELO

left join REAL_COTASAUTO DR
  ON  DR.COD_MODELO  = MULT.MODELO
  AND DR.ANO_MODELO  = MULT.ANOMODELO
  AND DR.COMBUSTIVEL = MULT.PROCEDENCIA
  AND ((MULT.COD_TABELA = '1' AND DR.TIPO_TABELA = 'F') OR
       (MULT.COD_TABELA = '2' AND DR.TIPO_TABELA = 'R'))
	and DR.ic_zero_km  = mult.zerokm
	AND mult.iniciovigencia BETWEEN DR.dt_inico_vigen and D.dt_fim_vigen			 

left join mult_calculocob PRIMEIO_SINISTRO
  on  PRIMEIO_SINISTRO.CALCULO   = MULT.CALCULO
  AND PRIMEIO_SINISTRO.COBERTURA = 947

left join MULT_PRODUTOSCOBPEROPC PRIMEIO_SINISTRO_DESC
  on PRIMEIO_SINISTRO_DESC.COBERTURA = 947
  AND PRIMEIO_SINISTRO_DESC.PRODUTO = 10
  AND PRIMEIO_SINISTRO_DESC.OPCAO = PRIMEIO_SINISTRO.OPCAO

left join mult_calculocob KM_ADICIONAL
  on  KM_ADICIONAL.CALCULO   = MULT.CALCULO
  AND KM_ADICIONAL.COBERTURA = 946

left join MULT_PRODUTOSCOBPEROPC KM_ADICIONAL_DESC
  on  KM_ADICIONAL_DESC.COBERTURA = 946
  AND KM_ADICIONAL_DESC.PRODUTO = 10
  AND KM_ADICIONAL_DESC.OPCAO = KM_ADICIONAL.OPCAO

left join mult_calculocob AR_DIRECAO
  on  AR_DIRECAO.CALCULO   = MULT.CALCULO
  AND AR_DIRECAO.COBERTURA = 997

left join MULT_PRODUTOSCOBPEROPC AR_DIRECAO_DESC
  ON AR_DIRECAO_DESC.COBERTURA = 997
  AND AR_DIRECAO_DESC.PRODUTO = 10
  AND AR_DIRECAO_DESC.OPCAO = AR_DIRECAO.OPCAO

left join mult_calculocob OFICINA_REFERENCIADA
  on  OFICINA_REFERENCIADA.CALCULO   = MULT.CALCULO
  AND OFICINA_REFERENCIADA.COBERTURA = 994

left join MULT_PRODUTOSCOBPEROPC OFICINA_REFERENCIADA_DESC
  ON OFICINA_REFERENCIADA_DESC.COBERTURA = 994
  AND OFICINA_REFERENCIADA_DESC.PRODUTO = 10
  AND OFICINA_REFERENCIADA_DESC.OPCAO = OFICINA_REFERENCIADA.OPCAO

inner join mult_produtos produtos
on NVL(mult.padrao,10) = produtos.produto

inner join real_anosauto aa	on aa.modelo = mult.modelo
	and aa.anode = mult.anomodelo
	
inner join mult_produtostabrg tabrg on tabrg.chave2 = aa.codigo_combustivel
	and tabrg.produto = 10
	and tabrg.tabela = 112
	and mult.iniciovigencia between tabrg.dt_inico_vigen and tabrg.dt_fim_vigen

where MULT.CALCULO = PCALCULO;
end;
/


CREATE OR REPLACE procedure prc_gera_imp_proposta (pcalculo      in  number,
                                                   pcampo        out types.cursor_type)is
begin
  open pcampo for
                 select mult.calculo,
                        mult.nome as proponente,
                        mult.dataversao,
                        mult.site,
                        cli.cgc_cpf,
                        cli.tipo_pessoa,
                        cliend.endereco,
                        cliend.tipologradouro,
                        cliend.numero,
                        cliend.complemento,
                        cliend.bairro,
                        cliend.cidade,
                        cliend.estado,
                        cliend.cep as cep_cliente,
                        tel_res.ddd,
                        tel_res.telefone as tel_residencia,
                        tel_cel.ddd      as ddd_cel,
                        tel_cel.telefone as tel_celular,
                        cli.e_mail,
                        cli.home_page,
                        cli.data_nascimento,
                        cli.sexo,
                        cli.cartao,
                        cli.bandeira,
                        cli.data_inicio,
                        div4.cod_conv as ag_captadora,
                        div5.cod_conv as ag_cobradora,
                        mult.iniciovigencia,
                        mult.finalvigencia,
                        mult.tipo_cobertura,
                        case when mult.iniciovigencia < produtos.validade then 2 else 1 end versao,
                        mp.tipocotacao,
                        mult.cep as cep_pernoite,
                        mult.datacalculo,
                        fab.nome         as fabricante,
                        modelo.descricao as modelo,
                        modelo.categ_tar1,
                        tabrg2.Texto as DescrCategoria,
                        mult.anofabricacao,
                        mult.anomodelo,
                        mult.placa,
                        mult.chassi,
                        mult.bairro as cor,
                        modelo.numpassageiros,
                        mult.procedencia,
                        vw.texto            as categoria,
                        mult.zerokm,
                        mult.numdependentes as nf,
                        mult.numero         as km_atual,
                        mult.observacao     as data_km,
                        vw_franq.franquia,
                        mpc5.franquia     as valor_franquia,
                        mult.cod_referencia as desconto,
                        v.valor             as desc_modulo,
                        mult.nivelbonusauto,
                        cob.opcao,
                        div2.divisao_superior,
                        div2.nome as estipulante,
                        qbr.descricaoresposta,
                        cob_obs.observacao,
                        rd.cd_fipe,
                        trg.texto      as congenere,
                        mult.campo1    as apolice_renovada,
                        mult.campo2    as vencimento,
                        mult.campo5    as ci,
                        mp.tipocotacao as verifica_obs_ajustado,--retirado do case
                        mp.observacao  as obs_ajustado,
                        mp.premio_auto as valor_ajustado,
                        mult.niveldm,
                        mp.premio_dm,
                        mult.niveldp,
                        mp.premio_dp,
                        mult.valorappdmh,
                        mpc.premio,
                        mult.valorappmorte,
                        mp.premio_app_morte,
                        mp.premio_app_invalidez,
                        mult.valorveiculo as vl_veic_calc,
                        vwt1.valor,
                        mpc3.premio as premio_extra,
                        mpc4.premio as vl_premio_car_res,
                        mp.premio_acessorios,
                        cob_vidros.opcao as vidros_opcao,
                        mpc2.premio as vl_premio_vidros,
                        mult.estado as servicos,
                        mp.premio_liquido,
                        ((valor_primeira + (valor_demais * (parcelas - 1)))/1.0738) - mp.premio_liquido as juros,
                        div3.divisao_superior as corretora,
                        div3.nome             as nome_corretora,
                        rc.ddd                as ddd_corretora,
                        CASE  WHEN    div3.divisao_superior    =  98626  or div3.divisao_superior    =  88626
                            THEN   '0800 727 2900'
                            ELSE    '(' ||rc.ddd|| ')'||substr(rc.telefone,1,4)||'-'||substr(rc.telefone,5,4)
                        END AS fone_corretora,
                        case when mult.iniciovigencia < produtos.validade then
                          produtos.banco_veic
                        else
                          produtos.versao
                        end versaocalculo,
                        --ace.valor  + mult.lmi_kitgas + mult.lmi_blindagem as vl_acessorios, old
                        ace.valor                  as vl_acessorios,
                        kitgas.valor               as vl_cobertura_kitgas,
                        nvl( kitgas.premio, 0 )    as vl_premio_kitgas,
                        blindagem.valor            as vl_cobertura_blindagem,
                        nvl( blindagem.premio, 0 ) as vl_premio_blindagem,
                        td.descricao               as desc_tip_doc,
                        mult.cidade                as data_saida,
                        cob_des.opcao              as opcao_des,
                        div_com.desconto           as desconto_ref,
                        div_com.pro_labore         as prolabore_ref,
                        mult.o_ct_ids_,
                        t2.subresposta2,
                        mult.cod_referencia,
                        round(mp2.descontocomissao,2) as descontocomissao,
                        mult.comissao,
						case when mult.padrao = 42 and kauto.TP_DIARI_CLSCO = 1 then '7 di√°rias'
						     when mult.padrao = 42 and kauto.TP_DIARI_CLSCO = 2 then '15 di√°rias'
							 when mult.padrao = 42 and kauto.TP_DIARI_CLSCO = 3 then '30 di√°rias'
							 when mult.padrao = 42 then '7 di√°rias'
                        else per.descricao   end           as carroreserva,
                        ((valor_primeira + (valor_demais * (parcelas - 1))) - (valor_primeira + (valor_demais * (parcelas - 1)))/1.0738) as iof,
                        (valor_primeira  + (valor_demais * (parcelas - 1))) as premio_total,
                        per2.opcao                   as tipo_cartao,
                        cob_conta.observacao         as conta,
                        cob_agencia.observacao       as agencia,
                        cob_nomeagencia.observacao   as nomeagencia,
                        cob_cidadeagencia.observacao as cidadeagencia,
                        per2.descricao               as cobranca,
                        cob_dia.valor                as dia,
                        valor_primeira,
                        valor_demais,
                        parcelas,
                        mult.estcvcondu,
                        mult.sexocondu,
                        mult.dtnascondu,
                        mult.lmi_kitgas,
                        mult.lmi_blindagem,
                        mult.tipousoveic,
                        mult.nomecondu,
                        mult.cpfcondu,
                        mult.cnhcondu,
                        mult.valorbase,
                        mult.cidade as data_mult,
                        mult.ciarenova,
                        qbr2.descricaosubresposta as dispositivo,
                        qbr3.descricaosubresposta2,
                        qbr3.descricaosubresposta,
                        qbr3.resposta2,
                        qbr3.subresposta,
                        qbr3.descricaoresposta2,
                        prod_disp.tipo as prod_disp,
                        mp.observacao  as obs_cobertura,
                        mult.calculoorigem,
                        cob_op.escolha,
                        qbr.resposta,
                        cp.condicao,
                        cp.forma_pagamento,
                        mult.datavencimento,
                        cob_dv.observacao  as obs_dv,
                        cob_dv2.observacao as obs_dv2,
                        mult.dv,
                        mult.numerotitulo,
                        --mult.mversao,
                        mult.cidade as dt_saida_veic,
                        mult.ids_aceitacao,
                        mult.tipodocumento,
                        mult.desc_score,
                        mult.tipo_desc_score,
                        mult.retornocrivo,
                        mult.situacao,
                        mult.dataemissao,
                        mult.datatransmissao,
                        mult.valor_custo_emissao,
                        mult.validado,
                        mult.iniciovigenciarenov,
                        mult.finalvigenciarenov,
                        mult.tiposeguro,
                        mult.chassirenov,
                        mult.valorveiculorenov,
                        cob_banco.opcao as banco,
                        mult.agravo,
                        p_ajuste,
                        mult.o_versaoids,
                        mult.protocolotrans,
                        mult.vistoriaprevia,
                        mult.pgto_banco_honda,
                        parentescotitular.valor as parentesco,
                        nometitular.observacao as nome_parente,
                        cnpjcpftitular.observacao as cpf_parente,
                        mult.retornodecodificador,
                        mult.tipocobranca,
                        produtos.nomeproduto,
                        mult.kitgas,
                        primeio_sinistro_desc.descricao  as prim_sinistro,
                        km_adicional_desc.descricao as km_adic,
						case when mult.padrao = 42  and kauto.TP_VEICU_CLSCO = 1 then 'N√£o possui'
						    when  mult.padrao = 42   and kauto.TP_VEICU_CLSCO = 2 then '1.0'
							when  mult.padrao = 42  and kauto.TP_VEICU_CLSCO = 3 then '1.0 AR'
                            when  mult.padrao = 42  and kauto.TP_VEICU_CLSCO = 4 then '1.4/1.6 AR/DH'
							when  mult.padrao = 42 	then '1.0'
                        else ar_direcao_desc.descricao end as ar_dh,
						case when mult.padrao = 42 and kauto.TP_OFCNA_CLSCO = 1 then 'N√£o possui'
							when mult.padrao = 42 and kauto.TP_OFCNA_CLSCO =  2 then 'Oficina Livre'
							when mult.padrao = 42 and kauto.TP_OFCNA_CLSCO = 3 then 'Oficina Referenciada'
							when mult.padrao = 42 then 'Oficina Referenciada'
                        else oficina_referenciada_desc.descricao end as oficina_ref ,
                        mult.blindagem,
                        mult.padrao,
                        mult.modalidade,
                        mult.desconto_cc,
                        mult.agravo_cc,
                        mult.numeronegocioreservado,
                        mult.numeroitemreservado,
                        mult.condicoes_especiais,
                        rcota.tipo_tabela,
                        nvl(mcc.valor,0) as valorcc,
                        nvl(mcc.tipo,'d') as tipocc,
                        tabrg.texto as combustivel,
                        cfg.valor as diaspa,
												cfg2.valor as diaspanovo,
                        mult.condicoes_especiais,
                        nvl(mult.calc_pai,0) as calc_pai,
                        mcmm.isencaoprimparcela,
                        mult.tipo_oferta,
    				          	ids.cod_batente,
					            	panova.opcao,
                        mult.diapagtorenov as databoa,
                        wsc.cd_oprdr_callo,
                        kauto.cd_chassi_rmarc,
                        apSomDvd.valor vl_SomDvd,
                        apSomDvd.premio pr_SomDvd,
						apSomDvd.franquia frq_SomDvd,
                        kAutoFalaSimi.valor vl_FalaSimi,
                        kAutoFalaSimi.premio pr_FalaSimi,
						kAutoFalaSimi.franquia frq_FalaSimi,
                        ApSom.valor vl_ApSom,
                        ApSom.premio pr_ApSom,
						ApSom.franquia frq_ApSom,
						ApOutros.valor vl_ApOutros,
						ApOutros.premio pr_ApOutros,
						ApOutros.franquia frq_ApOutros,
            dvcorrf.divisao_superior DivCorrF

                    from mult_calculo mult

                    left join mult_calculocorretor mcorrf  on  mcorrf.calculo = mult.calculo

                    left join tabela_divisoes dvcorrf  on  dvcorrf.divisao = mcorrf.corretor2 and dvcorrf.tipo_divisao = 'E'

                    left join  (select calculo, nvl(sum(valor),0) as valor
                                  from   mult_calculoaces
                                 where  valor > 0
                                 group by calculo) ace on ace.calculo = mult.calculo

                    left join mult_calculocob cob  on  cob.calculo = mult.calculo and cob.cobertura = 997

								    left join mult_calculocob cob_dv on cob_dv.calculo = mult.calculo and cob_dv.cobertura = 1027

                    left join mult_calculocob cob_dv2 on cob_dv2.calculo = mult.calculo and cob_dv2.cobertura = 1008

                    left join mult_calculocob cob_obs on cob_obs.calculo = mult.calculo and cob_obs.cobertura = 70

                    left join mult_calculocob cob_banco on  cob_banco.calculo  = mult.calculo
                                                       and cob_banco.cobertura = 957

                    left join mult_calculocob parentescotitular on parentescotitular.calculo   = mult.calculo
                                                               and parentescotitular.cobertura = 991

                    left join mult_calculocob nometitular on  nometitular.calculo  = mult.calculo
                                                         and nometitular.cobertura = 992

                    left join mult_calculocob cnpjcpftitular on cnpjcpftitular.calculo   = mult.calculo
                                                            and cnpjcpftitular.cobertura = 993

                    left join mult_calculocob cob_conta on cob_conta.calculo   = mult.calculo
                                                       and cob_conta.cobertura = 959

                    left join mult_calculocob cob_cartao on cob_cartao.calculo    = mult.calculo
                                                        and cob_cartao.cobertura  = 960
                                                        and cob_cartao.condutor   = 0

                    left join mult_calculocob cob_agencia on cob_agencia.calculo   = mult.calculo
                                                         and cob_agencia.cobertura = 958
                                                         and cob_agencia.condutor  = 0

                    left join mult_calculocob cob_nomeagencia on cob_nomeagencia.calculo   = mult.calculo
                                                             and cob_nomeagencia.cobertura = 940
                                                             and cob_nomeagencia.condutor  = 0

                    left join mult_calculocob cob_cidadeagencia on cob_cidadeagencia.calculo   = mult.calculo
                                                               and cob_cidadeagencia.cobertura = 941
                                                               and cob_cidadeagencia.condutor  = 0

                    left join mult_calculocob cob_dia on cob_dia.calculo   = mult.calculo
                                                     and cob_dia.cobertura = 987
                                                     and cob_dia.condutor  = 0

                    left join mult_calculocondPar cp on cp.calculo = mult.calculo
                                                    AND cp.escolha = 'S'
                                                    AND (((cp.Forma_Pagamento = 'F' and cob_cartao.opcao = 1) or  /*Forma de Pagamento*/
                                                         (cp.Forma_Pagamento = 'D' and cob_cartao.opcao = 2)))

                    left join real_deparafipe rd on rd.cd_fab_real = mult.fabricante
                                                and rd.cd_mod_real = mult.modelo

                    left join tabela_veiculofabric fab on  fab.fabricante = mult.fabricante

                    left join tabela_veiculomodelo modelo on  modelo.modelo = mult.modelo

                    inner join mult_produtos produtos on mult.padrao = produtos.produto

                    left join vw_tabrg_p10_t80 vw_franq on vw_franq.tipo_franquia = mult.tipo_franquia

                    left join mult_calculopremios mp on mp.calculo = mult.calculo
                                                    AND mp.escolha = 'S'

                    left join mult_calculopremios mp1 on MP1.CALCULO = mult.CALCULO
                                                     AND MP1.ESCOLHA = 'S'

                    left join mult_calculopremios mp2 on MP2.CALCULO = MULT.CALCULO
                                                     AND MP2.ESCOLHA = 'S'

                    left join mult_calculopremioscob mpc on mpc.calculo     = mult.calculo
                                                        and mpc.cobertura   = 64
                                                        and mpc.produto     = mp1.produto
                                                        and mpc.tipocotacao = mp1.tipocotacao

                    left join mult_calculocob cob_desp on cob_desp.calculo   = mult.calculo
                                                      and cob_desp.cobertura = 54

                    left join mult_calculocob cob_des on cob_des.calculo   = mult.calculo
                                                     and cob_des.cobertura = 994

                    left join vw_tabrg_p10_t23 v on  v.chave1 = cob_des.opcao

                    left join vw_tabrg_p10_t24 vw on  vw.chave1 = mult.valorbase

                    left join mult_calculodivisoes md on md.calculo = mult.calculo
                                                     and md.nivel   = 2

                    left join mult_calculodivisoes md2 on md2.calculo = mult.calculo
                                                      and md2.nivel   = 4

                    left join mult_calculodivisoes md3 on md3.calculo = mult.calculo
                                                      and md3.nivel   = 1

                    left join mult_calculodivisoes md4 on md4.calculo = mult.calculo
                                                      and md4.nivel   = 2

                    left join mult_calculodivisoes md5 on md5.calculo = mult.calculo
                                                      and md5.nivel   = 3

                    left join mult_calculopremioscob mpc2 on mpc2.calculo     = mult.calculo
                                                         and mpc2.cobertura   = 28
                                                         and mpc2.produto     = mp1.produto
                                                         and mpc2.tipocotacao = mp1.tipocotacao

                    left join mult_calculopremioscob mpc3 on mpc3.calculo     = mult.calculo
                                                         and mpc3.cobertura   = 1000
                                                         and mpc3.produto     = mp1.produto
                                                         and mpc3.tipocotacao = mp1.tipocotacao

                    left join mult_calculopremioscob mpc4 on mpc4.calculo     = mult.calculo
                                                         and mpc4.cobertura   = 1001
                                                         and mpc4.produto     = mp1.produto
                                                         and mpc4.tipocotacao = mp1.tipocotacao
					left join mult_calculopremioscob mpc5 on mpc5.calculo     = mult.calculo
                                                        and mpc5.cobertura   = 1
                                                        and mpc5.produto     = mp1.produto
                                                        and mpc5.tipocotacao = mp1.tipocotacao

                    left join mult_calculocob cob_car_res on cob_car_res.calculo   = mult.calculo
                                                         and cob_car_res.cobertura = 1001

                    left join mult_calculocob cob_vidros on cob_vidros.calculo   = mult.calculo
                                                        and cob_vidros.cobertura = 40

                    left join vw_tabrg_p10_t1 vwt1 on  vwt1.chave1 = 2

                    left join tabela_divisoes div on div.divisao      = md.divisao
                                                 AND div.tipo_divisao = 'A'

                    left join tabela_divisoes div2 on  div2.divisao = md2.divisao

                    left join tabela_divisoes div3 on  div3.divisao = md3.divisao

                    left join tabela_divisoes div4 on div4.divisao = md4.divisao

                    left join tabela_divisoes div5 on div5.divisao = md5.divisao

                    left join mult_calculoqbr qbr on qbr.calculo = mult.calculo
                                                 and qbr.questao = 87

                    left join real_corretores rc on  rc.corretor = div3.divisao_superior

                    left join tabela_clientes cli on  mult.cliente = cli.cliente

                    left join tabela_clientender cliend on cliend.cliente  = cli.cliente
                                                       and cliend.endereco is not null

                    left join tabela_clientfones tel_res on tel_res.cliente      = cli.cliente
                                                        and tel_res.cliente_fone = 1

                    left join tabela_clientfones tel_cel on tel_cel.cliente      = cli.cliente
                                                        and tel_cel.cliente_fone = 4

                    left join mult_calculoqbr qbr2 on qbr2.calculo = mult.calculo
                                                  and qbr2.questao = 243

                    left join mult_calculoqbr qbr3 on qbr3.calculo = mult.calculo
                                                  and qbr3.questao = 243


                    left join mult_produtostabrg trg on trg.valor   = mult.ciarenova
                                                    and trg.produto = 0

                    left join real_tipodoc td on td.tipo = cli.foto

                    left join mult_calculodivisoes mdref on mdref.calculo = mult.calculo
                                                        and mdref.nivel   = 4

                    left join mult_calculodivisoes mdref2 on mdref.calculo = mdref2.calculo
                                                         and mdref2.nivel  = 1

                    left join tabela_divisoescomer div_com on div_com.divisao    = mdref.divisao
                                                          and div_com.divisaocom = mdref2.divisao
                                                          and div_com.produto    = 10
                                                          and mult.dataversao between div_com.iniciovigencia and div_com.finalvigencia -- saf37636

                    left join mult_calculoqbr t2 on t2.calculo = mult.calculo
                                                and t2.item    = mult.item
                                                and t2.questao = 243

                    left join tabela_produtos d3 on d3.produto = mp2.produto

                    left join mult_calculocob cob_car_res_desc on cob_car_res_desc.calculo   = mult.calculo
                                                              and cob_car_res_desc.cobertura = 945
                                                              and cob_car_res_desc.condutor  = 0

                    left join mult_produtoscobperopc per on per.opcao     = cob_car_res_desc.opcao
                                                        and per.produto   = 10
                                                        and per.cobertura = 945

                    left join mult_produtoscobperopc per2 on per2.cobertura = cob_cartao.cobertura
                                                         and per2.opcao     = cob_cartao.opcao
                                                         and per2.produto   = 10

                    left join mult_produtosqbrdispseg prod_disp on prod_disp.dispositivo = qbr3.subresposta
                                                               and prod_disp.produto     = 10
                                                               and prod_disp.vigencia    = 1

                    left join mult_calculocobop cob_op on cob_op.calculo   = mult.calculo
                                                      and cob_op.item      = 0
                                                      and cob_op.cobertura = 1007

                    left join mult_calculocob primeio_sinistro on primeio_sinistro.calculo   = mult.calculo
                                                              and primeio_sinistro.cobertura = 947

                    left join mult_produtoscobperopc primeio_sinistro_desc on primeio_sinistro_desc.cobertura = 947
                                                                          and primeio_sinistro_desc.produto   = 10
                                                                          and primeio_sinistro_desc.opcao     = primeio_sinistro.opcao

                    left join mult_calculocob km_adicional on km_adicional.calculo   = mult.calculo
                                                          and km_adicional.cobertura = 946

                    left join mult_produtoscobperopc km_adicional_desc on  km_adicional_desc.cobertura = 946
                                                                      and km_adicional_desc.produto    = 10
                                                                      and km_adicional_desc.opcao      = km_adicional.opcao

                    left join mult_calculocob ar_direcao on ar_direcao.calculo   = mult.calculo
                                                        and ar_direcao.cobertura = 997

                    left join mult_produtoscobperopc ar_direcao_desc on ar_direcao_desc.cobertura = 997
                                                                    and ar_direcao_desc.produto   = 10
                                                                    and ar_direcao_desc.opcao     = ar_direcao.opcao

                    left join mult_calculocob oficina_referenciada on oficina_referenciada.calculo   = mult.calculo
                                                                  and oficina_referenciada.cobertura = 994

                    left join mult_produtoscobperopc oficina_referenciada_desc on oficina_referenciada_desc.cobertura = 994
                                                                              and oficina_referenciada_desc.produto   = 10
                                                                              and oficina_referenciada_desc.opcao     = oficina_referenciada.opcao

                    left join mult_calculopremioscob kitgas on kitgas.calculo = mult.calculo
                          and kitgas.cobertura   = 951
                          and kitgas.produto     = mult.padrao
                          and kitgas.tipocotacao = mp.tipocotacao

                    left join mult_calculopremioscob blindagem on blindagem.calculo = mult.calculo
                          and blindagem.cobertura   = 952
                          and blindagem.produto     = mult.padrao
                          and blindagem.tipocotacao = mp.tipocotacao

                    left join mult_calculocob panova on panova.cobertura = 960
                                                     and panova.calculo = mult.calculo

                    left join tabela_veiculomodelo vm on vm.modelo = mult.modelo

                    left join real_cotasauto rcota on rcota.cod_modelo   = vm.modelo
                          and rcota.cod_fabric  = vm.fabricante
                          and rcota.combustivel = vm.tipo_combustivel
                          and rcota.ano_modelo  = mult.anomodelo
                          and rcota.ic_zero_km  = mult.zerokm
                          and mult.iniciovigencia between rcota.dt_inico_vigen and rcota.dt_fim_vigen

                    left join mult_calculocontacorrente mcc on mcc.calculo = mult.calculo
                                                           and mcc.produto = mult.padrao
														   and mcc.tipocotacao = mp.tipocotacao

                    inner join real_anosauto aa	on aa.modelo           = mult.modelo
                                               and aa.anode            = mult.anomodelo
                                               and aa.tipo_combustivel = mult.procedencia

                    inner join mult_produtostabrg tabrg on tabrg.chave2  = aa.codigo_combustivel
                                                       and tabrg.produto = 10
                                                       and tabrg.tabela  = 112
                                                       and mult.iniciovigencia between tabrg.dt_inico_vigen and tabrg.dt_fim_vigen

                    inner join mult_produtostabrg tabrg2 on tabrg2.chave2  = modelo.categ_tar1
                                                         and tabrg2.produto = 10
                                                          and tabrg2.tabela  = 326

                    left join Tabela_Configuracoes_KCW cfg on cfg.Parametro = 'DIAS_PA_'||mult.Padrao||'_'||mult.TipoSeguro
                		left join Tabela_Configuracoes_KCW cfg2 on cfg2.Parametro = 'DIAS_PA_'||mult.Padrao||'_'||mult.TipoSeguro||'_'||PANOVA.OPCAO||'_'||mult.tipocobranca||'_NOVO'
                    left join mult_calculorenovacaoMM mcmm on mcmm.calculo = mult.calculo
                    left join mult_calculoids ids on ids.calculo = mult.calculo and mult.padrao = ids.produto and mp.tipocotacao = ids.tipo_cotacao -- SAF38104

					left join kit0004_mtcal_ws wsc on wsc.nr_callo = mult.calculo
					left join kit0001_mtcal_auto kauto on kauto.nr_callo = mult.calculo

          left join mult_calculopremioscob apSomDvd on apSomDvd.calculo = mult.calculo
                                                    and apSomDvd.cobertura = 321
													and apSomDvd.produto     = mp1.produto
                                                    and apSomDvd.tipocotacao = mp1.tipocotacao

          left join mult_calculopremioscob kAutoFalaSimi on kAutoFalaSimi.calculo = mult.calculo
                                                         and kAutoFalaSimi.cobertura = 322
                                                         and kAutoFalaSimi.produto     = mp1.produto
                                                         and kAutoFalaSimi.tipocotacao = mp1.tipocotacao

          left join mult_calculopremioscob ApSom on ApSom.calculo = mult.calculo
                                                 and ApSom.cobertura = 320
												 and ApSom.produto     = mp1.produto
                                                 and ApSom.tipocotacao = mp1.tipocotacao
          left join mult_calculopremioscob ApOutros on ApOutros.calculo = mult.calculo
                                                 and ApOutros.cobertura = 323
                                                 and ApOutros.produto     = mp1.produto
                                                 and ApOutros.tipocotacao = mp1.tipocotacao
                    where mult.calculo = pcalculo
                      and mult.item = 0
                      and substr(tabrg.texto, 1,1)  = mult.procedencia
                      and rownum = 1;


end;
/


CREATE OR REPLACE PROCEDURE "PRC_HONDA_CANAL_VENDAS" (p_dt_inicial in varchar2,
                                  p_dt_final in varchar2,
                                  p_resultado OUT TYPES.CURSOR_TYPE) AS
BEGIN
IF(p_dt_inicial = p_dt_final) then
    OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      --C.ZEROKM as ZEROKM,
      COUNT (C.CALCULO) AS QTD_ITENS,
      SUM(R.VALOR_PRIMEIRA + ((R.PARCELAS - 1)* R.VALOR_DEMAIS)) AS PREMIO_TOTAL
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
      INNER JOIN MULT_CALCULOCONDPAR R
      ON (R.CALCULO = C.CALCULO) AND
        (R.ESCOLHA = 'S')
      INNER JOIN MULT_CALCULOPREMIOS P
      ON (P.CALCULO = R.CALCULO) AND
         (P.TIPOCOTACAO = R.TIPOCOTACAO)
    WHERE
      C.DATACALCULO LIKE TO_DATE(p_dt_inicial,'DD/MM/YY') AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO = 'T' AND
      E.NIVEL = 4
      group by D.NOME;
ELSE
OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
     -- C.ZEROKM as ZEROKM,
      COUNT (C.CALCULO) AS QTD_ITENS,
      SUM(R.VALOR_PRIMEIRA + ((R.PARCELAS - 1)* R.VALOR_DEMAIS)) AS PREMIO_TOTAL
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
      INNER JOIN MULT_CALCULOCONDPAR R
      ON (R.CALCULO = C.CALCULO) AND
        (R.ESCOLHA = 'S')
      INNER JOIN MULT_CALCULOPREMIOS P
      ON (P.CALCULO = R.CALCULO) AND
         (P.TIPOCOTACAO = R.TIPOCOTACAO)
    WHERE
      C.DATACALCULO >= TO_DATE(p_dt_inicial,'DD/MM/YY') AND C.DATACALCULO <=  TO_DATE(p_dt_final,'DD/MM/YY') + 1 AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO = 'T' AND
      E.NIVEL = 4
      GROUP BY D.NOME;

END IF;
    exception
             when NO_DATA_FOUND then
                 DBMS_OUTPUT.PUT_LINE('Falha na execucao da procedure de carregamento do relatorio gerencial.');

END PRC_HONDA_CANAL_VENDAS;
/


CREATE OR REPLACE PROCEDURE "PRC_HONDA_NUMERO_VENDAS" (p_dt_inicial in varchar2,
                                  p_dt_final in varchar2,
                                  p_resultado OUT TYPES.CURSOR_TYPE) AS
BEGIN
IF(p_dt_inicial = p_dt_final) then
    OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      --C.ZEROKM as ZEROKM,
      COUNT (C.CALCULO) AS QTD_ITENS
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
    WHERE
      C.DATACALCULO LIKE TO_DATE(p_dt_inicial,'DD/MM/YY') AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO in ('C','E','T') AND
      E.NIVEL = 4
      GROUP BY D.NOME;
ELSE
    OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      --C.ZEROKM as ZEROKM,
      COUNT (C.CALCULO) AS QTD_ITENS
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
    WHERE
      C.DATACALCULO >= TO_DATE(p_dt_inicial,'DD/MM/YY') AND C.DATACALCULO <=  TO_DATE(p_dt_final,'DD/MM/YY') + 1 AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO IN ('C','E','T') AND
      E.NIVEL = 4
      GROUP BY D.NOME;
END IF;
    exception
             when NO_DATA_FOUND then
                 DBMS_OUTPUT.PUT_LINE('Falha na execucao da procedure de carregamento do relatorio Gerencial.');

END PRC_HONDA_NUMERO_VENDAS;
/


CREATE OR REPLACE PROCEDURE prc_ids(
    P_CALCULO IN MULT_CALCULO.CALCULO%TYPE,
    P_RESULTADO OUT TYPES.CURSOR_TYPE)
AS
BEGIN
  DECLARE
    CURSOR c_IDS
    IS
      SELECT calc.Calculo,
        Corr.Divisao_Superior Corretor,
        Corr.Divisao DivisaoCorretor,
        Estip.Divisao_Superior Estipulante,
        Estip.Divisao DivisaoEstipulante,
        calc.RetornoCrivo,
        calc.InicioVigencia,
        calc.FinalVigencia,
        calc.Tipo_Cobertura,
        Calc.Pgto_Banco_Honda,
        CASE
          WHEN (calc.FinalVigencia - calc.InicioVigencia) < 365
          THEN 'S'
          ELSE 'N'
        END PrazoCurto,
        calc.Procedencia,
        calc.Cep,
        calc.Tipo_Pessoa,
        calc.AnoFabricacao,
        calc.AnoModelo,
        calc.Lmi_Blindagem,
        calc.Lmi_KitGas,
        calc.Comissao,
        calc.ZeroKM,
        calc.cidade DataSaidaZeroKM,
        calc.Chassi,
        calc.Placa,
        calc.Bairro CorVeiculo,
        calc.Campo1 NumApoliceCongenere,
        calc.Campo2 VencApoliceCongenere,
        calc.Campo4 SucursalCongenere,
        calc.Campo3 NumItemCongenere,
        calc.Cod_Referencia Desconto,
        calc.Agravo,
        calc.P_Ajuste,
        calc.nivelbonusauto,
        calc.Bonus_Interno,
        calc.TipoSeguro,
        calc.CalculoOrigem,
        CASE
          WHEN calc.TipoSeguro IN (2,4)
          THEN 'S'
          ELSE 'N'
        END Sinistro,
        CASE
          WHEN calc.CalculoOrigem > 0
          THEN 'R'
          WHEN calc.TipoSeguro = 1
          THEN 'P'
          WHEN calc.TipoSeguro IN (2,3)
          THEN 'C'
          WHEN calc.TipoSeguro IN (4,5)
          THEN 'M'
        END TipoNegocio,
        calc.TipoUsoVeic,
        calc.ValorBase,
        calc.numpassag numpassageiros,
        calc.dtnascondu,
        calc.estcvcondu,
        calc.sexocondu,
        calc.Cod_Tabela,
        calc.Tipo_Franquia,
        NVL(calc.Estado,'N') Assist24H,
        NVL(calc.ValorAss24H,0) ValorAss24H,
        calc.CiaRenova,
        calc.Cod_Cidade,
        calc.ValorVeiculo,
        calc.niveldm,
        calc.niveldp,
        calc.valorappmorte,
        calc.valorappdmh,
        calc.desconto_cc,
        calc.agravo_cc,
        calc.Fabricante,
        Fabr.Nome DescFabricante,
        calc.Modelo,
        Model.Descricao DescModelo,
        TipVeic.Valor TipoVeiculo,
        TipVeicCarg.Valor TipoVeiculoCarga,
        TipVeic.Texto DescTipoVeic,
        TipVeicCarg.Texto DescTipoVeicCarga,
        Vidros.Opcao OpcVidros,
        CarReser.Opcao CarroReserva,
        TipoCarReser.Opcao TipoCarroReserva,
        TipOfic.Opcao TipoOficina,
        TipKMAdic.Opcao KmAdicional,
        Qbr.Grupo,
        Qbr.Resposta,
        Qbr.Resposta2,
        Qbr.DescricaoResposta2,
        Qbr.SubResposta,
        Qbr.SubResposta2,
        TipDisp.Tipo TipoDispositivo,
        DespExt.Opcao DespExtra,
        PerdFat.Valor PerdaFaturamento,
        Prod.Validade,
        CASE
          WHEN PrimSinis.Opcao = 1
          THEN 'S'
          ELSE 'N'
        END PrimeiroSinisIndeniz,
        Model.Tp_Vidro,
        Model.Categ_Tar1 Categoriatarifaria,
        CASE
          WHEN Calc.Padrao IN(11,14,15)
          THEN
            (SELECT texto
            FROM Mult_Produtostabrg tabrg
            WHERE tabrg.Produto = 11
            AND chave2          = model.Categ_Tar1
            AND tabela          = 330
            )
        ELSE
          (SELECT Texto
          FROM Mult_Produtostabrg Tabrg
          WHERE Tabrg.Produto = 10
          AND Chave2          = Model.Categ_Tar1
          AND Tabela          = 326
          )
      END DescCategoriatarifaria,
      calc.Tipo_Carroceria,
      calc.DataVersao,
      calc.Condicoes_Especiais,
      calc.Calc_Online,
      calc.site,
      kit1.CD_CEP_PRNOI CepPernoite,
      kit1.CD_CHASSI_RMARC ChassiRemarcado,
      kit1.CD_QURTO_EIXO QuartoEixoAdapt,
      kit1.CD_CARGA_DSCRG CargaDescarga,
      CASE kit1.CD_CARGA_DSCRG
        WHEN 18667
        THEN 500 --Contratada
        WHEN 18668
        THEN 0 --N√£o Contratada
      END VlrCargaDescarga,
      kit1.CD_CBINE_SUPLM CabineSuplementar,
      kit1.CD_FRANQ_CRROC ISCarroceria,
      kit1.CD_KM_ADCNL KmAdicionalCaminhao,
      kit1.VL_IS_UNIDD_FRIGO VlrUnidFrig,
      kit1.VL_IS_GUNCH VlrGuinchoE,
      kit1.VL_IS_ELEVD_PLATF_CARGA VlrElevador,
      kit1.VL_IS_GUND_MUNCK VlrGuindast,
      kit1.VL_IS_UNIDD_REFRG VlrUnidRefr,
      kit1.VL_IS_ROLON_ROLOF VlrRollOnOf,
      kit1.VL_IS_KIT_BASCL VlrKitBascu,
      kit1.VL_IS_OUTRO_EQUIP_CARGA VlrOutrosEq,
      kit1.VL_IS_APRLH_SOM VlrApareSom,
      kit1.VL_IS_APRLH_SOM_DVD VlrApareDVD,
      kit1.VL_IS_ALTO_FLANT VlrKitAutoF,
      kit1.VL_IS_OUTRO_EQUIP_PSSEI VlrOutrosAc,
	  kit1.TP_OFCNA_CLSCO TipoOficinaClassico ,
	  kit1.TP_VEICU_CLSCO TipoCarroReservaClassico,
      DescKmAdic.Descricao DescKmAdicCaminhao,
      kit1.TP_DIARI_CLSCO CarroReservaClassico
    FROM Mult_Calculo Calc
    INNER JOIN Tabela_VeiculoFabric Fabr
    ON Fabr.Fabricante = Calc.Fabricante
    INNER JOIN Tabela_VeiculoModelo Model
    ON Model.Modelo = Calc.Modelo
    LEFT OUTER JOIN VW_TABRG_P10_T24 TipVeic
    ON TipVeic.chave1 = calc.ValorBase
    LEFT OUTER JOIN Vw_Tabrg_P11_T24 Tipveiccarg
    ON Tipveiccarg.Chave1  = Calc.Valorbase
    AND TipVeicCarg.chave2 = 1
    INNER JOIN Mult_Calculocob Vidros
    ON Vidros.Calculo    = Calc.Calculo
    AND Vidros.Cobertura = 40
    LEFT OUTER JOIN Mult_Calculocob Primsinis
    ON Primsinis.Calculo    = Calc.Calculo
    AND PrimSinis.Cobertura = 947
    LEFT OUTER JOIN Mult_Calculocob Carreser
    ON Carreser.Calculo    = Calc.Calculo
    AND CarReser.Cobertura = 945
    LEFT OUTER JOIN Mult_Calculocob Tipocarreser
    ON Tipocarreser.Calculo    = Calc.Calculo
    AND TipoCarReser.Cobertura = 997
    LEFT OUTER JOIN Mult_Calculocob Tipofic
    ON Tipofic.Calculo    = Calc.Calculo
    AND Tipofic.Cobertura = 994
    LEFT OUTER JOIN Mult_Calculocob Tipkmadic
    ON Tipkmadic.Calculo    = Calc.Calculo
    AND TipKMAdic.Cobertura = 946
    LEFT OUTER JOIN Mult_Calculocob Despext
    ON Despext.Calculo    = Calc.Calculo
    AND DespExt.Cobertura = 54
    LEFT OUTER JOIN Mult_Calculocob Perdfat
    ON Perdfat.Calculo     = Calc.Calculo
    AND PerdFat.Cobertura IN(46,277)
    INNER JOIN Mult_Calculodivisoes Divcor
    ON Divcor.Calculo = Calc.Calculo
    AND DivCor.Nivel  = 1
    INNER JOIN Tabela_Divisoes Corr
    ON Corr.Divisao = DivCor.Divisao
    LEFT JOIN Mult_Calculoqbr Qbr
    ON Qbr.Calculo   = Calc.Calculo
    AND (Qbr.Questao = 243
    OR Qbr.Questao   = 244)
    LEFT OUTER JOIN Mult_Produtosqbrdispseg Tipdisp
    ON Tipdisp.Resposta     = Qbr.Resposta
    AND Tipdisp.Dispositivo = Qbr.Subresposta
    AND Tipdisp.Vigencia    = 1
    LEFT OUTER JOIN Mult_Calculodivisoes Divestip
    ON Divestip.Calculo = Calc.Calculo
    AND Divestip.Nivel  = 4
    LEFT OUTER JOIN Tabela_Divisoes Estip
    ON Estip.Divisao = DivEstip.Divisao
    LEFT JOIN kit0001_mtcal_auto kit1
    ON kit1.nr_callo=calc.calculo
    LEFT JOIN Mult_ProdutosCobPerOpc DescKmAdic
    ON DescKmAdic.Cobertura = 339
    AND DescKmAdic.Opcao    = kit1.CD_KM_ADCNL
    AND (DescKmAdic.Produto = 11
    OR DescKmAdic.Produto   = Calc.Padrao)
    LEFT JOIN Tabela_ConfigGlobais ConfigGlo
    ON ConfigGlo.corretor = Corr.Divisao_superior
    and ConfigGlo.produto = calc.padrao
    INNER JOIN Mult_Produtos Prod
    ON Prod.Produto    = Calc.Padrao
    WHERE calc.calculo = P_CALCULO
	AND ROWNUM = 1;
    --
    v_calculo MULT_CALCULO.CALCULO%TYPE;
    v_corretor Tabela_Divisoes.Divisao_Superior%TYPE;
    v_DivisaoCorretor Tabela_Divisoes.Divisao%TYPE;
    v_Estipulante Tabela_Divisoes.Divisao_Superior%TYPE;
    v_DivisaoEstipulante Tabela_Divisoes.Divisao%TYPE;
    v_RetornoCrivo mult_calculo.RetornoCrivo%TYPE;
    v_InicioVigencia mult_calculo.InicioVigencia%TYPE;
    v_FinalVigencia mult_calculo.FinalVigencia%TYPE;
    v_Tipo_Cobertura mult_calculo.Tipo_Cobertura%TYPE;
    v_Pgto_Banco_Honda mult_calculo.Pgto_Banco_Honda%TYPE;
    v_PrazoCurto VARCHAR2(1);
    v_Procedencia mult_calculo.Procedencia%TYPE;
    v_Cep mult_calculo.Cep%TYPE;
    v_Tipo_Pessoa mult_calculo.Tipo_Pessoa%TYPE;
    v_AnoFabricacao mult_calculo.AnoFabricacao%TYPE;
    v_AnoModelo mult_calculo.AnoModelo%TYPE;
    v_Lmi_Blindagem mult_calculo.Lmi_Blindagem%TYPE;
    v_Lmi_KitGas mult_calculo.Lmi_KitGas%TYPE;
    v_Comissao mult_calculo.Comissao%TYPE;
    v_ZeroKM mult_calculo.ZeroKM%TYPE;
    v_DataSaidaZeroKM mult_calculo.cidade%TYPE;
    v_Chassi mult_calculo.Chassi%TYPE;
    v_Placa mult_calculo.Placa%TYPE;
    v_CorVeiculo mult_calculo.Bairro%TYPE;
    v_NumApoliceCongenere mult_calculo.Campo1%TYPE;
    v_VencApoliceCongenere mult_calculo.Campo2%TYPE;
    v_SucursalCongenere mult_calculo.Campo4%TYPE;
    v_NumItemCongenere mult_calculo.Campo3%TYPE;
    v_Desconto mult_calculo.Cod_Referencia%TYPE;
    v_Agravo mult_calculo.Agravo%TYPE;
    v_P_Ajuste mult_calculo.P_Ajuste%TYPE;
    v_nivelbonusauto mult_calculo.nivelbonusauto%TYPE;
    v_Bonus_Interno mult_calculo.Bonus_Interno%TYPE;
    v_TipoSeguro mult_calculo.TipoSeguro%TYPE;
    v_CalculoOrigem mult_calculo.CalculoOrigem%TYPE;
    v_Sinistro    VARCHAR2(1);
    v_TipoNegocio VARCHAR2(1);
    v_TipoUsoVeic mult_calculo.TipoUsoVeic%TYPE;
    v_ValorBase mult_calculo.ValorBase%TYPE;
    v_numpassageiros mult_calculo.numpassag%TYPE;
    v_dtnascondu mult_calculo.dtnascondu%TYPE;
    v_estcvcondu mult_calculo.estcvcondu%TYPE;
    v_sexocondu mult_calculo.sexocondu%TYPE;
    v_Cod_Tabela mult_calculo.Cod_Tabela%TYPE;
    v_Tipo_Franquia mult_calculo.Tipo_Franquia%TYPE;
    v_Assist24H mult_calculo.Estado%TYPE;
    v_ValorAss24H mult_calculo.ValorAss24H%TYPE;
    v_CiaRenova mult_calculo.CiaRenova%TYPE;
    v_Cod_Cidade mult_calculo.Cod_Cidade%TYPE;
    v_ValorVeiculo mult_calculo.ValorVeiculo%TYPE;
    v_niveldm mult_calculo.niveldm%TYPE;
    v_niveldp mult_calculo.niveldp%TYPE;
    v_valorappmorte mult_calculo.valorappmorte%TYPE;
    v_valorappdmh mult_calculo.valorappdmh%TYPE;
    v_desconto_cc mult_calculo.desconto_cc%TYPE;
    v_agravo_cc mult_calculo.agravo_cc%TYPE;
    v_Fabricante mult_calculo.Fabricante%TYPE;
    v_DescFabricante Tabela_VeiculoFabric.Nome%TYPE;
    v_Modelo mult_calculo.Modelo%TYPE;
    v_DescModelo Tabela_VeiculoModelo.Descricao%TYPE;
    v_TipoVeiculo VW_TABRG_P10_T24.Valor%Type;
    v_TipoVeiculoCarga Vw_Tabrg_P11_T24.Valor%Type;
    v_DescTipoVeic VW_TABRG_P10_T24.Texto%Type;
    v_DescTipoVeicCarga Vw_Tabrg_P11_T24.Texto%Type;
    v_OpcVidros Mult_Calculocob.Opcao%Type;
    v_CarroReserva Mult_Calculocob.Opcao%Type;
    v_TipoCarroReserva Mult_Calculocob.Opcao%Type;
    v_TipoOficina Mult_Calculocob.Opcao%Type;
    v_KmAdicional Mult_Calculocob.Opcao%Type;
    v_Grupo Mult_Calculoqbr.Grupo%Type;
    v_Resposta Mult_Calculoqbr.Resposta%Type;
    v_Resposta2 Mult_Calculoqbr.Resposta2%Type;
    v_DescricaoResposta2 Mult_Calculoqbr.DescricaoResposta2%Type;
    v_SubResposta Mult_Calculoqbr.SubResposta%Type;
    v_SubResposta2 Mult_Calculoqbr.SubResposta2%Type;
    v_TipoDispositivo Mult_Produtosqbrdispseg.Tipo%Type;
    v_DespExtra Mult_Calculocob.Opcao%Type;
    v_PerdaFaturamento Mult_Calculocob.Opcao%Type;
    v_Validade Mult_Produtos.Validade%Type;
    v_PrimeiroSinisIndeniz VARCHAR2(1);
    v_Tp_Vidro Tabela_VeiculoModelo.Tp_Vidro%TYPE;
    v_Categoriatarifaria Tabela_VeiculoModelo.Categ_Tar1%TYPE;
    v_DescCategoriatarifaria Mult_Produtostabrg.Texto%TYPE;
    v_Tipo_Carroceria mult_calculo.Tipo_Carroceria%TYPE;
    v_DataVersao mult_calculo.DataVersao%TYPE;
    v_Condicoes_Especiais mult_calculo.Condicoes_Especiais%TYPE;
    v_Calc_Online mult_calculo.Calc_Online%TYPE;
    v_site mult_calculo.site%TYPE;
    v_CepPernoite kit0001_mtcal_auto.CD_CEP_PRNOI%TYPE;
    v_ChassiRemarcado kit0001_mtcal_auto.CD_CHASSI_RMARC%TYPE;
    v_QuartoEixoAdapt kit0001_mtcal_auto.CD_QURTO_EIXO%TYPE;
    v_CargaDescarga kit0001_mtcal_auto.CD_CARGA_DSCRG%TYPE;
    v_VlrCargaDescarga NUMBER(15,2);
    v_CabineSuplementar kit0001_mtcal_auto.CD_CBINE_SUPLM%TYPE;
    v_ISCarroceria kit0001_mtcal_auto.CD_FRANQ_CRROC%TYPE;
    v_KmAdicionalCaminhao kit0001_mtcal_auto.CD_KM_ADCNL%TYPE;
    v_VlrUnidFrig kit0001_mtcal_auto.VL_IS_UNIDD_FRIGO%TYPE;
    v_VlrGuinchoE kit0001_mtcal_auto.VL_IS_GUNCH%TYPE;
    v_VlrElevador kit0001_mtcal_auto.VL_IS_ELEVD_PLATF_CARGA%TYPE;
    v_VlrGuindast kit0001_mtcal_auto.VL_IS_GUND_MUNCK%TYPE;
    v_VlrUnidRefr kit0001_mtcal_auto.VL_IS_UNIDD_REFRG%TYPE;
    v_VlrRollOnOf kit0001_mtcal_auto.VL_IS_ROLON_ROLOF%TYPE;
    v_VlrKitBascu kit0001_mtcal_auto.VL_IS_KIT_BASCL%TYPE;
    v_VlrOutrosEq kit0001_mtcal_auto.VL_IS_OUTRO_EQUIP_CARGA%TYPE;
    v_VlrApareSom kit0001_mtcal_auto.VL_IS_APRLH_SOM%TYPE;
    v_VlrApareDVD kit0001_mtcal_auto.VL_IS_APRLH_SOM_DVD%TYPE;
    v_VlrKitAutoF kit0001_mtcal_auto.VL_IS_ALTO_FLANT%TYPE;
    v_VlrOutrosAc kit0001_mtcal_auto.VL_IS_OUTRO_EQUIP_PSSEI%TYPE;
	v_TipoCarroReservaClassico kit0001_mtcal_auto.TP_VEICU_CLSCO%TYPE;
	v_TipoOficinaClassico kit0001_mtcal_auto.TP_OFCNA_CLSCO%TYPE;
    v_DescKmAdicCaminhao Mult_ProdutosCobPerOpc.Descricao%TYPE;
    v_CarroReservaClassico kit0001_mtcal_auto.TP_DIARI_CLSCO%TYPE;
	v_ProdutoRenovG Number;
	v_ProdutoRenovM Number;
	v_ProdutoAnterior Number;

	CURSOR c_RenovGerada IS
       SELECT produto
         FROM mult_calculobatente
        WHERE calculo = v_calculo
         AND ROWNUM = 1;

	CURSOR c_RenovManual IS
       SELECT CD_MDUPR
         FROM tb_carga_renov_mm
        WHERE CD_APOLI_SUSEP = v_NumApoliceCongenere
         AND ROWNUM = 1;
    --
  BEGIN
    FOR r_ids IN c_IDS
    LOOP
      v_calculo                := r_ids.calculo;
      v_corretor               := r_ids.corretor;
      v_DivisaoCorretor        := r_ids.DivisaoCorretor;
      v_Estipulante            := r_ids.Estipulante;
      v_DivisaoEstipulante     := r_ids.DivisaoEstipulante;
      v_RetornoCrivo           := r_ids.RetornoCrivo;
      v_InicioVigencia         := r_ids.InicioVigencia;
      v_FinalVigencia          := r_ids.FinalVigencia;
      v_Tipo_Cobertura         := r_ids.Tipo_Cobertura;
      v_Pgto_Banco_Honda       := r_ids.Pgto_Banco_Honda;
      v_PrazoCurto             := r_ids.PrazoCurto;
      v_Procedencia            := r_ids.Procedencia;
      v_Cep                    := r_ids.Cep;
      v_Tipo_Pessoa            := r_ids.Tipo_Pessoa;
      v_AnoFabricacao          := r_ids.AnoFabricacao;
      v_AnoModelo              := r_ids.AnoModelo;
      v_Lmi_Blindagem          := r_ids.Lmi_Blindagem;
      v_Lmi_KitGas             := r_ids.Lmi_KitGas;
      v_Comissao               := r_ids.Comissao;
      v_ZeroKM                 := r_ids.ZeroKM;
      v_DataSaidaZeroKM        := r_ids.DataSaidaZeroKM;
      v_Chassi                 := r_ids.Chassi;
      v_Placa                  := r_ids.Placa;
      v_CorVeiculo             := r_ids.CorVeiculo;
      v_NumApoliceCongenere    := r_ids.NumApoliceCongenere;
      v_VencApoliceCongenere   := r_ids.VencApoliceCongenere;
      v_SucursalCongenere      := r_ids.SucursalCongenere;
      v_NumItemCongenere       := r_ids.NumItemCongenere;
      v_Desconto               := r_ids.Desconto;
      v_Agravo                 := r_ids.Agravo;
      v_P_Ajuste               := r_ids.P_Ajuste;
      v_nivelbonusauto         := r_ids.nivelbonusauto;
      v_Bonus_Interno          := r_ids.Bonus_Interno;
      v_TipoSeguro             := r_ids.TipoSeguro;
      v_CalculoOrigem          := r_ids.CalculoOrigem;
      v_Sinistro               := r_ids.Sinistro;
      v_TipoNegocio            := r_ids.TipoNegocio;
      v_TipoUsoVeic            := r_ids.TipoUsoVeic;
      v_ValorBase              := r_ids.ValorBase;
      v_numpassageiros         := r_ids.numpassageiros;
      v_dtnascondu             := r_ids.dtnascondu;
      v_estcvcondu             := r_ids.estcvcondu;
      v_sexocondu              := r_ids.sexocondu;
      v_Cod_Tabela             := r_ids.Cod_Tabela;
      v_Tipo_Franquia          := r_ids.Tipo_Franquia;
      v_Assist24H              := r_ids.Assist24H;
      v_ValorAss24H            := r_ids.ValorAss24H;
      v_CiaRenova              := r_ids.CiaRenova;
      v_Cod_Cidade             := r_ids.Cod_Cidade;
      v_ValorVeiculo           := r_ids.ValorVeiculo;
      v_niveldm                := r_ids.niveldm;
      v_niveldp                := r_ids.niveldp;
      v_valorappmorte          := r_ids.valorappmorte;
      v_valorappdmh            := r_ids.valorappdmh;
      v_desconto_cc            := r_ids.desconto_cc;
      v_agravo_cc              := r_ids.agravo_cc;
      v_Fabricante             := r_ids.Fabricante;
      v_DescFabricante         := r_ids.DescFabricante;
      v_Modelo                 := r_ids.Modelo;
      v_DescModelo             := r_ids.DescModelo;
      v_TipoVeiculo            := r_ids.TipoVeiculo;
      v_TipoVeiculoCarga       := r_ids.TipoVeiculoCarga;
      v_DescTipoVeic           := r_ids.DescTipoVeic;
      v_DescTipoVeicCarga      := r_ids.DescTipoVeicCarga;
      v_OpcVidros              := r_ids.OpcVidros;
      v_CarroReserva           := r_ids.CarroReserva;
      v_TipoCarroReserva       := r_ids.TipoCarroReserva;
      v_TipoOficina            := r_ids.TipoOficina;
      v_KmAdicional            := r_ids.KmAdicional;
      v_Grupo                  := r_ids.Grupo;
      v_Resposta               := r_ids.Resposta;
      v_Resposta2              := r_ids.Resposta2;
      v_DescricaoResposta2     := r_ids.DescricaoResposta2;
      v_SubResposta            := r_ids.SubResposta;
      v_SubResposta2           := r_ids.SubResposta2;
      v_TipoDispositivo        := r_ids.TipoDispositivo;
      v_DespExtra              := r_ids.DespExtra;
      v_PerdaFaturamento       := r_ids.PerdaFaturamento;
      v_Validade               := r_ids.Validade;
      v_PrimeiroSinisIndeniz   := r_ids.PrimeiroSinisIndeniz;
      v_Tp_Vidro               := r_ids.Tp_Vidro;
      v_Categoriatarifaria     := r_ids.Categoriatarifaria;
      v_DescCategoriatarifaria := r_ids.DescCategoriatarifaria;
      v_Tipo_Carroceria        := r_ids.Tipo_Carroceria;
      v_DataVersao             := r_ids.DataVersao;
      v_Condicoes_Especiais    := r_ids.Condicoes_Especiais;
      v_Calc_Online            := r_ids.Calc_Online;
      v_site                   := r_ids.site;
      v_CepPernoite            := r_ids.CepPernoite;
      v_ChassiRemarcado        := r_ids.ChassiRemarcado;
      v_QuartoEixoAdapt        := r_ids.QuartoEixoAdapt;
      v_CargaDescarga          := r_ids.CargaDescarga;
      v_VlrCargaDescarga       := r_ids.VlrCargaDescarga;
      v_CabineSuplementar      := r_ids.CabineSuplementar;
      v_ISCarroceria           := r_ids.ISCarroceria;
      v_KmAdicionalCaminhao    := r_ids.KmAdicionalCaminhao;
      v_VlrUnidFrig            := r_ids.VlrUnidFrig;
      v_VlrGuinchoE            := r_ids.VlrGuinchoE;
      v_VlrElevador            := r_ids.VlrElevador;
      v_VlrGuindast            := r_ids.VlrGuindast;
      v_VlrUnidRefr            := r_ids.VlrUnidRefr;
      v_VlrRollOnOf            := r_ids.VlrRollOnOf;
      v_VlrKitBascu            := r_ids.VlrKitBascu;
      v_VlrOutrosEq            := r_ids.VlrOutrosEq;
      v_VlrApareSom            := r_ids.VlrApareSom;
      v_VlrApareDVD            := r_ids.VlrApareDVD;
      v_VlrKitAutoF            := r_ids.VlrKitAutoF;
      v_VlrOutrosAc            := r_ids.VlrOutrosAc;
      v_DescKmAdicCaminhao     := r_ids.DescKmAdicCaminhao;
      v_CarroReservaClassico     := r_ids.CarroReservaClassico;
	  v_TipoCarroReservaClassico := r_ids.TipoCarroReservaClassico;
	  v_TipoOficinaClassico      := r_ids.TipoOficinaClassico;
    END LOOP;
	FOR r_RenovGerada IN c_RenovGerada LOOP
          v_ProdutoRenovG := r_RenovGerada.produto;
    END LOOP;
	FOR r_RenovManual IN c_RenovManual LOOP
          v_ProdutoRenovM := r_RenovManual.CD_MDUPR;
    END LOOP;

	IF v_TipoSeguro in (4,5) THEN
		IF v_CalculoOrigem > 0 THEN
			v_ProdutoAnterior := v_ProdutoRenovG;
		ELSE
			v_ProdutoAnterior := v_ProdutoRenovM;
		END IF;
	ELSE
		v_ProdutoAnterior := 0;
	END IF;

    OPEN P_RESULTADO FOR SELECT v_calculo calculo,
    v_corretor corretor,
    v_DivisaoCorretor DivisaoCorretor,
    v_Estipulante Estipulante,
    v_DivisaoEstipulante DivisaoEstipulante,
    v_RetornoCrivo RetornoCrivo,
    v_InicioVigencia InicioVigencia,
    v_FinalVigencia FinalVigencia,
    v_Tipo_Cobertura Tipo_Cobertura,
    v_Pgto_Banco_Honda Pgto_Banco_Honda,
    v_PrazoCurto PrazoCurto,
    v_Procedencia Procedencia,
    v_Cep Cep,
    v_Tipo_Pessoa Tipo_Pessoa,
    v_AnoFabricacao AnoFabricacao,
    v_AnoModelo AnoModelo,
    v_Lmi_Blindagem Lmi_Blindagem,
    v_Lmi_KitGas Lmi_KitGas,
    v_Comissao Comissao,
    v_ZeroKM ZeroKM,
    v_DataSaidaZeroKM DataSaidaZeroKM,
    v_Chassi Chassi,
    v_Placa Placa,
    v_CorVeiculo CorVeiculo,
    v_NumApoliceCongenere NumApoliceCongenere,
    v_VencApoliceCongenere VencApoliceCongenere,
    v_SucursalCongenere SucursalCongenere,
    v_NumItemCongenere NumItemCongenere,
    v_Desconto Desconto,
    v_Agravo Agravo,
    v_P_Ajuste P_Ajuste,
    v_nivelbonusauto nivelbonusauto,
    v_Bonus_Interno Bonus_Interno,
    v_TipoSeguro TipoSeguro,
    v_CalculoOrigem CalculoOrigem,
    v_Sinistro Sinistro,
    v_TipoNegocio TipoNegocio,
    v_TipoUsoVeic TipoUsoVeic,
    v_ValorBase ValorBase,
    v_numpassageiros numpassageiros,
    v_dtnascondu dtnascondu,
    v_estcvcondu estcvcondu,
    v_sexocondu sexocondu,
    v_Cod_Tabela Cod_Tabela,
    v_Tipo_Franquia Tipo_Franquia,
    v_Assist24H Assist24H,
    v_ValorAss24H ValorAss24H,
    v_CiaRenova CiaRenova,
    v_Cod_Cidade Cod_Cidade,
    v_ValorVeiculo ValorVeiculo,
    v_niveldm niveldm,
    v_niveldp niveldp,
    v_valorappmorte valorappmorte,
    v_valorappdmh valorappdmh,
    v_desconto_cc desconto_cc,
    v_agravo_cc agravo_cc,
    v_Fabricante Fabricante,
    v_DescFabricante DescFabricante,
    v_Modelo Modelo,
    v_DescModelo DescModelo,
    v_TipoVeiculo TipoVeiculo,
    v_TipoVeiculoCarga TipoVeiculoCarga,
    v_DescTipoVeic DescTipoVeic,
    v_DescTipoVeicCarga DescTipoVeicCarga,
    v_OpcVidros OpcVidros,
    v_CarroReserva CarroReserva,
    v_TipoCarroReserva TipoCarroReserva,
    v_TipoOficina TipoOficina,
    v_KmAdicional KmAdicional,
    v_Grupo Grupo,
    v_Resposta Resposta,
    v_Resposta2 Resposta2,
    v_DescricaoResposta2 DescricaoResposta2,
    v_SubResposta SubResposta,
    v_SubResposta2 SubResposta2,
    v_TipoDispositivo TipoDispositivo,
    v_DespExtra DespExtra,
    v_PerdaFaturamento PerdaFaturamento,
    v_Validade Validade,
    v_PrimeiroSinisIndeniz PrimeiroSinisIndeniz,
    v_Tp_Vidro Tp_Vidro,
    v_Categoriatarifaria Categoriatarifaria,
    v_DescCategoriatarifaria DescCategoriatarifaria,
    v_Tipo_Carroceria Tipo_Carroceria,
    v_DataVersao DataVersao,
    v_Condicoes_Especiais Condicoes_Especiais,
    v_Calc_Online Calc_Online,
    v_site site,
    v_CepPernoite CepPernoite,
    v_ChassiRemarcado ChassiRemarcado,
    v_QuartoEixoAdapt QuartoEixoAdapt,
    v_CargaDescarga CargaDescarga,
    v_VlrCargaDescarga VlrCargaDescarga,
    v_CabineSuplementar CabineSuplementar,
    v_ISCarroceria ISCarroceria,
    v_KmAdicionalCaminhao KmAdicionalCaminhao,
    v_VlrUnidFrig VlrUnidFrig,
    v_VlrGuinchoE VlrGuinchoE,
    v_VlrElevador VlrElevador,
    v_VlrGuindast VlrGuindast,
    v_VlrUnidRefr VlrUnidRefr,
    v_VlrRollOnOf VlrRollOnOf,
    v_VlrKitBascu VlrKitBascu,
    v_VlrOutrosEq VlrOutrosEq,
    v_VlrApareSom VlrApareSom,
    v_VlrApareDVD VlrApareDVD,
    v_VlrKitAutoF VlrKitAutoF,
    v_VlrOutrosAc VlrOutrosAc,
    v_DescKmAdicCaminhao DescKmAdicCaminhao,
    v_CarroReservaClassico CarroReservaClassico,
    v_TipoCarroReservaClassico TipoCarroReservaClassico,
    v_TipoOficinaClassico TipoOficinaClassico,
    v_ProdutoAnterior 	ProdutoAnterior FROM dual;
  END;
END;
/


CREATE OR REPLACE procedure        prc_ids_sugestao_tokio (P_CALCULO   IN MULT_CALCULO.CALCULO%TYPE,
                                                    P_RESULTADO OUT TYPES.CURSOR_TYPE) as
begin
  declare
    cursor c_IDS is
		SELECT  calc.Calculo,
				Corr.Divisao_Superior Corretor,
				Corr.Divisao DivisaoCorretor,
				Estip.Divisao_Superior Estipulante,
				Estip.Divisao DivisaoEstipulante,
				calc.RetornoCrivo,
				calc.InicioVigencia,
				calc.FinalVigencia,
				sgTokio.TP_COBTU Tipo_Cobertura,
				Calc.Pgto_Banco_Honda,
				CASE
				  WHEN (calc.FinalVigencia - calc.InicioVigencia) < 365
				  THEN 'S'
				  ELSE 'N'
				END PrazoCurto,
				calc.Procedencia,
				calc.Cep,
				calc.Tipo_Pessoa,
				calc.AnoFabricacao,
				calc.AnoModelo,
				calc.Lmi_Blindagem,
				calc.Lmi_KitGas,
				calc.Comissao,
				calc.ZeroKM,
				calc.cidade DataSaidaZeroKM,
				calc.Chassi,
				calc.Placa,
				calc.Bairro CorVeiculo,
				calc.Campo1 NumApoliceCongenere,
				calc.Campo2 VencApoliceCongenere,
				calc.Campo4 SucursalCongenere,
				calc.Campo3 NumItemCongenere,
				calc.Cod_Referencia Desconto,
				calc.Agravo,
				sgTokio.VL_FIPE P_Ajuste,
				calc.nivelbonusauto,
				calc.Bonus_Interno,
				calc.TipoSeguro,
				calc.CalculoOrigem,
				CASE
				  WHEN calc.TipoSeguro IN (2,4)
				  THEN 'S'
				  ELSE 'N'
				END Sinistro,
				CASE
				  WHEN calc.CalculoOrigem > 0
				  THEN 'R'
				  WHEN calc.TipoSeguro = 1
				  THEN 'P'
				  WHEN calc.TipoSeguro IN (2,3)
				  THEN 'C'
				  WHEN calc.TipoSeguro IN (4,5)
				  THEN 'M'
				END TipoNegocio,
				calc.TipoUsoVeic,
				calc.ValorBase,
				calc.numpassag numpassageiros,
				calc.dtnascondu,
				calc.estcvcondu,
				calc.sexocondu,
				calc.Cod_Tabela,
				calc.Tipo_Franquia,
				case calc.padrao
					when 14 then
						sgTokio.TP_ASSIT_24HH_CMHAO
					when 15 then
						sgTokio.TP_ASSIT_24HH_UTLRO
				end Assist24H,
				NVL(calc.ValorAss24H,0) ValorAss24H,
				calc.CiaRenova,
				calc.Cod_Cidade,
				case
					when calc.padrao = 10 then
						(SELECT pkg_kcwutils.GetValorMercadoPasseio(calc.Modelo, calc.Procedencia, calc.AnoModelo, calc.ZeroKM, calc.Cep, calc.DataVersao) from dual)
					when calc.padrao in(11,14,15) then
						(SELECT pkg_kcwutils.GetValorMercadoCarga(calc.Modelo, calc.Procedencia, calc.AnoModelo, calc.ZeroKM, calc.Cep, calc.DataVersao, calc.Fabricante) from dual)
				end ValorVeiculo,
				sgTokio.VL_DANO_MTRAL niveldm,
				sgTokio.VL_DANO_CRPRL niveldp,
				sgTokio.VL_APP valorappmorte,
				sgTokio.VL_DANO_MORAL valorappdmh,
				calc.desconto_cc,
				calc.agravo_cc,
				calc.Fabricante,
				Fabr.Nome DescFabricante,
				calc.Modelo,
				Model.Descricao DescModelo,
				TipVeic.Valor TipoVeiculo,
				TipVeicCarg.Valor TipoVeiculoCarga,
				TipVeic.Texto DescTipoVeic,
				TipVeicCarg.Texto DescTipoVeicCarga,
				case calc.padrao
					when 14 then sgTokio.CD_VIDRO_CMHAO
					when 15 then sgTokio.CD_VIDRO_UTLRO
				end OpcVidros,
				null CarroReserva,
				null TipoCarroReserva,
				null TipoOficina,
				case calc.padrao
					when 14 then sgTokio.CD_KMGM_ADCNL_CMHAO
					when 15 then sgTokio.CD_KMGM_ADCNL_UTLRO
				end KmAdicional,
				Qbr.Grupo,
				Qbr.Resposta,
				Qbr.Resposta2,
				Qbr.DescricaoResposta2,
				Qbr.SubResposta,
				Qbr.SubResposta2,
				TipDisp.Tipo TipoDispositivo,
				sgTokio.CD_DESPS_EXTRA DespExtra,
				sgTokio.VL_PERDA_FTUMT PerdaFaturamento,
				Prod.Validade,
				null PrimeiroSinisIndeniz,
				Model.Tp_Vidro,
				Model.Categ_Tar1 Categoriatarifaria,
				CASE
				  WHEN Calc.Padrao in(11,14,15) THEN
					(SELECT texto FROM Mult_Produtostabrg tabrg
					  WHERE tabrg.Produto = 11
					    AND chave2 = model.Categ_Tar1
					    AND tabela = 330
					)
				  ELSE
					(SELECT Texto FROM Mult_Produtostabrg Tabrg
					  WHERE Tabrg.Produto = 10
					    AND Chave2 = Model.Categ_Tar1
					    AND Tabela = 326
					)
				END DescCategoriatarifaria,
				calc.Tipo_Carroceria,
				calc.DataVersao,
				calc.Condicoes_Especiais,
				calc.Calc_Online,
				calc.site,
				kit1.CD_CEP_PRNOI      CepPernoite,
				kit1.CD_CHASSI_RMARC   ChassiRemarcado,
				kit1.CD_QURTO_EIXO     QuartoEixoAdapt,
				sgTokio.CD_CARGA_DSRGA CargaDescarga,
				case sgTokio.CD_CARGA_DSRGA
				  when 18667 then 500 --Contratada
				  when 18668 then 0   --N„o Contratada
				end VlrCargaDescarga,
				kit1.CD_CBINE_SUPLM    CabineSuplementar,
				kit1.CD_FRANQ_CRROC    ISCarroceria,
				case calc.padrao
					when 14 then sgTokio.CD_KMGM_ADCNL_CMHAO
					when 15 then sgTokio.CD_KMGM_ADCNL_UTLRO
				end KmAdicionalCaminhao,
				kit1.VL_IS_UNIDD_FRIGO       VlrUnidFrig,
				kit1.VL_IS_GUNCH             VlrGuinchoE,
				kit1.VL_IS_ELEVD_PLATF_CARGA VlrElevador,
				kit1.VL_IS_GUND_MUNCK        VlrGuindast,
				kit1.VL_IS_UNIDD_REFRG       VlrUnidRefr,
				kit1.VL_IS_ROLON_ROLOF       VlrRollOnOf,
				kit1.VL_IS_KIT_BASCL         VlrKitBascu,
				kit1.VL_IS_OUTRO_EQUIP_CARGA VlrOutrosEq,
				kit1.VL_IS_APRLH_SOM         VlrApareSom,
				kit1.VL_IS_APRLH_SOM_DVD     VlrApareDVD,
				kit1.VL_IS_ALTO_FLANT        VlrKitAutoF,
				kit1.VL_IS_OUTRO_EQUIP_PSSEI VlrOutrosAc,
				DescKmAdic.Descricao DescKmAdicCaminhao,
				sgTokio.TP_COTAC TipoCotacao
		  FROM Mult_Calculo Calc
		  INNER JOIN Tabela_VeiculoFabric Fabr         ON Fabr.Fabricante = Calc.Fabricante
		  INNER JOIN Tabela_VeiculoModelo Model        ON Model.Modelo = Calc.Modelo
		  LEFT OUTER JOIN VW_TABRG_P10_T24 TipVeic     ON TipVeic.chave1 = calc.ValorBase
		  LEFT OUTER JOIN Vw_Tabrg_P11_T24 Tipveiccarg ON Tipveiccarg.Chave1  = Calc.Valorbase
													  AND TipVeicCarg.chave2 = 1
		  left join KIT0002_MTCAL_SUGST sgTokio        on sgTokio.NR_CALLO = Calc.Calculo
													  and sgTokio.NR_ITEM = 0
		  INNER JOIN Mult_Calculodivisoes Divcor       ON Divcor.Calculo = Calc.Calculo
													  AND DivCor.Nivel  = 1
		  INNER JOIN Tabela_Divisoes Corr              ON Corr.Divisao = DivCor.Divisao
		  INNER JOIN Mult_Calculoqbr Qbr               ON Qbr.Calculo   = Calc.Calculo
													  AND (Qbr.Questao  = 243
														OR Qbr.Questao  = 244)
		  LEFT OUTER JOIN Mult_Produtosqbrdispseg Tipdisp ON Tipdisp.Resposta    = Qbr.Resposta
														 AND Tipdisp.Dispositivo = Qbr.Subresposta
														 AND Tipdisp.Vigencia    = 1
		  LEFT OUTER JOIN Mult_Calculodivisoes Divestip   ON Divestip.Calculo = Calc.Calculo
														 AND Divestip.Nivel   = 4
		  LEFT OUTER JOIN Tabela_Divisoes Estip        ON Estip.Divisao = DivEstip.Divisao
		  left join kit0001_mtcal_auto kit1            on kit1.nr_callo=calc.calculo
		  left join Mult_ProdutosCobPerOpc DescKmAdic  on DescKmAdic.Cobertura = 339
													  and DescKmAdic.Opcao = kit1.CD_KM_ADCNL
													  and (DescKmAdic.Produto = 11
														or DescKmAdic.Produto = Calc.Padrao)
		  INNER JOIN Mult_Produtos Prod                ON Prod.Produto = Calc.Padrao
      where calc.calculo = P_CALCULO;
      --
      v_calculo                 MULT_CALCULO.CALCULO%TYPE;
      v_corretor                Tabela_Divisoes.Divisao_Superior%TYPE;
      v_DivisaoCorretor 		    Tabela_Divisoes.Divisao%TYPE;
      v_Estipulante 			      Tabela_Divisoes.Divisao_Superior%TYPE;
      v_DivisaoEstipulante 	    Tabela_Divisoes.Divisao%TYPE;
      v_RetornoCrivo 			      mult_calculo.RetornoCrivo%TYPE;
      v_InicioVigencia 		      mult_calculo.InicioVigencia%TYPE;
      v_FinalVigencia 		      mult_calculo.FinalVigencia%TYPE;
      v_Tipo_Cobertura 		      mult_calculo.Tipo_Cobertura%TYPE;
      v_Pgto_Banco_Honda 		    mult_calculo.Pgto_Banco_Honda%TYPE;
      v_PrazoCurto 			        varchar2(1);
      v_Procedencia 			      mult_calculo.Procedencia%TYPE;
      v_Cep 					          mult_calculo.Cep%TYPE;
      v_Tipo_Pessoa 			      mult_calculo.Tipo_Pessoa%TYPE;
      v_AnoFabricacao 		      mult_calculo.AnoFabricacao%TYPE;
      v_AnoModelo 			        mult_calculo.AnoModelo%TYPE;
      v_Lmi_Blindagem 		      mult_calculo.Lmi_Blindagem%TYPE;
      v_Lmi_KitGas 			        mult_calculo.Lmi_KitGas%TYPE;
      v_Comissao 				        mult_calculo.Comissao%TYPE;
      v_ZeroKM 				          mult_calculo.ZeroKM%TYPE;
      v_DataSaidaZeroKM 		    mult_calculo.cidade%TYPE;
      v_Chassi 				          mult_calculo.Chassi%TYPE;
      v_Placa 				          mult_calculo.Placa%TYPE;
      v_CorVeiculo 			        mult_calculo.Bairro%TYPE;
      v_NumApoliceCongenere 	  mult_calculo.Campo1%TYPE;
      v_VencApoliceCongenere 	  mult_calculo.Campo2%TYPE;
      v_SucursalCongenere 	    mult_calculo.Campo4%TYPE;
      v_NumItemCongenere 		    mult_calculo.Campo3%TYPE;
      v_Desconto 				        mult_calculo.Cod_Referencia%TYPE;
      v_Agravo 				          mult_calculo.Agravo%TYPE;
      v_P_Ajuste 				        mult_calculo.P_Ajuste%TYPE;
      v_nivelbonusauto 		      mult_calculo.nivelbonusauto%TYPE;
      v_Bonus_Interno 		      mult_calculo.Bonus_Interno%TYPE;
      v_TipoSeguro 			        mult_calculo.TipoSeguro%TYPE;
      v_CalculoOrigem 		      mult_calculo.CalculoOrigem%TYPE;
      v_Sinistro 				        varchar2(1);
      v_TipoNegocio 			      varchar2(1);
      v_TipoUsoVeic 			      mult_calculo.TipoUsoVeic%TYPE;
      v_ValorBase 			        mult_calculo.ValorBase%TYPE;
      v_numpassageiros 		        mult_calculo.numpassag%TYPE;
      v_dtnascondu 			        mult_calculo.dtnascondu%TYPE;
      v_estcvcondu 			        mult_calculo.estcvcondu%TYPE;
      v_sexocondu 			        mult_calculo.sexocondu%TYPE;
      v_Cod_Tabela 			        mult_calculo.Cod_Tabela%TYPE;
      v_Tipo_Franquia 		      mult_calculo.Tipo_Franquia%TYPE;
      v_Assist24H 			        mult_calculo.Estado%TYPE;
      v_ValorAss24H 			      mult_calculo.ValorAss24H%TYPE;
      v_CiaRenova 			        mult_calculo.CiaRenova%TYPE;
      v_Cod_Cidade 			        mult_calculo.Cod_Cidade%TYPE;
      v_ValorVeiculo 			      mult_calculo.ValorVeiculo%TYPE;
      v_niveldm 				        mult_calculo.niveldm%TYPE;
      v_niveldp 				        mult_calculo.niveldp%TYPE;
      v_valorappmorte 		      mult_calculo.valorappmorte%TYPE;
      v_valorappdmh 			      mult_calculo.valorappdmh%TYPE;
      v_desconto_cc 			      mult_calculo.desconto_cc%TYPE;
      v_agravo_cc 			        mult_calculo.agravo_cc%TYPE;
      v_Fabricante 			        mult_calculo.Fabricante%TYPE;
      v_DescFabricante 		      Tabela_VeiculoFabric.Nome%TYPE;
      v_Modelo 				          mult_calculo.Modelo%TYPE;
      v_DescModelo 			        Tabela_VeiculoModelo.Descricao%TYPE;
      v_TipoVeiculo 			      VW_TABRG_P10_T24.Valor%Type;
      v_TipoVeiculoCarga 		    Vw_Tabrg_P11_T24.Valor%Type;
      v_DescTipoVeic 			      VW_TABRG_P10_T24.Texto%Type;
      v_DescTipoVeicCarga 	    Vw_Tabrg_P11_T24.Texto%Type;
      v_OpcVidros 			        Mult_Calculocob.Opcao%Type;
      v_CarroReserva 			      Mult_Calculocob.Opcao%Type;
      v_TipoCarroReserva 		    Mult_Calculocob.Opcao%Type;
      v_TipoOficina 			      Mult_Calculocob.Opcao%Type;
      v_KmAdicional 			      Mult_Calculocob.Opcao%Type;
      v_Grupo 				          Mult_Calculoqbr.Grupo%Type;
      v_Resposta 				        Mult_Calculoqbr.Resposta%Type;
      v_Resposta2 			        Mult_Calculoqbr.Resposta2%Type;
      v_DescricaoResposta2 	    Mult_Calculoqbr.DescricaoResposta2%Type;
      v_SubResposta 			      Mult_Calculoqbr.SubResposta%Type;
      v_SubResposta2 			      Mult_Calculoqbr.SubResposta2%Type;
      v_TipoDispositivo 		    Mult_Produtosqbrdispseg.Tipo%Type;
      v_DespExtra 			        Mult_Calculocob.Opcao%Type;
      v_PerdaFaturamento 		    Mult_Calculocob.Opcao%Type;
      v_Validade 				        Mult_Produtos.Validade%Type;
      v_PrimeiroSinisIndeniz 	  varchar2(1);
      v_Tp_Vidro 				        Tabela_VeiculoModelo.Tp_Vidro%TYPE;
      v_Categoriatarifaria 	    Tabela_VeiculoModelo.Categ_Tar1%TYPE;
      v_DescCategoriatarifaria  Mult_Produtostabrg.Texto%TYPE;
      v_Tipo_Carroceria 		    mult_calculo.Tipo_Carroceria%TYPE;
      v_DataVersao 			        mult_calculo.DataVersao%TYPE;
      v_Condicoes_Especiais 	  mult_calculo.Condicoes_Especiais%TYPE;
      v_Calc_Online 			      mult_calculo.Calc_Online%TYPE;
      v_site 					          mult_calculo.site%TYPE;
      v_CepPernoite 			      kit0001_mtcal_auto.CD_CEP_PRNOI%TYPE;
      v_ChassiRemarcado 		    kit0001_mtcal_auto.CD_CHASSI_RMARC%TYPE;
      v_QuartoEixoAdapt 		    kit0001_mtcal_auto.CD_QURTO_EIXO%TYPE;
      v_CargaDescarga 		      kit0001_mtcal_auto.CD_CARGA_DSCRG%TYPE;
      v_VlrCargaDescarga 		    kit0001_mtcal_auto.VL_IS_CARGA_DSCRG%TYPE;
      v_CabineSuplementar 	    kit0001_mtcal_auto.CD_CBINE_SUPLM%TYPE;
      v_ISCarroceria 			      kit0001_mtcal_auto.CD_FRANQ_CRROC%TYPE;
      v_KmAdicionalCaminhao 	  kit0001_mtcal_auto.CD_KM_ADCNL%TYPE;
      v_VlrUnidFrig 			      kit0001_mtcal_auto.VL_IS_UNIDD_FRIGO%TYPE;
      v_VlrGuinchoE 			      kit0001_mtcal_auto.VL_IS_GUNCH%TYPE;
      v_VlrElevador 			      kit0001_mtcal_auto.VL_IS_ELEVD_PLATF_CARGA%TYPE;
      v_VlrGuindast 			      kit0001_mtcal_auto.VL_IS_GUND_MUNCK%TYPE;
      v_VlrUnidRefr 			      kit0001_mtcal_auto.VL_IS_UNIDD_REFRG%TYPE;
      v_VlrRollOnOf 			      kit0001_mtcal_auto.VL_IS_ROLON_ROLOF%TYPE;
      v_VlrKitBascu 			      kit0001_mtcal_auto.VL_IS_KIT_BASCL%TYPE;
      v_VlrOutrosEq 			      kit0001_mtcal_auto.VL_IS_OUTRO_EQUIP_CARGA%TYPE;
      v_VlrApareSom 			      kit0001_mtcal_auto.VL_IS_APRLH_SOM%TYPE;
      v_VlrApareDVD 			      kit0001_mtcal_auto.VL_IS_APRLH_SOM_DVD%TYPE;
      v_VlrKitAutoF 			      kit0001_mtcal_auto.VL_IS_ALTO_FLANT%TYPE;
      v_VlrOutrosAc 			      kit0001_mtcal_auto.VL_IS_OUTRO_EQUIP_PSSEI%TYPE;
      v_DescKmAdicCaminhao 	    Mult_ProdutosCobPerOpc.Descricao%TYPE;
      v_TipoCotacao             Mult_CalculoPremios.TIPOCOTACAO%TYPE;
      --
  BEGIN
    FOR r_ids in c_IDS LOOP
        v_calculo                 := r_ids.calculo;
        v_corretor                := r_ids.corretor;
        v_DivisaoCorretor 		    := r_ids.DivisaoCorretor;
        v_Estipulante 			      := r_ids.Estipulante;
        v_DivisaoEstipulante 	    := r_ids.DivisaoEstipulante;
        v_RetornoCrivo 			      := r_ids.RetornoCrivo;
        v_InicioVigencia 		      := r_ids.InicioVigencia;
        v_FinalVigencia 		      := r_ids.FinalVigencia;
        v_Tipo_Cobertura 		      := r_ids.Tipo_Cobertura;
        v_Pgto_Banco_Honda 		    := r_ids.Pgto_Banco_Honda;
        v_PrazoCurto 			        := r_ids.PrazoCurto;
        v_Procedencia 			      := r_ids.Procedencia;
        v_Cep 					          := r_ids.Cep;
        v_Tipo_Pessoa 			      := r_ids.Tipo_Pessoa;
        v_AnoFabricacao 		      := r_ids.AnoFabricacao;
        v_AnoModelo 			        := r_ids.AnoModelo;
        v_Lmi_Blindagem 		      := r_ids.Lmi_Blindagem;
        v_Lmi_KitGas 			        := r_ids.Lmi_KitGas;
        v_Comissao 				        := r_ids.Comissao;
        v_ZeroKM 				          := r_ids.ZeroKM;
        v_DataSaidaZeroKM 		    := r_ids.DataSaidaZeroKM;
        v_Chassi 				          := r_ids.Chassi;
        v_Placa 				          := r_ids.Placa;
        v_CorVeiculo 			        := r_ids.CorVeiculo;
        v_NumApoliceCongenere 	  := r_ids.NumApoliceCongenere;
        v_VencApoliceCongenere 	  := r_ids.VencApoliceCongenere;
        v_SucursalCongenere 	    := r_ids.SucursalCongenere;
        v_NumItemCongenere 		    := r_ids.NumItemCongenere;
        v_Desconto 				        := r_ids.Desconto;
        v_Agravo 				          := r_ids.Agravo;
        v_P_Ajuste 				        := r_ids.P_Ajuste;
        v_nivelbonusauto 		      := r_ids.nivelbonusauto;
        v_Bonus_Interno 		      := r_ids.Bonus_Interno;
        v_TipoSeguro 			        := r_ids.TipoSeguro;
        v_CalculoOrigem 		      := r_ids.CalculoOrigem;
        v_Sinistro 				        := r_ids.Sinistro;
        v_TipoNegocio 			      := r_ids.TipoNegocio;
        v_TipoUsoVeic 			      := r_ids.TipoUsoVeic;
        v_ValorBase 			        := r_ids.ValorBase;
        v_numpassageiros 		      := r_ids.numpassageiros;
        v_dtnascondu 			        := r_ids.dtnascondu;
        v_estcvcondu 			        := r_ids.estcvcondu;
        v_sexocondu 			        := r_ids.sexocondu;
        v_Cod_Tabela 			        := r_ids.Cod_Tabela;
        v_Tipo_Franquia 		      := r_ids.Tipo_Franquia;
        v_Assist24H 			        := r_ids.Assist24H;
        v_ValorAss24H 			      := r_ids.ValorAss24H;
        v_CiaRenova 			        := r_ids.CiaRenova;
        v_Cod_Cidade 			        := r_ids.Cod_Cidade;
        v_ValorVeiculo 			      := r_ids.ValorVeiculo;
        v_niveldm 				        := r_ids.niveldm;
        v_niveldp 				        := r_ids.niveldp;
        v_valorappmorte 		      := r_ids.valorappmorte;
        v_valorappdmh 			      := r_ids.valorappdmh;
        v_desconto_cc 			      := r_ids.desconto_cc;
        v_agravo_cc 			        := r_ids.agravo_cc;
        v_Fabricante 			        := r_ids.Fabricante;
        v_DescFabricante 		      := r_ids.DescFabricante;
        v_Modelo 				          := r_ids.Modelo;
        v_DescModelo 			        := r_ids.DescModelo;
        v_TipoVeiculo 			      := r_ids.TipoVeiculo;
        v_TipoVeiculoCarga 		    := r_ids.TipoVeiculoCarga;
        v_DescTipoVeic 			      := r_ids.DescTipoVeic;
        v_DescTipoVeicCarga 	    := r_ids.DescTipoVeicCarga;
        v_OpcVidros 			        := r_ids.OpcVidros;
        v_CarroReserva 			      := r_ids.CarroReserva;
        v_TipoCarroReserva 		    := r_ids.TipoCarroReserva;
        v_TipoOficina 			      := r_ids.TipoOficina;
        v_KmAdicional 			      := r_ids.KmAdicional;
        v_Grupo 				          := r_ids.Grupo;
        v_Resposta 				        := r_ids.Resposta;
        v_Resposta2 			        := r_ids.Resposta2;
        v_DescricaoResposta2 	    := r_ids.DescricaoResposta2;
        v_SubResposta 			      := r_ids.SubResposta;
        v_SubResposta2 			      := r_ids.SubResposta2;
        v_TipoDispositivo 		    := r_ids.TipoDispositivo;
        v_DespExtra 			        := r_ids.DespExtra;
        v_PerdaFaturamento 		    := r_ids.PerdaFaturamento;
        v_Validade 				        := r_ids.Validade;
        v_PrimeiroSinisIndeniz 	  := r_ids.PrimeiroSinisIndeniz;
        v_Tp_Vidro 				        := r_ids.Tp_Vidro;
        v_Categoriatarifaria 	    := r_ids.Categoriatarifaria;
        v_DescCategoriatarifaria  := r_ids.DescCategoriatarifaria;
        v_Tipo_Carroceria 		    := r_ids.Tipo_Carroceria;
        v_DataVersao 			        := r_ids.DataVersao;
        v_Condicoes_Especiais 	  := r_ids.Condicoes_Especiais;
        v_Calc_Online 			      := r_ids.Calc_Online;
        v_site 					          := r_ids.site;
        v_CepPernoite 			      := r_ids.CepPernoite;
        v_ChassiRemarcado 		    := r_ids.ChassiRemarcado;
        v_QuartoEixoAdapt 		    := r_ids.QuartoEixoAdapt;
        v_CargaDescarga 		      := r_ids.CargaDescarga;
        v_VlrCargaDescarga 		    := r_ids.VlrCargaDescarga;
        v_CabineSuplementar 	    := r_ids.CabineSuplementar;
        v_ISCarroceria 			      := r_ids.ISCarroceria;
        v_KmAdicionalCaminhao 	  := r_ids.KmAdicionalCaminhao;
        v_VlrUnidFrig 			      := r_ids.VlrUnidFrig;
        v_VlrGuinchoE 			      := r_ids.VlrGuinchoE;
        v_VlrElevador 			      := r_ids.VlrElevador;
        v_VlrGuindast 			      := r_ids.VlrGuindast;
        v_VlrUnidRefr 			      := r_ids.VlrUnidRefr;
        v_VlrRollOnOf 			      := r_ids.VlrRollOnOf;
        v_VlrKitBascu 			      := r_ids.VlrKitBascu;
        v_VlrOutrosEq 			      := r_ids.VlrOutrosEq;
        v_VlrApareSom 			      := r_ids.VlrApareSom;
        v_VlrApareDVD 			      := r_ids.VlrApareDVD;
        v_VlrKitAutoF 			      := r_ids.VlrKitAutoF;
        v_VlrOutrosAc 			      := r_ids.VlrOutrosAc;
        v_DescKmAdicCaminhao 	    := r_ids.DescKmAdicCaminhao;
        v_TipoCotacao             := r_ids.TipoCotacao;
    END LOOP;

    OPEN P_RESULTADO for
        SELECT  v_calculo                calculo,
                v_corretor               corretor,
                v_DivisaoCorretor 		   DivisaoCorretor,
                v_Estipulante 			     Estipulante,
                v_DivisaoEstipulante 	   DivisaoEstipulante,
                v_RetornoCrivo 			     RetornoCrivo,
                v_InicioVigencia 		     InicioVigencia,
                v_FinalVigencia 		     FinalVigencia,
                v_Tipo_Cobertura 		     Tipo_Cobertura,
                v_Pgto_Banco_Honda 		   Pgto_Banco_Honda,
                v_PrazoCurto 			       PrazoCurto,
                v_Procedencia 			     Procedencia,
                v_Cep 					         Cep,
                v_Tipo_Pessoa 			     Tipo_Pessoa,
                v_AnoFabricacao 		     AnoFabricacao,
                v_AnoModelo 			       AnoModelo,
                v_Lmi_Blindagem 		     Lmi_Blindagem,
                v_Lmi_KitGas 			       Lmi_KitGas,
                v_Comissao 				       Comissao,
                v_ZeroKM 				         ZeroKM,
                v_DataSaidaZeroKM 		   DataSaidaZeroKM,
                v_Chassi 				         Chassi,
                v_Placa 				         Placa,
                v_CorVeiculo 		         CorVeiculo,
                v_NumApoliceCongenere 	 NumApoliceCongenere,
                v_VencApoliceCongenere 	 VencApoliceCongenere,
                v_SucursalCongenere 	   SucursalCongenere,
                v_NumItemCongenere 		   NumItemCongenere,
                v_Desconto 				       Desconto,
                v_Agravo 				         Agravo,
                v_P_Ajuste 				       P_Ajuste,
                v_nivelbonusauto 		     nivelbonusauto,
                v_Bonus_Interno 		     Bonus_Interno,
                v_TipoSeguro 			       TipoSeguro,
                v_CalculoOrigem 		     CalculoOrigem,
                v_Sinistro 				       Sinistro,
                v_TipoNegocio 			     TipoNegocio,
                v_TipoUsoVeic 			     TipoUsoVeic,
                v_ValorBase 			       ValorBase,
                v_numpassageiros 		     numpassageiros,
                v_dtnascondu 			       dtnascondu,
                v_estcvcondu 			       estcvcondu,
                v_sexocondu 			       sexocondu,
                v_Cod_Tabela 			       Cod_Tabela,
                v_Tipo_Franquia 		     Tipo_Franquia,
                v_Assist24H 			       Assist24H,
                v_ValorAss24H 			     ValorAss24H,
                v_CiaRenova 			       CiaRenova,
                v_Cod_Cidade 			       Cod_Cidade,
                v_ValorVeiculo 			     ValorVeiculo,
                v_niveldm 				       niveldm,
                v_niveldp 				       niveldp,
                v_valorappmorte 		     valorappmorte,
                v_valorappdmh 			     valorappdmh,
                v_desconto_cc 			     desconto_cc,
                v_agravo_cc 			       agravo_cc,
                v_Fabricante 			       Fabricante,
                v_DescFabricante 		     DescFabricante,
                v_Modelo 				         Modelo,
                v_DescModelo 			       DescModelo,
                v_TipoVeiculo 			     TipoVeiculo,
                v_TipoVeiculoCarga 		   TipoVeiculoCarga,
                v_DescTipoVeic 			     DescTipoVeic,
                v_DescTipoVeicCarga 	   DescTipoVeicCarga,
                v_OpcVidros 			       OpcVidros,
                v_CarroReserva 			     CarroReserva,
                v_TipoCarroReserva 		   TipoCarroReserva,
                v_TipoOficina 			     TipoOficina,
                v_KmAdicional 			     KmAdicional,
                v_Grupo 				         Grupo,
                v_Resposta 				       Resposta,
                v_Resposta2 			       Resposta2,
                v_DescricaoResposta2 	   DescricaoResposta2,
                v_SubResposta 			     SubResposta,
                v_SubResposta2 			     SubResposta2,
                v_TipoDispositivo 		   TipoDispositivo,
                v_DespExtra 			       DespExtra,
                v_PerdaFaturamento 		   PerdaFaturamento,
                v_Validade 				       Validade,
                v_PrimeiroSinisIndeniz 	 PrimeiroSinisIndeniz,
                v_Tp_Vidro 				       Tp_Vidro,
                v_Categoriatarifaria 	   Categoriatarifaria,
                v_DescCategoriatarifaria DescCategoriatarifaria,
                v_Tipo_Carroceria  		   Tipo_Carroceria,
                v_DataVersao 			 		   DataVersao,
                v_Condicoes_Especiais 	 Condicoes_Especiais,
                v_Calc_Online 			     Calc_Online,
                v_site 					 		     site,
                v_CepPernoite 			     CepPernoite,
                v_ChassiRemarcado 		   ChassiRemarcado,
                v_QuartoEixoAdapt 		   QuartoEixoAdapt,
                v_CargaDescarga 		     CargaDescarga,
                v_VlrCargaDescarga 		   VlrCargaDescarga,
                v_CabineSuplementar 	   CabineSuplementar,
                v_ISCarroceria 			     ISCarroceria,
                v_KmAdicionalCaminhao 	 KmAdicionalCaminhao,
                v_VlrUnidFrig 			     VlrUnidFrig,
                v_VlrGuinchoE 			     VlrGuinchoE,
                v_VlrElevador 			     VlrElevador,
                v_VlrGuindast 			     VlrGuindast,
                v_VlrUnidRefr 			     VlrUnidRefr,
                v_VlrRollOnOf 			     VlrRollOnOf,
                v_VlrKitBascu 			     VlrKitBascu,
                v_VlrOutrosEq 			     VlrOutrosEq,
                v_VlrApareSom 			     VlrApareSom,
                v_VlrApareDVD 			     VlrApareDVD,
                v_VlrKitAutoF 			     VlrKitAutoF,
                v_VlrOutrosAc 			     VlrOutrosAc,
                v_DescKmAdicCaminhao 	   DescKmAdicCaminhao,
                v_TipoCotacao            TipoCotacao
        FROM dual;
  end;
end;
/


CREATE OR REPLACE PROCEDURE "PRC_LISTAUSUARIO" (
   lid_usuario         IN       real_usuarios.cod_usuario%TYPE,
   lcd_corretor_usu    IN       real_usuarios.corretor%TYPE,
   lnm_usuario         OUT  NOCOPY     real_usuarios.nomeusuario%TYPE,
   lag_captadora_usu   OUT       real_usuarios.agencia%TYPE,
   ltp_usuario         OUT  NOCOPY     real_usuarios.tipousuario%TYPE,
   lcd_padrao_usu      OUT  NOCOPY      real_usuarios.padraousuario%TYPE,
   ltb_estipulante1    OUT       real_usuarios.estipulante1%TYPE,
   ltb_estipulante2    OUT      real_usuarios.estipulante2%TYPE,
   ltb_estipulante3    OUT      real_usuarios.estipulante3%TYPE,
   ltb_estipulante4    OUT      real_usuarios.estipulante4%TYPE,
   ltb_estipulante5    OUT      real_usuarios.estipulante5%TYPE,
   ltb_estipulante6    OUT      real_usuarios.estipulante6%TYPE,
   ltb_estipulante7    OUT      real_usuarios.estipulante7%TYPE,
   ltb_estipulante8    OUT      real_usuarios.estipulante8%TYPE,
   ltb_estipulante9    OUT      real_usuarios.estipulante9%TYPE,
   ltb_estipulante0    OUT      real_usuarios.estipulante0%TYPE,
   ldt_ini_vig_usu     OUT      real_usuarios.iniciovigencia%TYPE,
   ldt_fim_vig_usu     OUT      real_usuarios.finalvigencia%TYPE)
IS
BEGIN
  SELECT
   U.nomeusuario, 
   U.agencia, 
   U.tipousuario, 
   U.padraousuario, 
   U.estipulante1, 
   U.estipulante2, 
   U.estipulante3, 
   U.estipulante4, 
   U.estipulante5, 
   U.estipulante6, 
   U.estipulante7, 
   U.estipulante8, 
   U.estipulante9, 
   U.estipulante0, 
   U.iniciovigencia, 
   U.FINALVIGENCIA 
  INTO
    lnm_usuario,
   lag_captadora_usu,
   ltp_usuario,
   lcd_padrao_usu,
   ltb_estipulante1,
   ltb_estipulante2,
   ltb_estipulante3,
   ltb_estipulante4,
   ltb_estipulante5,
   ltb_estipulante6,
   ltb_estipulante7,
   ltb_estipulante8,
   ltb_estipulante9,
   ltb_estipulante0,
   ldt_ini_vig_usu,
   ldt_fim_vig_usu
  FROM
   REAL_USUARIOS U
  WHERE
   U.COD_USUARIO = lid_usuario AND
   U.CORRETOR = (SELECT 
                  D.DIVISAO 
                 FROM 
                  TABELA_DIVISOES D 
                 WHERE 
                  D.DIVISAO_SUPERIOR = LCD_CORRETOR_USU AND 
                  D.TIPO_DIVISAO = 'E');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   null;                  
end;
/


CREATE OR REPLACE PROCEDURE "PRC_LISTAUSUARIO_PORTAL" (
   lid_usuario         IN       real_usuarios.cod_usuario%TYPE,
   lcd_corretor_usu    IN       real_usuarios.corretor%TYPE,
   lnm_usuario         OUT  NOCOPY     real_usuarios.nomeusuario%TYPE,
   lag_captadora_usu   OUT       real_usuarios.agencia%TYPE,
   ltp_usuario         OUT  NOCOPY     real_usuarios.tipousuario%TYPE,
   lcd_padrao_usu      OUT  NOCOPY      real_usuarios.padraousuario%TYPE,
   pa_estipulantes     OUT  NOCOPY ESTIPULANTE_TYPE,
   ldt_ini_vig_usu     OUT      real_usuarios.iniciovigencia%TYPE,
   ldt_fim_vig_usu     OUT      real_usuarios.finalvigencia%TYPE)
IS
BEGIN
  pa_estipulantes.EXTEND(10);

  SELECT
   U.nomeusuario,
   U.agencia,
   U.tipousuario,
   U.padraousuario,
   U.estipulante1,
   U.estipulante2,
   U.estipulante3,
   U.estipulante4,
   U.estipulante5,
   U.estipulante6,
   U.estipulante7,
   U.estipulante8,
   U.estipulante9,
   U.estipulante0,
   U.iniciovigencia,
   U.FINALVIGENCIA
  INTO
    lnm_usuario,
   lag_captadora_usu,
   ltp_usuario,
   lcd_padrao_usu,
   pa_estipulantes(1).ESTIPULANTE_CODE,
   pa_estipulantes(2).ESTIPULANTE_CODE,
   pa_estipulantes(3).ESTIPULANTE_CODE,
   pa_estipulantes(4).ESTIPULANTE_CODE,
   pa_estipulantes(5).ESTIPULANTE_CODE,
   pa_estipulantes(6).ESTIPULANTE_CODE,
   pa_estipulantes(7).ESTIPULANTE_CODE,
   pa_estipulantes(8).ESTIPULANTE_CODE,
   pa_estipulantes(9).ESTIPULANTE_CODE,
   pa_estipulantes(10).ESTIPULANTE_CODE,
   ldt_ini_vig_usu,
   ldt_fim_vig_usu
  FROM
   REAL_USUARIOS U
  WHERE
   U.COD_USUARIO = lid_usuario AND
   U.CORRETOR = (SELECT
                  D.DIVISAO
                 FROM
                  TABELA_DIVISOES D
                 WHERE
                  D.DIVISAO_SUPERIOR = LCD_CORRETOR_USU AND
                  D.TIPO_DIVISAO = 'E');
end;
/


CREATE OR REPLACE PROCEDURE        PRC_PROPOSTA_CARGA ( p_calculo in mult_calculo.calculo%type, p_cproposta_carga out types.cursor_type ) is
begin
    Open P_Cproposta_Carga For
         select mult.nome as proponente,
                        cli.cgc_cpf,
                        cli.tipo_pessoa,
                        cliend.endereco,
                        cliend.numero,
                        cliend.complemento,
                        cliend.tipologradouro,
                        cliend.bairro,
                        cliend.cidade,
                        cliend.estado,
                        cliend.cep as cep_cliente,
            tel_res.ddd,
            tel_res.telefone as tel_residencia,
            tel_cel.ddd      as ddd_cel,
            tel_cel.telefone as tel_celular,
            cli.e_mail,
            cli.home_page,
            cli.data_nascimento,
            cli.sexo,
            cli.cartao,
            cli.bandeira,
            cli.data_inicio,
            mult.iniciovigencia,
            case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
            mult.finalvigencia,
            mult.tipo_cobertura,
            mp.tipocotacao,
            mult.cep as cep_pernoite,
            mult.datacalculo,
            fab.nome         as fabricante,
            modelo.descricao as modelo,
            mult.anofabricacao,
            mult.anomodelo,
            mult.placa,
            mult.chassi,
            mult.bairro as cor,
            mult.numpassag as numpassageiros,
            mult.procedencia,
            div4.cod_conv as ag_captadora,
            div5.cod_conv as ag_cobradora,
            mult.valorbase                 as categoria,
            mult.cod_tabela as is_carroceria,
            qbr2.descricaosubresposta as dispositivo,
            mult.zerokm,
            mult.numdependentes as nf,
            mult.numero         as km_atual,
            mult.observacao     as data_km,
            vw_franq.texto,
            mp.franquiaauto     as valor_franquia,
            mult.cod_referencia as desconto,
            0 as desc_modulo,
            mult.nivelbonusauto,
            0 as opcao,
            div2.divisao_superior,
            div2.nome as estipulante,
            qbr.descricaoresposta,
            cob_obs.observacao,
            '' as cd_fipe,
            trg.texto      as congenere,
            mult.campo1    as apolice_renovada,
            mult.campo2    as vencimento,
            mult.campo5    as ci,
            mp.tipocotacao as verifica_obs_ajustado,
            mp.observacao  as obs_ajustado,
            mp.premio_auto as valor_ajustado,
            mult.niveldm,
            mp.premio_dm,
            mult.niveldp,
            mp.premio_dp,
            mult.valorappdmh,
            nvl(mpc.premio,0) as premio ,
            mult.valorappmorte,
            mp.premio_app_morte,
            mp.premio_app_invalidez,
            mult.valorveiculo as vl_veic_calc,
            mpc3.premio as premio_extra,
            0 as vl_premio_car_res,
            0 as vidros_opcao,
            0 as vl_premio_vidros,
            mult.estado as servicos,
            mp.premio_liquido,
            mpc46.premio as premio_perda,
            mpc46.valor as is_perda,
            mpc951.valor as is_kitgas,
            mpc951.premio as premio_kitgas,
            ((valor_primeira + (valor_demais * (parcelas - 1)))/1.0738) - mp.premio_liquido as juros,
            div3.divisao_superior                                                           as corretora,
            div3.nome                                                                       as nome_corretora,
            rc.ddd                                                                          as ddd_corretora,
            rc.telefone                                                                     as fone_corretora,
            mult.versaocalculo,
            vwt1.valor as valor,
           (select nvl(sum(aces.valor),0)as valor
                         from mult_calculoaces aces
                         where aces.calculo = mult.calculo and aces.subtipo = 2
                               and aces.valor > 0) + mult.lmi_kitgas as vl_acessorios,
                        (select nvl(sum(aces.valor),0)as valor
                         from mult_calculoaces aces
                         where aces.calculo = mult.calculo and aces.subtipo = 1
                               and aces.valor > 0) + mult.lmi_kitgas as vl_equipamentos,
        (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 50) as premio_equipamentos,
        (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 3) as premio_acessorios,
        (select prcob.premio from mult_calculopremioscob prcob where prcob.calculo = mult.calculo and prcob.cobertura = 2) as premio_carroceria,


            td.descricao                             as desc_tip_doc,
            mult.cidade                              as data_saida,
            0                            as opcao_des,
            div_com.desconto                         as desconto_ref,
            div_com.pro_labore                       as prolabore_ref,
            mult.o_ct_ids_,
            t2.subresposta2,
            mult.cod_referencia,
            round(mp.descontocomissao,2)as descontocomissao,
            mult.comissao,
            ''  as carroreserva,
            ((cp2.valor_primeira + (cp2.valor_demais * (cp2.parcelas - 1))) - (cp2.valor_primeira + (cp2.valor_demais * (cp2.parcelas - 1)))/1.0738) as iof,
            (cp2.valor_primeira  + (cp2.valor_demais * (cp2.parcelas - 1)))                                                              as premio_total,
            per2.opcao                                                                                                       as tipo_cartao,
            '0'                                                                                           as numero_cartao,
            '0'                                                                                           as validade_cartao,
            cob_conta.observacao                                                                                             as conta,
            cob_agencia.observacao                                                                                           as agencia,
            cob_nomeagencia.observacao                                                                                       as nomeagencia,
            cob_cidadeagencia.observacao                                                                                     as cidadeagencia,
            per2.descricao                                                                                                   as cobranca,
            cob_dia.valor                                                                                                    as dia,
            cp2.valor_primeira,
            cp2.valor_demais,
            cp2.parcelas,
            mult.estcvcondu,
            mult.sexocondu,
            mult.dtnascondu,
            mult.lmi_kitgas,
            mult.lmi_blindagem,
            mult.tipousoveic,
            mult.nomecondu,
            mult.cpfcondu,
            mult.cnhcondu,
            mult.valorbase,
            mult.cidade as data_mult,
            mult.ciarenova,
            qbr2.descricaosubresposta2,
            qbr2.descricaosubresposta,
            qbr2.resposta2,
            qbr2.subresposta,
            qbr2.descricaoresposta2,
            disp.tipo as prod_disp,
            mp.observacao  as obs_cobertura,
            mult.calculoorigem,
            cob_op.escolha,
            qbr.resposta,
            cp2.condicao,
            mult.datavencimento,
            cob_dv.observacao  as obs_dv,
            cob_dv2.observacao as obs_dv2,
            mult.dv,
            mult.numerotitulo,
            mult.mversao,
            mult.cidade as dt_saida_veic,
            mult.ids_aceitacao,
            mult.tipodocumento,
            mult.desc_score,
            mult.tipo_desc_score,
            mult.retornocrivo,
            mult.situacao,
            mult.dataemissao,
            mult.datatransmissao,
            mult.valor_custo_emissao,
            mult.validado,
            mult.iniciovigenciarenov,
            mult.finalvigenciarenov,
            mult.tiposeguro,
            mult.chassirenov,
            mult.valorveiculorenov,
            cob_banco.opcao as banco,
            mult.calculo,
            mult.agravo,
            mult.o_versaoids,
            mult.protocolotrans,
            mult.vistoriaprevia,
            par_parentesco.valor as parentesco,
            par_nome.observacao as nome_parente,
            par_cpf.observacao as cpf_parente,
            mult.tipocobranca,
            mc_vidros.opcao as opcao_vidros,
            mult.desconto_cc,
            mult.agravo_cc,
            mult.numeronegocioreservado,
            mult.numeroitemreservado,
            tv.descricao as tipoveiculo,
            carroce.texto as carroceria,
            tabrg.texto as combustivel,
            cfg.Valor as DiasPA,
            cfg2.Valor as DiasPAnovo,
            mult.dataversao,
            cp2.FORMA_PAGAMENTO,
            nvl(mult.calc_pai,0) as calc_pai,
            McRMM.INADIMPLENTE,
            PANOVA.opcao,
      mult.diapagtorenov as DataBoa,
            rmm.nr_cpf_cnpj,
            ids.cod_batente,
            mult.Tipo_Oferta
      from  mult_calculo mult,
            tabela_veiculofabric fab,
            tabela_veiculomodelo modelo,
            vw_tabrg_p11_t80 vw_franq,
            mult_calculopremios mp,
            tabela_divisoes div2,
            mult_calculoqbr qbr,
            mult_calculopremioscob mpc,
            mult_calculoqbr qbr2,
            vw_tabrg_p11_t1 vwt1,
            mult_calculopremioscob mpc3,
            mult_calculopremioscob mpc46,
            tabela_divisoes div3,
            mult_calculodivisoes md3,
            real_corretores rc,
            mult_calculocondpar cp2,
            tabela_divisoescomer div_com,
            mult_calculodivisoes mdref,mult_calculodivisoes mdref2,
            mult_produtosqbrdispseg disp,mult_calculoqbr t2,
            real_usuarios usu,tabela_clientes cli,
            tabela_clientender cliend,
            tabela_clientfones tel_res,
            tabela_clientfones tel_cel,
            tabela_divisoes div4,
            tabela_divisoes div5,
            mult_calculodivisoes md4,
            mult_calculodivisoes md5,
            mult_calculocob cob_obs,
            mult_produtostabrg trg,
            real_tipodoc td,
            mult_produtoscobperopc per2,
            mult_calculocob cob_banco,
            mult_calculocob cob_cartao,
            mult_calculocob cob_conta,
            mult_calculocob cob_agencia,
        mult_calculocob cob_nomeagencia,
        mult_calculocob cob_cidadeagencia,
        mult_calculocob cob_dia,
            mult_calculocobop cob_op,
            mult_calculocob cob_dv,
            mult_calculocob cob_dv2,
            mult_calculodivisoes md2,
            mult_calculocob par_parentesco,
            mult_calculocob par_nome,
            mult_calculocob par_cpf,
            mult_calculocob mc_vidros,
            VW_VALORBASE_CARGA tv,
            mult_produtostabrg carroce,
            real_anosauto aa,
            mult_produtostabrg tabrg,
            mult_produtos produtos,
          Tabela_Configuracoes_KCW cfg,
            Tabela_Configuracoes_KCW cfg2,
          mult_calculopremioscob mpc951,
          Mult_CalculoRenovacaoMM McRMM,
            MULT_CALCULOCOB PANOVA,
            tb_carga_renov_mm rmm,
            mult_calculoids ids

        where --mult.calculo = 4428705 and
            mult.modelo = modelo.modelo(+)
            And Mult.Iniciovigencia Between Vw_Franq.Dt_Inico_Vigen And Vw_Franq.Dt_Fim_Vigen
            and ((mult.tipo_franquia = Vw_Franq.CHAVE2)and(Vw_Franq.CHAVE1 = 1))-- mult.mversao))
            and mult.fabricante = fab.fabricante(+)
            and ((mult.calculo                = mp.calculo(+))
            and (mp.escolha (+)               = 'S'))
            and ((mult.calculo = md2.calculo(+))and(md2.nivel (+)= 4)and(div2.divisao (+)= md2.divisao))
            and ((mult.calculo = md3.calculo(+))and(md3.nivel (+)= 1)and(div3.divisao (+)= md3.divisao))
            and ((mult.calculo = qbr.calculo(+)) and (qbr.questao (+)= 222))
            and ((mult.calculo = mpc.calculo(+))and(mpc.cobertura (+)= 64)and(mpc.produto (+)= 11))
            and ((mult.calculo = mpc3.calculo(+))and(mpc3.cobertura (+)= 1000)and(mpc3.produto (+)= 11))
            and ((mult.calculo = mpc46.calculo(+))and(mpc46.cobertura (+)= 46)and(mpc46.produto (+)= 11))
            and ((mult.calculo = qbr2.calculo(+)) and (qbr2.questao (+)= 244)and(qbr2.valida (+)= 'S'))
      and ((mult.calculo = mpc951.calculo(+))and(mpc951.cobertura (+)= 951)and(mpc951.produto (+)= 11))
            and vwt1.chave1 (+)= 2
            and mult.cliente = cli.cliente(+)
            and ((cli.cliente                 = cliend.cliente(+))
            and (cliend.endereco              is not null))
            and ((cli.cliente                 = tel_res.cliente(+))
            and (tel_res.CLIENTE_FONE (+)    = 1))
            and ((cli.cliente                 = tel_cel.cliente(+))
            and (tel_cel.CLIENTE_FONE (+)    = 4 ))
            and ((mult.calculo                = md4.calculo(+))
            and(md4.nivel (+)                 = 2)
            and(div4.divisao (+)              = md4.divisao))
            and ((mult.calculo                = md5.calculo(+))
            and(md5.nivel (+)                 = 3)
            and(div5.divisao (+)              = md5.divisao))
            and ((mult.calculo                = cob_obs.calculo(+))
            and (cob_obs.cobertura (+)        = 70))
            and ((mult.ciarenova              = trg.valor(+))
            and (trg.produto (+)              = 0))
            and (cli.foto                     = td.tipo(+))
            and ((mult.calculo                = cob_banco.calculo(+))
            and (cob_banco.cobertura (+)          = 957))
            and ((mult.calculo                = cob_conta.calculo(+))
            and (cob_conta.cobertura (+)      = 959))
            and ((mult.calculo                = cob_cartao.calculo(+))
            and (cob_cartao.cobertura (+)     = 960)
            and (cob_cartao.condutor (+)       = 0)
            and (per2.opcao (+)               = cob_cartao.opcao)
            and (per2.produto (+)              = 10)
            and (per2.cobertura (+)            = cob_cartao.cobertura) )
            and ((mult.calculo                = cob_agencia.calculo(+))
            and (cob_agencia.cobertura (+)    = 958)
            and (cob_agencia.condutor (+)     = 0))
        and ((mult.calculo                = cob_nomeagencia.calculo(+))
            and (cob_nomeagencia.cobertura (+)    = 940)
            and (cob_nomeagencia.condutor (+)     = 0))
      and ((mult.calculo                = cob_cidadeagencia.calculo(+))
            and (cob_cidadeagencia.cobertura (+)    = 941)
            and (cob_cidadeagencia.condutor (+)     = 0))
      and ((mult.calculo                = cob_dia.calculo(+))
            and (cob_dia.cobertura (+)        = 987)
            and (cob_dia.condutor (+)         = 0))
            and ((mult.calculo                = cob_op.calculo(+))
            and (cob_op.item (+)              = 0)
            and (cob_op.cobertura (+)         = 1007))
            and ((mult.calculo                = cob_dv.calculo(+))
            and (cob_dv.cobertura (+)         = 1027))
            and ((mult.calculo                = cob_dv2.calculo(+))
            and (cob_dv2.cobertura (+)        = 1008))
            and ((mult.calculo                = par_parentesco.calculo(+))
            and (par_parentesco.cobertura (+) = 991))
            and ((mult.calculo                = par_nome.calculo(+))
            and (par_nome.cobertura (+) = 992))
            and ((mult.calculo                = par_cpf.calculo(+))
            and (par_cpf.cobertura (+) = 993))
            and ((mult.calculo                = mc_vidros.calculo(+))
            and (mc_vidros.cobertura (+) = 40))
            and rc.corretor = div3.divisao_superior
            and ((mult.calculo                = cp2.calculo(+))
            and (cp2.escolha (+)               = 'S'))
            and ((mult.calculo = mdref.calculo(+))and(mdref2.calculo (+)= mdref.calculo)and(div_com.divisao (+)= mdref.divisao)and(mdref.nivel (+)= 4)and (mdref2.nivel (+)= 1)and(div_com.produto (+)= 11)
            and ((mult.dataversao between div_com.iniciovigencia and div_com.finalvigencia) OR (div_com.desconto is null)))
            and ((disp.produto (+)= 11) and (disp.vigencia (+)= 1) and (disp.dispositivo (+)= qbr2.subresposta))
            and ((mult.item (+)= 0)and(mult.calculo = t2.calculo(+))and(mult.item = t2.item(+))and(t2.questao (+)= 244))
            and ((usu.cod_usuario = mult.cod_usuario) and (usu.corretor = div3.divisao)and (usu.iniciovigencia = (select max(iniciovigencia)
                from real_usuarios where cod_usuario = mult.cod_usuario and corretor = div3.divisao)))
            and mult.calculo = p_calculo
            and mult.padrao = produtos.produto
            and tv.valorbase = mult.valorbase
            and ((nvl(mult.tipo_carroceria,0) = 0) or
                 (CARROCE.chave2 = mult.tipo_carroceria and
                     CARROCE.TABELA = 333 and
                     CARROCE.PRODUTO = 11 and
                     MULT.INICIOVIGENCIA between CARROCE.DT_INICO_VIGEN and CARROCE.DT_FIM_VIGEN))
            and aa.modelo = mult.modelo
            and aa.anode = mult.anomodelo
            and tabrg.chave2 = aa.codigo_combustivel
            and tabrg.produto = 11
            and tabrg.tabela = 181
            AND PANOVA.COBERTURA = 960  AND PANOVA.CALCULO = MULT.CALCULO
            and mult.iniciovigencia between tabrg.dt_inico_vigen and tabrg.dt_fim_vigen
            and cfg.Parametro = 'DIAS_PA_11_'||mult.TipoSeguro
            and cfg2.Parametro = 'DIAS_PA_11_'||mult.TipoSeguro||'_'||PANOVA.OPCAO||'_'||mult.tipocobranca||'_NOVO'
            and McRMM.calculo (+)= mult.Calculo
            and rmm.CD_APOLI_SUSEP (+)= McRMM.apoliceanterior
            and ids.calculo = mult.calculo

      and rownum = 1;

        exception
            when others then
                raise;
end;
/


CREATE OR REPLACE PROCEDURE        PRC_PROPOSTA_CONDOMINIO ( p_calculo mult_calculo.calculo%type,
                                                     p_cproposta_condominio out types.cursor_type ) is
begin

    open p_cproposta_condominio for
        select
        mult.calculo,
        mult.nome as proponente,
        mult.iniciovigencia,
		case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
        mult.finalvigencia,
        opc_tipocobertura.descricao as tipocondominio,
        opc_regiao.descricao as regiao,
        mult.datacalculo,
        mult.ciarenova,
        qtdeanos2.opcao qtdanos2,
        mult.cep,
        desccongenere.texto congenere,
        numeronegocio2.observacao no_negocio2,
        estipulantes.divisao_superior cod_estipulante,
        estipulantes.nome nome_estipulante,
        case when mult.InicioVigencia < PRODUTOS.VALIDADE then
		  PRODUTOS.banco_veic
		else
		  PRODUTOS.VERSAO
		end versaocalculo,
        mult.cod_referencia,
        mult.comissao,
        mult.calculoorigem,
        mult.retornocrivo,
        mult.fabricante,
        corretores.divisao_superior cod_corretor,
        corretores.nome nome_corretor,
        corretores_fones.ddd ddd_corretor,
        --corretores_fones.telefone telefone_corretor,
        CASE  WHEN    corretores.divisao_superior    =  98626  or corretores.divisao_superior    =  88626
        THEN   '0800 727 2900'
        ELSE     '('||corretores_fones.ddd||') ' || substr(corretores_fones.telefone,1,4) ||'-'|| substr(corretores_fones.telefone,5,4)
        END AS   telefone_corretor,
        qtdeanos.opcao qtdanos,
        numeronegocio.observacao no_negocio,
        taxas.taxa * 10000000 taxa,
        estipulantes_com.pro_labore,
        estipulantes_com.desconto,
        mult.validado,
        mult.agravo,
        produtos.validade,
        produtos.versao,
        clientes.nome,
        clientes.tipo_pessoa,
        clientes.cgc_cpf cnpj_cpf,
        clientes.e_mail email,
        clientes.home_page recebe_email,
        clientes.data_nascimento,
        clientes.sexo,
        clientes.cartao numero_documento,
        tipodoc.descricao tipo_documento,
        clientes.bandeira orgao_emissor,
        clientes.data_inicio data_expedicao,
        clientesender.cep cepcliente,
        clientesender.endereco enderecocli,
        clientesender.numero numerocli,
        clientesender.complemento complementocli,
        clientesender.bairro bairrocli,
        clientesender.cidade cidadecli,
        clientesender.estado estadocli,
        clientesfonesres.ddd dddcli,
        CLIENTESFONESRES.TELEFONE TELEFONECLI1,
        clientesfonescom.ddd dddcli2,
        clientesfonescom.telefone telefonecli2,
        tipodoc.descricao tipo_documentocli,
        vagas.valor as vagas,
        mult.valorbase,
        mult.endereco,
        mult.bairro,
        mult.cidade,
        mult.complemento,
        mult.numero,
        mult.estado,
        tbagencia.observacao agencia,
        tbnomeagencia.observacao nomeagencia,
        tbcidadeagencia.observacao cidadeagencia,
        desccobranca.descricao cobranca,
        tbbanco.opcao banco,
        tbconta.observacao conta,
        tbdiapgto.observacao dia_pgto,
        descagcaptadora.cod_conv ag_captadora,
        mult.valor_custo_emissao,
        mult.dv,
        tbnumtitulo.observacao numtitulo_cob,
        tbdigito.observacao dv_cob,
        tbpgtoantecipado.escolha pagto_antecipado,
        mult.numerotitulo,
        mult.datavencimento,
        mult.tipologradouro tipologradouro_ris,
        clientesender.tipologradouro tipologradouro_end,
        mult.protocolotrans,
        mult.situacao,
        tbtipogaragista.opcao tipo_garagista,
        tbparentesco.valor parentesco,
        tbnometitular.observacao nometitular,
        tbcpftitular.observacao cpftitular,
        mult.campo2 as vencimentocongenere,
        mult.tipocobranca,
        tbsinistralidade.valor as sinistralidade,
        mult.desconto_cc,
        mult.agravo_cc,
        mult.numeronegocioreservado,
        mult.numeroitemreservado,
        cobtpseguro.opcao as tiposeguro,
        mult.DATAEMISSAO,
        mult.DATATRANSMISSAO,
		mult.vistoriaprevia,
		tbInspecao.nome NomeContato,
		tbInspecao.dddtel DDDTelContato,
		tbInspecao.telefone TelefoneContato,
		tbInspecao.dddcel DDDCelContato,
		tbInspecao.celular CelularContato,
		tbInspecao.email EmailContato,
		cfg.Valor DiasPA,
		cfg2.valor diaspanovo,
		PANOVA.opcao,
    mult.diapagtorenov as DataBoa
        from
        mult_calculo mult,
        mult_calculodivisoes mult_estip,
        tabela_divisoes estipulantes,
        tabela_divisoescomer estipulantes_com,
        mult_calculodivisoes mult_corretor,
        tabela_divisoes corretores,
        tabela_divisoesfones corretores_fones,
        mult_calculocob tipocondominio,
        mult_calculocob regiao,
        mult_calculocob qtdeanos,
        mult_calculocob numeronegocio,
        mult_calculocob qtdeanos2,
        mult_calculocob numeronegocio2,
        mult_calculocob vagas,
        vw_tabrg_p0_t1 desccongenere,
        mult_calculocob taxas,
        mult_produtoscobperopc opc_tipocobertura,
        mult_produtoscobperopc opc_regiao,
        mult_produtos produtos,
        tabela_clientes clientes,
        tabela_clientfones clientesfonesres,
        tabela_clientfones clientesfonescom,
        tabela_clientender clientesender,
        real_tipodoc tipodoc,
        mult_calculocob tbagencia,
        mult_calculocob tbnomeagencia,
        mult_calculocob tbcidadeagencia,
        mult_calculocob tbcobranca,
        mult_produtoscobperopc desccobranca,
        mult_calculocob tbbanco,
        mult_calculocob tbconta,
        mult_calculocob tbdigito,
        mult_calculocob tbnumtitulo,
        mult_calculocob tbdiapgto,
        mult_calculocob tbparentesco,
        mult_calculocob tbcpftitular,
        mult_calculocob tbnometitular,
        mult_calculodivisoes agcaptadora,
        tabela_divisoes descagcaptadora,
        mult_calculocobop tbpgtoantecipado,
        mult_calculocob tbtipogaragista,
        mult_calculocob tbsinistralidade,
        mult_calculocob cobtpseguro,
		Mult_CalculoContatoInspecao tbInspecao,
		Tabela_Configuracoes_KCW cfg,
		Tabela_Configuracoes_KCW cfg2,
		MULT_CALCULOCOB PANOVA
        where
        --MULT.CALCULO = 4428757 AND
        mult_estip.calculo(+) = mult.calculo
        and mult_estip.nivel(+) = 4
        and estipulantes.divisao(+) = mult_estip.divisao
        and mult_corretor.calculo = mult.calculo
        and mult_corretor.nivel = 1
        and corretores.divisao = mult_corretor.divisao
        and corretores_fones.divisao(+) = corretores.divisao
        and (estipulantes.divisao is null or estipulantes_com.divisaocom = mult_corretor.divisao or mult.calculo > 0)
        and estipulantes_com.divisao(+) = mult_estip.divisao
        and estipulantes_com.produto(+) = 4
        and qtdeanos.calculo(+) = mult.calculo
        and qtdeanos.cobertura = 981
        and cobtpseguro.calculo(+) = mult.calculo
        and cobtpseguro.cobertura = 962
        and numeronegocio.calculo(+) = mult.calculo
        and numeronegocio.cobertura(+) = 70
        and qtdeanos2.calculo(+) = mult.calculo
        and qtdeanos2.cobertura = 972
        and numeronegocio2.calculo(+) = mult.calculo
        and numeronegocio2.cobertura(+) = 17
        and taxas.calculo = mult.calculo
        and taxas.cobertura = 19
        and desccongenere.valor = mult.ciarenova
        and tipocondominio.calculo = mult.calculo
        and tipocondominio.cobertura = 986
        and opc_tipocobertura.opcao = tipocondominio.opcao
        and opc_tipocobertura.cobertura = tipocondominio.cobertura
        and opc_tipocobertura.produto = 2
        and regiao.calculo = mult.calculo
        and regiao.cobertura = 985
        and opc_regiao.opcao = regiao.opcao
        and opc_regiao.cobertura = regiao.cobertura
        and opc_regiao.produto = 2
        and produtos.produto = mult.padrao
        and clientes.cliente = mult.cliente
        and tipodoc.tipo (+)= clientes.foto
        and clientesender.cliente = clientes.cliente
        and clientesender.tipo_endereco = 1
        and clientesfonesres.cliente = clientes.cliente
        and clientesfonesres.cliente_fone = 1
        and clientesfonescom.cliente = clientes.cliente
        and clientesfonescom.cliente_fone = 4
        and tipodoc.tipo (+)= clientes.foto
        and vagas.calculo(+) = mult.calculo
        and vagas.cobertura = 983
        and tbagencia.calculo = mult.calculo
        and tbagencia.cobertura (+)= 958
        and tbnomeagencia.calculo(+)= mult.calculo
        and tbnomeagencia.cobertura(+) = 940
        and tbcidadeagencia.calculo(+)= mult.calculo
        and tbcidadeagencia.cobertura(+) = 941
        and tbcobranca.calculo = mult.calculo
        and tbcobranca.cobertura = 960
        and desccobranca.cobertura(+) = tbcobranca.cobertura
        and desccobranca.opcao(+) = tbcobranca.opcao
        and desccobranca.produto = 2
        and tbbanco.calculo= mult.calculo
        and tbbanco.cobertura = 957
        and tbconta.calculo = mult.calculo
        and tbconta.cobertura = 959
        and tbdiapgto.calculo = mult.calculo
        and tbdiapgto.cobertura = 987
        and tbdigito.calculo = mult.calculo
        and tbdigito.cobertura = 1027
        and tbnumtitulo.calculo = mult.calculo
        and tbnumtitulo.cobertura = 1008
        and agcaptadora.calculo = mult.calculo
        and agcaptadora.nivel = 2
        and descagcaptadora.divisao = agcaptadora.divisao
        and tbpgtoantecipado.calculo = mult.calculo
        and tbpgtoantecipado.cobertura = 1007
        and tbtipogaragista.calculo = mult.calculo
        and tbtipogaragista.cobertura = 984
        and tbtipogaragista.condutor = 0
        and tbparentesco.calculo(+) = mult.calculo
        and tbparentesco.cobertura(+) = 991
        and tbnometitular.calculo(+) = mult.calculo
        and tbnometitular.cobertura(+) = 992
        and tbcpftitular.calculo(+) = mult.calculo
        and tbcpftitular.cobertura(+) = 993
        and tbsinistralidade.calculo(+) = mult.calculo
        and tbsinistralidade.cobertura(+) = 996
		and tbInspecao.calculo(+) = mult.calculo
        and mult.calculo = p_calculo
		and mult.padrao = produtos.produto
		AND PANOVA.COBERTURA = 960  AND PANOVA.CALCULO = MULT.CALCULO
		and cfg.Parametro = 'DIAS_PA_2_'||cobtpseguro.Opcao
		and cfg2.Parametro = 'DIAS_PA_2_'||cobtpseguro.Opcao||'_'||PANOVA.OPCAO||'_'||mult.tipocobranca||'_NOVO'
        and rownum = 1;

        exception
            when others then
                raise;

end;
/


CREATE OR REPLACE PROCEDURE        PRC_PROPOSTA_EMPRESARIAL ( p_calculo mult_calculo.calculo%type,
                                    p_cproposta_empresarial out types.cursor_type ) is
begin
    open p_cproposta_empresarial for
        select
        mult.calculo,
        mult.datacalculo,
        mult.cod_cidade,
        mult.cep cep_seguro,
        mult.endereco endereco_seguro,
        mult.numero numero_seguro,
        mult.complemento complemento_seguro,
        mult.bairro bairro_seguro,
        mult.cidade cidade_seguro,
        mult.estado estado_seguro,
        case when mult.InicioVigencia < PRODUTOS.VALIDADE then
		  PRODUTOS.banco_veic
		else
		  PRODUTOS.VERSAO
		end versaocalculo,
        mult.cod_referencia,
        mult.comissao,
        mult.calculoorigem,
        mult.retornocrivo,
        mult.iniciovigencia,
		case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
        mult.finalvigencia,
        mult.apol_ren_tokio,
        mult.item_ren_tokio,
        mult.bonus_ren_tokio,
        mult.validado,
        mult.dv,
        mult.angariador produtor,
        mult.tipodocumento,
        mult.situacao,
        mult.numerotitulo,
        mult.datavencimento,
        mult.valor_custo_emissao,
        mult.datatransmissao,
        mult.dataemissao,
        grupos.texto grupo,
        mult.fabricante cod_atividade,
        atividades.texto atividade,
        corretores.divisao_superior cod_corretor,
        corretores.nome nome_corretor,
        corretores_fones.ddd ddd_corretor,
        CASE  WHEN    corretores.divisao_superior    =  98626  or corretores.divisao_superior    =  88626
        THEN   '0800 727 2900'
        ELSE     '('||corretores_fones.ddd||') ' || substr(corretores_fones.telefone,1,4) ||'-'|| substr(corretores_fones.telefone,5,4)
        END AS   telefone_corretor,
        --corretores_fones.telefone telefone_corretor,
        estipulantes.divisao_superior cod_estipulante,
        estipulantes.nome nome_estipulante,
        qtdeanos.opcao qtdanos,
        numeronegocio.observacao no_negocio,
        taxas.taxa * 10000000 taxa,
        estipulantes_com.pro_labore,
        estipulantes_com.desconto,
        produtos.validade,
        mult.valorappmorte valor_declarado,
        mult.valorbase,
        '0' as desconto_modulo,
        2 as tipo_relacionamento,
        clientes.nome,
        clientes.tipo_pessoa,
        clientes.cgc_cpf cnpj_cpf,
        clientes.e_mail email,
        clientes.home_page recebe_email,
        clientes.data_nascimento,
        clientes.sexo,
        clientes.cartao numero_documento,
        tipodoc.descricao tipo_documento,
        clientes.bandeira orgao_emissor,
        clientes.data_inicio data_expedicao,
        clientesender.cep,
        clientesender.endereco,
        clientesender.numero,
        clientesender.complemento,
        clientesender.bairro,
        clientesender.cidade,
        clientesender.estado,
        clientesfonesres.ddd,
        CLIENTESFONESRES.TELEFONE TELEFONE1,
        clientesfonescom.ddd ddd2,
        clientesfonescom.telefone telefone2,
        '0' as no_cartao,
        '0' as validade_cartao,
        tbagencia.observacao agencia,
        tbnomeagencia.observacao nomeagencia,
        tbcidadeagencia.observacao cidadeagencia,
        tbbanco.opcao banco,
        tbconta.observacao conta,
        tbdiapgto.observacao dia_pgto,
        desccobranca.descricao cobranca,
        descagcaptadora.cod_conv ag_captadora,
        descagcobradora.cod_conv ag_cobradora,
        tbnumtitulo.observacao numtitulo_cob,
        tbdigito.observacao dv_cob,
        tbpgtoantecipado.escolha pagto_antecipado,
        cobertura.opcao tipo_cobertura,
        roubovalores.valor valor_roubo_valores,
        rcgcomp.valor valor_rcgcomp,
        rcgir.valor valor_rcgir,
        mult.tipologradouro tipologradouro_ris,
        clientesender.tipologradouro tipologradouro_end,
        qtdeanos2.opcao qtdanos2,
        numeronegocio2.observacao no_negocio2,
        desccongenere.texto congenere,
        mult.ciarenova,
        mult.agravo,
        mult.protocolotrans,
        tbparentesco.valor parentesco,
        tbnometitular.observacao nometitular,
        tbcpftitular.observacao cpftitular,
        mult.campo2 as vencimentocongenere,
        mult.tipocobranca,
        tbsinistralidade.valor as sinistralidade,
        cobtpseguro.opcao as tiposeguro,
        Localizacao.opcao as localizacao,
		    cfg.Valor as DiasPA,
				cfg2.Valor as DiasPANovo,
				calccob.opcao as shopinsn,
	    	PANOVA.opcao,
        mult.diapagtorenov as DataBoa,
        nvl(percbatente.valor1,0) as percbatente,
        mult.desconto_cc,
        mult.agravo_cc,
        mult.numeronegocioreservado,
        mult.numeroitemreservado
        from
				mult_calculocob calccob,
        mult_calculo mult,
        vw_tabrg_p4_t10 grupos,
        vw_tabrg_p4_t104 atividades,
        mult_calculodivisoes mult_estip,
        tabela_divisoes estipulantes,
        tabela_divisoescomer estipulantes_com,
        mult_calculodivisoes mult_corretor,
        tabela_divisoes corretores,
        tabela_divisoesfones corretores_fones,
        mult_calculocob qtdeanos,
        mult_calculocob numeronegocio,
        mult_calculocob taxas ,
        mult_produtos produtos,
        tabela_clientes clientes,
        tabela_clientfones clientesfonesres,
        tabela_clientfones clientesfonescom,
        tabela_clientender clientesender,
        real_tipodoc tipodoc,
        mult_calculocob roubovalores,
        mult_calculocob rcgcomp,
        mult_calculocob rcgir,
        mult_calculocob tbcobranca,
        mult_calculocob tbbanco,
        mult_calculocob tbagencia,
        mult_calculocob tbnomeagencia,
        mult_calculocob tbcidadeagencia,
        mult_calculocob tbconta,
        mult_calculocob tbdigito,
        mult_calculocob tbnumtitulo,
        mult_calculocob tbdiapgto,
        mult_calculocob cobertura,
        mult_calculocob tbparentesco,
        mult_calculocob tbcpftitular,
        mult_calculocob tbnometitular,
        mult_calculocobop tbpgtoantecipado,
        mult_produtoscobperopc desccobranca,
        mult_calculodivisoes agcaptadora,
        tabela_divisoes descagcaptadora,
        mult_calculodivisoes agcobradora,
        tabela_divisoes descagcobradora,
        mult_calculocob qtdeanos2,
        vw_tabrg_p0_t1 desccongenere,
        mult_calculocob numeronegocio2,
        mult_calculocob tbsinistralidade,
        mult_calculocob cobtpseguro,
        mult_calculocob Localizacao,
	    	Tabela_Configuracoes_KCW cfg,
	    	Tabela_Configuracoes_KCW cfg2,
	    	MULT_CALCULOCOB PANOVA,
        mult_calculoBatenteControle percbatente

        where
        --MULT.CALCULO = 4420861 AND
        grupos.chave2  = mult.modelo
        and atividades.chave1 = 1
        and atividades.chave3 = mult.fabricante
        and mult_estip.calculo(+) = mult.calculo
        and mult_estip.nivel(+) = 4
        and estipulantes.divisao(+) = mult_estip.divisao
        and mult_corretor.calculo = mult.calculo
        and mult_corretor.nivel = 1
        and corretores.divisao = mult_corretor.divisao
        and corretores_fones.divisao(+) = corretores.divisao
        and (estipulantes.divisao is null or estipulantes_com.divisaocom = mult_corretor.divisao)
        and estipulantes_com.divisao(+) = mult_estip.divisao
        and estipulantes_com.produto(+) = 4
        and qtdeanos.calculo(+) = mult.calculo
        and qtdeanos.cobertura(+) = 981
        and cobtpseguro.calculo(+) = mult.calculo
        and cobtpseguro.cobertura = 962
        and numeronegocio.calculo(+) = mult.calculo
        and numeronegocio.cobertura(+) = 70
        and taxas.calculo = mult.calculo
        and taxas.cobertura = 19
        and produtos.produto = mult.padrao
        and clientes.cliente = mult.cliente
        and tipodoc.tipo (+)= clientes.foto
        and clientesender.cliente = clientes.cliente
        and clientesender.tipo_endereco = 1
        and clientesfonesres.cliente = clientes.cliente
        and clientesfonesres.cliente_fone = 1
        and clientesfonescom.cliente = clientes.cliente
        and clientesfonescom.cliente_fone = 4
        and tbagencia.calculo= mult.calculo
        and tbagencia.cobertura = 958
        and tbnomeagencia.calculo(+)= mult.calculo
        and tbnomeagencia.cobertura(+) = 940
        and tbcidadeagencia.calculo(+)= mult.calculo
        and tbcidadeagencia.cobertura(+) = 941
        and tbbanco.calculo= mult.calculo
        and tbbanco.cobertura = 957
        and tbconta.calculo = mult.calculo
        and tbconta.cobertura = 959
        and tbdiapgto.calculo = mult.calculo
        and tbdiapgto.cobertura = 987
        and tbcobranca.calculo = mult.calculo
        and tbcobranca.cobertura = 960
        and desccobranca.cobertura(+) = tbcobranca.cobertura
        and desccobranca.opcao(+) = tbcobranca.opcao
        and desccobranca.produto = 4
        and tbpgtoantecipado.calculo = mult.calculo
        and tbpgtoantecipado.cobertura = 1007
        and tbnumtitulo.calculo = mult.calculo
        and tbnumtitulo.cobertura = 1008
        and tbdigito.calculo = mult.calculo
        and tbdigito.cobertura = 1027
        and cobertura.calculo = mult.calculo
        and cobertura.cobertura = 65
        and roubovalores.calculo = mult.calculo
        and roubovalores.cobertura = 29
        and rcgcomp.calculo = mult.calculo
        and rcgcomp.cobertura = 38
        and rcgir.calculo = mult.calculo
        and rcgir.cobertura = 965
        and agcaptadora.calculo = mult.calculo
        and agcaptadora.nivel = 2
        and descagcaptadora.divisao = agcaptadora.divisao
        and agcobradora.calculo = mult.calculo
        and agcobradora.nivel = 3
        and descagcobradora.divisao = agcobradora.divisao
        and qtdeanos2.calculo(+) = mult.calculo
        and qtdeanos2.cobertura(+) = 972
        and numeronegocio2.calculo(+) = mult.calculo
        and numeronegocio2.cobertura(+) = 17
        and tbparentesco.calculo(+) = mult.calculo
        and tbparentesco.cobertura(+) = 991
        and tbnometitular.calculo(+) = mult.calculo
        and tbnometitular.cobertura(+) = 992
        and tbcpftitular.calculo(+) = mult.calculo
        and tbcpftitular.cobertura(+) = 993
        and desccongenere.valor = mult.ciarenova
        and tbsinistralidade.calculo(+) = mult.calculo
        and tbsinistralidade.cobertura(+) = 996
        and mult.calculo = p_calculo
        and Localizacao.calculo(+) = mult.calculo
        and localizacao.cobertura(+) = 1004
	    	and mult.padrao = produtos.produto
    		AND PANOVA.COBERTURA = 960  AND PANOVA.CALCULO = MULT.CALCULO
		    and cfg.Parametro = 'DIAS_PA_4_'||cobtpseguro.Opcao
	    	and cfg2.parametro = 'DIAS_PA_4_'||cobtpseguro.Opcao||'_'||PANOVA.OPCAO||'_'||mult.tipocobranca||'_NOVO'
	    	and calccob.calculo = mult.calculo
				and calccob.cobertura = 1004
        and percbatente.calculo(+) = mult.calculo
        and percbatente.sequencia(+) = 20
        and rownum = 1
        and mult.iniciovigencia between Atividades.Dt_Inico_Vigen and atividades.dt_fim_vigen;


        exception
            when others then
                raise;
end;
/


CREATE OR REPLACE PROCEDURE          "PRC_PROPOSTA_RESIDENCIAL" ( p_calculo mult_calculo.calculo%type,
                                    p_cproposta_residencial out types.cursor_type ) is
begin
    open p_cproposta_residencial for
        select
			clientes.cliente,
			mult.calculo,
			mult.item,
			mult.datacalculo,
			mult.datatransmissao,
			mult.dataemissao,
			mult.iniciovigencia,
			case when mult.iniciovigencia < produtos.validade then 2 else 1 end Versao,
			mult.finalvigencia,
			mult.cod_cidade,
			mult.cep cep_seguro,
			mult.tipologradouro tipologradouro_seguro,
			mult.endereco endereco_seguro,
			mult.numero numero_seguro,
			mult.complemento complemento_seguro,
			mult.bairro bairro_seguro,
			mult.cidade cidade_seguro,
			mult.estado estado_seguro,
			case when mult.InicioVigencia < PRODUTOS.VALIDADE then
			  PRODUTOS.banco_veic
			else
			  PRODUTOS.VERSAO
			end versaocalculo,
			mult.comissao,
			mult.cod_referencia,
			mult.apol_ren_tokio,
			mult.item_ren_tokio,
			mult.bonus_ren_tokio,
			mult.calculoorigem,
			mult.retornocrivo,
			mult.validado,
			mult.dv,
			mult.angariador produtor,
			mult.tipodocumento,
			mult.situacao,
			mult.numerotitulo,
			mult.datavencimento,
			mult.valor_custo_emissao,
			imoveldesc.descricao tipo_imovel,
			ocupacaodesc.descricao tipo_ocupacao,
			construcao.opcao tipo_construcao,
			cobertura.opcao tipo_cobertura,
			condominio.opcao tipo_condominio,
			'2' as tipo_relacionamento,
			corretordesc.divisao_superior,
			to_char(corretordesc.divisao_superior) || ' ' || corretordesc.nome as corretor,
			to_char(estipdesc.divisao_superior) || ' ' || estipdesc.nome as estipulante,
			estipcom.desconto,
			estipcom.pro_labore,
			produtos.versao,
			produtos.validade,
      CASE  WHEN    corretordesc.divisao_superior    =  98626  or corretordesc.divisao_superior    =  88626
      THEN   '0800 727 2900'
      ELSE     '('||fonecorretor.ddd||') ' || substr(fonecorretor.telefone,1,4) ||'-'|| substr(fonecorretor.telefone,5,4)
      END AS   telefone,
			desccongenere.texto congenere,
			descapoliceant.observacao apoliceanterior,
			descrenovcongenere.opcao descontorenovcongenere,
			descnorenov.observacao numeronegociorenovacao,
			descrenovreal.opcao descontorenovreal,
			desctaxa.taxa * 10000000 taxa,
			clientes.nome,
			clientes.tipo_pessoa,
			clientes.cgc_cpf cnpj_cpf,
			clientes.e_mail email,
			clientes.home_page recebe_email,
			clientes.data_nascimento,
			clientes.sexo,
			clientes.cartao numero_documento,
			tipodoc.descricao tipo_documento,
			clientes.bandeira orgao_emissor,
			clientes.data_inicio data_expedicao,
			enderecos.cep,
			enderecos.tipologradouro,
			enderecos.endereco,
			enderecos.numero,
			enderecos.complemento,
			enderecos.bairro,
			enderecos.cidade,
			enderecos.estado,
			telefoneres.ddd,
			telefoneres.telefone telefone1,
			telefonecom.ddd as ddd2,
			telefonecom.telefone telefone2,
			'0' as no_cartao,
			'0' as validade_cartao,
			tbagencia.observacao agencia,
      tbnomeagencia.observacao nomeagencia,
      tbcidadeagencia.observacao cidadeagencia,
			tbconta.observacao conta,
			tbbanco.opcao banco,
			tbdiapgto.observacao dia_pgto,
			desccobranca.descricao cobranca,
			descagcaptadora.cod_conv ag_captadora,
			descagcobradora.cod_conv ag_cobradora,
			tbassistencia.opcao assitencia_24h,
			tbnumtitulo.observacao numtitulo_cob,
			tbdigito.observacao dv_cob,
			'0' as descmodulo,
			tbpgtoantecipado.escolha pagto_antecipado,
			mult.agravo,
			mult.protocolotrans,
			tbparentesco.valor parentesco,
			tbnometitular.observacao nometitular,
			tbcpftitular.observacao cpftitular,
			mult.campo2 as vencimentocongenere,
			mult.tipocobranca,
			tbsinistralidade.valor as sinistralidade,
			mult.desconto_cc,
			mult.agravo_cc,
			mult.numeronegocioreservado,
			mult.numeroitemreservado,
			cobtpseguro.opcao as tiposeguro,
			mult.vistoriaprevia,
			tbInspecao.nome NomeContato,
			tbInspecao.dddtel DDDTelContato,
			tbInspecao.telefone TelefoneContato,
			tbInspecao.dddcel DDDCelContato,
			tbInspecao.celular CelularContato,
			tbInspecao.email EmailContato,
			cfg.Valor DiasPA,
			cfg2.valor DiasPANovo,
			tbcobranca.opcao,
      mult.diapagtorenov as DataBoa
        from
			mult_calculo mult,
			mult_calculocob imovel,
			mult_produtoscobperopc imoveldesc,
			mult_calculocob ocupacao,
			mult_produtoscobperopc ocupacaodesc,
			mult_calculocob construcao,
			mult_calculocob cobertura,
			mult_calculocob condominio,
			mult_calculodivisoes estip,
			mult_calculodivisoes corretor,
			tabela_divisoes corretordesc,
			tabela_divisoes estipdesc,
			tabela_divisoesfones fonecorretor,
			tabela_divisoescomer estipcom,
			mult_produtos produtos,
			vw_tabrg_p0_t1 desccongenere,
			mult_calculocob descapoliceant,
			mult_calculocob descrenovcongenere,
			mult_calculocob descnorenov,
			mult_calculocob descrenovreal,
			mult_calculocob desctaxa,
			mult_calculocob tbagencia,
      mult_calculocob tbnomeagencia,
      mult_calculocob tbcidadeagencia,
			mult_calculocob tbconta,
			mult_calculocob tbdigito,
			mult_calculocob tbnumtitulo,
			mult_calculocob tbdiapgto,
			mult_calculocob tbassistencia,
			mult_calculocob tbbanco,
			mult_calculocob tbparentesco,
			mult_calculocob tbcpftitular,
			mult_calculocob tbnometitular,
			tabela_clientes clientes,
			tabela_clientfones telefoneres,
			tabela_clientfones telefonecom,
			tabela_clientender enderecos,
			real_tipodoc tipodoc,
			mult_calculocob tbcobranca,
			mult_produtoscobperopc desccobranca,
			mult_calculodivisoes agcaptadora,
			tabela_divisoes descagcaptadora,
			mult_calculodivisoes agcobradora,
			tabela_divisoes descagcobradora,
			mult_calculocobop tbpgtoantecipado,
			mult_calculocob tbsinistralidade,
			mult_calculocob cobtpseguro,
			Mult_CalculoContatoInspecao tbInspecao,
			Tabela_Configuracoes_KCW cfg,
			Tabela_Configuracoes_KCW cfg2
        where
			--mult.calculo = 4420863 and
			imovel.calculo(+) = mult.calculo  /*Pega Tipo Imovel*/
        and imovel.item(+) = mult.item
        and imovel.cobertura(+) = 998
        and imoveldesc.cobertura = imovel.cobertura
        and imoveldesc.opcao = imovel.opcao
        and ocupacao.calculo(+) = mult.calculo  /*Pega Tipo Ocupacao*/
        and ocupacao.item(+) = mult.item
        and ocupacao.cobertura(+) = 999
        and cobtpseguro.calculo(+) = mult.calculo
        and cobtpseguro.cobertura = 962
        and ocupacaodesc.cobertura = ocupacao.cobertura
        and ocupacaodesc.opcao = ocupacao.opcao
        and construcao.calculo = mult.calculo
        and construcao.item = mult.item
        and construcao.cobertura(+) = 986
        and cobertura.calculo(+) = mult.calculo
        and cobertura.item = mult.item
        and cobertura.cobertura(+) = 975
        and condominio.calculo(+) = mult.calculo
        and condominio.item(+)= mult.item
        and condominio.cobertura(+) = 1004
        and tbassistencia.calculo(+) = mult.calculo
        and tbassistencia.item(+) = mult.item
        and tbassistencia.cobertura(+) = 46
        and tbdigito.calculo(+) = mult.calculo
        and tbdigito.cobertura(+) = 1027
        and tbnumtitulo.calculo(+) = mult.calculo
        and tbnumtitulo.cobertura(+) = 1008
        and corretor.calculo = mult.calculo
        and corretor.nivel = 1
        and corretordesc.divisao =  corretor.divisao
        and fonecorretor.divisao = corretordesc.divisao
        and estip.calculo(+) = mult.calculo
        and estip.nivel(+) = 4
        and estipdesc.divisao(+) = estip.divisao
        and estipdesc.tipo_divisao(+) = 'B'
		and ((estip.divisao is null) or
            ((estipcom.divisaocom = corretor.divisao) and
            (mult.iniciovigencia between estipcom.iniciovigencia and estipcom.finalvigencia)))
        and estipcom.divisao(+) = estip.divisao
        and estipcom.produto(+) = 1
        and produtos.produto = 1
        and desccongenere.valor(+) = mult.ciarenova
        and descnorenov.calculo(+) = mult.calculo
        and descnorenov.cobertura(+) = 70
        and descapoliceant.calculo(+) = mult.calculo
        and descapoliceant.cobertura(+) = 17
        and descrenovcongenere.calculo(+) = mult.calculo
        and descrenovcongenere.cobertura(+) = 972
        and descrenovreal.calculo(+) = mult.calculo
        and descrenovreal.cobertura = 981
        and desctaxa.calculo(+) = mult.calculo
        and desctaxa.cobertura(+) = 19
        and tbagencia.calculo(+)= mult.calculo
        and tbagencia.cobertura(+) = 958
        and tbnomeagencia.calculo(+)= mult.calculo
        and tbnomeagencia.cobertura(+) = 940
        and tbcidadeagencia.calculo(+)= mult.calculo
        and tbcidadeagencia.cobertura(+) = 941
        and tbconta.calculo(+) = mult.calculo
        and tbconta.cobertura(+) = 959
        and tbbanco.calculo(+) = mult.calculo
        and tbbanco.cobertura(+) = 957
        and tbdiapgto.calculo(+) = mult.calculo
        and tbdiapgto.cobertura(+) = 987
        and tbcobranca.calculo(+) = mult.calculo
        and tbcobranca.cobertura(+) = 960
        and desccobranca.cobertura(+) = tbcobranca.cobertura
        and desccobranca.opcao(+) = tbcobranca.opcao
        and desccobranca.produto = 1
        and clientes.cliente = mult.cliente
        and telefoneres.cliente(+) = clientes.cliente
        and telefoneres.CLIENTE_FONE(+) = 1
        and telefonecom.cliente(+) = clientes.cliente
        and telefonecom.CLIENTE_FONE(+) = 4
        and enderecos.cliente = clientes.cliente
        and enderecos.tipo_endereco = 1
        and tipodoc.tipo (+)= clientes.foto
        and agcaptadora.calculo = mult.calculo
        and agcaptadora.nivel = 2
        and descagcaptadora.divisao = agcaptadora.divisao
        and agcobradora.calculo = mult.calculo
        and agcobradora.nivel = 3
        and descagcobradora.divisao = agcobradora.divisao
        and tbpgtoantecipado.calculo(+) = mult.calculo
        and tbpgtoantecipado.cobertura(+) = 1007
        and tbparentesco.calculo(+) = mult.calculo
        and tbparentesco.cobertura(+) = 991
        and tbnometitular.calculo(+) = mult.calculo
        and tbnometitular.cobertura(+) = 992
        and tbcpftitular.calculo(+) = mult.calculo
        and tbcpftitular.cobertura(+) = 993
        and tbsinistralidade.calculo(+) = mult.calculo
        and tbsinistralidade.cobertura(+) = 996
		and tbInspecao.calculo(+) = mult.calculo
        and mult.calculo = p_calculo
		and mult.padrao = produtos.produto
		and cfg.Parametro = 'DIAS_PA_1_'||cobtpseguro.Opcao
		and cfg2.parametro = 'DIAS_PA_1_'||cobtpseguro.Opcao||'_'||tbcobranca.OPCAO||'_'||mult.tipocobranca||'_NOVO'
        and rownum = 1;
	exception
		when others then
			raise;
end;
/


CREATE OR REPLACE PROCEDURE "PRC_SENDMAIL" (p_tipo in integer,
                       p_calculo in MULT_CALCULO.CALCULO%Type,
                       p_recipients in varchar2,
                       p_namefile1 in varchar2,
                       p_namefile2 in varchar2,
                       p_return out varchar2) IS
BEGIN
    declare
        --ORIGEM
        --v_from varchar2(320);
        --DESTINO
        v_to tms_mail.address_type;
        --COPIA
        v_cc tms_mail.address_type;
        --COPIA OCULTA
        v_bcc tms_mail.address_type;
        --ARRAY DE ANEXOS
        v_file tms_mail.file_type;
        --RETORNO DE ERRO DO STORAGE
        v_fault_a tms_storage.r_request_fault;
        --ID DE CORRELA«√O
        v_correlation_id tms_util.correlation_id;
        v_erro integer;
        v_subject varchar2(255);
        i integer;
        v_indx integer;
        v_body CLOB;
        sDirBase varchar2(20);
        sDirCotacao varchar2(20);
        sDirProposta varchar2(20);
        sDirBoleto varchar2(20);
        sReturn varchar2(255);
        sRequest_fault TMS_STORAGE.r_request_fault;
    begin
        sDirCotacao := '/kcw/cotacao';
        sDirProposta := '/kcw/proposta';
        sDirBoleto := '/kcw/boleto';
        --LIMPANDO OS ARRAYS
        --v_to.delete;
        --v_cc.delete;
        --v_bcc.delete;
        --v_file.delete;

        --DEFININDO ORIGEM
        --v_from :=  'daniel.carvalheiro@tokiomarine.com.br';

        --DEFININDO DESTINATARIO
        --v_to(1) := 'daniel.carvalheiro@tokiomarine.com.br';

        --DEFININDO DESTINATARIO COPIA
        --v_cc(1) := 'bruno.campana@tokiomarine.com.br';

        --DEFININDO COPIA OCULTA
        --v_bcc(1) :=  'cmainfor@gmail.com';
        --v_bcc(2) :=  'ivano_sistemas@yahoo.com.br';

        --ARQUIVO ANEXOS
        --v_file(1) := TMS_FILE_RECORD('teste.txt',TMS_UTIL.CLOB_TO_BLOB(to_clob('ARQUIVO ANEXO TESTE')) );

        --v_to := PKG_STRING_FNC.SPLIT_MAIL(p_recipients,',');
        DBMS_OUTPUT.ENABLE(1000000);

        v_indx := 0;
        v_subject := p_recipients;
        WHILE v_subject IS NOT NULL
        LOOP
          IF InStr(v_subject, ',') <> 0 THEN
            v_indx := v_indx + 1;
            v_to(v_indx) := SubStr(v_subject, 1, InStr(v_subject, ',')-1);
            v_subject := SubStr(v_subject, InStr(v_subject, ',')+1,Length(v_subject));
          ELSE
            v_indx := v_indx + 1;
            v_to(v_indx) := SubStr(v_subject, 1, Length(v_subject));
            v_subject := null;
          END IF;
        END LOOP;

        v_body := TMS_STORAGE.getClobFile('kcw', 'body.html', sRequest_fault);
         DBMS_OUTPUT.PUT_LINE('Length = ' || to_char(length(v_body)));
        --ENVIANDO O EMAIL NO FORMATO HTML
        if p_tipo = 1 then
          v_subject := 'CotaÁ„o do c·lculo ' || cast(p_calculo as varchar2);
          v_file(1) := TMS_FILE_RECORD(p_namefile1, TMS_STORAGE.getBlobFile(sDirCotacao, p_namefile1, sRequest_fault));
          dbms_output.put_line('DIR: ' || sDirCotacao);
          dbms_output.put_line('CODE: ' ||  v_fault_a.code );
          dbms_output.put_line('MESSAGE: ' ||  v_fault_a.message );
          dbms_output.put_line('DETAIL: ' ||  v_fault_a.detail );
        else
          if p_tipo = 2 then
            v_subject := 'Proposta do c·lculo ' || cast(p_calculo as varchar2);
            v_file(1) := TMS_FILE_RECORD(p_namefile1, TMS_STORAGE.getBlobFile(sDirProposta, p_namefile1, sRequest_fault));
          else
            if p_tipo = 3 then
              v_subject := 'Boleto do c·lculo ' || cast(p_calculo as varchar2);
              v_file(1) := TMS_FILE_RECORD(p_namefile2, TMS_STORAGE.getBlobFile(sDirBoleto, p_namefile2, sRequest_fault));
            else
              if p_tipo = 5 then
                v_subject := 'Proposta e boleto do c·lculo ' || cast(p_calculo as varchar2);
                v_file(1) := TMS_FILE_RECORD(p_namefile1, TMS_STORAGE.getBlobFile(sDirProposta, p_namefile1, sRequest_fault));
                v_file(2) := TMS_FILE_RECORD(p_namefile2, TMS_STORAGE.getBlobFile(sDirBoleto, p_namefile2, sRequest_fault));
              end if;
            end if;
          end if;
        end if;

        tms_mail.send_html( 'no-reply@tokiomarine.com.br',
                            v_to,
                            v_cc,
                            v_bcc,
                            v_subject,
                            v_Body,
                            v_file,
                            v_fault_a,
                            v_correlation_id );

        --dbms_output.put_line( v_fault_a.code );
        --dbms_output.put_line( v_fault_a.message );
        --dbms_output.put_line( v_fault_a.detail );

        --ID DE CORRELA«√O PARA CONSULTA POSTERIOR DO ENVIO
        --dbms_output.put_line( 'CORRELATION ID: ' || v_correlation_id.value );

        --VERIFICANDO STATUS DO EMAIL
        --TMS_MAIL.VERIFICASTATUS(v_correlation_id, v_fault_a);

        p_return := v_fault_a.message;

        --SE ENVIADO COM SUCESSO, A MENSAGEM DE RETORNO … 'Enviado com sucesso'
        --DBMS_OUTPUT.PUT_LINE(v_fault_a.code);
        --DBMS_OUTPUT.PUT_LINE(v_fault_a.message);
        --DBMS_OUTPUT.PUT_LINE(v_fault_a.detail);

        if p_tipo = 1 then
          sReturn := TMS_STORAGE.removeFile(sDirCotacao, p_namefile1, v_fault_a);
        ELSE
           if p_namefile1 is not null then
            SRETURN := TMS_STORAGE.REMOVEFILE(SDIRPROPOSTA, P_NAMEFILE1, V_FAULT_A);
           end if;
          if p_namefile2 is not null then
            sReturn := TMS_STORAGE.removeFile(sDirBoleto, p_namefile2, v_fault_a);
          end if;
        end if;
    exception
      when others then --kit_proc_log_excessao( 'func_sendmail - erro no envio de email', sqlcode, '', '', '' );
        p_return := SQLERRM;
    end;
end;
/


CREATE OR REPLACE PROCEDURE        prc_sql_selecao_realtime (PDATASERVER IN VARCHAR2, PTIPO IN VARCHAR2, PSQL_GERADO OUT LONG) IS
BEGIN
  DECLARE
    SQL_ORIGIN LONG(7000);
    vData varchar2(50);
  BEGIN
    vData := 'TO_DATE(''' ||TO_CHAR(sysdate - 7, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'')';
    IF PTIPO = 'PROC' THEN
      SQL_ORIGIN := 'select MC.CALCULO, MC.ITEM, MP.PREMIO_TOTAL,
                            TD.DIVISAO_SUPERIOR COD_INTERNO,
                            ESTI.DIVISAO_SUPERIOR DIVISAO_SUPERIOR_EST,
                            MC.NOME NOME_SEGURADO,
                            VC.DESCRICAO VEICULO,
                            vf.nome FABRICANTE,
                            case MC.PADRAO
                               when 10 then 7
                               when 11 then 9
							   when 14 then 9
							   when 15 then 9
                               when 42 then 20
                            end MODULOPRODUTO,
                            PROD.DESCRICAO as PRODUTO,
                            #FILTRO# FILTRO,
                            MC.DATAVERSAO,
                            MC.DATAVALIDADE,
                            MC.COMISSAO,
                            CLIE.CGC_CPF,
                            ESTI.NOME NOMEESTIPULANTE,
                            MC.CEP,
                            MC.INICIOVIGENCIA, VM.VALOR3 AGRUP_VEICULO,
                            CASE
                              WHEN MC.TIPOSEGURO = 1 THEN ''Seguro Novo''
                              WHEN MC.TIPOSEGURO BETWEEN 2 AND 3 THEN ''RenovaÁ„o CongÍnere''
                              WHEN MC.TIPOSEGURO BETWEEN 4 AND 5 THEN ''RenovaÁ„o Tokio''
                            END DESC_TIPOSEGURO,
                            CASE
                              WHEN MC.SITUACAO = ''E'' AND MC.TIPODOCUMENTO <> ''N'' THEN ''Efetivado''
                              WHEN MC.SITUACAO = ''E'' AND MC.TIPODOCUMENTO =  ''N'' THEN ''Finalizado sem transmiss„o''
                              WHEN MC.SITUACAO = ''T''                               THEN ''Transmitido''
                              WHEN MC.SITUACAO = ''C''                               THEN ''Calculado''
                              ELSE ''Pendente''
                            END SITUACAO,
                            CASE WHEN MC.VALIDADO = ''S'' THEN
                              ''Validado On-Line''
                            ELSE
                              ''Sem ValidaÁ„o''
                            END DESC_VALIDACAO,
                            MC.COD_USUARIO,
                            CASE
                            when MC.DATAVALIDADE is null then
                              ''Expirada''
                            WHEN MC.DATAVALIDADE - TO_DATE(''#DataServidor#'',''dd/mm/yyyy'') < 1 THEN
                              ''Expirada''
                            ELSE
                              TO_CHAR(MC.DATAVALIDADE, ''DD/MM/YYYY'')
                            END AS VALIDADE,
                            MC.DATAVALIDADE - TO_DATE(''#DataServidor#'',''dd/mm/yyyy'') AS DIAS,
                            CASE MC.PADRAO
                              WHEN 11 THEN
                                CASE
                                WHEN MC.DESCONTO_CC IS NOT NULL THEN ''DC''
                                WHEN MC.AGRAVO_CC IS NOT NULL THEN ''AG''
                                ELSE NULL
                                END
                              ELSE
                                CASE CC2.TIPO
                                WHEN ''D'' THEN ''DC''
                                WHEN ''A'' THEN ''AG''
                                ELSE CC2.TIPO END
                              END TIPOCC
                      from MULT_CALCULO MC
                        inner join VW_IDS IDS on IDS.Calculo=MC.CALCULO
                        INNER JOIN MULT_PADRAO PROD ON PROD.PADRAO = MC.PADRAO
                        left join TABELA_VEICULOMODELO VC on VC.MODELO = MC.MODELO
                        left join TABELA_VEICULOFABRIC VF on VF.FABRICANTE = VC.FABRICANTE
                        left join MULT_CALCULODIVISOES RELAC_ESTI ON RELAC_ESTI.CALCULO = MC.CALCULO
                                                                 AND RELAC_ESTI.NIVEL = 4
                        LEFT OUTER JOIN TABELA_DIVISOES ESTI ON ESTI.DIVISAO = RELAC_ESTI.DIVISAO
                        left join MULT_CALCULODIVISOES CD on CD.CALCULO = MC.CALCULO
                                                         and CD.NIVEL = 1
                        left join TABELA_DIVISOES TD on TD.DIVISAO = CD.DIVISAO
                        LEFT JOIN MULT_PRODUTOSTABRG VM ON VM.CHAVE2 = MC.MODELO
                                                       AND ((VM.PRODUTO = MC.PADRAO) or (VM.PRODUTO = 11 and (MC.PADRAO in(14,15))))
                                                       AND ((VM.CHAVE3 = MC.FABRICANTE AND VM.PRODUTO in(11,14,15)) OR (VM.PRODUTO=10))
                                                       AND VM.TABELA  = 9999
                                                       AND MC.DATAVERSAO BETWEEN VM.DT_INICO_VIGEN AND VM.DT_FIM_VIGEN
                        LEFT OUTER JOIN TABELA_CLIENTES CLIE ON CLIE.CLIENTE = MC.CLIENTE
                        LEFT JOIN MULT_CALCULOPREMIOS MP ON MP.CALCULO=MC.CALCULO
                                                        AND MP.ITEM=MC.ITEM
                                                        AND MP.PRODUTO=MC.PADRAO
                                                        AND ((MP.TIPOCOTACAO=1 AND MC.MODALIDADE=''A'')
                                                          OR (MP.TIPOCOTACAO=2 AND MC.MODALIDADE=''D'')
                                                          OR (MC.PADRAO in(11,14,15)))
                        LEFT JOIN MULT_CALCULOCONTACORRENTE CC2 ON CC2.CALCULO=MC.CALCULO
                                                               and CC2.PRODUTO=MC.PADRAO
                                                               and cc2.tipocotacao=1
                      where MC.PADRAO in(#PRODUTO#)
                        and MC.SITUACAO=''C''
                        and MC.SITE = ''P''
                        and MC.CALC_ONLINE = ''S''
                        and MC.VALIDADO = ''S''
                        and MC.TIPO_OFERTA is null
                        and TO_CHAR(MC.DATAVALIDADE - TO_DATE('''||pDataServer||''',''DD/MM/YYYY'')) IN (#VALIDADE#)
                        and MC.TIPOSEGURO in (#TIPOSEGURO#)
                        #CEPS#
                        #AGRUPAMENTO_VEIC#
                        and mc.dataprimeirocalculo >= '|| vData || '
                        and exists(select MP.CALCULO from MULT_CALCULOPREMIOS MP
                                    where MP.CALCULO=MC.CALCULO
                                      and MP.ITEM=MC.ITEM
                                      and MP.PRODUTO=MC.PADRAO)
                        and exists(select mc.calculo from MULT_CALCULOQBR MQ where MQ.CALCULO=MC.CALCULO AND MQ.ITEM=MC.ITEM)
                        and not exists(select rt.calculo from TABELA_CALCULOS_REALTIME RT where rt.calculo=mc.calculo)
						and not exists(select rc.calculo from TABELA_CALCULOS_REALTIME_CERRO RC where rc.calculo=mc.calculo)';
    ELSE
      SQL_ORIGIN := 'select MC.CALCULO, MC.ITEM, MC.NOME, CLIE.CGC_CPF, ESTI.NOME NOMEESTIPULANTE, MC.DATACALCULO,
                            CASE
                              WHEN MC.SITUACAO = ''E'' AND MC.TIPODOCUMENTO <> ''N'' THEN ''Efetivado''
                              WHEN MC.SITUACAO = ''E'' AND MC.TIPODOCUMENTO =  ''N'' THEN ''Finalizado sem transmiss„o''
                              WHEN MC.SITUACAO = ''T''                               THEN ''Transmitido''
                              WHEN MC.SITUACAO = ''C''                               THEN ''Calculado''
                              ELSE ''Pendente''
                            END SITUACAO,
                            MC.SITUACAO COD_SITUACAO, MC.COD_USUARIO, PROD.DESCRICAO as PRODUTO, MC.PADRAO, MC.VALIDADO,
                            CASE WHEN MC.DATAVALIDADE - TO_DATE(''#DataServidor#'',''dd/mm/yyyy'') < 1 THEN
                              ''Expirada''
                            ELSE
                              TO_CHAR(MC.DATAVALIDADE, ''DD/MM/YYYY'')
                            END AS VALIDADE,
                            MC.DATAVALIDADE - TO_DATE(''#DataServidor#'',''dd/mm/yyyy'') AS DIAS,
                            CASE
                              WHEN MC.TIPOSEGURO = 1 THEN ''Seguro Novo''
                              WHEN MC.TIPOSEGURO BETWEEN 2 AND 3 THEN ''RenovaÁ„o CongÍnere''
                              WHEN MC.TIPOSEGURO BETWEEN 4 AND 5 THEN ''RenovaÁ„o Tokio''
                            END DESC_TIPOSEGURO,
                            RELAC_ESTI.DIVISAO COD_ESTIPULANTE,
                            CASE WHEN MC.VALIDADO = ''S'' THEN
                              ''Validado On-Line''
                            ELSE
                              ''Sem ValidaÁ„o''
                            END DESC_VALIDACAO,
                            MC.CEP, VM.VALOR3 AGRUP_VEICULO, TD.DIVISAO_SUPERIOR COD_CORRETOR,
                            TD.NOME NOME_CORRETOR, MC.DATAVERSAO, MC.INICIOVIGENCIA
                     from MULT_CALCULO MC
                     inner join VW_IDS IDS on IDS.Calculo=MC.CALCULO
                     left join MULT_PRODUTOSTABRG VM on VM.CHAVE2 = MC.MODELO
                                                    AND ((VM.PRODUTO = MC.PADRAO) or (VM.PRODUTO = 11 and (MC.PADRAO in(14,15))))
                                                    AND ((VM.CHAVE3 = MC.FABRICANTE AND VM.PRODUTO in(11,14,15)) OR (VM.PRODUTO=10))
                                                    AND VM.TABELA  = 9999
                                                    AND MC.DATAVERSAO between VM.dt_inico_vigen and VM.dt_fim_vigen
                     INNER JOIN MULT_PADRAO PROD ON PROD.PADRAO = MC.PADRAO
                     LEFT OUTER JOIN TABELA_CLIENTES CLIE ON CLIE.CLIENTE = MC.CLIENTE
                     LEFT OUTER JOIN MULT_CALCULODIVISOES RELAC_ESTI ON RELAC_ESTI.CALCULO = MC.CALCULO AND RELAC_ESTI.NIVEL = 4
                     LEFT OUTER JOIN TABELA_DIVISOES ESTI ON ESTI.DIVISAO = RELAC_ESTI.DIVISAO
                     LEFT OUTER JOIN MULT_CALCULODIVISOES RELAC_CORR ON RELAC_CORR.CALCULO = MC.CALCULO AND RELAC_CORR.NIVEL = 1
                     inner join tabela_divisoes td on td.divisao=relac_corr.divisao
                     where MC.PADRAO in(#Produtos#)
                       and MC.SITUACAO=''C''
                       and MC.SITE = ''P''
                       and MC.CALC_ONLINE = ''S''
                       and MC.VALIDADO = ''S''
                       and MC.TIPO_OFERTA is null
                       and MC.DATAVALIDADE - TO_DATE(''#DataServidor#'',''dd/mm/yyyy'') IN (#ValidadeCotacao#)
                       and MC.TIPOSEGURO in (#TipoSeguro#)
                       #LinFxCEP#
                       #LinAgVei#
                       and mc.dataprimeirocalculo >= '|| vData || '
                       and exists(select MP.CALCULO from MULT_CALCULOPREMIOS MP
                                   where MP.CALCULO=MC.CALCULO
                                     and MP.ITEM=MC.ITEM
                                     and MP.PRODUTO=MC.PADRAO)
                       and exists(select mq.calculo from MULT_CALCULOQBR MQ where MQ.CALCULO=MC.CALCULO AND MQ.ITEM=MC.ITEM)';
      IF PTIPO = 'MRREALTIME' THEN
	    SQL_ORIGIN := SQL_ORIGIN || 'and not exists(select rt.calculo from TABELA_CALCULOS_REALTIME RT where rt.calculo=mc.calculo and rt.filtro<>#FILTRO#)
		                             and not exists(select rc.calculo from TABELA_CALCULOS_REALTIME_CERRO RC where rc.calculo=mc.calculo and rc.filtro<>#FILTRO#)';
	  ELSE
		SQL_ORIGIN := SQL_ORIGIN || 'and not exists(select rt.calculo from TABELA_CALCULOS_REALTIME RT where rt.calculo=mc.calculo)
		                             and not exists(select rc.calculo from TABELA_CALCULOS_REALTIME_CERRO RC where rc.calculo=mc.calculo) ';
	  END IF;
	END IF;
    PSQL_GERADO := SQL_ORIGIN;
  END;
END PRC_SQL_SELECAO_REALTIME;
/


CREATE OR REPLACE PROCEDURE "PRC_USUARIOS_PORTAL" (
   lid_usuario         IN       real_usuarios.cod_usuario%TYPE,
   lnm_usuario         IN       real_usuarios.nomeusuario%TYPE,
   lcd_corretor_usu    IN       real_usuarios.corretor%TYPE,
   lag_captadora_usu   IN       real_usuarios.agencia%TYPE,
   ltp_usuario         IN       real_usuarios.tipousuario%TYPE,
   lcd_padrao_usu      IN       real_usuarios.padraousuario%TYPE,
   pa_estipulantes     IN       ESTIPULANTE_TYPE,
   ldt_ini_vig_usu     IN       real_usuarios.iniciovigencia%TYPE,
   ldt_fim_vig_usu     IN       real_usuarios.finalvigencia%TYPE,
   mensagem_erro       OUT  nocopy     NVARCHAR2
)
IS
TYPE EST_ARRAY_TYPE IS VARRAY(10) of NUMBER(18);
BEGIN
   DECLARE
      I                   PLS_INTEGER;
      vagencia            NUMBER (8);
      lno_estipulante     NUMBER (8);
      testipulante        NUMBER (8);
      ldivisao_superior   NUMBER (8);
      lcd_corretor        NUMBER (8);
      lcd_agencia         NUMBER (8);
      lcd_agencia_dIV     NUMBER (8);
      la_cod_int_est      EST_ARRAY_TYPE;


      --Cursor com dados do Estipulante
      CURSOR tb_divisoes
      IS
         SELECT divisao
           FROM tabela_divisoes
          WHERE divisao_superior = ldivisao_superior AND tipo_divisao = 'B';

      --Cursor com dados do Corretor
      CURSOR tb_divisoesc
      IS
         SELECT divisao
           FROM tabela_divisoes
          WHERE divisao_superior = lcd_corretor_usu AND tipo_divisao = 'E';

   --Cursor com dados da AgÍncia Captadora
   -- DANILO EM 08/07/2011
   -- OLD VERSION
   --	 CURSOR tb_divisoesa
   --  IS
   --      SELECT divisao
   --        FROM tabela_divisoes
   --       WHERE divisao_superior = lag_captadora_usu AND tipo_divisao = 'A';
   --

   BEGIN
   -- NEW VERSION
   IF (lcd_corretor_usu = 43551) -- EH SANTANDER
   THEN lcd_agencia := 9934;   -- AGENCIA 9934
   ELSE lcd_agencia := 9925;   -- NAO EH SANTANDER FORCA ESSE VALOR 9925
   END IF;


   -- FIM ALTERACAO DANILO 08/07/2011

      la_cod_int_est := EST_ARRAY_TYPE();
      la_cod_int_est.EXTEND(10);

      DBMS_OUTPUT.ENABLE (1000000);

      BEGIN

         --Pegando o Codigo Interno do Corretor.
         OPEN tb_divisoesc;

         FETCH tb_divisoesc
          INTO lcd_corretor;

         IF tb_divisoesc%NOTFOUND
         THEN
            lcd_corretor := 0;
         END IF;

         CLOSE tb_divisoesc;

         --Pegando o Codigo Interno da AgÍncia Captadora se ela foi enviada.
       BEGIN
         SELECT divisao
         INTO lcd_agencia_DIV
         FROM tabela_divisoes
         WHERE divisao_superior = lcd_agencia AND tipo_divisao = 'A';
      EXCEPTION
         WHEN OTHERS
         THEN
            BEGIN
              lcd_agencia_DIV:= NULL;
            END;
      END;

            --Se a Agencia n„o existir eÁa È inserida
            IF (lcd_agencia_DIV IS NULL) OR (lcd_agencia_DIV = 0) OR (lcd_agencia_DIV = '')
            THEN
               SELECT func_contador ('TABELA_DIVISOES')
                 INTO lcd_agencia_dIV
                 FROM DUAL;

               INSERT INTO tabela_divisoes
                           (divisao,
                            nome,
                            tipo_divisao,
                            tem_endereco,
                            divisao_superior,
                            situacao,
                            data_inclusao,
                            cod_conv
                           )
                    VALUES (lcd_agencia_dIV,
                            'AGENCIA ' || TO_CHAR (lcd_agencia),
                            'A',
                            '1',
                            lcd_agencia,
                            'A',
                            SYSDATE,
                            TO_CHAR (lcd_agencia)
                           );
            END IF;


           for I in 1..10
           loop
              la_cod_int_est(I)  := 0;
              lno_estipulante    := 0;

             if  pa_estipulantes is not null and pa_estipulantes.count > 0 then
                 if pa_estipulantes.COUNT <= I then
                    lno_estipulante  := pa_estipulantes(i).ESTIPULANTE_CODE;
                 end if;
             end if;

              IF lno_estipulante  <> 0
              THEN

                OPEN tb_divisoes;

                FETCH tb_divisoes
                 INTO la_cod_int_est(I);

                IF tb_divisoes%NOTFOUND
                THEN
                   la_cod_int_est(I) := 0;
                END IF;

                CLOSE tb_divisoes;
              END IF;

           end loop;

         --Inserindo Usu·rio
         INSERT INTO real_usuarios
              VALUES (TRIM (lid_usuario), lcd_corretor, ldt_ini_vig_usu,
                      lnm_usuario, lcd_agencia_DIV, ltp_usuario, lcd_padrao_usu,
                      la_cod_int_est(1), la_cod_int_est(2), la_cod_int_est(3),
                      la_cod_int_est(4), la_cod_int_est(5), la_cod_int_est(6),
                      la_cod_int_est(7), la_cod_int_est(8), la_cod_int_est(9),
                      la_cod_int_est(10), ldt_fim_vig_usu);

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            BEGIN
               ROLLBACK;

               IF tb_divisoes%ISOPEN
               THEN
                  CLOSE tb_divisoes;
               END IF;

               IF tb_divisoesc%ISOPEN
               THEN
                  CLOSE tb_divisoesc;
               END IF;
               mensagem_erro :=
                     'Ocorreu um erro ao tentar gravar o usuario: '
                  || TRIM (lid_usuario)
                  || '-'
                  || TRIM (lnm_usuario)
                  || '  -  Mensagem: '
                  || SQLERRM
                  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               DBMS_OUTPUT.put_line (mensagem_erro);
            END;
      END;

      COMMIT;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PRC_VERIFICAAGRUPAMENTOVEIC" (PAGRUPAMENTO IN VARCHAR2,
															PRETURN OUT TYPES.CURSOR_TYPE)
IS 
BEGIN													   
	DECLARE
		type T_AGRUP_CURTYP is ref cursor;
		C_AGRUPAMENTOVEIC T_AGRUP_CURTYP;
		vSQL varchar2(3500) := 'select ED.AGRUPAMENTO_EDIT,  ag.cd_agrmt AGRUPAMENTO, ag.nm_agrmt DESCRICAO
								  from  (select TO_NUMBER(X.column_value.extract(''//./text()'')) AGRUPAMENTO_EDIT            
										   from XMLTABLE (''ROWSET/ROW/*'' PASSING                                                  
														  DBMS_XMLGEN.GETXMLTYPE(''select #AGRUPAMENTO# from dual'')
														 ) X         
										) ED                   
								left join ssv2004_agrmt ag on ag.cd_agrmt=ED.AGRUPAMENTO_EDIT
                                          and sysdate between ag.dt_inico_vigen and ag.dt_fim_vigen';
		SQL_DYNAMIC varchar2(3500);
	BEGIN
		if (C_AGRUPAMENTOVEIC%isopen) then
			close C_AGRUPAMENTOVEIC;
		end if;
		
		SQL_DYNAMIC := replace(vSQL, '#AGRUPAMENTO#', PAGRUPAMENTO);
		
		--open C_AGRUPAMENTOVEIC for SQL_DYNAMIC;
		open PRETURN for SQL_DYNAMIC;
	END;
END;
/


CREATE OR REPLACE PROCEDURE        proc_gera_acesso_crivo
( pcalculo IN NUMBER
, pretorno IN VARCHAR2
, pretornoold IN VARCHAR2
) AS
    v_pos_codreturn NUMBER := 0;
    v_pos_arroba NUMBER := 0;
    v_retrn_crivo_antes NUMBER;
    v_retrn_crivo_postr NUMBER;

BEGIN
    v_pos_codreturn := INSTR(UPPER(pretorno), 'CODRETURN=');
    IF v_pos_codreturn > 0 THEN
        v_pos_codreturn := (v_pos_codreturn + 10);
        v_pos_arroba := INSTR(UPPER(pretorno), '@', v_pos_codreturn);
        v_retrn_crivo_postr := SUBSTR(pretorno, v_pos_codreturn, (v_pos_arroba - v_pos_codreturn));
    END IF;

    v_pos_codreturn := INSTR(UPPER(pretornoold), 'CODRETURN=');
    IF v_pos_codreturn > 0 THEN
        v_pos_codreturn := (v_pos_codreturn + 10);
        v_pos_arroba := INSTR(UPPER(pretornoold), '@', v_pos_codreturn);
        v_retrn_crivo_antes := SUBSTR(pretornoold, v_pos_codreturn, (v_pos_arroba - v_pos_codreturn));
    END IF;

    BEGIN
        INSERT INTO checa_acesso_crivo
          (calculo,
           datetime,
           retornocrivo,
           cd_retrn_crivo_antes,
           cd_retrn_crivo_postr)
        VALUES
          (pcalculo,
           systimestamp,
           pretorno,
           v_retrn_crivo_antes,
           v_retrn_crivo_postr);

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            NULL;

    END;

END proc_gera_acesso_crivo;
/


CREATE OR REPLACE PROCEDURE "PROC_GERA_ACESSO_IDS" 
( PCALCULO IN NUMBER, PIDS_IN IN VARCHAR2, PIDS_OUT IN VARCHAR2) AS
BEGIN
  INSERT INTO CHECA_ACESSO_IDS
  (CALCULO , DATETIME    , IDS_IN , IDS_OUT ) VALUES
  (PCALCULO, SYSTIMESTAMP, PIDS_IN, PIDS_OUT);
END PROC_GERA_ACESSO_IDS;
/


CREATE OR REPLACE PROCEDURE "PROC_HONDA_CANAL_MODELO" (p_dt_inicial in varchar2,
                                  p_dt_final in varchar2,
                                  p_canal_venda in varchar2,
                                  p_modelo in varchar2,
                                  p_resultado OUT TYPES.CURSOR_TYPE) AS
BEGIN
IF(p_dt_inicial = p_dt_final) then
OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      COUNT (C.CALCULO) AS QTD_ITENS,
      --C.ZEROKM as ZEROKM,
      SUM(R.VALOR_PRIMEIRA + ((R.PARCELAS - 1)* R.VALOR_DEMAIS)) AS PREMIO_TOTAL,
      F.DESCRICAO as DESCRICAO
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
      INNER JOIN MULT_CALCULOCONDPAR R
      ON (R.CALCULO = C.CALCULO) AND
        (R.ESCOLHA = 'S')
      INNER JOIN MULT_CALCULOPREMIOS P
      ON (P.CALCULO = R.CALCULO) AND
         (P.TIPOCOTACAO = R.TIPOCOTACAO)
      INNER JOIN TABELA_VEICULOMODELO F
      ON (C.MODELO = F.MODELO)
    WHERE
      C.DATACALCULO LIKE TO_DATE(p_dt_final,'DD/MM/YY') AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO = 'T' AND
      E.NIVEL = 4 AND
      D.NOME LIKE p_canal_venda AND
      F.DESCRICAO LIKE p_modelo AND
      D.TIPO_DIVISAO = 'B'
      group by D.NOME, F.DESCRICAO;
ELSE
OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      COUNT (C.CALCULO) AS QTD_ITENS,
     -- C.ZEROKM as ZEROKM,
      SUM(R.VALOR_PRIMEIRA + ((R.PARCELAS - 1)* R.VALOR_DEMAIS)) AS PREMIO_TOTAL,
      F.DESCRICAO as DESCRICAO
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
      INNER JOIN MULT_CALCULOCONDPAR R
      ON (R.CALCULO = C.CALCULO) AND
        (R.ESCOLHA = 'S')
      INNER JOIN MULT_CALCULOPREMIOS P
      ON (P.CALCULO = R.CALCULO) AND
         (P.TIPOCOTACAO = R.TIPOCOTACAO)
      INNER JOIN TABELA_VEICULOMODELO F
      ON (C.MODELO = F.MODELO)
    WHERE
     C.DATACALCULO >= TO_DATE(p_dt_inicial,'DD/MM/YY') AND C.DATACALCULO <=  TO_DATE(p_dt_final,'DD/MM/YY') + 1 AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO = 'T' AND
      E.NIVEL = 4 AND
      D.NOME LIKE p_canal_venda AND
      F.DESCRICAO LIKE p_modelo AND
      D.TIPO_DIVISAO = 'B'
      group by D.NOME, F.DESCRICAO;
END IF;
       exception
             when NO_DATA_FOUND then
                 DBMS_OUTPUT.PUT_LINE('Falha na execucao da procedure de carregamento do relatorio HONDA.');
END PROC_HONDA_CANAL_MODELO;
/


CREATE OR REPLACE PROCEDURE "PROC_HONDA_CANAL_S_MODELO" (p_cod_marca in varchar2,
                                  p_dt_inicial in varchar2,
                                  p_dt_final in varchar2,
                                  p_canal_venda in varchar2,
                                  p_resultado OUT TYPES.CURSOR_TYPE) AS
BEGIN
IF(p_dt_inicial = p_dt_final) then
OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      COUNT (C.CALCULO) AS QTD_ITENS,
      --C.ZEROKM as ZEROKM,
      SUM(R.VALOR_PRIMEIRA + ((R.PARCELAS - 1)* R.VALOR_DEMAIS)) AS PREMIO_TOTAL,
      F.DESCRICAO as DESCRICAO
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
      INNER JOIN MULT_CALCULOCONDPAR R
      ON (R.CALCULO = C.CALCULO) AND
        (R.ESCOLHA = 'S')
      INNER JOIN MULT_CALCULOPREMIOS P
      ON (P.CALCULO = R.CALCULO) AND
         (P.TIPOCOTACAO = R.TIPOCOTACAO)
      INNER JOIN TABELA_VEICULOMODELO F
      ON (C.MODELO = F.MODELO)
    WHERE
      C.DATACALCULO LIKE TO_DATE(p_dt_final,'DD/MM/YY') AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO = 'T' AND
      E.NIVEL = 4 AND
      D.NOME LIKE p_canal_venda AND
      F.Fabricante = p_cod_marca AND
      D.TIPO_DIVISAO = 'B'
      group by D.NOME, F.DESCRICAO;
ELSE
OPEN p_resultado FOR
SELECT
      D.NOME AS CONCESSIONARIA,
      COUNT (C.CALCULO) AS QTD_ITENS,
      --C.ZEROKM as ZEROKM,
      SUM(R.VALOR_PRIMEIRA + ((R.PARCELAS - 1)* R.VALOR_DEMAIS)) AS PREMIO_TOTAL,
      F.DESCRICAO as DESCRICAO
    FROM
      MULT_CALCULO C
      INNER JOIN MULT_CALCULODIVISOES E
      ON (C.CALCULO = E.CALCULO)
      INNER JOIN MULT_CALCULODIVISOES CORR
      ON (C.CALCULO = CORR.CALCULO) AND
      CORR.NIVEL = 1
      INNER JOIN TABELA_DIVISOES CORR2
      ON (CORR.DIVISAO = CORR2.DIVISAO) AND
      CORR2.TIPO_DIVISAO = 'E' AND CORR2.DIVISAO_SUPERIOR = 98626
      INNER JOIN TABELA_DIVISOES D
      ON (E.DIVISAO = D.DIVISAO)
      INNER JOIN MULT_CALCULOCONDPAR R
      ON (R.CALCULO = C.CALCULO) AND
        (R.ESCOLHA = 'S')
      INNER JOIN MULT_CALCULOPREMIOS P
      ON (P.CALCULO = R.CALCULO) AND
         (P.TIPOCOTACAO = R.TIPOCOTACAO)
      INNER JOIN TABELA_VEICULOMODELO F
      ON (C.MODELO = F.MODELO)
    WHERE
      C.DATACALCULO >= TO_DATE(p_dt_inicial,'DD/MM/YY') AND C.DATACALCULO <=  TO_DATE(p_dt_final,'DD/MM/YY') + 1 AND
      C.PADRAO IN (10,42) AND
      C.SITUACAO = 'T' AND
      E.NIVEL = 4 AND
      D.NOME LIKE p_canal_venda AND
      F.Fabricante = p_cod_marca AND
      D.TIPO_DIVISAO = 'B'
      group by D.NOME,F.DESCRICAO;
END IF;
       exception
             when NO_DATA_FOUND then
                 DBMS_OUTPUT.PUT_LINE('Falha na execucao da procedure de carregamento do relatorio HONDA.');
END PROC_HONDA_CANAL_S_MODELO;
/


CREATE OR REPLACE procedure proc_teste7 is
  type t_xx is table of BASE_ET_2%rowtype;
  v_lista  t_xx;
  V_LimInf number;
  V_LimSup number;
  V_Delta  number;
  V_Total  number;
  v_gpa_id number;
  l_start  number;
BEGIN
  /*tms_gpa.iniciar_processo('KCW - Limpeza Base' --
                        , SubStr(USER, 1, 8) --
                        , '4402');*/

  /*v_gpa_id := tms_session.get_gpa_id;*/

  -- Delta Numero de registro por tabela
  V_Delta  := 5000000;
  V_LimInf := 1;
  V_Total  := 33000000;

  while V_LimInf <= V_Total loop
    l_start := DBMS_UTILITY.get_time;
  V_LimSup := V_LimInf + V_Delta;

     SELECT * BULK COLLECT
      INTO v_lista
      FROM (select calculo, dataprimeirocalculo, finalvigencia
              from mult_calculo
             where (calculo >= V_LimInf)
               and (calculo < V_LimSup)
               and situacao in ('E', 'T'));

    FORALL i IN 1 .. v_lista.COUNT
      INSERT /*+ append */
      INTO BASE_ET_2
      VALUES v_lista
        (i);

    commit;
    V_LimInf := V_LimSup;
  /*tms_gpa.info(v_gpa_id, 'Inseridos ' || V_LimSup || ' na BaseET em ' || (DBMS_UTILITY.get_time - l_start) || ' segundos.', null);*/
  end loop;

  /*tms_gpa.finalizar_processo;*/
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_APAGAPREMIO" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PPRODUTO      MULT_CALCULOPREMIOS.PRODUTO%Type,
PTIPOCOTACAO        MULT_CALCULOPREMIOS.TIPOCOTACAO%Type) IS
BEGIN
  DELETE FROM MULT_CALCULOPREMIOS
  WHERE CALCULO = PCALCULO
     AND ITEM    = 0
     AND PRODUTO = PPRODUTO
     AND TIPOCOTACAO = PTIPOCOTACAO;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_ATUALIZAPREMIO" (
PCALCULO      MULT_CALCULOPREMIOS.CALCULO%Type,
PPRODUTO      MULT_CALCULOPREMIOS.PRODUTO%Type,
PTIPOCOTACAO        MULT_CALCULOPREMIOS.TIPOCOTACAO%Type,
PCASCO       MULT_CALCULOPREMIOS.AJUSTE%Type,
PACESS       MULT_CALCULOPREMIOS.AJUSTE%Type,
PRCFDM       MULT_CALCULOPREMIOS.AJUSTE%Type,
PRCFDP       MULT_CALCULOPREMIOS.AJUSTE%Type,
PMAPP       MULT_CALCULOPREMIOS.AJUSTE%Type,
PAPP       MULT_CALCULOPREMIOS.AJUSTE%Type,
PMRCF       MULT_CALCULOPREMIOS.AJUSTE%Type,
PMOUT       MULT_CALCULOPREMIOS.AJUSTE%Type,
PLIQ       MULT_CALCULOPREMIOS.AJUSTE%Type,
PIOF       MULT_CALCULOPREMIOS.AJUSTE%Type,
PTOT       MULT_CALCULOPREMIOS.AJUSTE%Type,
PFRANQ       MULT_CALCULOPREMIOS.AJUSTE%Type,
PAJUSTE       MULT_CALCULOPREMIOS.AJUSTE%Type,
PTAXA       MULT_CALCULOPREMIOS.AJUSTE%Type,
PDESCRICAO       MULT_CALCULOPREMIOS.OBSERVACAO%TYPE,
PCOMISSAO_COMP MULT_CALCULOPREMIOS.COMISSAO_COMP%Type) IS
BEGIN
   DECLARE
       CPRODUTO number(16,6);
       Cursor T_PREMIOS Is
          SELECT PRODUTO FROM MULT_CALCULOPREMIOS
          WHERE CALCULO = PCALCULO
                AND ITEM    = 0
                AND PRODUTO = PPRODUTO
                AND TIPOCOTACAO = PTIPOCOTACAO;
   BEGIN
   Open T_PREMIOS;
   Fetch T_PREMIOS Into CPRODUTO;
   if T_PREMIOS%Notfound Then
     INSERT INTO MULT_CALCULOPREMIOS
            (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,ESCOLHA,COD_TABELA,PREMIO_CASCO,
             PREMIO_ACESSORIOS,PREMIO_AUTO,PREMIO_DM,PREMIO_DP,PREMIO_APP_MORTE,
             PREMIO_APP_INVALIDEZ,PREMIO_APP,PREMIO_RCF,PREMIO_OUTROS,
             PREMIO_LIQUIDO,PREMIO_IOF,PREMIO_TOTAL,FRANQUIAAUTO,AJUSTE,DESCONTOCOMISSAO,OBSERVACAO, COMISSAO_COMP)
     VALUES (PCALCULO,0,PPRODUTO,PTIPOCOTACAO,'N',9,PCASCO,PACESS,PCASCO,PRCFDM,PRCFDP,PMAPP,PMAPP,
             PAPP,PMRCF,PMOUT,PLIQ,PIOF,PTOT,PFRANQ,PAJUSTE,PTAXA,PDESCRICAO,PCOMISSAO_COMP);
   else
     UPDATE MULT_CALCULOPREMIOS
      SET PREMIO_CASCO      = PCASCO,
          PREMIO_ACESSORIOS = PACESS,
          PREMIO_AUTO       = PCASCO,
          PREMIO_DM         = PRCFDM,
          PREMIO_DP         = PRCFDP,
          PREMIO_APP_MORTE     = PMAPP,
          PREMIO_APP_INVALIDEZ = PMAPP,
          PREMIO_APP        = PAPP,
          PREMIO_RCF        = PMRCF,
          PREMIO_OUTROS     = PMOUT,
          PREMIO_LIQUIDO    = PLIQ,
          PREMIO_IOF        = PIOF,
          PREMIO_TOTAL      = PTOT,
          FRANQUIAAUTO      = PFRANQ,
          AJUSTE            = PAJUSTE,
          DESCONTOCOMISSAO  = PTAXA,
          OBSERVACAO        = PDESCRICAO,
          COMISSAO_COMP     = PCOMISSAO_COMP
     WHERE CALCULO = PCALCULO
       AND ITEM    = 0
       AND PRODUTO = PPRODUTO
       AND TIPOCOTACAO = PTIPOCOTACAO;
   end if;
   Close T_PREMIOS;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_ATUALIZARCOBERTURAS" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PPRODUTO      MULT_CALCULOPREMIOSCOB.PRODUTO%Type,
PCOBERTURA        MULT_CALCULOPREMIOSCOB.COBERTURA%Type,
PVALOR       MULT_CALCULOPREMIOSCOB.VALOR%Type,
PPREMIO       MULT_CALCULOPREMIOSCOB.PREMIO%Type,
PFRANQUIA       MULT_CALCULOPREMIOSCOB.FRANQUIA%Type,
PDESCRICAO       MULT_CALCULOPREMIOSCOB.DESCRICAO%Type) IS
BEGIN
   DECLARE
       CCobertura number(16,6);
       Cursor T_COBERTURA Is
          SELECT COBERTURA FROM MULT_CALCULOPREMIOSCOB WHERE CALCULO =  PCALCULO
          AND ITEM      = 0
          AND PRODUTO = PPRODUTO
          AND COBERTURA  = PCOBERTURA;
   BEGIN
   Open T_COBERTURA;
   Fetch T_COBERTURA Into CCobertura;
   if T_COBERTURA%Notfound Then
      INSERT INTO MULT_CALCULOPREMIOSCOB
      (CALCULO,ITEM,PRODUTO,COBERTURA,VALOR,PREMIO,FRANQUIA,DESCRICAO) VALUES
      (PCALCULO,0,PPRODUTO,PCOBERTURA,PVALOR,PPREMIO,PFRANQUIA,PDESCRICAO);
   else
      UPDATE MULT_CALCULOPREMIOSCOB
          SET VALOR = PVALOR , PREMIO = PPREMIO , FRANQUIA = PFRANQUIA, DESCRICAO = PDESCRICAO
   	      WHERE CALCULO   = PCALCULO AND ITEM = 0 AND PRODUTO = PPRODUTO AND COBERTURA = PCOBERTURA;
   end if;
   Close T_COBERTURA;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_CPAGINAO" (
PCalculo      MULT_CALCULO.CALCULO%Type,
PPadrao      MULT_CALCULO.PADRAO%Type) IS
BEGIN
  DECLARE
    PDESC VARCHAR2(40);
    PPRODUTO NUMBER(18,6);
    PGRUPO NUMBER(18,6);

    PUTILIZACAO NUMBER(18,6);

    PNIVELDM NUMBER(18,6);

    PNIVELDP NUMBER(18,6);
    PVALORAPPMORTE NUMBER(18,6);

    PVALORAPPINV NUMBER(18,6);
    PCOBERTURA NUMBER(18,6);

    PFRANQUIA NUMBER(18,6);
    PCONDICAO NUMBER(18,6);
    PCOMISSAO NUMBER(18,6);
    PDESCONTOCOMERCIAL NUMBER(18,6);
    PTIPO VARCHAR2(1);
    PTIPOAPOLICE NUMBER(18,6);
    PDATA date := sysdate;

    POpOpcao NUMBER(18,6);
    POpCobertura NUMBER(18,6);
    POpPreferida VARCHAR2(1);
    PcCobertura NUMBER(18,6);
    PcTipo1 VARCHAR2(1);
    PcSolicita VARCHAR2(1);
    PcMostra VARCHAR2(1);
    POpcao NUMBER(18,6);
  BEGIN
    SELECT GRUPO, UTILIZACAO, NIVELDM, NIVELDP, VALORAPPMORTE, VALORAPPINV, COBERTURA,
       FRANQUIA, CONDICAO,
       COMISSAO, DESCONTOCOMERCIAL, TIPO, TIPOAPOLICE
       Into PGRUPO, PUTILIZACAO, PNIVELDM, PNIVELDP, PVALORAPPMORTE, PVALORAPPINV,
       PCOBERTURA, PFRANQUIA, PCONDICAO,
       PCOMISSAO, PDESCONTOCOMERCIAL, PTIPO, PTIPOAPOLICE
       FROM MULT_PADRAO WHERE PADRAO = PPADRAO;
    INSERT INTO MULT_CALCULO (CALCULO, ITEM, ESTIPULANTE, CLIENTE, GRUPO, PADRAO,
       FABRICANTE, PROCEDENCIA,MODELO, ANOMODELO, ANOFABRICACAO, ZEROKM,
       VALORVEICULO, CEP, NIVELDM, NIVELDP, VALORAPPMORTE, VALORAPPINV,
       VALORAPPDMH, TIPO_COBERTURA, TIPO_FRANQUIA,
       NIVELBONUSAUTO, NIVELBONUSDM, NIVELBONUSDP, INICIOVIGENCIA, FINALVIGENCIA,
       DATACALCULO, QTDDIAS, CONDICAO, COMISSAO, DESCONTOCOMISSAO,
       CIARENOVA, QTDSINISTROS, TIPOPRODUTO, NUMPASSAGEIROS, SITUACAO, COD_CIDADE,
       COD_REFERENCIA,  COD_TABELA, VALORBASE, AJUSTE,
       NumCondutores, NumDependentes,TipoDocumento, CalculoOrigem)
    VALUES
       (PCALCULO,0,0,0,PGRUPO,PPADRAO,PUTILIZACAO,'N',
       0,0,0,'N',0,'',PNIVELDM,PNIVELDP,PVALORAPPMORTE,PVALORAPPINV,0,
       PCOBERTURA,PFRANQUIA,0,0,0,PDATA,PDATA+365,
       PDATA,365,PCONDICAO,PCOMISSAO - PDESCONTOCOMERCIAL,PDESCONTOCOMERCIAL,0,0,
       PTIPO,5,'P',0,0,
       PTIPOAPOLICE,0,0,0,0,'A',0);
       Insert into Mult_CalculoCob (Calculo,Item,Condutor,Cobertura,Valor,Opcao,Tipo,Solicita,PCondutor,SCondutor,DCondutor,Mostra,Escolha,Observacao,Taxa,Franquia,Premio)
       Select distinct PCALCULO as Calculo, 0 as Item, 0 as Condutor, d1.Cobertura, 0 as valor, d2.opcao,
              d1.tipo, d.solicita, 'N' as Pcondutor, 'N' as scondutor, 'N' as dcondutor, d.Mostra, 'S' as ESCOLHA, '' as observacao, 0 as taxa, 0 as franquia, 0 as premio from Mult_CobPerDic d, Mult_ProdutosCobPer d1, Mult_ProdutosCobPerOpc d2
       Where
              d1.cobertura = d.cobertura
              and d.Mostra = 'S'
              and (d1.Tipo = 'M' or d1.Tipo = 'P' or d1.Tipo = 'C')
              and d1.Produto = PPADRAO
              and (d.Escolha = 'N')
              and d2.produto (+) = d1.produto
              and d2.cobertura (+) = d1.cobertura
              and d2.Preferida (+) = 'S'
              and d.produto = d1.produto;
   END;
END;
/


CREATE OR REPLACE PROCEDURE       PROC10_CPAGINA0 (PCalculo      MULT_CALCULO.CALCULO%Type, PPadrao      MULT_CALCULO.PADRAO%Type, PDataServer Date) IS
BEGIN
  DECLARE
    PDESC VARCHAR2(40);
    PPRODUTO NUMBER(18,6);
    PGRUPO NUMBER(18,6);

    PUTILIZACAO NUMBER(18,6);

    PNIVELDM NUMBER(18,6);

    PNIVELDP NUMBER(18,6);
    PVALORAPPMORTE NUMBER(18,6);

    PVALORAPPINV NUMBER(18,6);
    PCOBERTURA NUMBER(18,6);

    PFRANQUIA NUMBER(18,6);
    PCONDICAO NUMBER(18,6);
    PCOMISSAO NUMBER(18,6);
    PDESCONTOCOMERCIAL NUMBER(18,6);
    PTIPO VARCHAR2(1);
    PTIPOAPOLICE NUMBER(18,6);
    PDATA date := sysdate;

    POpOpcao NUMBER(18,6);
    POpCobertura NUMBER(18,6);
    POpPreferida VARCHAR2(1);
    PcCobertura NUMBER(18,6);
    PcTipo1 VARCHAR2(1);
    PcSolicita VARCHAR2(1);
    PcMostra VARCHAR2(1);
    POpcao NUMBER(18,6);
    PDESC_VERSAO VARCHAR2(6);
  BEGIN
    -- Pegando vers„o da Mult_produtos (Ser· sempre a mesma para todos os produtos)
    SELECT VERSAO INTO PDESC_VERSAO FROM MULT_PRODUTOS WHERE PRODUTO = 10;


    SELECT GRUPO, UTILIZACAO, NIVELDM, NIVELDP, VALORAPPMORTE, VALORAPPINV, COBERTURA,
           FRANQUIA, CONDICAO,
           COMISSAO, DESCONTOCOMERCIAL, TIPO, TIPOAPOLICE
      Into PGRUPO, PUTILIZACAO, PNIVELDM, PNIVELDP, PVALORAPPMORTE, PVALORAPPINV,
           PCOBERTURA, PFRANQUIA, PCONDICAO,
           PCOMISSAO, PDESCONTOCOMERCIAL, PTIPO, PTIPOAPOLICE
      FROM MULT_PADRAO 
    WHERE PADRAO = PPADRAO;
    
    INSERT /*+ append */  INTO MULT_CALCULO (CALCULO, ITEM, ESTIPULANTE, CLIENTE, GRUPO, PADRAO,
       FABRICANTE, PROCEDENCIA,MODELO, ANOMODELO, ANOFABRICACAO, ZEROKM,
       VALORVEICULO, CEP, NIVELDM, NIVELDP, VALORAPPMORTE, VALORAPPINV,
       VALORAPPDMH, TIPO_COBERTURA, TIPO_FRANQUIA,
       NIVELBONUSAUTO, NIVELBONUSDM, NIVELBONUSDP, INICIOVIGENCIA, FINALVIGENCIA,
       DATACALCULO, QTDDIAS, CONDICAO, COMISSAO, DESCONTOCOMISSAO,
       CIARENOVA, QTDSINISTROS, TIPOPRODUTO, NUMPASSAGEIROS, SITUACAO, COD_CIDADE,
       COD_REFERENCIA,  COD_TABELA, VALORBASE, AJUSTE,
       NumCondutores, NumDependentes,TipoDocumento, CalculoOrigem,
       VERSAOPRIMEIROCALCULO,DATAPRIMEIROCALCULO, DATAVERSAO)
    VALUES
       (PCALCULO,0,0,0,PGRUPO,PPADRAO,PUTILIZACAO,'N',
       0,0,0,'N',0,'',PNIVELDM,PNIVELDP,PVALORAPPMORTE,PVALORAPPINV,0,
       PCOBERTURA,PFRANQUIA,0,0,0,PDATA,PDATA+365,
       PDATA,365,PCONDICAO,PCOMISSAO - PDESCONTOCOMERCIAL,PDESCONTOCOMERCIAL,0,0,
       PTIPO,5,'P',0,0,
       PTIPOAPOLICE,0,0,0,0,'A',0,PDESC_VERSAO,PDataServer, trunc(PDataServer));
       
    INSERT /*+ append */ into Mult_CalculoCob (Calculo,Item,Condutor,Cobertura,Valor,Opcao,Tipo,Solicita,PCondutor,SCondutor,DCondutor,Mostra,Escolha,Observacao,Taxa,Franquia,Premio)
      Select distinct PCALCULO as Calculo, 0 as Item, 0 as Condutor, d1.Cobertura, 0 as valor, d2.opcao,
            d1.tipo, d.solicita, 'N' as Pcondutor, 'N' as scondutor, 'N' as dcondutor, d.Mostra, 'S' as ESCOLHA, '' as observacao, 0 as taxa, 0 as franquia, 0 as premio from Mult_CobPerDic d, Mult_ProdutosCobPer d1, Mult_ProdutosCobPerOpc d2
      Where
          d1.cobertura = d.cobertura
          and d.Mostra = 'S'
          and (d1.Tipo = 'M' or d1.Tipo = 'P' or d1.Tipo = 'C')
          and d1.Produto = PPADRAO
          and (d.Escolha = 'N')
          and d2.produto (+) = d1.produto
          and d2.cobertura (+) = d1.cobertura
          and d2.Preferida (+) = 'S'
          and d.produto = d1.produto;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_CPAGINA1" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PREGIAO      MULT_CALCULO.cod_cidade%Type,
PVALOR        MULT_CALCULO.cod_cidade%Type,
PTABELA       MULT_CALCULO.cod_cidade%Type,
POBS       MULT_CALCULO.OBSERVACAO%Type,
PNCONDU       MULT_CALCULO.NUMCONDUTORES%Type,
PNDEP        MULT_CALCULO.NUMDEPENDENTES%Type,
PMODELO       MULT_CALCULO.MODELO%Type,
PTABELA1       MULT_CALCULO.MODELO%Type,
PTABELA2       MULT_CALCULO.MODELO%Type,
PTABELA3       MULT_CALCULO.MODELO%Type) IS
BEGIN
  DECLARE
	VarInt1 number(10);
   BEGIN
       Update mult_calculo set VALIDADE = DATACALCULO + 5, OBSERVACAO = PObs, NUMCONDUTORES = PNCondu, NUMDEPENDENTES = PNDep, cod_cidade = PRegiao, VALORVEICULO = Pvalor, VALORBASE = Pvalor
                      , COD_TABELA = PTABELA, ESTIPULANTE = 0, AJUSTE = 100 WHERE CALCULO = PCALCULO;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_CPAGINA2" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PVALORAPPMORTE      MULT_CALCULO.VALORAPPMORTE%Type,
PESTADO       MULT_CALCULO.ESTADO%Type,
PCIDADE      MULT_CALCULO.CIDADE%Type) IS
BEGIN
   if PVALORAPPMORTE = 0 then
      Update mult_calculo set VALORAPPMORTE = 10000 WHERE CALCULO = PCALCULO;
   end if;
   if PESTADO = '' then
      Update mult_calculo set ESTADO = 'SP' WHERE CALCULO = PCALCULO;
   end if;
   if PCIDADE = '' then
      Update mult_calculo set CIDADE = 'SAO PAULO' WHERE CALCULO = PCALCULO;
   end if;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA1" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PNOME      MULT_CALCULO.NOME%Type,
PCEP        MULT_CALCULO.CEP%Type,
PFABRICANTE       MULT_CALCULO.FABRICANTE%Type,
PZEROKM       MULT_CALCULO.ZEROKM%Type,
PPROCEDENCIA       MULT_CALCULO.PROCEDENCIA%Type,
PANOFABRICACAO        MULT_CALCULO.ANOFABRICACAO%Type,
PANOMODELO       MULT_CALCULO.ANOMODELO%Type,
PMODELO       MULT_CALCULO.MODELO%Type) IS
BEGIN
   Update mult_calculo set NOME = PNOME,
                           CEP = PCEP,
						   FABRICANTE = PFABRICANTE,
						   ZEROKM = PZEROKM,
						   PROCEDENCIA = PPROCEDENCIA,
						   ANOFABRICACAO = PANOFABRICACAO,
						   ANOMODELO = PANOMODELO,
						   MODELO = PMODELO
   where calculo = PCalculo;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA2" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PVALORVEICULO      MULT_CALCULO.VALORVEICULO%Type,
PAJUSTE        MULT_CALCULO.AJUSTE%Type) IS
BEGIN
   Update mult_calculo set VALORVEICULO = PVALORVEICULO,
                           AJUSTE = PAJUSTE
   where calculo = PCalculo;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA3" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PTIPO_COBERTURA      MULT_CALCULO.TIPO_COBERTURA%Type,
PVALORVEICULO        MULT_CALCULO.VALORVEICULO%Type,
PAJUSTE       MULT_CALCULO.AJUSTE%Type,
PNIVELDM       MULT_CALCULO.NIVELDM%Type,
PNIVELDP       MULT_CALCULO.NIVELDP%Type,
PVALORAPPDMH        MULT_CALCULO.VALORAPPDMH%Type,
PVALORAPPMORTE       MULT_CALCULO.VALORAPPMORTE%Type,
PCB000054       MULT_CALCULO.AJUSTE%Type,
PCB000945       MULT_CALCULO.AJUSTE%Type,
PCB000979       MULT_CALCULO.AJUSTE%Type,
PACE0092       MULT_CALCULO.AJUSTE%Type,
PACE0093       MULT_CALCULO.AJUSTE%Type,
PACE0098       MULT_CALCULO.AJUSTE%Type,
PACE1026       MULT_CALCULO.AJUSTE%Type,
PACE1027       MULT_CALCULO.AJUSTE%Type,
PACE1028       MULT_CALCULO.AJUSTE%Type) IS
BEGIN
   DECLARE
       PAcessorio number(16,6);
       Cursor T_ACE Is
   		   Select Acessorio from Mult_calculoAces where calculo = PCalculo;
   BEGIN
   Update mult_calculo set TIPO_COBERTURA = PTIPO_COBERTURA,
                           VALORVEICULO = PVALORVEICULO,
						   AJUSTE = PAJUSTE,
						   NIVELDM = PNIVELDM,
						   NIVELDP = PNIVELDP,
						   VALORAPPDMH = PVALORAPPDMH,
						   VALORAPPMORTE = PVALORAPPMORTE
   where calculo = PCalculo;
   Update mult_calculoCob set Opcao = PCB000054
   where calculo = PCalculo and cobertura = 54;
   Update mult_calculoCob set Opcao = PCB000945
   where calculo = PCalculo and cobertura = 945;
   Update mult_calculoCob set Opcao = PCB000979
   where calculo = PCalculo and cobertura = 979;
   Open T_ACE;
   Fetch T_ACE Into PAcessorio;
   if T_ACE%Notfound Then
      if Pace0092 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,92,'',92,0,Pace0092,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,92,'',0,0,0,0);
	  end if;
      if Pace0093 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,93,'',93,0,Pace0093,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,93,'',0,0,0,0);
	  end if;
      if Pace0098 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,98,'',98,0,Pace0098,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,98,'',0,0,0,0);
	  end if;
      if Pace1026 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1026,'',1026,0,Pace1026,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1026,'',0,0,0,0);
	  end if;
      if Pace1027 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1027,'',1027,0,Pace1027,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1027,'',0,0,0,0);
	  end if;
      if Pace1028 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1028,'',1028,0,Pace1028,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1028,'',0,0,0,0);
	  end if;
   else
      if Pace0092 <> 0 then
         Update mult_calculoAces set valor = Pace0092, tipo = 92 where calculo = PCalculo and acessorio = 92;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 92;
	  end if;
      if Pace0093 <> 0 then
         Update mult_calculoAces set valor = Pace0093, tipo = 93 where calculo = PCalculo and acessorio = 93;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 93;
	  end if;
      if Pace0098 <> 0 then
         Update mult_calculoAces set valor = Pace0098, tipo = 98 where calculo = PCalculo and acessorio = 98;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 98;
	  end if;
      if Pace1026 <> 0 then
         Update mult_calculoAces set valor = Pace1026, tipo = 1026 where calculo = PCalculo and acessorio = 1026;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1026;
	  end if;
      if Pace1027 <> 0 then
         Update mult_calculoAces set valor = Pace1027, tipo = 1027 where calculo = PCalculo and acessorio = 1027;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1027;
	  end if;
      if Pace1028 <> 0 then
         Update mult_calculoAces set valor = Pace1028, tipo = 1028 where calculo = PCalculo and acessorio = 1028;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1028;
	  end if;
   end if;
   Close T_ACE;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA3P" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PTIPO_COBERTURA      MULT_CALCULO.TIPO_COBERTURA%Type,
PVALORVEICULO        MULT_CALCULO.VALORVEICULO%Type,
PAJUSTE       MULT_CALCULO.AJUSTE%Type,
PNIVELDM       MULT_CALCULO.NIVELDM%Type,
PNIVELDP       MULT_CALCULO.NIVELDP%Type,
PVALORAPPDMH        MULT_CALCULO.VALORAPPDMH%Type,
PVALORAPPMORTE       MULT_CALCULO.VALORAPPMORTE%Type,
PCB000054       MULT_CALCULO.AJUSTE%Type,
PCB000945       MULT_CALCULO.AJUSTE%Type,
PCB000979       MULT_CALCULO.AJUSTE%Type,
PACE0092       MULT_CALCULO.AJUSTE%Type,
PACE0093       MULT_CALCULO.AJUSTE%Type,
PACE0098       MULT_CALCULO.AJUSTE%Type,
PACE1026       MULT_CALCULO.AJUSTE%Type,
PACE1027       MULT_CALCULO.AJUSTE%Type,
PACE1028       MULT_CALCULO.AJUSTE%Type,
PACE1029       MULT_CALCULO.AJUSTE%Type) IS
BEGIN
   DECLARE
       PAcessorio number(16,6);
       Cursor T_ACE Is
   		   Select Acessorio from Mult_calculoAces where calculo = PCalculo;
   BEGIN
   Update mult_calculo set TIPO_COBERTURA = PTIPO_COBERTURA,
                           VALORVEICULO = PVALORVEICULO,
			   AJUSTE = PAJUSTE,
			   NIVELDM = PNIVELDM,
			   NIVELDP = PNIVELDP,
			   VALORAPPDMH = PVALORAPPDMH,
			   VALORAPPMORTE = PVALORAPPMORTE
   where calculo = PCalculo;
   Update mult_calculoCob set Opcao = PCB000054
   where calculo = PCalculo and cobertura = 54;
   Update mult_calculoCob set Opcao = PCB000945
   where calculo = PCalculo and cobertura = 945;
   Update mult_calculoCob set Opcao = PCB000979
   where calculo = PCalculo and cobertura = 979;
   Open T_ACE;
   Fetch T_ACE Into PAcessorio;
   if T_ACE%Notfound Then
      if Pace0092 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,92,'',92,0,Pace0092,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,92,'',0,0,0,0);
	  end if;
      if Pace0093 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,93,'',93,0,Pace0093,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,93,'',0,0,0,0);
	  end if;
      if Pace0098 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,98,'',98,0,Pace0098,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,98,'',0,0,0,0);
	  end if;
      if Pace1026 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1026,'',1026,0,Pace1026,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1026,'',0,0,0,0);
	  end if;
      if Pace1027 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1027,'',1027,0,Pace1027,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1027,'',0,0,0,0);
	  end if;
      if Pace1028 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1028,'',1028,0,Pace1028,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1028,'',0,0,0,0);
	  end if;
      if Pace1029 <> 0 then
         Insert into mult_calculoAces values (PCalculo,0,1029,'',1029,0,Pace1029,0);
	  else
         Insert into mult_calculoAces values (PCalculo,0,1029,'',0,0,0,0);
	  end if;
   else
      if Pace0092 <> 0 then
         Update mult_calculoAces set valor = Pace0092, tipo = 92 where calculo = PCalculo and acessorio = 92;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 92;
	  end if;
      if Pace0093 <> 0 then
         Update mult_calculoAces set valor = Pace0093, tipo = 93 where calculo = PCalculo and acessorio = 93;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 93;
	  end if;
      if Pace0098 <> 0 then
         Update mult_calculoAces set valor = Pace0098, tipo = 98 where calculo = PCalculo and acessorio = 98;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 98;
	  end if;
      if Pace1026 <> 0 then
         Update mult_calculoAces set valor = Pace1026, tipo = 1026 where calculo = PCalculo and acessorio = 1026;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1026;
	  end if;
      if Pace1027 <> 0 then
         Update mult_calculoAces set valor = Pace1027, tipo = 1027 where calculo = PCalculo and acessorio = 1027;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1027;
	  end if;
      if Pace1028 <> 0 then
         Update mult_calculoAces set valor = Pace1028, tipo = 1028 where calculo = PCalculo and acessorio = 1028;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1028;
	  end if;
      if Pace1029 <> 0 then
         Update mult_calculoAces set valor = Pace1029, tipo = 1029 where calculo = PCalculo and acessorio = 1029;
	  else
         Update mult_calculoAces set valor = 0, tipo = 0 where calculo = PCalculo and acessorio = 1029;
	  end if;
   end if;
   Close T_ACE;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA4" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PNIVELBONUSAUTO      MULT_CALCULO.NIVELBONUSAUTO%Type,
PQBR227        MULT_CALCULO.AJUSTE%Type,
PQBR228        MULT_CALCULO.AJUSTE%Type,
PQBR229        MULT_CALCULO.AJUSTE%Type,
PQBR230        MULT_CALCULO.AJUSTE%Type,
PQBR243        MULT_CALCULO.AJUSTE%Type,
PSQBR243        MULT_CALCULO.AJUSTE%Type) IS
BEGIN
   DECLARE
        Pquestao NUMBER(16,6);
        Presposta NUMBER(16,6);
        PDescricaoResposta varchar2(200);
        PAgrupamentoRegiaoQbr NUMBER(16,6);
        PImprime NUMBER(16,6);
        PPercimpressao NUMBER(16,6);
		PSUBRESPOSTA NUMBER(16,6);
		PDescricaosubResposta varchar2(200);
        Cursor T_QBR227 Is
           select d2.Chave2 as Questao, d2.Chave4 as Resposta, d2.texto as descricaoresposta, d1.Valor as AgrupamentoRegiaoQbr, d2.Valor3 as Imprime, d2.Valor4 as Percimpressao
           from mult_produtostabrg d, mult_produtostabrg d01, Mult_produtosTabrg d1, Mult_ProdutosTabRg d2
           where
           d.produto = 10 and d.tabela = 50
           and d.chave1 = 1
           and d.chave2 <= 03415090
           and d.chave3 >= 03415090
           and d01.produto = 10 and d01.tabela = 25 and d.valor = d01.valor5
           AND d1.produto = 10
           and d1.tabela = 303
           and d1.Chave1 = d01.VALOR4
           and d2.produto = 10
           and d2.tabela = 304
           and (d2.Chave3 = d1.Valor or d2.Chave3 = 0)
           and d2.chave2 = 227
           and d2.chave4 = PQBR227
           and d2.chave1 = 17
           ORDER BY d.chave3 desc, d2.texto;
        Cursor T_QBR228 Is
           select d2.Chave2 as Questao, d2.Chave4 as Resposta, d2.texto as descricaoresposta, d1.Valor as AgrupamentoRegiaoQbr, d2.Valor3 as Imprime, d2.Valor4 as Percimpressao
           from mult_produtostabrg d, mult_produtostabrg d01, Mult_produtosTabrg d1, Mult_ProdutosTabRg d2
           where
           d.produto = 10 and d.tabela = 50
           and d.chave1 = 1
           and d.chave2 <= 03415090
           and d.chave3 >= 03415090
           and d01.produto = 10 and d01.tabela = 25 and d.valor = d01.valor5
           AND d1.produto = 10
           and d1.tabela = 303
           and d1.Chave1 = d01.VALOR4
           and d2.produto = 10
           and d2.tabela = 304
           and (d2.Chave3 = d1.Valor or d2.Chave3 = 0)
           and d2.chave2 = 228
           and d2.chave4 = PQBR228
           and d2.chave1 = 17
           ORDER BY d.chave3 desc, d2.texto;
        Cursor T_QBR229 Is
           select d2.Chave2 as Questao, d2.Chave4 as Resposta, d2.texto as descricaoresposta, d1.Valor as AgrupamentoRegiaoQbr, d2.Valor3 as Imprime, d2.Valor4 as Percimpressao
           from mult_produtostabrg d, mult_produtostabrg d01, Mult_produtosTabrg d1, Mult_ProdutosTabRg d2
           where
           d.produto = 10 and d.tabela = 50
           and d.chave1 = 1
           and d.chave2 <= 03415090
           and d.chave3 >= 03415090
           and d01.produto = 10 and d01.tabela = 25 and d.valor = d01.valor5
           AND d1.produto = 10
           and d1.tabela = 303
           and d1.Chave1 = d01.VALOR4
           and d2.produto = 10
           and d2.tabela = 304
           and (d2.Chave3 = d1.Valor or d2.Chave3 = 0)
           and d2.chave2 = 229
           and d2.chave4 = PQBR229
           and d2.chave1 = 17
           ORDER BY d.chave3 desc, d2.texto;
        Cursor T_QBR230 Is
           select d2.Chave2 as Questao, d2.Chave4 as Resposta, d2.texto as descricaoresposta, d1.Valor as AgrupamentoRegiaoQbr, d2.Valor3 as Imprime, d2.Valor4 as Percimpressao
           from mult_produtostabrg d, mult_produtostabrg d01, Mult_produtosTabrg d1, Mult_ProdutosTabRg d2
           where
           d.produto = 10 and d.tabela = 50
           and d.chave1 = 1
           and d.chave2 <= 03415090
           and d.chave3 >= 03415090
           and d01.produto = 10 and d01.tabela = 25 and d.valor = d01.valor5
           AND d1.produto = 10
           and d1.tabela = 303
           and d1.Chave1 = d01.VALOR4
           and d2.produto = 10
           and d2.tabela = 304
           and (d2.Chave3 = d1.Valor or d2.Chave3 = 0)
           and d2.chave2 = 230
           and d2.chave4 = PQBR230
           and d2.chave1 = 17
           ORDER BY d.chave3 desc, d2.texto;
        Cursor T_QBR243 Is
           select d2.Chave2 as Questao, d2.Chave4 as Resposta, d2.texto as descricaoresposta, d1.Valor as AgrupamentoRegiaoQbr, d2.Valor3 as Imprime, d2.Valor4 as Percimpressao
           from mult_produtostabrg d, mult_produtostabrg d01, Mult_produtosTabrg d1, Mult_ProdutosTabRg d2
           where
           d.produto = 10 and d.tabela = 50
           and d.chave1 = 1
           and d.chave2 <= 03415090
           and d.chave3 >= 03415090
           and d01.produto = 10 and d01.tabela = 25 and d.valor = d01.valor5
           AND d1.produto = 10
           and d1.tabela = 303
           and d1.Chave1 = d01.VALOR4
           and d2.produto = 10
           and d2.tabela = 304
           and (d2.Chave3 = d1.Valor or d2.Chave3 = 0)
           and d2.chave2 = 243
           and d2.chave4 = PQBR243
           and d2.chave1 = 17
           ORDER BY d.chave3 desc, d2.texto;
        Cursor T_SQBR243 Is
           select chave1 as resposta, chave2 as SUBRESPOSTA, texto as DescricaosubResposta from mult_produtostabrg
           where produto = 10
           and tabela = 305
           and chave1 = PQBR243
           and chave2 = PSQBR243;
   BEGIN
   Update mult_calculo set NIVELBONUSAUTO = PNIVELBONUSAUTO
   where calculo = PCalculo;
   Open T_QBR227;
   Fetch T_QBR227 Into Pquestao, Presposta, PDescricaoResposta, PAgrupamentoRegiaoQbr, PImprime, PPercimpressao;
   if T_QBR227%NotFound then
      Close T_QBR227;
   else
      Update mult_calculoQbr set Resposta = Presposta
             ,DescricaoResposta = PDescricaoResposta
             ,AgrupamentoRegiaoQbr = PAgrupamentoRegiaoQbr
             ,Imprime = PImprime
             ,PercImpressao = PPercimpressao
      where calculo = PCalculo
	        and Questao = 227;
      Close T_QBR227;
   end if;
   Open T_QBR228;
   Fetch T_QBR228 Into Pquestao, Presposta, PDescricaoResposta, PAgrupamentoRegiaoQbr, PImprime, PPercimpressao;
   if T_QBR228%NotFound then
      Close T_QBR228;
   else
      Update mult_calculoQbr set Resposta = Presposta
             ,DescricaoResposta = PDescricaoResposta
             ,AgrupamentoRegiaoQbr = PAgrupamentoRegiaoQbr
             ,Imprime = PImprime
             ,PercImpressao = PPercimpressao
      where calculo = PCalculo
	        and Questao = 228;
      Close T_QBR228;
   end if;
   Open T_QBR229;
   Fetch T_QBR229 Into Pquestao, Presposta, PDescricaoResposta, PAgrupamentoRegiaoQbr, PImprime, PPercimpressao;
   if T_QBR229%NotFound then
      Close T_QBR229;
   else
      Update mult_calculoQbr set Resposta = Presposta
             ,DescricaoResposta = PDescricaoResposta
             ,AgrupamentoRegiaoQbr = PAgrupamentoRegiaoQbr
             ,Imprime = PImprime
             ,PercImpressao = PPercimpressao
      where calculo = PCalculo
	        and Questao = 229;
      Close T_QBR229;
   end if;
   Open T_QBR230;
   Fetch T_QBR230 Into Pquestao, Presposta, PDescricaoResposta, PAgrupamentoRegiaoQbr, PImprime, PPercimpressao;
   if T_QBR230%NotFound then
      Close T_QBR230;
   else
      Update mult_calculoQbr set Resposta = Presposta
             ,DescricaoResposta = PDescricaoResposta
             ,AgrupamentoRegiaoQbr = PAgrupamentoRegiaoQbr
             ,Imprime = PImprime
             ,PercImpressao = PPercimpressao
      where calculo = PCalculo
	        and Questao = 230;
      Close T_QBR230;
   end if;
   Open T_QBR243;
   Fetch T_QBR243 Into Pquestao, Presposta, PDescricaoResposta, PAgrupamentoRegiaoQbr, PImprime, PPercimpressao;
   if T_QBR243%NotFound then
      Close T_QBR243;
   else
      Update mult_calculoQbr set Resposta = Presposta
             ,DescricaoResposta = PDescricaoResposta
             ,AgrupamentoRegiaoQbr = PAgrupamentoRegiaoQbr
             ,Imprime = PImprime
             ,PercImpressao = PPercimpressao
      where calculo = PCalculo
	        and Questao = 243;
      Close T_QBR243;
   end if;
   Open T_SQBR243;
   Fetch T_SQBR243 Into Presposta, PSUBRESPOSTA, PDescricaosubResposta;
   if T_SQBR243%NotFound then
      Close T_SQBR243;
   else
      Update mult_calculoQbr set SubResposta = PSUBRESPOSTA
             ,DescricaoSubResposta = PDescricaosubResposta
      where calculo = PCalculo
            and Questao = 243;
      Close T_SQBR243;
   end if;

   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA7" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PNOME      MULT_CALCULO.NOME%Type,
PCHASSI        MULT_CALCULO.CHASSI%Type,
PPARTICIPACAO1       MULT_CALCULOCONDU.PARTICIPACAO%Type,
PPARENTESCO1       MULT_CALCULOCONDU.PARENTESCO%Type,
PESTADOCIVIL1       MULT_CALCULOCONDU.ESTADOCIVIL%Type,
PPARTICIPACAO2       MULT_CALCULOCONDU.PARTICIPACAO%Type,
PPARENTESCO2       MULT_CALCULOCONDU.PARENTESCO%Type,
PESTADOCIVIL2       MULT_CALCULOCONDU.ESTADOCIVIL%Type,
PPARTICIPACAO3       MULT_CALCULOCONDU.PARTICIPACAO%Type,
PPARENTESCO3       MULT_CALCULOCONDU.PARENTESCO%Type,
PESTADOCIVIL3       MULT_CALCULOCONDU.ESTADOCIVIL%Type,
POBS3       MULT_CALCULOCONDU.OBS%Type,
PPARTICIPACAO4       MULT_CALCULOCONDU.PARTICIPACAO%Type,
PPARENTESCO4       MULT_CALCULOCONDU.PARENTESCO%Type,
PESTADOCIVIL4       MULT_CALCULOCONDU.ESTADOCIVIL%Type,
PNOME5       MULT_CALCULOCONDU.NOME%Type,
PESTADO       MULT_CALCULO.ESTADO%Type,
PCIDADE       MULT_CALCULO.CIDADE%Type,
PESTIPULANTE       MULT_CALCULO.ESTIPULANTE%Type) IS
BEGIN
   DECLARE
       PCondutor number(16,6);
       Cursor T_CONDU Is
   		   Select Condutor from Mult_calculoCondu where calculo = PCalculo;
   BEGIN
   Update mult_calculo set NOME = PNOME,
                           CHASSI = PCHASSI,
						   ESTADO = PESTADO,
						   CIDADE = PCIDADE,
						   ESTIPULANTE = PESTIPULANTE
   where calculo = PCalculo;
   Open T_CONDU;
   Fetch T_CONDU Into PCondutor;
   if T_CONDU%Notfound Then
      Insert into mult_calculoCondu (Calculo, Item, Condutor, Participacao, Parentesco, EstadoCivil, Nome, Obs)
	  values (PCalculo,0,1,PPARTICIPACAO1,PPARENTESCO1,PESTADOCIVIL1,'','');
      Insert into mult_calculoCondu (Calculo, Item, Condutor, Participacao, Parentesco, EstadoCivil, Nome, Obs)
	  values (PCalculo,0,2,PPARTICIPACAO2,PPARENTESCO2,PESTADOCIVIL2,'','');
      Insert into mult_calculoCondu (Calculo, Item, Condutor, Participacao, Parentesco, EstadoCivil, Nome, Obs)
	  values (PCalculo,0,3,PPARTICIPACAO3,PPARENTESCO3,PESTADOCIVIL3,'',POBS3);
      Insert into mult_calculoCondu (Calculo, Item, Condutor, Participacao, Parentesco, EstadoCivil, Nome, Obs)
	  values (PCalculo,0,4,PPARTICIPACAO4,PPARENTESCO4,PESTADOCIVIL4,'','');
      Insert into mult_calculoCondu (Calculo, Item, Condutor, Participacao, Parentesco, EstadoCivil, Nome, Obs)
	  values (PCalculo,0,5,0,'','',PNOME5,'');
   else
      Update mult_calculoCondu set Participacao = PPARTICIPACAO1, Parentesco = PPARENTESCO1, EstadoCivil =  PESTADOCIVIL1 where calculo = PCalculo and Condutor = 1;
      Update mult_calculoCondu set Participacao = PPARTICIPACAO2, Parentesco = PPARENTESCO2, EstadoCivil =  PESTADOCIVIL2 where calculo = PCalculo and Condutor = 2;
      Update mult_calculoCondu set Participacao = PPARTICIPACAO3, Parentesco = PPARENTESCO3, EstadoCivil =  PESTADOCIVIL3, Obs = PObs3 where calculo = PCalculo and Condutor = 3;
      Update mult_calculoCondu set Participacao = PPARTICIPACAO4, Parentesco = PPARENTESCO4, EstadoCivil =  PESTADOCIVIL4 where calculo = PCalculo and Condutor = 4;
      Update mult_calculoCondu set Nome = PNome5 where calculo = PCalculo and Condutor = 5;
   end if;
   Close T_CONDU;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GPAGINA9" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PTIPO_FRANQUIA      MULT_CALCULO.TIPO_FRANQUIA%Type,
PPRODUTO      MULT_CALCULOCONDPAR.PRODUTO%Type,
PTIPOCOTACAO      MULT_CALCULOCONDPAR.TIPOCOTACAO%Type,
PCONDICAO      MULT_CALCULOCONDPAR.CONDICAO%Type,
PPARCELAS      MULT_CALCULOCONDPAR.PARCELAS%Type) IS
BEGIN
   Update mult_calculo set TIPO_FRANQUIA = PTIPO_FRANQUIA
   where calculo = PCalculo;
   if PProduto <> 0 then
      Update Mult_CalculoPremios set Escolha = 'N'
      Where Calculo = PCALCULO;
      Update Mult_CalculoPremios set Escolha = 'S'
      Where Calculo = PCALCULO
      And Item = 0
      and Produto = PPRODUTO
      and TipoCotacao = PTIPOCOTACAO;
      Update Mult_CalculoCond set Escolha = 'N'
      Where Calculo = PCALCULO;
      Update Mult_CalculoCond set Escolha = 'S'
      Where Calculo = PCALCULO
      and Item = 0
      and Produto = PPRODUTO
      and TipoCotacao = PTIPOCOTACAO
      and Condicao = PCONDICAO;
      Update Mult_CalculoCondpar set Escolha = 'N'
      Where Calculo = PCALCULO;
      Update Mult_CalculoCondpar set Escolha = 'S'
      Where Calculo = PCALCULO
      and Item = 0
      and Produto = PPRODUTO
      and TipoCotacao = PTIPOCOTACAO
      and parcelas = PPARCELAS
      and Condicao = PCONDICAO;
      Update Mult_Calculo set Situacao = 'I'
      Where Calculo = PCALCULO;
   end if;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GRAVAERRO" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PTIPOCOTACAO        MULT_CALCULOPREMIOS.TIPOCOTACAO%Type,
PMENSAGEM      MULT_CALCULOPREMIOS.errorMessage%Type) IS
BEGIN
  IF PTIPOCOTACAO <> 0 THEN
     Update mult_calculopremios set errorMessage = PMENSAGEM
     where calculo = PCALCULO AND Item = 0 and TipoCotacao = PTIPOCOTACAO;
  ELSE
     Update mult_calculopremios set errorMessage = PMENSAGEM
     where calculo = PCALCULO AND Item = 0 ;
  END IF;
END;
/


CREATE OR REPLACE PROCEDURE "PROC10_GRAVAPARCELA" (
PCALCULO      MULT_CALCULO.CALCULO%Type,
PPRODUTO      MULT_CALCULOCONDPAR.PRODUTO%Type,
PTIPOCOTACAO        MULT_CALCULOCONDPAR.TIPOCOTACAO%Type,
PCONDICAO        MULT_CALCULOCONDPAR.CONDICAO%Type,
PPARCELAS        MULT_CALCULOCONDPAR.PARCELAS%Type,
PPRIM       MULT_CALCULOCONDPAR.VALOR_PRIMEIRA%Type,
PDEMA       MULT_CALCULOCONDPAR.VALOR_DEMAIS%Type) IS
BEGIN
   DECLARE
       CPRODUTO number(16,6);
       Cursor T_COND Is
          SELECT PRODUTO FROM MULT_CALCULOCOND
		  WHERE CALCULO = PCALCULO
		    AND ITEM    = 0
			AND PRODUTO = PPRODUTO
			AND TIPOCOTACAO = PTIPOCOTACAO
            AND CONDICAO = PCONDICAO;
       Cursor T_CONDPAR Is
          SELECT CALCULO FROM MULT_CALCULOCONDPAR
          WHERE CALCULO  = PCALCULO
            AND ITEM     = 0
            AND PRODUTO  = PPRODUTO
            AND TIPOCOTACAO = PTIPOCOTACAO
            AND CONDICAO    = PCONDICAO
            AND PARCELAS    = PPARCELAS;
   BEGIN
   Open T_COND;
   Fetch T_COND Into CPRODUTO;
   if T_COND%Notfound Then
      INSERT INTO MULT_CALCULOCOND
            (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,CONDICAO,ESCOLHA)
      VALUES (PCALCULO,0,PPRODUTO,PTIPOCOTACAO,PCONDICAO,'N');
   end if;
   Close T_COND;
   Open T_CONDPAR;
   Fetch T_CONDPAR Into CPRODUTO;
   if T_CONDPAR%Notfound Then
     INSERT INTO MULT_CALCULOCONDPAR
            (CALCULO,ITEM,PRODUTO,TIPOCOTACAO,CONDICAO,
             PARCELAS,VALOR_PRIMEIRA,VALOR_DEMAIS,ESCOLHA)
     VALUES (PCALCULO,0,PPRODUTO,PTIPOCOTACAO,PCONDICAO,
	         PPARCELAS,PPRIM,PDEMA,'N');
   else
     UPDATE MULT_CALCULOCONDPAR
        SET VALOR_PRIMEIRA= PPRIM,
            VALOR_DEMAIS  = PDEMA
     WHERE CALCULO       = PCALCULO
        AND ITEM          = 0
        AND PRODUTO       = PPRODUTO
        AND TIPOCOTACAO   = PTIPOCOTACAO
        AND CONDICAO      = PCONDICAO
        AND PARCELAS      = PPARCELAS;
   end if;
   Close T_CONDPAR;
   END;
END;
/


CREATE OR REPLACE PROCEDURE "REGIAOPORCEP3" (
    PPRODUTO IN mult_produtostabrg.PRODUTO%TYPE,
		PDATAVIGEN1 IN mult_produtostabrg.DT_INICO_VIGEN%TYPE,
		PDATAVIGEN2 IN mult_produtostabrg.DT_FIM_VIGEN%TYPE,
    PCHAVE2  IN mult_produtostabrg.CHAVE2%TYPE,
    PCAMPO OUT TYPES.CURSOR_TYPE
)
IS
BEGIN
OPEN PCAMPO FOR
  Select d.valor from mult_produtostabrg d
  where d.produto = PPRODUTO and d.tabela = 50
	  and DT_INICO_VIGEN <= PDATAVIGEN1
		and DT_FIM_VIGEN >= PDATAVIGEN2
    and d.chave2 <= PCHAVE2
    and d.chave3 >= PCHAVE2
order by d.chave3 desc;
end;
/


CREATE OR REPLACE PROCEDURE "RENUMERACALCULO" 
( PCALCOLD in MULT_CALCULO.CALCULO%Type,
  PCALCNEW in MULT_CALCULO.CALCULO%Type
)
IS
BEGIN
   Update Mult_calculo set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoCorretor set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoRealCor set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoAces set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoBens set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoCob set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoCobOp set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoCondu set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoPremiosCob set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoPremios set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoCond set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoCondPar set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoQBR set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoDivisoes set Calculo = PCalcNew  where Calculo = PCalcOld;
   Update Mult_calculoOcorrencias set Calculo = PCalcNew  where Calculo = PCalcOld;
END;
/


CREATE OR REPLACE PROCEDURE        TESTENOME(nome in varchar) AS 
begin
  dbms_output.put_line( nome ); 
END TESTENOME;
/


CREATE OR REPLACE PROCEDURE        TESTENOMESEMPARAM (NOME OUT VARCHAR) AS 
begin
  NOME := 'NOME TESTE'; 
END TESTENOMESEMPARAM;
/


CREATE OR REPLACE PROCEDURE ZParse_XML_CalcularSantander
IS
   --
   CURSOR c_Log_ConsultaQBR
   IS
        --
        SELECT id_log_calcr_stder,
               dt_inico_log,
               dt_fim_log,
               ds_msg_erro_log,
               -----
               NR_COTAC_MC1,
               NR_COTAC_MC2,
               NM_CLIEN,
               NR_CPF_CNPJ
          FROM KIT0016_LOG_CALCR_STDER
         WHERE tempo_em_mlseg IS NULL
      --AND     ID_LOG_CALCR    =       2364
      --AND     ROWNUM  <=       5
      ORDER BY id_log_calcr_stder DESC;

   --
   v_tempo_milisegundos        NUMBER (15);
   ct_commit                   NUMBER := 0;
   v_xml_saida                 XMLTYPE;
   v_mensagens_erro            VARCHAR2 (4000);
   v_tp_erro                   NUMBER (3);
   ct_erro                     NUMBER (15) := 0;
   v_hora_minima_sem_retorno   DATE;
--
   v_nr_cotac_mc1    VARCHAR2(100);
   v_nr_cotac_mc2   VARCHAR2(100);
   v_nm_clien          VARCHAR2(40);
   v_nr_cpf_cnpj     VARCHAR2(40);

BEGIN
   --
   --
   v_hora_minima_sem_retorno := SYSDATE - (15 / (24 * 60));

   --
   --Dbms_Output.Put_Line('sysdate: ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

   --Dbms_Output.Put_Line('sysdate: ' || To_Char(v_hora_minima_sem_retorno,'dd/mm/yyyy hh24:mi:ss'));
   --
   FOR r_Log IN c_Log_ConsultaQBR
   LOOP
      --
      --Dbms_Output.Put_Line('r_Log_Calcular.id_log_calcr: ' || r_Log_ConsultaValorMercado.id_log_calcr);
      --
      BEGIN
         --
         v_xml_saida := XMLTYPE (r_Log.ds_msg_erro_log);
      --
      EXCEPTION
         --
         WHEN OTHERS
         THEN
            --
            v_xml_saida := NULL;
      --Dbms_Output.Put_Line('erro no xmltype saida');
      --Dbms_Output.Put_Line(SubStr(SQLERRM,1,200));
      --
      --
      END;

      --
      BEGIN
         --
         v_tempo_milisegundos :=
            fws011_calcmilesec (r_Log.dt_fim_log, r_Log.dt_inico_log);
      --
      EXCEPTION
         --
         WHEN OTHERS
         THEN
            --
            v_tempo_milisegundos := NULL;
      --
      END;

      --
      BEGIN
         --
         SELECT EXTRACTVALUE (v_xml_saida, '//Retorno/Erros/Mensagem[1]')
           INTO v_mensagens_erro
           FROM DUAL;
      --
      EXCEPTION
         WHEN OTHERS
         THEN
            --
            v_mensagens_erro := NULL;
      --
      END;

      --Dbms_Output.Put_Line('v_mensagens_erro: ' || SubStr(v_mensagens_erro,1,200));
      --
      IF v_mensagens_erro IS NULL
      THEN
         --
         v_tp_erro := NULL;
      --
      ELSE
         --
         -- To-Do: pesquisar na tabela de
         v_tp_erro := 0;
         ct_erro := ct_erro + 1;
      --
      END IF;

      --
      IF r_Log.dt_fim_log IS NULL
         AND r_Log.dt_inico_log < v_hora_minima_sem_retorno
      THEN
         --
         --Dbms_Output.Put_Line('entrou no if');
         v_tp_erro := 0001;
         v_tempo_milisegundos := -1;
      --
      END IF;

      --
      UPDATE KIT0016_LOG_CALCR_STDER
         SET tempo_em_mlseg = v_tempo_milisegundos,
             ds_msg_erro_log = v_mensagens_erro,
             tp_erro_xml = v_tp_erro
       WHERE id_log_calcr_stder = r_Log.id_log_calcr_stder;

      --
      ct_commit := ct_commit + 1;

      --
      IF ct_commit > 5
      THEN
         --
         COMMIT;
         --
         ct_commit := 0;
      --
      END IF;
   --
   END LOOP;

   --
   IF ct_erro >= 100
   THEN
      --
      NULL;
   -- To-Do: Enviar e-mail
   --
   END IF;

   --
   COMMIT;
--
END ZParse_XML_CalcularSantander;
/
