Prompt Package Body MSAF_RELAT_IMPOSTOS_CPROC;
--
-- MSAF_RELAT_IMPOSTOS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_relat_impostos_cproc
IS
    -- Public variable declarations
    vs_mcod_empresa empresa.cod_empresa%TYPE;
    vs_razao_emp empresa.razao_social%TYPE;
    vs_mcod_estab estabelecimento.cod_estab%TYPE;
    vs_razao_estab estabelecimento.razao_social%TYPE;
    vs_mlinha VARCHAR2 ( 8000 );
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    vn_notas NUMBER := 0;
    -- variaveis para identificação de mudança de nota
    vant_cod_empresa x07_docto_fiscal.cod_empresa%TYPE;
    vant_cod_estab x07_docto_fiscal.cod_estab%TYPE;
    vant_data_fiscal x07_docto_fiscal.data_fiscal%TYPE;
    vant_movto_e_s x07_docto_fiscal.movto_e_s%TYPE;
    vant_norm_dev x07_docto_fiscal.norm_dev%TYPE;
    vant_ident_docto x07_docto_fiscal.ident_docto%TYPE;
    vant_ident_fis_jur x07_docto_fiscal.ident_fis_jur%TYPE;
    vant_num_docfis x07_docto_fiscal.num_docfis%TYPE;
    vant_serie_docfis x07_docto_fiscal.serie_docfis%TYPE;
    vant_sub_serie_docfis x07_docto_fiscal.sub_serie_docfis%TYPE;
    -- variaveis para bases e tributos X07
    -- icms
    v_base_trib_icms x07_base_docfis.vlr_base%TYPE;
    v_base_isen_icms x07_base_docfis.vlr_base%TYPE;
    v_base_outr_icms x07_base_docfis.vlr_base%TYPE;
    v_base_redu_icms x07_base_docfis.vlr_base%TYPE;
    -- i
    -- ipi
    v_base_trib_ipi x07_base_docfis.vlr_base%TYPE;
    v_base_isen_ipi x07_base_docfis.vlr_base%TYPE;
    v_base_outr_ipi x07_base_docfis.vlr_base%TYPE;
    v_base_redu_ipi x07_base_docfis.vlr_base%TYPE;
    -- IR
    v_base_trib_ir x07_base_docfis.vlr_base%TYPE;
    v_base_isen_ir x07_base_docfis.vlr_base%TYPE;
    -- ISS
    v_base_trib_iss x07_base_docfis.vlr_base%TYPE;
    v_base_isen_iss x07_base_docfis.vlr_base%TYPE;
    v_base_outr_iss x07_base_docfis.vlr_base%TYPE;
    -- ISS
    v_base_trib_icmss x07_base_docfis.vlr_base%TYPE;
    v_base_isen_icmss x07_base_docfis.vlr_base%TYPE;
    v_base_outr_icmss x07_base_docfis.vlr_base%TYPE;
    v_base_redu_icmss x07_base_docfis.vlr_base%TYPE;
    -- variaveis aliquotas e tributos
    -- icms
    v_aliq_icms x07_trib_docfis.aliq_tributo%TYPE;
    v_vlr_icms x07_trib_docfis.vlr_tributo%TYPE;
    v_vlr_dif_icms x07_trib_docfis.dif_aliq_tributo%TYPE;
    v_obs_icms x07_trib_docfis.obs_tributo%TYPE;
    v_cod_apur_icms detalhe_operacao.cod_det_operacao%TYPE;
    -- ipi
    v_aliq_ipi x07_trib_docfis.aliq_tributo%TYPE;
    v_vlr_ipi x07_trib_docfis.vlr_tributo%TYPE;
    v_obs_ipi x07_trib_docfis.obs_tributo%TYPE;
    v_cod_apur_ipi detalhe_operacao.cod_det_operacao%TYPE; -- IR
    -- IR
    v_aliq_ir x07_trib_docfis.aliq_tributo%TYPE;
    v_vlr_ir x07_trib_docfis.vlr_tributo%TYPE;
    -- ISS
    v_aliq_iss x07_trib_docfis.aliq_tributo%TYPE;
    v_vlr_iss x07_trib_docfis.vlr_tributo%TYPE;
    -- ISS
    v_aliq_icmss x07_trib_docfis.aliq_tributo%TYPE;
    v_vlr_icmss x07_trib_docfis.vlr_tributo%TYPE;
    v_obs_icmss x07_trib_docfis.obs_tributo%TYPE;
    v_cod_apur_icmss detalhe_operacao.cod_det_operacao%TYPE;
    v_ind_cred_icmss x07_trib_docfis.ind_cred_tributo%TYPE;
    -- Variaveis para tabela X08 (mercadorias)
    -- variaveis para bases e tributos x08
    -- icms
    v_base_trib_icms8 x08_base_merc.vlr_base%TYPE;
    v_base_isen_icms8 x08_base_merc.vlr_base%TYPE;
    v_base_outr_icms8 x08_base_merc.vlr_base%TYPE;
    v_base_redu_icms8 x08_base_merc.vlr_base%TYPE;
    -- ipi
    v_base_trib_ipi8 x08_base_merc.vlr_base%TYPE;
    v_base_isen_ipi8 x08_base_merc.vlr_base%TYPE;
    v_base_outr_ipi8 x08_base_merc.vlr_base%TYPE;
    v_base_redu_ipi8 x08_base_merc.vlr_base%TYPE;
    -- ICMSS
    v_base_trib_icmss8 x08_base_merc.vlr_base%TYPE;
    v_base_isen_icmss8 x08_base_merc.vlr_base%TYPE;
    v_base_outr_icmss8 x08_base_merc.vlr_base%TYPE;
    v_base_redu_icmss8 x08_base_merc.vlr_base%TYPE;
    -- variaveis aliquotas e tributos x08
    -- icms
    v_aliq_icms8 x08_trib_merc.aliq_tributo%TYPE;
    v_vlr_icms8 x08_trib_merc.vlr_tributo%TYPE;
    v_vlr_dif_icms8 x08_trib_merc.dif_aliq_tributo%TYPE;
    v_obs_icms8 x08_trib_merc.obs_tributo%TYPE;
    v_cod_apur_icms8 detalhe_operacao.cod_det_operacao%TYPE;
    -- ipi
    v_aliq_ipi8 x08_trib_merc.aliq_tributo%TYPE;
    v_vlr_ipi8 x08_trib_merc.vlr_tributo%TYPE;
    v_obs_ipi8 x08_trib_merc.obs_tributo%TYPE;
    v_cod_apur_ipi8 detalhe_operacao.cod_det_operacao%TYPE; -- IR
    -- ICMSS
    v_aliq_icmss8 x08_trib_merc.aliq_tributo%TYPE;
    v_vlr_icmss8 x08_trib_merc.vlr_tributo%TYPE;
    v_vlr_dif_icmss8 x08_trib_merc.dif_aliq_tributo%TYPE;
    v_obs_icmss8 x08_trib_merc.obs_tributo%TYPE;
    v_cod_apur_icmss8 detalhe_operacao.cod_det_operacao%TYPE;
    v_ind_cred_icmss8 x08_trib_merc.ind_cred_tributo%TYPE;
    v_ind_fornec_icmss8 x08_trib_merc.ind_fornec_tributo%TYPE;
    -- variaveis para bases e tributos X09
    -- icms
    v_base_trib_icms9 x09_base_serv.vlr_base%TYPE;
    v_base_isen_icms9 x09_base_serv.vlr_base%TYPE;
    v_base_outr_icms9 x09_base_serv.vlr_base%TYPE;
    v_base_redu_icms9 x09_base_serv.vlr_base%TYPE;
    -- IR
    v_base_trib_ir9 x09_base_serv.vlr_base%TYPE;
    v_base_isen_ir9 x09_base_serv.vlr_base%TYPE;
    -- ISS
    v_base_trib_iss9 x09_base_serv.vlr_base%TYPE;
    v_base_isen_iss9 x09_base_serv.vlr_base%TYPE;
    v_base_outr_iss9 x09_base_serv.vlr_base%TYPE;
    -- variaveis aliquotas e tributos
    -- icms
    v_aliq_icms9 x09_trib_serv.aliq_tributo%TYPE;
    v_vlr_icms9 x09_trib_serv.vlr_tributo%TYPE;
    v_vlr_dif_icms9 x09_trib_serv.dif_aliq_tributo%TYPE;
    v_obs_icms9 x09_trib_serv.obs_tributo%TYPE;
    v_cod_apur_icms9 detalhe_operacao.cod_det_operacao%TYPE;
    -- IR
    v_aliq_ir9 x09_trib_serv.aliq_tributo%TYPE;
    v_vlr_ir9 x09_trib_serv.vlr_tributo%TYPE;
    -- ISS
    v_aliq_iss9 x09_trib_serv.aliq_tributo%TYPE;
    v_vlr_iss9 x09_trib_serv.vlr_tributo%TYPE;
    -- variaveis cpdir
    v_cod_fis_jur_cpdir x04_pessoa_fis_jur.cod_fis_jur%TYPE := NULL;
    v_ind_fis_jur_cpdir x04_pessoa_fis_jur.ind_fis_jur%TYPE := NULL;
    v_uf_orig_dest estado.cod_estado%TYPE := NULL;
    v_uf_destino estado.cod_estado%TYPE := NULL;
    v_dt_ini DATE;
    v_dt_fim DATE;
    tab VARCHAR2 ( 20 ) := ';';
    c_numberformat2dec CONSTANT VARCHAR2 ( 50 ) := '99999999999990d99';
    c_numberformat4dec CONSTANT VARCHAR2 ( 50 ) := '90d9999';
    c_numberchar CONSTANT VARCHAR2 ( 50 ) := 'NLS_NUMERIC_CHARACTERS='',.''';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        --    vs_mcod_empresa := LIB_PARAMETROS.RECUPERAR('EMPRESA');
        lib_proc.add_param (
                             pstr
                           , 'Empresa'
                           , 'Varchar2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'Select distinct cod_empresa, cod_empresa||'' - ''||razao_social '
                             || 'from empresa order by 1'
        );
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'Varchar2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'Select distinct cod_estab, cod_estab||'' - ''||razao_social '
                             || 'from estabelecimento where cod_empresa = :1 union all select ''TODOS'',''TODOS'' from dual order by 1'
        );

        lib_proc.add_param ( pstr
                           , 'Data Inicial: '
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );
        lib_proc.add_param ( pstr
                           , 'Data Final: '
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );
        lib_proc.add_param ( pstr
                           , 'Escopo: '
                           , 'Varchar2'
                           , 'Listbox'
                           , 'S'
                           , 2
                           , NULL
                           , '0=Mercadorias,' || '1=Serviços,' || '2=Ambos' );
        lib_proc.add_param ( pstr
                           , 'Movimento: '
                           , 'Varchar2'
                           , 'Listbox'
                           , 'S'
                           , 'A'
                           , NULL
                           , 'S=Saída,' || 'E=Entrada,' || 'A=Ambos' );
        /*    LIB_PROC.add_param(pstr,
                               'Aliz - Procedimentos Customizados',
                               'Varchar2',
                               'TEXT',
                               'N');
            LIB_PROC.add_param(pstr,
                               'Desenvolvido para Accenture do Brasil LTDA.',
                               'Varchar2',
                               'TEXT',
                               'N');
            LIB_PROC.add_param(pstr,
                               'Versao  : ' || versao,
                               'Varchar2',
                               'TEXT',
                               'N');*/
        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorios para consulta dos impostos';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorios';
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
        RETURN '';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorios';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorios';
    END;

    FUNCTION executar ( vs_mcod_empresa VARCHAR2
                      , vs_cod_estab VARCHAR2
                      , vd_dt_inicio DATE
                      , vd_dt_final DATE
                      , vs_escopo VARCHAR2
                      , vs_movto_e_s VARCHAR2 )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */
        mproc_id INTEGER;
    BEGIN
        --    vs_mcod_empresa := '001';
        -- Cria Processo
        mproc_id :=
            lib_proc.new ( $$plsql_unit
                         , 48
                         , 150 );

        IF vs_escopo = '0' THEN
            lib_proc.add_tipo ( mproc_id
                              , 3
                              ,    'Mercadorias_'
                                || TO_CHAR ( vd_dt_inicio
                                           , 'dd-MON-rrrr' )
                                || '_'
                                || TO_CHAR ( vd_dt_final
                                           , 'dd-MON-rrrr' )
                                || '.csv'
                              , 2 );
        ELSIF vs_escopo = '1' THEN
            lib_proc.add_tipo ( mproc_id
                              , 3
                              ,    'Servicos_'
                                || TO_CHAR ( vd_dt_inicio
                                           , 'dd-MON-rrrr' )
                                || '_'
                                || TO_CHAR ( vd_dt_final
                                           , 'dd-MON-rrrr' )
                                || '.csv'
                              , 2 );
        ELSIF vs_escopo = '2' THEN
            lib_proc.add_tipo ( mproc_id
                              , 3
                              ,    'Merc_Serv_'
                                || TO_CHAR ( vd_dt_inicio
                                           , 'dd-MON-rrrr' )
                                || '_'
                                || TO_CHAR ( vd_dt_final
                                           , 'dd-MON-rrrr' )
                                || '.csv'
                              , 2 );
        END IF;

        -- Inicializacao das Variaveis
        vs_mcod_estab := vs_cod_estab;
        v_dt_ini := vd_dt_inicio;
        v_dt_fim := vd_dt_final;
        vant_cod_empresa := ' ';
        vant_cod_estab := ' ';
        vant_data_fiscal :=
            TO_DATE ( '01/01/1900'
                    , 'dd/mm/yyyy' );
        vant_ident_docto := 0;
        vant_ident_fis_jur := 0;
        vant_movto_e_s := ' ';
        vant_norm_dev := ' ';
        vant_num_docfis := ' ';
        vant_serie_docfis := ' ';
        vant_sub_serie_docfis := ' ';
        vn_notas := 0;

        /* Recupera dados do estabelecimento. */
        IF vs_mcod_estab = 'TODOS' THEN
            BEGIN
                SELECT a.razao_social
                  INTO vs_razao_emp
                  FROM empresa a
                 WHERE a.cod_empresa = vs_mcod_empresa;
            EXCEPTION
                WHEN OTHERS THEN
                    lib_proc.add_log (
                                          'erro ao consultar dados da empresa '
                                       || vs_mcod_empresa
                                       || ' e estabelecimento: TODOS '
                                       || SQLERRM
                                     , 1
                    );
            END;

            vs_razao_estab := 'TODOS';
        ELSE
            BEGIN
                SELECT a.razao_social
                     , b.razao_social
                  INTO vs_razao_emp
                     , vs_razao_estab
                  FROM empresa a
                     , estabelecimento b
                 WHERE a.cod_empresa = vs_mcod_empresa
                   AND b.cod_estab = vs_mcod_estab
                   AND b.cod_empresa = a.cod_empresa;
            EXCEPTION
                WHEN OTHERS THEN
                    lib_proc.add_log (
                                          'erro ao consultar dados da empresa '
                                       || vs_mcod_empresa
                                       || ' e estabelecimento '
                                       || vs_mcod_estab
                                       || SQLERRM
                                     , 1
                    );
            END;
        END IF;

        --   if vs_escopo in ('0','2') then
        -- Relatorio Estadual
        vn_pagina := 1;
        vn_linha := 48;
        --cabecalho(1);
        cabecalho_csv ( 3 );
        -- gera aquivo txt
        vs_mlinha :=
               'CIA'
            || tab
            || 'EST'
            || tab
            || 'DT FIS'
            || tab
            || 'EMI'
            || tab
            || 'ES'
            || tab
            || 'ND'
            || tab
            || 'CDO'
            || tab
            || 'MOD'
            || tab
            || 'CFO7'
            || tab
            || 'NF'
            || tab
            || 'SER'
            || tab
            || 'IN_FJ'
            || tab
            || 'CO_FJ'
            || tab
            || --'R.SOC' || tab ||
               'CNPJ'
            || tab
            || 'CO_CL'
            || tab
            || 'NAOP'
            || tab
            || 'NU_D_RE'
            || tab
            || 'NU_D_I_RE'
            || tab
            || 'DT_SR'
            || tab
            || 'IESUB'
            || tab
            || 'VL_PRO'
            || tab
            || 'TO_NF'
            || tab
            || 'FRT'
            || tab
            || 'SEG'
            || tab
            || 'OUT'
            || tab
            || 'DSC'
            || tab
            || 'SIT'
            || tab
            || 'CD_IND'
            || tab
            || 'CTCTB'
            || tab
            || 'AL_ICM'
            || tab
            || 'ICM'
            || tab
            || 'DFICM'
            || tab
            || 'OBICM'
            || tab
            || 'APICM'
            || tab
            || 'ALIPI'
            || tab
            || 'IPI'
            || tab
            || 'OBIPI'
            || tab
            || 'APIPI'
            || tab
            || 'ALIR'
            || tab
            || 'IR'
            || tab
            || 'AL_ISS'
            || tab
            || 'ISS'
            || tab
            || 'AL_ICMSS'
            || tab
            || 'ICMSS'
            || tab
            || 'OBICMSS'
            || tab
            || 'APICMSS'
            || tab
            || 'BTICM'
            || tab
            || 'BIICM'
            || tab
            || 'BOICM'
            || tab
            || 'BRICM'
            || tab
            || 'BTIPI'
            || tab
            || 'BIIPI'
            || tab
            || 'BOIPI'
            || tab
            || 'BRIPI'
            || tab
            || 'BTIR'
            || tab
            || 'BIIR'
            || tab
            || 'BTISS'
            || tab
            || 'BIISS'
            || tab
            || 'BOISS'
            || tab
            || 'BTICMSS'
            || tab
            || 'VCON_CP'
            || tab
            || 'CO_DOC'
            || tab
            || 'AL_DE'
            || tab
            || 'NF_ESP'
            || tab
            || 'TP_FRT'
            || tab
            || 'MUN'
            || tab
            || 'IT_CR'
            || tab
            || 'VTO_SE'
            || tab
            || 'DT_ES_EX'
            || tab
            || 'ICR_ICMSS'
            || tab
            || 'ICMSND'
            || tab
            || 'IPIND'
            || tab
            || 'BINSS'
            || tab
            || 'AL_INSS'
            || tab
            || 'INSS_RE'
            || tab
            || 'MA_AP_ISS'
            || tab
            || 'SUBISS'
            || tab
            || 'IMU_ISS'
            || tab
            || 'ICL_ISS'
            || tab
            || 'OUT1'
            || tab
            || 'DT_FAGER'
            || tab
            || 'DT_CAN'
            || tab
            || 'QUIT'
            || tab
            || 'BPIS'
            || tab
            || 'PIS'
            || tab
            || 'BCOF'
            || tab
            || 'COF'
            || tab
            || 'BIICMSS'
            || tab
            || 'BOICMSS'
            || tab
            || 'BRICMSS'
            || tab
            || 'PER_RB_ICM'
            || tab
            || 'I_FJ_CP'
            || tab
            || 'COD_FJ_CP'
            || tab
            || 'UF_OD'
            || tab
            || 'ICP_VD'
            || tab
            || 'UF_DE'
            || tab
            || 'SIT_ESP'
            || tab
            || 'IE'
            || tab
            || 'PAG_INSS'
            || tab
            || 'INF_SER'
            || tab
            || 'CNPJ_AR_OR'
            || tab
            || 'IE_AR_OR'
            || tab
            || 'CNPJ_AR_DE'
            || tab
            || 'IE_AR_DE'
            || tab
            || 'BPIS_ST'
            || tab
            || 'AL_PIS_ST'
            || tab
            || 'PIS_ST'
            || tab
            || 'BCOF_ST'
            || tab
            || 'AL_COF_ST'
            || tab
            || 'COF_ST'
            || tab
            || 'BCSLL'
            || tab
            || 'AL_CSLL'
            || tab
            || 'CSL'
            || tab
            || 'AL_PIS'
            || tab
            || 'AL_COF'
            || tab
            || 'BICMSS_ST'
            || tab
            || 'ICMSS_ST'
            || tab
            || 'SI_ESP_ST'
            || tab
            || 'ICMSS_ND'
            || tab
            || 'I_DOC_REC'
            || tab
            || 'SITDOC'
            || tab
            || 'OBS7'
            || tab
            || 'MU_OR'
            || tab
            || 'MU_DE'
            || tab
            || 'CFPS'
            || tab
            || 'NU_LC'
            || tab
            || 'B_ISS_RE'
            || tab
            || 'ISS_RE'
            || tab
            || 'DED_ISS'
            || tab
            || 'CL_CO'
            || tab
            || 'TP_CPL_ICM'
            || tab
            || 'PIS_RE'
            || tab
            || 'COF_RE'
            || tab
            || 'DT_LC_PC'
            || tab
            || 'PC_EXT'
            || tab
            || 'CSTPIS'
            || tab
            || 'CSTCOF'
            || tab
            || 'NA_FRT'
            || tab
            || 'NAT_REC'
            || tab
            || 'VE_CAN'
            || tab
            || 'NA_BS_CR'
            || tab
            || 'BL'
            || tab
            || 'S/M'
            || tab
            || 'ITE'
            || tab
            || 'CFO'
            || tab
            || 'DSCCFO'
            || tab
            || 'NAOP1'
            || tab
            || 'PRO'
            || tab
            || 'DSC PRO'
            || tab
            || 'QTD'
            || tab
            || 'NBM'
            || tab
            || 'V UN8'
            || tab
            || 'V IT8'
            || tab
            || 'V DES8'
            || tab
            || 'CST A'
            || tab
            || 'CST B'
            || tab
            || 'AL_ICM8'
            || tab
            || 'ICMS8'
            || tab
            || 'DFICM8'
            || tab
            || 'APICM8'
            || tab
            || 'ALIPI8'
            || tab
            || 'IPI8'
            || tab
            || 'APIPI8'
            || tab
            || 'ALICMSS'
            || tab
            || 'ICMSS'
            || tab
            || 'APICMSS'
            || tab
            || 'BTICM8'
            || tab
            || 'BIICM8'
            || tab
            || 'BOICM8'
            || tab
            || 'BRICM8'
            || tab
            || 'BTIPI8'
            || tab
            || 'BIIPI8'
            || tab
            || 'BOIPI8'
            || tab
            || 'BRIPI8'
            || tab
            || 'BTICMSS8'
            || tab
            || 'BIICMSS8'
            || tab
            || 'BOICMSS8'
            || tab
            || 'BRICMSS8'
            || tab
            || 'VCTA_CP8'
            || tab
            || 'V_AL_DES8'
            || tab
            || 'VCTA_IT'
            || tab
            || 'VO_ICM'
            || tab
            || 'VO_IPI'
            || tab
            || 'VO1'
            || tab
            || 'CR_ICMSS8'
            || tab
            || 'CO_T_INT'
            || tab
            || 'CSTPIS8'
            || tab
            || 'BPIS8'
            || tab
            || 'AL_PIS8'
            || tab
            || 'PIS8'
            || tab
            || 'CSTCOF8'
            || tab
            || 'BCOF8'
            || tab
            || 'AL_COF8'
            || tab
            || 'COF8'
            || tab
            || 'I_FRT'
            || tab
            || 'BICM_OR_DE'
            || tab
            || 'ICM_OR_DE'
            || tab
            || 'AL_ICM_OR_DE'
            || tab
            || 'P_RED_BS_ICM'
            || tab
            || 'BCSL8'
            || tab
            || 'CSL8'
            || tab
            || 'AL_CSL8'
            || tab
            || 'IND_F_ICMSS8'
            || tab
            || 'ST_ESP_ST8'
            || tab
            || 'DOC_REC8'
            || tab
            || 'IVL_PC8'
            || tab
            || 'CO_E_IPI'
            || tab
            || 'Q_BPIS'
            || tab
            || 'AL_PISR'
            || tab
            || 'Q_BCOF'
            || tab
            || 'AL_COFR'
            || tab
            || 'IT_PT'
            || tab
            || 'FUNR'
            || tab
            || 'ITPME'
            || tab
            || 'C_DCA'
            || tab
            || 'TPLC8'
            || tab
            || 'P_CR_O'
            || tab
            || 'CR_OU'
            || tab
            || 'ICM_DCA'
            || tab
            || 'PISEX8'
            || tab
            || 'PISTR8'
            || tab
            || 'PISNTR8'
            || tab
            || 'COEX8'
            || tab
            || 'COTR8'
            || tab
            || 'CONTR8'
            || tab
            || 'CD_EL'
            || tab
            || 'DLC_PC8'
            || tab
            || 'PCEXT8'
            || tab
            || 'COD_SER'
            || tab
            || 'DSC_SER'
            || tab
            || 'V_SER'
            || tab
            || 'TOT'
            || tab
            || 'QT9'
            || tab
            || 'V UN9'
            || tab
            || 'DES9'
            || tab
            || 'AL_ICM9'
            || tab
            || 'ICM9'
            || tab
            || 'DFICM9'
            || tab
            || 'OBICM9'
            || tab
            || 'APICM9'
            || tab
            || 'AL_IR9'
            || tab
            || 'VIR9'
            || tab
            || 'AL_ISS9'
            || tab
            || 'ISS9'
            || tab
            || 'BTICM9'
            || tab
            || 'BIICM9'
            || tab
            || 'BOICM9'
            || tab
            || 'BRICM9'
            || tab
            || 'BTIR9'
            || tab
            || 'BIIR9'
            || tab
            || 'BTISS9'
            || tab
            || 'BIISS9'
            || tab
            || 'BOISS9'
            || tab
            || 'IN_PRD'
            || tab
            || 'B_CSLL'
            || tab
            || 'AL_CSLL'
            || tab
            || 'CSLL'
            || tab
            || 'B_PIS'
            || tab
            || 'AL_PIS'
            || tab
            || 'PIS'
            || tab
            || 'B_COF'
            || tab
            || 'AL_COF'
            || tab
            || 'COF'
            || tab
            || 'CTA9'
            || tab
            || 'OBS9'
            || tab
            || 'CD_T_ISS'
            || tab
            || 'MA_PRO'
            || tab
            || 'MA_TER'
            || tab
            || 'BISS_RE'
            || tab
            || 'ISS_RE'
            || tab
            || 'DEDISS'
            || tab
            || 'SUBISS'
            || tab
            || 'CFPS'
            || tab
            || 'OUDSP'
            || tab
            || 'CSTPIS'
            || tab
            || 'CSTCOF'
            || tab
            || 'BINSS'
            || tab
            || 'INSS_RE'
            || tab
            || 'AL_INSS'
            || tab
            || 'PIS_RE'
            || tab
            || 'COF_RE'
            || tab
            || 'DT_LC_PC9'
            || tab
            || 'I_PC_EX'
            || tab
            || 'NA_REC9'
            || tab
            || 'NA_B_CR9'
            || tab
            || 'B_CI'
            || tab
            || 'AL_CI'
            || tab
            || 'VCI'
            || tab
            || 'VCO9'
            || tab
            || 'IVPC9'
            || tab
            || 'VPEX9'
            || tab
            || 'VPT9'
            || tab
            || 'VPNT9'
            || tab
            || 'VCEX9'
            || tab
            || 'VCT9'
            || tab
            || 'CONTA7'
            || tab
            || 'USER7'
            || tab
            || 'CONTA8'
            || tab
            || 'USER8'
            || tab
            || 'CONTA9'
            || tab
            || 'USER9'
            || tab
            || 'NPROC'
            || tab;

        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 3 );

        FOR mreg
            IN ( SELECT x7.cod_empresa
                      , x7.cod_estab
                      , x7.data_fiscal
                      , x7.movto_e_s
                      , x7.situacao
                      , x5.cod_docto
                      , x7.ident_docto
                      , x7.ident_fis_jur
                      , NULL ind_fis_jur
                      , x24.cod_modelo
                      , x7.num_docfis
                      , x7.serie_docfis
                      , NVL ( x7.sub_serie_docfis, ' ' ) sub_serie_docfis
                      , CASE
                            WHEN x24.cod_modelo IN ( '01'
                                                   , '02'
                                                   , '2D'
                                                   , '1B'
                                                   , '04'
                                                   , '06'
                                                   , '28'
                                                   , '29'
                                                   , '55'
                                                   , '59' ) THEN
                                'C'
                            WHEN x24.cod_modelo IN ( '2E'
                                                   , '07'
                                                   , '08'
                                                   , '8B'
                                                   , '09'
                                                   , '10'
                                                   , '11'
                                                   , '13'
                                                   , '14'
                                                   , '15'
                                                   , '16'
                                                   , '18'
                                                   , '21'
                                                   , '22'
                                                   , '26'
                                                   , '27'
                                                   , '57' ) THEN
                                'D'
                            ELSE
                                ' '
                        END
                            bloco
                      , x7.num_lancamento
                      , x7.num_controle_docto
                      , x7.num_processo
                      , x7.norm_dev
                      , cod_fis_jur
                      , x2002.cod_conta
                      , REPLACE ( x2013.descricao
                                , ';'
                                , '-' )
                            desc_produto
                      , ' ' cod_servico
                      , ' ' desc_servico
                      , x2012.cod_cfo
                      , x2012.descricao desc_cfop
                      , SUBSTR ( cod_fis_jur || ' - ' || razao_social
                               , 1
                               , 47 )
                            fornecedor
                      , razao_social
                      , cpf_cgc cnpj
                      , x7.data_emissao
                      , cod_class_doc_fis
                      , x2006.cod_natureza_op
                      , x7.num_docfis_ref
                      , x7.num_dec_imp_ref
                      , data_saida_rec
                      , insc_estad_substit
                      , x7.vlr_produto vlr_produto_x7
                      , vlr_tot_nota
                      , x7.vlr_frete vlr_frete_x7
                      , x7.vlr_seguro vlr_seguro_x7
                      , x7.vlr_outras vlr_outras_x7
                      , x7.vlr_desconto vlr_desconto_x7
                      , x7.cod_indice
                      , x7.vlr_contab_compl vlr_contab_compl_x7
                      , x7.vlr_aliq_destino vlr_aliq_destino_x7
                      , x7.ind_nf_especial
                      , x7.ind_tp_frete
                      , x7.cod_municipio
                      , x7.ind_transf_cred
                      , x7.vlr_tom_servico
                      , x7.dat_escr_extemp
                      , x7.vlr_icms_ndestac
                      , x7.vlr_ipi_ndestac
                      , x7.vlr_base_inss vlr_base_inss_x7
                      , x7.vlr_aliq_inss vlr_aliq_inss_x7
                      , x7.vlr_inss_retido vlr_inss_retido_x7
                      , x7.vlr_mat_aplic_iss
                      , x7.vlr_subempr_iss vlr_subempr_iss_x7
                      , x7.ind_munic_iss
                      , x7.ind_classe_op_iss
                      , x7.vlr_outros1 vlr_outros1_x7
                      , x7.dat_fato_gerador
                      , x7.dat_cancelamento
                      , x7.vlr_base_pis vlr_base_pis_x7
                      , x7.vlr_pis vlr_pis_x7
                      , x7.vlr_base_cofins vlr_base_cofins_x7
                      , x7.vlr_cofins vlr_cofins_x7
                      , x7.perc_red_base_icms perc_red_base_icms_x7
                      , x7.ind_compra_venda
                      , x7.ind_situacao_esp ind_situacao_esp_x7
                      , x7.insc_estadual
                      , x7.cod_pagto_inss
                      , x7.ind_nota_servico
                      , x7.cnpj_armaz_orig
                      , x7.ins_est_armaz_orig
                      , x7.cnpj_armaz_dest
                      , x7.ins_est_armaz_dest
                      , x7.vlr_base_pis_st
                      , x7.vlr_aliq_pis_st
                      , x7.vlr_pis_st
                      , x7.vlr_base_cofins_st
                      , x7.vlr_aliq_cofins_st
                      , x7.vlr_cofins_st
                      , x7.vlr_base_csll vlr_base_csll_x7
                      , x7.vlr_aliq_csll vlr_aliq_csll_x7
                      , x7.vlr_csll vlr_csll_x7
                      , x7.vlr_aliq_pis vlr_aliq_pis_x7
                      , x7.vlr_aliq_cofins vlr_aliq_cofins_x7
                      , x7.base_icmss_substituido
                      , x7.vlr_icmss_substituido
                      , x7.ind_situacao_esp_st ind_situacao_esp_st_x7
                      , x7.vlr_icmss_ndestac
                      , x7.ind_docto_rec ind_docto_rec_x7
                      , x7.cod_sit_docfis
                      , x7.cod_municipio_orig
                      , x7.cod_municipio_dest
                      , x7.cod_cfps cod_cfps_x7
                      , x7.vlr_base_iss_retido vlr_base_iss_retido_x7
                      , x7.vlr_iss_retido vlr_iss_retido_x7
                      , x7.vlr_deducao_iss vlr_deducao_iss_x7
                      , x7.ind_tp_compl_icms
                      , x7.vlr_pis_retido vlr_pis_retido_x7
                      , x7.vlr_cofins_retido vlr_cofins_retido_x7
                      , x7.dat_lanc_pis_cofins dat_lanc_pis_cofins_x7
                      , x7.ind_pis_cofins_extemp ind_pis_cofins_extemp_x7
                      , x7.cod_sit_pis
                      , x7.cod_sit_cofins
                      , x7.ind_nat_frete
                      , x7.cod_nat_rec
                      , x2014.cod_quitacao
                      , x2013.cod_produto
                      , x43.cod_nbm
                      , x8.num_item
                      , x8.quantidade
                      , x8.vlr_unit
                      , x8.vlr_item
                      , x8.vlr_desconto vlr_desconto8
                      , 0 quantidade9
                      , 0 vlr_unit9
                      , 0 vlr_desconto9
                      , y25.cod_situacao_a
                      , y26.cod_situacao_b
                      , x8.vlr_contab_compl
                      , x8.vlr_aliq_destino
                      , x8.vlr_contab_item
                      , x8.vlr_outros_icms
                      , x8.vlr_outros_ipi
                      , x8.vlr_outros1
                      , x8.cod_trib_int
                      , 0 vlr_servico
                      , 0 vlr_tot
                      , x8.vlr_base_pis vlr_base_pis8
                      , x8.vlr_pis vlr_pis8
                      , x8.vlr_aliq_pis vlr_aliq_pis8
                      , x8.vlr_base_cofins vlr_base_cofins8
                      , x8.vlr_cofins vlr_cofins8
                      , x8.vlr_aliq_cofins vlr_aliq_cofins8
                      , x8.cod_situacao_pis cod_situacao_pis8
                      , x8.cod_situacao_cofins cod_situacao_cofins8
                      , 0 vlr_base_pis9
                      , 0 vlr_pis9
                      , 0 vlr_aliq_pis9
                      , 0 vlr_base_cofins9
                      , 0 vlr_cofins9
                      , 0 vlr_aliq_cofins9
                      , NULL cod_situacao_pis9
                      , NULL cod_situacao_cofins9
                      , NULL dat_lanc_pis_cofins9
                      , x8.ind_natureza_frete
                      , x8.vlr_icms_origdest
                      , x8.base_icms_origdest
                      , x8.aliq_icms_origdest
                      , x8.perc_red_base_icms
                      , x8.vlr_base_csll vlr_base_csll8
                      , x8.vlr_aliq_csll vlr_aliq_csll8
                      , x8.vlr_csll vlr_csll8
                      , 0 vlr_base_csll9
                      , 0 vlr_aliq_csll9
                      , 0 vlr_csll9
                      , x8.ind_situacao_esp_st
                      , x8.ind_docto_rec
                      , x8.ind_vlr_pis_cofins
                      , x8.cod_enquad_ipi
                      , NULL cod_observacao
                      , NULL cod_trib_iss
                      , NULL vlr_mat_prop
                      , NULL vlr_mat_terc
                      , NULL vlr_base_iss_retido
                      , NULL vlr_iss_retido
                      , NULL vlr_deducao_iss
                      , NULL vlr_subempr_iss
                      , NULL cod_cfps
                      , NULL vlr_out_desp
                      , NULL vlr_base_inss
                      , NULL vlr_inss_retido
                      , NULL vlr_aliq_inss
                      , NULL vlr_pis_retido
                      , NULL vlr_cofins_retido
                      , x8.ind_pis_cofins_extemp
                      , NULL ind_nat_base_cred9
                      , x8.discri_item
                      , 'M' serv_merc
                      , NULL ind_produto
                      , x7.ident_fisjur_cpdir
                      , x7.ident_uf_orig_dest
                      , x7.ident_uf_destino
                      , x2009b.cod_observacao cod_observacao7
                      , dwt_cc.cod_classe_consumo
                      , x2006b.cod_natureza_op cod_natureza_op1
                      , x2012a.cod_cfo cod_cfo7
                      , x7.ind_venda_canc
                      , NULL cod_conta9
                      , x7.ind_nat_base_cred
                      , x8.qtd_base_pis
                      , x8.vlr_aliq_pis_r
                      , x8.qtd_base_cofins
                      , x8.vlr_aliq_cofins_r
                      , x8.item_port_tare
                      , x8.vlr_funrural
                      , x8.ind_tp_prod_medic
                      , x8.vlr_custo_dca
                      , x8.cod_tp_lancto cod_tp_lancto8
                      , x8.vlr_perc_cred_out
                      , x8.vlr_cred_out
                      , x8.vlr_icms_dca
                      , x8.vlr_pis_exp vlr_pis_exp8
                      , x8.vlr_pis_trib vlr_pis_trib8
                      , x8.vlr_pis_n_trib vlr_pis_n_trib8
                      , x8.vlr_cofins_exp vlr_cofins_exp8
                      , x8.vlr_cofins_trib vlr_cofins_trib8
                      , x8.vlr_cofins_n_trib vlr_cofins_n_trib8
                      , x8.cod_enq_legal
                      , x8.dat_lanc_pis_cofins dat_lanc_pis_cofins8
                      , x8.ind_pis_cofins_extemp ind_pis_cofins_extemp8
                      , NULL vlr_base_cide
                      , NULL vlr_aliq_cide
                      , NULL vlr_cide
                      , NULL vlr_comissao9
                      , NULL ind_vlr_pis_cofins9
                      , NULL vlr_pis_exp9
                      , NULL vlr_pis_trib9
                      , NULL vlr_pis_n_trib9
                      , NULL vlr_cofins_exp9
                      , NULL vlr_cofins_trib9
                      , x2002.cod_conta conta7
                      , x7.usuario user7
                      , x2002b.cod_conta conta8
                      , x8.usuario user8
                      , NULL conta9
                      , NULL user9
                   FROM x07_docto_fiscal x7
                        JOIN x08_itens_merc x8
                            ON ( x7.cod_empresa = x8.cod_empresa
                            AND x7.cod_estab = x8.cod_estab
                            AND x7.data_fiscal = x8.data_fiscal
                            AND x7.movto_e_s = x8.movto_e_s
                            AND x7.norm_dev = x8.norm_dev
                            AND x7.ident_docto = x8.ident_docto
                            AND x7.ident_fis_jur = x8.ident_fis_jur
                            AND x7.num_docfis = x8.num_docfis
                            AND x7.serie_docfis = x8.serie_docfis
                            AND x7.sub_serie_docfis = x8.sub_serie_docfis )
                        JOIN x04_pessoa_fis_jur x4 ON ( x7.ident_fis_jur = x4.ident_fis_jur )
                        JOIN x2005_tipo_docto x5 ON ( x7.ident_docto = x5.ident_docto )
                        JOIN x2024_modelo_docto x24 ON ( x7.ident_modelo = x24.ident_modelo )
                        LEFT OUTER JOIN x2012_cod_fiscal x2012a ON ( x7.ident_cfo = x2012a.ident_cfo )
                        LEFT OUTER JOIN x2006_natureza_op x2006 ON ( x7.ident_natureza_op = x2006.ident_natureza_op )
                        LEFT OUTER JOIN x2014_quitacao x2014 ON ( x7.ident_quitacao = x2014.ident_quitacao )
                        LEFT OUTER JOIN x2006_natureza_op x2006b ON ( x8.ident_natureza_op = x2006b.ident_natureza_op )
                        LEFT OUTER JOIN x2043_cod_nbm x43 ON ( x8.ident_nbm = x43.ident_nbm )
                        LEFT OUTER JOIN x2002_plano_contas x2002 ON ( x7.ident_conta = x2002.ident_conta )
                        LEFT OUTER JOIN x2002_plano_contas x2002b ON ( x8.ident_conta = x2002b.ident_conta )
                        LEFT OUTER JOIN x2012_cod_fiscal x2012 ON ( x8.ident_cfo = x2012.ident_cfo )
                        LEFT OUTER JOIN x2013_produto x2013 ON ( x8.ident_produto = x2013.ident_produto )
                        LEFT OUTER JOIN y2025_sit_trb_uf_a y25 ON ( x8.ident_situacao_a = y25.ident_situacao_a )
                        LEFT OUTER JOIN y2026_sit_trb_uf_b y26 ON ( x8.ident_situacao_b = y26.ident_situacao_b )
                        LEFT OUTER JOIN x2009_observacao x2009 ON ( x8.ident_observacao = x2009.ident_observacao )
                        LEFT OUTER JOIN x2009_observacao x2009b ON ( x7.ident_observacao = x2009b.ident_observacao )
                        LEFT OUTER JOIN dwt_classe_consumo dwt_cc
                            ON ( x7.ident_classe_consumo = dwt_cc.ident_classe_consumo )
                  WHERE x7.cod_empresa = vs_mcod_empresa
                    AND x7.cod_estab = DECODE ( vs_mcod_estab, 'TODOS', x7.cod_estab, vs_mcod_estab )
                    AND x7.data_fiscal BETWEEN v_dt_ini AND v_dt_fim
                    AND vs_escopo IN ( '0'
                                     , '2' )
                    AND DECODE ( x7.movto_e_s, '9', 'S', 'E' ) =
                            DECODE ( vs_movto_e_s
                                   , 'A', DECODE ( x7.movto_e_s, '9', 'S', 'E' )
                                   , 'S', DECODE ( x7.movto_e_s, '9', 'S', 'Z' )
                                   , DECODE ( x7.movto_e_s, '9', 'Z', 'E' ) )
                UNION ALL
                -- SErviços
                SELECT cod_empresa
                     , cod_estab
                     , data_fiscal
                     , movto_e_s
                     , x7.situacao
                     , x5.cod_docto
                     , ident_docto
                     , ident_fis_jur
                     , NULL ind_fis_jur
                     , x24.cod_modelo
                     , num_docfis
                     , serie_docfis
                     , NVL ( sub_serie_docfis, ' ' ) sub_serie_docfis
                     , 'A' bloco
                     , x7.num_lancamento
                     , x7.num_controle_docto
                     , x7.num_processo
                     , norm_dev
                     , cod_fis_jur
                     , x2002.cod_conta
                     , ' ' desc_produto
                     , cod_servico
                     , REPLACE ( x2018.descricao
                               , ';'
                               , '-' )
                           desc_servico
                     , x2012.cod_cfo
                     , x2012.descricao desc_cfop
                     , SUBSTR ( cod_fis_jur || ' - ' || razao_social
                              , 1
                              , 47 )
                           fornecedor
                     , razao_social
                     , cpf_cgc cnpj
                     , x7.data_emissao
                     , cod_class_doc_fis
                     , x2006.cod_natureza_op
                     , num_docfis_ref
                     , num_dec_imp_ref
                     , data_saida_rec
                     , insc_estad_substit
                     , x7.vlr_produto vlr_produto_x7
                     , vlr_tot_nota
                     , x7.vlr_frete vlr_frete_x7
                     , x7.vlr_seguro vlr_seguro_x7
                     , x7.vlr_outras vlr_outras_x7
                     , x7.vlr_desconto vlr_desconto_x7
                     , x7.cod_indice
                     , x7.vlr_contab_compl
                     , x7.vlr_aliq_destino
                     , x7.ind_nf_especial
                     , x7.ind_tp_frete
                     , x7.cod_municipio
                     , x7.ind_transf_cred
                     , x7.vlr_tom_servico
                     , x7.dat_escr_extemp
                     , x7.vlr_icms_ndestac
                     , x7.vlr_ipi_ndestac
                     , x7.vlr_base_inss
                     , x7.vlr_aliq_inss
                     , x7.vlr_inss_retido
                     , x7.vlr_mat_aplic_iss
                     , x7.vlr_subempr_iss
                     , x7.ind_munic_iss
                     , x7.ind_classe_op_iss
                     , x7.vlr_outros1
                     , x7.dat_fato_gerador
                     , x7.dat_cancelamento
                     , x7.vlr_base_pis
                     , x7.vlr_pis
                     , x7.vlr_base_cofins
                     , x7.vlr_cofins
                     , x7.perc_red_base_icms
                     , x7.ind_compra_venda
                     , x7.ind_situacao_esp
                     , x7.insc_estadual
                     , x7.cod_pagto_inss
                     , x7.ind_nota_servico
                     , x7.cnpj_armaz_orig
                     , x7.ins_est_armaz_orig
                     , x7.cnpj_armaz_dest
                     , x7.ins_est_armaz_dest
                     , x7.vlr_base_pis_st
                     , x7.vlr_aliq_pis_st
                     , x7.vlr_pis_st
                     , x7.vlr_base_cofins_st
                     , x7.vlr_aliq_cofins_st
                     , x7.vlr_cofins_st
                     , x7.vlr_base_csll vlr_base_csll_x7
                     , x7.vlr_aliq_csll vlr_aliq_csll_x7
                     , x7.vlr_csll vlr_csll_x7
                     , x7.vlr_aliq_pis
                     , x7.vlr_aliq_cofins_st
                     , x7.base_icmss_substituido
                     , x7.vlr_icmss_substituido
                     , x7.ind_situacao_esp_st
                     , x7.vlr_icmss_ndestac
                     , x7.ind_docto_rec
                     , x7.cod_sit_docfis
                     , x7.cod_municipio_orig
                     , x7.cod_municipio_dest
                     , x7.cod_cfps
                     , x7.vlr_base_iss_retido
                     , x7.vlr_iss_retido
                     , x7.vlr_deducao_iss
                     , x7.ind_tp_compl_icms
                     , x7.vlr_pis_retido
                     , x7.vlr_cofins_retido
                     , x7.dat_lanc_pis_cofins
                     , x7.ind_pis_cofins_extemp
                     , x7.cod_sit_pis
                     , x7.cod_sit_cofins
                     , x7.ind_nat_frete
                     , x7.cod_nat_rec
                     , x2014.cod_quitacao
                     , ' ' cod_produto
                     , ' ' cod_nbm
                     , x9.num_item
                     , 0 quantidade
                     , 0 vlr_unit
                     , 0 vlr_item
                     , 0 vlr_desconto8
                     , x9.quantidade
                     , x9.vlr_unit
                     , x9.vlr_desconto
                     , ' ' cod_situacao_a
                     , ' ' cod_situacao_b
                     , 0 vlr_contab_compl
                     , 0 vlr_aliq_destino
                     , 0 vlr_contab_item
                     , 0 vlr_outros_icms
                     , 0 vlr_outros_ipi
                     , 0 vlr_outros1
                     , NULL cod_trib_int
                     , x9.vlr_servico
                     , x9.vlr_tot
                     , 0 vlr_base_pis8
                     , 0 vlr_pis8
                     , 0 vlr_aliq_pis8
                     , 0 vlr_base_cofins8
                     , 0 vlr_cofins8
                     , 0 vlr_aliq_cofins8
                     , NULL cod_situacao_pis8
                     , NULL cod_situacao_cofins8
                     , x9.vlr_base_pis
                     , x9.vlr_pis
                     , x9.vlr_aliq_pis
                     , x9.vlr_base_cofins
                     , x9.vlr_cofins
                     , x9.vlr_aliq_cofins
                     , x9.cod_situacao_pis
                     , x9.cod_situacao_cofins
                     , x9.dat_lanc_pis_cofins
                     , ' ' ind_natureza_frete
                     , NULL vlr_icms_origdest
                     , NULL base_icms_origdest
                     , NULL aliq_icms_origdest
                     , NULL perc_red_base_icms
                     , 0 vlr_base_csll8
                     , 0 vlr_aliq_csll8
                     , 0 vlr_csll8
                     , x9.vlr_base_csll vlr_base_csll8
                     , x9.vlr_aliq_csll vlr_aliq_csll8
                     , x9.vlr_csll vlr_csll8
                     , NULL ind_situacao_esp_st
                     , NULL ind_docto_rec
                     , x9.ind_vlr_pis_cofins
                     , NULL cod_enquad_ipi
                     , x2009.cod_observacao
                     , x9.cod_trib_iss
                     , x9.vlr_mat_prop
                     , x9.vlr_mat_terc
                     , x9.vlr_base_iss_retido
                     , x9.vlr_iss_retido
                     , x9.vlr_deducao_iss
                     , x9.vlr_subempr_iss
                     , x9.cod_cfps
                     , x9.vlr_out_desp
                     , x9.vlr_base_inss
                     , x9.vlr_inss_retido
                     , x9.vlr_aliq_inss
                     , x9.vlr_pis_retido
                     , x9.vlr_cofins_retido
                     , x9.ind_pis_cofins_extemp
                     , x9.ind_nat_base_cred ind_nat_base_cred9
                     , NULL discri_item
                     , 'S' serv_merc
                     , x2013.ind_produto
                     , x7.ident_fisjur_cpdir
                     , x7.ident_uf_orig_dest
                     , x7.ident_uf_destino
                     , x2009b.cod_observacao cod_observacao7
                     , dwt_cc.cod_classe_consumo
                     , x2006b.cod_natureza_op cod_natureza_op1
                     , x2012a.cod_cfo cod_cfo7
                     , x7.ind_venda_canc
                     , x2002a.cod_conta cod_conta9
                     , x7.ind_nat_base_cred
                     , NULL qtd_base_pis
                     , NULL vlr_aliq_pis_r
                     , NULL qtd_base_cofins
                     , NULL vlr_aliq_cofins_r
                     , NULL item_port_tare
                     , NULL vlr_funrural
                     , NULL ind_tp_prod_medic
                     , NULL vlr_custo_dca
                     , NULL cod_tp_lancto
                     , NULL vlr_perc_cred_out
                     , NULL vlr_cred_out
                     , NULL vlr_icms_dca
                     , NULL vlr_pis_exp
                     , NULL vlr_pis_trib8
                     , NULL vlr_pis_n_trib
                     , NULL vlr_cofins_exp8
                     , NULL vlr_cofins_trib
                     , NULL vlr_cofins_n_trib
                     , NULL cod_enq_legal
                     , NULL dat_lanc_pis_cofins
                     , NULL ind_pis_cofins_extemp
                     , x9.vlr_base_cide
                     , x9.vlr_aliq_cide
                     , x9.vlr_cide
                     , x9.vlr_comissao
                     , x9.ind_vlr_pis_cofins
                     , x9.vlr_pis_exp
                     , x9.vlr_pis_trib
                     , x9.vlr_pis_n_trib
                     , x9.vlr_cofins_exp
                     , x9.vlr_cofins_trib
                     , x2002.cod_conta conta7
                     , x7.usuario user7
                     , NULL conta8
                     , NULL user8
                     , x2002a.cod_conta conta9
                     , x9.usuario user9
                  FROM x07_docto_fiscal x7
                       JOIN x09_itens_serv x9
                           USING (cod_empresa
                                , cod_estab
                                , data_fiscal
                                , movto_e_s
                                , norm_dev
                                , ident_docto
                                , ident_fis_jur
                                , num_docfis
                                , serie_docfis
                                , sub_serie_docfis)
                       JOIN x04_pessoa_fis_jur x4 USING (ident_fis_jur)
                       JOIN x2005_tipo_docto x5 USING (ident_docto)
                       JOIN x2024_modelo_docto x24 ON ( x7.ident_modelo = x24.ident_modelo )
                       LEFT OUTER JOIN x2012_cod_fiscal x2012a ON ( x7.ident_cfo = x2012a.ident_cfo )
                       LEFT OUTER JOIN x2006_natureza_op x2006 ON ( x7.ident_natureza_op = x2006.ident_natureza_op )
                       LEFT OUTER JOIN x2014_quitacao x2014 ON ( x7.ident_quitacao = x2014.ident_quitacao )
                       LEFT OUTER JOIN x2006_natureza_op x2006b ON ( x9.ident_natureza_op = x2006b.ident_natureza_op )
                       LEFT OUTER JOIN x2018_servicos x2018 ON ( x9.ident_servico = x2018.ident_servico )
                       LEFT OUTER JOIN x2002_plano_contas x2002 ON ( x7.ident_conta = x2002.ident_conta )
                       LEFT OUTER JOIN x2002_plano_contas x2002a ON ( x9.ident_conta = x2002a.ident_conta )
                       LEFT OUTER JOIN x2012_cod_fiscal x2012 ON ( x9.ident_cfo = x2012.ident_cfo )
                       LEFT OUTER JOIN x2009_observacao x2009 ON ( x9.ident_observacao = x2009.ident_observacao )
                       LEFT OUTER JOIN x2013_produto x2013 ON ( x9.ident_produto = x2013.ident_produto )
                       LEFT OUTER JOIN x2009_observacao x2009b ON ( x7.ident_observacao = x2009b.ident_observacao )
                       LEFT OUTER JOIN dwt_classe_consumo dwt_cc
                           ON ( x7.ident_classe_consumo = dwt_cc.ident_classe_consumo )
                 WHERE cod_empresa = vs_mcod_empresa
                   AND cod_estab = DECODE ( vs_mcod_estab, 'TODOS', cod_estab, vs_mcod_estab )
                   AND vs_escopo IN ( '1'
                                    , '2' )
                   AND data_fiscal BETWEEN v_dt_ini AND v_dt_fim
                   AND DECODE ( movto_e_s, '9', 'S', 'E' ) =
                           DECODE ( vs_movto_e_s
                                  , 'A', DECODE ( movto_e_s, '9', 'S', 'E' )
                                  , 'S', DECODE ( movto_e_s, '9', 'S', 'Z' )
                                  , DECODE ( movto_e_s, '9
'                                    , 'Z', 'E' ) )
                ORDER BY cod_empresa
                       , cod_estab
                       , data_fiscal
                       , movto_e_s
                       , norm_dev
                       , ident_docto
                       , ident_fis_jur
                       , num_docfis
                       , serie_docfis
                       , sub_serie_docfis
                       , num_item ) LOOP
            -- Guarda nota Anterior
            IF vant_cod_empresa <> mreg.cod_empresa
            OR vant_cod_estab <> mreg.cod_estab
            OR vant_data_fiscal <> mreg.data_fiscal
            OR vant_ident_docto <> mreg.ident_docto
            OR vant_ident_fis_jur <> mreg.ident_fis_jur
            OR vant_movto_e_s <> mreg.movto_e_s
            OR vant_norm_dev <> mreg.norm_dev
            OR vant_num_docfis <> mreg.num_docfis
            OR vant_serie_docfis <> mreg.serie_docfis
            OR vant_sub_serie_docfis <> mreg.sub_serie_docfis THEN
                vant_cod_empresa := mreg.cod_empresa;
                vant_cod_estab := mreg.cod_estab;
                vant_data_fiscal := mreg.data_fiscal;
                vant_ident_docto := mreg.ident_docto;
                vant_ident_fis_jur := mreg.ident_fis_jur;
                vant_movto_e_s := mreg.movto_e_s;
                vant_norm_dev := mreg.norm_dev;
                vant_num_docfis := mreg.num_docfis;
                vant_serie_docfis := mreg.serie_docfis;
                vant_sub_serie_docfis := mreg.sub_serie_docfis;
                vn_notas := vn_notas + 1;
            END IF;

            -- Limpa variaveis X07
            v_base_trib_icms := NULL;
            v_base_isen_icms := NULL;
            v_base_outr_icms := NULL;
            v_base_redu_icms := NULL;
            v_base_trib_ipi := NULL;
            v_base_isen_ipi := NULL;
            v_base_outr_ipi := NULL;
            v_base_redu_ipi := NULL;
            v_base_trib_ir := NULL;
            v_base_isen_ir := NULL;
            v_base_trib_iss := NULL;
            v_base_isen_iss := NULL;
            v_base_outr_iss := NULL;
            v_base_trib_icmss := NULL;
            v_base_isen_icmss := NULL;
            v_base_outr_icmss := NULL;
            v_base_redu_icmss := NULL;

            BEGIN
                SELECT cod_fis_jur
                     , ind_fis_jur
                  INTO v_cod_fis_jur_cpdir
                     , v_ind_fis_jur_cpdir
                  FROM x04_pessoa_fis_jur x04
                 WHERE x04.ident_fis_jur = mreg.ident_fisjur_cpdir;
            EXCEPTION
                WHEN OTHERS THEN
                    v_cod_fis_jur_cpdir := NULL;
                    v_ind_fis_jur_cpdir := NULL;
            END;

            BEGIN
                SELECT es.cod_estado
                  INTO v_uf_orig_dest
                  FROM estado es
                 WHERE es.ident_estado = mreg.ident_uf_orig_dest;
            EXCEPTION
                WHEN OTHERS THEN
                    v_uf_orig_dest := NULL;
            END;

            BEGIN
                SELECT es.cod_estado
                  INTO v_uf_destino
                  FROM estado es
                 WHERE es.ident_estado = mreg.ident_uf_destino;
            EXCEPTION
                WHEN OTHERS THEN
                    v_uf_destino := NULL;
            END;

            FOR mreg_b IN ( SELECT   cod_tributo
                                   , cod_tributacao
                                   , vlr_base
                                FROM x07_base_docfis x07b
                               WHERE x07b.cod_empresa = mreg.cod_empresa
                                 AND x07b.cod_estab = mreg.cod_estab
                                 AND x07b.data_fiscal = mreg.data_fiscal
                                 AND x07b.movto_e_s = mreg.movto_e_s
                                 AND x07b.norm_dev = mreg.norm_dev
                                 AND x07b.ident_docto = mreg.ident_docto
                                 AND x07b.ident_fis_jur = mreg.ident_fis_jur
                                 AND x07b.num_docfis = mreg.num_docfis
                                 AND NVL ( x07b.serie_docfis, ' ' ) = mreg.serie_docfis
                            ORDER BY 1
                                   , 2 ) LOOP
                IF mreg_b.cod_tributo = 'ICMS' THEN
                    IF mreg_b.cod_tributacao = '1' THEN
                        v_base_trib_icms := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '2' THEN
                        v_base_isen_icms := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '3' THEN
                        v_base_outr_icms := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '4' THEN
                        v_base_redu_icms := mreg_b.vlr_base;
                    END IF;
                ELSIF mreg_b.cod_tributo = 'IPI' THEN
                    IF mreg_b.cod_tributacao = '1' THEN
                        v_base_trib_ipi := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '2' THEN
                        v_base_isen_ipi := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '3' THEN
                        v_base_outr_ipi := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '4' THEN
                        v_base_redu_ipi := mreg_b.vlr_base;
                    END IF;
                ELSIF mreg_b.cod_tributo = 'IR' THEN
                    IF mreg_b.cod_tributacao = '1' THEN
                        v_base_trib_ir := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '2' THEN
                        v_base_isen_ir := mreg_b.vlr_base;
                    END IF;
                ELSIF mreg_b.cod_tributo = 'ISS' THEN
                    IF mreg_b.cod_tributacao = '1' THEN
                        v_base_trib_iss := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '2' THEN
                        v_base_isen_iss := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '3' THEN
                        v_base_outr_iss := mreg_b.vlr_base;
                    END IF;
                ELSIF mreg_b.cod_tributo = 'ICMS-S' THEN
                    IF mreg_b.cod_tributacao = '1' THEN
                        v_base_trib_icmss := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '2' THEN
                        v_base_isen_icmss := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '3' THEN
                        v_base_outr_icmss := mreg_b.vlr_base;
                    ELSIF mreg_b.cod_tributacao = '4' THEN
                        v_base_redu_icmss := mreg_b.vlr_base;
                    END IF;
                END IF;
            END LOOP;

            -- limpa variaveis de tributo da x07
            v_aliq_icms := NULL;
            v_vlr_icms := NULL;
            v_vlr_dif_icms := NULL;
            v_obs_icms := NULL;
            v_cod_apur_icms := NULL;
            -- ipi
            v_aliq_ipi := NULL;
            v_vlr_ipi := NULL;
            v_obs_ipi := NULL;
            v_cod_apur_ipi := NULL;
            -- IR
            v_aliq_ir := NULL;
            v_vlr_ir := NULL;
            -- ISS
            v_aliq_iss := NULL;
            v_vlr_iss := NULL;
            -- ISS
            v_aliq_icms := NULL;
            v_vlr_icms := NULL;
            v_vlr_dif_icms := NULL;
            v_obs_icms := NULL;
            v_cod_apur_icms := NULL;
            v_ind_cred_icmss := NULL;

            FOR mreg_t IN ( SELECT   cod_tributo
                                   , aliq_tributo
                                   , dif_aliq_tributo
                                   , obs_tributo
                                   , ind_cred_tributo
                                   , vlr_tributo
                                   , det.cod_det_operacao
                                FROM x07_trib_docfis x07t
                                   , detalhe_operacao det
                               WHERE x07t.ident_det_operacao = det.ident_det_operacao(+)
                                 AND x07t.cod_empresa = mreg.cod_empresa
                                 AND x07t.cod_estab = mreg.cod_estab
                                 AND x07t.data_fiscal = mreg.data_fiscal
                                 AND x07t.movto_e_s = mreg.movto_e_s
                                 AND x07t.norm_dev = mreg.norm_dev
                                 AND x07t.ident_docto = mreg.ident_docto
                                 AND x07t.ident_fis_jur = mreg.ident_fis_jur
                                 AND x07t.num_docfis = mreg.num_docfis
                                 AND NVL ( x07t.serie_docfis, ' ' ) = mreg.serie_docfis
                            ORDER BY cod_tributo ) LOOP
                IF mreg_t.cod_tributo = 'ICMS' THEN
                    v_aliq_icms := NVL ( mreg_t.aliq_tributo, 0 );
                    v_vlr_icms := NVL ( mreg_t.vlr_tributo, 0 );
                    v_vlr_dif_icms := NVL ( mreg_t.dif_aliq_tributo, 0 );
                    v_obs_icms := mreg_t.obs_tributo;
                    v_cod_apur_icms := mreg_t.cod_det_operacao;
                ELSIF mreg_t.cod_tributo = 'IPI' THEN
                    v_aliq_ipi := NVL ( mreg_t.aliq_tributo, 0 );
                    v_vlr_ipi := NVL ( mreg_t.vlr_tributo, 0 );
                    v_obs_ipi := mreg_t.obs_tributo;
                    v_cod_apur_ipi := mreg_t.cod_det_operacao;
                ELSIF mreg_t.cod_tributo = 'IR' THEN
                    v_aliq_ir := NVL ( mreg_t.aliq_tributo, 0 );
                    v_vlr_ir := NVL ( mreg_t.vlr_tributo, 0 );
                ELSIF mreg_t.cod_tributo = 'ISS' THEN
                    v_aliq_iss := NVL ( mreg_t.aliq_tributo, 0 );
                    v_vlr_iss := NVL ( mreg_t.vlr_tributo, 0 );
                ELSIF mreg_t.cod_tributo = 'ICMS-S' THEN
                    v_aliq_icmss := NVL ( mreg_t.aliq_tributo, 0 );
                    v_vlr_icmss := NVL ( mreg_t.vlr_tributo, 0 );
                    v_obs_icmss := mreg_t.obs_tributo;
                    v_cod_apur_icmss := mreg_t.cod_det_operacao;
                    v_ind_cred_icmss := mreg_t.ind_cred_tributo;
                END IF;
            END LOOP;

            -- lIMPA VARIAVEIS X8
            v_base_trib_icms8 := NULL;
            v_base_isen_icms8 := NULL;
            v_base_outr_icms8 := NULL;
            v_base_redu_icms8 := NULL;
            v_base_trib_ipi8 := NULL;
            v_base_isen_ipi8 := NULL;
            v_base_outr_ipi8 := NULL;
            v_base_redu_ipi8 := NULL;
            v_base_trib_icmss8 := NULL;
            v_base_isen_icmss8 := NULL;
            v_base_outr_icmss8 := NULL;
            v_base_redu_icmss8 := NULL;

            -- Busca Bases da tabela x08 (mercadorias)
            FOR mreg_b8 IN ( SELECT   cod_tributo
                                    , cod_tributacao
                                    , vlr_base
                                 FROM x08_base_merc x08b
                                WHERE x08b.cod_empresa = mreg.cod_empresa
                                  AND x08b.cod_estab = mreg.cod_estab
                                  AND x08b.data_fiscal = mreg.data_fiscal
                                  AND x08b.movto_e_s = mreg.movto_e_s
                                  AND x08b.norm_dev = mreg.norm_dev
                                  AND x08b.ident_docto = mreg.ident_docto
                                  AND x08b.ident_fis_jur = mreg.ident_fis_jur
                                  AND x08b.num_docfis = mreg.num_docfis
                                  AND NVL ( x08b.serie_docfis, ' ' ) = mreg.serie_docfis
                                  AND x08b.discri_item = mreg.discri_item
                                  AND mreg.serv_merc = 'M'
                             ORDER BY 1
                                    , 2 ) LOOP
                IF mreg_b8.cod_tributo = 'ICMS' THEN
                    IF mreg_b8.cod_tributacao = '1' THEN
                        v_base_trib_icms8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '2' THEN
                        v_base_isen_icms8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '3' THEN
                        v_base_outr_icms8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '4' THEN
                        v_base_redu_icms8 := mreg_b8.vlr_base;
                    END IF;
                ELSIF mreg_b8.cod_tributo = 'IPI' THEN
                    IF mreg_b8.cod_tributacao = '1' THEN
                        v_base_trib_ipi8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '2' THEN
                        v_base_isen_ipi8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '3' THEN
                        v_base_outr_ipi8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '4' THEN
                        v_base_redu_ipi8 := mreg_b8.vlr_base;
                    END IF;
                ELSIF mreg_b8.cod_tributo = 'ICMS-S' THEN
                    IF mreg_b8.cod_tributacao = '1' THEN
                        v_base_trib_icmss8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '2' THEN
                        v_base_isen_icmss8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '3' THEN
                        v_base_outr_icmss8 := mreg_b8.vlr_base;
                    ELSIF mreg_b8.cod_tributacao = '4' THEN
                        v_base_redu_icmss8 := mreg_b8.vlr_base;
                    END IF;
                END IF;
            END LOOP;

            -- limpa variaveis de tributo da x08
            v_aliq_icms8 := NULL;
            v_vlr_icms8 := NULL;
            v_vlr_dif_icms8 := NULL;
            v_obs_icms8 := NULL;
            v_cod_apur_icms8 := NULL;
            -- ipi
            v_aliq_ipi8 := NULL;
            v_vlr_ipi8 := NULL;
            v_obs_ipi8 := NULL;
            v_cod_apur_ipi8 := NULL;
            -- ICMSS
            v_aliq_icmss8 := NULL;
            v_vlr_icmss8 := NULL;
            v_vlr_dif_icmss8 := NULL;
            v_obs_icmss8 := NULL;
            v_cod_apur_icmss8 := NULL;
            v_ind_cred_icmss8 := NULL;

            FOR mreg_t8 IN ( SELECT   cod_tributo
                                    , aliq_tributo
                                    , dif_aliq_tributo
                                    , obs_tributo
                                    , ind_cred_tributo
                                    , vlr_tributo
                                    , det.cod_det_operacao
                                    , ind_fornec_tributo
                                 FROM x08_trib_merc x08t
                                    , detalhe_operacao det
                                WHERE x08t.ident_det_operacao = det.ident_det_operacao(+)
                                  AND x08t.cod_empresa = mreg.cod_empresa
                                  AND x08t.cod_estab = mreg.cod_estab
                                  AND x08t.data_fiscal = mreg.data_fiscal
                                  AND x08t.movto_e_s = mreg.movto_e_s
                                  AND x08t.norm_dev = mreg.norm_dev
                                  AND x08t.ident_docto = mreg.ident_docto
                                  AND x08t.ident_fis_jur = mreg.ident_fis_jur
                                  AND x08t.num_docfis = mreg.num_docfis
                                  AND NVL ( x08t.serie_docfis, ' ' ) = mreg.serie_docfis
                                  AND x08t.discri_item = mreg.discri_item
                                  AND mreg.serv_merc = 'M'
                             ORDER BY cod_tributo ) LOOP
                IF mreg_t8.cod_tributo = 'ICMS' THEN
                    v_aliq_icms8 := NVL ( mreg_t8.aliq_tributo, 0 );
                    v_vlr_icms8 := NVL ( mreg_t8.vlr_tributo, 0 );
                    v_vlr_dif_icms8 := NVL ( mreg_t8.dif_aliq_tributo, 0 );
                    v_obs_icms8 := mreg_t8.obs_tributo;
                    v_cod_apur_icms8 := mreg_t8.cod_det_operacao;
                ELSIF mreg_t8.cod_tributo = 'IPI' THEN
                    v_aliq_ipi8 := NVL ( mreg_t8.aliq_tributo, 0 );
                    v_vlr_ipi8 := NVL ( mreg_t8.vlr_tributo, 0 );
                    v_obs_ipi8 := mreg_t8.obs_tributo;
                    v_cod_apur_ipi8 := mreg_t8.cod_det_operacao;
                ELSIF mreg_t8.cod_tributo = 'ICMS-S' THEN
                    v_aliq_icmss8 := NVL ( mreg_t8.aliq_tributo, 0 );
                    v_vlr_icmss8 := NVL ( mreg_t8.vlr_tributo, 0 );
                    v_obs_icmss8 := mreg_t8.obs_tributo;
                    v_cod_apur_icmss8 := mreg_t8.cod_det_operacao;
                    v_ind_cred_icmss8 := mreg_t8.ind_cred_tributo;
                    v_ind_fornec_icmss8 := mreg_t8.ind_fornec_tributo;
                END IF;
            END LOOP;

            -- Limpa variaveis X09
            v_base_trib_icms9 := NULL;
            v_base_isen_icms9 := NULL;
            v_base_outr_icms9 := NULL;
            v_base_redu_icms9 := NULL;
            v_base_trib_ir9 := NULL;
            v_base_isen_ir9 := NULL;
            v_base_trib_iss9 := NULL;
            v_base_isen_iss9 := NULL;
            v_base_outr_iss9 := NULL;

            FOR mreg_b9 IN ( SELECT   cod_tributo
                                    , cod_tributacao
                                    , vlr_base
                                 FROM x09_base_serv x09b
                                WHERE x09b.cod_empresa = mreg.cod_empresa
                                  AND x09b.cod_estab = mreg.cod_estab
                                  AND x09b.data_fiscal = mreg.data_fiscal
                                  AND x09b.movto_e_s = mreg.movto_e_s
                                  AND x09b.norm_dev = mreg.norm_dev
                                  AND x09b.ident_docto = mreg.ident_docto
                                  AND x09b.ident_fis_jur = mreg.ident_fis_jur
                                  AND x09b.num_docfis = mreg.num_docfis
                                  AND NVL ( x09b.serie_docfis, ' ' ) = mreg.serie_docfis
                                  AND x09b.num_item = mreg.num_item
                                  AND mreg.serv_merc = 'S'
                             ORDER BY 1
                                    , 2 ) LOOP
                IF mreg_b9.cod_tributo = 'ICMS' THEN
                    IF mreg_b9.cod_tributacao = '1' THEN
                        v_base_trib_icms9 := mreg_b9.vlr_base;
                    ELSIF mreg_b9.cod_tributacao = '2' THEN
                        v_base_isen_icms9 := mreg_b9.vlr_base;
                    ELSIF mreg_b9.cod_tributacao = '3' THEN
                        v_base_outr_icms9 := mreg_b9.vlr_base;
                    ELSIF mreg_b9.cod_tributacao = '4' THEN
                        v_base_redu_icms9 := mreg_b9.vlr_base;
                    END IF;
                ELSIF mreg_b9.cod_tributo = 'IR' THEN
                    IF mreg_b9.cod_tributacao = '1' THEN
                        v_base_trib_ir9 := mreg_b9.vlr_base;
                    ELSIF mreg_b9.cod_tributacao = '2' THEN
                        v_base_isen_ir9 := mreg_b9.vlr_base;
                    END IF;
                ELSIF mreg_b9.cod_tributo = 'ISS' THEN
                    IF mreg_b9.cod_tributacao = '1' THEN
                        v_base_trib_iss9 := mreg_b9.vlr_base;
                    ELSIF mreg_b9.cod_tributacao = '2' THEN
                        v_base_isen_iss9 := mreg_b9.vlr_base;
                    ELSIF mreg_b9.cod_tributacao = '3' THEN
                        v_base_outr_iss9 := mreg_b9.vlr_base;
                    END IF;
                END IF;
            END LOOP;

            -- limpa variaveis de tributo da x09
            v_aliq_icms9 := NULL;
            v_vlr_icms9 := NULL;
            v_vlr_dif_icms9 := NULL;
            v_obs_icms9 := NULL;
            v_cod_apur_icms9 := NULL;
            -- IR
            v_aliq_ir9 := NULL;
            v_vlr_ir9 := NULL;
            -- ISS
            v_aliq_iss9 := NULL;
            v_vlr_iss9 := NULL;

            FOR mreg_t9 IN ( SELECT   cod_tributo
                                    , aliq_tributo
                                    , dif_aliq_tributo
                                    , obs_tributo
                                    , vlr_tributo
                                    , det.cod_det_operacao
                                 FROM x09_trib_serv x09t
                                    , detalhe_operacao det
                                WHERE x09t.ident_det_operacao = det.ident_det_operacao(+)
                                  AND x09t.cod_empresa = mreg.cod_empresa
                                  AND x09t.cod_estab = mreg.cod_estab
                                  AND x09t.data_fiscal = mreg.data_fiscal
                                  AND x09t.movto_e_s = mreg.movto_e_s
                                  AND x09t.norm_dev = mreg.norm_dev
                                  AND x09t.ident_docto = mreg.ident_docto
                                  AND x09t.ident_fis_jur = mreg.ident_fis_jur
                                  AND x09t.num_docfis = mreg.num_docfis
                                  AND NVL ( x09t.serie_docfis, ' ' ) = mreg.serie_docfis
                                  AND x09t.num_item = mreg.num_item
                                  AND mreg.serv_merc = 'S'
                             ORDER BY cod_tributo ) LOOP
                IF mreg_t9.cod_tributo = 'ICMS' THEN
                    v_aliq_icms9 := NVL ( mreg_t9.aliq_tributo, 0 );
                    v_vlr_icms9 := NVL ( mreg_t9.vlr_tributo, 0 );
                    v_vlr_dif_icms9 := NVL ( mreg_t9.dif_aliq_tributo, 0 );
                    v_obs_icms9 := mreg_t9.obs_tributo;
                    v_cod_apur_icms9 := mreg_t9.cod_det_operacao;
                ELSIF mreg_t9.cod_tributo = 'IR' THEN
                    v_aliq_ir9 := NVL ( mreg_t9.aliq_tributo, 0 );
                    v_vlr_ir9 := NVL ( mreg_t9.vlr_tributo, 0 );
                ELSIF mreg_t9.cod_tributo = 'ISS' THEN
                    v_aliq_iss9 := NVL ( mreg_t9.aliq_tributo, 0 );
                    v_vlr_iss9 := NVL ( mreg_t9.vlr_tributo, 0 );
                END IF;
            END LOOP;

            SELECT DECODE ( mreg.movto_e_s, '9', 'S', 'E' )
              INTO mreg.movto_e_s
              FROM DUAL;

            -- gera arquivo
            vs_mlinha :=
                   mreg.cod_empresa
                || tab
                || mreg.cod_estab
                || tab
                || TO_CHAR ( mreg.data_fiscal
                           , 'dd/mm/rrrr' )
                || tab
                || mreg.data_emissao
                || tab
                || mreg.movto_e_s
                || tab
                || mreg.norm_dev
                || tab
                || mreg.cod_docto
                || tab
                || mreg.cod_modelo
                || tab
                || mreg.cod_cfo7
                || tab
                || mreg.num_docfis
                || tab
                || mreg.serie_docfis
                || tab
                || mreg.ind_fis_jur
                || tab
                || mreg.cod_fis_jur
                || tab
                || --mreg.razao_social || tab ||
                   mreg.cnpj
                || tab
                || mreg.cod_class_doc_fis
                || tab
                || mreg.cod_natureza_op
                || tab
                || mreg.num_docfis_ref
                || tab
                || mreg.num_dec_imp_ref
                || tab
                || mreg.data_saida_rec
                || tab
                || mreg.insc_estad_substit
                || tab
                || TO_CHAR ( mreg.vlr_produto_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_tot_nota
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_frete_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_seguro_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_outras_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_desconto_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.situacao
                || tab
                || mreg.cod_indice
                || tab
                || mreg.cod_conta
                || tab
                || TO_CHAR ( v_aliq_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_dif_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_obs_icms
                || tab
                || v_cod_apur_icms
                || tab
                || TO_CHAR ( v_aliq_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_obs_ipi
                || tab
                || v_cod_apur_ipi
                || tab
                || TO_CHAR ( v_aliq_ir
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_ir
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_aliq_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_aliq_icmss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_icmss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_obs_icmss
                || tab
                || v_cod_apur_icmss
                || tab
                || TO_CHAR ( v_base_trib_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_ir
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_ir
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_icmss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_contab_compl_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.num_controle_docto
                || tab
                || --ok
                   TO_CHAR ( mreg.vlr_aliq_destino_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_nf_especial
                || tab
                || mreg.ind_tp_frete
                || tab
                || mreg.cod_municipio
                || tab
                || mreg.ind_transf_cred
                || tab
                || TO_CHAR ( mreg.vlr_tom_servico
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.dat_escr_extemp
                || tab
                || v_ind_cred_icmss
                || tab
                || TO_CHAR ( mreg.vlr_icms_ndestac
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_ipi_ndestac
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_inss_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_inss_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_inss_retido_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_mat_aplic_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_subempr_iss_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_munic_iss
                || tab
                || mreg.ind_classe_op_iss
                || tab
                || TO_CHAR ( mreg.vlr_outros1_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || --ok
                   mreg.dat_fato_gerador
                || tab
                || mreg.dat_cancelamento
                || tab
                || mreg.cod_quitacao
                || tab
                || TO_CHAR ( mreg.vlr_base_pis_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_cofins_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_icmss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_icmss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_icmss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.perc_red_base_icms_x7
                || tab
                || v_ind_fis_jur_cpdir
                || tab
                || v_cod_fis_jur_cpdir
                || tab
                || v_uf_orig_dest
                || tab
                || mreg.ind_compra_venda
                || tab
                || v_uf_destino
                || tab
                || mreg.ind_situacao_esp_x7
                || tab
                || mreg.insc_estadual
                || tab
                || mreg.cod_pagto_inss
                || tab
                || mreg.ind_nota_servico
                || tab
                || mreg.cnpj_armaz_orig
                || tab
                || mreg.ins_est_armaz_orig
                || tab
                || mreg.cnpj_armaz_dest
                || tab
                || mreg.ins_est_armaz_dest
                || tab
                || --ok
                   TO_CHAR ( mreg.vlr_base_pis_st
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_pis_st
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_st
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_cofins_st
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_cofins_st
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_st
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_csll_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_csll_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_csll_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_pis_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_cofins_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.base_icmss_substituido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_icmss_substituido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_situacao_esp_st_x7
                || tab
                || TO_CHAR ( mreg.vlr_icmss_ndestac
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_docto_rec_x7
                || tab
                || mreg.cod_sit_docfis
                || tab
                || mreg.cod_observacao7
                || tab
                || mreg.cod_municipio_orig
                || tab
                || mreg.cod_municipio_dest
                || tab
                || mreg.cod_cfps_x7
                || tab
                || mreg.num_lancamento
                || tab
                || --ok
                   TO_CHAR ( mreg.vlr_base_iss_retido_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_iss_retido_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_deducao_iss_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_classe_consumo
                || tab
                || mreg.ind_tp_compl_icms
                || tab
                || TO_CHAR ( mreg.vlr_pis_retido_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_retido_x7
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.dat_lanc_pis_cofins_x7
                || tab
                || mreg.ind_pis_cofins_extemp_x7
                || tab
                || mreg.cod_sit_pis
                || tab
                || mreg.cod_sit_cofins
                || tab
                || mreg.ind_nat_frete
                || tab
                || mreg.cod_nat_rec
                || tab
                || mreg.ind_venda_canc
                || tab
                || mreg.ind_nat_base_cred
                || tab
                || mreg.bloco
                || tab
                || -- Inicio Itens Mercadoria
                   mreg.serv_merc
                || tab
                || mreg.num_item
                || tab
                || mreg.cod_cfo
                || tab
                || mreg.desc_cfop
                || tab
                || mreg.cod_natureza_op1
                || tab
                || mreg.cod_produto
                || tab
                || mreg.desc_produto
                || tab
                || mreg.quantidade
                || tab
                || mreg.cod_nbm
                || tab
                || TO_CHAR ( mreg.vlr_unit
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_item
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_desconto8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_situacao_a
                || tab
                || mreg.cod_situacao_b
                || tab
                || -- ICMS
                   --ok
                   TO_CHAR ( v_aliq_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_dif_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_cod_apur_icms8
                || tab
                || -- IPI
                   TO_CHAR ( v_aliq_ipi8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_ipi8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_cod_apur_ipi8
                || tab
                || -- ICMSS
                   TO_CHAR ( v_aliq_icmss8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_icmss8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_cod_apur_icmss8
                || tab
                || -- BASE ICMSS
                   TO_CHAR ( v_base_trib_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_icms8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_ipi8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_ipi8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_ipi8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_ipi8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_icmss8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_icmss8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_icmss8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_icmss8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_contab_compl
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_destino
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_contab_item
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_outros_icms
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_outros_ipi
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_outros1
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || --ok
                   v_ind_cred_icmss8
                || tab
                || mreg.cod_trib_int
                || tab
                || mreg.cod_situacao_pis8
                || tab
                || TO_CHAR ( mreg.vlr_base_pis8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_pis8
                           , c_numberformat4dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_situacao_cofins8
                || tab
                || TO_CHAR ( mreg.vlr_base_cofins8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_cofins8
                           , c_numberformat4dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.base_icms_origdest
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_icms_origdest
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.aliq_icms_origdest
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.perc_red_base_icms
                || tab
                || TO_CHAR ( mreg.vlr_base_csll8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_csll8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_csll8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_ind_fornec_icmss8
                || tab
                || mreg.ind_situacao_esp_st
                || tab
                || mreg.ind_docto_rec
                || tab
                || mreg.ind_vlr_pis_cofins
                || tab
                || mreg.cod_enquad_ipi
                || tab
                || mreg.ind_natureza_frete
                || tab
                || mreg.qtd_base_pis
                || tab
                || TO_CHAR ( mreg.vlr_aliq_pis_r
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.qtd_base_cofins
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_cofins_r
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.item_port_tare
                || tab
                || TO_CHAR ( mreg.vlr_funrural
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_tp_prod_medic
                || tab
                || TO_CHAR ( mreg.vlr_custo_dca
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_tp_lancto8
                || tab
                || TO_CHAR ( mreg.vlr_perc_cred_out
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cred_out
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_icms_dca
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_exp8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_trib8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_n_trib8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_exp8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_trib8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_n_trib8
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_enq_legal
                || tab
                || mreg.dat_lanc_pis_cofins8
                || tab
                || mreg.ind_pis_cofins_extemp8
                || tab
                || mreg.cod_servico
                || tab
                || mreg.desc_servico
                || tab
                || TO_CHAR ( mreg.vlr_servico
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_tot
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.quantidade9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_unit9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_desconto9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_aliq_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_dif_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || v_obs_icms9
                || tab
                || v_cod_apur_icms9
                || tab
                || TO_CHAR ( v_aliq_ir9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_ir9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_aliq_iss9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_vlr_iss9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_redu_icms9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_ir9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_ir9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_trib_iss9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_isen_iss9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( v_base_outr_iss9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_produto
                || tab
                || TO_CHAR ( mreg.vlr_base_csll9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_csll9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_csll9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_pis9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_pis9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_cofins9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_cofins9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_conta9
                || tab
                || mreg.cod_observacao
                || tab
                || mreg.cod_trib_iss
                || tab
                || TO_CHAR ( mreg.vlr_mat_prop
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_mat_terc
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_base_iss_retido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_iss_retido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_deducao_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_subempr_iss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_cfps
                || tab
                || TO_CHAR ( mreg.vlr_out_desp
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.cod_situacao_pis9
                || tab
                || mreg.cod_situacao_cofins9
                || tab
                || TO_CHAR ( mreg.vlr_base_inss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_inss_retido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_inss
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_retido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_retido
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.dat_lanc_pis_cofins9
                || tab
                || mreg.ind_pis_cofins_extemp
                || tab
                || mreg.cod_nat_rec
                || tab
                || mreg.ind_nat_base_cred9
                || tab
                || TO_CHAR ( mreg.vlr_base_cide
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_aliq_cide
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cide
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_comissao9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.ind_vlr_pis_cofins9
                || tab
                || TO_CHAR ( mreg.vlr_pis_exp9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_trib9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_pis_n_trib9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_exp9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || TO_CHAR ( mreg.vlr_cofins_trib9
                           , c_numberformat2dec
                           , c_numberchar )
                || tab
                || mreg.conta7
                || tab
                || mreg.user7
                || tab
                || mreg.conta8
                || tab
                || mreg.user8
                || tab
                || mreg.conta9
                || tab
                || mreg.user9
                || tab
                || mreg.num_processo
                || tab;

            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 3 );
        END LOOP;

        lib_proc.add_log ( 'Total ' || vn_notas || ' NOTAS FISCAIS'
                         , 1 );
        vs_mlinha := NULL;
        lib_proc.close ( );
        RETURN mproc_id;
    END;

    FUNCTION formata_valor ( p_valor IN NUMBER
                           , p_tamanho IN INTEGER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TRUNC (   p_valor
                                    * POWER ( 10
                                            , 2 ) )
                          , 0 )
                    , p_tamanho
                    , '0' );
    END;

    PROCEDURE cabecalho_csv ( vs_tp_rel NUMBER )
    IS
    BEGIN
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      ,    'PERIODO: '
                        || TO_CHAR ( v_dt_ini
                                   , 'dd/mm/rrrr' )
                        || ' A '
                        || TO_CHAR ( v_dt_fim
                                   , 'dd/mm/rrrr' )
                        || ';;;;;;;;;;;'
                      , vs_tp_rel );

        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , vs_tp_rel );
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'EMPRESA: ' || vs_razao_emp || ';;;;;;;;;;;;
;;;;;;;'
                      , vs_tp_rel );

        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , vs_tp_rel );
        vs_mlinha := NULL;

        SELECT ';;;RELATORIO CONFERENCIA DE IMPOSTOS;;;;;;;;;'
          INTO vs_mlinha
          FROM DUAL;

        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , vs_tp_rel );
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , ';;;;;;;;;;;;'
                      , vs_tp_rel );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , vs_tp_rel );
    END cabecalho_csv;

    PROCEDURE rodape
    IS
    BEGIN
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 210
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha );
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , ' '
                      , 1 );

        lib_proc.add ( vs_mlinha );
        vn_linha := vn_linha + 1;
    END;
END msaf_relat_impostos_cproc;
/
SHOW ERRORS;
