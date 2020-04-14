Prompt Package Body SAF_GIA_PE_ANUAL_CPROC;
--
-- SAF_GIA_PE_ANUAL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY saf_gia_pe_anual_cproc
IS
    gslinhareg lib_proc_saida.texto%TYPE;
    gvcodempresa estabelecimento.cod_empresa%TYPE;
    gntotal NUMBER ( 3 );

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        -- A implementar:
        -- formatação dos parametros será:
        -- Titulo|Tipo da Variavel|Mandatorio|Dafault|Select;
        -- Decrição
        -- Titulo..........: Caption a ser mostrado na tela
        -- Tipo da Variavel: Conforme definido no Oracle
        -- Tipo de Controle: Textbox, Listbox, Combobox, Radiobutton ou Checkbox
        -- Mandatorio......: S ou N
        -- Dafault.........: Valor Default para o Campo
        -- Máscara.........: dd/mm/yyyy
        -- Valores.........: Comando SQL para a lista (Código, Descrição)

        gvcodempresa := lib_parametros.recuperar ( 'empresa' );

        lib_proc.add_param ( pstr
                           , 'Exercício'
                           , 'Number'
                           , 'Textbox'
                           , 'S'
                           , '2006'
                           , '0000'
                           , papresenta => 'S' );

        lib_proc.add_param ( pstr
                           , 'Indicador Original/Substituta'
                           , 'Varchar2'
                           , 'Radiobutton'
                           , 'S'
                           , 'N'
                           , pvalores => 'N=Original,S=Substituta'
                           , papresenta => 'S' );

        lib_proc.add_param ( pstr
                           , 'Responsável para Contato'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , ''
                           , 'SELECT cod_responsavel, nom_responsavel FROM resp_informacao ORDER BY nom_responsavel'
                           , 'N' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'Varchar2'
                           , 'Multiproc'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT a.cod_estab,
                               b.cod_estado ||'' - ''||
                               a.cod_estab  ||'' - ''||
                               a.razao_social
                          FROM estabelecimento a,
                               estado b
                         WHERE a.ident_estado = b.ident_estado
                           AND b.cod_estado = ''PE'' AND a.cod_empresa = '''
                             || gvcodempresa
                             || ''' ORDER BY b.cod_estado, a.cod_estab'
                           , 'S'
        );


        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        /* Nome da janela. */
        RETURN 'GIA-PE Eletrônica - Versão 2.5';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Arquivo Magnético';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '2.5';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'GIA-PE Eletrônica - Versão 2.5';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION f_usuario
        RETURN VARCHAR2
    IS
        i VARCHAR2 ( 20 );
    BEGIN
        i := lib_parametros.recuperar ( 'USUARIO' );
        RETURN i;
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Obrigações';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        /* Orientação do Papel. */
        RETURN 'LANDSCAPE';
    END;


    PROCEDURE gravalibproc ( plinhareg IN VARCHAR2 )
    IS
        lsordenacao lib_proc_saida.chave_ordenacao%TYPE;
        lslinhareg lib_proc_saida.texto%TYPE;
    BEGIN
        -- Calculo o seguencial e o total de linhas
        gntotal := gntotal + 1;

        lslinhareg :=
               lib_format.format ( gntotal
                                 , 2
                                 , 6 )
            || plinhareg;

        lsordenacao :=
            lib_format.format ( gntotal
                              , 2
                              , 3 );

        lib_proc.add ( plinha => UPPER ( lslinhareg )
                     , ppag => 1
                     , plin => 1
                     , ptipo => 1
                     , pchaveordenacao => lsordenacao );
    END gravalibproc;

    -- Cabeçalho --
    PROCEDURE cabecalho ( pversao IN NUMBER
                        , prelease IN NUMBER
                        , ptipoversao IN VARCHAR2
                        , pdata IN DATE
                        , phora IN DATE )
    IS
    BEGIN
        gslinhareg := '0';
        gslinhareg :=
               gslinhareg
            || lib_format.format ( 'GIA'
                                 , 1
                                 , 5 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pversao
                                 , 2
                                 , 2 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( prelease
                                 , 2
                                 , 2 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( ptipoversao
                                 , 1
                                 , 1 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( TO_CHAR ( pdata
                                           , 'YYYYMMDD' )
                                 , 1
                                 , 8 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( TO_CHAR ( phora
                                           , 'HH:MM:SS' )
                                 , 1
                                 , 8 );
        gravalibproc ( gslinhareg );
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Cabeçalho - Erro no processamento: ' || TO_CHAR ( SQLCODE ) || ' - ' || SQLERRM
                             , 0 );
    END cabecalho;

    PROCEDURE gerareg1 ( pinsccontrib IN VARCHAR2
                       , pcnpjcontrib IN VARCHAR2
                       , pexercicio IN NUMBER
                       , pindicador IN VARCHAR2
                       , prazaosocial IN VARCHAR2
                       , pcpfresp IN VARCHAR2
                       , pnomeresp IN VARCHAR2
                       , ptel IN NUMBER
                       , pmail IN VARCHAR2 )
    IS
    BEGIN
        gslinhareg := '1';
        gslinhareg :=
               gslinhareg
            || lib_format.format ( '000000'
                                 , 1
                                 , 6 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pinsccontrib
                                 , 2
                                 , 14 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pcnpjcontrib
                                 , 2
                                 , 14 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pexercicio
                                 , 2
                                 , 4 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pindicador
                                 , 1
                                 , 1 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( prazaosocial
                                 , 1
                                 , 46 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pcpfresp
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pnomeresp
                                 , 1
                                 , 40 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( ptel
                                 , 2
                                 , 14 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pmail
                                 , 1
                                 , 40 );
        gravalibproc ( gslinhareg );
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Reg 1 - Erro no processamento: ' || TO_CHAR ( SQLCODE ) || ' - ' || SQLERRM
                             , 0 );
    END gerareg1;


    PROCEDURE gerareg2 ( pvalorcont IN NUMBER
                       , pbasecalc IN NUMBER
                       , poutras IN NUMBER
                       , ppetroleoenergia IN NUMBER
                       , poutrosprodutos IN NUMBER
                       , pvalorcontncontrib IN NUMBER
                       , pvalorcontcontrib IN NUMBER
                       , pbasecalcncontrib IN NUMBER
                       , pbasecalccontrib IN NUMBER
                       , poutrasb IN NUMBER
                       , picmscobradost IN NUMBER )
    IS
    BEGIN
        gslinhareg := '2';
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pvalorcont
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pbasecalc
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( poutras
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( ppetroleoenergia
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( poutrosprodutos
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pvalorcontncontrib
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pvalorcontcontrib
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pbasecalcncontrib
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pbasecalccontrib
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( poutrasb
                                 , 2
                                 , 15 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( picmscobradost
                                 , 2
                                 , 15 );
        gravalibproc ( gslinhareg );
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Reg 2 - Erro no processamento: ' || TO_CHAR ( SQLCODE ) || ' - ' || SQLERRM
                             , 0 );
    END gerareg2;


    PROCEDURE gerareg3 ( pestado IN VARCHAR2
                       , pvalorcont IN NUMBER
                       , pbasecalc IN NUMBER
                       , poutras IN NUMBER
                       , penergia IN NUMBER
                       , poutrosprodutos IN NUMBER )
    IS
    BEGIN
        gslinhareg := '3';
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pestado
                                 , 1
                                 , 2 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pvalorcont
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pbasecalc
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( poutras
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( penergia
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( poutrosprodutos
                                 , 2
                                 , 11 );
        gravalibproc ( gslinhareg );
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Reg 3 - Erro no processamento: ' || TO_CHAR ( SQLCODE ) || ' - ' || SQLERRM
                             , 0 );
    END gerareg3;

    PROCEDURE gerareg4 ( pestado IN VARCHAR2
                       , pvalorcontncontrib IN NUMBER
                       , pvalorcontcontrib IN NUMBER
                       , pbasecalcncontrib IN NUMBER
                       , pbasecalccontrib IN NUMBER
                       , poutras IN NUMBER
                       , psubsttrib IN NUMBER )
    IS
    BEGIN
        gslinhareg := '4';
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pestado
                                 , 1
                                 , 2 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pvalorcontncontrib
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pvalorcontcontrib
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pbasecalcncontrib
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( pbasecalccontrib
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( poutras
                                 , 2
                                 , 11 );
        gslinhareg :=
               gslinhareg
            || lib_format.format ( psubsttrib
                                 , 2
                                 , 11 );
        gravalibproc ( gslinhareg );
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Reg 4 - Erro no processamento: ' || TO_CHAR ( SQLCODE ) || ' - ' || SQLERRM
                             , 0 );
    END gerareg4;

    -- Controle de Patches --

    -- Totalização dos Registros --
    PROCEDURE gerareg9 ( pqtdgia IN NUMBER )
    IS
    BEGIN
        IF gntotal > 0 THEN
            gslinhareg := '9';
            gslinhareg :=
                   gslinhareg
                || lib_format.format ( pqtdgia
                                     , 2
                                     , 6 );
            gslinhareg :=
                   gslinhareg
                || lib_format.format ( gntotal + 1
                                     , 2
                                     , 6 );
            gravalibproc ( gslinhareg );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log (
                                  'Reg 9 (Totalização dos Registros) - Erro no processamento: '
                               || TO_CHAR ( SQLCODE )
                               || ' - '
                               || SQLERRM
                             , 0
            );
    END gerareg9;

    FUNCTION executar ( pexercicio IN NUMBER
                      , porigsubst IN CHAR
                      , pcodresp IN VARCHAR2
                      , pcodestab IN VARCHAR2 )
        RETURN INTEGER
    IS
        TYPE ruf IS RECORD
        (
            ind_e_s CHAR ( 1 )
          , vlr_contabil NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_base_outras_entradas NUMBER ( 17, 2 )
          , vlr_icms_pet NUMBER ( 17, 2 )
          , vlr_icms_out NUMBER ( 17, 2 )
          , vlr_contabil_nc NUMBER ( 17, 2 )
          , vlr_contabil_c NUMBER ( 17, 2 )
          , vlr_base_icms_nc NUMBER ( 17, 2 )
          , vlr_base_icms_c NUMBER ( 17, 2 )
          , vlr_base_outras_saidas NUMBER ( 17, 2 )
          , vlr_icms_s NUMBER ( 17, 2 )
        );

        TYPE tuf IS TABLE OF ruf
            INDEX BY BINARY_INTEGER;

        vuf tuf;
        mproc_id INTEGER;
        lvnom_responsavel resp_informacao.nom_responsavel%TYPE;
        lvnum_cpf resp_informacao.num_cpf%TYPE;
        datainicial DATE;
        datafinal DATE;
        lnindes INTEGER;
        idx INTEGER;
        idxtot INTEGER; -- Índice totalizador (Registro Tipo 2)
        identestado INTEGER;
    BEGIN
        datainicial :=
            TO_DATE ( '0101' || pexercicio
                    , 'ddmmyyyy' );
        datafinal :=
            TO_DATE ( '3112' || pexercicio
                    , 'ddmmyyyy' );

        /* Cria Número de Processo */
        mproc_id :=
            lib_proc.new ( 'SAF_GIA_PE_ANUAL_FPROC'
                         , 48
                         , 150 );

        /* Arquivo */
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'GIAPE'
                          , 2 );

        /* Inicializa Variáveis */
        gntotal := 0;

        -- Cabeçalho
        cabecalho ( '2'
                  , '5'
                  , '1'
                  , SYSDATE
                  , SYSDATE );

        BEGIN
            SELECT r.nom_responsavel
                 , r.num_cpf
              INTO lvnom_responsavel
                 , lvnum_cpf
              FROM resp_informacao r
             WHERE r.cod_responsavel = pcodresp;
        EXCEPTION
            WHEN OTHERS THEN
                lib_proc.add_log (
                                      'Erro ocorrido durante recuperação de informações do Responsável Legal. '
                                   || SQLERRM
                                 , 0
                );
        END;

        vuf.delete;

        /* Criação dos registros */
        FOR cestab IN ( SELECT r.inscricao_estadual
                             , e.cgc
                             , e.razao_social
                             , e.telefone
                             , e.email
                          FROM estabelecimento e
                             , registro_estadual r
                         WHERE e.cod_empresa = gvcodempresa
                           AND e.cod_estab = pcodestab
                           AND e.ident_estado = r.ident_estado
                           AND e.cod_empresa = r.cod_empresa
                           AND e.cod_estab = r.cod_estab ) LOOP
            -- Cabeçalho GIA
            -- Registro 1
            gerareg1 ( cestab.inscricao_estadual
                     , cestab.cgc
                     , pexercicio
                     , porigsubst
                     , cestab.razao_social
                     , lvnum_cpf
                     , lvnom_responsavel
                     , cestab.telefone
                     , cestab.email );

            FOR cresuf
                IN ( SELECT   u.ident_estado ident_estado
                            , u.ind_e_s ind_e_s
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'E', u.vlr_contabil, 0 ) ) ) vlr_contabil
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'E', u.vlr_base_icms, 0 ) ) ) vlr_base_icms
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'E', u.vlr_base_outras, 0 ) ) ) vlr_base_outras_entradas
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'E', u.vlr_icms_pet, 0 ) ) ) vlr_icms_pet
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'E', u.vlr_icms_out, 0 ) ) ) vlr_icms_out
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'S', u.vlr_contabil_nc, 0 ) ) ) vlr_contabil_nc
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'S', u.vlr_contabil_c, 0 ) ) ) vlr_contabil_c
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'S', u.vlr_base_icms_nc, 0 ) ) ) vlr_base_icms_nc
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'S', u.vlr_base_icms_c, 0 ) ) ) vlr_base_icms_c
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'S', u.vlr_base_outras, 0 ) ) ) vlr_base_outras_saidas
                            , TRUNC ( SUM ( DECODE ( u.ind_e_s, 'S', u.vlr_icms_s, 0 ) ) ) vlr_icms_s
                         FROM est_res_uf_01 u
                            , estado e
                        WHERE u.cod_empresa = gvcodempresa
                          AND u.cod_estab = pcodestab
                          AND u.dat_apurac BETWEEN datainicial AND datafinal
                          AND UPPER ( e.cod_estado ) <> 'EX'
                          AND u.ident_estado = e.ident_estado
                     GROUP BY u.ident_estado
                            , u.ind_e_s ) LOOP
                IF cresuf.ind_e_s = 'E' THEN
                    lnindes := 1;
                ELSE
                    lnindes := 2;
                END IF;

                vuf ( lnindes || cresuf.ident_estado ).ind_e_s := cresuf.ind_e_s;
                vuf ( lnindes || cresuf.ident_estado ).vlr_contabil := cresuf.vlr_contabil;
                vuf ( lnindes || cresuf.ident_estado ).vlr_base_icms := cresuf.vlr_base_icms;
                vuf ( lnindes || cresuf.ident_estado ).vlr_base_outras_entradas := cresuf.vlr_base_outras_entradas;
                vuf ( lnindes || cresuf.ident_estado ).vlr_icms_pet := cresuf.vlr_icms_pet;
                vuf ( lnindes || cresuf.ident_estado ).vlr_icms_out := cresuf.vlr_icms_out;
                vuf ( lnindes || cresuf.ident_estado ).vlr_contabil_nc := cresuf.vlr_contabil_nc;
                vuf ( lnindes || cresuf.ident_estado ).vlr_contabil_c := cresuf.vlr_contabil_c;
                vuf ( lnindes || cresuf.ident_estado ).vlr_base_icms_nc := cresuf.vlr_base_icms_nc;
                vuf ( lnindes || cresuf.ident_estado ).vlr_base_icms_c := cresuf.vlr_base_icms_c;
                vuf ( lnindes || cresuf.ident_estado ).vlr_base_outras_saidas := cresuf.vlr_base_outras_saidas;
                vuf ( lnindes || cresuf.ident_estado ).vlr_icms_s := cresuf.vlr_icms_s;
            END LOOP;

            -- Totais dos Quadros I - Entradas  e  II - Saídas
            -- Registro 2
            idx := vuf.FIRST;

            idxtot := vuf.COUNT + 1;

            vuf ( idxtot ).ind_e_s := 'T';

            WHILE idx IS NOT NULL LOOP
                IF idxtot <> idx THEN
                    vuf ( idxtot ).vlr_contabil := NVL ( vuf ( idxtot ).vlr_contabil, 0 ) + vuf ( idx ).vlr_contabil;
                    vuf ( idxtot ).vlr_base_icms := NVL ( vuf ( idxtot ).vlr_base_icms, 0 ) + vuf ( idx ).vlr_base_icms;
                    vuf ( idxtot ).vlr_base_outras_entradas :=
                        NVL ( vuf ( idxtot ).vlr_base_outras_entradas, 0 ) + vuf ( idx ).vlr_base_outras_entradas;
                    vuf ( idxtot ).vlr_icms_pet := NVL ( vuf ( idxtot ).vlr_icms_pet, 0 ) + vuf ( idx ).vlr_icms_pet;
                    vuf ( idxtot ).vlr_icms_out := NVL ( vuf ( idxtot ).vlr_icms_out, 0 ) + vuf ( idx ).vlr_icms_out;
                    vuf ( idxtot ).vlr_contabil_nc :=
                        NVL ( vuf ( idxtot ).vlr_contabil_nc, 0 ) + vuf ( idx ).vlr_contabil_nc;
                    vuf ( idxtot ).vlr_contabil_c :=
                        NVL ( vuf ( idxtot ).vlr_contabil_c, 0 ) + vuf ( idx ).vlr_contabil_c;
                    vuf ( idxtot ).vlr_base_icms_nc :=
                        NVL ( vuf ( idxtot ).vlr_base_icms_nc, 0 ) + vuf ( idx ).vlr_base_icms_nc;
                    vuf ( idxtot ).vlr_base_icms_c :=
                        NVL ( vuf ( idxtot ).vlr_base_icms_c, 0 ) + vuf ( idx ).vlr_base_icms_c;
                    vuf ( idxtot ).vlr_base_outras_saidas :=
                        NVL ( vuf ( idxtot ).vlr_base_outras_saidas, 0 ) + vuf ( idx ).vlr_base_outras_saidas;
                    vuf ( idxtot ).vlr_icms_s := NVL ( vuf ( idxtot ).vlr_icms_s, 0 ) + vuf ( idx ).vlr_icms_s;
                END IF;

                idx := vuf.NEXT ( idx );
            END LOOP;

            gerareg2 ( vuf ( idxtot ).vlr_contabil
                     , vuf ( idxtot ).vlr_base_icms
                     , vuf ( idxtot ).vlr_base_outras_entradas
                     , vuf ( idxtot ).vlr_icms_pet
                     , vuf ( idxtot ).vlr_icms_out
                     , vuf ( idxtot ).vlr_contabil_nc
                     , vuf ( idxtot ).vlr_contabil_c
                     , vuf ( idxtot ).vlr_base_icms_nc
                     , vuf ( idxtot ).vlr_base_icms_c
                     , vuf ( idxtot ).vlr_base_outras_saidas
                     , vuf ( idxtot ).vlr_icms_s );

            vuf.delete ( idxtot );

            -- Entradas de Mercadorias,  Bens e/ou Aquisição de Serviços - Quadro I
            -- Registro 3
            idx := vuf.FIRST;

            WHILE idx IS NOT NULL LOOP
                IF vuf ( idx ).ind_e_s = 'E' THEN
                    identestado :=
                        TO_NUMBER ( SUBSTR ( idx
                                           , 2 ) );

                    DECLARE
                        codestado VARCHAR2 ( 2 );
                    BEGIN
                        SELECT cod_estado
                          INTO codestado
                          FROM estado
                         WHERE ident_estado = identestado;

                        gerareg3 ( codestado
                                 , vuf ( idxtot ).vlr_contabil
                                 , vuf ( idxtot ).vlr_base_icms
                                 , vuf ( idxtot ).vlr_base_outras_entradas
                                 , vuf ( idxtot ).vlr_icms_pet
                                 , vuf ( idxtot ).vlr_icms_out );
                    EXCEPTION
                        WHEN OTHERS THEN
                            codestado := NULL;
                    END;
                END IF;

                idx := vuf.NEXT ( idx );
            END LOOP;

            -- Saídas de Mercadorias,  Bens e/ou Prestação de Serviços - Quadro II
            -- Registro 4
            idx := vuf.FIRST;

            WHILE idx IS NOT NULL LOOP
                IF vuf ( idx ).ind_e_s = 'S' THEN
                    identestado :=
                        TO_NUMBER ( SUBSTR ( idx
                                           , 2 ) );

                    DECLARE
                        codestado VARCHAR2 ( 2 );
                    BEGIN
                        SELECT cod_estado
                          INTO codestado
                          FROM estado
                         WHERE ident_estado = identestado;

                        gerareg4 ( codestado
                                 , vuf ( idx ).vlr_contabil_nc
                                 , vuf ( idx ).vlr_contabil_c
                                 , vuf ( idx ).vlr_base_icms_nc
                                 , vuf ( idx ).vlr_base_icms_c
                                 , vuf ( idx ).vlr_base_outras_saidas
                                 , vuf ( idx ).vlr_icms_s );
                    EXCEPTION
                        WHEN OTHERS THEN
                            codestado := NULL;
                    END;
                END IF;

                idx := vuf.NEXT ( idx );
            END LOOP;
        END LOOP;

        -- Rodapé
        --(Registro 9)
        gerareg9 ( 1 );

        /* Fechamento do processo */
        COMMIT;
        lib_proc.close;
        RETURN mproc_id;
    END; -- Fim Executar
/*PROCEDURE teste IS
 mproc_id INTEGER;
BEGIN
 lib_parametros.salvar('EMPRESA', '076');

   mproc_id := Executar;

 lib_proc.list_output(mproc_id, 1);
 dbms_output.put_line('');
 dbms_output.put_line('---Arquivo Magnetico----');
 dbms_output.put_line('');
 lib_proc.list_output(mproc_id, 2);
   COMMIT;
END;*/
END saf_gia_pe_anual_cproc;
/
SHOW ERRORS;
