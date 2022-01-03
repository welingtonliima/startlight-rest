 SET SEARCH_PATH TO STARLIGHT;

/*==============================================================*/
/* Sequence: SEQ_USUARIO                                        */
/*==============================================================*/
CREATE SEQUENCE seq_usuario;

/*==============================================================*/
/* Table: TB_USUARIO                                            */
/*==============================================================*/
CREATE TABLE tb_usuario (
    id_usuario             NUMERIC(7)   NOT NULL DEFAULT NEXTVAL ('starlight.seq_usuario'),
    no_login               VARCHAR(50)  NOT NULL,
    tx_senha               VARCHAR(100) NOT NULL,
    tx_senha_temporaria    VARCHAR(100) NULL,
    tx_email               VARCHAR(100) NOT NULL,
    dt_email_verificacao   TIMESTAMP    NULL,   
    tp_situacao_usuario    NUMERIC(1)   NOT NULL,
    id_usuario_operacao    NUMERIC(7)   NOT NULL,
    dt_operacao            TIMESTAMP    NOT NULL,
    nu_ip_operacao         VARCHAR(80)  NOT NULL,
    nu_operacao            NUMERIC(5)   NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY ( id_usuario ) USING INDEX TABLESPACE tbs_starlight_i,
    CONSTRAINT uk_usuario_01 UNIQUE ( no_login )  USING INDEX TABLESPACE tbs_starlight_i,
    CONSTRAINT uk_usuario_02 UNIQUE ( tx_email )  USING INDEX TABLESPACE tbs_starlight_i,
    CONSTRAINT ck_usuario_01 CHECK  ( tp_situacao_usuario IN (1,2,3,4) ),
    CONSTRAINT fk_usuario_operacao FOREIGN KEY ( id_usuario_operacao ) 
        REFERENCES tb_usuario ( id_usuario ) ON DELETE RESTRICT ON UPDATE RESTRICT 
) TABLESPACE tbs_starlight_d;


/*==============================================================*/
/* Indexes: TB_USUARIO                                          */
/*==============================================================*/ 
CREATE INDEX idx_usuario_01 ON tb_usuario ( id_usuario_operacao ) TABLESPACE tbs_starlight_i;


/*==============================================================*/
/* Comment: TB_USUARIO                                          */
/*==============================================================*/   
COMMENT ON TABLE tb_usuario IS '[PII] - Armazena os usuários com acesso no sistema.';
COMMENT ON COLUMN tb_usuario.id_usuario IS '[NSA] - Identificador único do usuário com acesso ao sistema.';
COMMENT ON COLUMN tb_usuario.no_login IS '[PII] - Nome do login do usuário com acesso ao sistema.';
COMMENT ON COLUMN tb_usuario.tx_senha IS '[PII] - Senha do usuário com acesso ao sistema.';
COMMENT ON COLUMN tb_usuario.tx_senha_temporaria IS '[PII] - Senha temporária do usuário com acesso ao sistema.';
COMMENT ON COLUMN tb_usuario.tx_email IS '[PII] - Endereço eletrônico do usuário com acesso ao sistema.';
COMMENT ON COLUMN tb_usuario.dt_email_verificacao IS '[NSA] - Data de validação do email eletrônico.';
COMMENT ON COLUMN tb_usuario.tp_situacao_usuario IS '[NSA] - Identifica a situação do cadastro do usuário. Aceita os seguintes valores: 1-Aguardando Validação, 2-Ativo, 3-Senha Temporária, 4-Excluído.';
COMMENT ON COLUMN tb_usuario.id_usuario_operacao IS '[NSA] - Identificador do usuário que estava acessando o sistema no momento em que efetuou a operação do registro. Chave estrangeira oriunda da tabela tb_usuario.'; 
COMMENT ON COLUMN tb_usuario.dt_operacao IS '[NSA] - Data na qual foi efetuada a última operação no registro. Coluna preenchida por trigger de auditoria.';
COMMENT ON COLUMN tb_usuario.nu_ip_operacao IS '[NSA] - Número do endereço IP da interface de rede utilizada pelo usuário do sistema que manipulou o registro. Coluna preenchida por trigger de auditoria.';
COMMENT ON COLUMN tb_usuario.nu_operacao IS '[NSA] - Número de alterações realizadas no registro. Na inserção é iniciado com 0 e incrementado de 1 em 1 toda vez que houver modificação. Coluna preenchida por trigger de auditoria.';

