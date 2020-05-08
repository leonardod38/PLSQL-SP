--CREATE OR REPLACE PROCEDURE MSAF_GOL_ATUALIZA is

    declare

  -- Variáveis de Trabalho
  vd_data_nova  date;
  cod_estab_new varchar2(6);
  vd_emi_nova   date;
  vd_serie_nova VARCHAR2(3);
  vd_nota_nova  VARCHAR2(12);
  vn_controle   number := 0;
  v_num_item  NUMBER(5);
  v_num_item_dwti  NUMBER(5);
  v_num_item_dwts  NUMBER(5);
  v_code NUMBER;
  v_errm VARCHAR2(64);
  v_erro boolean;
  vs_chave_nf             varchar2(400);
  vs_chave_ant            varchar2(400);



  -- Notas
  r_x07_docto_fiscal         msaf.x07_docto_fiscal%rowtype;
  r_x07_trib_docfis          msaf.x07_trib_docfis%rowtype;
  r_x07_base_docfis          msaf.x07_base_docfis%rowtype;

  -- Itens de Mercadorias
  r_x08_itens_merc           msaf.x08_itens_merc%rowtype;
  r_x08_trib_merc            msaf.x08_trib_merc%rowtype;
  r_x08_base_merc            msaf.x08_base_merc%rowtype;

  -- Itens de Chassi
  r_x44_itens_chassi         msaf.x44_itens_chassi%rowtype;

  -- Itens de Mercadorias
  r_x09_itens_serv           msaf.x09_itens_serv%rowtype;
  r_x09_trib_serv            msaf.x09_trib_serv%rowtype;
  r_x09_base_serv            msaf.x09_base_serv%rowtype;
  

  r_x50_transp_docfis        msaf.x50_transp_docfis%rowtype;

  -- Observações
  r_x113_ajuste_apur         msaf.x113_ajuste_apur%rowtype;
  r_x112_obs_docfis          msaf.x112_obs_docfis%rowtype;
  r_x114_proc_ref            msaf.x114_proc_ref%rowtype;
  r_x116_docfis_ref          msaf.x116_docfis_ref%rowtype;
  r_x118_coleta_entrg        msaf.x118_coleta_entrg%rowtype;

  -- Tabelas Datamart
  ident_df_w                 number;
  r_dwt_docto_fiscal         msaf.dwt_docto_fiscal%rowtype;
  r_dwt_itens_merc           msaf.dwt_itens_merc%rowtype;
  r_dwt_itens_serv           msaf.dwt_itens_serv%rowtype;

  vb_erro                    boolean                                 := false;

  cursor c_dados is

