CREATE UNIQUE INDEX msafi.IDX_FIN4816_REINF_2010
    ON msafi.tb_fin4816_reinf_2010_gtt ( cod_empresa
                                       , cod_estab
                                       , dat_emissao
                                       , iden_fis_jur
                                       , num_docfis );



ALTER TABLE msafi.tb_fin4816_reinf_2010_gtt
    ADD CONSTRAINT idx_fin4816_reinf_2010 PRIMARY KEY
            ( cod_empresa
            , cod_estab
            , dat_emissao
            , iden_fis_jur
            , num_docfis );