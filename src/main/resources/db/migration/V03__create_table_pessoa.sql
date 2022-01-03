 SET SEARCH_PATH TO STARLIGHT;

/*==============================================================*/
/* Sequence: SEQ_PESSOA                                         */
/*==============================================================*/
CREATE SEQUENCE seq_pessoa;

/*==============================================================*/
/* Table: TB_PESSOA                                             */
/*==============================================================*/
CREATE TABLE tb_pessoa (
   id_pessoa            NUMERIC(7)    NOT NULL DEFAULT NEXTVAL ('starlight.seq_pessoa'),
   no_pessoa            VARCHAR(100)  NOT NULL,
   nu_documento         VARCHAR(14)   NOT NULL,
   id_usuario_operacao  NUMERIC(7)    NOT NULL,
   dt_operacao          TIMESTAMP     NOT NULL,
   nu_ip_operacao       VARCHAR(80)   NOT NULL,
   nu_operacao          NUMERIC(5)    NOT NULL,
   CONSTRAINT pk_pessoa PRIMARY KEY ( id_pessoa )  USING INDEX TABLESPACE tbs_starlight_i,
   CONSTRAINT uk_pessoa_01 UNIQUE ( nu_documento ) USING INDEX TABLESPACE tbs_starlight_i,
   CONSTRAINT fk_usuario_pessoa FOREIGN KEY ( id_usuario_operacao )
      REFERENCES tb_usuario ( id_usuario ) ON DELETE RESTRICT ON UPDATE RESTRICT
) TABLESPACE tbs_starlight_d;

/*==============================================================*/
/* Indexes: TB_PESSOA                                           */
/*==============================================================*/ 
CREATE INDEX idx_pessoa_01 ON tb_pessoa ( id_usuario_operacao ) TABLESPACE tbs_starlight_i;


/*==============================================================*/
/* Comment: TB_PESSOA                                           */
/*==============================================================*/   
COMMENT ON TABLE tb_pessoa IS '[PII] - Armazena os dados das pessoas.';
COMMENT ON COLUMN tb_pessoa.id_pessoa is '[NSA] - Identificador único da pessoa.';
COMMENT ON COLUMN tb_pessoa.no_pessoa is '[PII] - Nome/Razão social da pessoa.';
COMMENT ON COLUMN tb_pessoa.nu_documento is '[PII] - CPF/CNPJ da pessoa.';
COMMENT ON COLUMN tb_pessoa.id_usuario_operacao is '[NSA] - Identificador do usuário que estava acessando o sistema no momento em que efetuou a operação do registro. Chave estrangeira oriunda da tabela tb_usuario.';
COMMENT ON COLUMN tb_pessoa.dt_operacao is '[NSA] - Data na qual foi efetuada a última operação no registro. Coluna preenchida por trigger de auditoria.';
COMMENT ON COLUMN tb_pessoa.nu_ip_operacao is '[NSA] - Número do endereço IP da interface de rede utilizada pelo usuário do sistema que manipulou o registro. Coluna preenchida por trigger de auditoria.';
COMMENT ON COLUMN tb_pessoa.nu_operacao is '[NSA] - Número de alterações realizadas no registro. Na inserção é iniciado com 0 e incrementado de 1 em 1 toda vez que houver modificação. Coluna preenchida por trigger de auditoria.';


/*==============================================================*/
/* Table: TH_PESSOA                                             */
/*==============================================================*/
CREATE TABLE th_pessoa (
    id_pessoa              NUMERIC(7)   NOT NULL,
    no_pessoa              VARCHAR(100) NOT NULL,
    nu_documento           VARCHAR(14)  NOT NULL,
    id_usuario_operacao    NUMERIC(7)   NOT NULL,
    dt_operacao            TIMESTAMP    NOT NULL,
    nu_ip_operacao         VARCHAR(80)  NOT NULL,
    nu_operacao            NUMERIC(5)   NOT NULL,
    tp_operacao            CHAR(1)      NOT NULL
) TABLESPACE tbs_starlight_d;

/*==============================================================*/
/* Function: FNC_AUDITORIA_PESSOA                               */
/*==============================================================*/
CREATE OR REPLACE FUNCTION fnc_auditoria_pessoa()
    RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_id_usuario_operacao NUMERIC;
    v_nu_ip_operacao VARCHAR;
