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





