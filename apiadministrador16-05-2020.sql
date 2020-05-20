
CREATE   PROCEDURE `miprocedure` ()  BEGIN
DECLARE Cruc INTEGER DEFAULT 0;
DECLARE CSubDominio INTEGER DEFAULT 0;
DECLARE mensaje varchar(255) default "" ;
DECLARE var_userdb varchar(255) default "" ;
DECLARE var_passDB varchar(255) default "" ;
DECLARE var_db varchar(255) default "" ;
DECLARE aleatorio varchar(255) default "" ;
declare dat_fecha_actual datetime default (select now());
 set Cruc=(select count(*) from business where  ruc= "1212121");
 set CSubDominio=(select count(*) from business where  sub_dominio = "misubdshd");
  end;

CREATE   PROCEDURE `SP_ADMIN_AGREGAR_EMPRESAS` (IN `pint_id_tip_doc` INT(11), IN `pvar_num_documento` VARCHAR(15), IN `pcha_tip_persona` CHAR(1), IN `pvar_nombres` VARCHAR(50), IN `pvar_ape_paterno` VARCHAR(20), IN `pvar_ape_materno` VARCHAR(20), IN `pvar_ruc` VARCHAR(11), IN `pvar_id_tip_doc_contacto` VARCHAR(50), IN `pvar_num_documento_contacto` VARCHAR(50), IN `pvar_nombre_contacto` VARCHAR(50), IN `pvar_ape_paterno_contacto` VARCHAR(50), IN `pvar_ape_materno_contacto` VARCHAR(50), IN `pvar_email1_contacto` VARCHAR(50), IN `pvar_email2_contacto` VARCHAR(50), IN `pvar_movil1_contacto` VARCHAR(15), IN `pvar_movil2_contacto` VARCHAR(15), IN `pvar_movil3_contacto` VARCHAR(15), IN `pvar_direccion` VARCHAR(255), IN `pint_ubigeo` INTEGER, IN `pvar_subdominio` VARCHAR(255), IN `pvar_host_db` VARCHAR(50), IN `pvar_db_sistema` VARCHAR(50), IN `pvar_user_db` VARCHAR(50), IN `pvar_password_db` VARCHAR(50), IN `pvar_user_created` VARCHAR(20))  BEGIN
     DECLARE       int_count_documento      INTEGER              DEFAULT        0;
     DECLARE       int_count_ruc            INTEGER              DEFAULT        0;
     DECLARE       int_count_SubDominio     INTEGER              DEFAULT        0;

     DECLARE       int_id_empresa           INTEGER              DEFAULT        0;
     DECLARE       int_id_persona           INTEGER              DEFAULT        0;
     DECLARE       int_id_pers_contacto     INTEGER              DEFAULT        0;
     DECLARE       int_id_contacto          INTEGER              DEFAULT        0;
     DECLARE       int_id_vendedor          INTEGER              DEFAULT        0;

     DECLARE       var_mensaje              VARCHAR(255)         DEFAULT        "" ;
     DECLARE       dat_fecha_actual         DATETIME             DEFAULT       (SELECT now());
     
     START TRANSACTION;

        IF(pcha_tip_persona=1)THEN
            IF(pvar_num_documento!= '')THEN
                SET int_count_documento=(SELECT count(*) 
                                            FROM personas
                                                WHERE   num_documento = pvar_num_documento);
            END IF;
            IF(pvar_ruc!= '')THEN
                SET int_count_ruc=(SELECT count(*) 
                                            FROM personas
                                                WHERE  ruc = pvar_ruc);
            END IF;
        ELSE    
            IF(pcha_tip_persona = 2) THEN
                SET int_count_documento=(SELECT count(*) 
                                            FROM personas
                                                WHERE  num_documento = pvar_num_documento);
            END IF;
        END IF;
     
        SET int_count_SubDominio=(SELECT count(*) 
                                    FROM empresas 
                                        WHERE  sub_dominio = pvar_subdominio);

        IF(pcha_tip_persona=1 and int_count_ruc>0)THEN
            set var_mensaje =concat('El ruc ',pvar_ruc, ' Ya existe');
        ELSEIF (pcha_tip_persona=2 and int_count_documento>0) THEN
                set var_mensaje =concat('El ruc ',pvar_num_documento, ' Ya existe');
        ELSE  
            IF(int_count_documento > 0 AND int_count_SubDominio > 0 ) THEN
                set var_mensaje =concat('El numero de documento ',pvar_num_documento,' o el subdominio ',pvar_subdominio,' ya existe ');
            ELSE
                IF (int_count_documento = 0) THEN  
                    IF(int_count_SubDominio = 0)THEN

                        INSERT INTO personas (id_tip_doc,             num_documento,              tip_persona,
                                              nombres,                ape_paterno,                ape_materno,
                                              ruc,                    created_user,               created_at,        
                                              status
                                             )
                                      VALUES(pint_id_tip_doc,         pvar_num_documento,         pcha_tip_persona, 
                                              pvar_nombres,           pvar_ape_paterno,           pvar_ape_materno, 
                                             pvar_ruc,                pvar_user_created,          dat_fecha_actual,   
                                             1
                                            );
                        SET int_id_persona = (SELECT @@identity );
                        

                        INSERT INTO empresas(id_persona,              direccion,                  ubigeo,
                                             sub_dominio,             db_host,                    db_name,                    
                                             db_usuario,              db_contrasena,              fec_afiliacion,            
                                             flg_reconexion,          estado,                     created_user,
                                             created_at, status
                                            )
                                     VALUES(int_id_persona,           pvar_direccion,             pint_ubigeo,
                                            pvar_subdominio,          pvar_host_db,               pvar_db_sistema,
                                            pvar_user_db,             pvar_password_db,           dat_fecha_actual,
                                            int_id_vendedor,          1,                          pvar_user_created,
                                            dat_fecha_actual,         1
                                          );
                        SET int_id_empresa=(SELECT @@identity);

                        INSERT into personas(id_tip_doc,                       num_documento,                       tip_persona,
                                             nombres,                          ape_paterno,                         ape_materno,
                                             ruc,                              created_user,                        created_at,        
                                             status
                                             )
                                      VALUES(pvar_id_tip_doc_contacto,         pvar_num_documento_contacto,         1, 
                                             pvar_nombre_contacto,             pvar_ape_paterno_contacto,           pvar_ape_materno_contacto, 
                                             pvar_ruc,                         pvar_user_created,                   dat_fecha_actual,   
                                             1
                                            );
                        SET int_id_pers_contacto=(SELECT @@identity);

                        INSERT INTO contactos(id_persona,              id_empresa,                 email1, 
                                               email2,                   movil1,                    movil2,
                                              movil3,                  created_user,               created_at,  
                                             status
                                            )
                                    VALUES ( int_id_pers_contacto,    int_id_empresa,              pvar_email1_contacto, 
                                             pvar_email2_contacto,    pvar_movil1_contacto,        pvar_movil2_contacto,
                                             pvar_movil3_contacto,    pvar_user_created,           dat_fecha_actual, 
                                            1
                                           );
                        SET int_id_contacto=(SELECT @@identity );
                        IF(int_id_persona=0 OR int_id_empresa=0 OR int_id_contacto=0 OR int_id_pers_contacto=0 )THEN
                          ROLLBACK;
                          SET var_mensaje='Ocurrio un problema al intentar registrar empresa';
                        ELSE
                            COMMIT;
                            SET var_mensaje='Empresa registrado satisfactoriamente';
                        END IF;
                    ELSE
                       set var_mensaje =concat('El subdominio ',pvar_subdominio,' ya existe'); 
                    END IF;
                ELSE
                    set var_mensaje =concat('El numero de documento ',pvar_num_documento, ' Ya existe');   
                END IF;         
            END IF;
        END IF;    
   SELECT var_mensaje;
 end;

