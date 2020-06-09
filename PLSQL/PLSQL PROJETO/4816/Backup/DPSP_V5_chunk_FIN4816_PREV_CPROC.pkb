CREATE OR REPLACE PACKAGE BODY MSAF.DPSP_V5_FIN4816_PREV_CPROC
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Relatorio Previdenciario';
    mnm_cproc VARCHAR2 ( 100 ) := '5.Relatorio de apoio';
    mds_cproc VARCHAR2 ( 100 ) := 'Validacao das Inf. Reinf (V5)';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    i NUMBER := 0;


    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial Emissão:'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );


        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final Emissão:'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );

        -- PCOD_ESTAB
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , --PCOD_ESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           ,    ' SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) '
                             || ' FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C '
                             || ' WHERE 1=1 '
                             || --
                               ' AND A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''''
                             || ' AND B.IDENT_ESTADO = A.IDENT_ESTADO '
                             || ' AND A.COD_EMPRESA  = C.COD_EMPRESA '
                             || ' AND A.COD_ESTAB    = C.COD_ESTAB '
                             || -- ' AND C.TIPO         = ''L'' ' ||
                               ' ORDER BY A.COD_ESTAB  '
        );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
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

        lib_proc.add_log ( vtexto
                         , 1 );
        COMMIT;
    END loga;



 
    


--    PROCEDURE carga ( pnr_particao INTEGER
--                    , pnr_particao2 INTEGER
--                    , p_data_ini DATE
--                    , p_data_fim DATE
--                    , p_proc_id VARCHAR2
--                    , p_nm_empresa VARCHAR2
--                    , p_nm_usuario VARCHAR2 )
--    IS
--        v_data DATE;
--
--        -- Constantes declaration
--        cc_procedurename CONSTANT VARCHAR2 ( 30 ) := 'INSERT (FIN4816) ... ';
--
--        cc_limit NUMBER ( 7 ) := 10000;
--        vn_count_new NUMBER := 0;
--
--        l_status NUMBER;
--        
--       
--  
--               
--    
--    BEGIN
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE' ;
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ' ;
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
--
--                             -- Registra o andamento do processo na v$session
--                              dbms_application_info.set_module ( cc_procedurename, 'n:' || vn_count_new );
--                              v_data := p_data_ini - 1 + pnr_particao;
--                              dbms_application_info.set_module ( cc_procedurename || '  ' || v_data, 'n:' || vn_count_new );
--                          
--                          
--                          
--                          
--
--                             --================================================
--                             -- Table -  report fiscal
--                             --================================================
--                             OPEN cr_rtf ( v_data , p_nm_empresa, p_proc_id );
--                                LOOP
--                                dbms_application_info.set_module ( cc_procedurename, 'Executando o fetch report fiscal ...' );
--                                FETCH cr_rtf BULK COLLECT INTO l_data_fiscal LIMIT cc_limit;                                 
--                                FORALL i IN 1..l_data_fiscal.COUNT
--                                INSERT INTO msafi.tb_fin4816_report_fiscal_gtt VALUES l_data_fiscal(i);
--                                EXIT WHEN cr_rtf%NOTFOUND;
--                                END LOOP;                           
--                             CLOSE cr_rtf;
--                          
--                             
--
--                              
--                             --================================================
--                             --  INSERT Table -  Report Retenção
--                             --  Validações das Retenções Previdenciarias
--                             --================================================  
--                             OPEN rc_prev ( v_data , p_nm_empresa, p_proc_id );
--                                LOOP
--                                dbms_application_info.set_module ( cc_procedurename, 'Executando o fetch report Retenções Previdenciarias ...' );
--                                FETCH rc_prev BULK COLLECT INTO l_data_reinf LIMIT cc_limit;                                 
--                                FORALL i IN 1..l_data_reinf.COUNT
--                                INSERT INTO msafi.tb_fin4816_reinf_prev_gtt VALUES l_data_reinf(i);
--                                EXIT WHEN rc_prev%NOTFOUND;
--                                END LOOP;                           
--                             CLOSE rc_prev;
--                             
--                           
--                             
--                             --================================================
--                             --  INSERT Table -  Report EFD-REINF
--                             --  Conferência dos Eventos R-2010
--                             --================================================  
--                              OPEN rc_2010 ( v_data , p_nm_empresa, p_proc_id );
--                                LOOP
--                                dbms_application_info.set_module ( cc_procedurename, 'Executando o fetch report R-2010 ...' );
--                                FETCH rc_2010 BULK COLLECT INTO l_data_r2010 LIMIT cc_limit;                                 
--                                FORALL i IN 1..l_data_r2010.COUNT
--                                INSERT INTO msafi.tb_fin4816_reinf_2010_gtt VALUES l_data_r2010(i);
--                                EXIT WHEN rc_2010%NOTFOUND;
--                                END LOOP;                           
--                             CLOSE rc_2010;
--                             
--                             
--                            
--                             
--                            
--                 
--    END carga;



    PROCEDURE prc_output_excel ( vp_mproc_id IN NUMBER
                         , v_data_inicial IN DATE
                         , v_data_final IN DATE )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;
        v_data_inicial_p VARCHAR2 ( 30 );
    BEGIN
    
        v_data_inicial_p :=  TO_CHAR ( v_data_inicial , 'MM-YYYY' );

        loga ( v_data_inicial_p );




        lib_proc.add_tipo ( vp_mproc_id, 99, mcod_empresa || '_REL_PREVIDENCIARIO_' || v_data_inicial_p || '_' || '.XLS', 2 );
        lib_proc.add ( dsp_planilha.header, ptipo => 99 );
        lib_proc.add ( dsp_planilha.tabela_inicio , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>   dsp_planilha.campo ( 'Relatório Fiscal'         , p_custom => 'COLSPAN=19' )             || --  18
                                                            dsp_planilha.campo (  'Relatório Previdenciario', p_custom => 'COLSPAN=20 BGCOLOR=BLUE') || --  20
                                                            dsp_planilha.campo (  'Relatório Evento R-2010' , p_custom => 'COLSPAN=21 BGCOLOR=GREEN')   --  21
                                                            , p_class => 'h' ) , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>   dsp_planilha.campo ( 'Codigo da Empresa' )              || -- 1
                                                            dsp_planilha.campo ( 'Codigo do Estabelecimento' )      || -- 2
                                                            dsp_planilha.campo  ( 'Periodo de Emissão' )            || -- 3
                                                            dsp_planilha.campo ( 'CNPJ Drogaria' )                  || -- 4
                                                            dsp_planilha.campo ( 'Numero da Nota Fiscal' )          || -- 5
                                                            dsp_planilha.campo ( 'Tipo de Documento' )              || -- 6
                                                            dsp_planilha.campo ( 'Doc. Contábil' )                  || -- 6.1  adj- add  03/06/2020
                                                            dsp_planilha.campo ( 'Data Emissão' )                   || -- 7
                                                            dsp_planilha.campo ( 'CNPJ_Fonecedor' )                 || -- 8
                                                            dsp_planilha.campo ( 'UF' )                             || -- 9
                                                            dsp_planilha.campo ( 'Valor Total da Nota' )            || -- 10
                                                            dsp_planilha.campo ( 'Base de Calculo INSS' )           || -- 11
                                                            dsp_planilha.campo ( 'Valor do INSS' )                  || -- 12
                                                            dsp_planilha.campo ( 'Codigo Pessoa Fisica/juridica' )  || -- 13
                                                            dsp_planilha.campo ( 'Razão Social' )                   || -- 14
                                                            dsp_planilha.campo ( 'Municipio Prestador' )            || -- 15
                                                            dsp_planilha.campo ( 'Codigo de Serviço' )              || -- 16
                                                            dsp_planilha.campo ( 'Codigo CEI' )                     || -- 17
                                                            dsp_planilha.campo ( 'Equalização|S-N' )                || -- 18
                                                           -------------------------
                                                           --  Previdenciario
                                                           -------------------------
                                                            dsp_planilha.campo ( 'Cod. da Empresa' )                || --19
                                                            dsp_planilha.campo ( 'Cod. do Estabelecimento' )        || --21
                                                            dsp_planilha.campo ( 'Cod. Pessoa Fisica/Juridica')     || --22
                                                            dsp_planilha.campo ( 'Razão Social Cliente    ' )       || --23
                                                            dsp_planilha.campo ( 'CNPJ Cliente(s)' )                || --24
                                                            dsp_planilha.campo ( 'Nr. da Nota Fiscal' )             || --25
                                                            dsp_planilha.campo ( 'Data Emissão.' )                  || --26
                                                            dsp_planilha.campo ( 'Data Fiscal.' )                   || --26 *
                                                            dsp_planilha.campo ( 'Vlr. Total da Nota' )             || --27
                                                            dsp_planilha.campo ( 'Vlr Base de Calculo INSS' )       || --28
                                                            dsp_planilha.campo ( 'Vlr. Aliquota INSS' )             || --29
                                                            dsp_planilha.campo ( 'Vlr INSS Retido' )                || --30
                                                            dsp_planilha.campo ( 'Razão Social Drogaria' )          || --31
                                                            dsp_planilha.campo ( 'CNPJ-s Drogaria' )                || --32
                                                            dsp_planilha.campo ( 'Descrição do Tipo de Documento' ) || --33
                                                            dsp_planilha.campo ( 'Cod. Tipo de Serviço E-social' )  || --34
                                                            dsp_planilha.campo ( 'Descr. Tipo de Serviço E-social' )|| --35
                                                            dsp_planilha.campo ( 'Vlr. do Serviço' )                || --36
                                                            dsp_planilha.campo ( 'Cod. de Serviço Mastersaf' )      || --37
                                                            dsp_planilha.campo ( 'Descr. Codigo de Serv. Mastersaf')|| --38
                                                             -----------------------
                                                             --Eventos Reinf R2010
                                                             -----------------------           
                                                            dsp_planilha.campo ( 'Codigo Empresa.' )                || --39
                                                            dsp_planilha.campo ( 'Razão Social Drogaria.' )         || --40
                                                            dsp_planilha.campo ( 'Razão Social Cliente.' )          || --41
                                                            dsp_planilha.campo ( 'Número da Nota Fiscal.' )         || --42
                                                            dsp_planilha.campo ( 'Data de Emissão da NF.' )         || --43
                                                            dsp_planilha.campo ( 'Data Fiscal.' )                   || --44
                                                            dsp_planilha.campo ( 'Valor do Tributo.' )              || --45
                                                            dsp_planilha.campo ( 'Observação.' )                    || --46
                                                            dsp_planilha.campo ( 'Tipo de Serviço E-social.' )      || --47
                                                            dsp_planilha.campo ( 'Vlr. Base de Calculo Retenção.' ) || --48
                                                            dsp_planilha.campo ( 'Vlr. da Retenção.' )                 --49
                                          , p_class => 'h'
                       )
                     , ptipo => 99 );

                

            FOR i IN  msaf.pkg_fin4816_cursor.cr_rel_apoio_fiscal(pcod_empresa  => mcod_empresa,  pdata_ini => v_data_inicial , pdata_fim => v_data_final , pproc_id => vp_mproc_id  )
            
            
            LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;
          
            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>   dsp_planilha.campo ( i."Codigo da Empresa" )                                   || -- 1
                                                     dsp_planilha.campo ( i."Codigo do Estabelecimento" )                           || -- 2
                                                     dsp_planilha.campo ( i."Periodo de Emissão" )                                  || -- 3
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."CNPJ Drogaria" ) )                || -- 4
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Numero da Nota Fiscal") )         || -- 5
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Tipo de Documento" ) )            || -- 6
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Doc. Contábil"))                  || -- 6.1  adj-add 03/06/2020 
                                                     dsp_planilha.campo ( i."Data Emissão" )                                        || -- 7
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."CNPJ Fonecedor" ) )               || -- 8
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."UF" ) )                           || -- 9
                                                     dsp_planilha.campo ( i."Valor Total da Nota" )                                 || -- 10
                                                     dsp_planilha.campo ( i."Base de Calculo INSS" )                                || -- 11
                                                     dsp_planilha.campo ( i."Valor do INSS" )                                       || -- 12
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Codigo Pessoa Fisica/juridica"))    || -- 13
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."Razão Social" ) )                  || -- 14
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."Municipio Prestador"))             || -- 15
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."Codigo de Serviço"))               || -- 16
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."Codigo CEI"))                      || -- 17
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."DWT" ) )                           || -- 18
                                                      ---  Relatório Previdenciario
                                                     dsp_planilha.campo( i.empresa )                                                || -- 19
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Codigo Estabelecimento") )          || -- 20
                                                     dsp_planilha.campo (dsp_planilha.texto (i.cod_pessoa_fis_jur ))                || -- 21
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Razão Social Cliente"))             || -- 22
                                                     dsp_planilha.campo (dsp_planilha.texto (i."CNPJ Cliente" ) )                   || -- 23
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Nro. Nota Fiscal" ))                || -- 24
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Dt. Emissao" ) )                    || -- 25
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Dt. Fiscal" ) )                     || -- 26
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Vlr. Total da Nota") )              || -- 27
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Vlr Base Calc. Retenção"))          || -- 28
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Vlr. Aliquota INSS"))               || -- 29
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Vlr.Trib INSS RETIDO"))             || -- 30
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Razão Social Drogaria"))            || -- 31
                                                     dsp_planilha.campo (dsp_planilha.texto (i."CNPJ Drogarias" ) )                 || -- 32
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Descr. Tp. Documento"))             || -- 33
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Tp.Serv. E-social" ))               || -- 34
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Descr. Tp. Serv E-social"))         || -- 35
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Vlr. do Servico" ) )                || -- 36
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Cod. Serv. Mastersaf"))             || -- 37
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Descr. Serv. Mastersaf"))           || -- 38
                                                      -- reinf r2010
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Codigo Empresa" ) )                 || -- 39
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Razão Social Drogaria."))           || -- 40
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Razão Social Cliente."))            || -- 41
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Número da Nota Fiscal."))           || -- 42
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Data de Emissão da NF."))           || -- 43
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."Data Fiscal." ) )                  || -- 44
                                                     dsp_planilha.campo (dsp_planilha.texto ( i."Valor do Tributo." ))              || -- 45
                                                     dsp_planilha.campo (dsp_planilha.texto( i."Observação." ) )                    || -- 46
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Tipo de Serviço E-social." ))       || -- 47
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Vlr. Base de Calc. Retenção."))     || -- 48
                                                     dsp_planilha.campo (dsp_planilha.texto (i."Valor da Retenção."))                  -- 49
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => 99 );
        END LOOP;

        COMMIT;


        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 99 );
    END prc_output_excel;
    
    
    
    --           carga( pnr_particao  INTEGER,
--                  pnr_particao2 INTEGER,
--                  p_data_ini    DATE,      -- ok 
--                  p_data_fim    DATE,      -- ok 
--                  p_proc_id     VARCHAR2,   --ok 
--                  p_nm_empresa  VARCHAR2,  -- ok 
--                  p_nm_usuario  VARCHAR2);  -- ok 
    


   procedure   carga_test ( 
                  pnr_particao  INTEGER
                , pnr_particao2 INTEGER
                , pdata_inicial DATE
                , pdata_final   DATE
                , pprocid       VARCHAR2
                , pcod_empresa  VARCHAR2
                , p_nm_usuario  VARCHAR2 ) 
   is 
--    p_data_inicial DATE             := '01/12/2018';  -- data  inicial emissao '01/07/2018'   AND  '30/07/2018'  DSP062
--    p_data_final DATE               := '31/12/2018';  -- data  final  emissao
--    p_cod_empresa VARCHAR2 ( 10 )   := 'DSP';
--    p_cod_estab VARCHAR2 ( 10 )     := 'DSP062';
--    pproc_id  number                := 290380;
    
    idx NUMBER ( 10 )               := 0;
    v_sql VARCHAR2 ( 32767 );
    l_status  varchar2(10);
   
   begin    
             EXECUTE IMMEDIATE  'ALTER SESSION SET nls_date_format = ''DD/MM/YYYY HH24:MI:SS''';

   
            for j in   pkg_fin4816_cursor.rc_reinf_evento_e2010 (pcod_empresa  =>pcod_empresa ,   pdata_ini => pdata_inicial , pdata_fim => pdata_final , pproc_id => pprocid)   
             loop
             idx := idx + 1;             
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo Empresa"               := j."Codigo Empresa"               ;             
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Razão Social Drogaria."       := j."Razão Social Drogaria"        ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Razão Social Cliente."        := j."Razão Social Cliente"         ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Número da Nota Fiscal."       := j."Número da Nota Fiscal"        ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Data de Emissão da NF."       := j."Data de Emissão da NF"        ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Data Fiscal."                 := j."Data Fiscal"                  ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Valor do Tributo."            := j."Valor do Tributo"             ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Observação."                  := j."observacao"                   ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Tipo de Serviço E-social."    := j."Tipo de Serviço E-social"     ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Vlr. Base de Calc. Retenção." := j."Vlr. Base de Calc. Retenção"  ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Valor da Retenção."           := j."Valor da Retenção"            ;                                                                                                                       
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_reinf_e2010                 := idx;
             pkg_fin4816_type.t_fin4816_rtf ( idx ).nm_user                        := mnm_usuario;
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_procid                      := pprocid;         
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Data da Execução"             := to_date (sysdate,'DD/MM/YYYY HH24:MI:SS'); 
             
             
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete;      
             end loop;            
             idx := 0;
        
   

             for  m  in  pkg_fin4816_cursor.cr_rtf  (pcod_empresa  => pcod_empresa,  pdata_ini => pdata_inicial, pdata_fim   => pdata_final , pproc_id => pprocid )
             loop
             idx := idx + 1;
            
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo da Empresa"            := m.cod_empresa ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo do Estabelecimento"    := m.cod_estab;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Periodo de Emissão"           := to_char(m.data_emissao,'mm/yyyy');
             pkg_fin4816_type.t_fin4816_rtf ( idx )."CNPJ Drogaria"                := m.cgc;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Numero da Nota Fiscal"        := m.num_docto;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Tipo de Documento"            := m.tipo_docto;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Data Emissão"                 := m.data_emissao;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."CNPJ Fonecedor"               := m.cgc_fornecedor;       
             pkg_fin4816_type.t_fin4816_rtf ( idx ).uf                             := m.uf;                   
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Valor Total da Nota"          := m.valor_total;          
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Base de Calculo INSS"         := m.base_inss  ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Valor do INSS"                := m.valor_inss ;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo Pessoa Fisica/juridica":= m.cod_fis_jur;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Razão Social"                 := m.razao_social;         
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Municipio Prestador"          := m.municipio_prestador;  
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo de Serviço"            := m.cod_servico;          
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo CEI"                   := m.cod_cei;    
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_rtf                         := idx;
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Doc. Contábil"                := m.dsc_reservado1;                  
             pkg_fin4816_type.t_fin4816_rtf ( idx ).NM_USER                        := mnm_usuario;
             pkg_fin4816_type.t_fin4816_rtf ( idx ).ID_PROCID                      := pprocid;         
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Data da Execução"             := TO_DATE (SYSDATE,'DD/MM/YYYY HH24:MI:SS'); 
             
             
             
             
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete  ;     
             end loop;
             idx := 0;
             
             --    select distinct * from msafi.tb_fin4816_rel_apoio_fiscalv5 

             for n in   pkg_fin4816_cursor.cr_inss_retido (pempresa  => pcod_empresa , pdata_ini => pdata_inicial , pdata_fim => pdata_final , pproc_id => pprocid ) 
             loop
             idx := idx + 1;            
             pkg_fin4816_type.t_fin4816_rtf ( idx ).EMPRESA                     := n."Codigo Empresa";                              
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo Estabelecimento"    := n."Codigo Estabelecimento";                          
             pkg_fin4816_type.t_fin4816_rtf ( idx ).cod_pessoa_fis_jur          := n.cod_pessoa_fis_jur;                   
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Razão Social Cliente"      := n."Razão Social Cliente";                            
             pkg_fin4816_type.t_fin4816_rtf ( idx )."CNPJ Cliente"              := n."CNPJ Cliente";                                    
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Nro. Nota Fiscal"          := n."Número da Nota Fiscal";                           
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Dt. Emissao"               := n."Data Emissão";
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Dt. Fiscal"                := n."Data Fiscal";                                     
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Vlr. Total da Nota"        := n.vlr_tot_nota;                                      
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Vlr Base Calc. Retenção"   := n."Vlr Base Calc. Retenção";                         
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Vlr. Aliquota INSS"        := n.vlr_aliq_inss  ;                                    
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Vlr.Trib INSS RETIDO"      := n."Vlr.Trib INSS RETIDO";                            
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Razão Social Drogaria"     := n."Razão Social Drogaria";                           
             pkg_fin4816_type.t_fin4816_rtf ( idx )."CNPJ Drogarias"            := n.cgc;                                                  
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Descr. Tp. Documento"      := n.cod_docto;                                       
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Tp.Serv. E-social"         := n."Tipo de Serviço E-social";                                    
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Descr. Tp. Serv E-social"  := n.dsc_tipo_serv_esocial;                             
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Vlr. do Servico"           := n."Valor do Servico";                                
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Cod. Serv. Mastersaf"      := n.codigo_serv_prod;                                  
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Descr. Serv. Mastersaf"    := n.desc_serv_prod;   
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_inss_retido              := idx;
             pkg_fin4816_type.t_fin4816_rtf ( idx ).NM_USER                     := mnm_usuario;
             pkg_fin4816_type.t_fin4816_rtf ( idx ).ID_PROCID                   := pprocid;         
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Data da Execução"          := TO_DATE (SYSDATE,'DD/MM/YYYY HH24:MI:SS'); 
              
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete  ;         
             end loop;
             idx := 0;

             
             
             
             UPDATE  msafi.tb_fin4816_rel_apoio_fiscalv5 SET  ID_GERAL = ROWNUM
               WHERE  ID_PROCID   =  pprocid;
             commit;
             
             
                

             EXCEPTION 
              WHEN OTHERS THEN 
              loga ( '---ERRO NO PROCESSAMENTO---', FALSE );        
                  
         
   
   
   end carga_test;
  

    

    FUNCTION executar ( pdata_inicial DATE
                      , pdata_final DATE
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        --Variaveis genericas
        v_descricao             VARCHAR2 ( 4000 );
        p_task                  VARCHAR2 ( 30 );
        p_lote                  INTEGER := 10;
        v_qt_grupos             INTEGER := pdata_final - pdata_inicial + 1;
        v_qt_grupos_paralelos   INTEGER := 10;
       
        v_cont_estab            INTEGER := 0;
        l_status                NUMBER;
        
    BEGIN
    
        --=====================================================================
        --LIMPEZA DA TEMP QUANDO EXISTIREM REGISTROS MAIS ANTIGOS QUE 5 DIAS
        --=================================================================
         delete from msafi.tb_fin4816_prev_tmp_estab
         where to_date(substr(dt_carga, 1, 10), 'DD/MM/YYYY') <
               to_date(sysdate - 5, 'DD/MM/YYYY');
         commit;
      
           

         
             --    delete msafi.tb_fin4816_rel_apoio_fiscalV5 ;
             --    commit work;
         


    
              -- Criação: Processo
         mproc_id :=   lib_proc.new ( psp_nome => $$plsql_unit
                          , --  prows    => 48,
                            --  pcols    => 200,
                           pdescricao => v_descricao );

        COMMIT;

        p_task := 'PROC_EXCL_' || mproc_id;

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
    
         mcod_empresa := msafi.dpsp.v_empresa;
         mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );
         
          
         
         
         
         --===================================
         --QUANTIDADE DE PROCESSOS EM PARALELO
         --===================================
          
         IF nvl(p_lote, 0) < 1
         THEN
           v_qt_grupos_paralelos := 20;
         ELSIF nvl(p_lote, 0) > 100
         THEN
           v_qt_grupos_paralelos := 100;
         ELSE
           v_qt_grupos_paralelos := p_lote;
         END IF;
         
         loga('Quantidade em paralelo: ' || v_qt_grupos_paralelos, FALSE);
         loga(' ', FALSE);
         

         
         
         
         
         
         
         
         --============================================
         --LOOP de Estabelecimentos
         --============================================
         FOR v_estab IN pcod_estab.FIRST .. pcod_estab.LAST 
         LOOP
         v_cont_estab := v_cont_estab + 1;
         INSERT INTO msafi.tb_fin4816_prev_tmp_estab
         VALUES ( mproc_id, pcod_estab ( v_estab ), v_cont_estab, SYSDATE );
         COMMIT;
         END LOOP;        
         
         
         
         
         
        --===================================
        -- CHUNK
        --===================================
      
        msaf.dpsp_chunk_parallel.exec_parallel(mproc_id,
                                               'DPSP_V5_FIN4816_PREV_CPROC.CARGA_TEST',
                                               v_qt_grupos,
                                               v_qt_grupos_paralelos,
                                               p_task,               -- 'PROCESSAR_EXCLUSAO',
                                               'TO_DATE(''' ||
                                               to_char(pdata_inicial,
                                                       'DDMMYYYY') ||
                                               ''',''DDMMYYYY''),' ||
                                               'TO_DATE(''' ||
                                               to_char(pdata_final, 'DDMMYYYY') ||
                                               ''',''DDMMYYYY''),' || mproc_id ||
                                               ',''' || mcod_empresa || ''',' || '''' ||
                                               mnm_usuario || '''');
      
        dbms_parallel_execute.drop_task(p_task);
                 
 


        
--         carga_test ( 
--                  pnr_particao  INTEGER
--                , pnr_particao2 INTEGER
--                , pdata_inicial DATE
--                , pdata_final   DATE
--                , pprocid       VARCHAR2
--                , pcod_empresa  VARCHAR2
--                , p_nm_usuario  VARCHAR2 ) 
         
         
       
         --============================================
         -- LOOP  ( load table ) 
         --============================================
--          carga_test  (   
--            pcod_empresa    => mcod_empresa
--          , pdata_inicial   => pdata_inicial    --TO_DATE ( pdata_inicial, 'DD/MM/YYYY') 
--          , pdata_final     => pdata_final      --TO_DATE ( pdata_final, 'DD/MM/YYYY')  
--          , pprocid         => mproc_id ) ;
          



         



         --============================================
         -- Output Excel (03 relatórios )
         --============================================
             prc_output_excel (     vp_mproc_id    => mproc_id
                                 ,  v_data_inicial => pdata_inicial
                                 ,  v_data_final   => pdata_final);
            




          loga ( '---FIM DO PROCESSAMENTO---', FALSE );        
          lib_proc.close;          
          RETURN mproc_id;
 
    END;
    
END dpsp_v5_fin4816_prev_cproc;
/