Prompt Package EST_DIEF_RJ_CPROC;
--
-- EST_DIEF_RJ_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE est_dief_rj_cproc
IS
    -- Autor         : Everton Zamarioli
    -- Created       : 14/05/2006
    -- Purpose       : Geração de Arquivo para a entrega da DIEF para o município
    --                 do Rio de Janeiro

    /* Foram gerados os layouts : Serviço prestado
                                  Serviço tomado
    */

    mproc_id INTEGER;

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

    FUNCTION executar ( p_dat_comp DATE
                      , ptp_docto VARCHAR2
                      , p_cod_estab VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE teste;
END est_dief_rj_cproc;
/
SHOW ERRORS;