CREATE   PROCEDURE `SP_ADMIN_EDITAR_EMPRESA` (IN `pint_id_empresa` INT(11), IN `pint_id_tip_doc` INT(11), IN `pvar_num_documento` VARCHAR(8), IN `pcha_tip_persona` CHAR(1), IN `pvar_nombres` VARCHAR(50), IN `pvar_ape_paterno` VARCHAR(20), IN `pvar_ape_materno` VARCHAR(20), IN `pvar_ruc` VARCHAR(11), IN `pvar_id_tip_doc_contacto` VARCHAR(50), IN `pvar_num_documento_contacto` VARCHAR(50), IN `pvar_nombre_contacto` VARCHAR(50), IN `pvar_ape_paterno_contacto` VARCHAR(50), IN `pvar_ape_materno_contacto` VARCHAR(50), IN `pvar_email1_contacto` VARCHAR(50), IN `pvar_email2_contacto` VARCHAR(50), IN `pvar_movil1_contacto` VARCHAR(15), IN `pvar_movil2_contacto` VARCHAR(15), IN `pvar_movil3_contacto` VARCHAR(15), IN `pvar_direccion` VARCHAR(255), IN `pint_ubigeo` INT, IN `pint_estado` INT, IN `pvar_user_updated` VARCHAR(20))  BEGIN
   
    DECLARE        int_count_ruc                      INTEGER                   DEFAULT        0;
    DECLARE        int_count_SubDominio               INTEGER                   DEFAULT        0;

    DECLARE        int_id_empresa                     INTEGER                   DEFAULT        0;
    DECLARE        int_id_persona                     INTEGER                   DEFAULT        0;
    DECLARE        int_id_pers_contacto               INTEGER                   DEFAULT        0;
    DECLARE        int_id_contacto                    INTEGER                   DEFAULT        0;

    DECLARE        var_mensaje                        VARCHAR(255)              DEFAULT        "" ;

    DECLARE        dat_fecha_actual                   DATETIME                  DEFAULT       (SELECT now());
     
    START TRANSACTION;
    IF((SELECT count(*) FROM empresas where id_empresa=pint_id_empresa and status=1)>0) THEN

      set int_id_persona=(select id_persona 
                            from empresas 
                              where id_empresa=pint_id_empresa);

      set int_id_pers_contacto=(select id_persona 
                                    from contactos 
                                      where id_empresa=pint_id_empresa);

      set int_id_contacto=(select int_id_contacto 
                                       from contactos 
                                          where id_empresa=pint_id_empresa);

      update personas 
            set
              id_tip_doc = pint_id_tip_doc ,          num_documento = pvar_num_documento ,       tip_persona = pcha_tip_persona , 
              nombres    = pvar_nombres ,             ape_paterno   = pvar_ape_paterno ,         ape_materno = pvar_ape_materno , 
              ruc        = pvar_ruc ,                 updated_user  = pvar_user_updated ,        updated_at = dat_fecha_actual 
            where
             id_persona   = int_id_persona ;

      update empresas 
            set
              direccion    = pvar_direccion ,         ubigeo     = pint_ubigeo ,            estado = pint_estado ,          
              updated_user = pvar_user_updated ,      updated_at = dat_fecha_actual 
                
            where
              id_empresa = pint_id_empresa ;

       
      update personas 
            set
            id_tip_doc    = pint_id_tip_doc ,               num_documento = pvar_num_documento_contacto ,       nombres = pvar_nombre_contacto, 
            ape_paterno   = pvar_ape_paterno_contacto ,     ape_materno   = pvar_ape_materno_contacto ,         
            updated_user  = pvar_user_updated ,             updated_at    = dat_fecha_actual
            
            where
            id_persona = int_id_pers_contacto ;
                   
      
      update contactos 
            set 
            email1      = pvar_email1_contacto ,           email2 = pvar_email2_contacto ,        movil1 = pvar_movil1_contacto , 
            movil2      = pvar_movil2_contacto ,           movil3 = pvar_movil3_contacto ,        updated_user = pvar_user_updated ,  
            updated_at  = dat_fecha_actual 
            
            where
            id_contactos = int_id_contacto ;    
      SET var_mensaje= 'Empresa actualizada con exito';
    ELSE
     SET var_mensaje='No se encontro la empresa que se desea editar';  
   END IF;
   SELECT var_mensaje as mensaje;   
 end;

