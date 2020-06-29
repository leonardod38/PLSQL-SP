CREATE OR REPLACE PACKAGE BODY MSAF.dpsp_fin2662_par_relat_cproc IS

  TYPE a_estabs_t IS TABLE OF VARCHAR2(6);
  a_estabs a_estabs_t := a_estabs_t();

  mproc_id INTEGER;

  --Tipo, Nome e Descrição do Customizado
  mnm_tipo  VARCHAR2(100) := 'Obrigação Estadual';
  mnm_cproc VARCHAR2(100) := '4.Relatorio DUB-RJ';
  mds_cproc VARCHAR2(100) := 'Relatorio de Conferência DUB-RJ';

  i INTEGER := 1;

  FUNCTION parametros RETURN VARCHAR2 IS
  
    pstr VARCHAR2(5000);
  
  BEGIN
    mcod_empresa := lib_parametros.recuperar('EMPRESA');
    mcod_usuario := lib_parametros.recuperar('USUARIO');
  
    -- PPARAM:      STRING PASSADA POR REFERÊNCIA;
    -- PTITULO:     TÍTULO DO PARÂMETRO MOSTRADO NA JANELA;
    -- PTIPO:       VARCHAR2, DATE, INTEGER;
    -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
    -- PMANDATORIO: S OU N, INDICANDO SE A INFORMAÇÃO DO PARÂMETRO É OBRIGATÓRIA;
    -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
    -- PMASCARA:    MÁSCARA PARA DIGITAÇÃO (EX: DD/MM/YYYY, 999999 OU ######);
    -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
    -- PAPRESENTA:  S OU N, INDICANDO SE O PARÂMETRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;
  
    lib_proc.add_param(pparam      => pstr, --P_ANO
                       ptitulo     => 'Ano',
                       ptipo       => 'VARCHAR2',
                       pcontrole   => 'TEXTBOX',
                       pmandatorio => 'S',
                       pdefault    => NULL,
                       pmascara    => '####',
                       pvalores    => NULL);
  
    lib_proc.add_param(pparam      => pstr, --P_SEMESTRE
                       ptitulo     => 'Semestre',
                       ptipo       => 'VARCHAR2',
                       pcontrole   => 'RADIOBUTTON',
                       pmandatorio => 'S',
                       pdefault    => '1',
                       pmascara    => NULL,
                       pvalores    => '1=1ª Semestre,2=2ª Semestre');
  
    lib_proc.add_param(pstr,
                       '_____________________________________________________________________',
                       'VARCHAR2',
                       'TEXT');
  
    lib_proc.add_param(pparam      => pstr, --P_TIPO
                       ptitulo     => 'Tipo do Relatório',
                       ptipo       => 'VARCHAR2',
                       pcontrole   => 'RADIOBUTTON',
                       pmandatorio => 'S',
                       pdefault    => '3',
                       pmascara    => NULL,
                       pvalores    => '1=Analitico,2=Sintético,3=Todos');
  
    lib_proc.add_param(pstr,
                       'Filiais', --P_LOJAS
                       'VARCHAR2',
                       'MULTISELECT',
                       'S',
                       NULL,
                       NULL,
                       'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = ''' ||
                       mcod_empresa ||
                       ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO = ''RJ'' ORDER BY B.COD_ESTADO, A.COD_ESTAB');
  
    RETURN pstr;
  END;

  FUNCTION nome RETURN VARCHAR2 IS
  BEGIN
    RETURN mnm_cproc;
  END;

  FUNCTION tipo RETURN VARCHAR2 IS
  BEGIN
    RETURN mnm_tipo;
  END;

  FUNCTION versao RETURN VARCHAR2 IS
  BEGIN
    RETURN 'VERSAO 1.0';
  END;

  FUNCTION descricao RETURN VARCHAR2 IS
  BEGIN
    RETURN mds_cproc;
  END;

  FUNCTION modulo RETURN VARCHAR2 IS
  BEGIN
    RETURN 'PROCESSOS CUSTOMIZADOS';
  END;

  FUNCTION classificacao RETURN VARCHAR2 IS
  BEGIN
    RETURN 'PROCESSOS CUSTOMIZADOS';
  END;

  PROCEDURE loga(p_i_texto IN VARCHAR2, p_i_dttm IN BOOLEAN DEFAULT TRUE) IS
    vtexto VARCHAR2(1024);
  BEGIN
    IF p_i_dttm
    THEN
      vtexto := substr(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || ' - ' ||
                       p_i_texto,
                       1,
                       1024);
    ELSE
      vtexto := substr(p_i_texto, 1, 1024);
    END IF;
    lib_proc.add_log(vtexto, 1);
    COMMIT;
    ---
  END;

  FUNCTION moeda(v_conteudo NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(to_char(v_conteudo, '9g999g999g990d00'));
  END;

  PROCEDURE load_excel_analitico_lj(p_proc_instance IN VARCHAR2,
                                    p_ano           IN VARCHAR2,
                                    p_semestre      IN VARCHAR2) IS
  
    v_sql    VARCHAR2(20000);
    v_text01 VARCHAR2(20000);
    v_class  VARCHAR2(1) := 'a';
    c_conc   SYS_REFCURSOR;
    p_lojas  VARCHAR2(6);
  
    TYPE cur_tab_conc IS RECORD(
      cod_empresa      VARCHAR2(3),
      cod_estab        VARCHAR2(6),
      ie               CHAR(30),
      data_fiscal      DATE,
      mes_ano          CHAR(7),
      movto_e_s        CHAR(1),
      norm_dev         CHAR(1),
      cod_docto        VARCHAR2(5),
      cod_fis_jur      VARCHAR2(14),
      num_docfis       VARCHAR2(12),
      serie_docfis     VARCHAR2(3),
      num_autentic_nfe VARCHAR2(80),
      cod_produto      VARCHAR2(35),
      descricao        VARCHAR2(50),
      num_item         NUMBER(5),
      classificacao    VARCHAR2(50),
      cod_nbm          VARCHAR2(10),
      cod_natureza_op  VARCHAR2(3),
      cod_situacao_a   CHAR(1 BYTE),
      cod_situacao_b   VARCHAR2(2),
      cod_cfo          VARCHAR2(4),
      quantidade       NUMBER(17, 6),
      vlr_contab_item  NUMBER(17, 2),
      vlr_unit         NUMBER(19, 4),
      vlr_item         NUMBER(17, 2),
      base_icms        NUMBER(17, 2),
      base_isenta_icms NUMBER(17, 2),
      base_outras_icms NUMBER(17, 2),
      base_reduz_icms  NUMBER(17, 2),
      aliq_base_icms   NUMBER,
      --      
      ind_cesta_basica    INTEGER,
      cod_embasamento     VARCHAR2(200),
      cod_reg_calc        INTEGER,
      aliquota_interna_rj NUMBER,
      base_icms_dub       NUMBER,
      aliq_icms_dub       NUMBER,
      vlr_icms_dub        NUMBER);
  
    TYPE c_tab_conc IS TABLE OF cur_tab_conc;
    tab_e c_tab_conc;
  
  BEGIN
  
    loga('>>> Inicio Analitico - Lojas ' || p_proc_instance, FALSE);
  
    lib_proc.add_tipo(p_proc_instance,
                      i,
                      mcod_empresa || '_REL_ANALITICO_LOJA_DUB_RJ_' ||
                      p_ano || '.XLS',
                      2);
  
    COMMIT;
  
    lib_proc.add(dsp_planilha.header, ptipo => i);
    lib_proc.add(dsp_planilha.tabela_inicio, ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('LOJAS',
                                                                     p_custom => 'COLSPAN=31'),
                                    p_class    => 'h'),
                 ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('COD_EMPRESA') || --     
                                                  dsp_planilha.campo('COD_ESTAB') || --       
                                                  dsp_planilha.campo('INSCRICAO ESTADUAL') || --              
                                                  dsp_planilha.campo('DATA_FISCAL') || --     
                                                  dsp_planilha.campo('MES_ANO') || --         
                                                  dsp_planilha.campo('MOVTO_E_S') || --       
                                                  dsp_planilha.campo('NORM_DEV') || --        
                                                  dsp_planilha.campo('COD_DOCTO') || --       
                                                  dsp_planilha.campo('COD_FIS_JUR') || --     
                                                  dsp_planilha.campo('NUM_DOCFIS') || --      
                                                  dsp_planilha.campo('SERIE_DOCFIS') || --    
                                                  dsp_planilha.campo('NUM_AUTENTIC_NFE') || --
                                                  dsp_planilha.campo('COD_PRODUTO') || --     
                                                  dsp_planilha.campo('DESCRICAO') || --       
                                                  dsp_planilha.campo('NUM_ITEM') || --        
                                                  dsp_planilha.campo('CLASSIFICACAO') || --  
                                                  dsp_planilha.campo('COD_NBM') || --         
                                                  dsp_planilha.campo('COD_NATUREZA_OP') || -- 
                                                  dsp_planilha.campo('COD_SITUACAO_A') || --  
                                                  dsp_planilha.campo('COD_SITUACAO_B') || --  
                                                  dsp_planilha.campo('COD_CFO') || --         
                                                  dsp_planilha.campo('QUANTIDADE') || --      
                                                  dsp_planilha.campo('VLR_CONTAB_ITEM') || -- 
                                                  dsp_planilha.campo('VLR_UNIT') || --        
                                                  dsp_planilha.campo('VLR_ITEM') || --        
                                                  dsp_planilha.campo('BASE_ICMS') || --       
                                                  dsp_planilha.campo('BASE_ISENTA_ICMS') || --
                                                  dsp_planilha.campo('BASE_OUTRAS_ICMS') || --
                                                  dsp_planilha.campo('BASE_REDUZ_ICMS') || -- 
                                                 
                                                  dsp_planilha.campo('ALIQ_BASE_ICMS') || -- 
                                                  dsp_planilha.campo('IND_CESTA_BASICA') || -- 
                                                  dsp_planilha.campo('COD_EMBASAMENTO') || -- 
                                                  dsp_planilha.campo('COD_REG_CALC') || -- 
                                                  dsp_planilha.campo('ALIQUOTA_INTERNA_RJ') || -- 
                                                  dsp_planilha.campo('BASE_ICMS_DUB') || -- 
                                                  dsp_planilha.campo('ALIQ_ICMS_DUB') || -- 
                                                  dsp_planilha.campo('VLR_ICMS_DUB')
                                    --                                                        
                                   ,
                                    p_class => 'h'),
                 ptipo => i);
  
    FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
     LOOP
    
      p_lojas := a_estabs(est);
    
      v_sql := ' SELECT ';
      v_sql := v_sql || '  A.COD_EMPRESA        ';
      v_sql := v_sql || ' ,A.COD_ESTAB          ';
      v_sql := v_sql || ' ,A.IE                 ';
      v_sql := v_sql || ' ,A.DATA_FISCAL        ';
      v_sql := v_sql || ' ,A.MES_ANO            ';
      v_sql := v_sql || ' ,A.MOVTO_E_S          ';
      v_sql := v_sql || ' ,A.NORM_DEV           ';
      v_sql := v_sql || ' ,A.COD_DOCTO          ';
      v_sql := v_sql || ' ,A.COD_FIS_JUR        ';
      v_sql := v_sql || ' ,A.NUM_DOCFIS         ';
      v_sql := v_sql || ' ,A.SERIE_DOCFIS       ';
      v_sql := v_sql || ' ,A.NUM_AUTENTIC_NFE   ';
      v_sql := v_sql || ' ,A.COD_PRODUTO        ';
      v_sql := v_sql || ' ,A.DESCRICAO          ';
      v_sql := v_sql || ' ,A.NUM_ITEM           ';
      v_sql := v_sql || ' ,A.CLASSIFICACAO      ';
      v_sql := v_sql || ' ,A.COD_NBM            ';
      v_sql := v_sql || ' ,A.COD_NATUREZA_OP    ';
      v_sql := v_sql || ' ,A.COD_SITUACAO_A     ';
      v_sql := v_sql || ' ,A.COD_SITUACAO_B     ';
      v_sql := v_sql || ' ,A.COD_CFO            ';
      v_sql := v_sql || ' ,A.QUANTIDADE         ';
      v_sql := v_sql || ' ,A.VLR_CONTAB_ITEM    ';
      v_sql := v_sql || ' ,A.VLR_UNIT           ';
      v_sql := v_sql || ' ,A.VLR_ITEM           ';
      v_sql := v_sql || ' ,A.BASE_ICMS          ';
      v_sql := v_sql || ' ,A.BASE_ISENTA_ICMS   ';
      v_sql := v_sql || ' ,A.BASE_OUTRAS_ICMS   ';
      v_sql := v_sql || ' ,A.BASE_REDUZ_ICMS    ';
    
      v_sql := v_sql || ' ,A.ALIQ_BASE_ICMS               ';
      v_sql := v_sql || ' ,A.IND_CESTA_BASICA  ';
      v_sql := v_sql || ' ,A.COD_EMBASAMENTO  ';
      v_sql := v_sql || ' ,A.COD_REG_CALC           ';
      v_sql := v_sql || ' ,A.ALIQUOTA_INTERNA_RJ        ';
      v_sql := v_sql || ' ,A.BASE_ICMS_DUB        ';
      v_sql := v_sql || ' ,A.ALIQ_ICMS_DUB        ';
      v_sql := v_sql || ' ,A.VLR_ICMS_DUB        ';
      v_sql := v_sql || ' FROM MSAFI.DPSP_FIN2662_DUB  A ';
      v_sql := v_sql ||
               ' WHERE A.COD_ESTAB IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''RJ'' AND TIPO = ''L'') ';
--      --  06052020 - 07:37  ADJ 
--      v_sql := v_sql || ' AND EXISTS  ';
--      v_sql := v_sql || '  (  ';
--      v_sql := v_sql || ' SELECT 1  ';
--      v_sql := v_sql || '  FROM msafi.dpsp_fin4405_cest_arquivo b ';
--      v_sql := v_sql || ' WHERE b.cod_produto = a.cod_produto  ';
--      v_sql := v_sql || '  AND  TO_CHAR(data_fiscal, ''MM/YYYY'') =  periodo )' ;
--      -- 15/05/2020 - 12:16 ADJ
--      v_sql := v_sql || '  AND   NOT (cod_embasamento  like ''%128/94%''' ;
--      v_sql := v_sql || '  AND     classificacao = ''-1'' )';
               
      --
    
      IF p_semestre = '1'
      THEN
        v_sql := v_sql || '      AND a.DATA_FISCAL BETWEEN ''01/01/' ||
                 p_ano || ''' AND ''30/06/' || p_ano || '''   ';
      ELSE
        v_sql := v_sql || '      AND a.DATA_FISCAL BETWEEN ''01/07/' ||
                 p_ano || ''' AND ''31/12/' || p_ano || '''   ';
      END IF;
    
      v_sql := v_sql || ' AND a.COD_ESTAB = ''' || p_lojas || ''' ';
    
      --  V_SQL := V_SQL || ' ORDER BY A.COD_ESTAB ASC ';
    
      v_sql := v_sql ||
               ' ORDER BY  COD_EMPRESA, COD_ESTAB, DATA_FISCAL, NUM_DOCFIS, NUM_ITEM ASC ';
    
      BEGIN
        OPEN c_conc FOR v_sql;
      EXCEPTION
        WHEN OTHERS THEN
          loga('SQLERRM: ' || SQLERRM, FALSE);
          loga(substr(v_sql, 1, 1024), FALSE);
          loga(substr(v_sql, 1024, 1024), FALSE);
          loga(substr(v_sql, 2048, 1024), FALSE);
          loga(substr(v_sql, 3072), FALSE);
          raise_application_error(-20007, '!ERRO SELECT ANALITICO DUB!');
      END;
    
      LOOP
        FETCH c_conc BULK COLLECT
          INTO tab_e LIMIT 100;
      
        FOR ii IN 1 .. tab_e.COUNT LOOP
        
          IF v_class = 'a'
          THEN
            v_class := 'b';
          ELSE
            v_class := 'a';
          END IF;
        
    v_text01 := dsp_planilha.linha(p_conteudo => 
                 dsp_planilha.campo(tab_e(ii).cod_empresa)                    ||
                 dsp_planilha.campo(tab_e(ii).cod_estab)                      ||
                 dsp_planilha.campo(tab_e(ii).ie)                             ||
                 dsp_planilha.campo(tab_e(ii).data_fiscal)                    ||
                 dsp_planilha.campo(tab_e(ii).mes_ano)                        ||
                 dsp_planilha.campo(tab_e(ii).movto_e_s)                      ||
                 dsp_planilha.campo(tab_e(ii).norm_dev)                       ||
                 dsp_planilha.campo(tab_e(ii).cod_docto)                      ||
                 dsp_planilha.campo(tab_e(ii).cod_fis_jur)                    ||
                 dsp_planilha.campo(dsp_planilha.texto(tab_e(ii).num_docfis)) ||
                 dsp_planilha.campo(tab_e(ii).serie_docfis)                   ||
                 dsp_planilha.campo(dsp_planilha.texto(to_char(tab_e(ii).num_autentic_nfe)))||
                 dsp_planilha.campo(tab_e(ii).cod_produto)                    ||
                 dsp_planilha.campo(tab_e(ii).descricao)                      ||
                 dsp_planilha.campo(tab_e(ii).num_item)                       ||
                 dsp_planilha.campo(tab_e(ii).classificacao)                  ||
                 dsp_planilha.campo(tab_e(ii).cod_nbm)                        ||
                 dsp_planilha.campo(tab_e(ii).cod_natureza_op)                ||
                 dsp_planilha.campo(tab_e(ii).cod_situacao_a)                 ||
                 dsp_planilha.campo(dsp_planilha.texto(tab_e(ii).cod_situacao_b))||
                 dsp_planilha.campo(tab_e(ii).cod_cfo)                        ||
                 dsp_planilha.campo(tab_e(ii).quantidade)                     ||
                 dsp_planilha.campo(moeda(tab_e(ii).vlr_contab_item))         ||
                 dsp_planilha.campo(moeda(tab_e(ii).vlr_unit))                ||
                 dsp_planilha.campo(moeda(tab_e(ii).vlr_item))                ||
                 dsp_planilha.campo(moeda(tab_e(ii).base_icms))               ||
                 dsp_planilha.campo(moeda(tab_e(ii).base_isenta_icms))        ||
                 dsp_planilha.campo(moeda(tab_e(ii).base_outras_icms))        ||
                 dsp_planilha.campo(moeda(tab_e(ii).base_reduz_icms))         ||
                --  ALIQUOTA 
                 dsp_planilha.campo(moeda(tab_e(ii).aliq_base_icms))          ||
                 dsp_planilha.campo(tab_e(ii).ind_cesta_basica)               ||
                 dsp_planilha.campo(tab_e(ii).cod_embasamento)                ||
                 dsp_planilha.campo(tab_e(ii).cod_reg_calc)                   ||
                 dsp_planilha.campo(moeda(tab_e(ii).aliquota_interna_rj))     ||
                 dsp_planilha.campo(moeda(tab_e(ii).base_icms_dub))           ||
                 dsp_planilha.campo(moeda(tab_e(ii).aliq_icms_dub))           ||
                 dsp_planilha.campo(moeda(tab_e(ii).vlr_icms_dub))                                         
                                        ,
                                         p_class => v_class);
        
          msaf.lib_proc.add(v_text01, ptipo => i);
        
        END LOOP;
        tab_e.DELETE;
      
        EXIT WHEN c_conc%NOTFOUND;
      END LOOP;
    
      COMMIT;
      CLOSE c_conc;
    
    END LOOP;
  
    lib_proc.add(dsp_planilha.tabela_fim, ptipo => i);
  
  END load_excel_analitico_lj;

  --------------------------------------------------------------------------Relatório Analitico - INICIO------------------------------------------------------------------------

  PROCEDURE load_excel_analitico_cd(p_proc_instance IN VARCHAR2,
                                    p_ano           IN VARCHAR2,
                                    p_semestre      IN VARCHAR2) IS
  
    v_sql    VARCHAR2(20000);
    v_text01 VARCHAR2(20000);
    v_class  VARCHAR2(1) := 'a';
    c_conc   SYS_REFCURSOR;
    p_lojas  VARCHAR2(6);
  
    TYPE cur_tab_conc IS RECORD(
      
      cod_empresa      VARCHAR2(3),
      cod_estab        VARCHAR2(6),
      ie               CHAR(30),
      data_fiscal      DATE,
      mes_ano          CHAR(7),
      movto_e_s        CHAR(1),
      norm_dev         CHAR(1),
      cod_docto        VARCHAR2(5),
      cod_fis_jur      VARCHAR2(14),
      num_docfis       VARCHAR2(12),
      serie_docfis     VARCHAR2(3),
      num_autentic_nfe VARCHAR2(80),
      cod_produto      VARCHAR2(35),
      descricao        VARCHAR2(50),
      num_item         NUMBER(5),
      classificacao    VARCHAR2(50),
      cod_nbm          VARCHAR2(10),
      cod_natureza_op  VARCHAR2(3),
      cod_situacao_a   CHAR(1 BYTE),
      cod_situacao_b   VARCHAR2(2),
      cod_cfo          VARCHAR2(4),
      quantidade       NUMBER(17, 6),
      vlr_contab_item  NUMBER(17, 2),
      vlr_unit         NUMBER(19, 4),
      vlr_item         NUMBER(17, 2),
      base_icms        NUMBER(17, 2),
      base_isenta_icms NUMBER(17, 2),
      base_outras_icms NUMBER(17, 2),
      base_reduz_icms  NUMBER(17, 2),
      aliq_base_icms   NUMBER,
      --      
      ind_cesta_basica    INTEGER,
      cod_embasamento     VARCHAR2(200),
      cod_reg_calc        INTEGER,
      aliquota_interna_rj NUMBER,
      base_icms_dub       NUMBER,
      aliq_icms_dub       NUMBER,
      vlr_icms_dub        NUMBER
      
      );
  
    TYPE c_tab_conc IS TABLE OF cur_tab_conc;
    tab_e c_tab_conc;
  
  BEGIN
  
    loga('>>> Inicio Analitico - CDS ' || p_proc_instance, FALSE);
  
    lib_proc.add_tipo(p_proc_instance,
                      i,
                      mcod_empresa || '_REL_ANALITICO_CD_DUB_RJ_' || p_ano ||
                      '.XLS',
                      2);
  
    lib_proc.add(dsp_planilha.header, ptipo => i);
    lib_proc.add(dsp_planilha.tabela_inicio, ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('CDS',
                                                                     p_custom => 'COLSPAN=31'),
                                    p_class    => 'h'),
                 ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('COD_EMPRESA') || --     
                                                  dsp_planilha.campo('COD_ESTAB') || --       
                                                  dsp_planilha.campo('INSCRICAO ESTADUAL') || --              
                                                  dsp_planilha.campo('DATA_FISCAL') || --     
                                                  dsp_planilha.campo('MES_ANO') || --         
                                                  dsp_planilha.campo('MOVTO_E_S') || --       
                                                  dsp_planilha.campo('NORM_DEV') || --        
                                                  dsp_planilha.campo('COD_DOCTO') || --       
                                                  dsp_planilha.campo('COD_FIS_JUR') || --     
                                                  dsp_planilha.campo('NUM_DOCFIS') || --      
                                                  dsp_planilha.campo('SERIE_DOCFIS') || --    
                                                  dsp_planilha.campo('NUM_AUTENTIC_NFE') || --
                                                  dsp_planilha.campo('COD_PRODUTO') || --     
                                                  dsp_planilha.campo('DESCRICAO') || --       
                                                  dsp_planilha.campo('NUM_ITEM') || --        
                                                  dsp_planilha.campo('CLASSIFICACAO') || --  
                                                  dsp_planilha.campo('COD_NBM') || --         
                                                  dsp_planilha.campo('COD_NATUREZA_OP') || -- 
                                                  dsp_planilha.campo('COD_SITUACAO_A') || --  
                                                  dsp_planilha.campo('COD_SITUACAO_B') || --  
                                                  dsp_planilha.campo('COD_CFO') || --         
                                                  dsp_planilha.campo('QUANTIDADE') || --      
                                                  dsp_planilha.campo('VLR_CONTAB_ITEM') || -- 
                                                  dsp_planilha.campo('VLR_UNIT') || --        
                                                  dsp_planilha.campo('VLR_ITEM') || --        
                                                  dsp_planilha.campo('BASE_ICMS') || --       
                                                  dsp_planilha.campo('BASE_ISENTA_ICMS') || --
                                                  dsp_planilha.campo('BASE_OUTRAS_ICMS') || --
                                                  dsp_planilha.campo('BASE_REDUZ_ICMS') || -- 
                                                 
                                                  dsp_planilha.campo('ALIQ_BASE_ICMS') || -- 
                                                  dsp_planilha.campo('IND_CESTA_BASICA') || -- 
                                                  dsp_planilha.campo('COD_EMBASAMENTO') || -- 
                                                  dsp_planilha.campo('COD_REG_CALC') || -- 
                                                  dsp_planilha.campo('ALIQUOTA_INTERNA_RJ') || -- 
                                                  dsp_planilha.campo('BASE_ICMS_DUB') || -- 
                                                  dsp_planilha.campo('ALIQ_ICMS_DUB') || -- 
                                                  dsp_planilha.campo('VLR_ICMS_DUB')
                                    --                                                        
                                   ,
                                    p_class => 'h'),
                 ptipo => i);
  
    FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
     LOOP
    
      p_lojas := a_estabs(est);
    
      v_sql := ' SELECT ';
      v_sql := v_sql || '  A.COD_EMPRESA        ';
      v_sql := v_sql || ' ,A.COD_ESTAB          ';
      v_sql := v_sql || ' ,A.IE                 ';
      v_sql := v_sql || ' ,A.DATA_FISCAL        ';
      v_sql := v_sql || ' ,A.MES_ANO            ';
      v_sql := v_sql || ' ,A.MOVTO_E_S          ';
      v_sql := v_sql || ' ,A.NORM_DEV           ';
      v_sql := v_sql || ' ,A.COD_DOCTO          ';
      v_sql := v_sql || ' ,A.COD_FIS_JUR        ';
      v_sql := v_sql || ' ,A.NUM_DOCFIS         ';
      v_sql := v_sql || ' ,A.SERIE_DOCFIS       ';
      v_sql := v_sql || ' ,A.NUM_AUTENTIC_NFE   ';
      v_sql := v_sql || ' ,A.COD_PRODUTO        ';
      v_sql := v_sql || ' ,A.DESCRICAO          ';
      v_sql := v_sql || ' ,A.NUM_ITEM           ';
      v_sql := v_sql || ' ,A.CLASSIFICACAO      ';
      v_sql := v_sql || ' ,A.COD_NBM            ';
      v_sql := v_sql || ' ,A.COD_NATUREZA_OP    ';
      v_sql := v_sql || ' ,A.COD_SITUACAO_A     ';
      v_sql := v_sql || ' ,A.COD_SITUACAO_B     ';
      v_sql := v_sql || ' ,A.COD_CFO            ';
      v_sql := v_sql || ' ,A.QUANTIDADE         ';
      v_sql := v_sql || ' ,A.VLR_CONTAB_ITEM    ';
      v_sql := v_sql || ' ,A.VLR_UNIT           ';
      v_sql := v_sql || ' ,A.VLR_ITEM           ';
      v_sql := v_sql || ' ,A.BASE_ICMS          ';
      v_sql := v_sql || ' ,A.BASE_ISENTA_ICMS   ';
      v_sql := v_sql || ' ,A.BASE_OUTRAS_ICMS   ';
      v_sql := v_sql || ' ,A.BASE_REDUZ_ICMS    ';
      --
      v_sql := v_sql || ' ,A.ALIQ_BASE_ICMS               ';
      v_sql := v_sql || ' ,A.IND_CESTA_BASICA  ';
      v_sql := v_sql || ' ,A.COD_EMBASAMENTO  ';
      v_sql := v_sql || ' ,A.COD_REG_CALC           ';
      v_sql := v_sql || ' ,A.ALIQUOTA_INTERNA_RJ        ';
      v_sql := v_sql || ' ,A.BASE_ICMS_DUB        ';
      v_sql := v_sql || ' ,A.ALIQ_ICMS_DUB        ';
      v_sql := v_sql || ' ,A.VLR_ICMS_DUB        ';
      v_sql := v_sql || ' FROM MSAFI.DPSP_FIN2662_DUB  A ';
      v_sql := v_sql || ' WHERE A.COD_ESTAB IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''RJ'' AND TIPO = ''C'') ';
     --  06052020 - 07:37  ADJ 
--      v_sql := v_sql || ' AND EXISTS  ';
--      v_sql := v_sql || '  (  ';
--      v_sql := v_sql || ' SELECT 1  ';
--      v_sql := v_sql || '  FROM msafi.dpsp_fin4405_cest_arquivo b ';
--      v_sql := v_sql || ' WHERE b.cod_produto = a.cod_produto   ';
--      v_sql := v_sql || '  AND  TO_CHAR(data_fiscal, ''MM/YYYY'') =  periodo )' ;
      
--       -- 15/05/2020 - 12:16 ADJ
      v_sql := v_sql || '  AND   NOT (cod_embasamento  like ''%128/94%''' ;
      v_sql := v_sql || '  AND     classificacao = ''-1'' )';
      
    
      IF p_semestre = '1'
      THEN
        v_sql := v_sql || '      AND a.DATA_FISCAL BETWEEN ''01/01/' ||
                 p_ano || ''' AND ''30/06/' || p_ano || '''   ';
      ELSE
        v_sql := v_sql || '      AND a.DATA_FISCAL BETWEEN ''01/07/' ||
                 p_ano || ''' AND ''31/12/' || p_ano || '''   ';
      END IF;
    
      v_sql := v_sql || ' AND a.COD_ESTAB = ''' || p_lojas || ''' ';
    
      --V_SQL := V_SQL || ' ORDER BY A.COD_ESTAB       ASC ';
    
      v_sql := v_sql ||
               ' ORDER BY  COD_EMPRESA, COD_ESTAB, DATA_FISCAL, NUM_DOCFIS, NUM_ITEM     ASC ';
    
      BEGIN
        OPEN c_conc FOR v_sql;
      EXCEPTION
        WHEN OTHERS THEN
          loga('SQLERRM: ' || SQLERRM, FALSE);
          loga(substr(v_sql, 1, 1024), FALSE);
          loga(substr(v_sql, 1024, 1024), FALSE);
          loga(substr(v_sql, 2048, 1024), FALSE);
          loga(substr(v_sql, 3072), FALSE);
          raise_application_error(-20007, '!ERRO SELECT ANALITICO DUB!');
      END;
    
      LOOP
        FETCH c_conc BULK COLLECT
          INTO tab_e LIMIT 100;
      
        FOR ii IN 1 .. tab_e.COUNT LOOP
        
          IF v_class = 'a'
          THEN
            v_class := 'b';
          ELSE
            v_class := 'a';
          END IF;
        
          v_text01 := dsp_planilha.linha(p_conteudo => 
            dsp_planilha.campo(tab_e(ii).cod_empresa)                                   ||
            dsp_planilha.campo(tab_e(ii).cod_estab)                                     ||
            dsp_planilha.campo(dsp_planilha.texto(to_char(tab_e(ii).ie)))               ||
            dsp_planilha.campo(tab_e(ii).data_fiscal)                                   ||
            dsp_planilha.campo(tab_e(ii).mes_ano)                                       ||
            dsp_planilha.campo(tab_e(ii).movto_e_s)                                     ||
            dsp_planilha.campo(tab_e(ii).norm_dev)                                      ||
            dsp_planilha.campo(tab_e(ii).cod_docto)                                     ||
            dsp_planilha.campo(tab_e(ii).cod_fis_jur)                                   ||
            dsp_planilha.campo(dsp_planilha.texto(tab_e(ii).num_docfis))                ||
            dsp_planilha.campo(tab_e(ii).serie_docfis)                                  ||
            dsp_planilha.campo(dsp_planilha.texto(to_char(tab_e(ii).num_autentic_nfe))) ||
            dsp_planilha.campo(tab_e(ii).cod_produto)                                   ||
            dsp_planilha.campo(tab_e(ii).descricao)                                     ||
            dsp_planilha.campo(tab_e(ii).num_item)                                      ||
            dsp_planilha.campo(tab_e(ii).classificacao)                                 ||
            dsp_planilha.campo(tab_e(ii).cod_nbm)                                       ||
            dsp_planilha.campo(tab_e(ii).cod_natureza_op)                               ||
            dsp_planilha.campo(tab_e(ii).cod_situacao_a)                                ||
            dsp_planilha.campo(dsp_planilha.texto(tab_e(ii).cod_situacao_b))            ||
            dsp_planilha.campo(tab_e(ii).cod_cfo)                                       ||
            dsp_planilha.campo(tab_e(ii).quantidade)                                    ||
            dsp_planilha.campo(moeda(tab_e(ii).vlr_contab_item))                        ||
            dsp_planilha.campo(moeda(tab_e(ii).vlr_unit))                               ||
            dsp_planilha.campo(moeda(tab_e(ii).vlr_item))                               ||
            dsp_planilha.campo(moeda(tab_e(ii).base_icms))                              ||
            dsp_planilha.campo(moeda(tab_e(ii).base_isenta_icms))                       ||
            dsp_planilha.campo(moeda(tab_e(ii).base_outras_icms))                       ||
            dsp_planilha.campo(moeda(tab_e(ii).base_reduz_icms))                        ||
             --  ALIQUOTA 
            dsp_planilha.campo(moeda(tab_e(ii).aliq_base_icms))                         ||
            dsp_planilha.campo(tab_e(ii).ind_cesta_basica)                              ||
            dsp_planilha.campo(tab_e(ii).cod_embasamento)                               ||
            dsp_planilha.campo(tab_e(ii).cod_reg_calc)                                  ||
            dsp_planilha.campo(moeda(tab_e(ii).aliquota_interna_rj))                    ||
            dsp_planilha.campo(moeda(tab_e(ii).base_icms_dub))                          ||
            dsp_planilha.campo(moeda(tab_e(ii).aliq_icms_dub))                          ||
            dsp_planilha.campo(moeda(tab_e(ii).vlr_icms_dub)),
                                         p_class    => v_class);
          lib_proc.add(v_text01, ptipo => i);
        
        END LOOP;
        tab_e.DELETE;
      
        EXIT WHEN c_conc%NOTFOUND;
      END LOOP;
    
      COMMIT;
      CLOSE c_conc;
    
    END LOOP;
  
    lib_proc.add(dsp_planilha.tabela_fim, ptipo => i);
  
  END load_excel_analitico_cd;

  --------------------------------------------------------------------------Relatório Analitico - FIM  ------------------------------------------------------------------------

  --------------------------------------------------------------------------Relatório Analitico - FIM  ------------------------------------------------------------------------

  PROCEDURE load_excel_sintetico_lj(p_proc_instance IN VARCHAR2,
                                    p_ano           IN VARCHAR2,
                                    p_semestre      IN VARCHAR2) IS
  
    v_sql    VARCHAR2(20000);
    v_text01 VARCHAR2(20000);
    v_class  VARCHAR2(1) := 'a';
    c_conc   SYS_REFCURSOR;
    p_lojas  VARCHAR2(6);
  
    TYPE cur_tab_conc IS RECORD(
      
      cod_estab   VARCHAR2(6),
      ie          CHAR(30),
      periodo     VARCHAR2(15),
      embasamento CHAR(90),
      icms_dub    NUMBER(17, 2));
  
    TYPE c_tab_conc IS TABLE OF cur_tab_conc;
    tab_e c_tab_conc;
  
  BEGIN
  
    loga('>>> Inicio Sintético - Lojas ' || p_proc_instance, FALSE);
  
    lib_proc.add_tipo(p_proc_instance,
                      i,
                      mcod_empresa || '_REL_SINTETICO_LOJA_DUB_RJ_' ||
                      p_ano || '.XLS',
                      2);
  
    lib_proc.add(dsp_planilha.header, ptipo => i);
    lib_proc.add(dsp_planilha.tabela_inicio, ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('LOJAS - SINTÉTICO',
                                                                     p_custom => 'COLSPAN=5'),
                                    p_class    => 'h'),
                 ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('FILIAL') ||
                                                  dsp_planilha.campo('INSCRICAO ESTADUAL') ||
                                                  dsp_planilha.campo('PERIODO') ||
                                                  dsp_planilha.campo('EMBASAMENTO LEGAL') ||
                                                  dsp_planilha.campo('VALOR') --                                                        
                                   ,
                                    p_class    => 'h'),
                 ptipo => i);
  
    FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
     LOOP
    
      p_lojas := a_estabs(est);
    
      v_sql := ' SELECT ';
      v_sql := v_sql || ' COD_ESTAB  ,    ';
      v_sql := v_sql || ' IE ,  ';
      v_sql := v_sql || ' TO_CHAR(DATA_FISCAL,''Mon'')AS PERIODO,  ';
      v_sql := v_sql || ' COD_EMBASAMENTO EMBASAMENTO,  ';
      v_sql := v_sql || ' SUM(VLR_ICMS_DUB) ICMS_DUB ';
      v_sql := v_sql || ' FROM MSAFI.DPSP_FIN2662_DUB ';
      v_sql := v_sql ||
               ' WHERE COD_ESTAB IN (SELECT A.COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO A WHERE A.COD_ESTADO = ''RJ'' AND A.TIPO = ''L'') ';
               --  06052020 - 07:37  ADJ 
--      v_sql := v_sql || ' AND EXISTS  ';
--      v_sql := v_sql || '  (  ';
--      v_sql := v_sql || ' SELECT 1  ';
--      v_sql := v_sql || '  FROM msafi.dpsp_fin4405_cest_arquivo b ';
--      v_sql := v_sql || ' WHERE b.cod_produto = cod_produto ';
--      v_sql := v_sql || '  AND  TO_CHAR(data_fiscal, ''MM/YYYY'') =  periodo )' ;
--          -- 15/05/2020 - 12:16 ADJ
--      v_sql := v_sql || '  AND   NOT (COD_EMBASAMENTO  like ''%128/94%''' ;
--      v_sql := v_sql || '  AND     CLASSIFICACAO = ''-1'' )';
      
      
    
      v_sql := v_sql || ' AND COD_ESTAB = ''' || p_lojas || ''' ';
    
      IF p_semestre = '1'
      THEN
        v_sql := v_sql || '      AND DATA_FISCAL BETWEEN ''01/01/' || p_ano ||
                 ''' AND ''30/06/' || p_ano || '''   ';
      ELSE
        v_sql := v_sql || '      AND DATA_FISCAL BETWEEN ''01/07/' || p_ano ||
                 ''' AND ''31/12/' || p_ano || '''   ';
      END IF;
    
      v_sql := v_sql ||
               ' GROUP BY COD_ESTAB, IE, TO_CHAR(DATA_FISCAL,''Mon''), COD_EMBASAMENTO ';
    
      BEGIN
        OPEN c_conc FOR v_sql;
      EXCEPTION
        WHEN OTHERS THEN
          loga('SQLERRM: ' || SQLERRM, FALSE);
          loga(substr(v_sql, 1, 1024), FALSE);
          loga(substr(v_sql, 1024, 1024), FALSE);
          loga(substr(v_sql, 2048, 1024), FALSE);
          loga(substr(v_sql, 3072), FALSE);
          raise_application_error(-20007, '!ERRO SELECT DUB SINTETICO!');
      END;
    
      LOOP
        FETCH c_conc BULK COLLECT
          INTO tab_e LIMIT 100;
      
        FOR ii IN 1 .. tab_e.COUNT LOOP
        
          IF v_class = 'a'
          THEN
            v_class := 'b';
          ELSE
            v_class := 'a';
          END IF;
        
          v_text01 := dsp_planilha.linha(p_conteudo => dsp_planilha.campo(tab_e(ii).cod_estab)  ||
                                                       dsp_planilha.campo(dsp_planilha.texto(to_char(tab_e(ii).ie)))         ||
                                                       dsp_planilha.campo(tab_e(ii).periodo)    ||
                                                       dsp_planilha.campo(tab_e(ii).embasamento)||
                                                       dsp_planilha.campo(moeda(tab_e(ii).icms_dub)),
                                         p_class    => v_class);
          lib_proc.add(v_text01, ptipo => i);
        
        END LOOP;
        tab_e.DELETE;
      
        EXIT WHEN c_conc%NOTFOUND;
      END LOOP;
    
      COMMIT;
      CLOSE c_conc;
    
    END LOOP;
  
    lib_proc.add(dsp_planilha.tabela_fim, ptipo => i);
  
  END load_excel_sintetico_lj;

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------delete temporária--------------------------------------------------------------------------
  --       PROCEDURE DROP_OLD_TMP(MPROC_ID IN NUMBER) IS
  --    
  --        CURSOR C_OLD_TMP IS
  --            SELECT TABLE_NAME
  --            FROM MSAFI.DPSP_MSAF_TMP_CONTROL
  --            WHERE TRUNC((((86400*(SYSDATE-DTTM_CREATED))/60)/60)/24) >= 2;
  --            
  --        L_TABLE_NAME        VARCHAR2(30);
  --                
  --    BEGIN
  --        ---> Dropar tabelas TMP que tiveram processo interrompido a mais de 2 dias
  --        OPEN C_OLD_TMP;
  --        LOOP
  --            FETCH C_OLD_TMP INTO L_TABLE_NAME;
  --            
  --                BEGIN
  --                    EXECUTE IMMEDIATE 'DROP TABLE ' || L_TABLE_NAME;
  --                EXCEPTION
  --                    WHEN OTHERS THEN
  --                        NULL;
  --                END;    
  --              
  --                COMMIT;
  --            
  --            EXIT WHEN C_OLD_TMP%NOTFOUND;   
  --        END LOOP;
  --        COMMIT;
  --        CLOSE C_OLD_TMP;
  --        
  --    END;

  --     PROCEDURE DELETE_TEMP_TBL(MPROC_ID IN NUMBER) IS 
  --    BEGIN
  --    
  --      FOR TEMP_TABLE IN (
  --        SELECT TABLE_NAME
  --        FROM MSAFI.DPSP_MSAF_TMP_CONTROL
  --        WHERE PROC_ID = MPROC_ID)
  --      LOOP
  --        BEGIN
  --          EXECUTE IMMEDIATE 'DROP TABLE ' || TEMP_TABLE.TABLE_NAME;
  --          LOGA(TEMP_TABLE.TABLE_NAME || ' <', FALSE);
  --        EXCEPTION   
  --          WHEN OTHERS THEN
  --            LOGA(TEMP_TABLE.TABLE_NAME || ' <', FALSE);
  --          END;
  --      DELETE MSAFI.DPSP_MSAF_TMP_CONTROL WHERE PROC_ID = MPROC_ID AND TABLE_NAME = TEMP_TABLE.TABLE_NAME;
  --          COMMIT;
  --      END LOOP;
  --    --- checar TMPs de processos interrompidos e dropar
  --        DROP_OLD_TMP(MPROC_ID);
  --      END;

  --------------------------------------------------------------------------------------------- FIM ------------------------------------------------------------

  PROCEDURE load_excel_sintetico_cd(p_proc_instance IN VARCHAR2,
                                    p_ano           IN VARCHAR2,
                                    p_semestre      IN VARCHAR2) IS
  
    v_sql    VARCHAR2(20000);
    v_text01 VARCHAR2(20000);
    v_class  VARCHAR2(1) := 'a';
    c_conc   SYS_REFCURSOR;
    p_lojas  VARCHAR2(6);
  
    TYPE cur_tab_conc IS RECORD(
      
      cod_estab     VARCHAR2(6),
      embasamento   CHAR(90),
      periodo       VARCHAR2(15),
      cod_cfo       VARCHAR2(4),
      aliq          CHAR(6),
      base_icms_dub NUMBER(17, 2),
      icms_dub      NUMBER(17, 2));
  
    TYPE c_tab_conc IS TABLE OF cur_tab_conc;
    tab_e c_tab_conc;
  
  BEGIN
  
    loga('>>> Inicio Sintético - CDS ' || p_proc_instance, FALSE);
  
    lib_proc.add_tipo(p_proc_instance,
                      i,
                      mcod_empresa || '_REL_SINTETICO_CD_DUB_RJ_' || p_ano ||
                      '.XLS',
                      2);
  
    lib_proc.add(dsp_planilha.header, ptipo => i);
    lib_proc.add(dsp_planilha.tabela_inicio, ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('CDS SINTÉTICO',
                                                                     p_custom => 'COLSPAN=7'),
                                    p_class    => 'h'),
                 ptipo => i);
  
    lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('FILIAL') ||
                                                  dsp_planilha.campo('CONVENIO') ||
                                                  dsp_planilha.campo('PERIODO') ||
                                                  dsp_planilha.campo('COD_CFO') ||
                                                  dsp_planilha.campo('ALIQ') ||
                                                  dsp_planilha.campo('BASE_ICMS_DUB') ||
                                                  dsp_planilha.campo('ICMS_DUB') --                                                        
                                   ,
                                    p_class    => 'h'),
                 ptipo => i);
  
    FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
     LOOP
    
      p_lojas := a_estabs(est);
    
      v_sql := ' SELECT ';
      v_sql := v_sql || ' COD_ESTAB  ,    ';
      v_sql := v_sql || ' COD_EMBASAMENTO EMBASAMENTO,  ';
      v_sql := v_sql || ' TO_CHAR(DATA_FISCAL,''Mon'')AS PERIODO,  ';
      v_sql := v_sql || ' COD_CFO ,  ';
      v_sql := v_sql || ' ALIQ_ICMS_DUB ALIQ ,  ';
      v_sql := v_sql || ' SUM(BASE_ICMS_DUB) AS BASE_ICMS_DUB,  ';
      v_sql := v_sql || ' SUM(VLR_ICMS_DUB) AS ICMS_DUB';
      v_sql := v_sql || ' FROM MSAFI.DPSP_FIN2662_DUB ';
      v_sql := v_sql || ' WHERE COD_ESTAB IN (SELECT A.COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO A WHERE A.COD_ESTADO = ''RJ'' AND A.TIPO = ''C'')  ';
      --  06052020 - 07:37  ADJ 
