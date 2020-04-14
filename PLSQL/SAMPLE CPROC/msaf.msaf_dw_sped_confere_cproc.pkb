Prompt Package Body MSAF_DW_SPED_CONFERE_CPROC;
--
-- MSAF_DW_SPED_CONFERE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY "MSAF_DW_SPED_CONFERE_CPROC"
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    vs_razao_social estabelecimento.razao_social%TYPE;
    vn_cnpj VARCHAR2 ( 25 );
    mlinha VARCHAR2 ( 500 );
    vn_pagina NUMBER := 1;
    vn_linhas NUMBER := 0;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        lib_proc.add_param (
                             pstr
                           , 'ESTABELECIMENTO'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT COD_ESTAB, COD_ESTAB||'' - ''||RAZAO_SOCIAL FROM   ESTABELECIMENTO WHERE  COD_EMPRESA = '''
                             || mcod_empresa
                             || ''''
        );


        lib_proc.add_param ( pstr
                           , 'PERÍODO'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'CONTA'
                           , 'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'USAR CONTA REDUZIDA'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'S'
                           , 'N'
                           , NULL );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'SPED Contábil - Validação de Movimentos X Saldos';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Por Conta Contábil';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'SPED CONTÁBIL';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'SPED CONTÁBIL';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'SPED CONTÁBIL';
    END;

    FUNCTION executar ( ps_estab VARCHAR2
                      , pd_periodo DATE
                      , ps_conta VARCHAR2
                      , ps_reduzida VARCHAR2 )
        RETURN INTEGER
    IS
        /* VARIAVEIS DE TRABALHO */
        mproc_id INTEGER;
        vs_descricao x2002_plano_contas.descricao%TYPE;

        vd_data_ini DATE;
        vd_data_fim DATE;

        vn_saldo_final x02_saldos.vlr_saldo_fim%TYPE;
        vn_diferenca x02_saldos.vlr_saldo_fim%TYPE;


        vc_tem_movto CHAR ( 1 ) := 'N';

        CURSOR cur_movtos
        IS
            SELECT   x.cod_conta
                   , x.grupo_conta
                   , SUM ( x.valor_cred_saldo ) valor_cred
                   , SUM ( x.valor_deb_saldo ) valor_deb
                   , SUM ( x.valor_lancto_deb ) valor_lancto_deb
                   , SUM ( x.valor_lancto_cred ) valor_lancto_cred
                FROM (--MOVIMENTAÇÃO X01
                      SELECT   DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta ) cod_conta
                             , x2002.grupo_conta grupo_conta
                             , 0 valor_cred_saldo
                             , 0 valor_deb_saldo
                             , SUM ( DECODE ( x01.ind_deb_cre, 'D', x01.vlr_lancto, 0 ) ) valor_lancto_deb
                             , SUM ( DECODE ( x01.ind_deb_cre, 'C', x01.vlr_lancto, 0 ) ) valor_lancto_cred
                          FROM x01_contabil x01
                             , x2002_plano_contas x2002
                         WHERE x01.ident_conta = x2002.ident_conta
                           AND cod_empresa = mcod_empresa
                           AND cod_estab = ps_estab
                           AND x01.data_lancto BETWEEN vd_data_ini AND vd_data_fim
                           AND cod_conta = NVL ( ps_conta, cod_conta )
                      GROUP BY DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta )
                             , x2002.grupo_conta
                      UNION
                      --MOVIMENTAÇÃO X02
                      SELECT   DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta ) cod_conta
                             , x2002.grupo_conta grupo_conta
                             , SUM ( x02.vlr_tot_cre ) valor_cred_saldo
                             , SUM ( x02.vlr_tot_deb ) valor_deb_saldo
                             , 0 valor_lancto_deb
                             , 0 valor_lancto_cred
                          FROM x02_saldos x02
                             , x2002_plano_contas x2002
                         WHERE x02.ident_conta = x2002.ident_conta
                           AND cod_empresa = mcod_empresa
                           AND cod_estab = ps_estab
                           AND data_saldo = vd_data_fim
                           AND cod_conta = NVL ( ps_conta, cod_conta )
                      GROUP BY DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta )
                             , x2002.grupo_conta) x
            GROUP BY x.cod_conta
                   , x.grupo_conta
              HAVING ( ( SUM ( x.valor_cred_saldo ) <> SUM ( x.valor_lancto_cred ) )
                   OR ( SUM ( x.valor_deb_saldo ) <> SUM ( x.valor_lancto_deb ) ) )
            ORDER BY x.cod_conta;

        CURSOR cur_saldos
        IS
            SELECT   x.cod_conta
                   , x.grupo_conta
                   , SUM ( x.saldo_inicial ) saldo_inicial
                   , SUM ( x.valor_lancto ) valor_lancto
                   , SUM ( x.saldo_final ) saldo_final
                FROM ( --SALDO INICIAL
                       SELECT   DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta ) cod_conta
                              , x2002.grupo_conta grupo_conta
                              , SUM ( DECODE ( x02.ind_saldo_ini, 'C', x02.vlr_saldo_ini * -1, x02.vlr_saldo_ini ) )
                                    saldo_inicial
                              , 0 valor_lancto
                              , 0 saldo_final
                           FROM x02_saldos x02
                              , x2002_plano_contas x2002
                          WHERE x02.ident_conta = x2002.ident_conta
                            AND cod_empresa = mcod_empresa
                            AND cod_estab = ps_estab
                            AND data_saldo = vd_data_fim
                            AND cod_conta = NVL ( ps_conta, cod_conta )
                       GROUP BY DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta )
                              , x2002.grupo_conta
                       UNION
                       --MOVIMENTAÇÃO
                       SELECT   DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta ) cod_conta
                              , x2002.grupo_conta grupo_conta
                              , 0 saldo_inicial
                              , SUM ( DECODE ( x01.ind_deb_cre, 'C', x01.vlr_lancto * -1, x01.vlr_lancto ) ) valor_lancto
                              , 0 saldo_final
                           FROM x01_contabil x01
                              , x2002_plano_contas x2002
                          WHERE x01.ident_conta = x2002.ident_conta
                            AND x01.cod_empresa = mcod_empresa
                            AND x01.cod_estab = ps_estab
                            AND x01.data_lancto BETWEEN vd_data_ini AND vd_data_fim
                            AND cod_conta = NVL ( ps_conta, cod_conta )
                       GROUP BY DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta )
                              , x2002.grupo_conta
                       UNION
                       --SALDO FINAL
                       SELECT   DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta ) cod_conta
                              , x2002.grupo_conta grupo_conta
                              , 0 saldo_inicial
                              , 0 valor_lancto
                              , SUM ( DECODE ( x02.ind_saldo_fim, 'C', x02.vlr_saldo_fim * -1, x02.vlr_saldo_fim ) )
                                    saldo_final
                           FROM x02_saldos x02
                              , x2002_plano_contas x2002
                          WHERE x02.ident_conta = x2002.ident_conta
                            AND cod_empresa = mcod_empresa
                            AND cod_estab = ps_estab
                            AND data_saldo = vd_data_fim
                            AND cod_conta = NVL ( ps_conta, cod_conta )
                       GROUP BY DECODE ( ps_reduzida, 'S', x2002.cod_conta_reduz, x2002.cod_conta )
                              , x2002.grupo_conta ) x
            GROUP BY x.cod_conta
                   , x.grupo_conta
              HAVING ( ( SUM ( x.saldo_inicial ) + SUM ( x.valor_lancto ) - SUM ( x.saldo_final ) ) <> 0 )
            ORDER BY x.cod_conta;
    BEGIN
        -- CRIA PROCESSO
        mproc_id :=
            lib_proc.new ( 'MSAF_DW_SPED_CONFERE_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'CONFERENCIA SPED - MOVIMENTOS X SALDOS'
                          , 1 );
        lib_proc.add_tipo ( mproc_id
                          , 2
                          , 'CONFERENCIA SPED - SALDOS'
                          , 1 );

        vd_data_ini := pd_periodo;
        vd_data_fim := LAST_DAY ( pd_periodo );

        BEGIN
            SELECT      SUBSTR ( cgc
                               , 1
                               , 2 )
                     || '.'
                     || SUBSTR ( cgc
                               , 3
                               , 3 )
                     || '.'
                     || SUBSTR ( cgc
                               , 6
                               , 3 )
                     || '/'
                     || SUBSTR ( cgc
                               , 9
                               , 4 )
                     || '-'
                     || SUBSTR ( cgc
                               , 13
                               , 2 )
                         cgc
                   , cod_estab || ' - ' || estab.razao_social razao_social
                INTO vn_cnpj
                   , vs_razao_social
                FROM estabelecimento estab
               WHERE cod_empresa = mcod_empresa
                 AND cod_estab = ps_estab
            ORDER BY cod_estab;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                vn_cnpj := NULL;
                vs_razao_social := NULL;
        END;

        -- IMPRIME DIFERENÇAS ENTRE MOVIMENTAÇÃO E SALDOS
        -- INICIALIZA VARIAVEIS
        vn_pagina := 1;
        vn_linhas := 50;
        cabecalho ( ps_estab
                  , 1 );


        -- IMPRIME DIFERENÇAS ENTRE SALDOS CONTÁBEIS E MOVIMENTAÇÕES
        vc_tem_movto := 'N';

        FOR reg IN cur_movtos LOOP
            vc_tem_movto := 'S';

            -- BUSCA DESCRIÇÃO DA CONTA
            BEGIN
                SELECT descricao
                  INTO vs_descricao
                  FROM x2002_plano_contas
                 WHERE DECODE ( ps_reduzida, 'S', cod_conta_reduz, cod_conta ) = reg.cod_conta
                   AND grupo_conta = reg.grupo_conta
                   AND valid_conta = (SELECT MAX ( valid_conta )
                                        FROM x2002_plano_contas
                                       WHERE DECODE ( ps_reduzida, 'S', cod_conta_reduz, cod_conta ) = reg.cod_conta
                                         AND grupo_conta = reg.grupo_conta);
            EXCEPTION
                WHEN OTHERS THEN
                    vs_descricao := NULL;
            END;

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.cod_conta
                          , 2 );
            mlinha :=
                lib_str.w ( mlinha
                          , SUBSTR ( vs_descricao
                                   , 1
                                   , 49 )
                          , 20 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.valor_cred
                          , 70 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.valor_deb
                          , 90 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.valor_lancto_cred
                          , 110 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.valor_lancto_deb
                          , 130 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 1 );

            vn_linhas := vn_linhas + 1;
            cabecalho ( ps_estab
                      , 1 );
        END LOOP;

        IF vc_tem_movto = 'N' THEN
            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'N Ã O   E X I S T E M   D I F E R E N Ç A S   A   S E R E M   L I S T A D A S !'
                          , 40 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 1 );
        END IF;


        -- IMPRIME DIFERENÇAS ENTRE SALDOS
        -- INICIALIZA VARIAVEIS
        vn_pagina := 1;
        vn_linhas := 50;
        cabecalho ( ps_estab
                  , 2 );

        -- IMPRIME DIFERENÇAS ENTRE SALDOS CONTÁBEIS E MOVIMENTAÇÕES
        vc_tem_movto := 'N';

        FOR reg IN cur_saldos LOOP
            vc_tem_movto := 'S';

            -- BUSCA DESCRIÇÃO DA CONTA
            BEGIN
                SELECT descricao
                  INTO vs_descricao
                  FROM x2002_plano_contas
                 WHERE DECODE ( ps_reduzida, 'S', cod_conta_reduz, cod_conta ) = reg.cod_conta
                   AND grupo_conta = reg.grupo_conta
                   AND valid_conta = (SELECT MAX ( valid_conta )
                                        FROM x2002_plano_contas
                                       WHERE DECODE ( ps_reduzida, 'S', cod_conta_reduz, cod_conta ) = reg.cod_conta
                                         AND grupo_conta = reg.grupo_conta);
            EXCEPTION
                WHEN OTHERS THEN
                    vs_descricao := NULL;
            END;

            vn_saldo_final := reg.saldo_inicial + reg.valor_lancto;
            vn_diferenca := reg.saldo_final - vn_saldo_final;

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.cod_conta
                          , 2 );
            mlinha :=
                lib_str.w ( mlinha
                          , SUBSTR ( vs_descricao
                                   , 1
                                   , 49 )
                          , 20 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.saldo_inicial
                          , 70 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.valor_lancto
                          , 90 );
            mlinha :=
                lib_str.w ( mlinha
                          , reg.saldo_final
                          , 110 );
            mlinha :=
                lib_str.w ( mlinha
                          , vn_diferenca
                          , 130 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 2 );

            vn_linhas := vn_linhas + 1;
            cabecalho ( ps_estab
                      , 2 );
        END LOOP;

        IF vc_tem_movto = 'N' THEN
            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'N Ã O   E X I S T E M   D I F E R E N Ç A S   A   S E R E M   L I S T A D A S !'
                          , 40 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 2 );
        END IF;


        lib_proc.close ( );
        RETURN mproc_id;
    END;

    PROCEDURE cabecalho ( ps_estab VARCHAR2
                        , prel VARCHAR2 )
    IS
    BEGIN
        IF vn_linhas >= 49 THEN
            -- IMPRIME CABEÇALHO DO LOG
            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'FILIAL : ' || ps_estab || ' - ' || vs_razao_social
                          , 2 );
            mlinha :=
                lib_str.w ( mlinha
                          ,    'PÁGINA : '
                            || LPAD ( vn_pagina
                                    , 5
                                    , '0' )
                          , 136 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , prel );

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          ,    'DATA DE PROCESSAMENTO : '
                            || TO_CHAR ( SYSDATE
                                       , 'DD/MM/RRRR HH24:MI:SS' )
                          , 2 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , prel );

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , LPAD ( '-'
                                 , 200
                                 , '-' )
                          , 1 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , prel );

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );

            IF prel = 1 THEN
                mlinha :=
                    lib_str.w ( mlinha
                              , 'SPED CONTÁBIL - VALIDAÇÃO DE MOVIMENTOS X SALDOS'
                              , 56 );
            ELSE
                mlinha :=
                    lib_str.w ( mlinha
                              , 'SPED CONTÁBIL - VALIDAÇÃO DE SALDOS'
                              , 62 );
            END IF;

            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , prel );

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , LPAD ( '-'
                                 , 200
                                 , '-' )
                          , 1 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , prel );

            IF prel = 1 THEN
                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'SALDO'
                              , 86 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'MOVIMENTAÇÃO'
                              , 122 );
                lib_proc.add ( mlinha
                             , NULL
                             , NULL
                             , prel );

                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '-----------------------------------'
                              , 70 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '-----------------------------------'
                              , 110 );
                lib_proc.add ( mlinha
                             , NULL
                             , NULL
                             , prel );

                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'CONTA'
                              , 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'DESCRIÇÃO'
                              , 20 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'VALOR A CRÉDITO'
                              , 70 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'VALOR A DÉBITO'
                              , 91 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'VALOR A CRÉDITO'
                              , 110 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'VALOR A DÉBITO'
                              , 131 );
                lib_proc.add ( mlinha
                             , NULL
                             , NULL
                             , prel );
            ELSIF prel = 2 THEN
                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'CONTA'
                              , 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'DESCRIÇÃO'
                              , 20 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'SALDO INICIAL'
                              , 72 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'LANÇAMENTOS'
                              , 94 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'SALDO FINAL'
                              , 114 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'DIFERENÇA'
                              , 136 );
                lib_proc.add ( mlinha
                             , NULL
                             , NULL
                             , prel );
            END IF;

            mlinha :=
                lib_str.w ( ''
                          , ' '
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , LPAD ( '-'
                                 , 200
                                 , '-' )
                          , 1 );
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , prel );

            IF prel = 1 THEN
                vn_linhas := 9;
            ELSE
                vn_linhas := 7;
            END IF;

            vn_pagina := vn_pagina + 1;
        END IF;
    END;
END msaf_dw_sped_confere_cproc;
/
SHOW ERRORS;