CREATE   PROCEDURE `SP_ADMIN_ELIMINAR_EMPRESAS` (IN `pint_id_empresas` INT)  BEGIN
	declare int_id_persona integer DEFAULT 0;
declare int_id_persona_contacto integer DEFAULT 0;
		set int_id_persona=(select id_persona from empresas where id_empresa=pint_id_empresas);
		set int_id_persona_contacto=(select id_persona from contactos where id_empresa=pint_id_empresas);
		UPDATE empresas SET status=0 where id_empresa=pint_id_empresas;
		UPDATE personas set status=0 where id_persona=int_id_persona;
		UPDATE personas set status=0 where id_persona=int_id_persona_contacto;
		UPDATE contactos set status=0 where id_empresa=pint_id_empresas;
SELECT 'Empresa eliminada con exito ' as var_mensaje;
     end;

CREATE   PROCEDURE `SP_ADMIN_LISTAR_EMPRESAS` ()  BEGIN
      select 	
      	emp.id_empresa, 
		IF(per.tip_persona='2',per.nombres,
			CONCAT(per.nombres,' ',per.ape_paterno,' ',per.ape_materno))as razon_social, 
	    if(per.tip_persona=2,
			per.num_documento,
				if(per.ruc!='' or per.ruc!= null,
					per.ruc,per.num_documento)
		) as documento,
		emp.direccion, 
		emp.ubigeo, 
		emp.sub_dominio, 
		emp.db_host, 
		emp.db_name, 
		emp.db_usuario, 
		emp.db_contrasena, 
		emp.fec_afiliacion, 
		emp.fec_suspencion, 
		emp.fec_cancelacion, 
		emp.id_vendedor, 
		emp.flg_reconexion, 
		IF(emp.estado=1,'ACTIVO',
			(IF(emp.estado=2,'SUSPENDIDO',
				(IF(emp.estado=3,'ANULADO','SIN SERVICIO')))))as estado,
		emp.created_user, 
		emp.updated_user, 
		emp.created_at, 
		emp.updated_at, 
		emp.status	 
		from 
			empresas  emp INNER JOIN personas per
			on emp.id_persona=per.id_persona
		where emp.status=1;
     end;

