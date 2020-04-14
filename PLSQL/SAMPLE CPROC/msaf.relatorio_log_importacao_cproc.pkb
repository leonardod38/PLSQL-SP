Prompt Package Body RELATORIO_LOG_IMPORTACAO_CPROC;
--
-- RELATORIO_LOG_IMPORTACAO_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY relatorio_log_importacao_cproc
IS
    -- Autor   : Pedro A. Puerta
    -- Created : 03/12/2007
    -- Purpose : Diferencial de Aliquota

    mproc_id INTEGER;
    mliblic VARCHAR2 ( 50 );
    mchaveordenacao lib_proc_saida.chave_ordenacao%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        musuario := lib_parametros.recuperar ( 'Usuario' );

        SELECT razao_social
          INTO w_razao
          FROM empresa
         WHERE cod_empresa = mcod_empresa;

        lib_proc.add_param ( pstr
                           , 'Número do Processo'
                           , 'varchar2'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , '##################' );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio Log Completo por Número do processo';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio';
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
        RETURN 'Relatorio Log Completo por Número do processo';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Profarma';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'ESPECIFICOS - Profarma';
    END;

    FUNCTION executar ( pnum_processo IN NUMBER )
        RETURN INTEGER
    IS
        /* Variáveis de Trabalho */
        razaosocialemp_w empresa.razao_social%TYPE;
        razaosocialestab_w estabelecimento.razao_social%TYPE;
        insc_municipalestab_w estabelecimento.insc_municipal%TYPE;
        codinstfinanc_w estabelecimento.cod_inst_financ%TYPE;
        ident_estado_w estabelecimento.ident_estado%TYPE;
        desc_munic_w municipio.descricao%TYPE;
        cod_estado_w estado.cod_estado%TYPE;
        cod_uf_w municipio.cod_uf%TYPE;
        fim_w EXCEPTION;
        mdata_ini DATE;
        mdata_fim DATE;
        mproc_id INTEGER;
        mstatus INTEGER;
        r_dms_dados_ini dms_dados_ini%ROWTYPE;
        prox_w EXCEPTION;
        mcod_municipio municipio.cod_municipio%TYPE;
        mident_estado municipio.ident_estado%TYPE;
        log_prcc log_processo%ROWTYPE;
        tot_lidos_w det_proc_imp.tot_lidos%TYPE;
        tot_ins_w det_proc_imp.tot_ins%TYPE;
        tot_err_w det_proc_imp.tot_err%TYPE;
        tot_alt_w det_proc_imp.tot_alt%TYPE;
        tot_ignorados_w det_proc_imp.tot_ignorados%TYPE;
    BEGIN
        --    lib_parametros.salvar('ESTABELECIMENTO', pcodestab);
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        --    mcod_estab     := pCodEstab;
        mident_estado := NVL ( lib_parametros.recuperar ( 'IdUF' ), '' );
        mcod_municipio := NVL ( lib_parametros.recuperar ( 'IdMunicipio' ), '' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );
        mliblic := UPPER ( lib_parametros.recuperar ( 'LIBLIC' ) );
        --  mdata_ini      := pPeriodoRefIni;
        --    mdata_fim      := pPeriodoRefFim;

        -- CRIANDO O PROCESSO
        mproc_id :=
            lib_proc.new ( 'RELATORIO_LOG_IMPORTACAO_CPROC'
                         , 48
                         , 150
                         , paplicacao => mliblic );

        /*
            -- Obtendo os dados do Estabelecimento
            BEGIN
              SELECT A.RAZAO_SOCIAL,
                B.RAZAO_SOCIAL,
               B.INSC_MUNICIPAL,
                     B.CGC,
                     B.COD_INST_FINANC,
                     B.IDENT_ESTADO,
                     M.DESCRICAO,
                     M.COD_MUNICIPIO,
                     M.COD_UF,
                     E.COD_ESTADO
           INTO   RazaoSocialEmp_w,
                RazaoSocialEstab_w,
               insc_municipalEstab_w,
                     cgcEstab_w,
                     codInstFinanc_w,
                     ident_estado_w,
                     desc_munic_w,
                     cod_municipio_w,
                     cod_uf_w,
                     cod_estado_w
           FROM   EMPRESA         A,
                ESTABELECIMENTO B,
                     MUNICIPIO       M,
                     ESTADO          E
           WHERE  A.COD_EMPRESA = mcod_empresa
              AND    B.COD_ESTAB   = pcodestab
              AND    B.COD_EMPRESA = A.COD_EMPRESA
              AND    M.IDENT_ESTADO= B.IDENT_ESTADO
              AND    M.COD_MUNICIPIO=B.COD_MUNICIPIO
              AND    M.IDENT_ESTADO =E.IDENT_ESTADO;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   NULL;
              WHEN OTHERS THEN
                pkg_log.setCriticidade('E');
                pkg_log.setTitulo('Dados do Estabelecimento');
                pkg_log.setChaveRegistro('Estabelecimento: '||pcodestab);
                pkg_log.setMensagem('Erro na consulta ao cadastro de Estabelecimento.');
                pkg_log.setMensagemBanco(SQLERRM);
                pkg_log.gravaLog;
            END;
        */
        --RETIRAR OS ESPAÇOS DO NOME DO MUNICIPIO

        -- Inclui Header/Footer do Log de Processo
        --    lib_proc.Add_Log(RazaoSocialEmp_w, 0);
        --    lib_proc.Add_Log('Filial: ' || pCodEstab || ' - ' || RazaoSocialEstab_w  ,      0);
        lib_proc.add_log (
                           '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                         , 0
        );
        lib_proc.add_log (
                              '                                                      Relatório de Log de Erros do Processo'
                           || TO_CHAR ( pnum_processo )
                           || ' '
                         , 0
        );
        --    lib_proc.Add_Log('                                                                                Período: ' ||To_char(mdata_ini,'DD/MM/YYYY') || ' a ' || To_char(mdata_fim,'DD/MM/YYYY'), 0);
        lib_proc.add_log (
                              '                                                                                        Numero do Processo: '
                           || mproc_id
                         , 0
        );
        lib_proc.add_log (
                           '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                         , 0
        );

        ---------------------------------------------------------
        -- Relatório de Conferencia                            --
        ---------------------------------------------------------
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Conferência do Processo'
                          , 1 );

        -- Gravação do Cabeçalho do Relatório de Conferencia   --
        ---------------------------------------------------------
        lib_proc.add_tipo ( mproc_id
                          , 2
                          , 'Relatorio_log_Processo_' || TO_CHAR ( pnum_processo ) || '.txt'
                          , 2 );

        BEGIN
            SELECT *
              INTO log_prcc
              FROM log_processo
             WHERE num_processo = pnum_processo;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        mlinha :=
            pkg_mmag_issqn.centraliza (
                                           'Processo: '
                                        || pnum_processo
                                        || '   '
                                        || 'Arquivo: '
                                        || log_prcc.descricao
                                        || '   '
                                        || 'Usuário: '
                                        || log_prcc.cod_usuario
            );
        pkg_mmag_issqn.grava_linha ( mlinha
                                   , 1 );
        mlinha :=
            pkg_mmag_issqn.centraliza (
                                           'Período : '
                                        || TO_CHAR ( log_prcc.data_ini_movto )
                                        || ' a '
                                        || TO_CHAR ( log_prcc.data_fim_movto )
            );
        pkg_mmag_issqn.grava_linha ( mlinha
                                   , 1 );
        mlinha :=
            RPAD ( '-'
                 , 150
                 , '-' );
        pkg_mmag_issqn.grava_linha ( mlinha
                                   , 1 );

        BEGIN
            SELECT tot_lidos
                 , tot_ins
                 , tot_err
                 , tot_alt
                 , tot_ignorados
              INTO tot_lidos_w
                 , tot_ins_w
                 , tot_err_w
                 , tot_alt_w
                 , tot_ignorados_w
              FROM det_proc_imp
             WHERE num_processo = pnum_processo;
        EXCEPTION
            WHEN OTHERS THEN
                tot_lidos_w := NULL;
        END;

        IF log_prcc.ind_processo = 'IMP' THEN
            mlinha := 'Total de Registros Lidos: ' || tot_lidos_w;
            pkg_mmag_issqn.grava_linha ( mlinha
                                       , 1 );
            mlinha := 'Total de Registros Inseridos: ' || tot_ins_w;
            pkg_mmag_issqn.grava_linha ( mlinha
                                       , 1 );
            mlinha := 'Total de Registros com Erro: ' || tot_err_w;
            pkg_mmag_issqn.grava_linha ( mlinha
                                       , 1 );
            mlinha := 'Total de Registros Alterados: ' || tot_alt_w;
            pkg_mmag_issqn.grava_linha ( mlinha
                                       , 1 );
            mlinha := 'Total de Registros Ignorados: ' || tot_ignorados_w;
            pkg_mmag_issqn.grava_linha ( mlinha
                                       , 1 );
        END IF;

        --------------------------------

        mchaveordenacao :=
            LPAD ( '0'
                 , 10
                 , '0' );

        mlinha :=
               'Registro'
            || ';'
            || 'Codigo Erro'
            || ';'
            || 'Descricao Erro'
            || ';'
            || 'Chave do Registro'
            || ';'
            || 'Conteudo do Campo'
            || ';'
            || 'Mensagem do Banco de Dados';

        lib_proc.add ( mlinha
                     , ptipo => 2
                     , pchaveordenacao => mchaveordenacao
                     , plin => 1
                     , ppag => 1 );

        FOR cur_proc IN ( SELECT   l.*
                              FROM log_det_proc l
                             WHERE l.num_processo = pnum_processo
                          ORDER BY l.num_reg ) LOOP
            BEGIN
                mchaveordenacao :=
                    LPAD ( TO_CHAR ( cur_proc.num_reg )
                         , 10
                         , '0' );

                mlinha :=
                       TO_CHAR ( cur_proc.num_reg )
                    || ';'
                    || TO_CHAR ( cur_proc.cod_erro )
                    || ';'
                    || cur_proc.dado_erro
                    || ';'
                    || cur_proc.mens_erro
                    || ';'
                    || cur_proc.mens_compl
                    || ';'
                    || cur_proc.mens_banco;

                lib_proc.add ( mlinha
                             , ptipo => 2
                             , pchaveordenacao => mchaveordenacao
                             , plin => 1
                             , ppag => 1 );
            EXCEPTION
                WHEN prox_w THEN
                    NULL;
            END;
        END LOOP;

        mlinha :=
            RPAD ( '-'
                 , 150
                 , '-' );
        pkg_mmag_issqn.grava_linha ( mlinha
                                   , 1 );

        lib_proc.close ( );

        RETURN mproc_id;
    END;

    PROCEDURE teste
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , '076' );
        mcod_empresa := '076';
        mproc_id := executar ( 0001 );

        lib_proc.list_output ( mproc_id
                             , 1 );

        dbms_output.put_line ( '' );
        dbms_output.put_line ( '---Arquivo Magnetico----' );
        dbms_output.put_line ( '' );
        lib_proc.list_output ( mproc_id
                             , 2 );
    END;
