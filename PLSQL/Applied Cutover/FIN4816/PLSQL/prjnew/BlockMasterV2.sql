

DECLARE
    p_data_inicial DATE             := '01/12/2018';
    p_data_final DATE               := '31/12/2018';
    p_cod_empresa VARCHAR2 ( 10 )   := 'DSP';
    p_cod_estab VARCHAR2 ( 10 )     := 'DSP004';
    idx NUMBER ( 10 )               := 0;
    ---
    v_sql VARCHAR2 ( 32767 );
    l_status  varchar2(10);
    
    
   TYPE typ_fin4816_rtf IS RECORD
    (
      "Codigo da Empresa"              VARCHAR2(3 BYTE),
      "Codigo do Estabelecimento"      VARCHAR2(6 BYTE),
      "Periodo de Emissão"             VARCHAR2(7 BYTE),
      "CNPJ Drogaria"                  VARCHAR2(14 BYTE),
      "Numero da Nota Fiscal"          VARCHAR2(12 BYTE),
      "Tipo de Documento"              VARCHAR2(5 BYTE),
      "Data Emissão"                   DATE,
      "CNPJ Fonecedor"                 VARCHAR2(50 BYTE),
      UF                               VARCHAR2(5 BYTE),
      "Valor Total da Nota"            NUMBER(17,2),
      "Base de Calculo INSS"           NUMBER(17,2),
      "Valor do INSS"                  NUMBER(17,2),
      "Codigo Pessoa Fisica/juridica"  VARCHAR2(14 BYTE),
      "Razão Social"                   VARCHAR2(120 BYTE),
      "Municipio Prestador"            VARCHAR2(50 BYTE),
      "Codigo de Serviço"              VARCHAR2(14 BYTE),
      "Codigo CEI"                     VARCHAR2(15 BYTE),
      DWT                              VARCHAR2(1 BYTE),
      EMPRESA                          VARCHAR2(6 BYTE),
      "Codigo Estabelecimento"         VARCHAR2(6 BYTE),
      COD_PESSOA_FIS_JUR               VARCHAR2(14 BYTE),
      "Razão Social Cliente"           VARCHAR2(70 BYTE),
      "CNPJ Cliente"                   VARCHAR2(14 BYTE),
      "Nro. Nota Fiscal"               VARCHAR2(12 BYTE),
      "Dt. Emissao"                    DATE,
      "Dt. Fiscal"                     DATE,
      "Vlr. Total da Nota"             NUMBER,
      "Vlr Base Calc. Retenção"        NUMBER,
      "Vlr. Aliquota INSS"             NUMBER,
      "Vlr.Trib INSS RETIDO"           NUMBER,
      "Razão Social Drogaria"          VARCHAR2(70 BYTE),
      "CNPJ Drogarias"                 VARCHAR2(14 BYTE),
      "Descr. Tp. Documento"           VARCHAR2(5 BYTE),
      "Tp.Serv. E-social"              VARCHAR2(9 BYTE),
      "Descr. Tp. Serv E-social"       VARCHAR2(100 BYTE),
      "Vlr. do Servico"                NUMBER,
      "Cod. Serv. Mastersaf"           VARCHAR2(4 BYTE),
      "Descr. Serv. Mastersaf"         VARCHAR2(50 BYTE),
      "Codigo Empresa"                 VARCHAR2(3 BYTE),
      "Razão Social Drogaria."         VARCHAR2(100 BYTE),
      "Razão Social Cliente."          VARCHAR2(70 BYTE),
      "Número da Nota Fiscal."         VARCHAR2(15 BYTE),
      "Data de Emissão da NF."         DATE,
      "Data Fiscal."                   DATE,
      "Valor do Tributo."              NUMBER,
      "Observação."                    VARCHAR2(250 BYTE),
      "Tipo de Serviço E-social."      VARCHAR2(40 BYTE),
      "Vlr. Base de Calc. Retenção."   NUMBER,
      "Valor da Retenção."             NUMBER
    );
    
    
    
      TYPE table_fin4816_rtf IS TABLE OF typ_fin4816_rtf
        INDEX BY PLS_INTEGER;

      t_fin4816_rtf table_fin4816_rtf;
    
    
  
               
        
        
        CURSOR cr_rtf 
        IS
        SELECT   x09_itens_serv.cod_empresa         AS cod_empresa          -- Codigo da Empresa
               , x09_itens_serv.cod_estab           AS cod_estab            -- Codigo do Estabelecimento
               , x09_itens_serv.data_fiscal         AS data_fiscal          -- Data Fiscal
               , x09_itens_serv.movto_e_s           AS movto_e_s
               , x09_itens_serv.norm_dev            AS norm_dev
               , x09_itens_serv.ident_docto         AS ident_docto
               , x09_itens_serv.ident_fis_jur       AS ident_fis_jur
               , x09_itens_serv.num_docfis          AS num_docfis
               , x09_itens_serv.serie_docfis        AS serie_docfis
               , x09_itens_serv.sub_serie_docfis    AS sub_serie_docfis
               , x09_itens_serv.ident_servico       AS ident_servico
               , x09_itens_serv.num_item            AS num_item
               , x07_docto_fiscal.data_emissao      AS perido_emissao       -- Periodo de Emissão
               , estabelecimento.cgc                AS cgc                  -- CNPJ Drogaria
               , x07_docto_fiscal.num_docfis        AS num_docto            -- Numero da Nota Fiscal
               , x2005_tipo_docto.cod_docto         AS tipo_docto           -- Tipo de Documento
               , x07_docto_fiscal.data_emissao      AS data_emissao         -- Data Emissão
               , x04_pessoa_fis_jur.cpf_cgc         AS cgc_fornecedor       -- CNPJ_Fonecedor
               , estado.cod_estado                  AS uf                   -- uf
               , x09_itens_serv.vlr_tot             AS valor_total          -- Valor Total da Nota
               , x09_itens_serv.vlr_base_inss       AS base_inss            -- Base de Calculo INSS
               , x09_itens_serv.vlr_inss_retido     AS valor_inss           -- Valor do INSS
               , x04_pessoa_fis_jur.cod_fis_jur     AS cod_fis_jur          -- Codigo Pessoa Fisica/juridica
               , x04_pessoa_fis_jur.razao_social    AS razao_social         -- Razão Social
               , municipio.descricao                AS municipio_prestador  -- Municipio Prestador
               , x2018_servicos.cod_servico         AS cod_servico          -- Codigo de Serviço
               , x07_docto_fiscal.cod_cei           AS cod_cei              -- Codigo CEI
               , NULL                               AS equalizacao          -- Equalização
            FROM x07_docto_fiscal
               , x2005_tipo_docto
               , x04_pessoa_fis_jur
               , x09_itens_serv
               , estabelecimento
               , estado
               , x2018_servicos
               , municipio
            --   , msafi.tb_fin4816_prev_tmp_estab estab
           WHERE 1 = 1
             AND x09_itens_serv.cod_empresa = estabelecimento.cod_empresa
             AND x09_itens_serv.cod_estab = estabelecimento.cod_estab
            -- AND x09_itens_serv.cod_estab = estab.cod_estab
             --AND estab.proc_id          = pproc_id
             AND x09_itens_serv.cod_empresa = x07_docto_fiscal.cod_empresa
             AND x09_itens_serv.cod_estab = x07_docto_fiscal.cod_estab
             AND x09_itens_serv.data_fiscal = x07_docto_fiscal.data_fiscal
             AND x07_docto_fiscal.data_emissao between   p_data_inicial  and p_data_final
             AND x09_itens_serv.vlr_inss_retido           > 0
             AND x09_itens_serv.movto_e_s = x07_docto_fiscal.movto_e_s
             AND x09_itens_serv.norm_dev = x07_docto_fiscal.norm_dev
             AND x09_itens_serv.ident_docto = x07_docto_fiscal.ident_docto
             AND x09_itens_serv.ident_fis_jur = x07_docto_fiscal.ident_fis_jur
             AND x09_itens_serv.num_docfis = x07_docto_fiscal.num_docfis
             AND x09_itens_serv.serie_docfis = x07_docto_fiscal.serie_docfis
             AND x09_itens_serv.sub_serie_docfis = x07_docto_fiscal.sub_serie_docfis
             -- estado /municio
             AND estado.ident_estado = x04_pessoa_fis_jur.ident_estado
             AND municipio.ident_estado = estado.ident_estado
             AND municipio.cod_municipio = x04_pessoa_fis_jur.cod_municipio
             --  X2018_SERVICOS
             AND x2018_servicos.ident_servico = x09_itens_serv.ident_servico
             AND ( x2005_tipo_docto.ident_docto = x07_docto_fiscal.ident_docto )
             AND ( x04_pessoa_fis_jur.ident_fis_jur = x07_docto_fiscal.ident_fis_jur )
             AND ( x07_docto_fiscal.movto_e_s IN ( 1, 2, 3, 4, 5 ) )              AND ( ( x07_docto_fiscal.situacao <> 'S' )               OR ( x07_docto_fiscal.situacao IS NULL ) )
             AND ( x07_docto_fiscal.cod_estab = p_cod_estab ) --estab.cod_estab ) -- COD_ESTAB
             AND ( x07_docto_fiscal.cod_empresa = p_cod_empresa )
             AND ( x07_docto_fiscal.cod_class_doc_fis = '2' )
             AND ( ( x07_docto_fiscal.ident_cfo IS NULL )
               OR ( NOT ( EXISTS
                             (SELECT 1
                                FROM x2012_cod_fiscal x2012
                                   , prt_cfo_uf_msaf pcum
                                   , estabelecimento est
                               WHERE x2012.ident_cfo = x07_docto_fiscal.ident_cfo
                                 AND est.cod_empresa = x07_docto_fiscal.cod_empresa
                                 AND est.cod_estab = x07_docto_fiscal.cod_estab
                                 AND pcum.cod_empresa = est.cod_empresa
                                 AND pcum.cod_param = 415 --
                                 AND pcum.ident_estado = est.ident_estado
                                 AND pcum.cod_cfo = x2012.cod_cfo)
                     AND EXISTS
                             (SELECT 1
                                FROM ict_par_icms_uf ipiu
                                   , estabelecimento esta
                               WHERE ipiu.ident_estado = esta.ident_estado
                                 AND esta.cod_empresa = x07_docto_fiscal.cod_empresa
                                 AND esta.cod_estab = x07_docto_fiscal.cod_estab
                                 AND ipiu.dsc_param = '64'
                                 AND ipiu.ind_tp_par = 'S') ) ) )
        ORDER BY x09_itens_serv.cod_empresa
               , x09_itens_serv.cod_estab
               , x09_itens_serv.data_fiscal
               , x09_itens_serv.movto_e_s
               , x09_itens_serv.norm_dev
               , x09_itens_serv.ident_docto
               , x09_itens_serv.ident_fis_jur
               , x09_itens_serv.num_docfis
               , x09_itens_serv.serie_docfis
               , x09_itens_serv.sub_serie_docfis
               , x09_itens_serv.ident_servico
               , x09_itens_serv.num_item;
     


          r_fin4816_rel_apoio_fiscal  msafi.tb_fin4816_rel_apoio_fiscal%rowtype;  --  TARGET LOOP
          
          
       
    
    BEGIN
      delete msafi.tb_fin4816_rel_apoio_fiscalV5 ;
      commit;
      --  select * from msafi.tb_fin4816_rel_apoio_fiscal
      --  select * from msafi.reinf_conf_previdenciaria_tmp
            
      