CREATE   PROCEDURE `SP_ADMIN_LISTAR_EMPRESAS_POR_ID` (IN `pint_id_empresa` INT)  BEGIN
if((select count(*) from empresas where id_empresa= pint_id_empresa and status=1)>0)THEN
    select 	per.id_persona, 
	per.id_tip_doc, 
	per.num_documento, 
	per.tip_persona, 
	per.nombres, 
	per.ape_paterno, 
	per.ape_materno, 
	per.ruc, 
    perc.id_persona as id_pers_contacto, 
	perc.id_tip_doc as id_tip_doc_contacto, 
	perc.num_documento as num_documento_contacto, 
	perc.tip_persona as tip_persona_contacto, 
	perc.nombres as nombres_contacto, 
	perc.ape_paterno as ape_paterno_contacto, 
	perc.ape_materno as ape_materno_contacto, 
	perc.ruc, 
	cont.id_contactos, 
	cont.email1, 
	cont.email2, 
	cont.movil1, 
	cont.movil2, 
	cont.movil3, 		 
	emp.id_empresa, 
	emp.direccion, 
	emp.ubigeo, 
	emp.sub_dominio, 
	emp.db_host, 
	emp.db_name, 
	emp.db_usuario, 
	emp.db_contrasena, 
	emp.fec_afiliacion, 
	emp.fec_suspencion, 
	emp.fec_cancelacion, 
	emp.id_vendedor, 
	emp.flg_reconexion  
	from 
	empresas emp inner JOIN personas per 
	on emp.id_persona= per.id_persona
	inner JOIN contactos cont 
	on emp.id_empresa=cont.id_empresa
	inner join personas perc 
	on cont.id_persona=perc.id_persona
	where emp.id_empresa=pint_id_empresa
	and emp.status = 1;
