Prompt Package DSP_REL_CONF_NF_SAIDA_CPROC;
--
-- DSP_REL_CONF_NF_SAIDA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_rel_conf_nf_saida_cproc
IS
    -- AUTOR    : DPSP - REBELLO
    -- DATA     : 18/Fev/2016
    -- DESCRIÇÃO: Conferencia de NFs de Saida por Data, Estabelecimento e CFOPs (4)

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Variaveis (aqui nao podem ser constantes) para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    c_proc_9xx VARCHAR2 ( 30 ); --C_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    c_proc_dep VARCHAR2 ( 30 ); --C_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    c_proc_loj VARCHAR2 ( 30 ); --C_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_est VARCHAR2 ( 30 ); --C_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_estvd VARCHAR2 ( 30 ); --C_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';

    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION modulo
        RETURN VARCHAR2;

    FUNCTION classificacao
        RETURN VARCHAR2;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cfop1 VARCHAR2
                      , p_cfop2 VARCHAR2
                      , p_cfop3 VARCHAR2
                      , p_cfop4 VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;

    --------------------------------------------------------------------------------------------------------------
    CURSOR c_relatorio_nf_saida ( p_i_data_ini IN DATE
                                , p_i_data_fim IN DATE
                                , p_i_cfop1 IN VARCHAR2
                                , p_i_cfop2 IN VARCHAR2
                                , p_i_cfop3 IN VARCHAR2
                                , p_i_cfop4 IN VARCHAR2 )
    IS
        SELECT   a.cod_estab emitente
               , a.data_fiscal data_fiscal
               , a.data_emissao emissao
               , a.movto_e_s movto
               , a.num_docfis nf
               , a.serie_docfis serie
               , a.num_controle_docto id_people
               , '''' || a.num_autentic_nfe || '''' chave_de_acesso
               , c.cod_fis_jur cod_fis_jur
               , c.razao_social razao_social
               , d.cod_cfo cfop
               , e.cod_natureza_op fin
               , g.cod_situacao_b cst
               , SUM ( b.vlr_base_icms_1 ) tributada
               , SUM ( b.aliq_tributo_icms ) aliq
               , SUM ( b.vlr_tributo_icms ) icms
               , SUM ( b.vlr_base_icms_2 ) isenta
               , SUM ( b.vlr_base_icms_3 ) outras
               , SUM ( b.vlr_base_icms_4 ) reducao
            FROM msaf.dwt_docto_fiscal a
               , msaf.dwt_itens_merc b
               , msaf.x04_pessoa_fis_jur c
               , msaf.x2012_cod_fiscal d
               , msaf.x2006_natureza_op e
               , msaf.y2025_sit_trb_uf_a f
               , msaf.y2026_sit_trb_uf_b g
               , msafi.dsp_proc_estabs h ---TABELA TEMP
           WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
             AND a.ident_fis_jur = c.ident_fis_jur
             AND b.ident_cfo = d.ident_cfo
             AND b.ident_natureza_op = e.ident_natureza_op
             AND b.ident_situacao_a = f.ident_situacao_a
             AND b.ident_situacao_b = g.ident_situacao_b
             AND a.cod_empresa = mcod_empresa
             AND a.cod_estab = h.cod_estab
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND d.cod_cfo IN ( p_i_cfop1
                              , p_i_cfop2
                              , p_i_cfop3
                              , p_i_cfop4 )
             AND a.situacao = 'N'
             AND a.movto_e_s = '9'
        GROUP BY a.cod_estab
               , a.data_fiscal
               , a.data_emissao
               , a.movto_e_s
               , a.num_docfis
               , a.serie_docfis
               , a.num_controle_docto
               , a.num_autentic_nfe
               , c.cod_fis_jur
               , c.razao_social
               , d.cod_cfo
               , e.cod_natureza_op
               , g.cod_situacao_b;
--------------------------------------------------------------------------------------------------------------

END dsp_rel_conf_nf_saida_cproc;
/
SHOW ERRORS;
