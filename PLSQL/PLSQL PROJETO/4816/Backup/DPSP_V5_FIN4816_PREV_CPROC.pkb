CREATE OR REPLACE PACKAGE BODY MSAF.dpsp_v5_fin4816_prev_cproc
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
                           , ptitulo => 'Data Inicial'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );


        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
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

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>   dsp_planilha.campo ( 'Relatório Fiscal'         , p_custom => 'COLSPAN=18' )             || --
                                                            dsp_planilha.campo (  'Relatório Previdenciario', p_custom => 'COLSPAN=20 BGCOLOR=BLUE') || --
                                                            dsp_planilha.campo (  'Relatório Evento R-2010' , p_custom => 'COLSPAN=21 BGCOLOR=GREEN'), p_class => 'h' ) , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>   dsp_planilha.campo ( 'Codigo da Empresa' )              || -- 1
                                                            dsp_planilha.campo ( 'Codigo do Estabelecimento' )      || -- 2
                                                            dsp_planilha.campo  ( 'Periodo de Emissão' )            || -- 3
                                                            dsp_planilha.campo ( 'CNPJ Drogaria' )                  || -- 4
                                                            dsp_planilha.campo ( 'Numero da Nota Fiscal' )          || -- 5
                                                            dsp_planilha.campo ( 'Tipo de Documento' )              || -- 6
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



        FOR i IN (select * from msafi.tb_fin4816_rel_apoio_fiscal order by 1,2,3,4,5) LOOP
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


   procedure   carga_test (pcod_empresa varchar2, pdata_inicial date, pdata_final  date ,  pprocid number ) 
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
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_rtf := idx;
             
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete  ;     
             end loop;
             idx := 0;
             
             --    select distinct * from msafi.tb_fin4816_rel_apoio_fiscalv5 

             for n in   pkg_fin4816_cursor.cr_inss_retido (pempresa  => pcod_empresa , pdata_ini => pdata_inicial , pdata_fim => pdata_final , procid => pprocid ) 
             loop
             idx := idx + 1;            
             pkg_fin4816_type.t_fin4816_rtf ( idx ).EMPRESA                     := n."Codigo Empresa";                              
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Codigo Estabelecimento"    := n."Codigo Estabelecimento";                          
             pkg_fin4816_type.t_fin4816_rtf ( idx ).cod_pessoa_fis_jur          := n."Codigo Pessoa Fisica/Juridica";                   
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Razão Social Cliente"      := n."Razão Social Cliente";                            
             pkg_fin4816_type.t_fin4816_rtf ( idx )."CNPJ Cliente"              := n."CNPJ Cliente";                                    
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Nro. Nota Fiscal"          := n."Número da Nota Fiscal";                           
             pkg_fin4816_type.t_fin4816_rtf ( idx )."Dt. Emissao"               := n."Emissão";
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
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_inss_retido := idx;
              
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete  ;         
             end loop;
             idx := 0;

           
             for j in   pkg_fin4816_cursor.rc_reinf_evento_e2010 (pcod_empresa  =>pcod_empresa ,   pdata_ini => pdata_inicial , pdata_fim => pdata_final , pprocid => pprocid)   
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
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_reinf_e2010 := idx;
             
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete;      
             end loop;            
             idx := 0;


   
   
   
   end carga_test;
  
    PROCEDURE prc_reinf_conf_retencao ( 
                                        p_cod_empresa   IN VARCHAR2
                                      , p_cod_estab     IN  VARCHAR2 
                                      , p_tipo_selec    IN VARCHAR2
                                      , p_data_inicial  IN DATE
                                      , p_data_final    IN DATE
                                      , p_cod_usuario   IN VARCHAR2
                                      , p_entrada_saida IN VARCHAR2
                                      , p_status        OUT NUMBER
                                      , p_proc_id       IN VARCHAR2 
                                         )
    IS
    
    

    
        cod_empresa_w estabelecimento.cod_empresa%TYPE;
        cod_estab_w estabelecimento.cod_estab%TYPE;
        data_ini_w DATE;
        data_fim_w DATE;
        
        l_rec  varchar2(30);
        
        
  

        --  PREVISÃO DOS RETIDOS (1) = 'E'
        CURSOR c_conf_ret_prev ( p_cod_empresa VARCHAR2
                               , p_cod_estab VARCHAR2
                               , p_data_inicial DATE
                               , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
             WHERE 1 = 1
               AND estab.cod_estab      = dwt_itens.cod_estab
               AND estab.proc_id        = p_proc_id
               AND doc_fis.cod_empresa  = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
             WHERE 1 = 1
               AND estab.cod_estab      = dwt_itens.cod_estab
               AND estab.proc_id        = p_proc_id
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
                , msafi.tb_fin4816_prev_tmp_estab  estab
             WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id
               --
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_sem_tipo_serv ( p_cod_empresa VARCHAR2
                                    , p_cod_estab VARCHAR2
                                    , p_data_inicial DATE
                                    , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
             WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id
               -- 
               AND doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND NOT EXISTS
                       (SELECT 1
                          FROM prt_id_tipo_serv_esocial a
                             , x2018_servicos x2018
                         WHERE a.cod_empresa = dwt_itens.cod_empresa
                           AND a.cod_estab = dwt_itens.cod_estab
                           AND x2018.ident_servico = dwt_itens.ident_servico
                           AND a.grupo_servico = x2018.grupo_servico
                           AND a.cod_servico = x2018.cod_servico)
               AND NOT EXISTS
                       (SELECT 1
                          FROM prt_serv_msaf a
                             , x2018_servicos x2018
                         WHERE a.cod_empresa = dwt_itens.cod_empresa
                           AND a.cod_estab = dwt_itens.cod_estab
                           AND x2018.ident_servico = dwt_itens.ident_servico
                           AND a.grupo_servico = x2018.grupo_servico
                           AND a.cod_servico = x2018.cod_servico
                           AND a.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 ))
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               --AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
               
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
                 , msafi.tb_fin4816_prev_tmp_estab  estab
              WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id
                 
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND NOT EXISTS
                       (SELECT 1
                          FROM prt_id_tipo_serv_prod p
                             , x2013_produto x2013
                         WHERE p.cod_empresa = dwt_merc.cod_empresa
                           AND p.cod_estab = dwt_merc.cod_estab
                           AND x2013.ident_produto = dwt_merc.ident_produto
                           AND p.grupo_produto = x2013.grupo_produto
                           AND p.cod_produto = x2013.cod_produto
                           AND p.ind_produto = x2013.ind_produto)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_ret_prev_proc ( p_cod_empresa VARCHAR2
                                    , p_cod_estab VARCHAR2
                                    , p_data_inicial DATE
                                    , p_data_final DATE )
        IS
            SELECT DISTINCT doc_fis.data_emissao
                          , doc_fis.data_fiscal
                          , doc_fis.ident_fis_jur
                          , doc_fis.ident_docto
                          , doc_fis.num_docfis
                          , doc_fis.serie_docfis
                          , doc_fis.sub_serie_docfis
                          , NULL
                          , doc_fis.cod_class_doc_fis
                          , doc_fis.vlr_tot_nota
                          , doc_fis.vlr_contab_compl
                          , dwt_itens.vlr_base_inss
                          , dwt_itens.vlr_aliq_inss
                          , dwt_itens.vlr_inss_retido
                          , x2058.ind_tp_proc_adj
                          , x2058.num_proc_adj
                          , dwt_itens.num_item
                          , dwt_itens.vlr_servico
                          , x2058_adic.ind_tp_proc_adj
                          , x2058_adic.num_proc_adj
                          , dwt_itens.ident_servico
                          , NULL
                          , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , x2018_servicos x2018_adic
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
             WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
                 
               AND doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND ( x2058.num_proc_adj IS NOT NULL
                 OR x2058_adic.num_proc_adj IS NOT NULL )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               --AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
                 , msafi.tb_fin4816_prev_tmp_estab  estab
              WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id
               
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND ( x2058.num_proc_adj IS NOT NULL
                 OR x2058_adic.num_proc_adj IS NOT NULL )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               ---AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_ret_prev_sem_proc ( p_cod_empresa VARCHAR2
                                        , p_cod_estab VARCHAR2
                                        , p_data_inicial DATE
                                        , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , dwt_itens.ind_tp_proc_adj_princ
                 , NULL
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , dwt_itens.ind_tp_proc_adj_princ
                 , NULL
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , msafi.tb_fin4816_prev_tmp_estab  estab
              WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               --  
               AND doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND dwt_itens.ident_proc_adj_princ IS NULL
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) = 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , dwt_merc.ind_tp_proc_adj_princ
                 , NULL
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , dwt_merc.ind_tp_proc_adj_princ
                 , NULL
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , x2024_modelo_docto x2024
                 , msafi.tb_fin4816_prev_tmp_estab  estab
              WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id      
                 
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND dwt_merc.ident_proc_adj_princ IS NULL
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) = 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_inss_maior_bruto ( p_cod_empresa VARCHAR2
                                       , p_cod_estab VARCHAR2
                                       , p_data_inicial DATE
                                       , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               
               AND  doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_base_inss > doc_fis.vlr_tot_nota
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               
               AND doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_base_inss > doc_fis.vlr_tot_nota
               AND doc_fis.cod_empresa = p_cod_empresa
               --AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_merc.vlr_base_inss > doc_fis.vlr_tot_nota
               AND doc_fis.cod_empresa = p_cod_empresa
               --AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_inss_aliq_dif_informado ( p_cod_empresa VARCHAR2
                                              , p_cod_estab VARCHAR2
                                              , p_data_inicial DATE
                                              , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               
               AND  doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND ROUND ( ( dwt_itens.vlr_base_inss * dwt_itens.vlr_aliq_inss ) / 100
                         , 2 ) <> dwt_itens.vlr_inss_retido
               AND doc_fis.cod_empresa = p_cod_empresa
               --AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               AND  doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND ROUND ( ( dwt_itens.vlr_base_inss * dwt_itens.vlr_aliq_inss ) / 100
                         , 2 ) <> dwt_itens.vlr_inss_retido
               AND doc_fis.cod_empresa = p_cod_empresa
               --AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               
               AND  doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab    = dwt_merc.cod_estab
               AND doc_fis.data_fiscal  = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur= dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto  = dwt_merc.ident_docto
               AND doc_fis.num_docfis   = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND ROUND ( ( dwt_merc.vlr_base_inss * dwt_merc.vlr_aliq_inss ) / 100
                         , 2 ) <> dwt_merc.vlr_inss_retido
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_aliq_inss_invalida ( p_cod_empresa VARCHAR2
                                         , p_cod_estab VARCHAR2
                                         , p_data_inicial DATE
                                         , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                  , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               
               AND  doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_aliq_inss <> 11
               AND dwt_itens.vlr_aliq_inss <> 3.5
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               --
               AND  doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_aliq_inss <> 11
               AND dwt_itens.vlr_aliq_inss <> 3.5
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
                 , msafi.tb_fin4816_prev_tmp_estab  estab
               WHERE 1 = 1               
               AND estab.cod_estab      = doc_fis.cod_estab
               AND estab.proc_id        = p_proc_id   
               --
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_merc.vlr_aliq_inss <> 11
               AND dwt_merc.vlr_aliq_inss <> 3.5
               AND doc_fis.cod_empresa = p_cod_empresa
              -- AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        TYPE treg_data_emissao IS TABLE OF reinf_conf_previdenciaria.data_emissao%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_data_fiscal IS TABLE OF reinf_conf_previdenciaria.data_fiscal%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_fis_jur IS TABLE OF reinf_conf_previdenciaria.ident_fis_jur%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_docto IS TABLE OF reinf_conf_previdenciaria.ident_docto%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_docfis IS TABLE OF reinf_conf_previdenciaria.num_docfis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_serie_docfis IS TABLE OF reinf_conf_previdenciaria.serie_docfis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_sub_serie_docfis IS TABLE OF reinf_conf_previdenciaria.sub_serie_docfis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_tipo_serv_esocial IS TABLE OF reinf_conf_previdenciaria.ident_tipo_serv_esocial%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_cod_class_doc_fis IS TABLE OF reinf_conf_previdenciaria.cod_class_doc_fis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_tot_nota IS TABLE OF reinf_conf_previdenciaria.vlr_tot_nota%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_contab_compl IS TABLE OF reinf_conf_previdenciaria.vlr_contab_compl%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_base_inss IS TABLE OF reinf_conf_previdenciaria.vlr_base_inss%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_aliq_inss IS TABLE OF reinf_conf_previdenciaria.vlr_aliq_inss%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_inss_retido IS TABLE OF reinf_conf_previdenciaria.vlr_inss_retido%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ind_tipo_proc IS TABLE OF reinf_conf_previdenciaria.ind_tipo_proc%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_proc_jur IS TABLE OF reinf_conf_previdenciaria.num_proc_jur%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_item IS TABLE OF dwt_itens_serv.num_item%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_servico IS TABLE OF reinf_conf_previdenciaria.vlr_servico%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ind_tp_proc_adj_adic IS TABLE OF reinf_conf_previdenciaria.ind_tp_proc_adj_adic%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_proc_adj_adic IS TABLE OF reinf_conf_previdenciaria.num_proc_adj_adic%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_servico IS TABLE OF dwt_itens_serv.ident_servico%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_produto IS TABLE OF dwt_itens_merc.ident_produto%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_cod_param IS TABLE OF reinf_conf_previdenciaria.cod_param%TYPE
            INDEX BY BINARY_INTEGER;

        rreg_data_emissao treg_data_emissao;
        rreg_data_fiscal treg_data_fiscal;
        rreg_ident_fis_jur treg_ident_fis_jur;
        rreg_ident_docto treg_ident_docto;
        rreg_num_docfis treg_num_docfis;
        rreg_serie_docfis treg_serie_docfis;
        rreg_sub_serie_docfis treg_sub_serie_docfis;
        rreg_ident_tipo_serv_esocial treg_ident_tipo_serv_esocial;
        rreg_cod_class_doc_fis treg_cod_class_doc_fis;
        rreg_vlr_tot_nota treg_vlr_tot_nota;
        rreg_vlr_contab_compl treg_vlr_contab_compl;
        rreg_vlr_base_inss treg_vlr_base_inss;
        rreg_vlr_aliq_inss treg_vlr_aliq_inss;
        rreg_vlr_inss_retido treg_vlr_inss_retido;
        rreg_ind_tipo_proc treg_ind_tipo_proc;
        rreg_num_proc_jur treg_num_proc_jur;
        rreg_num_item treg_num_item;
        rreg_vlr_servico treg_vlr_servico;
        rreg_ind_tp_proc_adj_adic treg_ind_tp_proc_adj_adic;
        rreg_num_proc_adj_adic treg_num_proc_adj_adic;
        rreg_ident_servico treg_ident_servico;
        rreg_ident_produto treg_ident_produto;
        rreg_cod_param treg_cod_param;

        rtabsaida reinf_conf_previdenciaria%ROWTYPE;


        PROCEDURE inicializar
        IS
        BEGIN
            rreg_data_emissao.delete;
            rreg_data_fiscal.delete;
            rreg_ident_fis_jur.delete;
            rreg_ident_docto.delete;
            rreg_num_docfis.delete;
            rreg_serie_docfis.delete;
            rreg_sub_serie_docfis.delete;
            rreg_ident_tipo_serv_esocial.delete;
            rreg_cod_class_doc_fis.delete;
            rreg_vlr_tot_nota.delete;
            rreg_vlr_contab_compl.delete;
            rreg_vlr_base_inss.delete;
            rreg_vlr_aliq_inss.delete;
            rreg_vlr_inss_retido.delete;
            rreg_ind_tipo_proc.delete;
            rreg_num_proc_jur.delete;
            rreg_num_item.delete;
            rreg_vlr_servico.delete;
            rreg_ind_tp_proc_adj_adic.delete;
            rreg_num_proc_adj_adic.delete;
            rreg_cod_param.delete;
        END inicializar;

    
        
        PROCEDURE gravaregistro ( preg IN reinf_conf_previdenciaria%ROWTYPE )
        IS
        BEGIN
            BEGIN
                  INSERT INTO msafi.tb_fin4816_reinf_conf_prev_tmp  (
                                                cod_empresa
                                              , cod_estab
                                              , data_emissao
                                              , data_fiscal
                                              , ident_fis_jur
                                              , ident_docto
                                              , num_docfis
                                              , serie_docfis
                                              , sub_serie_docfis
                                              , cod_usuario
                                              , ident_tipo_serv_esocial
                                              , cod_class_doc_fis
                                              , vlr_tot_nota
                                              , vlr_contab_compl
                                              , vlr_base_inss
                                              , vlr_aliq_inss
                                              , vlr_inss_retido
                                              , ind_tipo_proc
                                              , num_proc_jur
                                              , num_item
                                              , vlr_servico
                                              , ind_tp_proc_adj_adic
                                              , num_proc_adj_adic
                                              , ident_servico   
                                              , ident_produto
                                              , cod_param
                                              , procid 
                                  )                                             
                                                                               
                     VALUES ( preg.cod_empresa                                 
                            , preg.cod_estab                                   
                            , preg.data_emissao                                
                            , preg.data_fiscal                                 
                            , preg.ident_fis_jur                                         
                            , preg.ident_docto                                 
                            , preg.num_docfis                                  
                            , preg.serie_docfis                                
                            , preg.sub_serie_docfis                            
                            , preg.cod_usuario                                 
                            , preg.ident_tipo_serv_esocial                     
                            , preg.cod_class_doc_fis                           
                            , preg.vlr_tot_nota                                
                            , preg.vlr_contab_compl                            
                            , preg.vlr_base_inss                               
                            , preg.vlr_aliq_inss                               
                            , preg.vlr_inss_retido                             
                            , preg.ind_tipo_proc                               
                            , preg.num_proc_jur                                
                            , preg.num_item
                            , preg.vlr_servico
                            , preg.ind_tp_proc_adj_adic
                            , preg.num_proc_adj_adic
                            , preg.ident_servico
                            , preg.ident_produto
                            , preg.cod_param 
                            , p_proc_id );
                            
                      

                --p_status := p_proc_id;
                          
        
                            
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
                WHEN OTHERS THEN
                    p_status := -1;
            END;
            
        END gravaregistro;


        PROCEDURE montaregistros
        IS
        BEGIN
            FOR i IN 1 .. rreg_data_emissao.COUNT LOOP
                BEGIN
                    p_status := 1;
                    rtabsaida.cod_empresa := cod_empresa_w;
                    rtabsaida.cod_estab := cod_estab_w;
                    rtabsaida.data_emissao := rreg_data_emissao ( i );
                    rtabsaida.data_fiscal := rreg_data_fiscal ( i );
                    rtabsaida.ident_fis_jur := rreg_ident_fis_jur ( i );
                    rtabsaida.ident_docto := rreg_ident_docto ( i );
                    rtabsaida.num_docfis := rreg_num_docfis ( i );
                    rtabsaida.serie_docfis := rreg_serie_docfis ( i );
                    rtabsaida.sub_serie_docfis := rreg_sub_serie_docfis ( i );
                    rtabsaida.cod_usuario := p_cod_usuario;
                    rtabsaida.ident_tipo_serv_esocial := rreg_ident_tipo_serv_esocial ( i );
                    rtabsaida.cod_class_doc_fis := rreg_cod_class_doc_fis ( i );
                    rtabsaida.vlr_tot_nota := rreg_vlr_tot_nota ( i );
                    rtabsaida.vlr_contab_compl := rreg_vlr_contab_compl ( i );
                    rtabsaida.vlr_base_inss := rreg_vlr_base_inss ( i );
                    rtabsaida.vlr_aliq_inss := rreg_vlr_aliq_inss ( i );
                    rtabsaida.vlr_inss_retido := rreg_vlr_inss_retido ( i );
                    rtabsaida.ind_tipo_proc := rreg_ind_tipo_proc ( i );
                    rtabsaida.num_proc_jur := rreg_num_proc_jur ( i );
                    rtabsaida.num_item := rreg_num_item ( i );
                    rtabsaida.vlr_servico := rreg_vlr_servico ( i );
                    rtabsaida.ind_tp_proc_adj_adic := rreg_ind_tp_proc_adj_adic ( i );
                    rtabsaida.num_proc_adj_adic := rreg_num_proc_adj_adic ( i );
                    rtabsaida.ident_servico := rreg_ident_servico ( i );
                    rtabsaida.ident_produto := rreg_ident_produto ( i );
                    rtabsaida.cod_param := rreg_cod_param ( i );

                    gravaregistro ( rtabsaida );
                END;
            END LOOP;
        END montaregistros;

        PROCEDURE montaregistrossemtiposerv
        IS
        BEGIN
            FOR i IN 1 .. rreg_data_emissao.COUNT LOOP
                BEGIN
                    p_status := 1;
                    rtabsaida.cod_empresa := cod_empresa_w;
                    rtabsaida.cod_estab := cod_estab_w;
                    rtabsaida.data_emissao := rreg_data_emissao ( i );
                    rtabsaida.data_fiscal := rreg_data_fiscal ( i );
                    rtabsaida.ident_fis_jur := rreg_ident_fis_jur ( i );
                    rtabsaida.ident_docto := rreg_ident_docto ( i );
                    rtabsaida.num_docfis := rreg_num_docfis ( i );
                    rtabsaida.serie_docfis := rreg_serie_docfis ( i );
                    rtabsaida.sub_serie_docfis := rreg_sub_serie_docfis ( i );
                    rtabsaida.cod_usuario := p_cod_usuario;
                    rtabsaida.ident_tipo_serv_esocial := NULL;
                    rtabsaida.cod_class_doc_fis := rreg_cod_class_doc_fis ( i );
                    rtabsaida.vlr_tot_nota := rreg_vlr_tot_nota ( i );
                    rtabsaida.vlr_contab_compl := rreg_vlr_contab_compl ( i );
                    rtabsaida.vlr_base_inss := rreg_vlr_base_inss ( i );
                    rtabsaida.vlr_aliq_inss := rreg_vlr_aliq_inss ( i );
                    rtabsaida.vlr_inss_retido := rreg_vlr_inss_retido ( i );
                    rtabsaida.ind_tipo_proc := rreg_ind_tipo_proc ( i );
                    rtabsaida.num_proc_jur := rreg_num_proc_jur ( i );
                    rtabsaida.num_item := rreg_num_item ( i );
                    rtabsaida.ind_tp_proc_adj_adic := rreg_ind_tp_proc_adj_adic ( i );
                    rtabsaida.num_proc_adj_adic := rreg_num_proc_adj_adic ( i );
                    rtabsaida.ident_servico := rreg_ident_servico ( i );
                    rtabsaida.ident_produto := rreg_ident_produto ( i );
                    rtabsaida.cod_param := rreg_cod_param ( i );

                    gravaregistro ( rtabsaida );
                END;
            END LOOP;
        END montaregistrossemtiposerv;



        PROCEDURE recregistrosservretprev
        IS
        BEGIN
            OPEN c_conf_ret_prev ( cod_empresa_w
                                 , cod_estab_w
                                 , data_ini_w
                                 , data_fim_w );

            LOOP
                FETCH c_conf_ret_prev
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_ret_prev%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_ret_prev;
        END recregistrosservretprev;



        PROCEDURE recregistrossemtiposerv
        IS
        BEGIN
            OPEN c_conf_sem_tipo_serv ( cod_empresa_w
                                      , cod_estab_w
                                      , data_ini_w
                                      , data_fim_w );

            LOOP
                FETCH c_conf_sem_tipo_serv
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_sem_tipo_serv%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_sem_tipo_serv;
        END recregistrossemtiposerv;


        PROCEDURE recregistrosretprevproc
        IS
        BEGIN
            OPEN c_conf_ret_prev_proc ( cod_empresa_w
                                      , cod_estab_w
                                      , data_ini_w
                                      , data_fim_w );

            LOOP
                FETCH c_conf_ret_prev_proc
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_ret_prev_proc%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_ret_prev_proc;
        END recregistrosretprevproc;


        PROCEDURE recregistrosretprevsemproc
        IS
        BEGIN
            OPEN c_conf_ret_prev_sem_proc ( cod_empresa_w
                                          , cod_estab_w
                                          , data_ini_w
                                          , data_fim_w );

            LOOP
                FETCH c_conf_ret_prev_sem_proc
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_ret_prev_sem_proc%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_ret_prev_sem_proc;
        END recregistrosretprevsemproc;



        PROCEDURE recregistrosinssmaiorbruto
        IS
        BEGIN
            OPEN c_conf_inss_maior_bruto ( cod_empresa_w
                                         , cod_estab_w
                                         , data_ini_w
                                         , data_fim_w );

            LOOP
                FETCH c_conf_inss_maior_bruto
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_inss_maior_bruto%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_inss_maior_bruto;
        END recregistrosinssmaiorbruto;


        PROCEDURE recregistrosinssaliqdifinform
        IS
        BEGIN
            OPEN c_conf_inss_aliq_dif_informado ( cod_empresa_w
                                                , cod_estab_w
                                                , data_ini_w
                                                , data_fim_w );

            LOOP
                FETCH c_conf_inss_aliq_dif_informado
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_inss_aliq_dif_informado%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_inss_aliq_dif_informado;
        END recregistrosinssaliqdifinform;


        PROCEDURE recregistrosaliqinssinvalida
        IS
        BEGIN
            OPEN c_conf_aliq_inss_invalida ( cod_empresa_w
                                           , cod_estab_w
                                           , data_ini_w
                                           , data_fim_w );

            LOOP
                FETCH c_conf_aliq_inss_invalida
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_aliq_inss_invalida%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_aliq_inss_invalida;
        END recregistrosaliqinssinvalida;
    BEGIN
        p_status := 0;

        cod_empresa_w := p_cod_empresa;
        cod_estab_w := p_cod_estab;
        data_ini_w := p_data_inicial;
        data_fim_w := p_data_final;



        IF p_tipo_selec = '1' THEN
            recregistrosservretprev;
        ELSIF p_tipo_selec = '2' THEN
            recregistrossemtiposerv;
        ELSIF p_tipo_selec = '3' THEN
            recregistrosretprevproc;
        ELSIF p_tipo_selec = '4' THEN
            recregistrosretprevsemproc;
        ELSIF p_tipo_selec = '5' THEN
            recregistrosinssmaiorbruto;
        ELSIF p_tipo_selec = '6' THEN
            recregistrosinssaliqdifinform;
        ELSIF p_tipo_selec = '7' THEN
            recregistrosaliqinssinvalida;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 0;
            RETURN;
        WHEN OTHERS THEN
            p_status := -1;
            RETURN;
    END prc_reinf_conf_retencao;
    

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
      
         delete msafi.tb_fin4816_reinf_conf_prev_tmp;      
         delete msafi.tb_fin4816_rel_apoio_fiscalV5 ;
         commit work;
         


    
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
        
         
            
   LOGA ('mcod_empresa: '||mcod_empresa); 
   
   LOGA ('pdata_inicial: '||pdata_inicial); 
   
   LOGA ('pdata_final: '||pdata_final); 
        
   LOGA ('mnm_usuario: '||mnm_usuario); 
        
    LOGA ('mproc_id: '||mproc_id); 
         
          --============================================
          -- LOOP de Estabelecimentos /inss retido 
          --============================================
                     prc_reinf_conf_retencao( 
                                    p_cod_empresa   => mcod_empresa
                                   ,p_cod_estab     => NULL   
                                   ,p_tipo_selec    => '1'
                                   ,p_data_inicial  => pdata_inicial   -- TO_DATE ( pdata_inicial, 'DD/MM/YYYY')
                                   ,p_data_final    => pdata_final     -- TO_DATE ( pdata_final, 'DD/MM/YYYY')
                                   ,p_cod_usuario   => mnm_usuario
                                   ,p_entrada_saida => 'E'
                                   ,p_status        => l_status
                                   ,p_proc_id       => mproc_id);
  
       
         
                     carga_test  (   
                                    pcod_empresa    =>  mcod_empresa
                                  , pdata_inicial   => TO_DATE ( pdata_inicial, 'DD/MM/YYYY') 
                                  , pdata_final     => TO_DATE ( pdata_final, 'DD/MM/YYYY')  
                                  , pprocid         => mproc_id ) ;
         
         
         
         


         

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