else
  SELECT 'La empresa no se encuentra registrada o fue eliminada' as mensaje;
end if;
	
  end;

CREATE   PROCEDURE `SP_ADMIN_LISTAR_EMPRESAS_POR_RUC` (IN `pvar_ruc` VARCHAR(11))  BEGIN
	select 
		emp.id_empresa,
		per.tip_persona,
		tdoc.tipo as codigo_doc,
		per.num_documento,
		if(per.tip_persona=2, 
				per.nombres ,
					concat(per.nombres," ",per.ape_paterno," ",per.ape_materno )
			) as razon_social,
		if(per.tip_persona=2,
			per.num_documento,
				if(per.ruc!='' or per.ruc!= null,
						per.ruc,per.num_documento)
		  ) as documento,
		emp.direccion,
		emp.db_host,
		emp.db_name,
		emp.db_usuario,
		emp.db_contrasena
		from personas per 
			inner join tiposdocumento tdoc
				on per.id_tip_doc=tdoc.id_tip_doc
			inner join empresas emp 
				on per.id_persona=emp.id_persona
		where per.num_ducumento=pvar_ruc
				and emp.status=1;
 end;

CREATE   PROCEDURE `SP_LISTAR_TIPO_DOCUMENTOS` ()  BEGIN
        select * from tiposdocumento;
         end;



