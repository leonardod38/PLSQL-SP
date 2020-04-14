Prompt Package Body ADEJO_RET_CRED_CIAP_CPROC;
--
-- ADEJO_RET_CRED_CIAP_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY adejo_ret_cred_ciap_cproc
IS
    -- Autor   : Erick P. Alcantara
    -- Created : 19/01/2018
    -- Purpose : Projeto CIAP - Geragco do arquivo TXT e XLSX

    musuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    /* Variaveis de Trabalho */
    mproc_id INTEGER;
    --  vCodEmpresa varchar2(10);
    lastday_aux DATE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'Usuario' );


        lib_proc.add_param (
                             pstr
                           , 'Empresa'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT COD_EMPRESA, COD_EMPRESA||'' - ''||razao_social '
                             || 'FROM EMPRESA WHERE COD_EMPRESA = '''
                             || mcod_empresa
                             || ''' ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT cod_estab, cod_estab||'' - ''||razao_social '
                             || 'FROM estabelecimento WHERE COD_EMPRESA = '''
                             || mcod_empresa
                             || ''' UNION ALL SELECT ''0000'',''Todos'' FROM DUAL '
                             || ' ORDER BY 1'
        );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );

                   /*
lib_proc.add_param(pstr,
                  'Diretsrio do Arquivo',
                  'varchar',
                  'Combobox',
                  'S',
                  'Diretsrio',
                  NULL,
                  'SELECT directory_name, directory_name FROM prt_diretorios_servidor');
                  */

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Geração Retorno de Crédito ICMS - CIAP';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Integragco SAP2';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Etapa de Geragco dos arquivos';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    PROCEDURE geraexcel ( pcod_empresa VARCHAR2
                        , pcod_estab VARCHAR2
                        , pdat_ini DATE
                        , pdat_fim DATE )
    IS
        CURSOR reg
        IS
            SELECT apt.cod_empresa
                 , apt.cod_estab
                 , TO_CHAR ( apt.dat_oper
                           , 'DDMMYYYY' )
                       dat_oper
                 , est.cgc cnpj_emissor
                 , est.cgc cnpj_dest
                 , apt.num_ciap
                 , CASE WHEN apt.ind_e_s = 'E' THEN 'ENTRADA' END ind_e_s
                 , apt.num_oficial_ciap
                 , apt.dat_apuracao
                 , apt.num_docfis
                 , apt.serie_docfis
                 , apt.sub_serie_docfis
                 , apt.dsc_bem
                 , CAST ( apt.vlr_cred_mensal AS NUMBER ( 17, 2 ) ) vlr_cred_mensal
                 , apt.parcela
                 , apt.tipo_mov
                 , 'GRAVADO NO DIRITORIO' status
              FROM apt_dem_base_cr apt
                 , estabelecimento est
             WHERE 1 = 1
               AND apt.cod_estab = est.cod_estab
               AND apt.cod_empresa = pcod_empresa
               AND apt.cod_estab LIKE DECODE ( pcod_estab, '0000', '%', pcod_estab )
               AND apt.dat_apuracao >= pdat_ini
               AND apt.dat_apuracao <= pdat_fim
               AND NVL ( apt.vlr_cred_mensal, 0 ) > 0;

        mlinha VARCHAR2 ( 1000 );
        separador VARCHAR2 ( 1 ) := ';';
    BEGIN
        lib_proc.add_tipo ( mproc_id
                          , 2
                          , 'RETORNOCREDITOICMS_CIAP.CSV'
                          , 2 );
        --LIB_PROC.ADD_TIPO(MPROC_ID, 1, PCOD_EMPRESA||'MA'||'CIAP'||TO_CHAR(CURRENT_TIMESTAMP,'DDMMYYYYHH24MISS')||'.TXT', 2);

        --RELATSRIO EXCEL
        mlinha := NULL;
        mlinha :=
               'COD_EMPRESA'
            || separador
            || 'COD_ESTAB'
            || separador
            || 'DAT_APURACAO'
            || separador
            || 'NUM_CIAP'
            || separador
            || 'IND_E_S'
            || separador
            || 'NUM_OFICIAL_CIAP'
            || separador
            || 'DAT_OPER'
            || separador
            || 'NUM_DOCFIS'
            || separador
            || 'SERIE_DOCFIS'
            || separador
            || 'SUB_SERIE_DOCFIS'
            || separador
            || 'DSC_BEM'
            || separador
            || 'VLR_CRED_MENSAL'
            || separador
            || 'PARCELA'
            || separador
            || 'TIPO_MOV'
            || separador
            || 'STATUS';

        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 2 );

        FOR c_reg IN reg LOOP
            --RELATSRIO EXCEL
            mlinha := NULL;
            mlinha :=
                   c_reg.cod_empresa
                || separador
                || c_reg.cod_estab
                || separador
                || c_reg.dat_apuracao
                || separador
                || c_reg.num_ciap
                || separador
                || c_reg.ind_e_s
                || separador
                || c_reg.num_oficial_ciap
                || separador
                || c_reg.dat_oper
                || separador
                || c_reg.num_docfis
                || separador
                || c_reg.serie_docfis
                || separador
                || c_reg.sub_serie_docfis
                || separador
                || c_reg.dsc_bem
                || separador
                || c_reg.vlr_cred_mensal
                || separador
                || c_reg.parcela
                || separador
                || c_reg.tipo_mov
                || separador
                || c_reg.status;
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 2 );
        END LOOP;
    END;

    PROCEDURE geraarquivo ( pcod_empresa VARCHAR2
                          , pcod_estab VARCHAR2
                          , pdat_ini DATE
                          , pdat_fim DATE )
    IS
        CURSOR reg
        IS
            SELECT apt.cod_empresa
                 , apt.cod_estab
                 , TO_CHAR ( apt.dat_oper
                           , 'DDMMYYYY' )
                       dat_oper
                 , est.cgc AS cnpj_emissor
                 , est.cgc AS cnpj_dest
                 , apt.num_ciap
                 , CASE WHEN apt.ind_e_s = 'E' THEN 'ENTRADA' END ind_e_s
                 , apt.num_oficial_ciap
                 , apt.dat_apuracao
                 , apt.num_docfis
                 , apt.serie_docfis
                 , apt.sub_serie_docfis
                 , apt.dsc_bem
                 , REPLACE ( TRIM ( TO_CHAR ( apt.vlr_cred_mensal
                                            , '0.99' ) )
                           , '.'
                           , ',' )
                       vlr_cred_mensal
                 , apt.parcela
                 , apt.tipo_mov
                 , 'GRAVADO NO DIRITORIO' status
              FROM apt_dem_base_cr apt
                 , estabelecimento est
             WHERE 1 = 1
               AND apt.cod_estab = est.cod_estab
               AND apt.cod_empresa = pcod_empresa
               AND apt.cod_estab LIKE DECODE ( pcod_estab, '0000', '%', pcod_estab )
               AND apt.dat_apuracao >= pdat_ini
               AND apt.dat_apuracao <= pdat_fim
               AND NVL ( apt.vlr_cred_mensal, 0 ) > 0;

        mlinha VARCHAR2 ( 1000 );
        separador VARCHAR2 ( 1 ) := ';';
    BEGIN
        --LIB_PROC.ADD_TIPO(MPROC_ID, 1, 'TESTE.CSV', 2);
        lib_proc.add_tipo (
                            mproc_id
                          , 1
                          ,    ( CASE pcod_empresa
                                    WHEN 'DP' THEN '3000'
                                    WHEN 'DSP' THEN '2000'
                                    WHEN 'DPS' THEN '4000'
                                    ELSE pcod_empresa
                                END )
                            || 'MA'
                            || 'CIAP'
                            || TO_CHAR ( CURRENT_TIMESTAMP
                                       , 'DDMMYYYYHH24MISS' )
                            || '.TXT'
                          , 2
        );

        --CABEGALHO DO ARQUIVO
        -- MLINHA := null;
        -- MLINHA := 'DATA_EMISSAO'||SEPARADOR||'CNPJ_EMISSOE'||SEPARADOR||'CNPJ_DETINATARIO'||SEPARADOR||'VALOR_CREDITO_ICMS';

        --lib_proc.add(mlinha,NULL,NULL,2);

        FOR c_reg IN reg LOOP
            --inicializa variavel
            mlinha := NULL;
            mlinha :=
                   c_reg.dat_oper
                || separador
                || c_reg.cnpj_emissor
                || separador
                || c_reg.cnpj_dest
                || separador
                || c_reg.vlr_cred_mensal;
            --insere linha
            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 1 );
        END LOOP;
    END;

    FUNCTION executar ( pcod_empresa VARCHAR2
                      , pcod_estab VARCHAR2
                      , pdata_ini DATE
                      , pdata_fim DATE )
        RETURN INTEGER
    IS
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'DPSP_TESTE_ADEJO_GERAARQ_CPROC'
                         , 48
                         , 150 );
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        lastday_aux := LAST_DAY ( pdata_ini );

        --Formata saida do relatsrio
        geraexcel ( pcod_empresa
                  , pcod_estab
                  , pdata_ini
                  , pdata_fim );
        --Formata saida do arquivo
        geraarquivo ( pcod_empresa
                    , pcod_estab
                    , pdata_ini
                    , pdata_fim );

        lib_proc.close ( );

        RETURN mproc_id;
    END;
END adejo_ret_cred_ciap_cproc;
/
SHOW ERRORS;
