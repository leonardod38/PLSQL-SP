Prompt Package MSAF_DIEF_RJ_CPROC;
--
-- MSAF_DIEF_RJ_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_dief_rj_cproc
IS
    -- Autor         : Everton Zamarioli
    -- Created       : 05/06/2006
    -- Purpose       : Geração de Arquivo para a entrega da DIEF para o município
    --                 do Rio de Janeiro
    -- versao 3.3 - alterado o cursor de documentos emitidos para trazer tambem os doc cancelados
    -- deletado o cursor de doc cancelados
    -- criacao do de para AIDF
    -- versao 4.0 - alterado o cursor de doc recebidos sem ref. ao codigo do servico

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

    FUNCTION executar ( pcd_estab VARCHAR2
                      , pdt_comp DATE
                      , ptp_docto VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE teste;
END msaf_dief_rj_cproc;
/
SHOW ERRORS;
