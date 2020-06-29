                    



                     declare
                     l_name_file     varchar2(100) ;
                     begin
                     l_name_file := 'V7_'||seq.nextval||'.xlsx';
                     
                      as_xlsx.clear_workbook;
                      as_xlsx.new_sheet('Report Fiscal');
                      as_xlsx.mergecells( 1, 1, 18, 1 );
                      --for c in 1 .. 10
                      --loop
                      as_xlsx.cell(  1, 1,'Report Fiscal DW'                , p_alignment => as_xlsx.get_alignment( p_horizontal => 'left' ), p_fillId => as_xlsx.get_fill( 'solid', '90EE90'  ),  
                                                                              p_fontId => as_xlsx.get_font( 'Calibri', p_rgb => 'FFFF0000' ) );  
                                                                                                                                                          
                      as_xlsx.cell(  1, 2, 'Codigo Da Empresa'              , p_fontid => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillid => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  2, 2, 'Codigo do Estabelecimento'      , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  3, 2, 'Periodo de Emissão'             , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  4, 2, 'CNPJ Drogaria'                  , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  5, 2, 'Numero da Nota Fiscal'          , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  6, 2, 'Tipo de Documento'              , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  7, 2, 'Data Emissão'                   , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  8, 2, 'uf'                             , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  9 ,2, 'Valor Total da Nota'            , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  10,2, 'Base de Calculo INSS'           , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  11,2, 'Valor do INSS'                  , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  12,2, 'Codigo Pessoa Fisica/juridica'  , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  13,2, 'Razão Social'                   , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  14,2, 'Municipio Prestador'            , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  15,2, 'Codigo de Serviço'              , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  16,2, 'Codigo da Empresa'              , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  17,2, 'Codigo CEI'                     , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '39FF14'  ) );
                      as_xlsx.cell(  18,2, 'DWT'                            , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', '90EE90'  )
                                                                            , p_alignment => as_xlsx.get_alignment( p_horizontal => 'center' ) ); 
                      as_xlsx.freeze_rows( 2 );    

                    
                      
                    
                      as_xlsx.new_sheet('Report INSS Retido');
                      as_xlsx.mergecells( 1, 1, 20, 1 );
                      as_xlsx.cell(  1, 1,'Report INSS Retido'         , p_alignment => as_xlsx.get_alignment( p_horizontal => 'left' ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFFE0'  ),  
                                                                         p_fontId => as_xlsx.get_font( 'Calibri', p_rgb => 'FFFF0000' ) );                                                                              
                      as_xlsx.cell(  1, 2, 'Codigo Da Empresa'         , p_fontid => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillid => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  2, 2, 'Codigo do Estabelecimento' , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  3, 2, 'cod.Pessoa Fis Jur'        , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );                      
                      as_xlsx.cell(  4, 2, 'Razão Social Cliente'      , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  5, 2, 'CNPJ Cliente'              , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  6, 2, 'Nro. Nota Fiscal'          , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  7, 2, 'Dt. Emissao'               , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  8, 2, 'Dt. Fiscal'                , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  9, 2, 'Vlr. Total da Nota'        , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  10,2, 'Vlr Base Calc. Retenção'   , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  11,2, 'Vlr. Aliquota INSS'        , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  12,2, 'Vlr.Trib INSS RETIDO'      , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  13,2, 'Razão Social Drogaria'     , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  14,2, 'CNPJ Drogarias'            , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  15,2, 'Descr. Tp. Documento'      , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  16,2, 'Tp.Serv. E-social'         , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  17,2, 'Descr. Tp. Serv E-social'  , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  18,2, 'Vlr. do Servico'           , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  19,2, 'Cod. Serv. Mastersaf'      , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.cell(  20,2, 'Descr. Serv. Mastersaf'    , p_fontId => as_xlsx.get_font( 'Arial', 2, 9, p_bold =>true ), p_fillId => as_xlsx.get_fill( 'solid', 'FFFF00'  ) );
                      as_xlsx.freeze_rows( 2 );  
                      
                      
                      
                      
                       
                       
                     --end loop;
                       
                      
                      
                      
                      
                      
                      as_xlsx.save( 'MSAFIMP', l_name_file);
                      end;
                      