--    p_data_inicial DATE             := '01/01/2019';
--    p_data_final DATE               := '31/01/2019';
--    p_cod_empresa VARCHAR2 ( 10 )   := 'DSP';
--    p_cod_estab VARCHAR2 ( 10 )     := 'DSP004';
--    
      
--                     prc_reinf_conf_retencao( 
--                                    p_cod_empresa   => p_cod_empresa
--                                   ,p_cod_estab     => p_cod_estab
--                                   ,p_tipo_selec    => '1'
--                                   ,p_data_inicial  => TO_DATE ('01/01/2019', 'DD/MM/YYYY')
--                                   ,p_data_final    => TO_DATE ('31/01/2019', 'DD/MM/YYYY')
--                                   ,p_cod_usuario   => 'leonardo.b.lima'
--                                   ,p_entrada_saida => 'E'
--                                   ,p_status        => l_status
--                                   ,p_proc_id       => 1);
--                     -- LOGA(L_STATUS);
                         
        
 
       for m in  cr_rtf  
       loop
              idx := idx + 1;
              t_fin4816_rtf ( idx )."Codigo da Empresa"            := m.cod_empresa ;
              t_fin4816_rtf ( idx )."Codigo do Estabelecimento"    := m.cod_estab;
              t_fin4816_rtf ( idx )."Periodo de Emissão"           := to_char(m.data_emissao,'mm/yyyy');
              t_fin4816_rtf ( idx )."CNPJ Drogaria"                := m.cgc;
              t_fin4816_rtf ( idx )."Numero da Nota Fiscal"        := m.num_docto;
              t_fin4816_rtf ( idx )."Tipo de Documento"            := m.tipo_docto;
              t_fin4816_rtf ( idx )."Data Emissão"                 := m.data_emissao;
              t_fin4816_rtf ( idx )."CNPJ Fonecedor"               := m.cgc_fornecedor;       
              t_fin4816_rtf ( idx ).uf                             := m.uf;                   
              t_fin4816_rtf ( idx )."Valor Total da Nota"          := m.valor_total;          
              t_fin4816_rtf ( idx )."Base de Calculo INSS"         := m.base_inss  ;
              t_fin4816_rtf ( idx )."Valor do INSS"                := m.valor_inss ;
              t_fin4816_rtf ( idx )."Codigo Pessoa Fisica/juridica":= m.cod_fis_jur;
              t_fin4816_rtf ( idx )."Razão Social"                 := m.razao_social;         
              t_fin4816_rtf ( idx )."Municipio Prestador"          := m.municipio_prestador;  
              t_fin4816_rtf ( idx )."Codigo de Serviço"            := m.cod_servico;          
              t_fin4816_rtf ( idx )."Codigo CEI"                   := m.cod_cei; 
              
              
              
              
              
              
              
             
              
               --   select * from msafi.tb_fin4816_rel_apoio_fiscal 
               --   select * from msafi.tb_fin4816_rel_apoio_fiscalv5
               
              
--               CREATE TABLE msafi.tb_fin4816_rel_apoio_fiscalV5 
--                AS SELECT * FROM msafi.tb_fin4816_rel_apoio_fiscal;
--                    
              
              
              
                  insert into msafi.tb_fin4816_rel_apoio_fiscalV5 
                   values t_fin4816_rtf ( idx );
                  commit;
           
                    
           
           
           
           
           
           
               
                    
--                    if  t_fin4816_rtf ( idx ).num_docfis = '081086' then
--                    
--                     dbms_output.put_line ( t_fin4816_rtf ( idx ).num_docfis);
--                     dbms_output.put_line ( '-- ok : = 081086');
--                      
--                       t_fin4816_rtf ( idx ).num_docfis :='0999999';
--                      dbms_output.put_line ( t_fin4816_rtf ( idx ).num_docfis);
--                      
--                    end if;
--                    
--                    
                    
                   
               
           
           
            
           
          


           
         
       
       
       end loop;
       idx := 0;
    
    EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line ( SQLERRM );
 END ;
   