



SELECT cod_empresa, cod_estab, data_fiscal,  num_docfis,   discri_item
, DSC_RESERVADO5, cod_tributo     , cod_tributacao , vlr_base , aliq_tributo     , vlr_tributo
   FROM ( 
SELECT cod_empresa, cod_estab, data_fiscal, movto_e_s, norm_dev, ident_docto, ident_fis_jur, num_docfis, 
    serie_docfis, sub_serie_docfis, discri_item
     , DSC_RESERVADO5  ,cod_tributo     , cod_tributacao , vlr_base
  FROM x08_itens_merc NATURAL JOIN x08_base_merc
 WHERE cod_empresa  = 'DSP'
   AND cod_estab    = 'DSP879'
   AND data_fiscal  = '02/07/2018'
   AND num_docfis   = '001022921'
   AND dsc_reservado5 LIKE '%1.%1A%'
   AND num_item     = 1 ) NATURAL JOIN(
SELECT cod_empresa, cod_estab, data_fiscal, movto_e_s, norm_dev, ident_docto, ident_fis_jur, num_docfis, 
 serie_docfis, sub_serie_docfis, discri_item
     , num_item     , cod_tributo     , aliq_tributo     , vlr_tributo
  FROM x08_itens_merc NATURAL JOIN x08_trib_merc   )
   
   
   