select x07d.rowid,
       x07d.NUM_DOCFIS   num_dofcis_novo,
       x07d.cod_empresa,
       x07d.cod_estab,
       x07d.data_fiscal,
       x07d.movto_e_s,
       x07d.norm_dev,
       x07d.ident_docto,
       x07d.ident_fis_jur,
       x07d.num_docfis,
       x07d.serie_docfis,
       x07d.sub_serie_docfis,
       x07d.num_controle_docto,
       x07d.num_autentic_nfe,
       x07d.data_emissao
        from msaf.x07_docto_fiscal  x07d,
             msaf.x09_itens_serv    X09
       ---      msaf.REQ000000131419   tab
 where 1=1
         --tab_gol com x07 e x09
   -- and lpad(tab.num_controle_docto,10,0) = lpad(x07d.num_controle_docto,10,0)
   --and tab.cod_empresa = x07d.cod_empresa
   --and tab.cod_estab = x07d.cod_estab
   --and to_date(tab.data_fiscal,'dd/mm/yyyy') = to_date(x07d.data_fiscal,'dd/mm/yyyy')
   --and tab.movto_e_s = x07d.movto_e_s
   --and tab.norm_dev = x07d.norm_dev
  -- and trim(tab.serie_docfis) = x07d.serie_docfis
 --and tab.dsc_reservado1 = x09.dsc_reservado1

                     --x07 com x09
   and x07d.cod_empresa        = X09.cod_empresa
   and x07d.cod_estab          = X09.cod_estab
   and x07d.data_fiscal        = X09.data_fiscal
   and x07d.movto_e_s          = X09.movto_e_s
   and x07d.norm_dev           = X09.norm_dev
   and x07d.ident_docto        = X09.ident_docto
   and x07d.ident_fis_jur      = X09.ident_fis_jur
   and x07d.num_docfis         = X09.num_docfis
   and x07d.serie_docfis       = X09.serie_docfis
   and x07d.sub_serie_docfis   = X09.sub_serie_docfis
   AND x07d.COD_estab          = '101' 
   order by x07d.num_docfis, x09.num_item

   ;
   
   
  cursor c_NF_trib (
                     p_cur_cod_empresa          varchar2,
                     p_cur_cod_estab            varchar2,
                     p_cur_data_fiscal          date,
                     p_cur_movto_e_s            char,
                     p_cur_norm_dev             char,
                     p_cur_ident_docto          number,
                     p_cur_ident_fis_jur        number,
                     p_cur_num_docfis           varchar2,
                     p_cur_serie_docfis         varchar2,
                     p_cur_sub_serie_docfis     varchar2
                   ) is
    select t.rowid,
           -- PK
           t.cod_empresa, t.cod_estab, t.data_fiscal, t.movto_e_s, t.norm_dev, t.ident_docto, t.ident_fis_jur, t.num_docfis, t.serie_docfis, t.sub_serie_docfis, t.cod_tributo
           --
      from msaf.x07_trib_docfis t
     where t.cod_empresa      = p_cur_cod_empresa
       and t.cod_estab        = p_cur_cod_estab
       and t.data_fiscal      = p_cur_data_fiscal
       and t.movto_e_s        = p_cur_movto_e_s
       and t.norm_dev         = p_cur_norm_dev
       and t.ident_docto      = p_cur_ident_docto
       and t.ident_fis_jur    = p_cur_ident_fis_jur
       and t.num_docfis       = p_cur_num_docfis
       and t.serie_docfis     = p_cur_serie_docfis
       and t.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor c_NF_base (
                     p_cur_cod_empresa          varchar2,
                     p_cur_cod_estab            varchar2,
                     p_cur_data_fiscal          date,
                     p_cur_movto_e_s            char,
                     p_cur_norm_dev             char,
                     p_cur_ident_docto          number,
                     p_cur_ident_fis_jur        number,
                     p_cur_num_docfis           varchar2,
                     p_cur_serie_docfis         varchar2,
                     p_cur_sub_serie_docfis     varchar2,
                     p_cur_cod_tributo          varchar2
                   ) is
    select b.rowid
      from msaf.x07_base_docfis b
     where b.cod_empresa      = p_cur_cod_empresa
       and b.cod_estab        = p_cur_cod_estab
       and b.data_fiscal      = p_cur_data_fiscal
       and b.movto_e_s        = p_cur_movto_e_s
       and b.norm_dev         = p_cur_norm_dev
       and b.ident_docto      = p_cur_ident_docto
       and b.ident_fis_jur    = p_cur_ident_fis_jur
       and b.num_docfis       = p_cur_num_docfis
       and b.serie_docfis     = p_cur_serie_docfis
       and b.sub_serie_docfis = p_cur_sub_serie_docfis
       and b.cod_tributo      = p_cur_cod_tributo;

       --itens

  cursor c_itM (
                 p_cur_cod_empresa          varchar2,
                 p_cur_cod_estab            varchar2,
                 p_cur_data_fiscal          date,
                 p_cur_movto_e_s            char,
                 p_cur_norm_dev             char,
                 p_cur_ident_docto          number,
                 p_cur_ident_fis_jur        number,
                 p_cur_num_docfis           varchar2,
                 p_cur_serie_docfis         varchar2,
                 p_cur_sub_serie_docfis     varchar2
               ) is
    select i.rowid,
           i.cod_empresa,
           i.cod_estab,
           i.data_fiscal,
           i.movto_e_s,
           i.norm_dev,
           i.num_docfis,
           i.ident_fis_jur,
           i.ident_docto,
           i.serie_docfis,
           i.sub_serie_docfis,
           i.discri_item
      from msaf.x08_itens_merc i
     where i.cod_empresa      = p_cur_cod_empresa
       and i.cod_estab        = p_cur_cod_estab
       and i.data_fiscal      = p_cur_data_fiscal
       and i.movto_e_s        = p_cur_movto_e_s
       and i.norm_dev         = p_cur_norm_dev
       and i.ident_docto      = p_cur_ident_docto
       and i.ident_fis_jur    = p_cur_ident_fis_jur
       and i.num_docfis       = p_cur_num_docfis
       and i.serie_docfis     = p_cur_serie_docfis
       and i.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor c_itM_trib (
                      p_cur_rowid varchar
                    ) is
    select t.rowid,
           t.cod_empresa,
           t.cod_estab,
           t.data_fiscal,
           t.movto_e_s,
           t.norm_dev,
           t.ident_docto,
           t.ident_fis_jur,
           t.num_docfis,
           t.serie_docfis,
           t.sub_serie_docfis,
           t.discri_item
      from msaf.x08_itens_merc i,
           msaf.x08_trib_merc  t
     where i.cod_empresa      = t.cod_empresa
       and i.cod_estab        = t.cod_estab
       and i.data_fiscal      = t.data_fiscal
       and i.movto_e_s        = t.movto_e_s
       and i.norm_dev         = t.norm_dev
       and i.ident_docto      = t.ident_docto
       and i.ident_fis_jur    = t.ident_fis_jur
       and i.num_docfis       = t.num_docfis
       and i.serie_docfis     = t.serie_docfis
       and i.sub_serie_docfis = t.sub_serie_docfis
       and i.discri_item      = t.discri_item
       and i.rowid            = p_cur_rowid;

  cursor c_itM_base (
                      p_cur_rowid varchar
                    ) is
    select b.rowid
      from msaf.x08_trib_merc  t,
           msaf.x08_base_merc  b
     where t.cod_empresa      = b.cod_empresa
       and t.cod_estab        = b.cod_estab
       and t.data_fiscal      = b.data_fiscal
       and t.movto_e_s        = b.movto_e_s
       and t.norm_dev         = b.norm_dev
       and t.ident_docto      = b.ident_docto
       and t.ident_fis_jur    = b.ident_fis_jur
       and t.num_docfis       = b.num_docfis
       and t.serie_docfis     = b.serie_docfis
       and t.sub_serie_docfis = b.sub_serie_docfis
       and t.discri_item      = b.discri_item
       and t.cod_tributo      = b.cod_tributo
       and t.rowid            = p_cur_rowid;

  -- itens de servico

  cursor c_itMs (
                 p_cur_cod_empresa          varchar2,
                 p_cur_cod_estab            varchar2,
                 p_cur_data_fiscal          date,
                 p_cur_movto_e_s            char,
                 p_cur_norm_dev             char,
                 p_cur_ident_docto          number,
                 p_cur_ident_fis_jur        number,
                 p_cur_num_docfis           varchar2,
                 p_cur_serie_docfis         varchar2,
                 p_cur_sub_serie_docfis     varchar2
               ) is
    select i.rowid,
           i.cod_empresa,
           i.cod_estab,
           i.data_fiscal,
           i.movto_e_s,
           i.norm_dev,
           i.num_docfis,
           i.ident_fis_jur,
           i.ident_docto,
           i.serie_docfis,
           i.sub_serie_docfis
        from msaf.x09_itens_serv i
     where i.cod_empresa      = p_cur_cod_empresa
       and i.cod_estab        = p_cur_cod_estab
       and i.data_fiscal      = p_cur_data_fiscal
       and i.movto_e_s        = p_cur_movto_e_s
       and i.norm_dev         = p_cur_norm_dev
       and i.ident_docto      = p_cur_ident_docto
       and i.ident_fis_jur    = p_cur_ident_fis_jur
       and i.num_docfis       = p_cur_num_docfis
       and i.serie_docfis     = p_cur_serie_docfis
       and i.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor c_itM_tribs (
                      p_cur_rowid varchar
                    ) is
    select t.rowid,
           t.cod_empresa,
           t.cod_estab,
           t.data_fiscal,
           t.movto_e_s,
           t.norm_dev,
           t.ident_docto,
           t.ident_fis_jur,
           t.num_docfis,
           t.serie_docfis,
           t.sub_serie_docfis
      from msaf.x09_itens_serv i,
           msaf.x09_trib_serv  t
     where i.cod_empresa      = t.cod_empresa
       and i.cod_estab        = t.cod_estab
       and i.data_fiscal      = t.data_fiscal
       and i.movto_e_s        = t.movto_e_s
       and i.norm_dev         = t.norm_dev
       and i.ident_docto      = t.ident_docto
       and i.ident_fis_jur    = t.ident_fis_jur
       and i.num_docfis       = t.num_docfis
       and i.serie_docfis     = t.serie_docfis
       and i.sub_serie_docfis = t.sub_serie_docfis
       and i.ident_servico    = t.ident_servico
       and i.num_item         = t.num_item
       and i.rowid            = p_cur_rowid;

  cursor c_itM_bases (
                      p_cur_rowid varchar
                    ) is
    select b.rowid
      from msaf.x09_trib_serv  t,
           msaf.x09_base_serv  b
     where t.cod_empresa      = b.cod_empresa
       and t.cod_estab        = b.cod_estab
       and t.data_fiscal      = b.data_fiscal
       and t.movto_e_s        = b.movto_e_s
       and t.norm_dev         = b.norm_dev
       and t.ident_docto      = b.ident_docto
       and t.ident_fis_jur    = b.ident_fis_jur
       and t.num_docfis       = b.num_docfis
       and t.serie_docfis     = b.serie_docfis
       and t.sub_serie_docfis = b.sub_serie_docfis
       and t.ident_servico    = b.ident_servico
       and t.num_item         = b.num_item
       and t.cod_tributo      = b.cod_tributo
       and t.rowid            = p_cur_rowid;


  cursor c_X44 (
                      p_cur_rowid varchar
                    ) is
    select t.rowid,
           t.cod_empresa,
           t.cod_estab,
           t.data_fiscal,
           t.movto_e_s,
           t.norm_dev,
           t.ident_docto,
           t.ident_fis_jur,
           t.num_docfis,
           t.serie_docfis,
           t.sub_serie_docfis,
           t.discri_item
      from msaf.x08_itens_merc i,
           msaf.x44_itens_chassi  t
     where i.cod_empresa      = t.cod_empresa
       and i.cod_estab        = t.cod_estab
       and i.data_fiscal      = t.data_fiscal
       and i.movto_e_s        = t.movto_e_s
       and i.norm_dev         = t.norm_dev
       and i.ident_docto      = t.ident_docto
       and i.ident_fis_jur    = t.ident_fis_jur
       and i.num_docfis       = t.num_docfis
       and i.serie_docfis     = t.serie_docfis
       and i.sub_serie_docfis = t.sub_serie_docfis
       and i.discri_item      = t.discri_item
       and i.rowid            = p_cur_rowid;

  cursor cur_x50 (
                   p_cur_cod_empresa          varchar2,
                   p_cur_cod_estab            varchar2,
                   p_cur_data_fiscal          date,
                   p_cur_movto_e_s            char,
                   p_cur_norm_dev             char,
                   p_cur_ident_docto          number,
                   p_cur_ident_fis_jur        number,
                   p_cur_num_docfis           varchar2,
                   p_cur_serie_docfis         varchar2,
                   p_cur_sub_serie_docfis     varchar2
                 ) is
    select x50.rowid
      from msaf.x50_transp_docfis x50
     where x50.cod_empresa      = p_cur_cod_empresa
       and x50.cod_estab        = p_cur_cod_estab
       and x50.data_escr_fiscal = p_cur_data_fiscal
       and x50.movto_e_s        = p_cur_movto_e_s
       and x50.norm_dev         = p_cur_norm_dev
       and x50.ident_docto      = p_cur_ident_docto
       and x50.ident_fis_jur    = p_cur_ident_fis_jur
       and x50.num_docfis       = p_cur_num_docfis
       and x50.serie_docfis     = p_cur_serie_docfis
       and x50.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor cur_x112 (
                    p_cur_cod_empresa          varchar2,
                    p_cur_cod_estab            varchar2,
                    p_cur_data_fiscal          date,
                    p_cur_movto_e_s            char,
                    p_cur_norm_dev             char,
                    p_cur_ident_docto          number,
                    p_cur_ident_fis_jur        number,
                    p_cur_num_docfis           varchar2,
                    p_cur_serie_docfis         varchar2,
                    p_cur_sub_serie_docfis     varchar2
                  ) is
    select msaf.x112.rowid
      from msaf.x112_obs_docfis x112
     where x112.cod_empresa      = p_cur_cod_empresa
       and x112.cod_estab        = p_cur_cod_estab
       and x112.data_fiscal      = p_cur_data_fiscal
       and x112.movto_e_s        = p_cur_movto_e_s
       and x112.norm_dev         = p_cur_norm_dev
       and x112.ident_docto      = p_cur_ident_docto
       and x112.ident_fis_jur    = p_cur_ident_fis_jur
       and x112.num_docfis       = p_cur_num_docfis
       and x112.serie_docfis     = p_cur_serie_docfis
       and x112.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor cur_x113 (
                    p_cur_cod_empresa          varchar2,
                    p_cur_cod_estab            varchar2,
                    p_cur_data_fiscal          date,
                    p_cur_movto_e_s            char,
                    p_cur_norm_dev             char,
                    p_cur_ident_docto          number,
                    p_cur_ident_fis_jur        number,
                    p_cur_num_docfis           varchar2,
                    p_cur_serie_docfis         varchar2,
                    p_cur_sub_serie_docfis     varchar2,
                    p_cur_ident_observacao     number,
                    p_cur_ind_icompl_lancto    char
                  ) is
    select x113.rowid
      from msaf.x113_ajuste_apur x113
     where x113.cod_empresa       = p_cur_cod_empresa
       and x113.cod_estab         = p_cur_cod_estab
       and x113.data_fiscal       = p_cur_data_fiscal
       and x113.movto_e_s         = p_cur_movto_e_s
       and x113.norm_dev          = p_cur_norm_dev
       and x113.ident_docto       = p_cur_ident_docto
       and x113.ident_fis_jur     = p_cur_ident_fis_jur
       and x113.num_docfis        = p_cur_num_docfis
       and x113.serie_docfis      = p_cur_serie_docfis
       and x113.sub_serie_docfis  = p_cur_sub_serie_docfis
       and x113.ident_observacao  = p_cur_ident_observacao
       and x113.ind_icompl_lancto = p_cur_ind_icompl_lancto;


  cursor cur_x114 (
                    p_cur_cod_empresa          varchar2,
                    p_cur_cod_estab            varchar2,
                    p_cur_data_fiscal          date,
                    p_cur_movto_e_s            char,
                    p_cur_norm_dev             char,
                    p_cur_ident_docto          number,
                    p_cur_ident_fis_jur        number,
                    p_cur_num_docfis           varchar2,
                    p_cur_serie_docfis         varchar2,
                    p_cur_sub_serie_docfis     varchar2,
                    p_cur_ident_observacao     number,
                    p_cur_ind_icompl_lancto    char
                  ) is
    select x114.rowid
      from msaf.x114_proc_ref x114
     where x114.cod_empresa      = p_cur_cod_empresa
       and x114.cod_estab        = p_cur_cod_estab
       and x114.data_fiscal      = p_cur_data_fiscal
       and x114.movto_e_s        = p_cur_movto_e_s
       and x114.norm_dev         = p_cur_norm_dev
       and x114.ident_docto      = p_cur_ident_docto
       and x114.ident_fis_jur    = p_cur_ident_fis_jur
       and x114.num_docfis       = p_cur_num_docfis
       and x114.serie_docfis     = p_cur_serie_docfis
       and x114.sub_serie_docfis = p_cur_sub_serie_docfis
       and x114.ident_observacao  = p_cur_ident_observacao
       and x114.ind_icompl_lancto = p_cur_ind_icompl_lancto;

  cursor cur_x116 (
                    p_cur_cod_empresa          varchar2,
                    p_cur_cod_estab            varchar2,
                    p_cur_data_fiscal          date,
                    p_cur_movto_e_s            char,
                    p_cur_norm_dev             char,
                    p_cur_ident_docto          number,
                    p_cur_ident_fis_jur        number,
                    p_cur_num_docfis           varchar2,
                    p_cur_serie_docfis         varchar2,
                    p_cur_sub_serie_docfis     varchar2,
                    p_cur_ident_observacao     varchar2
                  ) is
    select x116.rowid
      from msaf.x116_docfis_ref x116
     where x116.cod_empresa      = p_cur_cod_empresa
       and x116.cod_estab        = p_cur_cod_estab
       and x116.data_fiscal      = p_cur_data_fiscal
       and x116.movto_e_s        = p_cur_movto_e_s
       and x116.norm_dev         = p_cur_norm_dev
       and x116.ident_docto      = p_cur_ident_docto
       and x116.ident_fis_jur    = p_cur_ident_fis_jur
       and x116.num_docfis       = p_cur_num_docfis
       and x116.serie_docfis     = p_cur_serie_docfis
       and x116.sub_serie_docfis = p_cur_sub_serie_docfis
       and x116.ident_observacao = p_cur_ident_observacao;

  cursor cur_x118 (
                    p_cur_cod_empresa          varchar2,
                    p_cur_cod_estab            varchar2,
                    p_cur_data_fiscal          date,
                    p_cur_movto_e_s            char,
                    p_cur_norm_dev             char,
                    p_cur_ident_docto          number,
                    p_cur_ident_fis_jur        number,
                    p_cur_num_docfis           varchar2,
                    p_cur_serie_docfis         varchar2,
                    p_cur_sub_serie_docfis     varchar2
                  ) is
    select x118.rowid
      from msaf.x118_coleta_entrg x118
     where x118.cod_empresa      = p_cur_cod_empresa
       and x118.cod_estab        = p_cur_cod_estab
       and x118.data_fiscal      = p_cur_data_fiscal
       and x118.movto_e_s        = p_cur_movto_e_s
       and x118.norm_dev         = p_cur_norm_dev
       and x118.ident_docto      = p_cur_ident_docto
       and x118.ident_fis_jur    = p_cur_ident_fis_jur
       and x118.num_docfis       = p_cur_num_docfis
       and x118.serie_docfis     = p_cur_serie_docfis
       and x118.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor c_dNF (
                 p_cur_cod_empresa          varchar2,
                 p_cur_cod_estab            varchar2,
                 p_cur_data_fiscal          date,
                 p_cur_movto_e_s            char,
                 p_cur_norm_dev             char,
                 p_cur_ident_docto          number,
                 p_cur_ident_fis_jur        number,
                 p_cur_num_docfis           varchar2,
                 p_cur_serie_docfis         varchar2,
                 p_cur_sub_serie_docfis     varchar2
               ) is
    select c.rowid,
           c.ident_docto_fiscal
      from msaf.dwt_docto_fiscal c
     where c.cod_empresa      = p_cur_cod_empresa
       and c.cod_estab        = p_cur_cod_estab
       and c.data_fiscal      = p_cur_data_fiscal
       and c.movto_e_s        = p_cur_movto_e_s
       and c.norm_dev         = p_cur_norm_dev
       and c.ident_docto      = p_cur_ident_docto
       and c.ident_fis_jur    = p_cur_ident_fis_jur
       and c.num_docfis       = p_cur_num_docfis
       and c.serie_docfis     = p_cur_serie_docfis
       and c.sub_serie_docfis = p_cur_sub_serie_docfis;

  cursor c_dIM (
                 p_cur_ident_docto_fiscal number
               ) is
    select rowid
      from msaf.dwt_itens_merc
     where ident_docto_fiscal = p_cur_ident_docto_fiscal;

  cursor c_dIS (
                 p_cur_ident_docto_fiscal number
               ) is
    select rowid
      from msaf.dwt_itens_serv
     where ident_docto_fiscal = p_cur_ident_docto_fiscal;