BEGIN
    v_id_usuario_operacao := current_setting('auditoria.id_usuario_operacao');
    v_nu_ip_operacao	  := current_setting('auditoria.nu_ip_operacao');
    
    IF ( tg_op = 'INSERT' ) THEN
        new.id_usuario_operacao := v_id_usuario_operacao;
        new.nu_ip_operacao := v_nu_ip_operacao;
        new.dt_operacao := now();
        new.nu_operacao := 0;
        RETURN new;
    END IF;
    
    IF ( tg_op = 'UPDATE' ) THEN
        new.id_usuario_operacao := v_id_usuario_operacao;
        new.nu_ip_operacao := v_nu_ip_operacao;
        new.dt_operacao := now();
        new.nu_operacao := old.nu_operacao + 1;    
            
        INSERT INTO th_pessoa (
            id_pessoa,            
            no_pessoa,              
            nu_documento,              
            id_usuario_operacao,    
            dt_operacao,           
            nu_ip_operacao,        
            nu_operacao,           
            tp_operacao   
        ) VALUES (
            old.id_pessoa,
            old.no_pessoa,
            old.nu_documento,
            old.id_usuario_operacao,
            old.dt_operacao,
            old.nu_ip_operacao,
            old.nu_operacao,
            CASE old.nu_operacao WHEN 0 THEN 'I' ELSE 'U' END
        );
        RETURN NEW;
    END IF;

    IF ( tg_op = 'DELETE' ) THEN

        INSERT INTO th_pessoa (
            id_pessoa,            
            no_pessoa,              
            nu_documento,              
            id_usuario_operacao,    
            dt_operacao,           
            nu_ip_operacao,        
            nu_operacao,           
            tp_operacao   
        ) VALUES (
            old.id_pessoa,
            old.no_pessoa,
            old.nu_documento,
            old.id_usuario_operacao,
            old.dt_operacao,
            old.nu_ip_operacao,
            old.nu_operacao,
            CASE old.nu_operacao WHEN 0 THEN 'I' ELSE 'U' END
        );


        INSERT INTO th_pessoa (
            id_pessoa,            
            no_pessoa,              
            nu_documento,              
            id_usuario_operacao,    
            dt_operacao,           
            nu_ip_operacao,        
            nu_operacao,           
            tp_operacao   
        ) VALUES (
            old.id_pessoa,
            old.no_pessoa,
            old.nu_documento,
            v_id_usuario_operacao,
            now(),
            v_nu_ip_operacao,
            old.nu_operacao + 1,
            'D'
        );
        RETURN old;
    END IF;
END;
$$;

/*==============================================================*/
/* Trigger: TG_PESSOA                                           */
/*==============================================================*/
CREATE TRIGGER tg_pessoa 
    BEFORE INSERT OR UPDATE OR DELETE ON tb_pessoa
    FOR EACH ROW
    EXECUTE PROCEDURE fnc_auditoria_pessoa();


/*==============================================================*/
/* Grant: TB_PESSOA                                             */
/*==============================================================*/
GRANT SELECT, INSERT, UPDATE, DELETE ON tb_pessoa TO RL_STARLIGHT_APP;
GRANT SELECT ON tb_pessoa TO RL_STARLIGHT_USR;

GRANT SELECT ON th_pessoa TO RL_STARLIGHT_AUD;

/*==============================================================*/
/* Insert: TB_USUARIO                                           */
/*==============================================================*/
CALL prc_registrar_operacao (1, '127.0.0.1');

INSERT INTO tb_pessoa (no_pessoa, nu_documento) VALUES ('MARCELO JUAN GONCALVES', '53779884429');
INSERT INTO tb_pessoa (no_pessoa, nu_documento) VALUES ('REBECA SUELI HELOISE REZENDE', '44446743503');
INSERT INTO tb_pessoa (no_pessoa, nu_documento) VALUES ('RAFAEL MARCELO RIBEIRO', '80653892950');
INSERT INTO tb_pessoa (no_pessoa, nu_documento) VALUES ('OLIVER E IGOR CONTABIL ME', '32861529000196');
INSERT INTO tb_pessoa (no_pessoa, nu_documento) VALUES ('GABRIEL E ISABELLY ADVOCACIA LTDA', '41331846000191');
INSERT INTO tb_pessoa (no_pessoa, nu_documento) VALUES ('AURORA E TIAGO GRAFICA ME', '57557838000106');

COMMIT;