CREATE OR REPLACE PACKAGE MSAF.dpsp_v6_fin4816_prev_cproc
IS
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

    FUNCTION orientacao
        RETURN VARCHAR2;
    
 --
   type tp_alignment is record(
    vertical   varchar2(11),
    horizontal varchar2(16),
    wrapText   boolean);
  --
  procedure clear_workbook;
  --
  procedure new_sheet(p_sheetname varchar2 := null);
  --
  function OraFmt2Excel(p_format varchar2 := null) return varchar2;
  --
  function get_numFmt(p_format varchar2 := null) return pls_integer;
  --
  function get_font(p_name      varchar2,
                    p_family    pls_integer := 2,
                    p_fontsize  number := 11,
                    p_theme     pls_integer := 1,
                    p_underline boolean := false,
                    p_italic    boolean := false,
                    p_bold      boolean := false,
                    p_rgb       varchar2 := null -- this is a hex ALPHA Red Green Blue value
                    ) return pls_integer;
  --
  function get_fill(p_patternType varchar2,
                    p_fgRGB       varchar2 := null -- this is a hex ALPHA Red Green Blue value
                    ) return pls_integer;
  --
  function get_border(p_top    varchar2 := 'thin',
                      p_bottom varchar2 := 'thin',
                      p_left   varchar2 := 'thin',
                      p_right  varchar2 := 'thin')
  /*
    none
    thin
    medium
    dashed
    dotted
    thick
    double
    hair
    mediumDashed
    dashDot
    mediumDashDot
    dashDotDot
    mediumDashDotDot
    slantDashDot
    */
   return pls_integer;
  --
  function get_alignment(p_vertical   varchar2 := null,
                         p_horizontal varchar2 := null,
                         p_wrapText   boolean := null)
  /* horizontal
    center
    centerContinuous
    distributed
    fill
    general
    justify
    left
    right
    */
    /* vertical
    bottom
    center
    distributed
    justify
    top
    */
   return tp_alignment;
  --
  procedure cell(p_col       pls_integer,
                 p_row       pls_integer,
                 p_value     number,
                 p_numFmtId  pls_integer := null,
                 p_fontId    pls_integer := null,
                 p_fillId    pls_integer := null,
                 p_borderId  pls_integer := null,
                 p_alignment tp_alignment := null,
                 p_sheet     pls_integer := null);
  --
  procedure cell(p_col       pls_integer,
                 p_row       pls_integer,
                 p_value     varchar2,
                 p_numFmtId  pls_integer := null,
                 p_fontId    pls_integer := null,
                 p_fillId    pls_integer := null,
                 p_borderId  pls_integer := null,
                 p_alignment tp_alignment := null,
                 p_sheet     pls_integer := null);
  --
  procedure cell(p_col       pls_integer,
                 p_row       pls_integer,
                 p_value     date,
                 p_numFmtId  pls_integer := null,
                 p_fontId    pls_integer := null,
                 p_fillId    pls_integer := null,
                 p_borderId  pls_integer := null,
                 p_alignment tp_alignment := null,
                 p_sheet     pls_integer := null);
  --
  procedure hyperlink(p_col   pls_integer,
                      p_row   pls_integer,
                      p_url   varchar2,
                      p_value varchar2 := null,
                      p_sheet pls_integer := null);
  --
  procedure hyperlink_loc(p_col      pls_integer,
                          p_row      pls_integer,
                          p_location varchar2);
  --
  procedure comment(p_col    pls_integer,
                    p_row    pls_integer,
                    p_text   varchar2,
                    p_author varchar2 := null,
                    p_width  pls_integer := 150 -- pixels
                   ,
                    p_height pls_integer := 100 -- pixels
                   ,
                    p_sheet  pls_integer := null);
  --
  procedure mergecells(p_tl_col pls_integer -- top left
                      ,
                       p_tl_row pls_integer,
                       p_br_col pls_integer -- bottom right
                      ,
                       p_br_row pls_integer,
                       p_sheet  pls_integer := null);
  --
  procedure list_validation(p_sqref_col   pls_integer,
                            p_sqref_row   pls_integer,
                            p_tl_col      pls_integer -- top left
                           ,
                            p_tl_row      pls_integer,
                            p_br_col      pls_integer -- bottom right
                           ,
                            p_br_row      pls_integer,
                            p_style       varchar2 := 'stop' -- stop, warning, information
                           ,
                            p_title       varchar2 := null,
                            p_prompt      varchar := null,
                            p_show_error  boolean := false,
                            p_error_title varchar2 := null,
                            p_error_txt   varchar2 := null,
                            p_sheet       pls_integer := null);
  --
  procedure list_validation(p_sqref_col    pls_integer,
                            p_sqref_row    pls_integer,
                            p_defined_name varchar2,
                            p_style        varchar2 := 'stop' -- stop, warning, information
                           ,
                            p_title        varchar2 := null,
                            p_prompt       varchar := null,
                            p_show_error   boolean := false,
                            p_error_title  varchar2 := null,
                            p_error_txt    varchar2 := null,
                            p_sheet        pls_integer := null);
  --
  procedure defined_name(p_tl_col     pls_integer -- top left
                        ,
                         p_tl_row     pls_integer,
                         p_br_col     pls_integer -- bottom right
                        ,
                         p_br_row     pls_integer,
                         p_name       varchar2,
                         p_sheet      pls_integer := null,
                         p_localsheet pls_integer := null);
  --
  procedure set_column_width(p_col pls_integer, p_width number, p_sheet pls_integer := null);
  --
  procedure set_column(p_col       pls_integer,
                       p_numFmtId  pls_integer := null,
                       p_fontId    pls_integer := null,
                       p_fillId    pls_integer := null,
                       p_borderId  pls_integer := null,
                       p_alignment tp_alignment := null,
                       p_sheet     pls_integer := null);
  --
  procedure set_row_height(p_row pls_integer, p_height number, p_sheet pls_integer := null);
  --
  procedure set_row(p_row       pls_integer,
                    p_numFmtId  pls_integer := null,
                    p_fontId    pls_integer := null,
                    p_fillId    pls_integer := null,
                    p_borderId  pls_integer := null,
                    p_alignment tp_alignment := null,
                    p_sheet     pls_integer := null);
  --
  procedure freeze_rows(p_nr_rows pls_integer := 1, p_sheet pls_integer := null);
  --
  procedure freeze_cols(p_nr_cols pls_integer := 1, p_sheet pls_integer := null);
  --
  procedure freeze_pane(p_col pls_integer, p_row pls_integer, p_sheet pls_integer := null);
  --
  procedure set_autofilter(p_column_start pls_integer := null,
                           p_column_end   pls_integer := null,
                           p_row_start    pls_integer := null,
                           p_row_end      pls_integer := null,
                           p_sheet        pls_integer := null);
  --
  function finish return blob;
  --
  procedure save(p_directory varchar2, p_filename varchar2);
  --
  procedure query2sheet(p_sql            varchar2,
                        p_column_headers boolean := true,
                        p_directory      varchar2 := null,
                        p_filename       varchar2 := null,
                        p_sheet          pls_integer := null);
  --
