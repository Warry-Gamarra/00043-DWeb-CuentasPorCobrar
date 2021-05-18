USE [BD_OCEF_CtasPorCobrar]
GO


/*------------------------------------------ Correos ---------------------------------------------------*/


INSERT INTO [dbo].[TS_CorreoAplicacion](T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, D_FecUpdate, B_Habilitado, B_Eliminado)
	 VALUES (N'wgamarra@unfv.edu.pe', N'WgBHAEEAUABtAHAATAAxAEAAMgAwADEANgA=', 'TLS', 'smtp.office365.com', 587, GETDATE(), 1, 0)
GO


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('TIPO ALUMNO', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(1, 'Alum. Regulares', '1', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(1, 'Alumn. Ingresantes', '2', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(1, 'Todos', '3', 1, 0)


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('GRADO', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(2, 'Pre Grado', '1', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(2, 'Post.G.(Maestría)', '2', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(2, 'Post.G.(Doctorado)', '3', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(2, 'Sec.Post.G', '4', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(2, 'Todos', '5', 1, 0)


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('TIPO OBLIGACIÓN', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(3, 'Matrícula', '1', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(3, 'Otros pagos', '0', 1, 0)


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('CAMPO CALCULADO', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(4, 'Crd. Desaprobados', '1', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(4, 'Deudas Anteriores', '2', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(4, 'Pensión de enseñanza', '3', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(4, 'No Voto', '4', 1, 0)


/* -------------------------------- TC_EntidadFinanciera - TC_CuentaDeposito ------------------------------------ */

SET IDENTITY_INSERT TC_EntidadFinanciera ON
GO

INSERT TC_EntidadFinanciera(I_EntidadFinanID, T_EntidadDesc, B_Habilitado, B_Eliminado)values(1, 'BANCO DE COMERCIO', 1, 0)
INSERT TC_EntidadFinanciera(I_EntidadFinanID, T_EntidadDesc, B_Habilitado, B_Eliminado)values(2, 'BANCO DE CRÉDITO DEL PERÚ', 1, 0)

SET IDENTITY_INSERT TC_EntidadFinanciera OFF
GO


INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-0414438', 1, 0)
INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-0416304', 1, 0)
INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-0418432', 1, 0)
INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-0444317', 1, 0)
INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-0450881', 1, 0)
INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-045127-2', 1, 0)
INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(1, '110-01-0451398', 1, 0)


INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado) VALUES(2, '119-104146435-1-01', 1, 0)
GO



/* -------------------------------- TC_CategoriaPago ------------------------------------ */

--INSERT INTO TC_CategoriaPago (T_CatPagoDesc, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (N'MIGRADO (CATEGORIA TEMPORAL)', 10, 1, 8, 3, 0, 0)
SET IDENTITY_INSERT TC_CategoriaPago ON
GO

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (1, N'MATRÍCULA PREGRADO INGRESANTE', '0639', 1, 1, 4, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (2, N'MATRÍCULA PREGRADO REGULAR', '0635', 1, 1, 4, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (3, N'MATRÍCULA EUPG MAESTRÍA INGRESANTE', '0671', 1, 1, 5, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (4, N'MATRÍCULA EUPG MAESTRÍA REGULAR', '0670', 1, 1, 5, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (5, N'MATRÍCULA EUPG DOCTORADO INGRESANTE', '0675', 1, 1, 6, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (6, N'MATRÍCULA EUPG DOCTORADO REGULAR', '0674', 1, 1, 6, 1, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (7, N'PENSIÓN EUPG MAESTRÍA INGRESANTE', '0679', 2, 1, 5, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (8, N'PENSIÓN EUPG MAESTRÍA REGULAR', '0678', 2, 1, 5, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (9, N'PENSIÓN EUPG DOCTORADO INGRESANTE', '0681', 2, 1, 6, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (10, N'PENSIÓN EUPG DOCTORADO REGULAR', '0680', 2, 1, 6, 1, 1, 0)
																																							 
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (11, N'DEUDA ANTERIOR EUPG MAESTRÍA', '0682', 1, 1, 5, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (12, N'DEUDA ANTERIOR EUPG DOCTORADO', '0683', 1, 1, 6, 3, 1, 0)
																																							 
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (13, N'OTROS PAGOS PREGRADO INGRESANTE', '0638', 2, 1, 4, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (14, N'OTROS PAGOS PREGRADO REGULAR', '0637', 2, 1, 4, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (15, N'OTROS PAGOS EUPG INGRESANTE', '0698', 2, 1, 7, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (16, N'OTROS PAGOS EUPG REGULAR', '0695', 2, 1, 7, 1, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (17, N'MATRÍCULA EUDED INGRESANTE', '0685', 1, 1, 4, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (18, N'MATRÍCULA EUDED REGULAR', '0685', 1, 1, 4, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (19, N'PENSIÓN EUDED INGRESANTE', '0688', 2, 1, 4, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (20, N'PENSIÓN EUDED REGULAR', '0687', 2, 1, 4, 1, 1, 0)


INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (21, N'MATRÍCULA EUPG MAESTRÍA SEMIPRESENCIAL INGRESANTE', '0672', 1, 1, 5, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (22, N'MATRÍCULA EUPG MAESTRÍA SEMIPRESENCIAL REGULAR', '0672', 1, 1, 5, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (23, N'MATRÍCULA EUPG DOCTORADO SEMIPRESENCIAL INGRESANTE', '0673', 1, 1, 6, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (24, N'MATRÍCULA EUPG DOCTORADO SEMIPRESENCIAL REGULAR', '0673', 1, 1, 6, 1, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (25, N'PENSION EUPG MAESTRÍA SEMIPRESENCIAL INGRESANTE', '0677', 1, 1, 5, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (26, N'PENSION EUPG MAESTRÍA SEMIPRESENCIAL REGULAR', '0677', 1, 1, 5, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (27, N'PENSION EUPG DOCTORADO SEMIPRESENCIAL INGRESANTE', '0676', 1, 1, 6, 2, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (28, N'PENSION EUPG DOCTORADO SEMIPRESENCIAL REGULAR', '0676', 1, 1, 6, 1, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (29, N'PENSION EUPG MAESTRÍA PERIODO ANTERIOR', '0696', 1, 1, 5, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (30, N'PENSION EUPG DOCTORADO PERIODO ANTERIOR', '0697', 1, 1, 6, 1, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (31, N'PENSION PROLICED REGULAR', '0689', 1, 1, 6, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (32, N'MATRÍCULA PROLICED REGULAR', '0690', 1, 1, 6, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (33, N'MATRÍCULA PROCUNED REGULAR', '0691', 1, 1, 6, 1, 1, 0)
INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (34, N'PENSION PROCUNED REGULAR', '0692', 1, 1, 6, 1, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (35, N'SERVICIO DE SALUD', '0636', 2, 1, 4, 3, 1, 0)

INSERT INTO TC_CategoriaPago (I_CatPagoID, T_CatPagoDesc, N_CodBanco, I_Prioridad, B_Obligacion, I_Nivel, I_TipoAlumno, B_Habilitado, B_Eliminado) VALUES (36, N'OTRAS TASAS SIN OBLIGACIÓN', NULL, 2, 0, 8, 3, 1, 0)

SET IDENTITY_INSERT TC_CategoriaPago off
GO




/*------------------------------------ Dependencias ------------------------------------*/
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('000000','0000000000','ADMINISTRACION CENTRAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010000','03000OGREC','RECTORADO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010007','03091APREC','OFICINA DE ACREDITACION',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010100','03010OCREC','OFICINA GENERAL DE AUDITORIA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010200','03020ASREC','OFICINA CENTRAL DE PLANIFICACION',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010300','03040RNREC','OFICINA CENTRAL DE RELACIONES NACIONALES E INTERNACIONES',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010400','03030ASREC','OFICINA CENTRAL JURIDICO LEGAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010500','03050ASREC','SECRETARIA GENERAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010600','03060APREC','OFICINA CENTRAL DE COMUNICACIËN E IMAGEN INSTITUCIONAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010700','03070APREC','OFICINA CENTRAL DE BIENESTAR UNIVERSITARIO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010800','03080APREC','CENTRO UNIVERSITARIO DE COMPUTO E INFORMATICA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010901','03140DCREC','CENTRO PRE UNIVERSITARIO VILLARREAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('010902','04010ODREC','EDITORIAL UNIVERSITARIA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011000','03100DCREC','ESCUELA UNIVERSITARIA DE POST GRADO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011100','','CENTRO UNIVERSITARIO INVESTIGACION Y PROYECCION NACIONAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011104','04020ODREC','FONDO DOCUMENTARIO DE LA CULTURA PERUANA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011200','','CENTRO UNIVERSITARIO RELACION, GESTION Y ACCION SOCIAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011300','03130DCREC','CENTRO DE EXTENSION UNIVERSITARIA Y PROYECCION SOCIAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011302','04060APVAC','INSTITUTO DE IDIOMAS',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011400','03110DCREC','ESCUELA UNIVERSITARIA DE EDUCACION .A DISTANCIA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('011500','03120DCREC','CENTRO UNIVERSITARIO DE PRODUCCION DE BIENES Y SERVICIOS',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020000','04000OGVAC','VICE RECTORADO ACADEMICO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020100','04010APVAC','OFICINA CENTRAL DE ADMISION',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020200','04020APVAC','OFICINA CENTRAL DE ASUNTOS ACADEMICOS',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020300','04030APVAC','OFICINA CENTRAL DE INVESTIGACION',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020400','03150DCREC','CENTRO CULTURAL FEDERICO VILLARREAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020500','04040APVAC','INSTITUTO CENTRAL DE RECREACION EDUCACION FISICA Y DEPORTES',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('020600','04050APVAC','OFICINA CENTRAL DE REGISTRO CENTRAL Y CENTRO DE COMPUTO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('030000','05000OGVAD','VICE RECTORADO ADMINISTRATIVO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('030100','05020APVAD','OFICINA CENTRAL DE RECURSOS HUMANOS',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('030200','05030APVAD','OFICINA CENTRAL DE LOGISTICA Y SERVICIOS GENERALES',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('030300','05010APVAD','OFICINA CENTRAL ECONOMICO FINANCIERA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('030500','05040APVAD','OFICINA DE INFRAESTRUCTURA Y DESARROLLO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('039003','05050APVAD','OFICINA DE PATRIMONIO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('100000','06020OLFAC','ARQUITECTURA Y URBANISMO',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('110000','06010OLFAC','ADMINISTRACION',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('120000','06030OLFAC','CIENCIAS ECONOMICAS',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('130000','06040OLFAC','CIENCIAS FINANCIERAS Y CONTABLES',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('140000','06050OLFAC','CIENCIAS NATURALES Y MATEMATICA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('150000','06060OLFAC','CIENCIAS SOCIALES',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('160000','06090OLFAC','HUMANIDADES',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('170000','06070OLFAC','DERECHO Y CIENCIA POLITICA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('180000','06080OLFAC','EDUCACION',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('190000','06100OLFAC','INGENIERIA CIVIL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('200000','06120OLFAC','INGENIERIA GEOGRAFICA Y AMBIENTAL',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('210000','06130OLFAC','INGENIERIA INDUSTRIAL Y SISTEMAS',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('220000','06140OLFAC','MEDICINA "HIPOLITO UNANUE"',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('230000','06150OLFAC','OCEANOGRAFIA, PESQUERIA Y CC.AA.',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('240000','06160OLFAC','ODONTOLOGIA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('250000','06170OLFAC','PSICOLOGIA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('260000','06180OLFAC','TECNOLOGIA MEDICA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('270000','06110OLFAC','INGENIERIA ELECTRONICA E INFORMATICA',1,0)
INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('040000','06000OGVRI','VICERRECTORADO DE INVESTIGACION',1,0)

--INSERT INTO TC_DependenciaUNFV (C_DepCod, C_DepCodPl, T_DepDesc, B_Habilitado, B_Eliminado) VALUES ('','03110OLFAC','',0,0)
GO


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('PERIODOS', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'ANUAL', 'A', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'REGULARIZ. CURSADA', 'G', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'SUBSANACION', 'S', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'EXAMENES EXTRAORDINA', 'E', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'SEMESTRAL (1)', '1', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'SEMESTRAL (2)', '2', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'NIVELACION', 'N', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'REGULARIZACION', 'R', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'APLAZADOS', 'L', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'VERANO O VACACIONAL', 'V', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'CARGO', 'C', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'CONVALIDACION', 'D', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'APLAZADOS', 'P', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'COMPLEMENTACION ACAD', 'M', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'SUBSANACION (COMPLE)', 'B', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'ADELANTO', '0', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'RECONOCIMIENTO', 'T', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'CONV.MOVIL.ESTUDIANT', 'K', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'CICLO ESPECIAL', 'Z', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'CICLO EXTRAORDINARIO', 'X', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'ADELANTO EXTRAORDINA', 'I', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'ESPECIAL CECCPUE', 'W', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(5, 'EVALUACION ESPECIAL', 'U', 1, 0)
GO


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('GRUPO COD_RC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(6, 'GRUPO 1', '1', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(6, 'GRUPO 2', '2', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(6, 'GRUPO 3', '3', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(6, 'GRUPO 4', '4', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(6, 'GRUPO P', 'P', 1, 0)
GO


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('COD INGRESO', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'ADMISION ORDINARIA', 'AD', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'BACHILLER FAP (COMPLEMENTACION', 'BF', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONV.COOP. Y COORD. TECN.ACAD.', 'CY', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PAGANTES-INGRESANTES CONVENIOS', 'PA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'BACHILLER (OPTAR TITULO)', 'OT', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CENEPA', 'CC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CENEPA E HIJOS C.TER', 'CN', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CEPREVI', 'CE', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO COMPUTRONIC', 'CT', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EJERCITO PERUANO', 'CP', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EMCH', 'CM', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EMCH-TRASLADO EXTERNO', 'MT', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EP - BACH. ENFERMERIA', 'PB', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EP - ENFERMERIA', 'PE', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EP - SEGUNDA PROFESION', 'PS', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EUPG-COINDE', 'CI', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EXTERNO INTERNACIONAL', 'CX', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO FAP - COMPL. BACH.', 'FB', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO FAP-SEGUNDA PROFESION', 'FS', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO FUERZA AEREA DEL PERU', 'CF', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO PNP-SEGUNDA PROFESION', 'LS', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO POLICIA NAC. DEL PERU', 'CL', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'EDUCACION A DISTANCIA', 'ED', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'HEROES DEL CENEPA', 'HC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'HIJOS - VICT. DE TERRORISMO', 'HT', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'MEJORES DEPORTISTAS', 'MD', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'OTROS CONVENIOS', 'CO', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PERSONAS CON DISCAPACIDAD', 'PD', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST GRADO', 'PG', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST GRADO (HOSPITAL B-C)', 'BC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST GRADO (ICTE)', 'IC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (C.HOSP.DANIEL CAR)', 'HA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (CONV.REG.DE SALUD)', 'GH', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (CONVENIO UNFV-CAL)', 'CA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (DEVIDA)', 'DP', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (FAP)', 'PF', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (HOSP. 2 DE MAYO)', 'DM', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (HOSP. STA. ROSA)', 'HS', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO CON.INST.SALUD NIÐO', 'HN', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO SALUD I-C', 'DS', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO SALUD III-CALLAO', 'DC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(CONV. MINIST.JUSTIC', 'MJ', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(CONV.CONT.PUBL.PUN)', 'DA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(INST.ESP.MATER.PER)', 'MP', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PRIMEROS PUESTOS', 'PP', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PROCAE', 'PC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PROCUNED', 'PR', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PROLICED', 'PL', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'REGULARIZACION POR COBERTURA', 'RC', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'SEGUNDA ESPECIALIDAD', 'SG', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'SEGUNDA PROFESION', 'SP', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'TRASLADO EXTERNO', 'TE', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'TRASLADO EXTERNO (UNIV. NAC.)', 'TN', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'TRASLADO EXTERNO (UNIV. PART.)', 'TP', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'TRASLADO INTERNO', 'TI', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'TRASLADOS', 'TR', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'BACHILLERATO DE ENFERMERIA', 'BE', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(DISA IV-LIMA-ESTE)', 'CD', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO EP - ENFERMERIA', 'EE', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CONVENIO INTERN.(ANDRES BELLO)', 'CB', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(C.MED-CO.REG.XVIII)', 'CR', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(DISA III-HOP.CHANC)', 'IH', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (ESSALUD-C.R.CAST.)', 'RT', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO(C.MED-HOS.GRAU III)', 'HG', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'SEMIPRESENCIAL Y VIRTUAL', 'SV', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'SEMIPRESENCIAL', 'SM', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO <HOSP. ALMENARA>', 'RA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'EX.ADM.CADETES EMCH 2004', 'EA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'EXONERADO POR GRADO-TITULO', 'EX', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'P.A. DE MOVILIDAD ESTUDIANTIL', 'ME', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'PLAN INTEGRAL DE REPARACION', 'PI', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'APTITUD FISICA', 'AF', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'OPTAR GRADO ACADEMICO', 'OG', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'REUBICADO', 'RU', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'CAMBIO DE ESPECIALIDAD', 'BO', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'POST-GRADO (COLEG.ARQ.C.R.HUA)', 'HU', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(7, 'REGULARIZ.DE INGRESO', 'RI', 1, 0)
GO


INSERT TC_Parametro(T_ParametroDesc, B_Habilitado, B_Eliminado) VALUES('MOTIVO MATRICULA', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'LICENCIA', 'L', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'RESERVA DE MATRICULA', 'R', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'ANULADO X R.RECTORAL', 'A', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'ANULADO X R.FACULTAD', 'F', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'SIN OBSERVACIONES   ', 'S', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'REHABILITADO POR', 'H', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'RETIRADO', 'T', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'MATRICULA NO PROCEDE', 'N', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'AMPLIACION DE CREDIT', 'P', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'MAT.AUTOR.REPR.PENDI', 'E', 1, 0)
INSERT TC_CatalogoOpcion(I_ParametroID, T_OpcionDesc, T_OpcionCod, B_Habilitado, B_Eliminado) VALUES(8, 'PENDIENTE X IMPRIMIR', 'I', 1, 0)
GO


SET IDENTITY_INSERT TC_TipoArchivo ON;

INSERT INTO TC_TipoArchivo (I_TipoArchivoID, T_TipoArchivDesc, B_ArchivoEntrada, B_ArchivoSalida, B_Habilitado, B_Eliminado) VALUES (1, 'DATOS DE ALUMNO', 0, 1, 1, 0)
INSERT INTO TC_TipoArchivo (I_TipoArchivoID, T_TipoArchivDesc, B_ArchivoEntrada, B_ArchivoSalida, B_Habilitado, B_Eliminado) VALUES (2, 'DEUDA DE OBLIGACIONES', 0, 1, 1, 0)
INSERT INTO TC_TipoArchivo (I_TipoArchivoID, T_TipoArchivDesc, B_ArchivoEntrada, B_ArchivoSalida, B_Habilitado, B_Eliminado) VALUES (3, 'RECAUDACIÓN DE OBLIGACIONES ', 1, 0, 1, 0)
INSERT INTO TC_TipoArchivo (I_TipoArchivoID, T_TipoArchivDesc, B_ArchivoEntrada, B_ArchivoSalida, B_Habilitado, B_Eliminado) VALUES (4, 'RECAUDACIÓN DE TASAS SIN OBLIGACIONES', 1, 0, 1, 0)

SET IDENTITY_INSERT TC_TipoArchivo OFF;



SET IDENTITY_INSERT TS_CampoTablaPago ON;

INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (1, 'type_dataPago', 'C_CodAlu', 'Código de depositante', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (2, 'type_dataPago', 'C_CodOperacion', 'Código de operación', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (3, 'type_dataPago', 'C_Referencia', 'Código de referencia', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (4, 'type_dataPago', 'C_CodRc', 'Código de carrera', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (5, 'type_dataPago', 'C_Moneda', 'Moneda', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (6, 'type_dataPago', 'D_FecPago', 'Fec. Pago', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (7, 'type_dataPago', 'D_FecVencto', 'Fec. vencimiento', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (8, 'type_dataPago', 'I_Cantidad', 'Cantidad', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (9, 'type_dataPago', 'I_MontoPago', 'Monto de pago', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (10, 'type_dataPago', 'I_ProcesoID', 'Cuota de pago', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (11, 'type_dataPago', 'T_LugarPago', 'Lugar de pago', 3, 1, 0, 1, GETDATE())
INSERT INTO TS_CampoTablaPago (I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (12, 'type_dataPago', 'T_NomDepositante', 'Nombre del depositante', 3, 1, 0, 1, GETDATE())

SET IDENTITY_INSERT TS_CampoTablaPago OFF;



--/*---------------------------------------------------------------------------------------------------------------------------------------*/
--/*---------------------------------------------------------------------------------------------------------------------------------------*/
--/*														MIGRACION DE DATOS DEL TEMPORAL DE PAGOS										 */
--/*---------------------------------------------------------------------------------------------------------------------------------------*/
--/*---------------------------------------------------------------------------------------------------------------------------------------*/


/* -------------------------------- TC_CuentaDeposito ------------------------------------ */

/*	SI DURANTE LA MIGRACION EXISTEN MAS NUMEROS DE CUENTA QUE LOS REGISTRADOS INICIALMENTE SE
	INSERTAN EN LA TABLA TC_CuentaDeposito
*/


IF EXISTS (SELECT DISTINCT N_CTA_CTE FROM temporal_pagos..cp_des 
			WHERE ELIMINADO = 0 AND NOT EXISTS (
			SELECT * FROM TC_CuentaDeposito CD 
			WHERE N_CTA_CTE COLLATE DATABASE_DEFAULT = C_NumeroCuenta COLLATE DATABASE_DEFAULT))
BEGIN
	INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado)
	SELECT DISTINCT 1, N_CTA_CTE, 1, 0 FROM temporal_pagos..cp_des 
			WHERE ELIMINADO = 0 AND NOT EXISTS (
			SELECT * FROM TC_CuentaDeposito CD 
			WHERE N_CTA_CTE COLLATE DATABASE_DEFAULT = C_NumeroCuenta COLLATE DATABASE_DEFAULT)
END
GO


/* -------------------------------- TC_CuentaDeposito_CategoriaPago ------------------------------------ */

INSERT TC_CuentaDeposito_CategoriaPago(I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado)
SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
FROM TC_CategoriaPago CP 
	 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
				 FROM TC_CuentaDeposito CD  
				 	 INNER JOIN temporal_pagos..cp_des TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
				 WHERE ELIMINADO = 0
) BNC ON CP.N_CodBanco = BNC.CODIGO_BNC
UNION
SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
FROM TC_CategoriaPago CP 
	 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
				 FROM TC_CuentaDeposito CD  
 				 		INNER JOIN temporal_pagos..cp_des TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
				 WHERE CODIGO_BNC IS NULL AND ELIMINADO = 0
) BNC ON CP.N_CodBanco IS NULL
GO


/* -------------------------------- TC_Proceso - TI_CtaDepo_Proceso ------------------------------------ */

SET IDENTITY_INSERT TC_Proceso ON
GO

WITH TEMP_PROC (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, B_Habilitado, B_Eliminado)
AS
(
	SELECT CAST(TP_CD.CUOTA_PAGO AS INT) CUOTA_PAGO, I_CatPagoID, TP_CD.DESCRIPCIO, 
	   CASE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4))) WHEN 1 THEN SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4) ELSE NULL END AS I_Anio, 
	    CODIGO_BNC, FCH_VENC, PRIORIDAD, CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 ELSE NULL END AS C_MORA,
		1 AS B_Migrado, 1 AS B_Habilitado, TP_CD.ELIMINADO
	FROM TC_CategoriaPago CP  
		  INNER JOIN temporal_pagos..cp_des TP_CD ON CP.N_CodBanco COLLATE DATABASE_DEFAULT = TP_CD.CODIGO_BNC COLLATE DATABASE_DEFAULT
	WHERE TP_CD.ELIMINADO = 0 AND CODIGO_BNC IN (
			'0635','0636','0638','0670','0671','0674',
			'0675','0678','0679','0680','0681','0682',
			'0683','0689','0690','0691','0692','0695',
			'0696','0697','0698'
			)
)

INSERT INTO TC_Proceso (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, B_Habilitado, B_Eliminado)
SELECT	I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, co_periodo.I_OpcionID AS I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, TEMP.B_Habilitado, TEMP.B_Eliminado
FROM	TEMP_PROC TEMP
		LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM temporal_pagos..cp_pri WHERE eliminado = 0) TP_CP ON TP_CP.cuota_pago = TEMP.I_ProcesoID
		LEFT JOIN TC_CatalogoOpcion co_periodo ON co_periodo.T_OpcionCod COLLATE DATABASE_DEFAULT = TP_CP.p COLLATE DATABASE_DEFAULT AND co_periodo.I_ParametroID = 5
WHERE	NOT EXISTS (
			SELECT TP_CD2.I_ProcesoID , COUNT(TP_CD2.I_ProcesoID)
			  FROM TEMP_PROC TP_CD2
				   LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM temporal_pagos..cp_pri WHERE eliminado = 0) TP_CP ON TP_CP.cuota_pago = TP_CD2.I_ProcesoID
			 WHERE TP_CD2.I_ProcesoID = TEMP.I_ProcesoID
			GROUP BY TP_CD2.I_ProcesoID
			HAVING COUNT(TP_CD2.I_ProcesoID) > 1
		)
UNION
SELECT	I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, NULL AS I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, 
		B_Migrado, TEMP.B_Habilitado, TEMP.B_Eliminado
FROM	TEMP_PROC TEMP
WHERE	EXISTS (
			SELECT TP_CD2.I_ProcesoID , COUNT(TP_CD2.I_ProcesoID)
			  FROM TEMP_PROC TP_CD2
				   LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM temporal_pagos..cp_pri WHERE eliminado = 0) TP_CP ON TP_CP.cuota_pago = TP_CD2.I_ProcesoID
			 WHERE TP_CD2.I_ProcesoID = TEMP.I_ProcesoID
			GROUP BY TP_CD2.I_ProcesoID
			HAVING COUNT(TP_CD2.I_ProcesoID) > 1
		)
UNION
SELECT CAST(TP_CD.CUOTA_PAGO AS INT) CUOTA_PAGO, I_CatPagoID, TP_CD.DESCRIPCIO, 
	   CASE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4))) WHEN 1 THEN SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4) ELSE NULL END AS I_Anio, 
	    NULL AS I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 ELSE NULL END AS C_MORA,
		1 AS B_Migrado, 1 AS B_Habilitado, TP_CD.ELIMINADO
FROM TC_CategoriaPago CP  
	  INNER JOIN temporal_pagos..cp_des TP_CD ON TP_CD.CODIGO_BNC IS NULL AND CP.B_Obligacion = 0 
WHERE TP_CD.ELIMINADO = 0

SET IDENTITY_INSERT TC_Proceso OFF
GO

-- Cambiando el Identity de TC_Periodo a la maxima cuota de pago de la base de datos del temporal de pagos.

DECLARE @I_ProcesoID	int
SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM  temporal_pagos..cp_des) + 1 

DBCC CHECKIDENT(TC_Proceso, RESEED, @I_ProcesoID)

GO

-- Estableciendo la relacion entre cuentas de deposito y procesos importados.

INSERT INTO TI_CtaDepo_Proceso (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado)
SELECT CD.I_CtaDepositoID, P.I_ProcesoID, 1 AS B_Habilitado, 0 AS B_Eliminado
FROM TC_Proceso P
	INNER JOIN temporal_pagos..cp_des TP_CD ON TP_CD.CUOTA_PAGO = P.I_ProcesoID AND TP_CD.ELIMINADO = 0
	INNER JOIN TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
GO


/* -------------------------------- TC_Concepto - TI_ConceptoPago (OBLIGACIONES) ------------------------------------ */

SET IDENTITY_INSERT TC_Concepto ON
GO

-- INSERTAR CONCEPTOS agrupa = 1
INSERT INTO TC_Concepto (I_ConceptoID, T_ConceptoDesc, T_Clasificador, I_Monto, I_MontoMinimo, B_EsObligacion, B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado)
				SELECT id_cp, descripcio, clasificad, monto, monto_min, 1, 1, 0, 1, 0, NULL, 1,eliminado
				FROM temporal_pagos..cp_pri 
				WHERE agrupa = 1 and tipo_oblig = 1

SET IDENTITY_INSERT TC_Concepto OFF
GO

-- INSERTAR CONCEPTOS agrupa = 0

 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230010100',	0, NULL, 1, 0, 40, 40,'BIBLIOTECA', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230010300',	0, NULL, 1, 0, 16, 11,'CARNET UNIVERSITARIO EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230010301',	0, NULL, 1, 0, 16, 16,'CARNET UNIVERSITARIO', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230020315',	0, NULL, 0, 0, 40, 0,'LABORATORIO EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '123003200',	0, NULL, 0, 0, 6, 6,'RECORD ACADÉMICO', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230032000',	0, NULL, 1, 0, 6, 6,'RECORD ACADÉMICO', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230033701',	0, NULL, 1, 0, 150, 150,'CONSTANCIA DE INGRESO MAESTRÍA', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230033702',	0, NULL, 1, 0, 150, 150,'CONSTANCIA DE INGRESO DOCTORADO', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230040311',	0, NULL, 1, 0, 49, 49,'LABORATORIO GABINETE - GRUPO 1', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230040312',	0, NULL, 1, 0, 42, 42,'LABORATORIO GABINETE - GRUPO 2', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230040313',	0, NULL, 1, 0, 35, 35,'LABORATORIO GABINETE - GRUPO 3', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230040314',	0, NULL, 1, 0, 28, 28,'LABORATORIO GABINETE - GRUPO 4', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230070200',	0, NULL, 1, 0, 25, 25,'SERVICIOS UNIVERSITARIOS', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080100',	0, NULL, 1, 0, 1920, 480,'PENSIÓN MAESTRIA INGRESANTE EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080110',	0, NULL, 1, 0, 1920, 480,'PENSIÓN MAESTRIA REGULAR EUPG', 1)
 --INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080200',	0, NULL, 1, 0, 2400, 600,'PENSIÓN DOCTORADO INGRESANTE EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080200',	0, NULL, 1, 0, 2400, 600,'PENSIÓN DOCTORADO REGULAR EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080610',	1, 13, 1, 0,	2232, 248,'PENSIÓN ENSEÑANZA SEGUNDA PROFESIÓN', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080605',	1, 13, 1, 0,	186, 186,'PENSIÓN CONVENIO - 2DA PROF. PNP', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080606',	1, 13, 1, 0,	186, 186,'PENSIÓN CONVENIO - 2DA PROF. EP', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080611',	1, 13, 1, 0,	200, 200,'PENSIÓN ENSEÑANZA - TRASLADO EXT.PARTICUL', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080612',	1, 13, 1, 0,	50,	50,'PENSIÓN ENSEÑANZA - TRASLADO EXT.NACIONAL', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230080618',	0, NULL, 1, 0, 100,	100,'DERECHO ACADÉMICO MENSUAL', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230081600',	0, NULL, 1, 0, 390,	130,'PENSIÓN - PROCUNED', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230081601',	0, NULL, 1, 0, 225,	225,'PENSIÓN - PROLICED', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230090200',	0, NULL, 1, 0, 35, 0,'MATRÍCULA', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion, B_ModalidadIngreso, I_ModalidadIngresoID ) VALUES (1, 0, 0, '1230090300',	0, NULL, 1, 0, 100,	100,'MATRÍCULA CONVENIO POLI', 1, 1, 64)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion, B_ModalidadIngreso, I_ModalidadIngresoID ) VALUES (1, 0, 0, '1230090301',	0, NULL, 1, 0, 170,	170,'MATRÍCULA (X CONVENIO) 2DA.PROF.FAP', 1, 1, 61)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion, B_ModalidadIngreso, I_ModalidadIngresoID ) VALUES (1, 0, 0, '1230090302',	0, NULL, 1, 0, 170,	170,'MATRÍCULA (X CONVENIO) 2DA.PROF.PNP', 1, 1, 63)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion, B_ModalidadIngreso, I_ModalidadIngresoID ) VALUES (1, 0, 0, '1230090303',	0, NULL, 1, 0, 170,	170,'MATRÍCULA (X CONVENIO) 2DA.PROF.EJE', 1, 1, 57)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion, B_ModalidadIngreso, I_ModalidadIngresoID ) VALUES (1, 0, 0, '1230090304',	0, NULL, 1, 0, 178,	178,'MATRÍCULA (ALUMNO.CONV)', 1, 1, 53)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion, B_ModalidadIngreso, I_ModalidadIngresoID ) VALUES (1, 0, 0, '1230090308',	0, NULL, 1, 0, 196,	196,'MATRÍCULA BACHILL.CONV.FAP', 1, 1, 62)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 1, 0, '1230090400',	0, NULL, 1, 0, 50, 50,'MATRÍCULA EXTEMPORÁNEA (RECARGO)', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230090502',	0, NULL, 0, 0, 80, 80,'MATRÍCULA / LIMA - PROCUNED', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230090503',	0, NULL, 0, 0, 80, 80,'MATRÍCULA / PROV. - PROCUNED', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230090504',	0, NULL, 0, 0, 100,	100,'MATRÍCULA / LIMA - PROLICED', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230090505',	0, NULL, 0, 0, 130,	130,'MATRÍCULA / PROV. - PROLICED', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230091500',	0, NULL, 1, 0, 500,	500,'MATRÍCULA MAESTRÍA - EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230091600',	0, NULL, 1, 0, 500,	500,'MATRÍCULA DOCTORADO - EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230092500',	0, NULL, 0, 0, 100,	100,'MATRÍCULA SUSPENSIÓN', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (1, 0, 0, '1230092501',	0, NULL, 0, 0, 100,	100,'MATRÍCULA CANCELADA', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230990210',	1, 14, 1 , 0, 21,21,'MULTA POR NO VOTAR', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '123099100',	1, 12, 1 , 0,	0, 0,'FRACCIONAMIENTO DEUDA ANTERIOR EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1230991000',	0, NULL, 1 , 0,	0, 0,'MORA X PENSIONES - PERIODO ACTUAL', 1)
 --INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '123991000', 0, NULL, 1 , 0, 0, 0,'MORA X PENSIONES', 1)
 --INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1323199121', 0, NULL, 1 , 0, 0, 0,'DEUDAS ANTERIORES EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1440012800',	0, NULL, 1, 0, 3, 3,'CARPETA DE MATRÍCULA', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1540020315',	0, NULL, 1, 0, 0, 0,'LABORATORIO INFORMÁTICA - EUPG', 1)
 INSERT INTO TC_Concepto (B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, T_Clasificador, B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_Monto, I_MontoMinimo, T_ConceptoDesc, B_EsObligacion ) VALUES (0, 0, 0, '1540100100',	0, NULL, 1, 0, 5, 5,'DEPORTES', 1)

 GO


SET IDENTITY_INSERT TI_ConceptoPago ON
GO

INSERT INTO TI_ConceptoPago (I_ConcPagID, I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_AlumnosDestino, I_GradoDestino, I_TipoObligacion, T_Clasificador, C_CodTasa, B_Calculado, I_Calculado, 
							B_AnioPeriodo, I_Anio, I_Periodo, B_Especialidad, C_CodRc, B_Dependencia, C_DepCod, B_GrupoCodRc, I_GrupoCodRc, B_ModalidadIngreso, I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, B_ConceptoAfecta, 
							I_ConceptoAfectaID, N_NroPagos, B_Porcentaje, C_Moneda, M_Monto, M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Migrado, B_Habilitado, B_Eliminado, I_TipoDescuentoID)

			SELECT  cp.id_cp, cp.cuota_pago, c.I_ConceptoID, cp.descripcio, cp.fraccionab, cp.concepto_g, cp.agrupa, co_tipoAlumno.I_OpcionID as tip_alumno, co_grado.I_OpcionID as grado, co_tipOblg.I_OpcionID as tip_oblig, cp.clasificad, cp.clasific_5, 
					CASE WHEN co_calc.I_OpcionID IS NULL THEN 0 ELSE 1 END as calculado, co_calc.I_OpcionID as tip_calculo, CASE CAST(cp.ano AS int) WHEN 0 THEN 0 ELSE 1 END as b_anio, CASE CAST(cp.ano AS int) WHEN 0 THEN NULL ELSE CAST(cp.ano AS int) END as anio, 
					co_periodo.I_OpcionID as periodo, CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN 0 ELSE 1 END as b_cod_rc, CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN NULL ELSE cp.cod_rc END as cod_rc, 
					CASE LEN(LTRIM(RTRIM(cp.cod_dep_pl))) WHEN 0 THEN 0 ELSE 1 END as b_cod_dep_pl, unfv_dep.I_DependenciaID, CASE WHEN co_grpRc.I_OpcionID IS NULL THEN 0 ELSE 1 END as b_co_grpRc, co_grpRc.I_OpcionID as grupo_rc,
					CASE WHEN co_codIng.I_OpcionID IS NULL THEN 0 ELSE 1 END as b_codIng, co_codIng.I_OpcionID as codIng, CASE cp.id_cp_agrp WHEN 0 THEN 0 ELSE 1 END as b_id_cp_agrp, CASE cp.id_cp_agrp WHEN 0 THEN NULL ELSE cp.id_cp_agrp END as id_cp_agrp, 
					CASE cp.id_cp_afec WHEN 0 THEN 0 ELSE 1 END as b_id_cp_afec, CASE cp.id_cp_afec WHEN 0 THEN NULL ELSE cp.id_cp_afec END as id_cp_afec, cp.nro_pagos, cp.porcentaje, 'PEN' as moneda, cp.monto, cp.monto_min, cp.descrip_l,
					cp.documento, 1 as migrado, 1 as habilitado, cp.eliminado as eliminado, NULL as tipo_descuento

			FROM	temporal_pagos.dbo.cp_pri cp
					INNER JOIN TC_Concepto c ON c.T_Clasificador COLLATE DATABASE_DEFAULT = cp.clasificad COLLATE DATABASE_DEFAULT AND c.B_ConceptoAgrupa = 0
					INNER JOIN TC_Proceso p ON cp.cuota_pago = p.I_ProcesoID
					LEFT JOIN TC_CatalogoOpcion co_tipoAlumno ON CAST(co_tipoAlumno.T_OpcionCod AS float) = cp.tip_alumno AND co_tipoAlumno.I_ParametroID = 1
					LEFT JOIN TC_CatalogoOpcion co_grado ON CAST(co_grado.T_OpcionCod AS float) = cp.grado AND co_grado.I_ParametroID = 2
					LEFT JOIN TC_CatalogoOpcion co_tipOblg ON CAST(co_tipOblg.T_OpcionCod AS bit) = cp.tipo_oblig AND co_tipOblg.I_ParametroID = 3
					LEFT JOIN TC_CatalogoOpcion co_calc ON co_calc.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.calcular COLLATE DATABASE_DEFAULT AND co_calc.I_ParametroID = 4
					LEFT JOIN TC_CatalogoOpcion co_periodo ON co_periodo.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.p COLLATE DATABASE_DEFAULT AND co_periodo.I_ParametroID = 5
					LEFT JOIN TC_CatalogoOpcion co_grpRc ON co_grpRc.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.grupo_rc COLLATE DATABASE_DEFAULT AND co_grpRc.I_ParametroID = 6
					LEFT JOIN TC_CatalogoOpcion co_codIng ON co_codIng.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.cod_ing COLLATE DATABASE_DEFAULT AND co_codIng.I_ParametroID = 7
					LEFT JOIN TC_DependenciaUNFV unfv_dep on unfv_dep.C_DepCodPl COLLATE DATABASE_DEFAULT = cp.cod_dep_pl COLLATE DATABASE_DEFAULT AND LEN(unfv_dep.C_DepCodPl) > 0 
			WHERE	
			 		p.I_CatPagoID <> 36 
					AND cp.agrupa = 0
			ORDER BY cuota_pago, id_cp

SET IDENTITY_INSERT TI_ConceptoPago OFF
GO

-- Cambiando el Identity de TC_Periodo a la maxima cuota de pago de la base de datos del temporal de pagos.

DECLARE @I_ConcPagID	int
SET @I_ConcPagID = (SELECT MAX(CAST(id_cp as int)) FROM  temporal_pagos..cp_pri) + 1 

DBCC CHECKIDENT(TI_ConceptoPago, RESEED, @I_ConcPagID)

GO


--SET IDENTITY_INSERT TI_ConceptoPago ON

--INSERT INTO TI_ConceptoPago (I_ConcPagID, I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_AlumnosDestino, I_GradoDestino, I_TipoObligacion, 
--							 T_Clasificador, C_CodTasa, B_Calculado, I_Calculado, B_AnioPeriodo, I_Anio, I_Periodo, B_Especialidad, C_CodRc, B_Dependencia, C_DepCod, B_GrupoCodRc, I_GrupoCodRc, 
--							 B_ModalidadIngreso, I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, B_ConceptoAfecta, I_ConceptoAfectaID, N_NroPagos, B_Porcentaje, C_Moneda, M_Monto, 
--							 M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Migrado, B_Habilitado, B_Eliminado, I_TipoDescuentoID) 
--					 SELECT cp.id_cp, cp.cuota_pago, 0, cp.descripcio, cp.fraccionab, cp.concepto_g, cp.agrupa, co_tipoAlumno.I_OpcionID, co_grado.I_OpcionID, co_tipOblg.I_OpcionID,
--							cp.clasificad, cp.clasific_5, CASE WHEN co_calc.I_OpcionID IS NULL THEN 0 ELSE 1 END, co_calc.I_OpcionID, CASE CAST(cp.ano AS int) WHEN 0 THEN 0 ELSE 1 END, 
--							CASE CAST(cp.ano AS int) WHEN 0 THEN NULL ELSE CAST(cp.ano AS int) END, co_periodo.I_OpcionID, CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN 0 ELSE 1 END, 
--							CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN NULL ELSE cp.cod_rc END, CASE LEN(LTRIM(RTRIM(cp.cod_dep_pl))) WHEN 0 THEN 0 ELSE 1 END, unfv_dep.I_DependenciaID, 
--							CASE WHEN co_grpRc.I_OpcionID IS NULL THEN 0 ELSE 1 END, co_grpRc.I_OpcionID, CASE WHEN co_codIng.I_OpcionID IS NULL THEN 0 ELSE 1 END, co_codIng.I_OpcionID, 
--							CASE cp.id_cp_agrp WHEN 0 THEN NULL ELSE 1 END, CASE cp.id_cp_agrp WHEN 0 THEN NULL ELSE cp.id_cp_agrp END, CASE cp.id_cp_afec WHEN 0 THEN NULL ELSE 1 END, 
--							CASE cp.id_cp_afec WHEN 0 THEN NULL ELSE cp.id_cp_afec END, cp.nro_pagos, cp.porcentaje, 'PEN', cp.monto, cp.monto_min, cp.descrip_l, cp.documento, 1, 0, 0, NULL 							

--					 FROM	temporal_pagos.dbo.cp_pri cp
--							LEFT JOIN temporal_pagos.dbo.cp_des cd ON cp.cuota_pago = cd.CUOTA_PAGO AND Cd.eliminado = 0 
--							LEFT JOIN TC_CatalogoOpcion co_tipoAlumno ON CAST(co_tipoAlumno.T_OpcionCod AS float) = cp.tip_alumno AND co_tipoAlumno.I_ParametroID = 1
--							LEFT JOIN TC_CatalogoOpcion co_grado ON CAST(co_grado.T_OpcionCod AS float) = cp.grado AND co_grado.I_ParametroID = 2
--							LEFT JOIN TC_CatalogoOpcion co_tipOblg ON CAST(co_tipOblg.T_OpcionCod AS bit) = cp.tipo_oblig AND co_tipOblg.I_ParametroID = 3
--							LEFT JOIN TC_CatalogoOpcion co_calc ON co_calc.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.calcular COLLATE DATABASE_DEFAULT AND co_calc.I_ParametroID = 4
--							LEFT JOIN TC_CatalogoOpcion co_periodo ON co_periodo.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.p COLLATE DATABASE_DEFAULT AND co_periodo.I_ParametroID = 5
--							LEFT JOIN TC_CatalogoOpcion co_grpRc ON co_grpRc.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.grupo_rc COLLATE DATABASE_DEFAULT AND co_grpRc.I_ParametroID = 6
--							LEFT JOIN TC_CatalogoOpcion co_codIng ON co_codIng.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.cod_ing COLLATE DATABASE_DEFAULT AND co_codIng.I_ParametroID = 7
--							LEFT JOIN TC_DependenciaUNFV unfv_dep on unfv_dep.C_DepCodPl COLLATE DATABASE_DEFAULT = cp.cod_dep_pl COLLATE DATABASE_DEFAULT AND LEN(unfv_dep.C_DepCodPl) > 0 
--					 WHERE cd.cuota_pago IS not NULL
--							AND NOT EXISTS (SELECT id_cp, descripcio, 0, ISNULL(eliminado, 0) FROM temporal_pagos.dbo.cp_pri B WHERE cp.ID_CP IN (3899,3898,3897,3896) AND cp.eliminado = 1)
--					 ORDER BY id_cp

--SET IDENTITY_INSERT TI_ConceptoPago OFF
--GO


--INSERT INTO TC_MatriculaAlumno (C_CodRc, C_CodAlu, I_Anio, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, B_Habilitado, B_Eliminado)
--      SELECT DISTINCT ep.COD_RC, ep.COD_ALU, CAST(ISNULL(ep.ANO, '0') as int), co_periodo.I_OpcionID, 'S', NULL, NULL, 1,0
--	    FROM temporal_pagos.dbo.ec_pri ep  
--			 INNER JOIN TC_CatalogoOpcion co_periodo ON co_periodo.T_OpcionCod COLLATE DATABASE_DEFAULT = ep.P COLLATE DATABASE_DEFAULT AND co_periodo.I_ParametroID = 5
--		WHERE EP.COD_RC IS NOT NULL AND ep.COD_ALU IS NOT NULL

--GO


--INSERT INTO TR_ObligacionAluCab (I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_UsuarioMod, D_FecMod)
--	  SELECT P.I_ProcesoID, I_MatAluID, 'PEN', eo.MONTO, 1, 0, NULL, NULL, NULL, NULL
--		FROM (SELECT * FROM temporal_pagos.dbo.ec_obl WHERE ANO <> 'A') eo 
--			 INNER JOIN TC_Proceso P ON eo.CUOTA_PAGO = P.I_ProcesoID
--			 LEFT JOIN (SELECT M.*, C.T_OpcionCod FROM TC_MatriculaAlumno M 
--						INNER JOIN TC_CatalogoOpcion C ON M.I_Periodo = c.I_OpcionID) AS ma ON eo.COD_ALU COLLATE DATABASE_DEFAULT = ma.C_CodAlu COLLATE DATABASE_DEFAULT 
--																							AND eo.COD_RC COLLATE DATABASE_DEFAULT = ma.C_CodRc COLLATE DATABASE_DEFAULT 
--																							AND CAST(eo.ANO AS INT)  = ma.I_Anio
--																							AND eo.p COLLATE DATABASE_DEFAULT = ma.T_OpcionCod COLLATE DATABASE_DEFAULT 

--GO


--INSERT INTO TR_ObligacionAluDet (I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_UsuarioMod, D_FecMod)
--					SELECT OA.I_ObligacionAluID, CP.I_ConcPagID, CAST(ED.monto AS decimal(15,2)), CASE ED.pagado WHEN 'T' THEN 1 ELSE 0 END, CASE ED.eliminado WHEN 'T' THEN 1 ELSE 0 END, 
--							CASE ED.eliminado WHEN 'T' THEN 1 ELSE 0 END, NULL, NULL, NULL, NULL
--					  FROM temporal_pagos..ec_det ED
--							INNER JOIN (SELECT OAC.I_ObligacionAluID, OAC.I_ProcesoID, M.C_CodAlu, M.C_CodRc, P.I_Anio, C.T_OpcionCod as P, OAC.D_FecVencto
--										FROM TC_Proceso P 
--										INNER JOIN TR_ObligacionAluCab OAC ON OAC.I_ProcesoID = P.I_ProcesoID
--										INNER JOIN TC_MatriculaAlumno M ON OAC.I_MatAluID = M.I_MatAluID
--										INNER JOIN TC_CatalogoOpcion C ON M.I_Periodo = c.I_OpcionID ) OA ON ED.cod_alu COLLATE DATABASE_DEFAULT = OA.C_CodAlu COLLATE DATABASE_DEFAULT
--													AND ED.cod_rc COLLATE DATABASE_DEFAULT = OA.C_CodRc COLLATE DATABASE_DEFAULT
--													AND CAST(ED.cuota_pago AS int) = OA.I_ProcesoID
--													AND CAST(ED.ano AS int) = OA.I_Anio
--													AND ED.p COLLATE DATABASE_DEFAULT = OA.P COLLATE DATABASE_DEFAULT
--													AND ED.fch_venc COLLATE DATABASE_DEFAULT = CONVERT(VARCHAR, OA.D_FecVencto, 101) COLLATE DATABASE_DEFAULT
--							INNER JOIN TI_ConceptoPago CP ON CP.I_ConcPagID = CAST(ED.concepto AS INT)

--GO


--INSERT INTO TR_TasaUnfv (C_CodTasa, I_MontoTasa, I_NroPagos, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_ConcPagID)
--				SELECT  C_CodTasa, M_Monto, N_NroPagos, 1, 0, NULL, NULL, I_ConcPagID
--				  FROM  TI_ConceptoPago
--				 WHERE  LEN(C_CodTasa) <> 0

--GO


--INSERT INTO TRI_PagoProcesadoUnfv (I_TasaUnfvID, I_PagoBancoID, I_ObligacionAluID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado)
--			SELECT  NULL, NULL, I_ObligacionAluID,  CASE pagado WHEN 1 THEN CAST(EO.monto AS decimal(15,2)) ELSE 0 END, CASE pagado WHEN 1 THEN 0 ELSE CAST(EO.monto AS decimal(15,2)) END, NULL, 0, NULL, NULL, 0
--			  FROM  temporal_pagos.dbo.ec_obl EO 
--					INNER JOIN (SELECT OAC.I_ObligacionAluID, OAC.I_ProcesoID, M.C_CodAlu, M.C_CodRc, P.I_Anio, C.T_OpcionCod as P, OAC.D_FecVencto
--								FROM TC_Proceso P 
--								INNER JOIN TR_ObligacionAluCab OAC ON OAC.I_ProcesoID = P.I_ProcesoID
--								INNER JOIN TC_MatriculaAlumno M ON OAC.I_MatAluID = M.I_MatAluID
--								INNER JOIN TC_CatalogoOpcion C ON M.I_Periodo = c.I_OpcionID ) OA ON EO.cod_alu COLLATE DATABASE_DEFAULT = OA.C_CodAlu COLLATE DATABASE_DEFAULT
--											AND EO.cod_rc COLLATE DATABASE_DEFAULT = OA.C_CodRc COLLATE DATABASE_DEFAULT
--											AND CAST(EO.cuota_pago AS int) = OA.I_ProcesoID
--											AND EO.ano = CAST(OA.I_Anio AS varchar)
--											AND EO.p COLLATE DATABASE_DEFAULT = OA.P COLLATE DATABASE_DEFAULT
--											AND CONVERT(VARCHAR, EO.fch_venc, 101) = CONVERT(VARCHAR, OA.D_FecVencto, 101)
--					INNER JOIN TC_Proceso P ON P.I_ProcesoID = CAST(EO.CUOTA_PAGO AS INT)
--				WHERE tipo_oblig = 1

--GO


--INSERT INTO TC_ClasificadorPresupuestal (C_TipoTransCod, C_GenericaCod, C_SubGeneCod, C_EspecificaCod, T_ClasificadorDesc, T_ClasificadorDetalle, B_Eliminado, I_UsuarioCre, D_FecCre)
--								SELECT SUBSTRING(CLASIFICADOR, 1, 1), SUBSTRING(CLASIFICADOR, 3, 1)
--									  , CASE CHARINDEX('.', CLASIFICADOR, 5) WHEN 0 THEN IIF(LEN(SUBSTRING(CLASIFICADOR, 5, 4)) = 0, NULL, REPLACE(SUBSTRING(CLASIFICADOR, 5, 4), ' ','')) ELSE REPLACE(SUBSTRING(CLASIFICADOR, 5, (CHARINDEX('.', CLASIFICADOR, 5) - 5)), ' ','') END
--									  , CASE CHARINDEX('.', CLASIFICADOR, 5) WHEN 0 THEN NULL ELSE REPLACE(SUBSTRING(CLASIFICADOR, CHARINDEX('.', CLASIFICADOR, 5) + 1, 4), ' ','') END
--									  , DESCRIPCION, DESCRIPCION_DETALLADA, 0, 1, GETDATE()
--								  FROM temporal_pagos..Clasificadores

--INSERT INTO TC_ClasificadorAnio (I_ClasificadorID, N_Anio, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
--						SELECT  I_ClasificadorID, '2021', 1, 0, I_UsuarioCre, D_FecCre
--						  FROM  TC_ClasificadorPresupuestal