begin

  for nf in c_dados loop
    
   vs_chave_nf :=    nf.COD_ESTAB
                   ||nf.NUM_DOCFIS
                   ||nf.num_controle_docto
                   ||nf.DATA_FISCAL;

  begin
    dbms_output.enable(NULL);
    v_erro:=true;

           --vd_data_nova  := nf.data_fiscal_NOVA;
           --vd_emi_nova   := nf.data_emissao_NOVA;
           --vd_serie_nova := nf.serie_docfis_NOVA;
             vd_nota_nova  := nf.num_dofcis_novo;
       cod_estab_new:='1444';




          -- Capa NF - 1º Nível - x07_docto_fiscal
          select * into r_x07_docto_fiscal from msaf.x07_docto_fiscal where rowid = nf.rowid;
            r_x07_docto_fiscal.cod_estab := cod_estab_new;
            --r_x07_docto_fiscal.serie_docfis   := vd_serie_nova;
            --r_x07_docto_fiscal.data_fiscal    := vd_data_nova;
            --r_x07_docto_fiscal.data_saida_rec := vd_data_nova;
            --r_x07_docto_fiscal.dat_lanc_pis_cofins := vd_data_nova;
            --r_x07_docto_fiscal.data_emissao   := vd_emi_nova;
            insert into msaf.x07_docto_fiscal values r_x07_docto_fiscal;

          -- Processamento da cópia e alteração da base e imposto da NF.
          
          
          for nfT in c_NF_trib (
                                 nf.cod_empresa,
                                 nf.cod_estab,
                                 nf.data_fiscal,
                                 nf.movto_e_s,
                                 nf.norm_dev,
                                 nf.ident_docto,
                                 nf.ident_fis_jur,
                                 nf.num_docfis,
                                 nf.serie_docfis,
                                 nf.sub_serie_docfis
                               ) loop

              -- Capa NF - 2º Nível - x07_trib_docfis
              select * into r_x07_trib_docfis from msaf.x07_trib_docfis where rowid = nfT.rowid;
              --r_x07_trib_docfis.serie_docfis := vd_serie_nova;
                 r_x07_trib_docfis.cod_estab := cod_estab_new;
              --r_x07_trib_docfis.data_fiscal := vd_data_nova;
              insert into msaf.x07_trib_docfis values r_x07_trib_docfis;

              for nfB in c_NF_base (
                                     nfT.cod_empresa,
                                     nfT.cod_estab,
                                     nfT.data_fiscal,
                                     nfT.movto_e_s,
                                     nfT.norm_dev,
                                     nfT.ident_docto,
                                     nfT.ident_fis_jur,
                                     nfT.num_docfis,
                                     nfT.serie_docfis,
                                     nfT.sub_serie_docfis,
                                     nfT.cod_tributo
                                   ) loop

                  -- Capa NF - 3º Nível - x07_base_docfis
                  select * into r_x07_base_docfis from msaf.x07_base_docfis where rowid = nfB.rowid;
                  --r_x07_base_docfis.serie_docfis := vd_serie_nova;
                r_x07_base_docfis.cod_estab := cod_estab_new;
                  --r_x07_base_docfis.data_fiscal := vd_data_nova;
                  insert into msaf.x07_base_docfis values r_x07_base_docfis;
                  delete msaf.x07_base_docfis where rowid = nfB.rowid;

              end loop;

              delete msaf.x07_trib_docfis where rowid = nfT.rowid;

          end loop;

          -- Itens de Mercadorias
          for IM in c_itM (
                             nf.cod_empresa,
                             nf.cod_estab,
                             nf.data_fiscal,
                             nf.movto_e_s,
                             nf.norm_dev,
                             nf.ident_docto,
                             nf.ident_fis_jur,
                             nf.num_docfis,
                             nf.serie_docfis,
                             nf.sub_serie_docfis
                           ) loop

              -- 1º Nível - x08_itens_merc
              select * into r_x08_itens_merc from msaf.x08_itens_merc where rowid = IM.rowid;
              --r_x08_itens_merc.serie_docfis := vd_serie_nova;
              r_x08_itens_merc.cod_estab := cod_estab_new;
              --r_x08_itens_merc.data_fiscal := vd_data_nova;
              insert into msaf.x08_itens_merc values r_x08_itens_merc;

              -- 2º Nível
              for IM_TRIB in c_itM_trib ( IM.rowid ) loop

                  select * into r_x08_trib_merc from msaf.x08_trib_merc where rowid = IM_TRIB.rowid;
               --   r_x08_trib_merc.serie_docfis := vd_serie_nova;
            r_x08_trib_merc.cod_estab := cod_estab_new;
           -- r_x08_trib_merc.data_fiscal := vd_data_nova;
                  insert into msaf.x08_trib_merc values r_x08_trib_merc;

                  -- 3º Nível
                  for IM_BASE in c_itM_base ( IM_TRIB.rowid ) loop

                      select * into r_x08_base_merc from msaf.x08_base_merc where rowid = IM_BASE.rowid;
                      --r_x08_base_merc.serie_docfis := vd_serie_nova;
                        r_x08_base_merc.cod_estab := cod_estab_new;
                      --r_x08_base_merc.data_fiscal := vd_data_nova;
                      insert into msaf.x08_base_merc values r_x08_base_merc;
                      delete msaf.x08_base_merc where rowid = im_base.rowid;

                  end loop;

                  delete msaf.x08_trib_merc where rowid = im_trib.rowid;

              end loop;


              -- 2º Nível X44
              for IM_x44 in c_x44 ( IM.rowid ) loop

                  select * into r_x44_itens_chassi from msaf.x44_itens_chassi where rowid = IM_X44.rowid;
                 -- r_x44_itens_chassi.serie_docfis := vd_serie_nova;
            r_x44_itens_chassi.cod_estab := cod_estab_new;
            --r_x44_itens_chassi.data_fiscal := vd_data_nova;
                  insert into msaf.x44_itens_chassi values r_x44_itens_chassi;

                  delete msaf.x44_itens_chassi where rowid = im_x44.rowid;

              end loop;


              delete msaf.x08_itens_merc where rowid = IM.rowid;

          end loop;

             -- Itens de servico

         for IMs in c_itMs (
                             nf.cod_empresa,
                             nf.cod_estab,
                             nf.data_fiscal,
                             nf.movto_e_s,
                             nf.norm_dev,
                             nf.ident_docto,
                             nf.ident_fis_jur,
                             nf.num_docfis,
                             nf.serie_docfis,
                             nf.sub_serie_docfis
                           ) loop
                           
          --if vs_chave_ant <> vs_chave_nf or vs_chave_ant is null then
         -- v_num_item:= 1; 
        --   vs_chave_ant := vs_chave_nf;
       --  end if; 
         
               

              -- 1º Nível - x09_itens_serv
              select * into r_x09_itens_serv from msaf.x09_itens_serv where rowid = IMs.rowid;
              -- r_x09_itens_serv.serie_docfis := vd_serie_nova;
           r_x09_itens_serv.cod_estab := cod_estab_new;
           --num_item
           --r_x09_itens_serv.num_item:=v_num_item;
           --num_item
          --r_x09_itens_serv.data_fiscal := vd_data_nova;
              insert into msaf.x09_itens_serv values r_x09_itens_serv;

               -- 2º Nível
                  for IM_TRIBs in c_itM_tribs ( IMs.rowid ) loop

                  select * into r_x09_trib_serv from msaf.x09_trib_serv where rowid = IM_TRIBs.rowid;
                   --r_x09_trib_serv.serie_docfis := vd_serie_nova;
                     r_x09_trib_serv.cod_estab := cod_estab_new;
                     --r_x09_trib_serv.num_item:=v_num_item;
                  -- r_x09_trib_serv.data_fiscal := vd_data_nova;
                  insert into msaf.x09_trib_serv values r_x09_trib_serv;

                  -- 3º Nível
                    for IM_BASEs in c_itM_bases ( IM_TRIBs.rowid ) loop

                        select * into r_x09_base_serv from msaf.x09_base_serv where rowid = IM_BASEs.rowid;
                       -- r_x09_base_serv.serie_docfis := vd_serie_nova;
                          r_x09_base_serv.cod_estab := cod_estab_new;
                          --r_x09_base_serv.num_item:=v_num_item;
                      --  r_x09_base_serv.data_fiscal := vd_data_nova;
                        insert into msaf.x09_base_serv values r_x09_base_serv;
                        delete msaf.x09_base_serv where rowid = im_bases.rowid;

                    end loop; -- c_itM_bases

                        delete msaf.x09_trib_serv where rowid = im_tribs.rowid;

                  end loop; --c_itM_tribs

                delete msaf.x09_itens_serv where rowid = IMs.rowid;
                
               --  v_num_item := v_num_item  + 1;  

          end loop; --c_itMs



          -- Verifica observações da nota e seus "filhos"
          for x112 in cur_x112 (
                                 nf.cod_empresa,
                                 nf.cod_estab,
                                 nf.data_fiscal,
                                 nf.movto_e_s,
                                 nf.norm_dev,
                                 nf.ident_docto,
                                 nf.ident_fis_jur,
                                 nf.num_docfis,
                                 nf.serie_docfis,
                                 nf.sub_serie_docfis
                                 ) loop

              select * into r_x112_obs_docfis from msaf.x112_obs_docfis where rowid = x112.rowid;

             -- r_x112_obs_docfis.serie_docfis := vd_serie_nova;
         r_x112_obs_docfis.cod_estab := cod_estab_new;
       --   r_x112_obs_docfis.data_fiscal  := vd_data_nova;

              insert into msaf.x112_obs_docfis values r_x112_obs_docfis;

               -- Altera X113
              for x113 in cur_x113 (
                                     nf.cod_empresa,
                                     nf.cod_estab,
                                     nf.data_fiscal,
                                     nf.movto_e_s,
                                     nf.norm_dev,
                                     nf.ident_docto,
                                     nf.ident_fis_jur,
                                     nf.num_docfis,
                                     nf.serie_docfis,
                                     nf.sub_serie_docfis,
                                     r_x112_obs_docfis.ident_observacao,
                                     r_x112_obs_docfis.ind_icompl_lancto
                                   ) loop

                  select * into r_x113_ajuste_apur from msaf.x113_ajuste_apur where rowid = x113.rowid;
                  --r_x113_ajuste_apur.serie_docfis := vd_serie_nova;
                  r_x113_ajuste_apur.cod_estab := cod_estab_new;
                 -- r_x113_ajuste_apur.data_fiscal  := vd_data_nova;

                  insert into msaf.x113_ajuste_apur values r_x113_ajuste_apur;
                  delete msaf.x113_ajuste_apur where rowid = x113.rowid;

              end loop;

              -- Altera X114
              for x114 in cur_x114 (
                                     nf.cod_empresa,
                                     nf.cod_estab,
                                     nf.data_fiscal,
                                     nf.movto_e_s,
                                     nf.norm_dev,
                                     nf.ident_docto,
                                     nf.ident_fis_jur,
                                     nf.num_docfis,
                                     nf.serie_docfis,
                                     nf.sub_serie_docfis,
                                     r_x112_obs_docfis.ident_observacao,
                                     r_x112_obs_docfis.ind_icompl_lancto
                                   ) loop


                  select * into r_x114_proc_ref from msaf.x114_proc_ref where rowid = x114.rowid;
                --  r_x114_proc_ref.serie_docfis := vd_serie_nova;
           r_x114_proc_ref.cod_estab := cod_estab_new;
         -- r_x114_proc_ref.data_fiscal := vd_data_nova;
                  insert into msaf.x114_proc_ref values r_x114_proc_ref;
                  delete msaf.x114_proc_ref where rowid = x114.rowid;

              end loop;

              -- Altera X116
              for x116 in cur_x116 (
                                     nf.cod_empresa,
                                     nf.cod_estab,
                                     nf.data_fiscal,
                                     nf.movto_e_s,
                                     nf.norm_dev,
                                     nf.ident_docto,
                                     nf.ident_fis_jur,
                                     nf.num_docfis,
                                     nf.serie_docfis,
                                     nf.sub_serie_docfis,
                                     r_x112_obs_docfis.ident_observacao
                                   ) loop

                  select * into r_x116_docfis_ref from msaf.x116_docfis_ref where rowid = x116.rowid;
                 -- r_x116_docfis_ref.serie_docfis := vd_serie_nova;
                r_x116_docfis_ref.cod_estab := cod_estab_new;
          --r_x116_docfis_ref.data_fiscal  := vd_data_nova;
                  insert into msaf.x116_docfis_ref values r_x116_docfis_ref;
                  delete msaf.x116_docfis_ref where rowid = x116.rowid;

              end loop;

              -- Altera X118
              for x118 in cur_x118 (
                                     nf.cod_empresa,
                                     nf.cod_estab,
                                     nf.data_fiscal,
                                     nf.movto_e_s,
                                     nf.norm_dev,
                                     nf.ident_docto,
                                     nf.ident_fis_jur,
                                     nf.num_docfis,
                                     nf.serie_docfis,
                                     nf.sub_serie_docfis
                                   ) loop

                  select * into r_x118_coleta_entrg from msaf.x118_coleta_entrg where rowid = x118.rowid;
                 -- r_x118_coleta_entrg.serie_docfis := vd_serie_nova;
            r_x118_coleta_entrg.cod_estab := cod_estab_new;
           --          r_x118_coleta_entrg.data_fiscal  := vd_data_nova;
                  insert into msaf.x118_coleta_entrg values r_x118_coleta_entrg;
                  delete msaf.x118_coleta_entrg where rowid = x118.rowid;

              end loop;

              delete msaf.x112_obs_docfis where rowid = x112.rowid;

          end loop;

          -- Altera X50
          for x50 in cur_x50 (
                               nf.cod_empresa,
                               nf.cod_estab,
                               nf.data_fiscal,
                               nf.movto_e_s,
                               nf.norm_dev,
                               nf.ident_docto,
                               nf.ident_fis_jur,
                               nf.num_docfis,
                               nf.serie_docfis,
                               nf.sub_serie_docfis
                             ) loop

              select * into r_x50_transp_docfis from msaf.x50_transp_docfis where rowid = x50.rowid;
            -- r_x50_transp_docfis.serie_docfis := vd_serie_nova;
        r_x50_transp_docfis.cod_estab := cod_estab_new;
       -- r_x50_transp_docfis.data_escr_fiscal  := vd_data_nova;
              insert into msaf.x50_transp_docfis values r_x50_transp_docfis;
              delete msaf.x50_transp_docfis where rowid = x50.rowid;

          end loop;

          delete msaf.x07_docto_fiscal where rowid = nf.rowid;----

           -- Atualização das Tabelas "Datamart"
          for dNF in c_dNF (
                             nf.cod_empresa,
                             nf.cod_estab,
                             nf.data_fiscal,
                             nf.movto_e_s,
                             nf.norm_dev,
                             nf.ident_docto,
                             nf.ident_fis_jur,
                             nf.num_docfis,
                             nf.serie_docfis,
                             nf.sub_serie_docfis
                           ) loop

              -- Cria capa para DWT
              select * into r_dwt_docto_fiscal from msaf.dwt_docto_fiscal where rowid = dNF.rowid;

              -- Busca próx. sequencia do data mart
              select seq_docto.nextval into ident_df_w from dual;

              r_dwt_docto_fiscal.ident_docto_fiscal := ident_df_w;
            --  r_dwt_docto_fiscal.data_fiscal        := vd_data_nova;
        --r_dwt_docto_fiscal.dat_lanc_pis_cofins := vd_data_nova;
             -- r_dwt_docto_fiscal.data_emissao       := vd_emi_nova;
             -- r_dwt_docto_fiscal.serie_docfis       := vd_serie_nova;
              r_dwt_docto_fiscal.cod_estab         := cod_estab_new ;


              INSERT INTO DWT_DOCTO_FISCAL (
                          IDENT_DOCTO_FISCAL,
                          COD_EMPRESA,
                          COD_ESTAB,
                          DATA_FISCAL,
                          MOVTO_E_S,
                          NORM_DEV,
                          IDENT_DOCTO,
                          IDENT_FIS_JUR,
                          NUM_DOCFIS,
                          SERIE_DOCFIS,
                          SUB_SERIE_DOCFIS,
                          DATA_EMISSAO,
                          COD_CLASS_DOC_FIS,
                          IDENT_MODELO,
                          IDENT_CFO,
                          IDENT_NATUREZA_OP,
                          NUM_DOCFIS_REF,
                          SERIE_DOCFIS_REF,
                          S_SER_DOCFIS_REF,
                          NUM_DEC_IMP_REF,
                          DATA_SAIDA_REC,
                          INSC_ESTAD_SUBSTIT,
                          VLR_PRODUTO,
                          VLR_TOT_NOTA,
                          VLR_FRETE,
                          VLR_SEGURO,
                          VLR_OUTRAS,
                          VLR_BASE_DIF_FRETE,
                          VLR_DESCONTO,
                          CONTRIB_FINAL,
                          SITUACAO,
                          COD_INDICE,
                          VLR_NOTA_CONV,
                          IDENT_CONTA,
                          IND_MODELO_CUPOM,
                          VLR_CONTAB_COMPL,
                          NUM_CONTROLE_DOCTO,
                          VLR_ALIQ_DESTINO,
                          VLR_OUTROS1,
                          VLR_OUTROS2,
                          VLR_OUTROS3,
                          VLR_OUTROS4,
                          VLR_OUTROS5,
                          VLR_ALIQ_OUTROS1,
                          VLR_ALIQ_OUTROS2,
                          IND_NF_ESPECIAL,
                          NUM_MAQUINA,
                          NUM_CUPOM_FINAL,
                          ALIQ_TRIBUTO_ICMS,
                          VLR_TRIBUTO_ICMS,
                          DIF_ALIQ_TRIB_ICMS,
                          OBS_TRIBUTO_ICMS,
                          IDENT_DET_OP_ICMS,
                          ALIQ_TRIBUTO_IPI,
                          VLR_TRIBUTO_IPI,
                          OBS_TRIBUTO_IPI,
                          IDENT_DET_OP_IPI,
                          ALIQ_TRIBUTO_ICMSS,
                          VLR_TRIBUTO_ICMSS,
                          OBS_TRIBUTO_ICMSS,
                          IDENT_DET_OP_ICMSS,
                          ALIQ_TRIBUTO_IR,
                          VLR_TRIBUTO_IR,
                          ALIQ_TRIBUTO_ISS,
                          VLR_TRIBUTO_ISS,
                          VLR_BASE_ICMS_1,
                          VLR_BASE_ICMS_2,
                          VLR_BASE_ICMS_3,
                          VLR_BASE_ICMS_4,
                          VLR_BASE_IPI_1,
                          VLR_BASE_IPI_2,
                          VLR_BASE_IPI_3,
                          VLR_BASE_IPI_4,
                          VLR_BASE_ICMSS,
                          VLR_BASE_IR_1,
                          VLR_BASE_IR_2,
                          VLR_BASE_ISS_1,
                          VLR_BASE_ISS_2,
                          VLR_BASE_ISS_3,
                          NUM_PROCESSO,
                          IND_GRAVACAO,
                          IND_TP_FRETE,
                          COD_MUNICIPIO,
                          IND_TRANSF_CRED,
                          DAT_DI,
                          VLR_TOM_SERVICO,
                          DAT_ESCR_EXTEMP,
                          COD_TRIB_INT,
                          COD_REGIAO,
                          DAT_AUTENTIC,
                          COD_CANAL_DISTRIB,
                          IND_CRED_ICMSS,
                          VLR_ICMS_NDESTAC,
                          VLR_IPI_NDESTAC,
                          VLR_TOT_IN,
                          VLR_ICMS_IN,
                          VLR_ICMS_B1_IN,
                          VLR_ICMS_B2_IN,
                          VLR_ICMS_B3_IN,
                          VLR_ICMS_B4_IN,
                          VLR_IPI_IN,
                          VLR_IPI_B1_IN,
                          VLR_IPI_B2_IN,
                          VLR_IPI_B3_IN,
                          VLR_IPI_B4_IN,
                          VLR_BASE_INSS,
                          VLR_ALIQ_INSS,
                          VLR_INSS_RETIDO,
                          VLR_MAT_APLIC_ISS,
                          VLR_SUBEMPR_ISS,
                          IND_MUNIC_ISS,
                          IND_CLASSE_OP_ISS,
                          DAT_FATO_GERADOR,
                          DAT_CANCELAMENTO,
                          NUM_PAGINA,
                          NUM_LIVRO,
                          NRO_AIDF_NF,
                          DAT_VALID_DOC_AIDF,
                          IND_FATURA,
                          IDENT_QUITACAO,
                          NUM_SELO_CONT_ICMS,
                          VLR_BASE_PIS,
                          VLR_PIS,
                          VLR_BASE_COFINS,
                          VLR_COFINS,
                          BASE_ICMS_ORIGDEST,
                          VLR_ICMS_ORIGDEST,
                          ALIQ_ICMS_ORIGDEST,
                          VLR_DESC_CONDIC,
                          VLR_BASE_ISE_ICMSS,
                          VLR_BASE_OUT_ICMSS,
                          VLR_RED_BASE_ICMSS,
                          PERC_RED_BASE_ICMS,
                          IDENT_FISJUR_CPDIR,
                          IND_MEDIDAJUDICIAL,
                          IDENT_UF_ORIG_DEST,
                          IND_COMPRA_VENDA,
                          COD_TP_DISP_SEG,
                          NUM_CTR_DISP,
                          NUM_FIM_DOCTO,
                          IDENT_UF_DESTINO,
                          SERIE_CTR_DISP,
                          SUB_SERIE_CTR_DISP,
                          IND_SITUACAO_ESP,
                          INSC_ESTADUAL,
                          COD_PAGTO_INSS,
                          DAT_OPERACAO,
                          USUARIO,
                          DAT_INTERN_AM,
                          IDENT_FISJUR_LSG,
                          COMPROV_EXP,
                          NUM_FINAL_CRT_DISP,
                          NUM_ALVARA,
                          NOTIFICA_SEFAZ,
                          INTERNA_SUFRAMA,
                          IND_NOTA_SERVICO,
                          COD_MOTIVO,
                          COD_AMPARO,
                          IDENT_ESTADO_AMPAR,
                          OBS_COMPL_MOTIVO,
                          IND_TP_RET,
                          IND_TP_TOMADOR,
                          COD_ANTEC_ST,
                          IND_TELECOM,
                          CNPJ_ARMAZ_ORIG,
                          IDENT_UF_ARMAZ_ORIG,
                          INS_EST_ARMAZ_ORIG,
                          CNPJ_ARMAZ_DEST,
                          IDENT_UF_ARMAZ_DEST,
                          INS_EST_ARMAZ_DEST,
                          OBS_INF_ADIC_NF,
                          VLR_BASE_INSS_2,
                          VLR_ALIQ_INSS_2,
                          VLR_INSS_RETIDO_2,
                          COD_PAGTO_INSS_2,
                          VLR_BASE_PIS_ST,
                          VLR_ALIQ_PIS_ST,
                          VLR_PIS_ST,
                          VLR_BASE_COFINS_ST,
                          VLR_ALIQ_COFINS_ST,
                          VLR_COFINS_ST,
                          VLR_BASE_CSLL,
                          VLR_ALIQ_CSLL,
                          VLR_CSLL,
                          VLR_ALIQ_PIS,
                          VLR_ALIQ_COFINS,
                          BASE_ICMSS_SUBSTITUIDO,
                          VLR_ICMSS_SUBSTITUIDO,
                          COD_CEI,
                          VLR_JUROS_INSS,
                          VLR_MULTA_INSS,
                          IND_SITUACAO_ESP_ST,
                          VLR_ICMSS_NDESTAC,
                          IND_DOCTO_REC,
                          DAT_PGTO_GNRE_DARJ,
                          DT_PAGTO_NF,
                          IND_ORIGEM_INFO,
                          HORA_SAIDA,
                          COD_SIT_DOCFIS,
                          IDENT_OBSERVACAO,
                          IDENT_SITUACAO_A,
                          IDENT_SITUACAO_B,
                          NUM_CONT_REDUC,
                          COD_MUNICIPIO_ORIG,
                          COD_MUNICIPIO_DEST,
                          COD_CFPS,
                          NUM_LANCAMENTO,
                          VLR_MAT_PROP,
                          VLR_MAT_TERC,
                          VLR_BASE_ISS_RETIDO,
                          VLR_ISS_RETIDO,
                          VLR_DEDUCAO_ISS,
                          COD_MUNIC_ARMAZ_ORIG,
                          INS_MUNIC_ARMAZ_ORIG,
                          COD_MUNIC_ARMAZ_DEST,
                          INS_MUNIC_ARMAZ_DEST,
                          IDENT_CLASSE_CONSUMO,
                          IND_ESPECIF_RECEITA,
                          NUM_CONTRATO,
                          COD_AREA_TERMINAL,
                          COD_TP_UTIL,
                          GRUPO_TENSAO,
                          DATA_CONSUMO_INI,
                          DATA_CONSUMO_FIM,
                          DATA_CONSUMO_LEIT,
                          QTD_CONTRATADA_PONTA,
                          QTD_CONTRATADA_FPONTA,
                          QTD_CONSUMO_TOTAL,
                          IDENT_UF_CONSUMO,
                          COD_MUNIC_CONSUMO,
                          ATO_NORMATIVO,
                          NUM_ATO_NORMATIVO,
                          ANO_ATO_NORMATIVO,
                          CAPITULACAO_NORMA,
                          COD_OPER_ESP_ST,
                          VLR_OUTRAS_ENTID,
                          VLR_TERCEIROS,
                          IND_TP_COMPL_ICMS,
                          VLR_BASE_CIDE,
                          VLR_ALIQ_CIDE,
                          VLR_CIDE,
                          COD_VERIFIC_NFE,
                          COD_TP_RPS_NFE,
                          NUM_RPS_NFE,
                          SERIE_RPS_NFE,
                          DAT_EMISSAO_RPS_NFE,
                          DSC_SERVICO_NFE,
                          NUM_AUTENTIC_NFE,
                          NUM_DV_NFE,
                          MODELO_NF_DMS,
                          COD_MODELO_COTEPE,
                          VLR_COMISSAO,
                          IND_NFE_DENEG_INUT,
                          IND_NF_REG_ESPECIAL,
                          VLR_ABAT_NTRIBUTADO,
                          IDENT_FIS_CONCES,
                          COD_AUTENTIC,
                          IND_PORT_CAT44,
                          OBS_DADOS_FATURA,
                          HORA_EMISSAO,
                          VLR_OUTROS_ICMS,
                          HORA_SAIDA_REC,
                          NUM_AUTENTIC_NFE_AUX,
                          VLR_BASE_INSS_RURAL,
                          VLR_ALIQ_INSS_RURAL,
                          VLR_INSS_RURAL,
                          IDENT_CLASSE_CONSUMO_SEF_PE,
                          VLR_PIS_RETIDO,
                          VLR_COFINS_RETIDO,
                          DAT_LANC_PIS_COFINS,
                          IND_PIS_COFINS_EXTEMP,
                          COD_SIT_PIS,
                          COD_SIT_COFINS,
                          IND_NAT_FRETE,
                          CATEGORIA_TRAB,
                          COD_NAT_REC,
                          IND_VENDA_CANC,
                          IND_NAT_BASE_CRED,
                          IND_NF_CONTINGENCIA,
                          VLR_ACRESCIMO,
                          VLR_ANTECIP_TRIB,
                          IND_IPI_NDESTAC_DF,
                          NUM_NFTS,
                          IND_NF_VENDA_TERCEIROS,
                          COD_SISTEMA_ORIG,
                          IDENT_SCP,
                          IND_PREST_SERV,
                          IND_TIPO_PROC,
                          NUM_PROC_JUR,
                          IND_DEC_PROC,
                          IND_TIPO_AQUIS,
                          VLR_DESC_GILRAT,
                          VLR_DESC_SENAR,
                          CNPJ_SUBEMPREITEIRO,
                          CNPJ_CPF_PROPRIETARIO_CNO,
                          VLR_RET_SUBEMPREITADO,
                          NUM_DOCFIS_SERV,
                          --V_DATA_TRAB,
                          VLR_FCP_UF_DEST,
                          VLR_ICMS_UF_DEST,
                          VLR_ICMS_UF_ORIG,
                          --DATA_INDEMISS,
                          --DATA_INDEMISN,
                          VLR_CONTRIB_PREV,
                          VLR_GILRAT,
                          VLR_CONTRIB_SENAR
                        )
                        VALUES
                        (r_dwt_docto_fiscal.IDENT_DOCTO_FISCAL,
                         r_dwt_docto_fiscal.COD_EMPRESA,
                         r_dwt_docto_fiscal.COD_ESTAB,
                         r_dwt_docto_fiscal.DATA_FISCAL,
                         r_dwt_docto_fiscal.MOVTO_E_S,
                         r_dwt_docto_fiscal.NORM_DEV,
                         r_dwt_docto_fiscal.IDENT_DOCTO,
                         r_dwt_docto_fiscal.IDENT_FIS_JUR,
                         r_dwt_docto_fiscal.NUM_DOCFIS,
                         r_dwt_docto_fiscal.SERIE_DOCFIS,
                         r_dwt_docto_fiscal.SUB_SERIE_DOCFIS,
                         r_dwt_docto_fiscal.DATA_EMISSAO,
                         r_dwt_docto_fiscal.COD_CLASS_DOC_FIS,
                         r_dwt_docto_fiscal.IDENT_MODELO,
                         r_dwt_docto_fiscal.IDENT_CFO,
                         r_dwt_docto_fiscal.IDENT_NATUREZA_OP,
                         r_dwt_docto_fiscal.NUM_DOCFIS_REF,
                         r_dwt_docto_fiscal.SERIE_DOCFIS_REF,
                         r_dwt_docto_fiscal.S_SER_DOCFIS_REF,
                         r_dwt_docto_fiscal.NUM_DEC_IMP_REF,
                         r_dwt_docto_fiscal.DATA_SAIDA_REC,
                         r_dwt_docto_fiscal.INSC_ESTAD_SUBSTIT,
                         r_dwt_docto_fiscal.VLR_PRODUTO,
                         r_dwt_docto_fiscal.VLR_TOT_NOTA,
                         r_dwt_docto_fiscal.VLR_FRETE,
                         r_dwt_docto_fiscal.VLR_SEGURO,
                         r_dwt_docto_fiscal.VLR_OUTRAS,
                         r_dwt_docto_fiscal.VLR_BASE_DIF_FRETE,
                         r_dwt_docto_fiscal.VLR_DESCONTO,
                         r_dwt_docto_fiscal.CONTRIB_FINAL,
                         r_dwt_docto_fiscal.SITUACAO,
                         r_dwt_docto_fiscal.COD_INDICE,
                         r_dwt_docto_fiscal.VLR_NOTA_CONV,
                         r_dwt_docto_fiscal.IDENT_CONTA,
                         r_dwt_docto_fiscal.IND_MODELO_CUPOM,
                         r_dwt_docto_fiscal.VLR_CONTAB_COMPL,
                         r_dwt_docto_fiscal.NUM_CONTROLE_DOCTO,
                         r_dwt_docto_fiscal.VLR_ALIQ_DESTINO,
                         r_dwt_docto_fiscal.VLR_OUTROS1,
                         r_dwt_docto_fiscal.VLR_OUTROS2,
                         r_dwt_docto_fiscal.VLR_OUTROS3,
                         r_dwt_docto_fiscal.VLR_OUTROS4,
                         r_dwt_docto_fiscal.VLR_OUTROS5,
                         r_dwt_docto_fiscal.VLR_ALIQ_OUTROS1,
                         r_dwt_docto_fiscal.VLR_ALIQ_OUTROS2,
                         r_dwt_docto_fiscal.IND_NF_ESPECIAL,
                         r_dwt_docto_fiscal.NUM_MAQUINA,
                         r_dwt_docto_fiscal.NUM_CUPOM_FINAL,
                         r_dwt_docto_fiscal.ALIQ_TRIBUTO_ICMS,
                         r_dwt_docto_fiscal.VLR_TRIBUTO_ICMS,
                         r_dwt_docto_fiscal.DIF_ALIQ_TRIB_ICMS,
                         r_dwt_docto_fiscal.OBS_TRIBUTO_ICMS,
                         r_dwt_docto_fiscal.IDENT_DET_OP_ICMS,
                         r_dwt_docto_fiscal.ALIQ_TRIBUTO_IPI,
                         r_dwt_docto_fiscal.VLR_TRIBUTO_IPI,
                         r_dwt_docto_fiscal.OBS_TRIBUTO_IPI,
                         r_dwt_docto_fiscal.IDENT_DET_OP_IPI,
                         r_dwt_docto_fiscal.ALIQ_TRIBUTO_ICMSS,
                         r_dwt_docto_fiscal.VLR_TRIBUTO_ICMSS,
                         r_dwt_docto_fiscal.OBS_TRIBUTO_ICMSS,
                         r_dwt_docto_fiscal.IDENT_DET_OP_ICMSS,
                         r_dwt_docto_fiscal.ALIQ_TRIBUTO_IR,
                         r_dwt_docto_fiscal.VLR_TRIBUTO_IR,
                         r_dwt_docto_fiscal.ALIQ_TRIBUTO_ISS,
                         r_dwt_docto_fiscal.VLR_TRIBUTO_ISS,
                         r_dwt_docto_fiscal.VLR_BASE_ICMS_1,
                         r_dwt_docto_fiscal.VLR_BASE_ICMS_2,
                         r_dwt_docto_fiscal.VLR_BASE_ICMS_3,
                         r_dwt_docto_fiscal.VLR_BASE_ICMS_4,
                         r_dwt_docto_fiscal.VLR_BASE_IPI_1,
                         r_dwt_docto_fiscal.VLR_BASE_IPI_2,
                         r_dwt_docto_fiscal.VLR_BASE_IPI_3,
                         r_dwt_docto_fiscal.VLR_BASE_IPI_4,
                         r_dwt_docto_fiscal.VLR_BASE_ICMSS,
                         r_dwt_docto_fiscal.VLR_BASE_IR_1,
                         r_dwt_docto_fiscal.VLR_BASE_IR_2,
                         r_dwt_docto_fiscal.VLR_BASE_ISS_1,
                         r_dwt_docto_fiscal.VLR_BASE_ISS_2,
                         r_dwt_docto_fiscal.VLR_BASE_ISS_3,
                         r_dwt_docto_fiscal.NUM_PROCESSO,
                         r_dwt_docto_fiscal.IND_GRAVACAO,
                         r_dwt_docto_fiscal.IND_TP_FRETE,
                         r_dwt_docto_fiscal.COD_MUNICIPIO,
                         r_dwt_docto_fiscal.IND_TRANSF_CRED,
                         r_dwt_docto_fiscal.DAT_DI,
                         r_dwt_docto_fiscal.VLR_TOM_SERVICO,
                         r_dwt_docto_fiscal.DAT_ESCR_EXTEMP,
                         r_dwt_docto_fiscal.COD_TRIB_INT,
                         r_dwt_docto_fiscal.COD_REGIAO,
                         r_dwt_docto_fiscal.DAT_AUTENTIC,
                         r_dwt_docto_fiscal.COD_CANAL_DISTRIB,
                         r_dwt_docto_fiscal.IND_CRED_ICMSS,
                         r_dwt_docto_fiscal.VLR_ICMS_NDESTAC,
                         r_dwt_docto_fiscal.VLR_IPI_NDESTAC,
                         r_dwt_docto_fiscal.VLR_TOT_IN,
                         r_dwt_docto_fiscal.VLR_ICMS_IN,
                         r_dwt_docto_fiscal.VLR_ICMS_B1_IN,
                         r_dwt_docto_fiscal.VLR_ICMS_B2_IN,
                         r_dwt_docto_fiscal.VLR_ICMS_B3_IN,
                         r_dwt_docto_fiscal.VLR_ICMS_B4_IN,
                         r_dwt_docto_fiscal.VLR_IPI_IN,
                         r_dwt_docto_fiscal.VLR_IPI_B1_IN,
                         r_dwt_docto_fiscal.VLR_IPI_B2_IN,
                         r_dwt_docto_fiscal.VLR_IPI_B3_IN,
                         r_dwt_docto_fiscal.VLR_IPI_B4_IN,
                         r_dwt_docto_fiscal.VLR_BASE_INSS,
                         r_dwt_docto_fiscal.VLR_ALIQ_INSS,
                         r_dwt_docto_fiscal.VLR_INSS_RETIDO,
                         r_dwt_docto_fiscal.VLR_MAT_APLIC_ISS,
                         r_dwt_docto_fiscal.VLR_SUBEMPR_ISS,
                         r_dwt_docto_fiscal.IND_MUNIC_ISS,
                         r_dwt_docto_fiscal.IND_CLASSE_OP_ISS,
                         r_dwt_docto_fiscal.DAT_FATO_GERADOR,
                         r_dwt_docto_fiscal.DAT_CANCELAMENTO,
                         r_dwt_docto_fiscal.NUM_PAGINA,
                         r_dwt_docto_fiscal.NUM_LIVRO,
                         r_dwt_docto_fiscal.NRO_AIDF_NF,
                         r_dwt_docto_fiscal.DAT_VALID_DOC_AIDF,
                         r_dwt_docto_fiscal.IND_FATURA,
                         r_dwt_docto_fiscal.IDENT_QUITACAO,
                         r_dwt_docto_fiscal.NUM_SELO_CONT_ICMS,
                         r_dwt_docto_fiscal.VLR_BASE_PIS,
                         r_dwt_docto_fiscal.VLR_PIS,
                         r_dwt_docto_fiscal.VLR_BASE_COFINS,
                         r_dwt_docto_fiscal.VLR_COFINS,
                         r_dwt_docto_fiscal.BASE_ICMS_ORIGDEST,
                         r_dwt_docto_fiscal.VLR_ICMS_ORIGDEST,
                         r_dwt_docto_fiscal.ALIQ_ICMS_ORIGDEST,
                         r_dwt_docto_fiscal.VLR_DESC_CONDIC,
                         r_dwt_docto_fiscal.VLR_BASE_ISE_ICMSS,
                         r_dwt_docto_fiscal.VLR_BASE_OUT_ICMSS,
                         r_dwt_docto_fiscal.VLR_RED_BASE_ICMSS,
                         r_dwt_docto_fiscal.PERC_RED_BASE_ICMS,
                         r_dwt_docto_fiscal.IDENT_FISJUR_CPDIR,
                         r_dwt_docto_fiscal.IND_MEDIDAJUDICIAL,
                         r_dwt_docto_fiscal.IDENT_UF_ORIG_DEST,
                         r_dwt_docto_fiscal.IND_COMPRA_VENDA,
                         r_dwt_docto_fiscal.COD_TP_DISP_SEG,
                         r_dwt_docto_fiscal.NUM_CTR_DISP,
                         r_dwt_docto_fiscal.NUM_FIM_DOCTO,
                         r_dwt_docto_fiscal.IDENT_UF_DESTINO,
                         r_dwt_docto_fiscal.SERIE_CTR_DISP,
                         r_dwt_docto_fiscal.SUB_SERIE_CTR_DISP,
                         r_dwt_docto_fiscal.IND_SITUACAO_ESP,
                         r_dwt_docto_fiscal.INSC_ESTADUAL,
                         r_dwt_docto_fiscal.COD_PAGTO_INSS,
                         r_dwt_docto_fiscal.DAT_OPERACAO,
                         r_dwt_docto_fiscal.USUARIO,
                         r_dwt_docto_fiscal.DAT_INTERN_AM,
                         r_dwt_docto_fiscal.IDENT_FISJUR_LSG,
                         r_dwt_docto_fiscal.COMPROV_EXP,
                         r_dwt_docto_fiscal.NUM_FINAL_CRT_DISP,
                         r_dwt_docto_fiscal.NUM_ALVARA,
                         r_dwt_docto_fiscal.NOTIFICA_SEFAZ,
                         r_dwt_docto_fiscal.INTERNA_SUFRAMA,
                         r_dwt_docto_fiscal.IND_NOTA_SERVICO,
                         r_dwt_docto_fiscal.COD_MOTIVO,
                         r_dwt_docto_fiscal.COD_AMPARO,
                         r_dwt_docto_fiscal.IDENT_ESTADO_AMPAR,
                         r_dwt_docto_fiscal.OBS_COMPL_MOTIVO,
                         r_dwt_docto_fiscal.IND_TP_RET,
                         r_dwt_docto_fiscal.IND_TP_TOMADOR,
                         r_dwt_docto_fiscal.COD_ANTEC_ST,
                         r_dwt_docto_fiscal.IND_TELECOM,
                         r_dwt_docto_fiscal.CNPJ_ARMAZ_ORIG,
                         r_dwt_docto_fiscal.IDENT_UF_ARMAZ_ORIG,
                         r_dwt_docto_fiscal.INS_EST_ARMAZ_ORIG,
                         r_dwt_docto_fiscal.CNPJ_ARMAZ_DEST,
                         r_dwt_docto_fiscal.IDENT_UF_ARMAZ_DEST,
                         r_dwt_docto_fiscal.INS_EST_ARMAZ_DEST,
                         r_dwt_docto_fiscal.OBS_INF_ADIC_NF,
                         r_dwt_docto_fiscal.VLR_BASE_INSS_2,
                         r_dwt_docto_fiscal.VLR_ALIQ_INSS_2,
                         r_dwt_docto_fiscal.VLR_INSS_RETIDO_2,
                         r_dwt_docto_fiscal.COD_PAGTO_INSS_2,
                         r_dwt_docto_fiscal.VLR_BASE_PIS_ST,
                         r_dwt_docto_fiscal.VLR_ALIQ_PIS_ST,
                         r_dwt_docto_fiscal.VLR_PIS_ST,
                         r_dwt_docto_fiscal.VLR_BASE_COFINS_ST,
                         r_dwt_docto_fiscal.VLR_ALIQ_COFINS_ST,
                         r_dwt_docto_fiscal.VLR_COFINS_ST,
                         r_dwt_docto_fiscal.VLR_BASE_CSLL,
                         r_dwt_docto_fiscal.VLR_ALIQ_CSLL,
                         r_dwt_docto_fiscal.VLR_CSLL,
                         r_dwt_docto_fiscal.VLR_ALIQ_PIS,
                         r_dwt_docto_fiscal.VLR_ALIQ_COFINS,
                         r_dwt_docto_fiscal.BASE_ICMSS_SUBSTITUIDO,
                         r_dwt_docto_fiscal.VLR_ICMSS_SUBSTITUIDO,
                         r_dwt_docto_fiscal.COD_CEI,
                         r_dwt_docto_fiscal.VLR_JUROS_INSS,
                         r_dwt_docto_fiscal.VLR_MULTA_INSS,
                         r_dwt_docto_fiscal.IND_SITUACAO_ESP_ST,
                         r_dwt_docto_fiscal.VLR_ICMSS_NDESTAC,
                         r_dwt_docto_fiscal.IND_DOCTO_REC,
                         r_dwt_docto_fiscal.DAT_PGTO_GNRE_DARJ,
                         r_dwt_docto_fiscal.DT_PAGTO_NF,
                         r_dwt_docto_fiscal.IND_ORIGEM_INFO,
                         r_dwt_docto_fiscal.HORA_SAIDA,
                         r_dwt_docto_fiscal.COD_SIT_DOCFIS,
                         r_dwt_docto_fiscal.IDENT_OBSERVACAO,
                         r_dwt_docto_fiscal.IDENT_SITUACAO_A,
                         r_dwt_docto_fiscal.IDENT_SITUACAO_B,
                         r_dwt_docto_fiscal.NUM_CONT_REDUC,
                         r_dwt_docto_fiscal.COD_MUNICIPIO_ORIG,
                         r_dwt_docto_fiscal.COD_MUNICIPIO_DEST,
                         r_dwt_docto_fiscal.COD_CFPS,
                         r_dwt_docto_fiscal.NUM_LANCAMENTO,
                         r_dwt_docto_fiscal.VLR_MAT_PROP,
                         r_dwt_docto_fiscal.VLR_MAT_TERC,
                         r_dwt_docto_fiscal.VLR_BASE_ISS_RETIDO,
                         r_dwt_docto_fiscal.VLR_ISS_RETIDO,
                         r_dwt_docto_fiscal.VLR_DEDUCAO_ISS,
                         r_dwt_docto_fiscal.COD_MUNIC_ARMAZ_ORIG,
                         r_dwt_docto_fiscal.INS_MUNIC_ARMAZ_ORIG,
                         r_dwt_docto_fiscal.COD_MUNIC_ARMAZ_DEST,
                         r_dwt_docto_fiscal.INS_MUNIC_ARMAZ_DEST,
                         r_dwt_docto_fiscal.IDENT_CLASSE_CONSUMO,
                         r_dwt_docto_fiscal.IND_ESPECIF_RECEITA,
                         r_dwt_docto_fiscal.NUM_CONTRATO,
                         r_dwt_docto_fiscal.COD_AREA_TERMINAL,
                         r_dwt_docto_fiscal.COD_TP_UTIL,
                         r_dwt_docto_fiscal.GRUPO_TENSAO,
                         r_dwt_docto_fiscal.DATA_CONSUMO_INI,
                         r_dwt_docto_fiscal.DATA_CONSUMO_FIM,
                         r_dwt_docto_fiscal.DATA_CONSUMO_LEIT,
                         r_dwt_docto_fiscal.QTD_CONTRATADA_PONTA,
                         r_dwt_docto_fiscal.QTD_CONTRATADA_FPONTA,
                         r_dwt_docto_fiscal.QTD_CONSUMO_TOTAL,
                         r_dwt_docto_fiscal.IDENT_UF_CONSUMO,
                         r_dwt_docto_fiscal.COD_MUNIC_CONSUMO,
                         r_dwt_docto_fiscal.ATO_NORMATIVO,
                         r_dwt_docto_fiscal.NUM_ATO_NORMATIVO,
                         r_dwt_docto_fiscal.ANO_ATO_NORMATIVO,
                         r_dwt_docto_fiscal.CAPITULACAO_NORMA,
                         r_dwt_docto_fiscal.COD_OPER_ESP_ST,
                         r_dwt_docto_fiscal.VLR_OUTRAS_ENTID,
                         r_dwt_docto_fiscal.VLR_TERCEIROS,
                         r_dwt_docto_fiscal.IND_TP_COMPL_ICMS,
                         r_dwt_docto_fiscal.VLR_BASE_CIDE,
                         r_dwt_docto_fiscal.VLR_ALIQ_CIDE,
                         r_dwt_docto_fiscal.VLR_CIDE,
                         r_dwt_docto_fiscal.COD_VERIFIC_NFE,
                         r_dwt_docto_fiscal.COD_TP_RPS_NFE,
                         r_dwt_docto_fiscal.NUM_RPS_NFE,
                         r_dwt_docto_fiscal.SERIE_RPS_NFE,
                         r_dwt_docto_fiscal.DAT_EMISSAO_RPS_NFE,
                         r_dwt_docto_fiscal.DSC_SERVICO_NFE,
                         r_dwt_docto_fiscal.NUM_AUTENTIC_NFE,
                         r_dwt_docto_fiscal.NUM_DV_NFE,
                         r_dwt_docto_fiscal.MODELO_NF_DMS,
                         r_dwt_docto_fiscal.COD_MODELO_COTEPE,
                         r_dwt_docto_fiscal.VLR_COMISSAO,
                         r_dwt_docto_fiscal.IND_NFE_DENEG_INUT,
                         r_dwt_docto_fiscal.IND_NF_REG_ESPECIAL,
                         r_dwt_docto_fiscal.VLR_ABAT_NTRIBUTADO,
                         r_dwt_docto_fiscal.IDENT_FIS_CONCES,
                         r_dwt_docto_fiscal.COD_AUTENTIC,
                         r_dwt_docto_fiscal.IND_PORT_CAT44,
                         r_dwt_docto_fiscal.OBS_DADOS_FATURA,
                         r_dwt_docto_fiscal.HORA_EMISSAO,
                         r_dwt_docto_fiscal.VLR_OUTROS_ICMS,
                         r_dwt_docto_fiscal. HORA_SAIDA_REC,
                         r_dwt_docto_fiscal.NUM_AUTENTIC_NFE_AUX,
                         r_dwt_docto_fiscal.VLR_BASE_INSS_RURAL,
                         r_dwt_docto_fiscal.VLR_ALIQ_INSS_RURAL,
                         r_dwt_docto_fiscal.VLR_INSS_RURAL,
                         r_dwt_docto_fiscal.IDENT_CLASSE_CONSUMO_SEF_PE,
                         r_dwt_docto_fiscal.VLR_PIS_RETIDO,
                         r_dwt_docto_fiscal.VLR_COFINS_RETIDO,
                         r_dwt_docto_fiscal.DAT_LANC_PIS_COFINS,
                         r_dwt_docto_fiscal.IND_PIS_COFINS_EXTEMP,
                         r_dwt_docto_fiscal.COD_SIT_PIS,
                         r_dwt_docto_fiscal.COD_SIT_COFINS,
                         r_dwt_docto_fiscal.IND_NAT_FRETE,
                         r_dwt_docto_fiscal.CATEGORIA_TRAB,
                         r_dwt_docto_fiscal.COD_NAT_REC,
                         r_dwt_docto_fiscal.IND_VENDA_CANC,
                         r_dwt_docto_fiscal.IND_NAT_BASE_CRED,
                         r_dwt_docto_fiscal.IND_NF_CONTINGENCIA,
                         r_dwt_docto_fiscal.VLR_ACRESCIMO,
                         r_dwt_docto_fiscal.VLR_ANTECIP_TRIB,
                         r_dwt_docto_fiscal.IND_IPI_NDESTAC_DF,
                         r_dwt_docto_fiscal.NUM_NFTS,
                         r_dwt_docto_fiscal.IND_NF_VENDA_TERCEIROS,
                         r_dwt_docto_fiscal.COD_SISTEMA_ORIG,
                         r_dwt_docto_fiscal.IDENT_SCP,
                         r_dwt_docto_fiscal.IND_PREST_SERV,
                         r_dwt_docto_fiscal.IND_TIPO_PROC,
                         r_dwt_docto_fiscal.NUM_PROC_JUR,
                         r_dwt_docto_fiscal.IND_DEC_PROC,
                         r_dwt_docto_fiscal.IND_TIPO_AQUIS,
                         r_dwt_docto_fiscal.VLR_DESC_GILRAT,
                         r_dwt_docto_fiscal.VLR_DESC_SENAR,
                         r_dwt_docto_fiscal.CNPJ_SUBEMPREITEIRO,
                         r_dwt_docto_fiscal.CNPJ_CPF_PROPRIETARIO_CNO,
                         r_dwt_docto_fiscal.VLR_RET_SUBEMPREITADO,
                         r_dwt_docto_fiscal.NUM_DOCFIS_SERV,
                         --r_dwt_docto_fiscal.V_DATA_TRAB, -- virtual
                         r_dwt_docto_fiscal.VLR_FCP_UF_DEST,
                         r_dwt_docto_fiscal.VLR_ICMS_UF_DEST,
                         r_dwt_docto_fiscal.VLR_ICMS_UF_ORIG,
                         --r_dwt_docto_fiscal.DATA_INDEMISS, -- virtual
                         --r_dwt_docto_fiscal.DATA_INDEMISN, -- virtual
                         r_dwt_docto_fiscal.VLR_CONTRIB_PREV,
                         r_dwt_docto_fiscal.VLR_GILRAT,
                         r_dwt_docto_fiscal.VLR_CONTRIB_SENAR
                        );


              --insert into dwt_docto_fiscal values r_dwt_docto_fiscal;

              for dIM in c_dIM ( dNF.ident_docto_fiscal ) loop
              --  if vs_chave_ant <> vs_chave_nf or vs_chave_ant is null then
                  --- v_num_item_dwti:= 1; 
                 --  vs_chave_ant := vs_chave_nf;
               --end if;

                  -- Cria itens para DWT
                  select * into r_dwt_itens_merc from msaf.dwt_itens_merc where rowid = dIM.rowid;

                  r_dwt_itens_merc.ident_docto_fiscal := ident_df_w;
                --r_dwt_itens_merc.data_fiscal        := vd_data_nova;
               -- r_dwt_itens_merc.serie_docfis := vd_serie_nova;
                  --r_dwt_itens_merc.num_item:=v_num_item_dwti;
                  r_dwt_itens_merc.cod_estab := cod_estab_new;


                  insert into dwt_itens_merc values r_dwt_itens_merc;

                  -- Apaga item
                  delete dwt_itens_merc where rowid = dIM.rowid;
                  
                 -- v_num_item_dwti:=v_num_item_dwti+1;

              end loop;

              for dIS in c_dIS ( dNF.ident_docto_fiscal ) loop
                
              --if vs_chave_ant <> vs_chave_nf or vs_chave_ant is null then
                 --  v_num_item_dwts:= 1; 
                 --  vs_chave_ant := vs_chave_nf;
              --  end if;


                  -- Cria itens para DWT
                  select * into r_dwt_itens_serv from msaf.dwt_itens_serv where rowid = dIS.rowid;

                  r_dwt_itens_serv.ident_docto_fiscal := ident_df_w;
                 -- r_dwt_itens_serv.data_fiscal        := vd_data_nova;
                 -- r_dwt_itens_serv.serie_docfis := vd_serie_nova;
                   -- r_dwt_itens_serv.num_item:=v_num_item_dwts;
                    r_dwt_itens_serv.cod_estab := cod_estab_new;

                  insert into dwt_itens_serv values r_dwt_itens_serv;

                  -- Apaga item
                  delete dwt_itens_serv where rowid = dIS.rowid;

           end loop;

              -- Apaga capa
              delete dwt_docto_fiscal where rowid = dNF.rowid;
              --commit;
  --v_num_item_dwts:=v_num_item_dwts+1;
          end loop;

       -- delete msaf_souza_nf where num_controle_docto = vc_NF.num_controle_docto;


  -- commit;

   exception
  when no_data_found then
    
  null;
  
   when dup_val_on_index then
   
   null;
   --dbms_output.put_line ( 'Já executado para Nota: '||vd_nota_nova ) ;
  
  when others then
       v_code := SQLCODE;
       v_errm := SUBSTR(SQLERRM, 1 , 64);
       v_erro:=false;
       DBMS_OUTPUT.PUT_LINE('Erro na Nota: ' || r_x07_docto_fiscal.num_docfis || ' - ' || v_errm);
       
       

   end;
   
   if v_erro then
   
dbms_output.put_line ( 'Nota atualizada, FAVOR VALIDAR, Num_controle_docto: '||nf.num_controle_docto||' - '||'Numero Nota Novo: '||vd_nota_nova ) ;
    
    end if;

  end loop;
 --  commit;
   
  
end;
/