/*==============================================================*/
/* Table: TH_USUARIO                                            */
/*==============================================================*/
CREATE TABLE th_usuario (
    id_usuario             NUMERIC(7)   NULL,
    no_login               VARCHAR(50)  NULL,
    tx_senha               VARCHAR(100) NULL,
    tx_senha_temporaria    VARCHAR(100) NULL,
    tx_email               VARCHAR(100) NULL,
    dt_email_verificacao   TIMESTAMP    NULL,   
    tp_situacao_usuario    NUMERIC(1)   NULL,
    id_usuario_operacao    NUMERIC(7)   NOT NULL,
    dt_operacao            TIMESTAMP    NOT NULL,
    nu_ip_operacao         VARCHAR(80)  NOT NULL,
    nu_operacao            NUMERIC(5)   NOT NULL,
    tp_operacao            CHAR(1)      NOT NULL
) TABLESPACE tbs_starlight_d;

/*==============================================================*/
/* Function: FNC_AUDITORIA_USUARIO                              */
/*==============================================================*/
CREATE OR REPLACE FUNCTION fnc_auditoria_usuario()
    RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_id_usuario_operacao NUMERIC;
    v_nu_ip_operacao VARCHAR;
BEGIN
    v_id_usuario_operacao := current_setting('auditoria.id_usuario_operacao');
    v_nu_ip_operacao	  := current_setting('auditoria.nu_ip_operacao');
    
    IF ( tg_op = 'INSERT' ) THEN
        new.id_usuario_operacao := new.id_usuario;
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
            
        INSERT INTO th_usuario (
            id_usuario,            
            no_login,              
            tx_senha,              
            tx_senha_temporaria,  
            tx_email,              
            dt_email_verificacao,  
            tp_situacao_usuario,   
            id_usuario_operacao,    
            dt_operacao,           
            nu_ip_operacao,        
            nu_operacao,           
            tp_operacao   
        ) VALUES (
            old.id_usuario,
            old.no_login,
            old.tx_senha,
            old.tx_senha_temporaria,
            old.tx_email,
            old.dt_email_verificacao,
            old.tp_situacao_usuario,
            old.id_usuario_operacao,
            old.dt_operacao,
            old.nu_ip_operacao,
            old.nu_operacao,
            CASE old.nu_operacao WHEN 0 THEN 'I' ELSE 'U' END
        );
        RETURN NEW;
    END IF;

    IF ( tg_op = 'DELETE' ) THEN

        INSERT INTO th_usuario (
            id_usuario,            
            no_login,              
            tx_senha,              
            tx_senha_temporaria,  
            tx_email,              
            dt_email_verificacao,  
            tp_situacao_usuario,   
            id_usuario_operacao,    
            dt_operacao,           
            nu_ip_operacao,        
            nu_operacao,           
            tp_operacao   
        ) VALUES (
            old.id_usuario,
            old.no_login,
            old.tx_senha,
            old.tx_senha_temporaria,
            old.tx_email,
            old.dt_email_verificacao,
            old.tp_situacao_usuario,
            old.id_usuario_operacao,
            old.dt_operacao,
            old.nu_ip_operacao,
            old.nu_operacao,
            CASE old.nu_operacao WHEN 0 THEN 'I' ELSE 'U' END
        );


        INSERT INTO th_usuario (
            id_usuario,            
            no_login,              
            tx_senha,              
            tx_senha_temporaria,  
            tx_email,              
            dt_email_verificacao,  
            tp_situacao_usuario,   
            id_usuario_operacao,    
            dt_operacao,           
            nu_ip_operacao,        
            nu_operacao,           
            tp_operacao   
        ) VALUES (
            old.id_usuario,
            old.no_login,
            old.tx_senha,
            old.tx_senha_temporaria,
            old.tx_email,
            old.dt_email_verificacao,
            old.tp_situacao_usuario,
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
/* Trigger: TG_USUARIO                                           */
/*==============================================================*/
CREATE TRIGGER tg_usuario 
    BEFORE INSERT OR UPDATE OR DELETE ON tb_usuario
    FOR EACH ROW
    EXECUTE PROCEDURE fnc_auditoria_usuario();


/*==============================================================*/
/* Grant: TB_USUARIO                                            */
/*==============================================================*/
GRANT SELECT, INSERT, UPDATE, DELETE ON tb_usuario TO RL_STARLIGHT_APP;
GRANT SELECT ON tb_usuario TO RL_STARLIGHT_USR;

GRANT SELECT ON th_usuario TO RL_STARLIGHT_AUD;


/*==============================================================*/
/* Insert: TB_USUARIO                                           */
/*==============================================================*/
CALL prc_registrar_operacao (1, '127.0.0.1');

INSERT INTO tb_usuario (no_login, tx_senha, tx_senha_temporaria, tx_email, dt_email_verificacao, tp_situacao_usuario)
    VALUES('admin', 'admin@123', NULL, 'adm@wjangoo.io', now(), 2);

COMMIT;