CREATE TABLE `contactos` (
  `id_contactos` int(10) UNSIGNED NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  `id_empresa` int(11) DEFAULT NULL,
  `email1` varchar(255) DEFAULT NULL,
  `email2` varchar(255) DEFAULT NULL,
  `movil1` varchar(255) DEFAULT NULL,
  `movil2` varchar(255) DEFAULT NULL,
  `movil3` varchar(255) DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `empresas` (
  `id_empresa` int(10) UNSIGNED NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `ubigeo` int(11) NOT NULL,
  `sub_dominio` varchar(255) NOT NULL,
  `db_host` varchar(255) NOT NULL,
  `db_name` varchar(255) NOT NULL,
  `db_usuario` varchar(255) NOT NULL,
  `db_contrasena` varchar(255) NOT NULL,
  `fec_afiliacion` datetime NOT NULL,
  `fec_suspencion` datetime DEFAULT NULL,
  `fec_cancelacion` datetime DEFAULT NULL,
  `id_vendedor` int(11) DEFAULT NULL,
  `flg_reconexion` char(255) NOT NULL,
  `estado` char(255) NOT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `personas` (
  `id_persona` int(10) UNSIGNED NOT NULL,
  `id_tip_doc` int(11) DEFAULT NULL,
  `num_documento` varchar(8) NOT NULL,
  `tip_persona` char(1) NOT NULL,
  `nombres` varchar(50) NOT NULL,
  `ape_paterno` varchar(20) DEFAULT NULL,
  `ape_materno` varchar(20) DEFAULT NULL,
  `ruc` varchar(11) DEFAULT NULL,
  `created_user` varchar(5) DEFAULT NULL,
  `updated_user` varchar(5) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `tickets` (
  `id_ticket` int(10) UNSIGNED NOT NULL,
  `id_empresa` int(11) DEFAULT NULL,
  `numero` varchar(10) NOT NULL,
  `fec_emision` char(1) NOT NULL,
  `fec_vencimiento` date NOT NULL,
  `periodo` char(6) NOT NULL,
  `imp_total` decimal(8,2) NOT NULL,
  `fec_pago` datetime NOT NULL,
  `flg_reconexion` char(2) NOT NULL,
  `estado` char(1) NOT NULL,
  `created_user` varchar(10) DEFAULT NULL,
  `updated_user` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `tickets_det` (
  `id_ticket_det` int(10) UNSIGNED NOT NULL,
  `id_ticket` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `importe` decimal(8,2) NOT NULL,
  `created_user` varchar(10) DEFAULT NULL,
  `updated_user` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `tiposdocumento` (
  `id_tip_doc` int(10) UNSIGNED NOT NULL,
  `tipo` char(4) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `nom_corto` varchar(15) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



INSERT INTO `tiposdocumento` (`id_tip_doc`, `tipo`, `nombre`, `nom_corto`, `created_at`, `updated_at`) VALUES
(1, '01', 'DOCUMENTO NACIONAL DE IDENTIDAD', 'DNI', '2020-03-25 20:37:09', '2020-03-25 20:37:09'),
(2, '04', 'CARNET DE EXTRANJERIA', 'CARNET EXT.', '2020-03-25 20:37:09', '2020-03-25 20:37:09'),
(3, '06', 'REGISTRO UNICO DE CONTRIBUYENTES', 'RUC', '2020-03-25 20:37:09', '2020-03-25 20:37:09'),
(4, '07', 'PASAPORTE', 'PASAPORTE ', '2020-03-25 20:37:09', '2020-03-25 20:37:09'),
(5, '11', 'PART. DE NACIMIENTO-IDENTIDAD', 'P.NAC.', '2020-03-25 20:37:09', '2020-03-25 20:37:09'),
(6, '00', 'OTROS ', 'OTROS ', '2020-03-25 20:37:09', '2020-03-25 20:37:09');



CREATE TABLE `vendedores` (
  `id_vendedor` int(10) UNSIGNED NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  `fec_activacion` datetime NOT NULL,
  `estado` char(1) NOT NULL,
  `created_user` varchar(10) DEFAULT NULL,
  `updated_user` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


ALTER TABLE `contactos`
  ADD PRIMARY KEY (`id_contactos`),
  ADD KEY `contactos_id_empresa_foreign` (`id_empresa`),
  ADD KEY `contactos_id_persona_foreign` (`id_persona`);


ALTER TABLE `empresas`
  ADD PRIMARY KEY (`id_empresa`),
  ADD KEY `empresas_id_vendedor_foreign` (`id_vendedor`),
  ADD KEY `id_persona` (`id_persona`);


ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);


ALTER TABLE `personas`
  ADD PRIMARY KEY (`id_persona`),
  ADD KEY `personas_id_tip_doc_foreign` (`id_tip_doc`);


ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id_ticket`),
  ADD KEY `tickets_id_empresa_foreign` (`id_empresa`);


ALTER TABLE `tickets_det`
  ADD PRIMARY KEY (`id_ticket_det`),
  ADD KEY `tickets_det_id_ticket_foreign` (`id_ticket`);


ALTER TABLE `tiposdocumento`
  ADD PRIMARY KEY (`id_tip_doc`);


ALTER TABLE `vendedores`
  ADD PRIMARY KEY (`id_vendedor`),
  ADD KEY `vendedores_id_persona_foreign` (`id_persona`);


ALTER TABLE `contactos`
  MODIFY `id_contactos` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `empresas`
  MODIFY `id_empresa` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `personas`
  MODIFY `id_persona` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `tickets`
  MODIFY `id_ticket` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `tickets_det`
  MODIFY `id_ticket_det` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `tiposdocumento`
  MODIFY `id_tip_doc` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;


ALTER TABLE `vendedores`
  MODIFY `id_vendedor` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;