/* Example
begin
  as_xlsx.clear_workbook;
  as_xlsx.new_sheet;
  as_xlsx.cell( 5, 1, 5 );
  as_xlsx.cell( 3, 1, 3 );
  as_xlsx.cell( 2, 2, 45 );
  as_xlsx.cell( 3, 2, 'Anton Scheffer', p_alignment => as_xlsx.get_alignment( p_wraptext => true ) );
  as_xlsx.cell( 1, 4, sysdate, p_fontId => as_xlsx.get_font( 'Calibri', p_rgb => 'FFFF0000' ) );
  as_xlsx.cell( 2, 4, sysdate, p_numFmtId => as_xlsx.get_numFmt( 'dd/mm/yyyy h:mm' ) );
  as_xlsx.cell( 3, 4, sysdate, p_numFmtId => as_xlsx.get_numFmt( as_xlsx.orafmt2excel( 'dd/mon/yyyy' ) ) );
  as_xlsx.cell( 5, 5, 75, p_borderId => as_xlsx.get_border( 'double', 'double', 'double', 'double' ) );
  as_xlsx.cell( 2, 3, 33 );
  as_xlsx.hyperlink( 1, 6, 'http://www.amis.nl', 'Amis site' );
  as_xlsx.cell( 1, 7, 'Some merged cells', p_alignment => as_xlsx.get_alignment( p_horizontal => 'center' ) );
  as_xlsx.mergecells( 1, 7, 3, 7 );
  for i in 1 .. 5
  loop
    as_xlsx.comment( 3, i + 3, 'Row ' || (i+3), 'Anton' );
  end loop;
  as_xlsx.new_sheet;
  as_xlsx.set_row( 1, p_fillId => as_xlsx.get_fill( 'solid', 'FFFF0000' ) ) ;
  for i in 1 .. 5
  loop
    as_xlsx.cell( 1, i, i );
    as_xlsx.cell( 2, i, i * 3 );
    as_xlsx.cell( 3, i, 'x ' || i * 3 );
  end loop;
  as_xlsx.query2sheet( 'select rownum, x.*
, case when mod( rownum, 2 ) = 0 then rownum * 3 end demo
, case when mod( rownum, 2 ) = 1 then ''demo '' || rownum end demo2 from dual x connect by rownum <= 5' );
  as_xlsx.save( 'MY_DIR', 'my.xlsx' );
end;





--
begin
  as_xlsx.clear_workbook;
  as_xlsx.new_sheet;
  as_xlsx.cell( 1, 6, 5 );
  as_xlsx.cell( 1, 7, 3 );
  as_xlsx.cell( 1, 8, 7 );
  as_xlsx.new_sheet;
  as_xlsx.cell( 2, 6, 15, p_sheet => 2 );
  as_xlsx.cell( 2, 7, 13, p_sheet => 2 );
  as_xlsx.cell( 2, 8, 17, p_sheet => 2 );
  as_xlsx.list_validation( 6, 3, 1, 6, 1, 8, p_show_error => true, p_sheet => 1 );
  as_xlsx.defined_name( 2, 6, 2, 8, 'Anton', 2 );
  as_xlsx.list_validation
    ( 6, 1, 'Anton'
    , p_style => 'information'
    , p_title => 'valid values are'
    , p_prompt => '13, 15 and 17'
    , p_show_error => true
    , p_error_title => 'Are you sure?'
    , p_error_txt => 'Valid values are: 13, 15 and 17'
    , p_sheet => 1 );
  as_xlsx.save( 'MY_DIR', 'my.xlsx' );
end;
--
begin
  as_xlsx.clear_workbook;
  as_xlsx.new_sheet;
  as_xlsx.cell( 1, 6, 5 );
  as_xlsx.cell( 1, 7, 3 );
  as_xlsx.cell( 1, 8, 7 );
  as_xlsx.set_autofilter( 1,1, p_row_start => 5, p_row_end => 8 );
  as_xlsx.new_sheet;
  as_xlsx.cell( 2, 6, 5 );
  as_xlsx.cell( 2, 7, 3 );
  as_xlsx.cell( 2, 8, 7 );
  as_xlsx.set_autofilter( 2,2, p_row_start => 5, p_row_end => 8 );
  as_xlsx.save( 'MY_DIR', 'my.xlsx' );
end;
--
begin
  as_xlsx.clear_workbook;
  as_xlsx.new_sheet;
  for c in 1 .. 10
  loop
    as_xlsx.cell( c, 1, 'COL' || c );
    as_xlsx.cell( c, 2, 'val' || c );
    as_xlsx.cell( c, 3, c );
  end loop;
  as_xlsx.freeze_rows( 1 );
  as_xlsx.new_sheet;
  for r in 1 .. 10
  loop
    as_xlsx.cell( 1, r, 'ROW' || r );
    as_xlsx.cell( 2, r, 'val' || r );
    as_xlsx.cell( 3, r, r );
  end loop;
  as_xlsx.freeze_cols( 3 );
  as_xlsx.new_sheet;
  as_xlsx.cell( 3, 3, 'Start freeze' );
  as_xlsx.freeze_pane( 3,3 );
  as_xlsx.save( 'MY_DIR', 'my.xlsx' );
end;
*/


    FUNCTION executar ( pdata_inicial DATE
                      , pdata_final DATE
                      -- , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER;
        
  
     
        
END dpsp_v6_fin4816_prev_cproc;
/