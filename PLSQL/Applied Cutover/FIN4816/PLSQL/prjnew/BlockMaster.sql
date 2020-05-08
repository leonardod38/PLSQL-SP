DECLARE
    p_data_inicial DATE := '01/01/2017';
    p_data_final DATE := '31/01/2017';
    p_cod_empresa VARCHAR2 ( 10 ) := 'DM1';
    p_cod_estab VARCHAR2 ( 10 ) := 'BRZ1';
    v_sql VARCHAR2 ( 32767 );
    idx NUMBER ( 10 ) := 0;

    TYPE rc IS REF CURSOR;

    c1 rc;


    TYPE typ_fin4816_rtf IS RECORD
    (
        cod_empresa VARCHAR2 ( 3 BYTE )
      , cod_estab VARCHAR2 ( 6 BYTE )
      , data_fiscal DATE
      , movto_e_s CHAR ( 1 BYTE )
      , norm_dev CHAR ( 1 BYTE )
      , ident_docto NUMBER ( 12 )
      , ident_fis_jur NUMBER ( 12 )
      , num_docfis VARCHAR2 ( 12 BYTE )
      , serie_docfis VARCHAR2 ( 3 BYTE )
      , sub_serie_docfis VARCHAR2 ( 2 BYTE )
      , ident_servico NUMBER ( 12 )
      , num_item NUMBER ( 5 )
      , perido_emissao DATE
      , cgc VARCHAR2 ( 14 BYTE )
      , num_docto VARCHAR2 ( 12 BYTE )
      , tipo_docto VARCHAR2 ( 5 BYTE )
      , data_emissao DATE
      , cgc_fornecedor VARCHAR2 ( 14 BYTE )
      , uf VARCHAR2 ( 2 BYTE )
      , valor_total NUMBER ( 17, 2 )
      , base_inss NUMBER ( 17, 2 )
      , valor_inss NUMBER ( 17, 2 )
      , cod_fis_jur VARCHAR2 ( 14 BYTE )
      , razao_social VARCHAR2 ( 70 BYTE )
      , municipio_prestador VARCHAR2 ( 50 BYTE )
      , cod_servico VARCHAR2 ( 4 BYTE )
      , cod_cei VARCHAR2 ( 15 BYTE )
      , equalizacao NUMBER
    );

    TYPE table_fin4816_rtf IS TABLE OF typ_fin4816_rtf
        INDEX BY PLS_INTEGER;

    t_fin4816_rtf table_fin4816_rtf;



    TYPE typ_cod_empresa IS TABLE OF VARCHAR2 ( 3 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_cod_estab IS TABLE OF VARCHAR2 ( 6 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_data_fiscal IS TABLE OF DATE
        INDEX BY PLS_INTEGER;

    TYPE typ_movto_e_s IS TABLE OF CHAR ( 1 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_norm_dev IS TABLE OF CHAR ( 1 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_ident_docto IS TABLE OF NUMBER ( 12 )
        INDEX BY PLS_INTEGER;

    TYPE typ_ident_fis_jur IS TABLE OF NUMBER ( 12 )
        INDEX BY PLS_INTEGER;

    TYPE typ_num_docfis IS TABLE OF VARCHAR2 ( 12 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_serie_docfis IS TABLE OF VARCHAR2 ( 3 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_sub_serie_docfis IS TABLE OF VARCHAR2 ( 2 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_ident_servico IS TABLE OF NUMBER ( 12 )
        INDEX BY PLS_INTEGER;

    TYPE typ_num_item IS TABLE OF NUMBER ( 5 )
        INDEX BY PLS_INTEGER;

    TYPE typ_perido_emissao IS TABLE OF DATE
        INDEX BY PLS_INTEGER;

    TYPE typ_cgc IS TABLE OF VARCHAR2 ( 14 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_num_docto IS TABLE OF VARCHAR2 ( 12 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_tipo_docto IS TABLE OF VARCHAR2 ( 5 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_data_emissao IS TABLE OF DATE
        INDEX BY PLS_INTEGER;

    TYPE typ_cgc_fornecedor IS TABLE OF VARCHAR2 ( 14 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_uf IS TABLE OF VARCHAR2 ( 2 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_valor_total IS TABLE OF NUMBER ( 17, 2 )
        INDEX BY PLS_INTEGER;

    TYPE typ_base_inss IS TABLE OF NUMBER ( 17, 2 )
        INDEX BY PLS_INTEGER;

    TYPE typ_valor_inss IS TABLE OF NUMBER ( 17, 2 )
        INDEX BY PLS_INTEGER;

    TYPE typ_cod_fis_jur IS TABLE OF VARCHAR2 ( 14 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_razao_social IS TABLE OF VARCHAR2 ( 70 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_municipio_prestador IS TABLE OF VARCHAR2 ( 50 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_cod_servico IS TABLE OF VARCHAR2 ( 4 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_cod_cei IS TABLE OF VARCHAR2 ( 15 BYTE )
        INDEX BY PLS_INTEGER;

    TYPE typ_equalizacao IS TABLE OF NUMBER
        INDEX BY PLS_INTEGER;



    l_cod_empresa typ_cod_empresa;
    l_cod_estab typ_cod_estab;
    l_data_fiscal typ_data_fiscal;
    l_movto_e_s typ_movto_e_s;
    l_norm_dev typ_norm_dev;
    l_ident_docto typ_ident_docto;
    l_ident_fis_jur typ_ident_fis_jur;
    l_num_docfis typ_num_docfis;
    l_serie_docfis typ_serie_docfis;
    l_sub_serie_docfis typ_sub_serie_docfis;
    l_ident_servico typ_ident_servico;
    l_num_item typ_num_item;
    l_perido_emissao typ_perido_emissao;
    l_cgc typ_cgc;
    l_num_docto typ_num_docto;
    l_tipo_docto typ_tipo_docto;
    l_data_emissao typ_data_emissao;
    l_cgc_fornecedor typ_cgc_fornecedor;
    l_uf typ_uf;
    l_valor_total typ_valor_total;
    l_base_inss typ_base_inss;
    l_valor_inss typ_valor_inss;
    l_cod_fis_jur typ_cod_fis_jur;
    l_razao_social typ_razao_social;
    l_municipio_prestador typ_municipio_prestador;
    l_cod_servico typ_cod_servico;
    l_cod_cei typ_cod_cei;
    l_equalizacao typ_equalizacao;
BEGIN
    v_sql := ' SELECT ';
    v_sql := v_sql || '   x09_itens_serv.cod_empresa      as cod_empresa        ';
    v_sql := v_sql || ' , x09_itens_serv.cod_estab        as cod_estab          ';
    v_sql := v_sql || ' , x09_itens_serv.data_fiscal AS data_fiscal             '; -- Data Fiscal
    v_sql := v_sql || ' , x09_itens_serv.movto_e_s AS movto_e_s                 ';
    v_sql := v_sql || ' , x09_itens_serv.norm_dev AS norm_dev                   ';
    v_sql := v_sql || ' , x09_itens_serv.ident_docto AS ident_docto             ';
    v_sql := v_sql || ' , x09_itens_serv.ident_fis_jur AS ident_fis_jur         ';
    v_sql := v_sql || ' , x09_itens_serv.num_docfis AS num_docfis               ';
    v_sql := v_sql || ' , x09_itens_serv.serie_docfis AS serie_docfis           ';
    v_sql := v_sql || ' , x09_itens_serv.sub_serie_docfis AS sub_serie_docfis   ';
    v_sql := v_sql || ' , x09_itens_serv.ident_servico AS ident_servico         ';
    v_sql := v_sql || ' , x09_itens_serv.num_item AS num_item                   ';
    v_sql := v_sql || ' , x07_docto_fiscal.data_emissao AS perido_emissao       '; -- Periodo de Emissão
    v_sql := v_sql || ' , estabelecimento.cgc AS cgc                            '; -- CNPJ Drogaria
    v_sql := v_sql || ' , x07_docto_fiscal.num_docfis AS num_docto              '; -- Numero da Nota Fiscal
    v_sql := v_sql || ' , x2005_tipo_docto.cod_docto AS tipo_docto              '; -- Tipo de Documento
    v_sql := v_sql || ' , x07_docto_fiscal.data_emissao AS data_emissao         '; -- Data Emissão
    v_sql := v_sql || ' , x04_pessoa_fis_jur.cpf_cgc AS cgc_fornecedor          '; -- CNPJ_Fonecedor
    v_sql := v_sql || ' , estado.cod_estado AS uf                               '; -- uf
    v_sql := v_sql || ' , x09_itens_serv.vlr_tot AS valor_total                 '; -- Valor Total da Nota
    v_sql := v_sql || ' , x09_itens_serv.vlr_base_inss AS base_inss             '; -- Base de Calculo INSS
    v_sql := v_sql || ' , x09_itens_serv.vlr_inss_retido AS valor_inss          '; -- Valor do INSS
    v_sql := v_sql || ' , x04_pessoa_fis_jur.cod_fis_jur AS cod_fis_jur         '; -- Codigo Pessoa Fisica/juridica
    v_sql := v_sql || ' , x04_pessoa_fis_jur.razao_social AS razao_social       '; -- Razão Social
    v_sql := v_sql || ' , municipio.descricao AS municipio_prestador            '; -- Municipio Prestador
    v_sql := v_sql || ' , x2018_servicos.cod_servico AS cod_servico             '; -- Codigo de Serviço
    v_sql := v_sql || ' , x07_docto_fiscal.cod_cei AS cod_cei                   '; -- Codigo CEI
    v_sql := v_sql || ' , NULL AS equalizacao                                   '; -- Equalização
    v_sql := v_sql || ' FROM                                                    ';
    v_sql := v_sql || '      x07_docto_fiscal                                   ';
    v_sql := v_sql || '    , x2005_tipo_docto                                   ';
    v_sql := v_sql || '    , x04_pessoa_fis_jur                                 ';
    v_sql := v_sql || '    , x09_itens_serv                                     ';
    v_sql := v_sql || '    , estabelecimento                                    ';
    v_sql := v_sql || '    , estado                                             ';
    v_sql := v_sql || '    , x2018_servicos                                     ';
    v_sql := v_sql || '    , municipio                                          ';
    v_sql := v_sql || ' WHERE 1=1                                               ';
    v_sql := v_sql || '   AND x09_itens_serv.cod_empresa        = estabelecimento.cod_empresa           ';
    v_sql := v_sql || '   AND x09_itens_serv.cod_estab          = estabelecimento.cod_estab             ';
    v_sql := v_sql || '   AND x09_itens_serv.cod_empresa        = ''' || p_cod_empresa || '''';
    v_sql := v_sql || '   AND x09_itens_serv.cod_estab          = ''' || p_cod_estab || '''';
    --V_SQL := V_SQL||  ' --  AND x09_itens_serv.cod_estab      = estab.cod_estab
    --V_SQL := V_SQL||  ' --  AND estab.proc_id                 = pproc_id
    v_sql := v_sql || '   AND x09_itens_serv.cod_empresa        = x07_docto_fiscal.cod_empresa          ';
    v_sql := v_sql || '   AND x09_itens_serv.cod_estab          = x07_docto_fiscal.cod_estab            ';
    v_sql := v_sql || '   AND x09_itens_serv.data_fiscal        = x07_docto_fiscal.data_fiscal          ';
    v_sql := v_sql || '   AND x07_docto_fiscal.data_emissao between  ''' || p_data_inicial || '''';
    v_sql := v_sql || '   AND   ''' || p_data_final || '''';
    -- V_SQL := V_SQL||  '   AND   x09_itens_serv.vlr_inss_retido  > 0                                      ';
    v_sql := v_sql || '   AND x09_itens_serv.movto_e_s          = x07_docto_fiscal.movto_e_s             ';
    v_sql := v_sql || '   AND x09_itens_serv.norm_dev           = x07_docto_fiscal.norm_dev              ';
    v_sql := v_sql || '   AND x09_itens_serv.ident_docto        = x07_docto_fiscal.ident_docto           ';
    v_sql := v_sql || '   AND x09_itens_serv.ident_fis_jur      = x07_docto_fiscal.ident_fis_jur         ';
    v_sql := v_sql || '   AND x09_itens_serv.num_docfis         = x07_docto_fiscal.num_docfis            ';
    v_sql := v_sql || '   AND x09_itens_serv.serie_docfis       = x07_docto_fiscal.serie_docfis          ';
    v_sql := v_sql || '   AND x09_itens_serv.sub_serie_docfis   = x07_docto_fiscal.sub_serie_docfis      ';
    v_sql := v_sql || '   AND estado.ident_estado               = x04_pessoa_fis_jur.ident_estado        ';
    v_sql := v_sql || '   AND municipio.ident_estado            = estado.ident_estado                    ';
    v_sql := v_sql || '   AND municipio.cod_municipio           = x04_pessoa_fis_jur.cod_municipio       ';
    v_sql := v_sql || '   AND x2018_servicos.ident_servico      = x09_itens_serv.ident_servico           ';
    v_sql := v_sql || '   AND ( x2005_tipo_docto.ident_docto    = x07_docto_fiscal.ident_docto )         ';
    v_sql := v_sql || '   AND ( x04_pessoa_fis_jur.ident_fis_jur= x07_docto_fiscal.ident_fis_jur )       ';
    v_sql := v_sql || '   AND ( x07_docto_fiscal.movto_e_s IN ( 1, 2, 3, 4, 5 ) )                        ';
    v_sql := v_sql || '   AND (( x07_docto_fiscal.situacao <>  ''S'' )                                   ';
    v_sql := v_sql || '   OR  ( x07_docto_fiscal.situacao IS NULL ))                                     ';
    v_sql := v_sql || '   AND ( x07_docto_fiscal.cod_class_doc_fis =''2'')                               ';
    v_sql := v_sql || '   AND ( ( x07_docto_fiscal.ident_cfo IS NULL )                                   ';
    v_sql := v_sql || '              OR ( NOT ( EXISTS                                                   ';
    v_sql := v_sql || '                            (SELECT 1                                             ';
    v_sql := v_sql || '                               FROM x2012_cod_fiscal x2012                        ';
    v_sql := v_sql || '                                  , prt_cfo_uf_msaf pcum                          ';
    v_sql := v_sql || '                                  , estabelecimento est                           ';
    v_sql := v_sql || '                              WHERE x2012.ident_cfo = x07_docto_fiscal.ident_cfo     ';
    v_sql := v_sql || '                                AND est.cod_empresa = x07_docto_fiscal.cod_empresa   ';
    v_sql := v_sql || '                                AND est.cod_estab = x07_docto_fiscal.cod_estab       ';
    v_sql := v_sql || '                                AND pcum.cod_empresa = est.cod_empresa               ';
    v_sql := v_sql || '                                AND pcum.cod_param = 415                             ';
    v_sql := v_sql || '                                AND pcum.ident_estado = est.ident_estado             ';
    v_sql := v_sql || '                                AND pcum.cod_cfo = x2012.cod_cfo)                    ';
    v_sql := v_sql || '                    AND EXISTS                                                       ';
    v_sql := v_sql || '                            (SELECT 1                                                ';
    v_sql := v_sql || '                               FROM ict_par_icms_uf ipiu                             ';
    v_sql := v_sql || '                                  , estabelecimento esta                             ';
    v_sql := v_sql || '                              WHERE ipiu.ident_estado = esta.ident_estado            ';
    v_sql := v_sql || '                                AND esta.cod_empresa = x07_docto_fiscal.cod_empresa  ';
    v_sql := v_sql || '                                AND esta.cod_estab = x07_docto_fiscal.cod_estab      ';
    v_sql := v_sql || '                                AND ipiu.dsc_param =''64''                           ';
    v_sql := v_sql || '                                AND ipiu.ind_tp_par = ''S'') ) ) )                   ';
    v_sql := v_sql || '       ORDER BY x09_itens_serv.cod_empresa                                           ';
    v_sql := v_sql || '              , x09_itens_serv.cod_estab                                             ';
    v_sql := v_sql || '              , x09_itens_serv.data_fiscal                                           ';
    v_sql := v_sql || '              , x09_itens_serv.movto_e_s                                             ';
    v_sql := v_sql || '              , x09_itens_serv.norm_dev                                              ';
    v_sql := v_sql || '              , x09_itens_serv.ident_docto                                           ';
    v_sql := v_sql || '              , x09_itens_serv.ident_fis_jur                                         ';
    v_sql := v_sql || '              , x09_itens_serv.num_docfis                                            ';
    v_sql := v_sql || '              , x09_itens_serv.serie_docfis                                          ';
    v_sql := v_sql || '              , x09_itens_serv.sub_serie_docfis                                      ';
    v_sql := v_sql || '              , x09_itens_serv.ident_servico                                         ';
    v_sql := v_sql || '              , x09_itens_serv.num_item                                              ';



    OPEN c1 FOR v_sql;

    LOOP
        FETCH c1
            BULK COLLECT INTO t_fin4816_rtf
            LIMIT 1000;

        FOR i IN t_fin4816_rtf.FIRST .. t_fin4816_rtf.LAST LOOP
            idx := idx + 1;
            
            IF  t_fin4816_rtf ( i ).num_docfis  = '081086' THEN 
              DBMS_OUTPUT.PUT_LINE(t_fin4816_rtf ( i ).num_docfis);
            END IF ;
            
            
            l_cod_empresa ( idx ) := t_fin4816_rtf ( i ).cod_empresa;
            l_cod_estab ( idx ) := t_fin4816_rtf ( i ).cod_estab;
            l_data_fiscal ( idx ) := t_fin4816_rtf ( i ).data_fiscal;
            l_movto_e_s ( idx ) := t_fin4816_rtf ( i ).movto_e_s;
            l_norm_dev ( idx ) := t_fin4816_rtf ( i ).norm_dev;
            l_ident_docto ( idx ) := t_fin4816_rtf ( i ).ident_docto;
            l_ident_fis_jur ( idx ) := t_fin4816_rtf ( i ).ident_fis_jur;
            l_num_docfis ( idx ) := t_fin4816_rtf ( i ).num_docfis;
            l_serie_docfis ( idx ) := t_fin4816_rtf ( i ).serie_docfis;
            l_sub_serie_docfis ( idx ) := t_fin4816_rtf ( i ).sub_serie_docfis;
            l_ident_servico ( idx ) := t_fin4816_rtf ( i ).ident_servico;
            l_num_item ( idx ) := t_fin4816_rtf ( i ).num_item;
            l_perido_emissao ( idx ) := t_fin4816_rtf ( i ).perido_emissao;
            l_cgc ( idx ) := t_fin4816_rtf ( i ).cgc;
            l_num_docto ( idx ) := t_fin4816_rtf ( i ).num_docto;
            l_tipo_docto ( idx ) := t_fin4816_rtf ( i ).tipo_docto;
            l_data_emissao ( idx ) := t_fin4816_rtf ( i ).data_emissao;
            l_cgc_fornecedor ( idx ) := t_fin4816_rtf ( i ).cgc_fornecedor;
            l_uf ( idx ) := t_fin4816_rtf ( i ).uf;
            l_valor_total ( idx ) := t_fin4816_rtf ( i ).valor_total;
            l_base_inss ( idx ) := t_fin4816_rtf ( i ).base_inss;
            l_valor_inss ( idx ) := t_fin4816_rtf ( i ).valor_inss;
            l_cod_fis_jur ( idx ) := t_fin4816_rtf ( i ).cod_fis_jur;
            l_razao_social ( idx ) := t_fin4816_rtf ( i ).razao_social;
            l_municipio_prestador ( idx ) := t_fin4816_rtf ( i ).municipio_prestador;
            l_cod_servico ( idx ) := t_fin4816_rtf ( i ).cod_servico;
            l_cod_cei ( idx ) := t_fin4816_rtf ( i ).cod_cei;
            l_equalizacao ( idx ) := t_fin4816_rtf ( i ).equalizacao;
           
            
        END LOOP;

        EXIT WHEN c1%NOTFOUND;
    END LOOP;

    DELETE FROM tmp_process_01_rtf;
    
    --   SELECT * FROM tmp_process_01_rtf;  
    COMMIT;

    FORALL idx IN l_cod_empresa.FIRST .. l_cod_empresa.LAST
        INSERT /*APPEND*/
          INTO tmp_process_01_rtf ( cod_empresa
                                       , cod_estab
                                       , data_fiscal
                                       , movto_e_s
                                       , norm_dev
                                       , ident_docto
                                       , ident_fis_jur
                                       , num_docfis
                                       , serie_docfis
                                       , sub_serie_docfis
                                       , ident_servico
                                       , num_item
                                       , perido_emissao
                                       , cgc
                                       , num_docto
                                       , tipo_docto
                                       , data_emissao
                                       , cgc_fornecedor
                                       , uf
                                       , valor_total
                                       , base_inss
                                       , valor_inss
                                       , cod_fis_jur
                                       , razao_social
                                       , municipio_prestador
                                       , cod_servico
                                       , cod_cei
                                       , equalizacao )
             VALUES ( l_cod_empresa ( idx )
                    , l_cod_estab ( idx )
                    , l_data_fiscal ( idx )
                    , l_movto_e_s ( idx )
                    , l_norm_dev ( idx )
                    , l_ident_docto ( idx )
                    , l_ident_fis_jur ( idx )
                    , l_num_docfis ( idx )
                    , l_serie_docfis ( idx )
                    , l_sub_serie_docfis ( idx )
                    , l_ident_servico ( idx )
                    , l_num_item ( idx )
                    , l_perido_emissao ( idx )
                    , l_cgc ( idx )
                    , l_num_docto ( idx )
                    , l_tipo_docto ( idx )
                    , l_data_emissao ( idx )
                    , l_cgc_fornecedor ( idx )
                    , l_uf ( idx )
                    , l_valor_total ( idx )
                    , l_base_inss ( idx )
                    , l_valor_inss ( idx )
                    , l_cod_fis_jur ( idx )
                    , l_razao_social ( idx )
                    , l_municipio_prestador ( idx )
                    , l_cod_servico ( idx )
                    , l_cod_cei ( idx )
                    , l_equalizacao ( idx ) );

    COMMIT;
    l_cod_empresa.delete;
    l_cod_estab.delete;
    l_data_fiscal.delete;
    l_movto_e_s.delete;
    l_norm_dev.delete;
    l_ident_docto.delete;
    l_ident_fis_jur.delete;
    l_num_docfis.delete;
    l_serie_docfis.delete;
    l_sub_serie_docfis.delete;
    l_ident_servico.delete;
    l_num_item.delete;
    l_perido_emissao.delete;
    l_cgc.delete;
    l_num_docto.delete;
    l_tipo_docto.delete;
    l_data_emissao.delete;
    l_cgc_fornecedor.delete;
    l_uf.delete;
    l_valor_total.delete;
    l_base_inss.delete;
    l_valor_inss.delete;
    l_cod_fis_jur.delete;
    l_razao_social.delete;
    l_municipio_prestador.delete;
    l_cod_servico.delete;
    l_cod_cei.delete;
    l_equalizacao.delete;

    idx := 0;
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line ( SQLERRM );
--DBMS_OUTPUT.PUT_LINE (V_SQL);
END;