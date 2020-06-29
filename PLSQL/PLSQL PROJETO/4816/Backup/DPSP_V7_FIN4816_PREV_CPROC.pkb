CREATE OR REPLACE PACKAGE BODY MSAF.DPSP_V7_FIN4816_PREV_CPROC
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    
    l_name_file     varchar2(100) ;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 )  := '0 - Relatorio Previdenciario';
    mnm_cproc VARCHAR2 ( 100 ) := '7.Relatorio de apoio';
    mds_cproc VARCHAR2 ( 100 ) := 'Validacao das Inf. Reinf (V7) - Sheet/Tela/zip';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    i NUMBER := 0;
    
    lv VARCHAR2(50);
    
     c_local_file_header CONSTANT RAW ( 4 ) := HEXTORAW ( '504B0304' ); -- Local file header signature
    c_end_of_central_directory CONSTANT RAW ( 4 ) := HEXTORAW ( '504B0506' ); -- End of central directory signature

    --
    TYPE tp_xf_fmt IS RECORD
    (
        numfmtid PLS_INTEGER
      , fontid PLS_INTEGER
      , fillid PLS_INTEGER
      , borderid PLS_INTEGER
      , alignment tp_alignment
    );

    TYPE tp_col_fmts IS TABLE OF tp_xf_fmt
        INDEX BY PLS_INTEGER;

    TYPE tp_row_fmts IS TABLE OF tp_xf_fmt
        INDEX BY PLS_INTEGER;

    TYPE tp_widths IS TABLE OF NUMBER
        INDEX BY PLS_INTEGER;

    TYPE tp_heights IS TABLE OF NUMBER
        INDEX BY PLS_INTEGER;

    TYPE tp_cell IS RECORD
    (
        VALUE NUMBER
      , style VARCHAR2 ( 50 )
    );

    TYPE tp_cells IS TABLE OF tp_cell
        INDEX BY PLS_INTEGER;

    TYPE tp_rows IS TABLE OF tp_cells
        INDEX BY PLS_INTEGER;

    TYPE tp_autofilter IS RECORD
    (
        column_start PLS_INTEGER
      , column_end PLS_INTEGER
      , row_start PLS_INTEGER
      , row_end PLS_INTEGER
    );

    TYPE tp_autofilters IS TABLE OF tp_autofilter
        INDEX BY PLS_INTEGER;

    TYPE tp_hyperlink IS RECORD
    (
        cell VARCHAR2 ( 10 )
      , url VARCHAR2 ( 1000 )
      , location VARCHAR2 ( 1000 )
    );

    TYPE tp_hyperlinks IS TABLE OF tp_hyperlink
        INDEX BY PLS_INTEGER;

    SUBTYPE tp_author IS VARCHAR2 ( 32767 CHAR );

    TYPE tp_authors IS TABLE OF PLS_INTEGER
        INDEX BY tp_author;

    authors tp_authors;

    TYPE tp_comment IS RECORD
    (
        text VARCHAR2 ( 32767 CHAR )
      , author tp_author
      , row PLS_INTEGER
      , column PLS_INTEGER
      , width PLS_INTEGER
      , height PLS_INTEGER
    );

    TYPE tp_comments IS TABLE OF tp_comment
        INDEX BY PLS_INTEGER;

    TYPE tp_mergecells IS TABLE OF VARCHAR2 ( 21 )
        INDEX BY PLS_INTEGER;

    TYPE tp_validation IS RECORD
    (
        TYPE VARCHAR2 ( 10 )
      , errorstyle VARCHAR2 ( 32 )
      , showinputmessage BOOLEAN
      , prompt VARCHAR2 ( 32767 CHAR )
      , title VARCHAR2 ( 32767 CHAR )
      , error_title VARCHAR2 ( 32767 CHAR )
      , error_txt VARCHAR2 ( 32767 CHAR )
      , showerrormessage BOOLEAN
      , formula1 VARCHAR2 ( 32767 CHAR )
      , formula2 VARCHAR2 ( 32767 CHAR )
      , allowblank BOOLEAN
      , sqref VARCHAR2 ( 32767 CHAR )
    );

    TYPE tp_validations IS TABLE OF tp_validation
        INDEX BY PLS_INTEGER;

    TYPE tp_sheet IS RECORD
    (
        rows tp_rows
      , widths tp_widths
      , heights tp_heights
      , name VARCHAR2 ( 100 )
      , freeze_rows PLS_INTEGER
      , freeze_cols PLS_INTEGER
      , autofilters tp_autofilters
      , hyperlinks tp_hyperlinks
      , col_fmts tp_col_fmts
      , row_fmts tp_row_fmts
      , comments tp_comments
      , mergecells tp_mergecells
      , validations tp_validations
    );

    TYPE tp_sheets IS TABLE OF tp_sheet
        INDEX BY PLS_INTEGER;

    TYPE tp_numfmt IS RECORD
    (
        numfmtid PLS_INTEGER
      , formatcode VARCHAR2 ( 100 )
    );

    TYPE tp_numfmts IS TABLE OF tp_numfmt
        INDEX BY PLS_INTEGER;

    TYPE tp_fill IS RECORD
    (
        patterntype VARCHAR2 ( 30 )
      , fgrgb VARCHAR2 ( 8 )
    );

    TYPE tp_fills IS TABLE OF tp_fill
        INDEX BY PLS_INTEGER;

    TYPE tp_cellxfs IS TABLE OF tp_xf_fmt
        INDEX BY PLS_INTEGER;

    TYPE tp_font IS RECORD
    (
        name VARCHAR2 ( 100 )
      , family PLS_INTEGER
      , fontsize NUMBER
      , theme PLS_INTEGER
      , rgb VARCHAR2 ( 8 )
      , underline BOOLEAN
      , italic BOOLEAN
      , bold BOOLEAN
    );

    TYPE tp_fonts IS TABLE OF tp_font
        INDEX BY PLS_INTEGER;

    TYPE tp_border IS RECORD
    (
        top VARCHAR2 ( 17 )
      , bottom VARCHAR2 ( 17 )
      , left VARCHAR2 ( 17 )
      , right VARCHAR2 ( 17 )
    );

    TYPE tp_borders IS TABLE OF tp_border
        INDEX BY PLS_INTEGER;

    TYPE tp_numfmtindexes IS TABLE OF PLS_INTEGER
        INDEX BY PLS_INTEGER;

    TYPE tp_strings IS TABLE OF PLS_INTEGER
        INDEX BY VARCHAR2 ( 32767 CHAR );

    TYPE tp_str_ind IS TABLE OF VARCHAR2 ( 32767 CHAR )
        INDEX BY PLS_INTEGER;

    TYPE tp_defined_name IS RECORD
    (
        name VARCHAR2 ( 32767 CHAR )
      , REF VARCHAR2 ( 32767 CHAR )
      , sheet PLS_INTEGER
    );

    TYPE tp_defined_names IS TABLE OF tp_defined_name
        INDEX BY PLS_INTEGER;

    TYPE tp_book IS RECORD
    (
        sheets tp_sheets
      , strings tp_strings
      , str_ind tp_str_ind
      , str_cnt PLS_INTEGER:= 0
      , fonts tp_fonts
      , fills tp_fills
      , borders tp_borders
      , numfmts tp_numfmts
      , cellxfs tp_cellxfs
      , numfmtindexes tp_numfmtindexes
      , defined_names tp_defined_names
    );

    workbook tp_book;


    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        -- PDATA_EMISSAO_INICIAL 
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial Emissão:'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        -- PDATA_EMISSAO_FINAL
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final Emissão:'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );
              
          -- P_RADIO
          LIB_PROC.ADD_PARAM(PPARAM   => PSTR, PTITULO=> 'Salve o arquivo  : ', PTIPO => 'varchar2', PCONTROLE   => 'radiobutton',  PMANDATORIO => 'S',   PDEFAULT => 'S', PMASCARA    => NULL,PVALORES    => 'S= .csv,S1= .xlxs');
                           
                           
           -- DIRETÓRIO
          lib_proc.add_param(pparam      => pstr,
                       ptitulo     => 'Salve Excel (.ZIP) ',
                       ptipo       => 'Varchar2',
                       pcontrole   => 'Textbox',
                       pmandatorio => 'N',
                       pdefault    => 'MSAFIMP',
                       pmascara    => null,
                       pvalores    => 'SELECT directory_name,directory_path FROM PRT_DIRETORIOS_SERVIDOR',
                       papresenta  => 'N',
                       phabilita   =>':3 IN (''S1'',''L'')'
                       );
     

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
                             || ' FROM ESTABELECIMENTO A, ESTADO B, ESTABELECIMENTO C '
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
        
        
       --
      
        
        
        
        

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
  

    --
    PROCEDURE blob2file ( p_blob BLOB
                        , p_directory VARCHAR2 := 'MY_DIR'
                        , p_filename VARCHAR2 := 'my.xlsx' )
    IS
        t_fh utl_file.file_type;
        t_len PLS_INTEGER := 32767;
    BEGIN
        t_fh :=
            utl_file.fopen ( p_directory
                           , p_filename
                           , 'wb' );

        FOR i IN 0 .. TRUNC ( ( dbms_lob.getlength ( p_blob ) - 1 ) / t_len ) LOOP
            utl_file.put_raw ( t_fh
                             , dbms_lob.SUBSTR ( p_blob
                                               , t_len
                                               , i * t_len + 1 ) );
        END LOOP;

        utl_file.fclose ( t_fh );
    END;

    --
    FUNCTION raw2num ( p_raw RAW
                     , p_len INTEGER
                     , p_pos INTEGER )
        RETURN NUMBER
    IS
    BEGIN
        RETURN utl_raw.cast_to_binary_integer ( utl_raw.SUBSTR ( p_raw
                                                               , p_pos
                                                               , p_len )
                                              , utl_raw.little_endian );
    END;

    --
    FUNCTION little_endian ( p_big NUMBER
                           , p_bytes PLS_INTEGER := 4 )
        RETURN RAW
    IS
    BEGIN
        RETURN utl_raw.SUBSTR ( utl_raw.cast_from_binary_integer ( p_big
                                                                 , utl_raw.little_endian )
                              , 1
                              , p_bytes );
    END;

    --
    FUNCTION blob2num ( p_blob BLOB
                      , p_len INTEGER
                      , p_pos INTEGER )
        RETURN NUMBER
    IS
    BEGIN
        RETURN utl_raw.cast_to_binary_integer ( dbms_lob.SUBSTR ( p_blob
                                                                , p_len
                                                                , p_pos )
                                              , utl_raw.little_endian );
    END;

    --
    PROCEDURE add1file ( p_zipped_blob IN OUT BLOB
                       , p_name VARCHAR2
                       , p_content BLOB )
    IS
        t_now DATE;
        t_blob BLOB;
        t_len INTEGER;
        t_clen INTEGER;
        t_crc32 RAW ( 4 ) := HEXTORAW ( '00000000' );
        t_compressed BOOLEAN := FALSE;
        t_name RAW ( 32767 );
    BEGIN
        t_now := SYSDATE;
        t_len := NVL ( dbms_lob.getlength ( p_content ), 0 );

        IF t_len > 0 THEN
            t_blob := utl_compress.lz_compress ( p_content );
            t_clen := dbms_lob.getlength ( t_blob ) - 18;
            t_compressed := t_clen < t_len;
            t_crc32 :=
                dbms_lob.SUBSTR ( t_blob
                                , 4
                                , t_clen + 11 );
        END IF;

        IF NOT t_compressed THEN
            t_clen := t_len;
            t_blob := p_content;
        END IF;

        IF p_zipped_blob IS NULL THEN
            dbms_lob.createtemporary ( p_zipped_blob
                                     , TRUE );
        END IF;

        t_name :=
            utl_i18n.string_to_raw ( p_name
                                   , 'AL32UTF8' );
        dbms_lob.append ( p_zipped_blob
                        , utl_raw.CONCAT ( c_local_file_header -- Local file header signature
                                         , HEXTORAW ( '1400' ) -- version 2.0
                                         , CASE
                                               WHEN t_name = utl_i18n.string_to_raw ( p_name
                                                                                    , 'US8PC437' ) THEN
                                                   HEXTORAW ( '0000' ) -- no General purpose bits
                                               ELSE
                                                   HEXTORAW ( '0008' ) -- set Language encoding flag (EFS)
                                           END
                                         , CASE WHEN t_compressed THEN HEXTORAW ( '0800' ) -- deflate
                                                                                          ELSE HEXTORAW ( '0000' ) -- stored
                                                                                                                  END
                                         , little_endian (     TO_NUMBER ( TO_CHAR ( t_now
                                                                                   , 'ss' ) )
                                                             / 2
                                                           +   TO_NUMBER ( TO_CHAR ( t_now
                                                                                   , 'mi' ) )
                                                             * 32
                                                           +   TO_NUMBER ( TO_CHAR ( t_now
                                                                                   , 'hh24' ) )
                                                             * 2048
                                                         , 2 ) -- File last modification time
                                         , little_endian (   TO_NUMBER ( TO_CHAR ( t_now
                                                                                 , 'dd' ) )
                                                           +   TO_NUMBER ( TO_CHAR ( t_now
                                                                                   , 'mm' ) )
                                                             * 32
                                                           +   (   TO_NUMBER ( TO_CHAR ( t_now
                                                                                       , 'yyyy' ) )
                                                                 - 1980 )
                                                             * 512
                                                         , 2 ) -- File last modification date
                                         , t_crc32 -- CRC-32
                                         , little_endian ( t_clen ) -- compressed size
                                         , little_endian ( t_len ) -- uncompressed size
                                         , little_endian ( utl_raw.LENGTH ( t_name )
                                                         , 2 ) -- File name length
                                         , HEXTORAW ( '0000' ) -- Extra field length
                                         , t_name -- File name
                                                  ) );

        IF t_compressed THEN
            dbms_lob.COPY ( p_zipped_blob
                          , t_blob
                          , t_clen
                          , dbms_lob.getlength ( p_zipped_blob ) + 1
                          , 11 ); -- compressed content
        ELSIF t_clen > 0 THEN
            dbms_lob.COPY ( p_zipped_blob
                          , t_blob
                          , t_clen
                          , dbms_lob.getlength ( p_zipped_blob ) + 1
                          , 1 ); --  content
        END IF;

        IF dbms_lob.istemporary ( t_blob ) = 1 THEN
            dbms_lob.freetemporary ( t_blob );
        END IF;
    END;

    --
    PROCEDURE finish_zip ( p_zipped_blob IN OUT BLOB )
    IS
        t_cnt PLS_INTEGER := 0;
        t_offs INTEGER;
        t_offs_dir_header INTEGER;
        t_offs_end_header INTEGER;
        t_comment RAW ( 32767 ) := utl_raw.cast_to_raw ( 'Implementation by Anton Scheffer' );
    BEGIN
        t_offs_dir_header := dbms_lob.getlength ( p_zipped_blob );
        t_offs := 1;

        WHILE dbms_lob.SUBSTR ( p_zipped_blob
                              , utl_raw.LENGTH ( c_local_file_header )
                              , t_offs ) = c_local_file_header LOOP
            t_cnt := t_cnt + 1;
            dbms_lob.append ( p_zipped_blob
                            , utl_raw.CONCAT ( HEXTORAW ( '504B0102' ) -- Central directory file header signature
                                             , HEXTORAW ( '1400' ) -- version 2.0
                                             , dbms_lob.SUBSTR ( p_zipped_blob
                                                               , 26
                                                               , t_offs + 4 )
                                             , HEXTORAW ( '0000' ) -- File comment length
                                             , HEXTORAW ( '0000' ) -- Disk number where file starts
                                             , HEXTORAW ( '0000' ) -- Internal file attributes =>
                                             --     0000 binary file
                                             --     0100 (ascii)text file
                                             , CASE
                                                   WHEN dbms_lob.SUBSTR ( p_zipped_blob
                                                                        , 1
                                                                        ,   t_offs
                                                                          + 30
                                                                          + blob2num ( p_zipped_blob
                                                                                     , 2
                                                                                     , t_offs + 26 )
                                                                          - 1 ) IN ( HEXTORAW ( '2F' ) -- /
                                                                                   , HEXTORAW ( '5C' ) -- \
                                                                                                       ) THEN
                                                       HEXTORAW ( '10000000' ) -- a directory/folder
                                                   ELSE
                                                       HEXTORAW ( '2000B681' ) -- a file
                                               END -- External file attributes
                                             , little_endian ( t_offs - 1 ) -- Relative offset of local file header
                                             , dbms_lob.SUBSTR ( p_zipped_blob
                                                               , blob2num ( p_zipped_blob
                                                                          , 2
                                                                          , t_offs + 26 )
                                                               , t_offs + 30 ) -- File name
                                                                               ) );
            t_offs :=
                  t_offs
                + 30
                + blob2num ( p_zipped_blob
                           , 4
                           , t_offs + 18 ) -- compressed size
                + blob2num ( p_zipped_blob
                           , 2
                           , t_offs + 26 ) -- File name length
                + blob2num ( p_zipped_blob
                           , 2
                           , t_offs + 28 ); -- Extra field length
        END LOOP;

        t_offs_end_header := dbms_lob.getlength ( p_zipped_blob );
        dbms_lob.append ( p_zipped_blob
                        , utl_raw.CONCAT ( c_end_of_central_directory -- End of central directory signature
                                         , HEXTORAW ( '0000' ) -- Number of this disk
                                         , HEXTORAW ( '0000' ) -- Disk where central directory starts
                                         , little_endian ( t_cnt
                                                         , 2 ) -- Number of central directory records on this disk
                                         , little_endian ( t_cnt
                                                         , 2 ) -- Total number of central directory records
                                         , little_endian ( t_offs_end_header - t_offs_dir_header ) -- Size of central directory
                                         , little_endian ( t_offs_dir_header ) -- Offset of start of central directory, relative to start of archive
                                         , little_endian ( NVL ( utl_raw.LENGTH ( t_comment ), 0 )
                                                         , 2 ) -- ZIP file comment length
                                         , t_comment ) );
    END;

    --
    FUNCTION alfan_col ( p_col PLS_INTEGER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE
                   WHEN p_col > 702 THEN
                          CHR ( 64 + TRUNC ( ( p_col - 27 ) / 676 ) )
                       || CHR (   65
                                + MOD ( TRUNC ( ( p_col - 1 ) / 26 ) - 1
                                      , 26 ) )
                       || CHR (   65
                                + MOD ( p_col - 1
                                      , 26 ) )
                   WHEN p_col > 26 THEN
                          CHR ( 64 + TRUNC ( ( p_col - 1 ) / 26 ) )
                       || CHR (   65
                                + MOD ( p_col - 1
                                      , 26 ) )
                   ELSE
                       CHR ( 64 + p_col )
               END;
    END;

    --
    FUNCTION col_alfan ( p_col VARCHAR2 )
        RETURN PLS_INTEGER
    IS
    BEGIN
        RETURN   ASCII ( SUBSTR ( p_col
                                , -1 ) )
               - 64
               + NVL (   (   ASCII ( SUBSTR ( p_col
                                            , -2
                                            , 1 ) )
                           - 64 )
                       * 26
                     , 0 )
               + NVL (   (   ASCII ( SUBSTR ( p_col
                                            , -3
                                            , 1 ) )
                           - 64 )
                       * 676
                     , 0 );
    END;

    --
    PROCEDURE clear_workbook
    IS
        t_row_ind PLS_INTEGER;
    BEGIN
        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            t_row_ind := workbook.sheets ( s ).rows.FIRST ( );

            WHILE t_row_ind IS NOT NULL LOOP
                workbook.sheets ( s ).rows ( t_row_ind ).delete ( );
                t_row_ind := workbook.sheets ( s ).rows.NEXT ( t_row_ind );
            END LOOP;

            workbook.sheets ( s ).rows.delete ( );
            workbook.sheets ( s ).widths.delete ( );
            workbook.sheets ( s ).autofilters.delete ( );
            workbook.sheets ( s ).hyperlinks.delete ( );
            workbook.sheets ( s ).col_fmts.delete ( );
            workbook.sheets ( s ).row_fmts.delete ( );
            workbook.sheets ( s ).comments.delete ( );
            workbook.sheets ( s ).mergecells.delete ( );
            workbook.sheets ( s ).validations.delete ( );
        END LOOP;

        workbook.strings.delete ( );
        workbook.str_ind.delete ( );
        workbook.fonts.delete ( );
        workbook.fills.delete ( );
        workbook.borders.delete ( );
        workbook.numfmts.delete ( );
        workbook.cellxfs.delete ( );
        workbook.defined_names.delete ( );
        workbook := NULL;
    END;

    --
    PROCEDURE new_sheet ( p_sheetname VARCHAR2 := NULL )
    IS
        t_nr PLS_INTEGER := workbook.sheets.COUNT ( ) + 1;
        t_ind PLS_INTEGER;
    BEGIN
        workbook.sheets ( t_nr ).name :=
            NVL ( dbms_xmlgen.CONVERT ( TRANSLATE ( p_sheetname
                                                  , 'a/\[]*:?'
                                                  , 'a' ) )
                , 'Sheet' || t_nr );

        IF workbook.strings.COUNT ( ) = 0 THEN
            workbook.str_cnt := 0;
        END IF;

        IF workbook.fonts.COUNT ( ) = 0 THEN
            t_ind := get_font ( 'Calibri' );
        END IF;

        IF workbook.fills.COUNT ( ) = 0 THEN
            t_ind := get_fill ( 'none' );
            t_ind := get_fill ( 'gray125' );
        END IF;

        IF workbook.borders.COUNT ( ) = 0 THEN
            t_ind :=
                get_border ( ''
                           , ''
                           , ''
                           , '' );
        END IF;
    END;

    --
    PROCEDURE set_col_width ( p_sheet PLS_INTEGER
                            , p_col PLS_INTEGER
                            , p_format VARCHAR2 )
    IS
        t_width NUMBER;
        t_nr_chr PLS_INTEGER;
    BEGIN
        IF p_format IS NULL THEN
            RETURN;
        END IF;

        IF INSTR ( p_format
                 , ';' ) > 0 THEN
            t_nr_chr :=
                LENGTH ( TRANSLATE ( SUBSTR ( p_format
                                            , 1
                                            ,   INSTR ( p_format
                                                      , ';' )
                                              - 1 )
                                   , 'a\"'
                                   , 'a' ) );
        ELSE
            t_nr_chr :=
                LENGTH ( TRANSLATE ( p_format
                                   , 'a\"'
                                   , 'a' ) );
        END IF;

        t_width := TRUNC ( ( t_nr_chr * 7 + 5 ) / 7 * 256 ) / 256; -- assume default 11 point Calibri

        IF workbook.sheets ( p_sheet ).widths.EXISTS ( p_col ) THEN
            IF ( workbook.sheets ( p_sheet ).widths ( p_col ) IS NULL
             OR workbook.sheets ( p_sheet ).widths ( p_col ) <= 0 ) THEN
                workbook.sheets ( p_sheet ).widths ( p_col ) :=
                    GREATEST ( workbook.sheets ( p_sheet ).widths ( p_col )
                             , t_width );
            END IF;
        ELSE
            workbook.sheets ( p_sheet ).widths ( p_col ) :=
                GREATEST ( t_width
                         , 8.43 );
        END IF;
    END;

    --
    FUNCTION orafmt2excel ( p_format VARCHAR2 := NULL )
        RETURN VARCHAR2
    IS
        t_format VARCHAR2 ( 1000 )
            := SUBSTR ( p_format
                      , 1
                      , 1000 );
    BEGIN
        t_format :=
            REPLACE ( REPLACE ( t_format
                              , 'hh24'
                              , 'hh' )
                    , 'hh12'
                    , 'hh' );
        t_format :=
            REPLACE ( t_format
                    , 'mi'
                    , 'mm' );
        t_format :=
            REPLACE ( REPLACE ( REPLACE ( t_format
                                        , 'AM'
                                        , '~~' )
                              , 'PM'
                              , '~~' )
                    , '~~'
                    , 'AM/PM' );
        t_format :=
            REPLACE ( REPLACE ( REPLACE ( t_format
                                        , 'am'
                                        , '~~' )
                              , 'pm'
                              , '~~' )
                    , '~~'
                    , 'AM/PM' );
        t_format :=
            REPLACE ( REPLACE ( t_format
                              , 'day'
                              , 'DAY' )
                    , 'DAY'
                    , 'dddd' );
        t_format :=
            REPLACE ( REPLACE ( t_format
                              , 'dy'
                              , 'DY' )
                    , 'DAY'
                    , 'ddd' );
        t_format :=
            REPLACE ( REPLACE ( t_format
                              , 'RR'
                              , 'RR' )
                    , 'RR'
                    , 'YY' );
        t_format :=
            REPLACE ( REPLACE ( t_format
                              , 'month'
                              , 'MONTH' )
                    , 'MONTH'
                    , 'mmmm' );
        t_format :=
            REPLACE ( REPLACE ( t_format
                              , 'mon'
                              , 'MON' )
                    , 'MON'
                    , 'mmm' );
        RETURN t_format;
    END;

    --
    FUNCTION get_numfmt ( p_format VARCHAR2 := NULL )
        RETURN PLS_INTEGER
    IS
        t_cnt PLS_INTEGER;
        t_numfmtid PLS_INTEGER;
    BEGIN
        IF p_format IS NULL THEN
            RETURN 0;
        END IF;

        t_cnt := workbook.numfmts.COUNT ( );

        FOR i IN 1 .. t_cnt LOOP
            IF workbook.numfmts ( i ).formatcode = p_format THEN
                t_numfmtid := workbook.numfmts ( i ).numfmtid;
                EXIT;
            END IF;
        END LOOP;

        IF t_numfmtid IS NULL THEN
            t_numfmtid := CASE WHEN t_cnt = 0 THEN 164 ELSE workbook.numfmts ( t_cnt ).numfmtid + 1 END;
            t_cnt := t_cnt + 1;
            workbook.numfmts ( t_cnt ).numfmtid := t_numfmtid;
            workbook.numfmts ( t_cnt ).formatcode := p_format;
            workbook.numfmtindexes ( t_numfmtid ) := t_cnt;
        END IF;

        RETURN t_numfmtid;
    END;

    --
    FUNCTION get_font ( p_name VARCHAR2
                      , p_family PLS_INTEGER := 2
                      , p_fontsize NUMBER := 11
                      , p_theme PLS_INTEGER := 1
                      , p_underline BOOLEAN := FALSE
                      , p_italic BOOLEAN := FALSE
                      , p_bold BOOLEAN := FALSE
                      , p_rgb VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
                                               )
        RETURN PLS_INTEGER
    IS
        t_ind PLS_INTEGER;
    BEGIN
        IF workbook.fonts.COUNT ( ) > 0 THEN
            FOR f IN 0 .. workbook.fonts.COUNT ( ) - 1 LOOP
                IF ( workbook.fonts ( f ).name = p_name
                AND workbook.fonts ( f ).family = p_family
                AND workbook.fonts ( f ).fontsize = p_fontsize
                AND workbook.fonts ( f ).theme = p_theme
                AND workbook.fonts ( f ).underline = p_underline
                AND workbook.fonts ( f ).italic = p_italic
                AND workbook.fonts ( f ).bold = p_bold
                AND ( workbook.fonts ( f ).rgb = p_rgb
                  OR ( workbook.fonts ( f ).rgb IS NULL
                  AND p_rgb IS NULL ) ) ) THEN
                    RETURN f;
                END IF;
            END LOOP;
        END IF;

        t_ind := workbook.fonts.COUNT ( );
        workbook.fonts ( t_ind ).name := p_name;
        workbook.fonts ( t_ind ).family := p_family;
        workbook.fonts ( t_ind ).fontsize := p_fontsize;
        workbook.fonts ( t_ind ).theme := p_theme;
        workbook.fonts ( t_ind ).underline := p_underline;
        workbook.fonts ( t_ind ).italic := p_italic;
        workbook.fonts ( t_ind ).bold := p_bold;
        workbook.fonts ( t_ind ).rgb := p_rgb;
        RETURN t_ind;
    END;

    --
    FUNCTION get_fill ( p_patterntype VARCHAR2
                      , p_fgrgb VARCHAR2 := NULL )
        RETURN PLS_INTEGER
    IS
        t_ind PLS_INTEGER;
    BEGIN
        IF workbook.fills.COUNT ( ) > 0 THEN
            FOR f IN 0 .. workbook.fills.COUNT ( ) - 1 LOOP
                IF ( workbook.fills ( f ).patterntype = p_patterntype
                AND NVL ( workbook.fills ( f ).fgrgb, 'x' ) = NVL ( UPPER ( p_fgrgb ), 'x' ) ) THEN
                    RETURN f;
                END IF;
            END LOOP;
        END IF;

        t_ind := workbook.fills.COUNT ( );
        workbook.fills ( t_ind ).patterntype := p_patterntype;
        workbook.fills ( t_ind ).fgrgb := UPPER ( p_fgrgb );
        RETURN t_ind;
    END;

    --
    FUNCTION get_border ( p_top VARCHAR2 := 'thin'
                        , p_bottom VARCHAR2 := 'thin'
                        , p_left VARCHAR2 := 'thin'
                        , p_right VARCHAR2 := 'thin' )
        RETURN PLS_INTEGER
    IS
        t_ind PLS_INTEGER;
    BEGIN
        IF workbook.borders.COUNT ( ) > 0 THEN
            FOR b IN 0 .. workbook.borders.COUNT ( ) - 1 LOOP
                IF ( NVL ( workbook.borders ( b ).top, 'x' ) = NVL ( p_top, 'x' )
                AND NVL ( workbook.borders ( b ).bottom, 'x' ) = NVL ( p_bottom, 'x' )
                AND NVL ( workbook.borders ( b ).left, 'x' ) = NVL ( p_left, 'x' )
                AND NVL ( workbook.borders ( b ).right, 'x' ) = NVL ( p_right, 'x' ) ) THEN
                    RETURN b;
                END IF;
            END LOOP;
        END IF;

        t_ind := workbook.borders.COUNT ( );
        workbook.borders ( t_ind ).top := p_top;
        workbook.borders ( t_ind ).bottom := p_bottom;
        workbook.borders ( t_ind ).left := p_left;
        workbook.borders ( t_ind ).right := p_right;
        RETURN t_ind;
    END;

    --
    FUNCTION get_alignment ( p_vertical VARCHAR2 := NULL
                           , p_horizontal VARCHAR2 := NULL
                           , p_wraptext BOOLEAN := NULL )
        RETURN tp_alignment
    IS
        t_rv tp_alignment;
    BEGIN
        t_rv.vertical := p_vertical;
        t_rv.horizontal := p_horizontal;
        t_rv.wraptext := p_wraptext;
        RETURN t_rv;
    END;

    --
    FUNCTION get_xfid ( p_sheet PLS_INTEGER
                      , p_col PLS_INTEGER
                      , p_row PLS_INTEGER
                      , p_numfmtid PLS_INTEGER := NULL
                      , p_fontid PLS_INTEGER := NULL
                      , p_fillid PLS_INTEGER := NULL
                      , p_borderid PLS_INTEGER := NULL
                      , p_alignment tp_alignment := NULL )
        RETURN VARCHAR2
    IS
        t_cnt PLS_INTEGER;
        t_xfid PLS_INTEGER;
        t_xf tp_xf_fmt;
        t_col_xf tp_xf_fmt;
        t_row_xf tp_xf_fmt;
    BEGIN
        IF workbook.sheets ( p_sheet ).col_fmts.EXISTS ( p_col ) THEN
            t_col_xf := workbook.sheets ( p_sheet ).col_fmts ( p_col );
        END IF;

        IF workbook.sheets ( p_sheet ).row_fmts.EXISTS ( p_row ) THEN
            t_row_xf := workbook.sheets ( p_sheet ).row_fmts ( p_row );
        END IF;

        t_xf.numfmtid :=
            COALESCE ( p_numfmtid
                     , t_col_xf.numfmtid
                     , t_row_xf.numfmtid
                     , 0 );
        t_xf.fontid :=
            COALESCE ( p_fontid
                     , t_col_xf.fontid
                     , t_row_xf.fontid
                     , 0 );
        t_xf.fillid :=
            COALESCE ( p_fillid
                     , t_col_xf.fillid
                     , t_row_xf.fillid
                     , 0 );
        t_xf.borderid :=
            COALESCE ( p_borderid
                     , t_col_xf.borderid
                     , t_row_xf.borderid
                     , 0 );
        t_xf.alignment :=
            COALESCE ( p_alignment
                     , t_col_xf.alignment
                     , t_row_xf.alignment );

        IF ( t_xf.numfmtid + t_xf.fontid + t_xf.fillid + t_xf.borderid = 0
        AND t_xf.alignment.vertical IS NULL
        AND t_xf.alignment.horizontal IS NULL
        AND NOT NVL ( t_xf.alignment.wraptext, FALSE ) ) THEN
            RETURN '';
        END IF;

        IF ( t_xf.numfmtid > 0
        AND workbook.numfmtindexes.EXISTS ( t_xf.numfmtid ) ) THEN
            set_col_width ( p_sheet
                          , p_col
                          , workbook.numfmts ( workbook.numfmtindexes ( t_xf.numfmtid ) ).formatcode );
        END IF;

        t_cnt := workbook.cellxfs.COUNT ( );

        FOR i IN 1 .. t_cnt LOOP
            IF ( workbook.cellxfs ( i ).numfmtid = t_xf.numfmtid
            AND workbook.cellxfs ( i ).fontid = t_xf.fontid
            AND workbook.cellxfs ( i ).fillid = t_xf.fillid
            AND workbook.cellxfs ( i ).borderid = t_xf.borderid
            AND NVL ( workbook.cellxfs ( i ).alignment.vertical, 'x' ) = NVL ( t_xf.alignment.vertical, 'x' )
            AND NVL ( workbook.cellxfs ( i ).alignment.horizontal, 'x' ) = NVL ( t_xf.alignment.horizontal, 'x' )
            AND NVL ( workbook.cellxfs ( i ).alignment.wraptext, FALSE ) = NVL ( t_xf.alignment.wraptext, FALSE ) ) THEN
                t_xfid := i;
                EXIT;
            END IF;
        END LOOP;

        IF t_xfid IS NULL THEN
            t_cnt := t_cnt + 1;
            t_xfid := t_cnt;
            workbook.cellxfs ( t_cnt ) := t_xf;
        END IF;

        RETURN 's="' || t_xfid || '"';
    END;

    --
    PROCEDURE cell ( p_col PLS_INTEGER
                   , p_row PLS_INTEGER
                   , p_value NUMBER
                   , p_numfmtid PLS_INTEGER := NULL
                   , p_fontid PLS_INTEGER := NULL
                   , p_fillid PLS_INTEGER := NULL
                   , p_borderid PLS_INTEGER := NULL
                   , p_alignment tp_alignment := NULL
                   , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).VALUE := p_value;
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).style := NULL;
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).style :=
            get_xfid ( t_sheet
                     , p_col
                     , p_row
                     , p_numfmtid
                     , p_fontid
                     , p_fillid
                     , p_borderid
                     , p_alignment );
    END;

    --
    FUNCTION add_string ( p_string VARCHAR2 )
        RETURN PLS_INTEGER
    IS
        t_cnt PLS_INTEGER;
    BEGIN
        IF ( p_string IS NULL ) THEN
            RETURN NULL;
        END IF;

        IF workbook.strings.EXISTS ( p_string ) THEN
            t_cnt := workbook.strings ( p_string );
        ELSE
            t_cnt := workbook.strings.COUNT ( );
            workbook.str_ind ( t_cnt ) := p_string;
            workbook.strings ( NVL ( p_string, '' ) ) := t_cnt;
        END IF;

        workbook.str_cnt := workbook.str_cnt + 1;
        RETURN t_cnt;
    END;

    --
    PROCEDURE cell ( p_col PLS_INTEGER
                   , p_row PLS_INTEGER
                   , p_value VARCHAR2
                   , p_numfmtid PLS_INTEGER := NULL
                   , p_fontid PLS_INTEGER := NULL
                   , p_fillid PLS_INTEGER := NULL
                   , p_borderid PLS_INTEGER := NULL
                   , p_alignment tp_alignment := NULL
                   , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
        t_alignment tp_alignment := p_alignment;
    BEGIN
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).VALUE := add_string ( NVL ( p_value, '' ) );

        IF t_alignment.wraptext IS NULL
       AND INSTR ( p_value
                 , CHR ( 13 ) ) > 0 THEN
            t_alignment.wraptext := TRUE;
        END IF;

        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).style :=
               't="s" '
            || get_xfid ( t_sheet
                        , p_col
                        , p_row
                        , p_numfmtid
                        , p_fontid
                        , p_fillid
                        , p_borderid
                        , t_alignment );
    END;

    --
    PROCEDURE cell ( p_col PLS_INTEGER
                   , p_row PLS_INTEGER
                   , p_value DATE
                   , p_numfmtid PLS_INTEGER := NULL
                   , p_fontid PLS_INTEGER := NULL
                   , p_fillid PLS_INTEGER := NULL
                   , p_borderid PLS_INTEGER := NULL
                   , p_alignment tp_alignment := NULL
                   , p_sheet PLS_INTEGER := NULL )
    IS
        t_numfmtid PLS_INTEGER := p_numfmtid;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).VALUE :=
              p_value
            - TO_DATE ( '01-01-1904'
                      , 'DD-MM-YYYY' );

        IF t_numfmtid IS NULL
       AND NOT ( workbook.sheets ( t_sheet ).col_fmts.EXISTS ( p_col )
            AND workbook.sheets ( t_sheet ).col_fmts ( p_col ).numfmtid IS NOT NULL )
       AND NOT ( workbook.sheets ( t_sheet ).row_fmts.EXISTS ( p_row )
            AND workbook.sheets ( t_sheet ).row_fmts ( p_row ).numfmtid IS NOT NULL ) THEN
            t_numfmtid := get_numfmt ( 'dd/mm/yyyy' );
        END IF;

        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).style :=
            get_xfid ( t_sheet
                     , p_col
                     , p_row
                     , t_numfmtid
                     , p_fontid
                     , p_fillid
                     , p_borderid
                     , p_alignment );
    END;

    --
    PROCEDURE hyperlink ( p_col PLS_INTEGER
                        , p_row PLS_INTEGER
                        , p_url VARCHAR2
                        , p_value VARCHAR2 := NULL
                        , p_sheet PLS_INTEGER := NULL )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).VALUE := add_string ( NVL ( p_value, p_url ) );
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).style :=
               't="s" '
            || get_xfid ( t_sheet
                        , p_col
                        , p_row
                        , ''
                        , get_font ( 'Calibri'
                                   , p_theme => 10
                                   , p_underline => TRUE ) );
        t_ind := workbook.sheets ( t_sheet ).hyperlinks.COUNT ( ) + 1;
        workbook.sheets ( t_sheet ).hyperlinks ( t_ind ).cell := alfan_col ( p_col ) || p_row;
        workbook.sheets ( t_sheet ).hyperlinks ( t_ind ).url := p_url;
    END;

    --
    PROCEDURE hyperlink_loc ( p_col PLS_INTEGER
                            , p_row PLS_INTEGER
                            , p_location VARCHAR2 )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := workbook.sheets.COUNT ( );
    BEGIN
        workbook.sheets ( t_sheet ).rows ( p_row ) ( p_col ).style :=
               't="s" '
            || get_xfid ( t_sheet
                        , p_col
                        , p_row
                        , ''
                        , get_font ( 'Calibri'
                                   , p_theme => 10
                                   , p_underline => TRUE ) );
        t_ind := workbook.sheets ( t_sheet ).hyperlinks.COUNT ( ) + 1;
        workbook.sheets ( t_sheet ).hyperlinks ( t_ind ).cell := alfan_col ( p_col ) || p_row;
        workbook.sheets ( t_sheet ).hyperlinks ( t_ind ).location := p_location;
    END;

    --
    PROCEDURE comment ( p_col PLS_INTEGER
                      , p_row PLS_INTEGER
                      , p_text VARCHAR2
                      , p_author VARCHAR2 := NULL
                      , p_width PLS_INTEGER := 150
                      , p_height PLS_INTEGER := 100
                      , p_sheet PLS_INTEGER := NULL )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        t_ind := workbook.sheets ( t_sheet ).comments.COUNT ( ) + 1;
        workbook.sheets ( t_sheet ).comments ( t_ind ).row := p_row;
        workbook.sheets ( t_sheet ).comments ( t_ind ).column := p_col;
        workbook.sheets ( t_sheet ).comments ( t_ind ).text := dbms_xmlgen.CONVERT ( p_text );
        workbook.sheets ( t_sheet ).comments ( t_ind ).author := dbms_xmlgen.CONVERT ( p_author );
        workbook.sheets ( t_sheet ).comments ( t_ind ).width := p_width;
        workbook.sheets ( t_sheet ).comments ( t_ind ).height := p_height;
    END;

    --
    PROCEDURE mergecells ( p_tl_col PLS_INTEGER -- top left
                         , p_tl_row PLS_INTEGER
                         , p_br_col PLS_INTEGER -- bottom right
                         , p_br_row PLS_INTEGER
                         , p_sheet PLS_INTEGER := NULL )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        t_ind := workbook.sheets ( t_sheet ).mergecells.COUNT ( ) + 1;
        workbook.sheets ( t_sheet ).mergecells ( t_ind ) :=
            alfan_col ( p_tl_col ) || p_tl_row || ':' || alfan_col ( p_br_col ) || p_br_row;
    END;

    --
    PROCEDURE add_validation ( p_type VARCHAR2
                             , p_sqref VARCHAR2
                             , p_style VARCHAR2 := 'stop' -- stop, warning, information
                             , p_formula1 VARCHAR2 := NULL
                             , p_formula2 VARCHAR2 := NULL
                             , p_title VARCHAR2 := NULL
                             , p_prompt VARCHAR := NULL
                             , p_show_error BOOLEAN := FALSE
                             , p_error_title VARCHAR2 := NULL
                             , p_error_txt VARCHAR2 := NULL
                             , p_sheet PLS_INTEGER := NULL )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        t_ind := workbook.sheets ( t_sheet ).validations.COUNT ( ) + 1;
        workbook.sheets ( t_sheet ).validations ( t_ind ).TYPE := p_type;
        workbook.sheets ( t_sheet ).validations ( t_ind ).errorstyle := p_style;
        workbook.sheets ( t_sheet ).validations ( t_ind ).sqref := p_sqref;
        workbook.sheets ( t_sheet ).validations ( t_ind ).formula1 := p_formula1;
        workbook.sheets ( t_sheet ).validations ( t_ind ).error_title := p_error_title;
        workbook.sheets ( t_sheet ).validations ( t_ind ).error_txt := p_error_txt;
        workbook.sheets ( t_sheet ).validations ( t_ind ).title := p_title;
        workbook.sheets ( t_sheet ).validations ( t_ind ).prompt := p_prompt;
        workbook.sheets ( t_sheet ).validations ( t_ind ).showerrormessage := p_show_error;
    END;

    --
    PROCEDURE list_validation ( p_sqref_col PLS_INTEGER
                              , p_sqref_row PLS_INTEGER
                              , p_tl_col PLS_INTEGER -- top left
                              , p_tl_row PLS_INTEGER
                              , p_br_col PLS_INTEGER -- bottom right
                              , p_br_row PLS_INTEGER
                              , p_style VARCHAR2 := 'stop' -- stop, warning, information
                              , p_title VARCHAR2 := NULL
                              , p_prompt VARCHAR := NULL
                              , p_show_error BOOLEAN := FALSE
                              , p_error_title VARCHAR2 := NULL
                              , p_error_txt VARCHAR2 := NULL
                              , p_sheet PLS_INTEGER := NULL )
    IS
    BEGIN
        add_validation (
                         'list'
                       , alfan_col ( p_sqref_col ) || p_sqref_row
                       , p_style => LOWER ( p_style )
                       , p_formula1 =>    '$'
                                       || alfan_col ( p_tl_col )
                                       || '$'
                                       || p_tl_row
                                       || ':$'
                                       || alfan_col ( p_br_col )
                                       || '$'
                                       || p_br_row
                       , p_title => p_title
                       , p_prompt => p_prompt
                       , p_show_error => p_show_error
                       , p_error_title => p_error_title
                       , p_error_txt => p_error_txt
                       , p_sheet => p_sheet
        );
    END;

    --
    PROCEDURE list_validation ( p_sqref_col PLS_INTEGER
                              , p_sqref_row PLS_INTEGER
                              , p_defined_name VARCHAR2
                              , p_style VARCHAR2 := 'stop' -- stop, warning, information
                              , p_title VARCHAR2 := NULL
                              , p_prompt VARCHAR := NULL
                              , p_show_error BOOLEAN := FALSE
                              , p_error_title VARCHAR2 := NULL
                              , p_error_txt VARCHAR2 := NULL
                              , p_sheet PLS_INTEGER := NULL )
    IS
    BEGIN
        add_validation ( 'list'
                       , alfan_col ( p_sqref_col ) || p_sqref_row
                       , p_style => LOWER ( p_style )
                       , p_formula1 => p_defined_name
                       , p_title => p_title
                       , p_prompt => p_prompt
                       , p_show_error => p_show_error
                       , p_error_title => p_error_title
                       , p_error_txt => p_error_txt
                       , p_sheet => p_sheet );
    END;

    --
    PROCEDURE defined_name ( p_tl_col PLS_INTEGER -- top left
                           , p_tl_row PLS_INTEGER
                           , p_br_col PLS_INTEGER -- bottom right
                           , p_br_row PLS_INTEGER
                           , p_name VARCHAR2
                           , p_sheet PLS_INTEGER := NULL
                           , p_localsheet PLS_INTEGER := NULL )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
        t_sheet_name VARCHAR ( 100 );
    BEGIN
        IF ( workbook.sheets.EXISTS ( workbook.sheets.COUNT )
        AND workbook.sheets ( workbook.sheets.COUNT ).name IS NOT NULL ) THEN
            t_sheet_name := workbook.sheets ( workbook.sheets.COUNT ).name;
        ELSE
            t_sheet_name := 'Sheet' || t_sheet;
        END IF;

        t_sheet_name := '''' || t_sheet_name || '''';

        t_ind := workbook.defined_names.COUNT ( ) + 1;
        workbook.defined_names ( t_ind ).name := p_name;
        workbook.defined_names ( t_ind ).REF :=
               t_sheet_name
            || '!$'
            || alfan_col ( p_tl_col )
            || '$'
            || p_tl_row
            || ':$'
            || alfan_col ( p_br_col )
            || '$'
            || p_br_row;
        workbook.defined_names ( t_ind ).sheet := p_localsheet;
    END;

    --
    PROCEDURE set_column_width ( p_col PLS_INTEGER
                               , p_width NUMBER
                               , p_sheet PLS_INTEGER := NULL )
    IS
    BEGIN
        workbook.sheets ( NVL ( p_sheet, workbook.sheets.COUNT ( ) ) ).widths ( p_col ) := p_width;
    END;

    --
    PROCEDURE set_column ( p_col PLS_INTEGER
                         , p_numfmtid PLS_INTEGER := NULL
                         , p_fontid PLS_INTEGER := NULL
                         , p_fillid PLS_INTEGER := NULL
                         , p_borderid PLS_INTEGER := NULL
                         , p_alignment tp_alignment := NULL
                         , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).col_fmts ( p_col ).numfmtid := p_numfmtid;
        workbook.sheets ( t_sheet ).col_fmts ( p_col ).fontid := p_fontid;
        workbook.sheets ( t_sheet ).col_fmts ( p_col ).fillid := p_fillid;
        workbook.sheets ( t_sheet ).col_fmts ( p_col ).borderid := p_borderid;
        workbook.sheets ( t_sheet ).col_fmts ( p_col ).alignment := p_alignment;
    END;

    --
    PROCEDURE set_row_height ( p_row PLS_INTEGER
                             , p_height NUMBER
                             , p_sheet PLS_INTEGER := NULL )
    IS
    BEGIN
        workbook.sheets ( NVL ( p_sheet, workbook.sheets.COUNT ( ) ) ).heights ( p_row ) := p_height;
    END;

    --
    PROCEDURE set_row ( p_row PLS_INTEGER
                      , p_numfmtid PLS_INTEGER := NULL
                      , p_fontid PLS_INTEGER := NULL
                      , p_fillid PLS_INTEGER := NULL
                      , p_borderid PLS_INTEGER := NULL
                      , p_alignment tp_alignment := NULL
                      , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).row_fmts ( p_row ).numfmtid := p_numfmtid;
        workbook.sheets ( t_sheet ).row_fmts ( p_row ).fontid := p_fontid;
        workbook.sheets ( t_sheet ).row_fmts ( p_row ).fillid := p_fillid;
        workbook.sheets ( t_sheet ).row_fmts ( p_row ).borderid := p_borderid;
        workbook.sheets ( t_sheet ).row_fmts ( p_row ).alignment := p_alignment;
    END;

    --
    PROCEDURE freeze_rows ( p_nr_rows PLS_INTEGER := 1
                          , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).freeze_cols := NULL;
        workbook.sheets ( t_sheet ).freeze_rows := p_nr_rows;
    END;

    --
    PROCEDURE freeze_cols ( p_nr_cols PLS_INTEGER := 1
                          , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).freeze_rows := NULL;
        workbook.sheets ( t_sheet ).freeze_cols := p_nr_cols;
    END;

    --
    PROCEDURE freeze_pane ( p_col PLS_INTEGER
                          , p_row PLS_INTEGER
                          , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        workbook.sheets ( t_sheet ).freeze_rows := p_row;
        workbook.sheets ( t_sheet ).freeze_cols := p_col;
    END;

    --
    PROCEDURE set_autofilter ( p_column_start PLS_INTEGER := NULL
                             , p_column_end PLS_INTEGER := NULL
                             , p_row_start PLS_INTEGER := NULL
                             , p_row_end PLS_INTEGER := NULL
                             , p_sheet PLS_INTEGER := NULL )
    IS
        t_ind PLS_INTEGER;
        t_sheet PLS_INTEGER := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
    BEGIN
        t_ind := 1;
        workbook.sheets ( t_sheet ).autofilters ( t_ind ).column_start := p_column_start;
        workbook.sheets ( t_sheet ).autofilters ( t_ind ).column_end := p_column_end;
        workbook.sheets ( t_sheet ).autofilters ( t_ind ).row_start := p_row_start;
        workbook.sheets ( t_sheet ).autofilters ( t_ind ).row_end := p_row_end;
        defined_name ( p_column_start
                     , p_row_start
                     , p_column_end
                     , p_row_end
                     , '_xlnm._FilterDatabase'
                     , t_sheet
                     , t_sheet - 1 );
    END;

    --
    /*
      procedure add1xml
        ( p_excel in out nocopy blob
        , p_filename varchar2
        , p_xml clob
        )
      is
        t_tmp blob;
        c_step constant number := 24396;
      begin
        dbms_lob.createtemporary( t_tmp, true );
        for i in 0 .. trunc( length( p_xml ) / c_step )
        loop
          dbms_lob.append( t_tmp, utl_i18n.string_to_raw( substr( p_xml, i * c_step + 1, c_step ), 'AL32UTF8' ) );
        end loop;
        add1file( p_excel, p_filename, t_tmp );
        dbms_lob.freetemporary( t_tmp );
      end;
    */
    --
    PROCEDURE add1xml ( p_excel IN OUT NOCOPY BLOB
                      , p_filename    VARCHAR2
                      , p_xml         CLOB )
    IS
        t_tmp BLOB;
        dest_offset INTEGER := 1;
        src_offset INTEGER := 1;
        lang_context INTEGER;
        warning INTEGER;
    BEGIN
        lang_context := dbms_lob.default_lang_ctx;
        dbms_lob.createtemporary ( t_tmp
                                 , TRUE );
        dbms_lob.converttoblob ( t_tmp
                               , p_xml
                               , dbms_lob.lobmaxsize
                               , dest_offset
                               , src_offset
                               , NLS_CHARSET_ID ( 'AL32UTF8' )
                               , lang_context
                               , warning );
        add1file ( p_excel
                 , p_filename
                 , t_tmp );
        dbms_lob.freetemporary ( t_tmp );
    END;

    --
    FUNCTION finish
        RETURN BLOB
    IS
        t_excel BLOB;
        t_xxx CLOB;
        t_tmp VARCHAR2 ( 32767 CHAR );
        t_str VARCHAR2 ( 32767 CHAR );
        t_c NUMBER;
        t_h NUMBER;
        t_w NUMBER;
        t_cw NUMBER;
        t_cell VARCHAR2 ( 1000 CHAR );
        t_row_ind PLS_INTEGER;
        t_col_min PLS_INTEGER;
        t_col_max PLS_INTEGER;
        t_col_ind PLS_INTEGER;
        t_len PLS_INTEGER;
        ts TIMESTAMP := SYSTIMESTAMP;
        t_row_height VARCHAR2 ( 100 );
    BEGIN
        dbms_lob.createtemporary ( t_excel
                                 , TRUE );
        t_xxx :=
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Default Extension="vml" ContentType="application/vnd.openxmlformats-officedocument.vmlDrawing"/>
<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>';

        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            t_xxx :=
                   t_xxx
                || '
<Override PartName="/xl/worksheets/sheet'
                || s
                || '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>';
        END LOOP;

        t_xxx :=
               t_xxx
            || '
<Override PartName="/xl/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>';

        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            IF workbook.sheets ( s ).comments.COUNT ( ) > 0 THEN
                t_xxx :=
                       t_xxx
                    || '
<Override PartName="/xl/comments'
                    || s
                    || '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml"/>';
            END IF;
        END LOOP;

        t_xxx := t_xxx || '
</Types>';
        add1xml ( t_excel
                , '[Content_Types].xml'
                , t_xxx );
        t_xxx :=
               '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<dc:creator>'
            || SYS_CONTEXT ( 'userenv'
                           , 'os_user' )
            || '</dc:creator>
<cp:lastModifiedBy>'
            || SYS_CONTEXT ( 'userenv'
                           , 'os_user' )
            || '</cp:lastModifiedBy>
<dcterms:created xsi:type="dcterms:W3CDTF">'
            || TO_CHAR ( CURRENT_TIMESTAMP
                       , 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM' )
            || '</dcterms:created>
<dcterms:modified xsi:type="dcterms:W3CDTF">'
            || TO_CHAR ( CURRENT_TIMESTAMP
                       , 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM' )
            || '</dcterms:modified>
</cp:coreProperties>';
        add1xml ( t_excel
                , 'docProps/core.xml'
                , t_xxx );
        t_xxx :=
               '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
<Application>Microsoft Excel</Application>
<DocSecurity>0</DocSecurity>
<ScaleCrop>false</ScaleCrop>
<HeadingPairs>
<vt:vector size="2" baseType="variant">
<vt:variant>
<vt:lpstr>Worksheets</vt:lpstr>
</vt:variant>
<vt:variant>
<vt:i4>'
            || workbook.sheets.COUNT ( )
            || '</vt:i4>
</vt:variant>
</vt:vector>
</HeadingPairs>
<TitlesOfParts>
<vt:vector size="'
            || workbook.sheets.COUNT ( )
            || '" baseType="lpstr">';

        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            t_xxx := t_xxx || '
<vt:lpstr>'            || workbook.sheets ( s ).name || '</vt:lpstr>';
        END LOOP;

        t_xxx := t_xxx || '</vt:vector>
</TitlesOfParts>
<LinksUpToDate>false</LinksUpToDate>
<SharedDoc>false</SharedDoc>
<HyperlinksChanged>false</HyperlinksChanged>
<AppVersion>14.0300</AppVersion>
</Properties>';
        add1xml ( t_excel
                , 'docProps/app.xml'
                , t_xxx );
        t_xxx :=
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>';
        add1xml ( t_excel
                , '_rels/.rels'
                , t_xxx );
        t_xxx :=
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">';

        IF workbook.numfmts.COUNT ( ) > 0 THEN
            t_xxx := t_xxx || '<numFmts count="' || workbook.numfmts.COUNT ( ) || '">';

            FOR n IN 1 .. workbook.numfmts.COUNT ( ) LOOP
                t_xxx :=
                       t_xxx
                    || '<numFmt numFmtId="'
                    || workbook.numfmts ( n ).numfmtid
                    || '" formatCode="'
                    || workbook.numfmts ( n ).formatcode
                    || '"/>';
            END LOOP;

            t_xxx := t_xxx || '</numFmts>';
        END IF;

        t_xxx := t_xxx || '<fonts count="' || workbook.fonts.COUNT ( ) || '" x14ac:knownFonts="1">';

        FOR f IN 0 .. workbook.fonts.COUNT ( ) - 1 LOOP
            t_xxx :=
                   t_xxx
                || '<font>'
                || CASE WHEN workbook.fonts ( f ).bold THEN '<b/>' END
                || CASE WHEN workbook.fonts ( f ).italic THEN '<i/>' END
                || CASE WHEN workbook.fonts ( f ).underline THEN '<u/>' END
                || '<sz val="'
                || TO_CHAR ( workbook.fonts ( f ).fontsize
                           , 'TM9'
                           , 'NLS_NUMERIC_CHARACTERS=.,' )
                || '"/>
<color '
                || CASE
                       WHEN workbook.fonts ( f ).rgb IS NOT NULL THEN 'rgb="' || workbook.fonts ( f ).rgb
                       ELSE 'theme="' || workbook.fonts ( f ).theme
                   END
                || '"/>
<name val="'
                || workbook.fonts ( f ).name
                || '"/>
<family val="'
                || workbook.fonts ( f ).family
                || '"/>
<scheme val="none"/>
</font>'     ;
        END LOOP;

        t_xxx := t_xxx || '</fonts>
<fills count="'    || workbook.fills.COUNT ( ) || '">';

        FOR f IN 0 .. workbook.fills.COUNT ( ) - 1 LOOP
            t_xxx :=
                   t_xxx
                || '<fill><patternFill patternType="'
                || workbook.fills ( f ).patterntype
                || '">'
                || CASE
                       WHEN workbook.fills ( f ).fgrgb IS NOT NULL THEN
                           '<fgColor rgb="' || workbook.fills ( f ).fgrgb || '"/>'
                   END
                || '</patternFill></fill>';
        END LOOP;

        t_xxx := t_xxx || '</fills>
<borders count="'  || workbook.borders.COUNT ( ) || '">';

        FOR b IN 0 .. workbook.borders.COUNT ( ) - 1 LOOP
            t_xxx :=
                   t_xxx
                || '<border>'
                || CASE
                       WHEN workbook.borders ( b ).left IS NULL THEN '<left/>'
                       ELSE '<left style="' || workbook.borders ( b ).left || '"/>'
                   END
                || CASE
                       WHEN workbook.borders ( b ).right IS NULL THEN '<right/>'
                       ELSE '<right style="' || workbook.borders ( b ).right || '"/>'
                   END
                || CASE
                       WHEN workbook.borders ( b ).top IS NULL THEN '<top/>'
                       ELSE '<top style="' || workbook.borders ( b ).top || '"/>'
                   END
                || CASE
                       WHEN workbook.borders ( b ).bottom IS NULL THEN '<bottom/>'
                       ELSE '<bottom style="' || workbook.borders ( b ).bottom || '"/>'
                   END
                || '</border>';
        END LOOP;

        t_xxx := t_xxx || '</borders>
<cellStyleXfs count="1">
<xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>
</cellStyleXfs>
<cellXfs count="'  || ( workbook.cellxfs.COUNT ( ) + 1 ) || '">
<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>';

        FOR x IN 1 .. workbook.cellxfs.COUNT ( ) LOOP
            t_xxx :=
                   t_xxx
                || '<xf numFmtId="'
                || workbook.cellxfs ( x ).numfmtid
                || '" fontId="'
                || workbook.cellxfs ( x ).fontid
                || '" fillId="'
                || workbook.cellxfs ( x ).fillid
                || '" borderId="'
                || workbook.cellxfs ( x ).borderid
                || '">';

            IF ( workbook.cellxfs ( x ).alignment.horizontal IS NOT NULL
             OR workbook.cellxfs ( x ).alignment.vertical IS NOT NULL
             OR workbook.cellxfs ( x ).alignment.wraptext ) THEN
                t_xxx :=
                       t_xxx
                    || '<alignment'
                    || CASE
                           WHEN workbook.cellxfs ( x ).alignment.horizontal IS NOT NULL THEN
                               ' horizontal="' || workbook.cellxfs ( x ).alignment.horizontal || '"'
                       END
                    || CASE
                           WHEN workbook.cellxfs ( x ).alignment.vertical IS NOT NULL THEN
                               ' vertical="' || workbook.cellxfs ( x ).alignment.vertical || '"'
                       END
                    || CASE WHEN workbook.cellxfs ( x ).alignment.wraptext THEN ' wrapText="true"' END
                    || '/>';
            END IF;

            t_xxx := t_xxx || '</xf>';
        END LOOP;

        t_xxx :=
               t_xxx
            || '</cellXfs>
<cellStyles count="1">
<cellStyle name="Normal" xfId="0" builtinId="0"/>
</cellStyles>
<dxfs count="0"/>
<tableStyles count="0" defaultTableStyle="TableStyleMedium2" defaultPivotStyle="PivotStyleLight16"/>
<extLst>
<ext uri="{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main">
<x14:slicerStyles defaultSlicerStyle="SlicerStyleLight1"/>
</ext>
</extLst>
</styleSheet>';
        add1xml ( t_excel
                , 'xl/styles.xml'
                , t_xxx );
        t_xxx :=
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<fileVersion appName="xl" lastEdited="5" lowestEdited="5" rupBuild="9302"/>
<workbookPr date1904="true" defaultThemeVersion="124226"/>
<bookViews>
<workbookView xWindow="120" yWindow="45" windowWidth="19155" windowHeight="4935"/>
</bookViews>
<sheets>';

        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            t_xxx := t_xxx || '
<sheet name="'         || workbook.sheets ( s ).name || '" sheetId="' || s || '" r:id="rId' || ( 9 + s ) || '"/>';
        END LOOP;

        t_xxx := t_xxx || '</sheets>';

        IF workbook.defined_names.COUNT ( ) > 0 THEN
            t_xxx := t_xxx || '<definedNames>';

            FOR s IN 1 .. workbook.defined_names.COUNT ( ) LOOP
                t_xxx :=
                       t_xxx
                    || '
<definedName name="'
                    || workbook.defined_names ( s ).name
                    || '"'
                    || CASE
                           WHEN workbook.defined_names ( s ).sheet IS NOT NULL THEN
                               ' localSheetId="' || TO_CHAR ( workbook.defined_names ( s ).sheet ) || '"'
                       END
                    || '>'
                    || workbook.defined_names ( s ).REF
                    || '</definedName>';
            END LOOP;

            t_xxx := t_xxx || '</definedNames>';
        END IF;

        t_xxx := t_xxx || '<calcPr calcId="144525"/></workbook>';
        add1xml ( t_excel
                , 'xl/workbook.xml'
                , t_xxx );
        t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme">
<a:themeElements>
<a:clrScheme name="Office">
<a:dk1>
<a:sysClr val="windowText" lastClr="000000"/>
</a:dk1>
<a:lt1>
<a:sysClr val="window" lastClr="FFFFFF"/>
</a:lt1>
<a:dk2>
<a:srgbClr val="1F497D"/>
</a:dk2>
<a:lt2>
<a:srgbClr val="EEECE1"/>
</a:lt2>
<a:accent1>
<a:srgbClr val="4F81BD"/>
</a:accent1>
<a:accent2>
<a:srgbClr val="C0504D"/>
</a:accent2>
<a:accent3>
<a:srgbClr val="9BBB59"/>
</a:accent3>
<a:accent4>
<a:srgbClr val="8064A2"/>
</a:accent4>
<a:accent5>
<a:srgbClr val="4BACC6"/>
</a:accent5>
<a:accent6>
<a:srgbClr val="F79646"/>
</a:accent6>
<a:hlink>
<a:srgbClr val="0000FF"/>
</a:hlink>
<a:folHlink>
<a:srgbClr val="800080"/>
</a:folHlink>
</a:clrScheme>
<a:fontScheme name="Office">
<a:majorFont>
<a:latin typeface="Cambria"/>
<a:ea typeface=""/>
<a:cs typeface=""/>
<a:font script="Jpan" typeface="MS P????"/>
<a:font script="Hang" typeface="?? ??"/>
<a:font script="Hans" typeface="??"/>
<a:font script="Hant" typeface="????"/>
<a:font script="Arab" typeface="Times New Roman"/>
<a:font script="Hebr" typeface="Times New Roman"/>
<a:font script="Thai" typeface="Tahoma"/>
<a:font script="Ethi" typeface="Nyala"/>
<a:font script="Beng" typeface="Vrinda"/>
<a:font script="Gujr" typeface="Shruti"/>
<a:font script="Khmr" typeface="MoolBoran"/>
<a:font script="Knda" typeface="Tunga"/>
<a:font script="Guru" typeface="Raavi"/>
<a:font script="Cans" typeface="Euphemia"/>
<a:font script="Cher" typeface="Plantagenet Cherokee"/>
<a:font script="Yiii" typeface="Microsoft Yi Baiti"/>
<a:font script="Tibt" typeface="Microsoft Himalaya"/>
<a:font script="Thaa" typeface="MV Boli"/>
<a:font script="Deva" typeface="Mangal"/>
<a:font script="Telu" typeface="Gautami"/>
<a:font script="Taml" typeface="Latha"/>
<a:font script="Syrc" typeface="Estrangelo Edessa"/>
<a:font script="Orya" typeface="Kalinga"/>
<a:font script="Mlym" typeface="Kartika"/>
<a:font script="Laoo" typeface="DokChampa"/>
<a:font script="Sinh" typeface="Iskoola Pota"/>
<a:font script="Mong" typeface="Mongolian Baiti"/>
<a:font script="Viet" typeface="Times New Roman"/>
<a:font script="Uigh" typeface="Microsoft Uighur"/>
<a:font script="Geor" typeface="Sylfaen"/>
</a:majorFont>
<a:minorFont>
<a:latin typeface="Calibri"/>
<a:ea typeface=""/>
<a:cs typeface=""/>
<a:font script="Jpan" typeface="MS P????"/>
<a:font script="Hang" typeface="?? ??"/>
<a:font script="Hans" typeface="??"/>
<a:font script="Hant" typeface="????"/>
<a:font script="Arab" typeface="Arial"/>
<a:font script="Hebr" typeface="Arial"/>
<a:font script="Thai" typeface="Tahoma"/>
<a:font script="Ethi" typeface="Nyala"/>
<a:font script="Beng" typeface="Vrinda"/>
<a:font script="Gujr" typeface="Shruti"/>
<a:font script="Khmr" typeface="DaunPenh"/>
<a:font script="Knda" typeface="Tunga"/>
<a:font script="Guru" typeface="Raavi"/>
<a:font script="Cans" typeface="Euphemia"/>
<a:font script="Cher" typeface="Plantagenet Cherokee"/>
<a:font script="Yiii" typeface="Microsoft Yi Baiti"/>
<a:font script="Tibt" typeface="Microsoft Himalaya"/>
<a:font script="Thaa" typeface="MV Boli"/>
<a:font script="Deva" typeface="Mangal"/>
<a:font script="Telu" typeface="Gautami"/>
<a:font script="Taml" typeface="Latha"/>
<a:font script="Syrc" typeface="Estrangelo Edessa"/>
<a:font script="Orya" typeface="Kalinga"/>
<a:font script="Mlym" typeface="Kartika"/>
<a:font script="Laoo" typeface="DokChampa"/>
<a:font script="Sinh" typeface="Iskoola Pota"/>
<a:font script="Mong" typeface="Mongolian Baiti"/>
<a:font script="Viet" typeface="Arial"/>
<a:font script="Uigh" typeface="Microsoft Uighur"/>
<a:font script="Geor" typeface="Sylfaen"/>
</a:minorFont>
</a:fontScheme>
<a:fmtScheme name="Office">
<a:fillStyleLst>
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:tint val="50000"/>
<a:satMod val="300000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="35000">
<a:schemeClr val="phClr">
<a:tint val="37000"/>
<a:satMod val="300000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:tint val="15000"/>
<a:satMod val="350000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:lin ang="16200000" scaled="1"/>
</a:gradFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:shade val="51000"/>
<a:satMod val="130000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="80000">
<a:schemeClr val="phClr">
<a:shade val="93000"/>
<a:satMod val="130000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:shade val="94000"/>
<a:satMod val="135000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:lin ang="16200000" scaled="0"/>
</a:gradFill>
</a:fillStyleLst>
<a:lnStyleLst>
<a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">
<a:solidFill>
<a:schemeClr val="phClr">
<a:shade val="95000"/>
<a:satMod val="105000"/>
</a:schemeClr>
</a:solidFill>
<a:prstDash val="solid"/>
</a:ln>
<a:ln w="25400" cap="flat" cmpd="sng" algn="ctr">
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:prstDash val="solid"/>
</a:ln>
<a:ln w="38100" cap="flat" cmpd="sng" algn="ctr">
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:prstDash val="solid"/>
</a:ln>
</a:lnStyleLst>
<a:effectStyleLst>
<a:effectStyle>
<a:effectLst>
<a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0">
<a:srgbClr val="000000">
<a:alpha val="38000"/>
</a:srgbClr>
</a:outerShdw>
</a:effectLst>
</a:effectStyle>
<a:effectStyle>
<a:effectLst>
<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">
<a:srgbClr val="000000">
<a:alpha val="35000"/>
</a:srgbClr>
</a:outerShdw>
</a:effectLst>
</a:effectStyle>
<a:effectStyle>
<a:effectLst>
<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">
<a:srgbClr val="000000">
<a:alpha val="35000"/>
</a:srgbClr>
</a:outerShdw>
</a:effectLst>
<a:scene3d>
<a:camera prst="orthographicFront">
<a:rot lat="0" lon="0" rev="0"/>
</a:camera>
<a:lightRig rig="threePt" dir="t">
<a:rot lat="0" lon="0" rev="1200000"/>
</a:lightRig>
</a:scene3d>
<a:sp3d>
<a:bevelT w="63500" h="25400"/>
</a:sp3d>
</a:effectStyle>
</a:effectStyleLst>
<a:bgFillStyleLst>
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:tint val="40000"/>
<a:satMod val="350000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="40000">
<a:schemeClr val="phClr">
<a:tint val="45000"/>
<a:shade val="99000"/>
<a:satMod val="350000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:shade val="20000"/>
<a:satMod val="255000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:path path="circle">
<a:fillToRect l="50000" t="-80000" r="50000" b="180000"/>
</a:path>
</a:gradFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:tint val="80000"/>
<a:satMod val="300000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:shade val="30000"/>
<a:satMod val="200000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:path path="circle">
<a:fillToRect l="50000" t="50000" r="50000" b="50000"/>
</a:path>
</a:gradFill>
</a:bgFillStyleLst>
</a:fmtScheme>
</a:themeElements>
<a:objectDefaults/>
<a:extraClrSchemeLst/>
</a:theme>';
        add1xml ( t_excel
                , 'xl/theme/theme1.xml'
                , t_xxx );

        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            t_col_min := 16384;
            t_col_max := 1;
            t_row_ind := workbook.sheets ( s ).rows.FIRST ( );

            WHILE t_row_ind IS NOT NULL LOOP
                t_col_min :=
                    LEAST ( t_col_min
                          , workbook.sheets ( s ).rows ( t_row_ind ).FIRST ( ) );
                t_col_max :=
                    GREATEST ( t_col_max
                             , workbook.sheets ( s ).rows ( t_row_ind ).LAST ( ) );
                t_row_ind := workbook.sheets ( s ).rows.NEXT ( t_row_ind );
            END LOOP;

            t_xxx :=
                   '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">
<dimension ref="'
                || alfan_col ( t_col_min )
                || workbook.sheets ( s ).rows.FIRST ( )
                || ':'
                || alfan_col ( t_col_max )
                || workbook.sheets ( s ).rows.LAST ( )
                || '"/>
<sheetViews>
<sheetView'
                || CASE WHEN s = 1 THEN ' tabSelected="1"' END
                || ' workbookViewId="0">';

            IF workbook.sheets ( s ).freeze_rows > 0
           AND workbook.sheets ( s ).freeze_cols > 0 THEN
                t_xxx :=
                       t_xxx
                    || (    '<pane xSplit="'
                         || workbook.sheets ( s ).freeze_cols
                         || '" '
                         || 'ySplit="'
                         || workbook.sheets ( s ).freeze_rows
                         || '" '
                         || 'topLeftCell="'
                         || alfan_col ( workbook.sheets ( s ).freeze_cols + 1 )
                         || ( workbook.sheets ( s ).freeze_rows + 1 )
                         || '" '
                         || 'activePane="bottomLeft" state="frozen"/>' );
            ELSE
                IF workbook.sheets ( s ).freeze_rows > 0 THEN
                    t_xxx :=
                           t_xxx
                        || '<pane ySplit="'
                        || workbook.sheets ( s ).freeze_rows
                        || '" topLeftCell="A'
                        || ( workbook.sheets ( s ).freeze_rows + 1 )
                        || '" activePane="bottomLeft" state="frozen"/>';
                END IF;

                IF workbook.sheets ( s ).freeze_cols > 0 THEN
                    t_xxx :=
                           t_xxx
                        || '<pane xSplit="'
                        || workbook.sheets ( s ).freeze_cols
                        || '" topLeftCell="'
                        || alfan_col ( workbook.sheets ( s ).freeze_cols + 1 )
                        || '1" activePane="bottomLeft" state="frozen"/>';
                END IF;
            END IF;

            t_xxx := t_xxx || '</sheetView>
</sheetViews>
<sheetFormatPr defaultRowHeight="15" x14ac:dyDescent="0.25"/>';

            IF workbook.sheets ( s ).widths.COUNT ( ) > 0 THEN
                t_xxx := t_xxx || '<cols>';
                t_col_ind := workbook.sheets ( s ).widths.FIRST ( );

                WHILE t_col_ind IS NOT NULL LOOP
                    t_xxx :=
                           t_xxx
                        || '<col min="'
                        || t_col_ind
                        || '" max="'
                        || t_col_ind
                        || '" width="'
                        || TO_CHAR ( workbook.sheets ( s ).widths ( t_col_ind )
                                   , 'TM9'
                                   , 'NLS_NUMERIC_CHARACTERS=.,' )
                        || '" customWidth="1"/>';
                    t_col_ind := workbook.sheets ( s ).widths.NEXT ( t_col_ind );
                END LOOP;

                t_xxx := t_xxx || '</cols>';
            END IF;

            t_xxx := t_xxx || '<sheetData>';
            t_row_ind := workbook.sheets ( s ).rows.FIRST ( );
            t_tmp := NULL;

            WHILE t_row_ind IS NOT NULL LOOP
                /* row height */
                IF ( workbook.sheets ( s ).heights.EXISTS ( t_row_ind )
                AND workbook.sheets ( s ).heights ( t_row_ind ) > 0 ) THEN
                    t_row_height :=
                        'ht="' || TO_CHAR ( workbook.sheets ( s ).heights ( t_row_ind ) ) || '" customHeight="1"';
                ELSE
                    t_row_height := '';
                END IF;

                t_tmp :=
                       t_tmp
                    || '<row r="'
                    || t_row_ind
                    || '" spans="'
                    || t_col_min
                    || ':'
                    || t_col_max
                    || '" '
                    || t_row_height
                    || '>';
                t_len := LENGTH ( t_tmp );
                t_col_ind := workbook.sheets ( s ).rows ( t_row_ind ).FIRST ( );

                WHILE t_col_ind IS NOT NULL LOOP
                    t_cell :=
                           '<c r="'
                        || alfan_col ( t_col_ind )
                        || t_row_ind
                        || '"'
                        || ' '
                        || workbook.sheets ( s ).rows ( t_row_ind ) ( t_col_ind ).style
                        || '><v>'
                        || TO_CHAR ( workbook.sheets ( s ).rows ( t_row_ind ) ( t_col_ind ).VALUE
                                   , 'TM9'
                                   , 'NLS_NUMERIC_CHARACTERS=.,' )
                        || '</v></c>';

                    IF t_len > 32000 THEN
                        dbms_lob.writeappend ( t_xxx
                                             , t_len
                                             , t_tmp );
                        t_tmp := NULL;
                        t_len := 0;
                    END IF;

                    t_tmp := t_tmp || t_cell;
                    t_len := t_len + LENGTH ( t_cell );
                    t_col_ind := workbook.sheets ( s ).rows ( t_row_ind ).NEXT ( t_col_ind );
                END LOOP;

                t_tmp := t_tmp || '</row>';
                t_row_ind := workbook.sheets ( s ).rows.NEXT ( t_row_ind );
            END LOOP;

            t_tmp := t_tmp || '</sheetData>';
            t_len := LENGTH ( t_tmp );
            dbms_lob.writeappend ( t_xxx
                                 , t_len
                                 , t_tmp );

            FOR a IN 1 .. workbook.sheets ( s ).autofilters.COUNT ( ) LOOP
                t_xxx :=
                       t_xxx
                    || '<autoFilter ref="'
                    || alfan_col ( NVL ( workbook.sheets ( s ).autofilters ( a ).column_start, t_col_min ) )
                    || NVL ( workbook.sheets ( s ).autofilters ( a ).row_start, workbook.sheets ( s ).rows.FIRST ( ) )
                    || ':'
                    || alfan_col ( COALESCE ( workbook.sheets ( s ).autofilters ( a ).column_end
                                            , workbook.sheets ( s ).autofilters ( a ).column_start
                                            , t_col_max ) )
                    || NVL ( workbook.sheets ( s ).autofilters ( a ).row_end, workbook.sheets ( s ).rows.LAST ( ) )
                    || '"/>';
            END LOOP;

            IF workbook.sheets ( s ).mergecells.COUNT ( ) > 0 THEN
                t_xxx :=
                    t_xxx || '<mergeCells count="' || TO_CHAR ( workbook.sheets ( s ).mergecells.COUNT ( ) ) || '">';

                FOR m IN 1 .. workbook.sheets ( s ).mergecells.COUNT ( ) LOOP
                    t_xxx := t_xxx || '<mergeCell ref="' || workbook.sheets ( s ).mergecells ( m ) || '"/>';
                END LOOP;

                t_xxx := t_xxx || '</mergeCells>';
            END IF;

            --
            IF workbook.sheets ( s ).validations.COUNT ( ) > 0 THEN
                t_xxx :=
                       t_xxx
                    || '<dataValidations count="'
                    || TO_CHAR ( workbook.sheets ( s ).validations.COUNT ( ) )
                    || '">';

                FOR m IN 1 .. workbook.sheets ( s ).validations.COUNT ( ) LOOP
                    t_xxx :=
                           t_xxx
                        || '<dataValidation'
                        || ' type="'
                        || workbook.sheets ( s ).validations ( m ).TYPE
                        || '"'
                        || ' errorStyle="'
                        || workbook.sheets ( s ).validations ( m ).errorstyle
                        || '"'
                        || ' allowBlank="'
                        || CASE
                               WHEN NVL ( workbook.sheets ( s ).validations ( m ).allowblank, TRUE ) THEN '1'
                               ELSE '0'
                           END
                        || '"'
                        || ' sqref="'
                        || workbook.sheets ( s ).validations ( m ).sqref
                        || '"';

                    IF workbook.sheets ( s ).validations ( m ).prompt IS NOT NULL THEN
                        t_xxx :=
                               t_xxx
                            || ' showInputMessage="1" prompt="'
                            || workbook.sheets ( s ).validations ( m ).prompt
                            || '"';

                        IF workbook.sheets ( s ).validations ( m ).title IS NOT NULL THEN
                            t_xxx := t_xxx || ' promptTitle="' || workbook.sheets ( s ).validations ( m ).title || '"';
                        END IF;
                    END IF;

                    IF workbook.sheets ( s ).validations ( m ).showerrormessage THEN
                        t_xxx := t_xxx || ' showErrorMessage="1"';

                        IF workbook.sheets ( s ).validations ( m ).error_title IS NOT NULL THEN
                            t_xxx :=
                                t_xxx || ' errorTitle="' || workbook.sheets ( s ).validations ( m ).error_title || '"';
                        END IF;

                        IF workbook.sheets ( s ).validations ( m ).error_txt IS NOT NULL THEN
                            t_xxx := t_xxx || ' error="' || workbook.sheets ( s ).validations ( m ).error_txt || '"';
                        END IF;
                    END IF;

                    t_xxx := t_xxx || '>';

                    IF workbook.sheets ( s ).validations ( m ).formula1 IS NOT NULL THEN
                        t_xxx :=
                            t_xxx || '<formula1>' || workbook.sheets ( s ).validations ( m ).formula1 || '</formula1>';
                    END IF;

                    IF workbook.sheets ( s ).validations ( m ).formula2 IS NOT NULL THEN
                        t_xxx :=
                            t_xxx || '<formula2>' || workbook.sheets ( s ).validations ( m ).formula2 || '</formula2>';
                    END IF;

                    t_xxx := t_xxx || '</dataValidation>';
                END LOOP;

                t_xxx := t_xxx || '</dataValidations>';
            END IF;

            --
            IF workbook.sheets ( s ).hyperlinks.COUNT ( ) > 0 THEN
                t_xxx := t_xxx || '<hyperlinks>';

                FOR h IN 1 .. workbook.sheets ( s ).hyperlinks.COUNT ( ) LOOP
                    IF ( workbook.sheets ( s ).hyperlinks ( h ).location IS NOT NULL ) THEN
                        t_xxx :=
                               t_xxx
                            || '<hyperlink ref="'
                            || workbook.sheets ( s ).hyperlinks ( h ).cell
                            || '" location="'
                            || workbook.sheets ( s ).hyperlinks ( h ).location
                            || '"/>';
                    ELSE
                        t_xxx :=
                               t_xxx
                            || '<hyperlink ref="'
                            || workbook.sheets ( s ).hyperlinks ( h ).cell
                            || '" r:id="rId'
                            || h
                            || '"/>';
                    END IF;
                END LOOP;

                t_xxx := t_xxx || '</hyperlinks>';
            END IF;

            t_xxx :=
                t_xxx || '<pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>';

            IF workbook.sheets ( s ).comments.COUNT ( ) > 0 THEN
                t_xxx :=
                    t_xxx || '<legacyDrawing r:id="rId' || ( workbook.sheets ( s ).hyperlinks.COUNT ( ) + 1 ) || '"/>';
            END IF;

            --
            t_xxx := t_xxx || '</worksheet>';
            add1xml ( t_excel
                    , 'xl/worksheets/sheet' || s || '.xml'
                    , t_xxx );

            IF workbook.sheets ( s ).hyperlinks.COUNT ( ) > 0
            OR workbook.sheets ( s ).comments.COUNT ( ) > 0 THEN
                t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';

                IF workbook.sheets ( s ).comments.COUNT ( ) > 0 THEN
                    t_xxx :=
                           t_xxx
                        || '<Relationship Id="rId'
                        || ( workbook.sheets ( s ).hyperlinks.COUNT ( ) + 2 )
                        || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments" Target="../comments'
                        || s
                        || '.xml"/>';
                    t_xxx :=
                           t_xxx
                        || '<Relationship Id="rId'
                        || ( workbook.sheets ( s ).hyperlinks.COUNT ( ) + 1 )
                        || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing" Target="../drawings/vmlDrawing'
                        || s
                        || '.vml"/>';
                END IF;

                FOR h IN 1 .. workbook.sheets ( s ).hyperlinks.COUNT ( ) LOOP
                    t_xxx :=
                           t_xxx
                        || '<Relationship Id="rId'
                        || h
                        || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="'
                        || workbook.sheets ( s ).hyperlinks ( h ).url
                        || '" TargetMode="External"/>';
                END LOOP;

                t_xxx := t_xxx || '</Relationships>';
                add1xml ( t_excel
                        , 'xl/worksheets/_rels/sheet' || s || '.xml.rels'
                        , t_xxx );
            END IF;

            --
            IF workbook.sheets ( s ).comments.COUNT ( ) > 0 THEN
                DECLARE
                    cnt PLS_INTEGER;
                    author_ind tp_author;
                --          t_col_ind := workbook.sheets( s ).widths.next( t_col_ind );
                BEGIN
                    authors.delete ( );

                    FOR c IN 1 .. workbook.sheets ( s ).comments.COUNT ( ) LOOP
                        authors ( workbook.sheets ( s ).comments ( c ).author ) := 0;
                    END LOOP;

                    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<comments xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
<authors>'           ;
                    cnt := 0;
                    author_ind := authors.FIRST ( );

                    WHILE author_ind IS NOT NULL
                       OR authors.NEXT ( author_ind ) IS NOT NULL LOOP
                        authors ( author_ind ) := cnt;
                        t_xxx := t_xxx || '<author>' || author_ind || '</author>';
                        cnt := cnt + 1;
                        author_ind := authors.NEXT ( author_ind );
                    END LOOP;
                END;

                t_xxx := t_xxx || '</authors><commentList>';

                FOR c IN 1 .. workbook.sheets ( s ).comments.COUNT ( ) LOOP
                    t_xxx :=
                           t_xxx
                        || '<comment ref="'
                        || alfan_col ( workbook.sheets ( s ).comments ( c ).column )
                        || TO_CHAR (
                                        workbook.sheets ( s ).comments ( c ).row
                                     || '" authorId="'
                                     || authors ( workbook.sheets ( s ).comments ( c ).author )
                           )
                        || '">
<text>'              ;

                    IF workbook.sheets ( s ).comments ( c ).author IS NOT NULL THEN
                        t_xxx :=
                               t_xxx
                            || '<r><rPr><b/><sz val="9"/><color indexed="81"/><rFont val="Tahoma"/><charset val="1"/></rPr><t xml:space="preserve">'
                            || workbook.sheets ( s ).comments ( c ).author
                            || ':</t></r>';
                    END IF;

                    t_xxx :=
                           t_xxx
                        || '<r><rPr><sz val="9"/><color indexed="81"/><rFont val="Tahoma"/><charset val="1"/></rPr><t xml:space="preserve">'
                        || CASE WHEN workbook.sheets ( s ).comments ( c ).author IS NOT NULL THEN '
'                            END
                        || workbook.sheets ( s ).comments ( c ).text
                        || '</t></r></text></comment>';
                END LOOP;

                t_xxx := t_xxx || '</commentList></comments>';
                add1xml ( t_excel
                        , 'xl/comments' || s || '.xml'
                        , t_xxx );
                t_xxx :=
                    '<xml xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">
<o:shapelayout v:ext="edit"><o:idmap v:ext="edit" data="2"/></o:shapelayout>
<v:shapetype id="_x0000_t202" coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/></v:shapetype>';

                FOR c IN 1 .. workbook.sheets ( s ).comments.COUNT ( ) LOOP
                    t_xxx :=
                           t_xxx
                        || '<v:shape id="_x0000_s'
                        || TO_CHAR ( c )
                        || '" type="#_x0000_t202"
style="position:absolute;margin-left:35.25pt;margin-top:3pt;z-index:'
                        || TO_CHAR ( c )
                        || ';visibility:hidden;" fillcolor="#ffffe1" o:insetmode="auto">
<v:fill color2="#ffffe1"/><v:shadow on="t" color="black" obscured="t"/><v:path o:connecttype="none"/>
<v:textbox style="mso-direction-alt:auto"><div style="text-align:left"></div></v:textbox>
<x:ClientData ObjectType="Note"><x:MoveWithCells/><x:SizeWithCells/>';
                    t_w := workbook.sheets ( s ).comments ( c ).width;
                    t_c := 1;

                    LOOP
                        IF workbook.sheets ( s ).widths.EXISTS ( workbook.sheets ( s ).comments ( c ).column + t_c ) THEN
                            t_cw :=
                                  256
                                * workbook.sheets ( s ).widths ( workbook.sheets ( s ).comments ( c ).column + t_c );
                            t_cw := TRUNC ( ( t_cw + 18 ) / 256 * 7 ); -- assume default 11 point Calibri
                        ELSE
                            t_cw := 64;
                        END IF;

                        EXIT WHEN t_w < t_cw;
                        t_c := t_c + 1;
                        t_w := t_w - t_cw;
                    END LOOP;

                    t_h := workbook.sheets ( s ).comments ( c ).height;
                    t_xxx :=
                           t_xxx
                        || TO_CHAR (    '<x:Anchor>'
                                     || workbook.sheets ( s ).comments ( c ).column
                                     || ',15,'
                                     || workbook.sheets ( s ).comments ( c ).row
                                     || ',30,'
                                     || ( workbook.sheets ( s ).comments ( c ).column + t_c - 1 )
                                     || ','
                                     || ROUND ( t_w )
                                     || ','
                                     || ( workbook.sheets ( s ).comments ( c ).row + 1 + TRUNC ( t_h / 20 ) )
                                     || ','
                                     || MOD ( t_h
                                            , 20 )
                                     || '</x:Anchor>' );
                    t_xxx :=
                           t_xxx
                        || TO_CHAR (
                                        '<x:AutoFill>False</x:AutoFill><x:Row>'
                                     || ( workbook.sheets ( s ).comments ( c ).row - 1 )
                                     || '</x:Row><x:Column>'
                                     || ( workbook.sheets ( s ).comments ( c ).column - 1 )
                                     || '</x:Column></x:ClientData></v:shape>'
                           );
                END LOOP;

                t_xxx := t_xxx || '</xml>';
                add1xml ( t_excel
                        , 'xl/drawings/vmlDrawing' || s || '.vml'
                        , t_xxx );
            END IF;
        --
        END LOOP;

        t_xxx :=
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>';

        FOR s IN 1 .. workbook.sheets.COUNT ( ) LOOP
            t_xxx :=
                   t_xxx
                || '
<Relationship Id="rId'
                || ( 9 + s )
                || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet'
                || s
                || '.xml"/>';
        END LOOP;

        t_xxx := t_xxx || '</Relationships>';
        add1xml ( t_excel
                , 'xl/_rels/workbook.xml.rels'
                , t_xxx );
        t_xxx :=
               '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="'
            || workbook.str_cnt
            || '" uniqueCount="'
            || workbook.strings.COUNT ( )
            || '">';
        t_tmp := NULL;

        FOR i IN 0 .. workbook.str_ind.COUNT ( ) - 1 LOOP
            /* if left space */
            IF ( SUBSTR ( workbook.str_ind ( i )
                        , 1
                        , 1 ) = CHR ( 32 ) ) THEN
                t_str := '<si><t xml:space="preserve">';
            ELSE
                t_str := '<si><t>';
            END IF;

            t_str :=
                   t_str
                || dbms_xmlgen.CONVERT ( SUBSTR ( workbook.str_ind ( i )
                                                , 1
                                                , 32000 ) )
                || '</t></si>';

            IF LENGTH ( t_tmp ) + LENGTH ( t_str ) > 32000 THEN
                t_xxx := t_xxx || t_tmp;
                t_tmp := NULL;
            END IF;

            t_tmp := t_tmp || t_str;
        END LOOP;

        t_xxx := t_xxx || t_tmp || '</sst>';
        add1xml ( t_excel
                , 'xl/sharedStrings.xml'
                , t_xxx );
        finish_zip ( t_excel );
        clear_workbook;
        RETURN t_excel;
    END;

    --
    PROCEDURE save ( p_directory VARCHAR2
                   , p_filename VARCHAR2 )
    IS
    BEGIN
        blob2file ( finish
                  , p_directory
                  , p_filename );
    END;

    --
    PROCEDURE query2sheet ( p_sql VARCHAR2
                          , p_column_headers BOOLEAN := TRUE
                          , p_directory VARCHAR2 := NULL
                          , p_filename VARCHAR2 := NULL
                          , p_sheet PLS_INTEGER := NULL )
    IS
        t_sheet PLS_INTEGER;
        t_c INTEGER;
        t_col_cnt INTEGER;
        t_desc_tab dbms_sql.desc_tab2;
        d_tab dbms_sql.date_table;
        n_tab dbms_sql.number_table;
        v_tab dbms_sql.varchar2_table;
        t_bulk_size PLS_INTEGER := 200;
        t_r INTEGER;
        t_cur_row PLS_INTEGER;
    BEGIN
        IF p_sheet IS NULL THEN
            new_sheet;
        END IF;

        t_c := dbms_sql.open_cursor;
        dbms_sql.parse ( t_c
                       , p_sql
                       , dbms_sql.native );
        dbms_sql.describe_columns2 ( t_c
                                   , t_col_cnt
                                   , t_desc_tab );

        FOR c IN 1 .. t_col_cnt LOOP
            IF p_column_headers THEN
                cell ( c
                     , 1
                     , t_desc_tab ( c ).col_name
                     , p_sheet => t_sheet );
            END IF;

            --      dbms_output.put_line( t_desc_tab( c ).col_name || ' ' || t_desc_tab( c ).col_type );
            CASE
                WHEN t_desc_tab ( c ).col_type IN ( 2
                                                  , 100
                                                  , 101 ) THEN
                    dbms_sql.define_array ( t_c
                                          , c
                                          , n_tab
                                          , t_bulk_size
                                          , 1 );
                WHEN t_desc_tab ( c ).col_type IN ( 12
                                                  , 178
                                                  , 179
                                                  , 180
                                                  , 181
                                                  , 231 ) THEN
                    dbms_sql.define_array ( t_c
                                          , c
                                          , d_tab
                                          , t_bulk_size
                                          , 1 );
                WHEN t_desc_tab ( c ).col_type IN ( 1
                                                  , 8
                                                  , 9
                                                  , 96
                                                  , 112 ) THEN
                    dbms_sql.define_array ( t_c
                                          , c
                                          , v_tab
                                          , t_bulk_size
                                          , 1 );
                ELSE
                    NULL;
            END CASE;
        END LOOP;

        --
        t_cur_row := CASE WHEN p_column_headers THEN 2 ELSE 1 END;
        t_sheet := NVL ( p_sheet, workbook.sheets.COUNT ( ) );
        --
        t_r := dbms_sql.execute ( t_c );

        LOOP
            t_r := dbms_sql.fetch_rows ( t_c );

            IF t_r > 0 THEN
                FOR c IN 1 .. t_col_cnt LOOP
                    CASE
                        WHEN t_desc_tab ( c ).col_type IN ( 2
                                                          , 100
                                                          , 101 ) THEN
                            dbms_sql.COLUMN_VALUE ( t_c
                                                  , c
                                                  , n_tab );

                            FOR i IN 0 .. t_r - 1 LOOP
                                IF n_tab ( i + n_tab.FIRST ( ) ) IS NOT NULL THEN
                                    cell ( c
                                         , t_cur_row + i
                                         , n_tab ( i + n_tab.FIRST ( ) )
                                         , p_sheet => t_sheet );
                                END IF;
                            END LOOP;

                            n_tab.delete;
                        WHEN t_desc_tab ( c ).col_type IN ( 12
                                                          , 178
                                                          , 179
                                                          , 180
                                                          , 181
                                                          , 231 ) THEN
                            dbms_sql.COLUMN_VALUE ( t_c
                                                  , c
                                                  , d_tab );

                            FOR i IN 0 .. t_r - 1 LOOP
                                IF d_tab ( i + d_tab.FIRST ( ) ) IS NOT NULL THEN
                                    cell ( c
                                         , t_cur_row + i
                                         , d_tab ( i + d_tab.FIRST ( ) )
                                         , p_sheet => t_sheet );
                                END IF;
                            END LOOP;

                            d_tab.delete;
                        WHEN t_desc_tab ( c ).col_type IN ( 1
                                                          , 8
                                                          , 9
                                                          , 96
                                                          , 112 ) THEN
                            dbms_sql.COLUMN_VALUE ( t_c
                                                  , c
                                                  , v_tab );

                            FOR i IN 0 .. t_r - 1 LOOP
                                IF v_tab ( i + v_tab.FIRST ( ) ) IS NOT NULL THEN
                                    cell ( c
                                         , t_cur_row + i
                                         , v_tab ( i + v_tab.FIRST ( ) )
                                         , p_sheet => t_sheet );
                                END IF;
                            END LOOP;

                            v_tab.delete;
                        ELSE
                            NULL;
                    END CASE;
                END LOOP;
            END IF;

            EXIT WHEN t_r != t_bulk_size;
            t_cur_row := t_cur_row + t_r;
        END LOOP;

        dbms_sql.close_cursor ( t_c );

        IF ( p_directory IS NOT NULL
        AND p_filename IS NOT NULL ) THEN
            save ( p_directory
                 , p_filename );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF dbms_sql.is_open ( t_c ) THEN
                dbms_sql.close_cursor ( t_c );
            END IF;
    END;
    
    
    
    
    
         PROCEDURE prc_in_excel_xlsx  (     pCodEmpresa    VARCHAR2  , pDataInicial   DATE , pDatafim       DATE , pprocid        NUMBER , pdir  VARCHAR2 DEFAULT 'MSAFIMP') 
          IS 
                      l_cod_empresa varchar2(10);
        
                    l_name_file     varchar2(100) ;
                    
                    in_filename VARCHAR2(100) := 'FIN4816_REINF_V7_34264.xlsx';
                    l_directory   varchar2(100) := 'MSAFIMP';
                    src_file   BFILE;
                    v_content  BLOB;
                    v_blob_len INTEGER;
                    v_file     utl_file.file_type;
                    v_buffer   RAW(32767);
                    v_amount   BINARY_INTEGER := 32767;
                    v_pos      INTEGER := 1;
                    
                    
                     begin
                      l_name_file := 'FIN4816_REINF_V7'||'_'||pprocid||'.xlsx';
                      
                      
                     
                     
                      dpsp_v7_fin4816_prev_cproc.clear_workbook;
                      dpsp_v7_fin4816_prev_cproc.new_sheet('Report Fiscal');
                      dpsp_v7_fin4816_prev_cproc.mergecells( 1, 1, 19, 1 );
                      dpsp_v7_fin4816_prev_cproc.cell(  1, 1,'Report Fiscal DW'                , p_alignment => dpsp_v7_fin4816_prev_cproc.get_alignment( p_horizontal => 'left' ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '90EE90'  ),  
                                                                              p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Calibri', p_rgb => 'FFFF0000' ) );  
                                                                                                                                                          
                      dpsp_v7_fin4816_prev_cproc.cell(  1, 2, 'Codigo Da Empresa'              , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillid => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  2, 2, 'Codigo do Estabelecimento'      , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  3, 2, 'Periodo de Emissão'             , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  4, 2, 'CNPJ Drogaria'                  , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  5, 2, 'Numero da Nota Fiscal'          , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  6, 2, 'Tipo de Documento'              , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  7, 2, 'Doc. Contábil'                  , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  8, 2, 'Data Emissão'                   , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  9 ,2, 'CNPJ Fonecedor'                 , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  10,2, 'UF'                             , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  11,2, 'Valor Total da Nota'            , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  12,2, 'Base de Calculo INSS'           , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  13,2, 'Valor do INSS'                  , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  14,2, 'Codigo Pessoa Fisica/juridica'  , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  15,2, 'Razão Social'                   , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  16,2, 'Municipio Prestador'            , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  17,2, 'Codigo de Serviço'              , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  18,2, 'Codigo CEI'                     , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '39FF14'  ) );                      
                      dpsp_v7_fin4816_prev_cproc.cell(  19,2, 'DWT'                            , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '90EE90'  )
                                                                            , p_alignment => dpsp_v7_fin4816_prev_cproc.get_alignment( p_horizontal => 'center' ) ); 
                      ---
                      for m  in  PKG_FIN4816_CURSOR.cr_rel_apoio_fiscal( pcod_empresa =>  pCodEmpresa ,  pdata_ini=> pDataInicial,  pdata_fim=> pDatafim, pproc_id => pprocid)
                      LOOP 
                      dpsp_v7_fin4816_prev_cproc.cell(   1, m.id_rtf + 2 , m."Codigo da Empresa"               , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   2, m.id_rtf + 2 , m."Codigo do Estabelecimento"       , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   3, m.id_rtf + 2 , m."Periodo de Emissão"              , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   4, m.id_rtf + 2 , m."CNPJ Drogaria"                   , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   5, m.id_rtf + 2 , m."Numero da Nota Fiscal"           , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   6, m.id_rtf + 2 , m."Tipo de Documento"               , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   7, m.id_rtf + 2 , m."Doc. Contábil"                   , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   8, m.id_rtf + 2 , m."Data Emissão"                    , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(   9, m.id_rtf + 2 , m."CNPJ Fonecedor"                  , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  10, m.id_rtf + 2 , m."UF"                              , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  11, m.id_rtf + 2 , m."Valor Total da Nota"             , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  12, m.id_rtf + 2 , m."Base de Calculo INSS"            , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  13, m.id_rtf + 2 , m."Valor do INSS"                   , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  14, m.id_rtf + 2 , m."Codigo Pessoa Fisica/juridica"   , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  15, m.id_rtf + 2 , m."Razão Social"                    , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  16, m.id_rtf + 2 , m."Municipio Prestador"             , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  17, m.id_rtf + 2 , m."Codigo de Serviço"               , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  18, m.id_rtf + 2 , m."Codigo CEI"                      , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  19, m.id_rtf + 2 , m."DWT"                             , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 8, p_bold =>false ) );                      
                      END LOOP;
                      dpsp_v7_fin4816_prev_cproc.freeze_rows( 2 ); 
                      
                    

                    
                      dpsp_v7_fin4816_prev_cproc.new_sheet('Report INSS Retido');
                      dpsp_v7_fin4816_prev_cproc.mergecells( 1, 1, 20, 1 );
                      dpsp_v7_fin4816_prev_cproc.cell(  1, 1,'Report INSS Retido'         , p_alignment => dpsp_v7_fin4816_prev_cproc.get_alignment( p_horizontal => 'left' ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFFE0'  ),  
                                                                         p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Calibri', p_rgb => 'FFFF0000' ) );
                                                                                                                                                       
                      dpsp_v7_fin4816_prev_cproc.cell(  1, 2, 'Codigo Da Empresa'         , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillid => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  2, 2, 'Codigo do Estabelecimento' , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  3, 2, 'cod.Pessoa Fis Jur'        , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );                      
                      dpsp_v7_fin4816_prev_cproc.cell(  4, 2, 'Razão Social Cliente'      , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  5, 2, 'CNPJ Cliente'              , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  6, 2, 'Nro. Nota Fiscal'          , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  7, 2, 'Dt. Emissao'               , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  8, 2, 'Dt. Fiscal'                , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  9, 2, 'Vlr. Total da Nota'        , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  10,2, 'Vlr Base Calc. Retenção'   , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  11,2, 'Vlr. Aliquota INSS'        , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  12,2, 'Vlr.Trib INSS RETIDO'      , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  13,2, 'Razão Social Drogaria'     , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  14,2, 'CNPJ Drogarias'            , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  15,2, 'Descr. Tp. Documento'      , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  16,2, 'Tp.Serv. E-social'         , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  17,2, 'Descr. Tp. Serv E-social'  , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  18,2, 'Vlr. do Servico'           , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  19,2, 'Cod. Serv. Mastersaf'      , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  20,2, 'Descr. Serv. Mastersaf'    , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'FFFF00'  ) );
                      dpsp_v7_fin4816_prev_cproc.freeze_rows( 2 );  
                      
                              
                      
                      
                      
                      dpsp_v7_fin4816_prev_cproc.new_sheet('Report Reinf-E2010');
                      dpsp_v7_fin4816_prev_cproc.mergecells( 1, 1, 8, 1 );
                      dpsp_v7_fin4816_prev_cproc.cell(  1, 1,'Report Reinf-E2010'         , p_alignment => dpsp_v7_fin4816_prev_cproc.get_alignment( p_horizontal => 'left' ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', 'ADD8E6'  ),  
                                                                         p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Calibri', p_rgb => 'FFFF0000' ) );
                                                                                                                                                       
                      dpsp_v7_fin4816_prev_cproc.cell(  1, 2, 'Codigo Da Empresa'              , p_fontid => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillid => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  2, 2, 'Razão Social Drogaria'          , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  3, 2, 'Razão Social Cliente'           , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  4, 2, 'Nro. Nota Fiscal '              , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  5 ,2, 'Valor do Tributo '              , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  7 ,2, 'observação'                     , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  6 ,2, 'Tp.Serv. E-social'              , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  7 ,2, 'Vlr. Base de Calc. Retenção'    , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.cell(  8 ,2, 'Valor da Retenção '             , p_fontId => dpsp_v7_fin4816_prev_cproc.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => dpsp_v7_fin4816_prev_cproc.get_fill( 'solid', '00BFFF'  ) );
                      dpsp_v7_fin4816_prev_cproc.freeze_rows( 2 );  
                      
                      dpsp_v7_fin4816_prev_cproc.save( pdir, l_name_file);
                      


                        BEGIN
                           src_file := bfilename(pdir, l_name_file);
                           dbms_lob.fileopen(src_file, dbms_lob.file_readonly);
                           v_content  := utl_compress.lz_compress(src_file, 9);
                           v_blob_len := dbms_lob.getlength(v_content);
                           v_file     := utl_file.fopen(l_directory,in_filename || '.zip', 'wb');
                           
                            WHILE v_pos < v_blob_len 
                            LOOP
                              dbms_lob.READ(v_content, v_amount, v_pos, v_buffer);
                              utl_file.put_raw(v_file, v_buffer, TRUE);
                              v_pos := v_pos + v_amount;
                            END LOOP;
                           
                            utl_file.fclose(v_file);

                        EXCEPTION
                           WHEN OTHERS THEN
                              IF utl_file.is_open(v_file) THEN
                                 utl_file.fclose(v_file);
                              END IF;
                              RAISE;
                        END;
            

      END prc_in_excel_xlsx ;
      
      
      
      
      
      
       PROCEDURE prc_out_excel_csv ( 
                                   vp_mproc_id IN NUMBER
                                 , v_data_inicial IN DATE
                                 , v_data_final IN DATE 
                                 )
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

                

            FOR i IN  pkg_fin4816_cursor.cr_rel_apoio_fiscal(pcod_empresa  => mcod_empresa,  pdata_ini => v_data_inicial , pdata_fim => v_data_final , pproc_id => vp_mproc_id  )
            
            
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
    END prc_out_excel_csv;
    
    

    FUNCTION executar ( pdata_inicial   DATE
                      , pdata_final     DATE    
                      , p_radio         VARCHAR2    
                      , pcod_dir        VARCHAR2                  
                      , pcod_estab      lib_proc.vartab 
                      
                      )
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
        --====================================================================
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
        
        l_name_file   := to_char('myexcel_'||mproc_id||'.xlsx');
        p_task := 'PROC_EXCL_' || mproc_id;


        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
    
         mcod_empresa := lib_parametros.recuperar(upper('EMPRESA'));
         mnm_usuario  := lib_parametros.recuperar ( 'USUARIO' );
         
          
         
         
         
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
         
         
         
       
         --============================================
         -- LOOP  ( load table ) 
         --============================================
          carga_test  (   
            pcod_empresa    => mcod_empresa
          , pdata_inicial   => pdata_inicial    --TO_DATE ( pdata_inicial, 'DD/MM/YYYY') 
          , pdata_final     => pdata_final       --TO_DATE ( pdata_final, 'DD/MM/YYYY')  
          , pprocid         => mproc_id ) ;
            
          
          
          
          
          --=================================================
          -- Imput/output  do Excel 
          --=================================================
          IF  p_radio = 'S'  THEN 
          prc_out_excel_csv (   vp_mproc_id=> mproc_id , v_data_inicial=> pdata_inicial, v_data_final => pdata_final);
          ELSE
          
          BEGIN
          prc_in_excel_xlsx  (  pCodEmpresa=> mcod_empresa , pDataInicial => pdata_inicial , pDatafim => pdata_final , pprocid => mproc_id , pdir=> pcod_dir ); 
          EXCEPTION 
          WHEN OTHERS THEN
          loga ( '---ERRO NO PROCESSAMENTO---', FALSE );  
          loga ( '----> Diretório Inválido :'||pcod_dir, FALSE );  
          loga ( '----> Por favor, escolha outro diretório ou procure o administrador!', FALSE ); 
          lib_proc.close;          
          RETURN mproc_id;
          loga('teste nr.'||seq.nextval);
          END;
          END IF ;
          
          
          
          
          
          
          
          
          
          
                  
          loga('teste nr.'||seq.nextval);

          loga ( '---FIM DO PROCESSAMENTO---', FALSE );        
          lib_proc.close;          
          RETURN mproc_id;
          
          
          
          
 
    END;
    
    
END DPSP_V7_FIN4816_PREV_CPROC;
/