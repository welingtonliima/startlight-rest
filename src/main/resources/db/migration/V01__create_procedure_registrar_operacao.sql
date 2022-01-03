/*==============================================================*/
/* Procedure: PRC_REGISTRAR_OPERACAO                            */
/*==============================================================*/
CREATE OR REPLACE PROCEDURE prc_registrar_operacao (p_id_usuario_operacao numeric, p_nu_ip varchar(80))
LANGUAGE plpgsql AS $$
BEGIN 
    EXECUTE FORMAT('set auditoria.id_usuario_operacao=%s', p_id_usuario_operacao) ;
    EXECUTE FORMAT('set auditoria.nu_ip_operacao=%L', p_nu_ip) ;
END;
$$;