--      v_sql := v_sql || ' AND EXISTS  ';
--      v_sql := v_sql || '  (  ';
--      v_sql := v_sql || ' SELECT 1  ';
--      v_sql := v_sql || '  FROM msafi.dpsp_fin4405_cest_arquivo b ';
--      v_sql := v_sql || ' WHERE b.cod_produto = cod_produto ';
--      v_sql := v_sql || '  AND  TO_CHAR(data_fiscal, ''MM/YYYY'') =  periodo )' ;
--       -- 15/05/2020 - 12:16 ADJ
--      v_sql := v_sql || '  AND   NOT (COD_EMBASAMENTO  like ''%128/94%''' ;
--      v_sql := v_sql || '  AND     CLASSIFICACAO = ''-1'' )';
      v_sql := v_sql || ' AND COD_ESTAB = ''' || p_lojas || ''' ';
    
      IF p_semestre = '1'
      THEN
        v_sql := v_sql || '      AND DATA_FISCAL BETWEEN ''01/01/' || p_ano ||
                 ''' AND ''30/06/' || p_ano || '''   ';
      ELSE
        v_sql := v_sql || '      AND DATA_FISCAL BETWEEN ''01/07/' || p_ano ||
                 ''' AND ''31/12/' || p_ano || '''   ';
      END IF;
    
      v_sql := v_sql ||
               ' GROUP BY COD_ESTAB,COD_EMBASAMENTO, TO_CHAR(DATA_FISCAL,''Mon''), COD_CFO , ALIQ_ICMS_DUB';
    
      BEGIN
        OPEN c_conc FOR v_sql;
      EXCEPTION
        WHEN OTHERS THEN
          loga('SQLERRM: ' || SQLERRM, FALSE);
          loga(substr(v_sql, 1, 1024), FALSE);
          loga(substr(v_sql, 1024, 1024), FALSE);
          loga(substr(v_sql, 2048, 1024), FALSE);
          loga(substr(v_sql, 3072), FALSE);
          raise_application_error(-20007, '!ERRO SELECT DUB SINTETICO!');
      END;
    
      LOOP
        FETCH c_conc BULK COLLECT
          INTO tab_e LIMIT 100;
      
        FOR ii IN 1 .. tab_e.COUNT LOOP
        
          IF v_class = 'a'
          THEN
            v_class := 'b';
          ELSE
            v_class := 'a';
          END IF;
        
          v_text01 := dsp_planilha.linha(p_conteudo => dsp_planilha.campo(tab_e(ii).cod_estab)              ||
                                                       dsp_planilha.campo(tab_e(ii).embasamento)            ||
                                                       dsp_planilha.campo(tab_e(ii).periodo)                ||
                                                       dsp_planilha.campo(tab_e(ii).cod_cfo)                ||
                                                       dsp_planilha.campo(tab_e(ii).aliq)                   ||
                                                       dsp_planilha.campo(moeda(tab_e(ii).base_icms_dub))   ||
                                                       dsp_planilha.campo(moeda(tab_e(ii).icms_dub)), p_class    => v_class);
          lib_proc.add(v_text01, ptipo => i);
        
        END LOOP;
        tab_e.DELETE;
      
        EXIT WHEN c_conc%NOTFOUND;
      END LOOP;
    
      COMMIT;
      CLOSE c_conc;
    END LOOP;
  
    lib_proc.add(dsp_planilha.tabela_fim, ptipo => i);
  
  END load_excel_sintetico_cd;
  
  
  
  
  
  procedure  prc_regra_dub_icms ( pyear      VARCHAR2
                                ,  psemestre VARCHAR2
                                ,  pcodestab VARCHAR2
                                ,  pempresa  VARCHAR2
                                )
  is 
  
  --DECLARE
    v_cur_recs_counter NUMBER   := 0;
    v_sql_rowcount NUMBER       := 0;
    v_bulk_limit NUMBER         := 1000;

    CURSOR c_rec  (pcod_empresa  varchar2 , pcod_estab varchar2, pdta_inicial  date, pdta_final date) 
    IS
        SELECT a.ROWID rowid_dub
             , a.cod_empresa
             , a.cod_estab
             , a.cod_embasamento
             , aliquota_interna_rj aliquota_interna_rj_old
             , 20 AS aliquota_interna_rj
             , a.base_icms_dub
             , ((a.base_icms_dub * 20) / 100) AS vlr_icms_dub_new
          FROM msafi.dpsp_fin2662_dub a
         WHERE 1 = 1
           AND a.cod_estab      = pcod_estab
           AND a.cod_empresa    = pcod_empresa
           AND a.data_fiscal between   pdta_inicial  and pdta_final
          --- AND a.num_docfis IN ( '002069036', '002069209', '002069157')
           AND EXISTS
                   (SELECT 1
                      FROM msafi.dpsp_fin4405_cest_arquivo b
                     WHERE b.cod_produto = cod_produto
                       AND TO_CHAR ( data_fiscal
                                   , 'MM/YYYY' ) = periodo)
             AND  a.cod_embasamento  like '%ISENÇÃO%'   ;
                                   
