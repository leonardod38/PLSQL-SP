Prompt Package Body PKG_GERACAO_ARQ_DIRFCONT_CPROC;
--
-- PKG_GERACAO_ARQ_DIRFCONT_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY pkg_geracao_arq_dirfcont_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        lib_proc.add_param ( pstr
                           , 'Empresa'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , 'Ano Base'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '####' );
        lib_proc.add_param ( pstr
                           , 'Data Emisssão'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => 'DD/MM/YYYY' );
        lib_proc.add_param ( pstr
                           , 'Diretório'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '#######################################' );
        lib_proc.add_param ( pstr
                           , 'Nome do Arquivo'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '####################' );

        lib_proc.add_param ( pstr
                           , 'Código Reteção'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );
        lib_proc.add_param ( pstr
                           , ''
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , pmascara => '######' );

        -- lib_proc.add_param(pstr, 'Cod. Estabelecimento', 'Varchar2', 'Textbox', 'N' ,pmascara => '######');

        -- lib_proc.add_param(pstr, 'Cod. Estado', 'Varchar2',
        --         'listbox', 'S', '', '', 'AC=AC,AL=AL,AM=AM,AP=AP,BA=BA,CE=CE,DF=DF,ES=ES,EX=EX,GO=GO,MA=MA,MG=MG,MS=MS,MT=MT,PA=PA,PB=PB,PE=PE,PI=PI,PR=PR,RJ=RJ,RN=RN,RO=RO,RR=RR,RS=RS,SC=SC,SE=SE,SP=SP,TO=TO');

        -- lib_proc.add_param(pstr, 'Cod. Mod. CIAP', 'Varchar2','listbox', 'S', '', '', 'A=A,B=B,C=C,D=D'  );


        RETURN pstr;
    END;



    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'DIRF Contribuição';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Pessoa Jurídica Contribuição';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Geração Arquivo texto Contribuição ';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Utilitarios';
    END;

    FUNCTION executar ( par_empresa VARCHAR2
                      , par_ano_base VARCHAR2
                      , par_data_emissao DATE
                      , par_diretorio VARCHAR2
                      , par_arquivo VARCHAR2
                      , par_codigo1 VARCHAR2
                      , par_codigo2 VARCHAR2
                      , par_codigo3 VARCHAR2
                      , par_codigo4 VARCHAR2
                      , par_codigo5 VARCHAR2
                      , par_codigo6 VARCHAR2
                      , par_codigo7 VARCHAR2
                      , par_codigo8 VARCHAR2
                      , par_codigo9 VARCHAR2
                      , par_codigo10 VARCHAR2 )
        RETURN INTEGER
    IS
    BEGIN
        sp_geracao_arquivo_dirf_cont ( par_empresa
                                     , par_ano_base
                                     , par_data_emissao
                                     , par_diretorio
                                     , par_arquivo
                                     , par_codigo1
                                     , par_codigo2
                                     , par_codigo3
                                     , par_codigo4
                                     , par_codigo5
                                     , par_codigo6
                                     , par_codigo7
                                     , par_codigo8
                                     , par_codigo9
                                     , par_codigo10 );
        RETURN (NULL);
    END;



    PROCEDURE sp_geracao_arquivo_dirf_cont ( p_empresa IN CHAR
                                           , p_ano_base IN NUMBER
                                           , p_data_emissao DATE
                                           , p_diretorio IN CHAR
                                           , p_arquivo IN CHAR
                                           , p_codigo1 IN CHAR
                                           , p_codigo2 IN CHAR
                                           , p_codigo3 IN CHAR
                                           , p_codigo4 IN CHAR
                                           , p_codigo5 IN CHAR
                                           , p_codigo6 IN CHAR
                                           , p_codigo7 IN CHAR
                                           , p_codigo8 IN CHAR
                                           , p_codigo9 IN CHAR
                                           , p_codigo10 IN CHAR )
    IS
        v_mes_base VARCHAR2 ( 3 );
        v_cgc VARCHAR2 ( 20 );
        v_cpf_cgc VARCHAR2 ( 20 );
        v_valor_rend VARCHAR2 ( 25 );
        v_irrf_retido VARCHAR2 ( 25 );
        v_cpf_cgc_controle VARCHAR2 ( 20 ) := 'X';


        --- in( '02577445000164','01850383000150')


        --Cabeçalho
        CURSOR c1
        IS
            SELECT   DISTINCT '1' cabecalho
                            , x53.ano_competencia
                            , est.razao_social
                            , est.cgc
                            , x04.cpf_cgc
                            , x04.razao_social razao_social_x04
                            , SUBSTR ( x04.cod_fis_jur
                                     , 1
                                     , 10 )
                                  cod_fis_jur
                            , resp.nom_responsavel
                            , SUBSTR ( x04.endereco
                                     , 1
                                     , 40 )
                                  endereco
                            , x04.cidade
                            , estad.cod_estado
                            , x04.cep
                            , '  ' branco
                FROM x53_retencao_irrf x53
                   , estabelecimento est
                   , x04_pessoa_fis_jur x04
                   , resp_informacao resp
                   , estado estad
               WHERE x53.cod_empresa LIKE DECODE ( p_empresa, NULL, '%', p_empresa )
                 AND x53.ano_competencia = p_ano_base
                 -- and  x04.CPF_CGC in( '02577445000164','01850383000150')
                 AND x53.cod_empresa = x53.cod_empresa
                 AND x53.cod_estab = est.cod_estab
                 AND x53.ident_fis_jur = x04.ident_fis_jur
                 AND resp.ind_categoria = '2'
                 AND x04.ident_estado = estad.ident_estado
                 AND LENGTH ( x04.cpf_cgc ) = 14
                 AND x04.cpf_cgc IN ( SELECT x04.cpf_cgc
                                        FROM x53_retencao_irrf x53
                                           , x2019_cod_darf x2019
                                           , x04_pessoa_fis_jur x04
                                       WHERE x53.cod_empresa LIKE DECODE ( p_empresa, NULL, '%', p_empresa )
                                         AND x53.ano_competencia = p_ano_base
                                         --and  x04.CPF_CGC  in( '02577445000164','01850383000150')
                                         --and  x04.CPF_CGC  in( '02577445000164')
                                         AND x53.ident_darf = x2019.ident_darf
                                         AND x53.ident_fis_jur = x04.ident_fis_jur
                                         AND LENGTH ( x04.cpf_cgc ) = 14
                                         AND x2019.cod_darf IN ( p_codigo1
                                                               , p_codigo2
                                                               , p_codigo3
                                                               , p_codigo4
                                                               , p_codigo5
                                                               , p_codigo6
                                                               , p_codigo7
                                                               , p_codigo8
                                                               , p_codigo9
                                                               , p_codigo10 ) )
            ORDER BY x04.razao_social;


        --Detalhe
        CURSOR c2
        IS
            SELECT   DISTINCT x04.cpf_cgc
                            , '2' detalhe
                            , x53.mes_competencia
                            , '1' sequencia
                            , x2019.cod_darf
                            , x2019.descricao
                            , SUM ( x53.vlr_bruto ) tot_vlr_bruto
                            , SUM ( x53.vlr_ir_retido ) tot_vlr_ir_retido
                FROM x53_retencao_irrf x53
                   , x2019_cod_darf x2019
                   , x04_pessoa_fis_jur x04
               WHERE x53.cod_empresa LIKE DECODE ( p_empresa, NULL, '%', p_empresa )
                 AND x53.ano_competencia = p_ano_base
                 --and  x04.CPF_CGC  in( '02577445000164','01850383000150')
                 --and  x04.CPF_CGC  in( '02577445000164')
                 AND x53.ident_darf = x2019.ident_darf
                 AND x53.ident_fis_jur = x04.ident_fis_jur
                 AND LENGTH ( x04.cpf_cgc ) = 14
                 AND x2019.cod_darf IN ( p_codigo1
                                       , p_codigo2
                                       , p_codigo3
                                       , p_codigo4
                                       , p_codigo5
                                       , p_codigo6
                                       , p_codigo7
                                       , p_codigo8
                                       , p_codigo9
                                       , p_codigo10 )
            GROUP BY x04.cpf_cgc
                   , x53.mes_competencia
                   , x2019.cod_darf
                   , x2019.descricao
            ORDER BY x04.cpf_cgc
                   , x53.mes_competencia
                   , x2019.cod_darf;
    BEGIN
        utl_file.fclose ( out_file );
        out_file :=
            utl_file.fopen ( p_diretorio
                           , p_arquivo
                           , 'w' );

        -- Trata Cabeçalho
        FOR rec1 IN c1 LOOP
            IF v_cpf_cgc_controle <> rec1.cpf_cgc THEN
                v_cgc :=
                       SUBSTR ( rec1.cgc
                              , 1
                              , 2 )
                    || '.'
                    || SUBSTR ( rec1.cgc
                              , 3
                              , 3 )
                    || '.'
                    || SUBSTR ( rec1.cgc
                              , 6
                              , 3 )
                    || '/'
                    || SUBSTR ( rec1.cgc
                              , 9
                              , 4 )
                    || '-'
                    || SUBSTR ( rec1.cgc
                              , 13
                              , 2 );

                v_cpf_cgc :=
                       SUBSTR ( rec1.cpf_cgc
                              , 1
                              , 2 )
                    || '.'
                    || SUBSTR ( rec1.cpf_cgc
                              , 3
                              , 3 )
                    || '.'
                    || SUBSTR ( rec1.cpf_cgc
                              , 6
                              , 3 )
                    || '/'
                    || SUBSTR ( rec1.cpf_cgc
                              , 9
                              , 4 )
                    || '-'
                    || SUBSTR ( rec1.cpf_cgc
                              , 13
                              , 2 );

                utl_file.put_line ( out_file
                                  ,    rec1.cabecalho
                                    || TO_CHAR ( rec1.ano_competencia )
                                    || RPAD ( rec1.razao_social
                                            , 40
                                            , ' ' )
                                    || v_cgc
                                    || ' '
                                    || v_cpf_cgc
                                    || ' '
                                    || RPAD ( rec1.razao_social_x04
                                            , 40
                                            , ' ' )
                                    || RPAD ( rec1.cod_fis_jur
                                            , 10
                                            , ' ' )
                                    || RPAD ( rec1.nom_responsavel
                                            , 40
                                            , ' ' )
                                    || TO_CHAR ( p_data_emissao
                                               , 'ddmmyyyy' )
                                    || RPAD ( rec1.endereco
                                            , 40
                                            , ' ' )
                                    || RPAD ( rec1.cidade
                                            , 25
                                            , ' ' )
                                    || RPAD ( rec1.cod_estado
                                            , 2
                                            , ' ' )
                                    || LPAD ( rec1.cep
                                            , 8
                                            , '0' )
                                    || rec1.branco );


                -- Trata Detalhe
                FOR rec2 IN c2 LOOP
                    IF rec1.cpf_cgc = rec2.cpf_cgc THEN
                        --Conveter mes para string
                        IF rec2.mes_competencia = '1' THEN
                            v_mes_base := 'JAN';
                        ELSIF rec2.mes_competencia = '2' THEN
                            v_mes_base := 'FEV';
                        ELSIF rec2.mes_competencia = '3' THEN
                            v_mes_base := 'MAR';
                        ELSIF rec2.mes_competencia = '4' THEN
                            v_mes_base := 'ABR';
                        ELSIF rec2.mes_competencia = '5' THEN
                            v_mes_base := 'MAI';
                        ELSIF rec2.mes_competencia = '6' THEN
                            v_mes_base := 'JUN';
                        ELSIF rec2.mes_competencia = '7' THEN
                            v_mes_base := 'JUL';
                        ELSIF rec2.mes_competencia = '8' THEN
                            v_mes_base := 'AGO';
                        ELSIF rec2.mes_competencia = '9' THEN
                            v_mes_base := 'SET';
                        ELSIF rec2.mes_competencia = '10' THEN
                            v_mes_base := 'OUT';
                        ELSIF rec2.mes_competencia = '11' THEN
                            v_mes_base := 'NOV';
                        ELSIF rec2.mes_competencia = '12' THEN
                            v_mes_base := 'DEZ';
                        END IF;

                        IF rec2.tot_vlr_bruto = 0 THEN
                            v_valor_rend := '           0,00';
                        ELSE
                            v_valor_rend :=
                                LPAD ( LTRIM ( RTRIM ( TO_CHAR ( rec2.tot_vlr_bruto
                                                               , '999g999g999g999d99' ) ) )
                                     , 15
                                     , ' ' );
                        END IF;

                        IF rec2.tot_vlr_ir_retido = 0 THEN
                            v_irrf_retido := '           0,00';
                        ELSE
                            v_irrf_retido :=
                                LPAD ( LTRIM ( RTRIM ( TO_CHAR ( rec2.tot_vlr_ir_retido
                                                               , '999g999g999g999d99' ) ) )
                                     , 15
                                     , ' ' );
                        END IF;

                        utl_file.put_line ( out_file
                                          ,    rec2.detalhe
                                            || v_mes_base
                                            || rec2.sequencia
                                            || RPAD ( rec2.cod_darf
                                                    , 4
                                                    , ' ' )
                                            || RPAD ( rec2.descricao
                                                    , 66
                                                    , ' ' )
                                            || v_valor_rend
                                            || v_irrf_retido );
                    END IF;
                END LOOP;
            END IF;

            v_cpf_cgc_controle := rec1.cpf_cgc;
        END LOOP;

        utl_file.fclose ( out_file );
    EXCEPTION
        WHEN utl_file.invalid_path THEN
            utl_file.fclose ( out_file );
            raise_application_error ( -20001
                                    , 'Invalid path during openning
process.'                              );
        WHEN utl_file.invalid_mode THEN
            utl_file.fclose ( out_file );
            raise_application_error ( -20002
                                    , 'Invalid mode. ' );
        WHEN utl_file.invalid_operation THEN
            utl_file.fclose ( out_file );
            raise_application_error ( -20003
                                    , 'Diretório inválido ' );
            raise_application_error ( -20003
                                    , 'Invalid operation. ' );
        WHEN utl_file.invalid_filehandle THEN
            utl_file.fclose ( out_file );
            raise_application_error ( -20004
                                    , 'Invalid File Handle. ' );
        WHEN utl_file.read_error THEN
            utl_file.fclose ( out_file );
            raise_application_error ( -20005
                                    , 'Read error. ' );
        WHEN OTHERS THEN
            utl_file.put_line ( out_file
                              , 'CPF_CGC --> ' || v_cpf_cgc || SQLCODE || '  ' || SQLERRM );
            utl_file.fclose ( out_file );
    END sp_geracao_arquivo_dirf_cont;
END pkg_geracao_arq_dirfcont_cproc;
/
SHOW ERRORS;
