Prompt Package Body MSAF_DIM_SLS_CPROC;
--
-- MSAF_DIM_SLS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_dim_sls_cproc
IS
    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_estab.cod_usuario%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento '
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT e.cod_estab, e.cod_estab||'' - ''||e.razao_social FROM estabelecimento e WHERE e.cod_empresa = '''
                             || mcod_empresa
                             || ''''
        );

        lib_proc.add_param ( pstr
                           , 'Período Inicial '
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );

        lib_proc.add_param ( pstr
                           , 'Período Final '
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'DIM - SÃO LUIS(MA)';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'DIM';
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
        RETURN 'DIM - SÃO LUIS(MA)';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION executar ( pcd_estab VARCHAR2
                      , pdt_inicio DATE
                      , pdt_final DATE )
        RETURN INTEGER
    IS
        /* Variáveis de Trabalho */
        mproc_id INTEGER;
        mlinha VARCHAR2 ( 1000 );
        v_insc_mun VARCHAR2 ( 15 );
    BEGIN
        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'MSAF_DIM_SLS_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'ARQ_DIM'
                          , 2 );

        DECLARE
            -- Inicio Cr01
            -- notas fiscais de serviços emitidas
            CURSOR rel_serv_saida ( ccd_empresa VARCHAR2
                                  , ccd_estab VARCHAR2
                                  , cdt_inicio DATE
                                  , cdt_final DATE )
            IS
                SELECT   dwt07.data_emissao
                       , 'E' serie
                       , ' ' modelo
                       , 'B' natureza
                       , dwt07.num_docfis
                       , dwt07.vlr_tot_nota
                       , SUM ( dwt09.vlr_servico ) vlr_servico
                       , dwt09.aliq_tributo_iss aliquota
                       , x04.insc_municipal
                       , x04.cpf_cgc
                       , '00000000000' cpf
                       , 'AVENIDA' tp_rua
                       , UPPER ( x04.razao_social ) razao_social
                       , UPPER ( x04.endereco ) endereco
                       , x04.num_endereco
                       , UPPER ( x04.compl_endereco ) compl_endereco
                       , UPPER ( x04.bairro ) bairro
                       , UPPER ( x04.cidade ) cidade
                       , UPPER ( uf.cod_estado ) uf
                       , x04.cep
                       , x04.cod_atividade
                       , dwt07.situacao
                    FROM dwt_itens_serv dwt09
                       , dwt_docto_fiscal dwt07
                       , estado uf
                       , x04_pessoa_fis_jur x04
                   WHERE dwt09.ident_docto_fiscal = dwt07.ident_docto_fiscal
                     AND dwt07.ident_fis_jur = x04.ident_fis_jur
                     AND x04.ident_estado = uf.ident_estado
                     AND dwt07.cod_empresa = ccd_empresa --'001'
                     AND dwt07.cod_estab = ccd_estab --'0001'
                     AND dwt07.movto_e_s = '9'
                     AND dwt07.data_fiscal BETWEEN cdt_inicio AND cdt_final
                GROUP BY dwt07.data_emissao
                       , dwt07.num_docfis
                       , dwt07.vlr_tot_nota
                       , dwt09.aliq_tributo_iss
                       , x04.insc_municipal
                       , x04.cpf_cgc
                       , UPPER ( x04.razao_social )
                       , UPPER ( x04.endereco )
                       , x04.num_endereco
                       , UPPER ( x04.compl_endereco )
                       , UPPER ( x04.bairro )
                       , UPPER ( x04.cidade )
                       , UPPER ( uf.cod_estado )
                       , x04.cep
                       , x04.cod_atividade
                       , dwt07.situacao;

            -- Fim Cr01

            -- Início Cr02
            -- notas fiscais de serviços recebidas
            CURSOR rel_serv_ent ( ccd_empresa VARCHAR2
                                , ccd_estab VARCHAR2
                                , cdt_inicio DATE
                                , cdt_final DATE )
            IS
                SELECT   dwt07.dt_pagto_nf
                       , dwt07.data_emissao
                       , 'E' serie
                       , ' ' modelo
                       , 'B' natureza
                       , dwt07.num_docfis
                       , dwt07.vlr_tot_nota
                       , SUM ( dwt09.vlr_servico ) vlr_servico
                       , dwt09.aliq_tributo_iss aliquota
                       , x04.insc_municipal
                       , x04.cpf_cgc
                       , '00000000000' cpf
                       , UPPER ( x04.razao_social ) razao_social
                       , 'AVENIDA' tp_rua
                       , UPPER ( x04.endereco ) endereco
                       , x04.num_endereco
                       , UPPER ( x04.compl_endereco ) compl_endereco
                       , UPPER ( x04.bairro ) bairro
                       , UPPER ( x04.cidade ) cidade
                       , DECODE ( x04.cod_pais, '105', UPPER ( uf.cod_estado ), 'EX' ) uf
                       , x04.cep
                    FROM dwt_itens_serv dwt09
                       , dwt_docto_fiscal dwt07
                       , estado uf
                       , x04_pessoa_fis_jur x04
                   WHERE dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                     AND dwt07.ident_fis_jur = x04.ident_fis_jur
                     AND x04.ident_fis_jur = dwt09.ident_fis_jur
                     AND x04.ident_estado = uf.ident_estado
                     AND dwt07.cod_empresa = ccd_empresa --'001'
                     AND dwt07.cod_estab = ccd_estab --'0001'
                     AND dwt07.movto_e_s <> '9'
                     AND dwt07.situacao = 'N'
                     AND dwt07.data_fiscal BETWEEN cdt_inicio AND cdt_final
                GROUP BY dwt07.dt_pagto_nf
                       , dwt07.data_emissao
                       , dwt07.num_docfis
                       , dwt07.vlr_tot_nota
                       , dwt09.aliq_tributo_iss
                       , x04.insc_municipal
                       , x04.cpf_cgc
                       , UPPER ( x04.razao_social )
                       , UPPER ( x04.endereco )
                       , x04.num_endereco
                       , UPPER ( x04.compl_endereco )
                       , UPPER ( x04.bairro )
                       , UPPER ( x04.cidade )
                       , DECODE ( x04.cod_pais, '105', UPPER ( uf.cod_estado ), 'EX' )
                       , x04.cep;
        -- Fim Cr02

        BEGIN
            BEGIN
                SELECT insc_municipal
                  INTO v_insc_mun
                  FROM estabelecimento
                 WHERE cod_empresa = mcod_empresa
                   AND cod_estab = pcd_estab;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    lib_proc.add_log ( 'FALTA CADASTRAR A INCRIÇÃO MUNICIPAL PARA O ESTABELECIMENTO ' || pcd_estab
                                     , 1 );
            END;

            mlinha :=
                RPAD ( ' '
                     , 15
                     , ' ' );
            mlinha :=
                lib_str.w ( mlinha
                          , 'H'
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , NVL ( v_insc_mun, 0 )
                          , 2 );
            mlinha :=
                lib_str.w ( mlinha
                          , '500'
                          , 13 );
            lib_proc.add ( mlinha );

            -- notas fiscais de serviços - saídas
            FOR mreg IN rel_serv_saida ( mcod_empresa
                                       , pcd_estab
                                       , pdt_inicio
                                       , pdt_final ) LOOP
                mlinha :=
                    RPAD ( ' '
                         , 332
                         , ' ' );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'E'
                              , 1 );

                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.data_emissao
                                        , 'DD/MM/YYYY' )
                              , 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.serie
                              , 12 );
                mlinha :=
                    lib_str.w ( mlinha
                              , ' '
                              , 12 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.natureza
                              , 12 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( mreg.num_docfis
                                     , 9
                                     , '0' )
                              , 16 );

                IF NVL ( UPPER ( mreg.situacao ), 'N' ) = 'N' THEN
                    mlinha :=
                        lib_str.w ( mlinha
                                  , TO_CHAR ( mreg.vlr_tot_nota
                                            , '999999999999.99' )
                                  , 25 );
                    mlinha :=
                        lib_str.w ( mlinha
                                  , TO_CHAR ( mreg.vlr_servico
                                            , '999999999999.99' )
                                  , 40 );
                ELSE
                    mlinha :=
                        lib_str.w ( mlinha
                                  , '000000000000.00'
                                  , 25 );
                    mlinha :=
                        lib_str.w ( mlinha
                                  , '000000000000.00'
                                  , 40 );
                END IF;

                mlinha :=
                    lib_str.w ( mlinha
                              , 'A'
                              , 55 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.aliquota
                                        , '99.99' )
                              , 56 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( NVL ( mreg.insc_municipal, 0 )
                                     , 11
                                     , 0 )
                              , 61 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( NVL ( mreg.cpf_cgc, 0 )
                                     , 14
                                     , 0 )
                              , 72 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cpf
                              , 86 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.razao_social
                              , 97 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.tp_rua
                              , 137 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.endereco
                              , 147 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.num_endereco
                              , 197 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.compl_endereco
                              , 203 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'BAIRRO'
                              , 223 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.bairro
                              , 233 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cidade
                              , 283 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.uf
                              , 313 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cep
                              , 315 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cod_atividade
                              , 323 );
                lib_proc.add ( mlinha );
            END LOOP;

            -- notas fiscais de serviços - entradas
            FOR mreg IN rel_serv_ent ( mcod_empresa
                                     , pcd_estab
                                     , pdt_inicio
                                     , pdt_final ) LOOP
                mlinha :=
                    RPAD ( ' '
                         , 366
                         , ' ' );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'R'
                              , 1 );

                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.dt_pagto_nf
                                        , 'DD/MM/YYYY' )
                              , 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.data_emissao
                                        , 'DD/MM/YYYY' )
                              , 12 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.serie
                              , 22 );
                mlinha :=
                    lib_str.w ( mlinha
                              , ' '
                              , 24 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.natureza
                              , 25 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( mreg.num_docfis
                                     , 9
                                     , '0' )
                              , 26 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.vlr_tot_nota
                                        , '999999999999.99' )
                              , 35 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.vlr_servico
                                        , '999999999999.99' )
                              , 50 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.aliquota
                                        , '99.99' )
                              , 65 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '000000'
                              , 70 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '000000'
                              , 76 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( NVL ( mreg.insc_municipal, 0 )
                                     , 11
                                     , 0 )
                              , 112 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( NVL ( mreg.cpf_cgc, 0 )
                                     , 14
                                     , 0 )
                              , 123 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '00000000000'
                              , 86 );
                mlinha :=
                    lib_str.w ( mlinha
                              , SUBSTR ( mreg.razao_social
                                       , 1
                                       , 40 )
                              , 148 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'RUA'
                              , 188 );
                mlinha :=
                    lib_str.w ( mlinha
                              , SUBSTR ( mreg.endereco
                                       , 1
                                       , 50 )
                              , 198 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.num_endereco
                              , 248 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.compl_endereco
                              , 254 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'BAIRRO'
                              , 274 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.bairro
                              , 284 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cidade
                              , 334 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.uf
                              , 364 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cep
                              , 366 );
                lib_proc.add ( mlinha );
            END LOOP;
        END;

        lib_proc.close ( );
        RETURN mproc_id;
    END;
END msaf_dim_sls_cproc;
/
SHOW ERRORS;