--           AND SUBSTR ( cod_embasamento
--                      , 1
--                      , 2 ) IN ( 8   -- CONVÊNIO 88 / 91 - ISENÇÃO (VASILHAME OU SACARIA)
--                               , 4   -- CONVÊNIO 10/2002 - ISENÇÃO - COQUETEL P/ HIV
--                               , 3   -- CONVÊNIO 126/10 - ISENÇÃO - ORTOPÉDICOS
--                               , 2   -- CONVÊNIO 162/94 - ISENÇÃO - ONCOLÓGICOS
--                               , 1   -- CONVÊNIO 116/98 - ISENÇÃO - PRESERVATIVOS 
--                               );

    TYPE tb_rec IS TABLE OF c_rec%ROWTYPE;

    v_tb_rec tb_rec;
   
l_data_inicial DATE ;
l_data_final   DATE;



BEGIN


            IF  psemestre  = '1'  THEN 
              l_data_inicial  := '0101'||pyear;
              l_data_final    := '3006'||pyear;
              
              else 
              l_data_inicial  := '0107'||pyear;
              l_data_final    := '3112'||pyear;
           
            END IF;


            OPEN c_rec   (
                      pcod_empresa => pempresa 
                    , pcod_estab   => pcodestab 
                    , pdta_inicial => l_data_inicial
                    , pdta_final   => l_data_final)  ;

    LOOP
        FETCH c_rec 
            BULK COLLECT INTO v_tb_rec
            LIMIT v_bulk_limit;

        FORALL i IN 1 .. v_tb_rec.COUNT
            UPDATE msafi.dpsp_fin2662_dub b
               SET b.aliquota_interna_rj    = 20
                 , b.vlr_icms_dub           = v_tb_rec ( i ).vlr_icms_dub_new
             WHERE b.ROWID                  = v_tb_rec ( i ).rowid_dub;

        v_sql_rowcount := v_sql_rowcount + SQL%ROWCOUNT;
        v_cur_recs_counter := v_cur_recs_counter + v_tb_rec.COUNT;
        COMMIT;
        EXIT WHEN c_rec%NOTFOUND;
    END LOOP;

    CLOSE c_rec;

    dbms_output.put_line ( 'Total loop count: ' || v_cur_recs_counter );
    dbms_output.put_line ( 'Actual rows updated: ' || v_sql_rowcount );
