   DECLARE
    p_data_inicial DATE             := '01/12/2018';  -- data  inicial emissao '01/07/2018'   AND  '30/07/2018'  DSP062
    p_data_final DATE               := '31/12/2018';  -- data  final  emissao
    p_cod_empresa VARCHAR2 ( 10 )   := 'DSP';
    p_cod_estab VARCHAR2 ( 10 )     := 'DSP062';
    pprocid  number                := 295754;
    
    idx NUMBER ( 10 )               := 0;
    v_sql VARCHAR2 ( 32767 );
    l_status  varchar2(10);
    
    BEGIN
                

    
            --   select * from msafi.tb_fin4816_reinf_conf_prev_tmp; 
            --   select * from msafi.tb_fin4816_prev_tmp_estab	
            --   select * from msafi.tb_fin4816_rel_apoio_fiscalv5 
            
              ---delete msafi.tb_fin4816_reinf_conf_prev_tmp;      
              --delete msafi.tb_fin4816_rel_apoio_fiscalV5 ;
              --commit;
              
         
      
         

             for  m  in  pkg_fin4816_cursor.cr_rtf  (pcod_empresa  => p_cod_empresa,  pdata_ini => p_data_inicial, pdata_fim   => p_data_final , pproc_id => pprocid )
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
             --
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete  ;     
             end loop;
             idx := 0;
             

             for n in   pkg_fin4816_cursor.cr_inss_retido (pempresa  => p_cod_empresa , pdata_ini => p_data_inicial , pdata_fim => p_data_final , pproc_id => pprocid ) 
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
             pkg_fin4816_type.t_fin4816_rtf ( idx ).id_inss_retido := idx;
              
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete  ;         
             end loop;
             idx := 0;

           
             for j in   pkg_fin4816_cursor.rc_reinf_evento_e2010 (pcod_empresa  =>p_cod_empresa ,   pdata_ini => p_data_inicial , pdata_fim => p_data_final , pproc_id => pprocid)   
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
             --
             insert into msafi.tb_fin4816_rel_apoio_fiscalv5 
             values pkg_fin4816_type.t_fin4816_rtf ( idx );
             commit; 
             pkg_fin4816_type.t_fin4816_rtf .delete;      
             end loop;            
             idx := 0;                 
             
             UPDATE  msafi.tb_fin4816_rel_apoio_fiscalv5 SET  ID_GERAL = ROWNUM ;
             COMMIT;
         

            END ;