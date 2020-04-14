Prompt Package COPY_DATA2_CPROC;
--
-- COPY_DATA2_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE copy_data2_cproc
IS
    -- author  : RMARENDA
    -- created : 16/10/03 11:00:00
    -- purpose : COPIA DE DOCUMENTOS FISCAIS

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

    FUNCTION executar ( pdtiniorig DATE
                      , pdtfimorig DATE
                      , ptipomiov VARCHAR2
                      , pnumdocfis VARCHAR2
                      , pcodestaborig VARCHAR2
                      , pmesdest VARCHAR2
                      , panodest VARCHAR2
                      , pcodempdest VARCHAR2
                      , pcodestabdest VARCHAR2 )
        RETURN INTEGER;

    FUNCTION count_reg ( p_tabela VARCHAR2
                       , p_cod_empresa VARCHAR2
                       , p_cod_estab VARCHAR2
                       , p_tp_mov VARCHAR2
                       , p_num_docfis VARCHAR2
                       , p_nome_col VARCHAR2
                       , p_nome_col2 VARCHAR2
                       , p_dt_iniorig DATE
                       , p_dt_fimorig DATE )
        RETURN NUMBER;

    PROCEDURE teste;
END;
/
SHOW ERRORS;