/*
  Procedure Cabecalho(pini date,
                      pfim date ) is
  begin
         if conta = 0 and pfolha = 0 then
           pfolha := 1;
           conta  := 0;
           pPrinta := True;
         elsif conta >= 46 then
           pPrinta := True;
           conta   := 0;
           pfolha  := pfolha + 1;
           mLinha  := LIB_STR.w('',rpad(vLinha, 150, vLinha),1);
           LIB_PROC.add(mLinha);
           lib_proc.new_page();
         else
           pPrinta := False;
         end if;

         If pPrinta then

         mLinha := LIB_STR.w('','',1);
         mLinha := LIB_STR.w(mLinha   , Temp                       , 3);
         mLinha := LIB_STR.wcenter(mLinha   , 'Periodo : '||TO_CHAR(pini, 'DD/MM/RRRR')||' Até '||TO_CHAR(pfIM, 'DD/MM/RRRR')                     , 150);
         mLinha := LIB_STR.wd(mLinha   , 'Data : '||to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss')||'   '||
                                         'Pagina : '||Lpad(pfolha, 3, ' ') , 148);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w('','',1);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w('','',1);
         mLinha := LIB_STR.w(mLinha   , substr(tNome, 1, 50)                       , 3);
         mLinha := LIB_STR.wcenter(mLinha   , 'Insc.Estadual : '||tInscEst , 150);
         mLinha := LIB_STR.wd(mLinha   , 'C.N.P.J. : '||tCpnj , 148);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w('','',1);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w('','',1);
         mLinha := LIB_STR.wcenter(mLinha   , 'Diferencial de Aliquota por Documento' , 150);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w('','',1);
         LIB_PROC.add(mLinha);

         mLinha := LIB_STR.w('',rpad(vLinha, 150, vLinha),1);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w(''       , vSep                            ,1);
         mLinha := LIB_STR.w(mLinha   , ' Numero '                       , 3);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w(mLinha   , ' Dif.Aliq. '                         , length(mLinha)+1);
         mLinha := LIB_STR.w(mLinha   , vSep                            , length(mLinha)+1);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         mLinha := LIB_STR.w('',rpad(vLinha, 150, vLinha),1);
         LIB_PROC.add(mLinha);
         conta := conta + 1;

         end if;

  end cabecalho;
*/
END relatorio_log_importacao_cproc;
/
SHOW ERRORS;
