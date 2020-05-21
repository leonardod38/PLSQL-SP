select COD_ESTAB ,classificacao, cod_embasamento, to_char(data_fiscal, 'MM/YYYY') DATA_FISCAL  , 
count(*)
  from msafi.dpsp_fin2662_dub
where   not(cod_embasamento  like '%128/94%'  and      classificacao = '-1' )
and   to_char(data_fiscal, 'MM/YYYY')   BETWEEN  '01/2019'  AND '12/2019'  
group by COD_ESTAB ,classificacao, cod_embasamento, to_char(data_fiscal, 'MM/YYYY')




select cod_estab, TO_CHAR(DATA_FISCAL, 'MM/YYYY') , count(*)
  from msafi.dpsp_fin2662_dub
where  1=1 
AND  NOT ( cod_embasamento  like '%128/94%'  and      classificacao = '-1' )
and  cod_estab  = 'DP1542'
GROUP BY cod_estab, TO_CHAR(DATA_FISCAL, 'MM/YYYY') 
ORDER BY 1 desc


select classificacao, cod_embasamento , count(*) 
  from   msafi.dpsp_fin2662_dub
--where classificacao <> '-1'
group by classificacao, cod_embasamento 


--11/2019  --  55812  old / 10942
--07/2019  --  45024  old  / 4223
--08/2019  -- 


--02/2020  
--03/2019
--11/2019


CREATE TABLE msafi.dpsp_fin2662_dub_bkp
AS SELECT * FROM msafi.dpsp_fin2662_dub





select PERIODO, count(*)  from  msafi.dpsp_fin4405_cest_arquivo b
GROUP BY PERIODO

SELECT * from  msafi.dpsp_fin4405_cest_arquivo b

select * from msafi.dpsp_fin2662_par_con_dub

select * FROM msafi.dpsp_fin2662_reg_calc_dub







 -- 5 - CONV�NIO 128/94 - CESTA B�SICA - REDU��O BASE DE C�LCULO 
 select  *
  from   msafi.dpsp_fin2662_dub
  where substr(cod_embasamento,1,1) = 5
  and  num_docfis ='000188100'
  and cod_empresa = 'DP'
  and cod_estab = 'DP1214'
  
  
 SELECT cod_convenio, cod_cst, cod_cfop , item_subclassificacao,a.cod_reg_calc, des_reg_calc
   FROM msafi.dpsp_fin2662_par_reg_dub    a
   ,    msafi.dpsp_fin2662_reg_calc_dub   b
 where a.cod_reg_calc  = b.cod_reg_calc   
   and  cod_cst = '00'  and  cod_cfop ='5152' 
 
 
 
 select classificacao, cod_embasamento , count(*) 
  from   msafi.dpsp_fin2662_dub
--where classificacao <> '-1'
group by classificacao, cod_embasamento 
 








SELECT * from  msafi.dpsp_fin4405_cest_arquivo b
where cod_produto = '634999'







 
   select * from msafi.dpsp_fin2662_dub
 
 
 
 
select * from x2013_produto


select distinct x2013.dsc_reservado4, b.cod_produto, x2013.cod_produto
 from x2013_produto  x2013,
   msafi.dpsp_fin4405_cest_arquivo b
 where trim(b.cod_produto)  = trim(x2013.cod_produto)
 --and  x2013.cod_produto = '692867'

select x2013.dsc_reservado4
   from x2013_produto x2013
   where cod_produto like '692867'



--
--  -1	7 - CONV�NIO 15/81 E 33/93 - REDU��O DA BASE DE C�LCULOS (TRANSFER�NCIA DE ATIVOS)
--  -1	5 - CONV�NIO 128/94 - CESTA B�SICA - REDU��O BASE DE C�LCULO
--  -1	9 - DECRETO ART. 27.427/00 LIVRO XII TITULO I - DIFERIMENTO (SUCATA)


--
--5	CONV�NIO 128/94 - CESTA B�SICA - REDU��O BASE DE C�LCULO	1	                        06/01/2020 11:31:59	accenture
--7	CONV�NIO 15/81 E 33/93 - REDU��O DA BASE DE C�LCULOS (TRANSFER�NCIA DE ATIVOS)	1	    06/01/2020 11:31:59	accenture
--9	DECRETO ART. 27.427/00 LIVRO XII TITULO I - DIFERIMENTO (SUCATA)	1	                06/01/2020 11:31:59	accenture


CESTA B�SICA
ISEN��O
REDU��O DE BASE
DIFERIMENTO



