CREATE OR REPLACE PACKAGE MSAF.DPSP_V7_FIN4816_PREV_CPROC
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
    TYPE tp_alignment IS RECORD
    (
        vertical VARCHAR2 ( 11 )
      , horizontal VARCHAR2 ( 16 )
      , wraptext BOOLEAN
    );

    --
--    PROCEDURE clear_workbook;

    --
    PROCEDURE new_sheet ( p_sheetname VARCHAR2 := NULL );

    --
    FUNCTION orafmt2excel ( p_format VARCHAR2 := NULL )
        RETURN VARCHAR2;

    --
    FUNCTION get_numfmt ( p_format VARCHAR2 := NULL )
        RETURN PLS_INTEGER;

    --
    FUNCTION get_font ( p_name VARCHAR2
                      , p_family PLS_INTEGER := 2
                      , p_fontsize NUMBER := 11
                      , p_theme PLS_INTEGER := 1
                      , p_underline BOOLEAN := FALSE
                      , p_italic BOOLEAN := FALSE
                      , p_bold BOOLEAN := FALSE
                      , p_rgb VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
                                               )
        RETURN PLS_INTEGER;

    --
    FUNCTION get_fill ( p_patterntype VARCHAR2
                      , p_fgrgb VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
                                                 )
        RETURN PLS_INTEGER;

    --
    FUNCTION get_border ( p_top VARCHAR2 := 'thin'
                        , p_bottom VARCHAR2 := 'thin'
                        , p_left VARCHAR2 := 'thin'
                        , p_right VARCHAR2 := 'thin' )
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
        RETURN PLS_INTEGER;

    --
    FUNCTION get_alignment ( p_vertical VARCHAR2 := NULL
                           , p_horizontal VARCHAR2 := NULL
                           , p_wraptext BOOLEAN := NULL )
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
        RETURN tp_alignment;

    --
    PROCEDURE cell ( p_col PLS_INTEGER
                   , p_row PLS_INTEGER
                   , p_value NUMBER
                   , p_numfmtid PLS_INTEGER := NULL
                   , p_fontid PLS_INTEGER := NULL
                   , p_fillid PLS_INTEGER := NULL
                   , p_borderid PLS_INTEGER := NULL
                   , p_alignment tp_alignment := NULL
                   , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE cell ( p_col PLS_INTEGER
                   , p_row PLS_INTEGER
                   , p_value VARCHAR2
                   , p_numfmtid PLS_INTEGER := NULL
                   , p_fontid PLS_INTEGER := NULL
                   , p_fillid PLS_INTEGER := NULL
                   , p_borderid PLS_INTEGER := NULL
                   , p_alignment tp_alignment := NULL
                   , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE cell ( p_col PLS_INTEGER
                   , p_row PLS_INTEGER
                   , p_value DATE
                   , p_numfmtid PLS_INTEGER := NULL
                   , p_fontid PLS_INTEGER := NULL
                   , p_fillid PLS_INTEGER := NULL
                   , p_borderid PLS_INTEGER := NULL
                   , p_alignment tp_alignment := NULL
                   , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE hyperlink ( p_col PLS_INTEGER
                        , p_row PLS_INTEGER
                        , p_url VARCHAR2
                        , p_value VARCHAR2 := NULL
                        , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE hyperlink_loc ( p_col PLS_INTEGER
                            , p_row PLS_INTEGER
                            , p_location VARCHAR2 );

    --
    PROCEDURE comment ( p_col PLS_INTEGER
                      , p_row PLS_INTEGER
                      , p_text VARCHAR2
                      , p_author VARCHAR2 := NULL
                      , p_width PLS_INTEGER := 150 -- pixels
                      , p_height PLS_INTEGER := 100 -- pixels
                      , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE mergecells ( p_tl_col PLS_INTEGER -- top left
                         , p_tl_row PLS_INTEGER
                         , p_br_col PLS_INTEGER -- bottom right
                         , p_br_row PLS_INTEGER
                         , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE list_validation ( p_sqref_col PLS_INTEGER
                              , p_sqref_row PLS_INTEGER
                              , p_tl_col PLS_INTEGER -- top left
                              , p_tl_row PLS_INTEGER
                              , p_br_col PLS_INTEGER -- bottom right
                              , p_br_row PLS_INTEGER
                              , p_style VARCHAR2 := 'stop' -- stop, warning, information
                              , p_title VARCHAR2 := NULL
                              , p_prompt VARCHAR := NULL
                              , p_show_error BOOLEAN := FALSE
                              , p_error_title VARCHAR2 := NULL
                              , p_error_txt VARCHAR2 := NULL
                              , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE list_validation ( p_sqref_col PLS_INTEGER
                              , p_sqref_row PLS_INTEGER
                              , p_defined_name VARCHAR2
                              , p_style VARCHAR2 := 'stop' -- stop, warning, information
                              , p_title VARCHAR2 := NULL
                              , p_prompt VARCHAR := NULL
                              , p_show_error BOOLEAN := FALSE
                              , p_error_title VARCHAR2 := NULL
                              , p_error_txt VARCHAR2 := NULL
                              , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE defined_name ( p_tl_col PLS_INTEGER -- top left
                           , p_tl_row PLS_INTEGER
                           , p_br_col PLS_INTEGER -- bottom right
                           , p_br_row PLS_INTEGER
                           , p_name VARCHAR2
                           , p_sheet PLS_INTEGER := NULL
                           , p_localsheet PLS_INTEGER := NULL );

    --
    PROCEDURE set_column_width ( p_col PLS_INTEGER
                               , p_width NUMBER
                               , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE set_column ( p_col PLS_INTEGER
                         , p_numfmtid PLS_INTEGER := NULL
                         , p_fontid PLS_INTEGER := NULL
                         , p_fillid PLS_INTEGER := NULL
                         , p_borderid PLS_INTEGER := NULL
                         , p_alignment tp_alignment := NULL
                         , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE set_row_height ( p_row PLS_INTEGER
                             , p_height NUMBER
                             , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE set_row ( p_row PLS_INTEGER
                      , p_numfmtid PLS_INTEGER := NULL
                      , p_fontid PLS_INTEGER := NULL
                      , p_fillid PLS_INTEGER := NULL
                      , p_borderid PLS_INTEGER := NULL
                      , p_alignment tp_alignment := NULL
                      , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE freeze_rows ( p_nr_rows PLS_INTEGER := 1
                          , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE freeze_cols ( p_nr_cols PLS_INTEGER := 1
                          , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE freeze_pane ( p_col PLS_INTEGER
                          , p_row PLS_INTEGER
                          , p_sheet PLS_INTEGER := NULL );

    --
    PROCEDURE set_autofilter ( p_column_start PLS_INTEGER := NULL
                             , p_column_end PLS_INTEGER := NULL
                             , p_row_start PLS_INTEGER := NULL
                             , p_row_end PLS_INTEGER := NULL
                             , p_sheet PLS_INTEGER := NULL );

    --
    FUNCTION finish
        RETURN BLOB;

    --
    PROCEDURE save ( p_directory VARCHAR2
                   , p_filename VARCHAR2 );

    --
    PROCEDURE query2sheet ( p_sql VARCHAR2
                          , p_column_headers BOOLEAN := TRUE
                          , p_directory VARCHAR2 := NULL
                          , p_filename VARCHAR2 := NULL
                          , p_sheet PLS_INTEGER := NULL );

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


   
    FUNCTION executar ( pdata_inicial   DATE
                      , pdata_final     DATE 
                      , p_radio         VARCHAR2
                      , pcod_dir        VARCHAR2         
                      , pcod_estab      lib_proc.vartab 
                      )
        RETURN INTEGER;
END DPSP_V7_FIN4816_PREV_CPROC;
/