--END;

  end prc_regra_dub_icms;
  
  
  

  FUNCTION executar(p_ano      VARCHAR2,
                    p_semestre VARCHAR2,
                    p_tipo     VARCHAR2,
                    p_lojas    lib_proc.vartab) RETURN INTEGER IS
  
    i1 INTEGER;
  
    --Variaveis genericas
    vp_proc_instance VARCHAR2(30);
    v_gera_loja integer := 0;
    v_gera_cd integer := 0;
    
  
  BEGIN
  
    --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo
    --diretamente na tela do Mastersaf
  
    lib_parametros.salvar('EMPRESA',
                          nvl(mcod_empresa, msafi.dpsp.v_empresa));
  
    mcod_empresa := lib_parametros.recuperar('EMPRESA');
    mcod_usuario := lib_parametros.recuperar('USUARIO');
  
    IF mcod_usuario IS NULL
    THEN
      lib_parametros.salvar('USUARIO', 'AUTOMATICO');
      mcod_usuario := lib_parametros.recuperar('USUARIO');
    END IF;
  
    mproc_id := lib_proc.NEW($$PLSQL_UNIT, 48, 150);
  
    i := 1;
  
    -- LIB_PROC.ADD_TIPO(MPROC_ID,i, TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '_DUB_RJ',1);
    -- commit;
  
    --PREPARAR LOJAS
  
    IF (p_lojas.COUNT > 0)
    THEN
      --   i := i + 1;
    
      i1 := p_lojas.FIRST;
      WHILE i1 IS NOT NULL LOOP
        a_estabs.EXTEND();
        a_estabs(a_estabs.LAST) := p_lojas(i1);
        i1 := p_lojas.NEXT(i1);
        
      END LOOP;
    
    ELSE
      --i := i + 1;
    
      FOR c1 IN (SELECT cod_estab
                   FROM msafi.dsp_estabelecimento
                  WHERE cod_empresa = mcod_empresa
                    --AND tipo = 'L'
                    AND COD_ESTADO = 'RJ'
                    ) LOOP
        a_estabs.EXTEND();
        a_estabs(a_estabs.LAST) := c1.cod_estab;
      END LOOP;
    END IF;
  
    --MARCAR INCIO DA EXECUCAO
  
    loga('<<' || mnm_cproc || '>>', FALSE);
    loga('---INICIO DO PROCESSAMENTO---', FALSE);

     FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
     LOOP
  
      SELECT greatest(decode(tipo, 'L', 1, 0), v_gera_loja),
             greatest(decode(tipo, 'C', 1, 0), v_gera_cd)
                  into v_gera_loja, v_gera_cd
                   FROM msafi.dsp_estabelecimento
                  WHERE cod_empresa = mcod_empresa
                   and cod_estab =  a_estabs(est);
          

                prc_regra_dub_icms ( pyear => p_ano   ,psemestre => p_semestre  ,pcodestab => a_estabs(est) ,pempresa  => 'DP' );
                   
  
     end loop;
  
    IF p_tipo <> '2'
    THEN
    
      i := 2;
      if v_gera_loja = 1 then 
      load_excel_analitico_lj(mproc_id, p_ano, p_semestre);
      end if;
    
      i := 3;
      if v_gera_cd = 1 then 
      load_excel_analitico_cd(mproc_id, p_ano, p_semestre);
      end if;
      
    END IF;
    --
    IF p_tipo <> '1'
    THEN
      i := 4;
      if v_gera_loja = 1 then 
      load_excel_sintetico_lj(mproc_id, p_ano, p_semestre);
      end if;
      i := 5;
      if v_gera_cd = 1 then 
      load_excel_sintetico_cd(mproc_id, p_ano, p_semestre);
      end if;
    END IF;
  
    dbms_application_info.set_module($$PLSQL_UNIT, 'PROC_ID: ' || mproc_id);
  
    --GERAR CHAVE PROC_ID
    SELECT round(dbms_random.VALUE(10000000000000, 999999999999999))
      INTO vp_proc_instance
      FROM dual;
  
    --Limpa tabela temporária
    --  DELETE_TEMP_TBL(MPROC_ID);
  
    loga(' ');
    loga('FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]');
  
    loga('---FIM DO PROCESSAMENTO---', FALSE);
  
    --  delete tmp
  
    lib_proc.CLOSE();
    COMMIT;
  
    RETURN mproc_id;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      loga('SQLERRM: ' || SQLERRM, FALSE);
      loga('ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace);
      loga('SQLERRM: ' || SQLERRM);
      loga('ERRO!');
      loga(' ');
      loga(dbms_utility.format_error_backtrace);
    
      msaf.lib_proc.CLOSE;
      COMMIT;
    
      UPDATE lib_processo SET situacao = 'ERRO' WHERE proc_id = mproc_id;
    
      RETURN mproc_id;
    
  END;

END dpsp_fin2662_par_relat_cproc;
/