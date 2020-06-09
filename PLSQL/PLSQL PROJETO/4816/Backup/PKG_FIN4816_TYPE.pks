CREATE OR REPLACE PACKAGE MSAF.pkg_fin4816_type 
IS 


 TYPE typ_fin4816_rtf IS RECORD
    (
      "Codigo da Empresa"              VARCHAR2(3 BYTE),
      "Codigo do Estabelecimento"      VARCHAR2(6 BYTE),
      "Periodo de Emiss�o"             VARCHAR2(7 BYTE),
      "CNPJ Drogaria"                  VARCHAR2(14 BYTE),
      "Numero da Nota Fiscal"          VARCHAR2(12 BYTE),
      "Tipo de Documento"              VARCHAR2(5 BYTE),
      "Data Emiss�o"                   DATE,
      "CNPJ Fonecedor"                 VARCHAR2(50 BYTE),
      UF                               VARCHAR2(5 BYTE),
      "Valor Total da Nota"            NUMBER(17,2),
      "Base de Calculo INSS"           NUMBER(17,2),
      "Valor do INSS"                  NUMBER(17,2),
      "Codigo Pessoa Fisica/juridica"  VARCHAR2(14 BYTE),
      "Raz�o Social"                   VARCHAR2(120 BYTE),
      "Municipio Prestador"            VARCHAR2(50 BYTE),
      "Codigo de Servi�o"              VARCHAR2(14 BYTE),
      "Codigo CEI"                     VARCHAR2(15 BYTE),
      id_rtf                           NUMBER,
      DWT                              VARCHAR2(10 BYTE),
      
      --
      EMPRESA                          VARCHAR2(6 BYTE),
      "Codigo Estabelecimento"         VARCHAR2(6 BYTE),
      COD_PESSOA_FIS_JUR               VARCHAR2(14 BYTE),
      "Raz�o Social Cliente"           VARCHAR2(70 BYTE),
      "CNPJ Cliente"                   VARCHAR2(14 BYTE),
      "Nro. Nota Fiscal"               VARCHAR2(12 BYTE),
      "Dt. Emissao"                    DATE,
      "Dt. Fiscal"                     DATE,
      "Vlr. Total da Nota"             NUMBER,
      "Vlr Base Calc. Reten��o"        NUMBER,
      "Vlr. Aliquota INSS"             NUMBER,
      "Vlr.Trib INSS RETIDO"           NUMBER,
      "Raz�o Social Drogaria"          VARCHAR2(70 BYTE),
      "CNPJ Drogarias"                 VARCHAR2(14 BYTE),
      "Descr. Tp. Documento"           VARCHAR2(5 BYTE),
      "Tp.Serv. E-social"              VARCHAR2(9 BYTE),
      "Descr. Tp. Serv E-social"       VARCHAR2(100 BYTE),
      "Vlr. do Servico"                NUMBER,
      "Cod. Serv. Mastersaf"           VARCHAR2(4 BYTE),
      "Descr. Serv. Mastersaf"         VARCHAR2(50 BYTE),
      ID_INSS_RETIDO                   NUMBER,
      --
      "Codigo Empresa"                 VARCHAR2(3 BYTE),
      "Raz�o Social Drogaria."         VARCHAR2(100 BYTE),
      "Raz�o Social Cliente."          VARCHAR2(70 BYTE),
      "N�mero da Nota Fiscal."         VARCHAR2(15 BYTE),
      "Data de Emiss�o da NF."         DATE,
      "Data Fiscal."                   DATE,
      "Valor do Tributo."              NUMBER,
      "Observa��o."                    VARCHAR2(250 BYTE),
      "Tipo de Servi�o E-social."      VARCHAR2(40 BYTE),
      "Vlr. Base de Calc. Reten��o."   NUMBER,
      "Valor da Reten��o."             NUMBER,
      ID_REINF_E2010                   NUMBER,
      ID_GERAL                         NUMBER,
      --  NOVOS CAMPOS  --  02/06/2020
      "Doc. Cont�bil"                  VARCHAR2(255),
      NM_USER                          VARCHAR2(255),
      ID_PROCID                        NUMBER ,
      "Data da Execu��o"               DATE   
    );
    
    
          
    
    
    
      TYPE table_fin4816_rtf IS TABLE OF typ_fin4816_rtf
        INDEX BY PLS_INTEGER;

      t_fin4816_rtf table_fin4816_rtf;
    
     r_fin4816_rel_apoio_fiscal  msafi.tb_fin4816_rel_apoio_fiscalV5%rowtype;  --  TARGET LOOP
  
    
  END pkg_fin4816_type;
/