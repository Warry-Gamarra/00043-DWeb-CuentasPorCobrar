USE [BD_OCEF_CtasPorCobrar]
GO

/*	-----------------------  Autenticacion	-----------------------  */


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_Usuarios')
	DROP TABLE TC_Usuarios
GO

CREATE TABLE TC_Usuarios
( 
	UserId               int IDENTITY ( 1,1 ) ,
	UserName             varchar(20)  NOT NULL ,
	I_UsuarioCrea        int  NULL ,
	D_FecActualiza       datetime  NULL ,
	B_CambiaPassword	 bit  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	CONSTRAINT PK_Usuarios PRIMARY KEY (UserId ASC),
	CONSTRAINT FK_Usuarios_Usuarios_UsuarioCrea FOREIGN KEY (I_UsuarioCrea) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'webpages_Roles')
	DROP TABLE webpages_Roles
GO

CREATE TABLE webpages_Roles
( 
	RoleId               int IDENTITY ( 1,1 ) ,
	RoleName             varchar(50)  NOT NULL ,
	CONSTRAINT PK_Roles PRIMARY KEY (RoleId ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TS_CorreoAplicacion')
	DROP TABLE TS_CorreoAplicacion
GO

CREATE TABLE TS_CorreoAplicacion
( 
	I_CorreoID           tinyint IDENTITY ( 1,1 ) ,
	T_DireccionCorreo    varchar(250)  NULL ,
	T_PasswordCorreo     varchar(500)  NULL ,
	T_Seguridad          varchar(10)  NULL ,
	T_HostName           varchar(50)  NOT NULL ,
	I_Puerto             smallint  NOT NULL ,
	D_FecUpdate          datetime  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	CONSTRAINT PK_CorreoAplicacion PRIMARY KEY (I_CorreoID ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_DatosUsuario')
	DROP TABLE TC_DatosUsuario
GO

CREATE TABLE TC_DatosUsuario
( 
	I_DatosUsuarioID     int IDENTITY ( 1,1 ) ,
	N_NumDoc             varchar(15)  NULL ,
	T_NomPersona         varchar(250)  NULL ,
	T_CorreoUsuario      varchar(100)  NULL ,
	D_FecRegistro        datetime  NULL ,
	D_FecActualiza       datetime  NULL ,
	B_Habilitado         bit  NOT NULL ,
	CONSTRAINT PK_DatosUsuario PRIMARY KEY (I_DatosUsuarioID ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TI_UsuarioDatosUsuario')
	DROP TABLE TI_UsuarioDatosUsuario
GO

CREATE TABLE TI_UsuarioDatosUsuario
( 
	UserId               int NOT NULL ,
	I_DatosUsuarioID     int NOT NULL ,
	D_FecAlta            datetime  NOT NULL ,
	D_FecBaja            datetime  NULL ,
	B_Habilitado         bit  NOT NULL ,
	CONSTRAINT PK_UsuarioDatosUsuario PRIMARY KEY (UserId, I_DatosUsuarioID ASC),
	CONSTRAINT FK_Usuarios_UsuarioDatosUsuario FOREIGN KEY (UserId) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_DatosUsuario_UsuarioDatosUsuario FOREIGN KEY (I_DatosUsuarioID) REFERENCES TC_DatosUsuario(I_DatosUsuarioID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'webpages_Membership')
	DROP TABLE webpages_Membership
GO

CREATE TABLE webpages_Membership
( 
	UserId               int  NOT NULL ,
	CreateDate           datetime  NULL ,
	ConfirmationToken    nvarchar(max)  NULL ,
	IsConfirmed          bit  NULL ,
	LastPasswordFailureDate datetime  NULL ,
	PasswordFailuresSinceLastSuccess int  NULL ,
	Password             nvarchar(max)  NULL ,
	PasswordChangedDate  datetime  NULL ,
	PasswordSalt         varchar(max)  NULL ,
	PasswordVerificationToken nvarchar(max)  NULL ,
	PasswordVerificationTokenExpirationDate datetime  NULL ,
	CONSTRAINT PK_Membership PRIMARY KEY (UserId ASC),
	CONSTRAINT FK_Usuarios_Membership FOREIGN KEY (UserId) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'webpages_UsersInRoles')
	DROP TABLE webpages_UsersInRoles
GO

CREATE TABLE webpages_UsersInRoles
( 
	UserId               int  NOT NULL ,
	RoleId               int  NOT NULL ,
	CONSTRAINT PK_UsersInRoles PRIMARY KEY (UserId ASC,RoleId ASC),
	CONSTRAINT FK_Roles_UserInRoles FOREIGN KEY (RoleId) REFERENCES webpages_Roles(RoleId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_Usuarios_UsersInRoles FOREIGN KEY (UserId) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



/*	-----------------------  Mantenimientos	-----------------------  */


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_TipoDocumento')
	DROP TABLE TC_TipoDocumento
GO

CREATE TABLE TC_TipoDocumento 
(
	C_DocCod		varchar(2)  NOT NULL,
	T_DocDesc		varchar(150)  NOT NULL,
	B_Habilitado		bit  NOT NULL,
	CONSTRAINT PK_TipoDocumento PRIMARY KEY (C_DocCod ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_TipoResolucion')
	DROP TABLE TC_TipoResolucion
GO

CREATE TABLE TC_TipoResolucion
(
	C_ResolucionCod			varchar(2)  NOT NULL,
	T_ResolucionDesc		varchar(150)  NOT NULL,
	B_Habilitado			bit  NOT NULL,
	CONSTRAINT PK_TipoResolucion PRIMARY KEY (C_ResolucionCod ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_EntidadFinanciera')
	DROP TABLE TC_EntidadFinanciera
GO

CREATE TABLE TC_EntidadFinanciera
(
	C_EntidadCod		varchar(2)  NOT NULL,
	T_EntidadDesc		varchar(150)  NOT NULL,
	B_Habilitado		bit  NOT NULL,
	CONSTRAINT PK_EntidadFinanciera PRIMARY KEY (C_EntidadCod ASC)
)
GO




IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_CuentaDeposito')
	DROP TABLE TC_CuentaDeposito
GO

CREATE TABLE TC_CuentaDeposito
(
	I_CtaDepID			int identity(1,1),
	C_NumeroCuenta		varchar(50)	NOT NULL,
	C_EntidadCod		varchar(2)	NOT NULL,
	B_Habilitado		bit,
	CONSTRAINT PK_CuentaDeposito PRIMARY KEY (I_CtaDepID ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_DependenciaUNFV')
	DROP TABLE TC_DependenciaUNFV
GO

CREATE TABLE TC_DependenciaUNFV
(
	C_DepCod			int identity(1,1),
	CONSTRAINT PK_DependenciaUNFV PRIMARY KEY (C_DepCod ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_CuotaPago')
	DROP TABLE TC_CuotaPago
GO

CREATE TABLE TC_CuotaPago
(
	I_CuotaPagoID		int identity(1,1),
	T_CuotaPagoDesc	varchar(250) NOT NULL,
	CONSTRAINT PK_CuotaPago PRIMARY KEY (I_CuotaPagoID ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_Periodo')
	DROP TABLE TC_Periodo
GO

CREATE TABLE TC_Periodo
(
	I_PeriodoID		int identity(1,1),
	I_CuotaPagoID	int NOT NULL,
	N_Anio			int,
	D_FecIni		datetime,
	D_FecFin		datetime,
	B_Habilitado	bit,
	CONSTRAINT PK_Periodo PRIMARY KEY (I_PeriodoID ASC),
	CONSTRAINT FK_Periodo_CuotaPago FOREIGN KEY (I_CuotaPagoID) REFERENCES TC_CuotaPago(I_CuotaPagoID)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TI_Periodo_CuentaDeposito')
	DROP TABLE TI_Periodo_CuentaDeposito
GO

CREATE TABLE TI_Periodo_CuentaDeposito
(
	I_CtaDepID		int  NOT NULL,
	I_PeriodoID		int  NOT NULL,
	C_DepCod		int  NOT NULL,
	CONSTRAINT PK_Periodo_CuentaDeposito PRIMARY KEY (I_CtaDepID ASC, I_PeriodoID ASC, C_DepCod ASC),
	CONSTRAINT FK_Periodo_CuentaDeposito FOREIGN KEY (I_CtaDepID) REFERENCES TC_CuentaDeposito(I_CtaDepID),
	CONSTRAINT FK_Periodo_CuentaDeposito_Periodo FOREIGN KEY (I_PeriodoID) REFERENCES TC_Periodo(I_PeriodoID),
	CONSTRAINT FK_Periodo_CuentaDeposito_DependenciaUNFV FOREIGN KEY (C_DepCod) REFERENCES TC_DependenciaUNFV(C_DepCod)	
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TC_ConceptoPago')
	DROP TABLE TC_ConceptoPago
GO

CREATE TABLE TC_ConceptoPago
(
	I_ConceptoID	int identity(1,1),
	T_ConceptoDesc	varchar(250),
	B_Habilitado	bit,
	CONSTRAINT PK_ConceptoPago PRIMARY KEY (I_ConceptoID ASC)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TI_ConceptoPago_Periodo')
	DROP TABLE TI_ConceptoPago_Periodo
GO

CREATE TABLE TI_ConceptoPago_Periodo
(
	I_ConcPagPerID			int identity(1,1),
	I_ConceptoID			int not null,
	B_Fraccionable			bit,
	B_ConceptoGeneral		bit,
	B_AgrupaConcepto		bit,
	I_AlumnosDestino		int,
	I_GradoDestino			int,
	I_TipoObligacion		int,
	I_PeriodoID				int,
	T_Clasificador			varchar(250),
	T_Clasificador5			varchar(250),
	B_Calculado				bit,
	I_Calculado				int,
	B_AnioPeriodo			bit,
	I_Anio					int,--OBS
	I_Periodo				int,--OBS
	B_Especialidad			bit,
	C_CodRc					CHAR(3),
	B_Dependencia			bit,
	C_DepCod				int,--OBS
	B_GrupoCodRc			bit,
	I_GrupoCodRc			int,
	B_ModalidadIngreso		bit,
	I_ModalidadIngresoID	int,
	B_ConceptoAgrupa		bit,
	I_ConceptoAgrupaID		int,
	B_ConceptoAfecta		int,
	I_ConceptoAfectaID		int,
	N_NroPagos				int,
	B_Porcentaje			bit,
	M_Monto					decimal(10,4),
	M_MontoMinimo			decimal(10,4),
	T_DescripcionLarga		varchar(250),
	T_Documento				varchar(250),
	B_Habilitado			bit,
	CONSTRAINT PK_ConceptoPago_Periodo PRIMARY KEY (I_ConcPagPerID ASC),
	CONSTRAINT FK_ConceptoPago_Periodo FOREIGN KEY (I_ConceptoID) REFERENCES TC_ConceptoPago(I_ConceptoID)
)
GO

