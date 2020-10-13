USE [BD_OCEF_CtasPorCobrar]
GO


/*	-----------------------  Autenticacion	-----------------------  */

CREATE TABLE webpages_Roles
( 
	RoleId               int IDENTITY ( 1,1 ) ,
	RoleName             varchar(50)  NOT NULL ,
	CONSTRAINT PK_Roles PRIMARY KEY  NONCLUSTERED (RoleId ASC)
)
go



CREATE TABLE TC_Usuarios
( 
	UserId               int IDENTITY ( 1,1 ) ,
	UserName             varchar(20)  NOT NULL ,
	I_UsuarioCrea        int  NULL ,
	D_FecActualiza       datetime  NULL ,
	B_CambiaPassword     bit  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Usuarios PRIMARY KEY  NONCLUSTERED (UserId ASC),
	CONSTRAINT FK_Usuarios_Usuarios_UsuarioCrea FOREIGN KEY (I_UsuarioCrea) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE webpages_UsersInRoles
( 
	UserId               int  NOT NULL ,
	RoleId               int  NOT NULL ,
	CONSTRAINT PK_UsersInRoles PRIMARY KEY  NONCLUSTERED (UserId ASC,RoleId ASC),
	CONSTRAINT FK_Roles_UserInRoles FOREIGN KEY (RoleId) REFERENCES webpages_Roles(RoleId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_Usuarios_UsersInRoles FOREIGN KEY (UserId) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



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
	CONSTRAINT PK_Membership PRIMARY KEY  NONCLUSTERED (UserId ASC),
	CONSTRAINT FK_Usuarios_Membership FOREIGN KEY (UserId) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_DatosUsuario
( 
	I_DatosUsuarioID     int IDENTITY ( 1,1 ) ,
	N_NumDoc             varchar(15)  NULL ,
	T_NomPersona         varchar(250)  NULL ,
	T_CorreoUsuario      varchar(100)  NULL ,
	D_FecRegistro        datetime  NULL ,
	D_FecActualiza       datetime  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_DatosUsuario PRIMARY KEY  NONCLUSTERED (I_DatosUsuarioID ASC)
)
go



CREATE TABLE TI_UsuarioDatosUsuario
( 
	UserId               int  NOT NULL ,
	I_DatosUsuarioID     int  NOT NULL ,
	D_FecAlta            datetime  NOT NULL ,
	D_FecBaja            datetime  NULL ,
	B_Habilitado         bit  NOT NULL ,
	CONSTRAINT PK_UsuarioDatosUsuario PRIMARY KEY  NONCLUSTERED (UserId ASC,I_DatosUsuarioID ASC),
	CONSTRAINT FK_Usuarios_UsuarioDatosUsuario FOREIGN KEY (UserId) REFERENCES TC_Usuarios(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_DatosUsuario_UsuarioDatosUsuario FOREIGN KEY (I_DatosUsuarioID) REFERENCES TC_DatosUsuario(I_DatosUsuarioID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TS_CorreoAplicacion
( 
	I_CorreoID           tinyint IDENTITY ( 1,1 ) ,
	T_DireccionCorreo    varchar(250)  NULL ,
	T_PasswordCorreo     varchar(500)  NULL ,
	T_Seguridad          varchar(10)  NULL ,
	T_HostName           varchar(50)  NOT NULL ,
	I_Puerto             smallint  NOT NULL ,
	D_FecUpdate          datetime  NOT NULL ,
	I_ProgramaID         tinyint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CorreoAplicacion PRIMARY KEY  NONCLUSTERED (I_CorreoID ASC)
)
go


/*	-----------------------  Mantenimientos	-----------------------  */


CREATE TABLE TC_TipoDocumento 
(
	C_DocCod		varchar(2)  NOT NULL,
	T_DocDesc		varchar(150)  NOT NULL,
	B_Habilitado		bit  NOT NULL,
	CONSTRAINT PK_TipoDocumento PRIMARY KEY (C_DocCod ASC)
)
GO


CREATE TABLE TC_TipoResolucion
(
	C_ResolucionCod			varchar(2)  NOT NULL,
	T_ResolucionDesc		varchar(150)  NOT NULL,
	B_Habilitado			bit  NOT NULL,
	CONSTRAINT PK_TipoResolucion PRIMARY KEY (C_ResolucionCod ASC)
)
GO


CREATE TABLE TC_TipoPeriodo
( 
	I_TipoPeriodoID      int IDENTITY ( 1,1 ) ,
	T_TipoPerDesc        varchar(250)  NOT NULL ,
	I_Prioridad          tinyint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_TipoPeriodo PRIMARY KEY  CLUSTERED (I_TipoPeriodoID ASC)
)
GO


CREATE TABLE TC_Periodo
( 
	I_PeriodoID          int IDENTITY ( 1,1 ) ,
	I_TipoPeriodoID      int  NOT NULL ,
	I_Anio               smallint  NOT NULL ,
	D_FecVencto          date  NULL ,
	I_Prioridad          tinyint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Periodo PRIMARY KEY  CLUSTERED (I_PeriodoID ASC),
	CONSTRAINT FK_TipoPeriodo_Periodo FOREIGN KEY (I_TipoPeriodoID) REFERENCES TC_TipoPeriodo(I_TipoPeriodoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TC_DependenciaUNFV
( 
	I_DependenciaID      int IDENTITY ( 1,1 ) ,
	T_DependDesc         varchar(250)  NULL ,
	I_DepAgrupaID        int  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_DependenciaUNFV PRIMARY KEY  CLUSTERED (I_DependenciaID ASC)
)
GO



CREATE TABLE TC_EntidadFinanciera
( 
	I_EntidadFinanID     int IDENTITY ( 1,1 ) ,
	T_EntidadDesc        varchar(150)  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_EntidadFinanciera PRIMARY KEY  NONCLUSTERED (I_EntidadFinanID ASC)
)
GO



CREATE TABLE TC_CuentaDeposito
( 
	I_CtaDepositoID      int IDENTITY ( 1,1 ) ,
	I_EntidadFinanID     int  NULL ,
	C_NumeroCuenta       varchar(50)  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CuentaDeposito PRIMARY KEY  CLUSTERED (I_CtaDepositoID ASC),
	CONSTRAINT FK_EntiidadFinanciera_CuentaDeposito FOREIGN KEY (I_EntidadFinanID) REFERENCES TC_EntidadFinanciera(I_EntidadFinanID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TI_Dependencia_CtaDepo_Periodo
( 
	I_DepCtaDepoPerID    int IDENTITY ( 1,1 ) ,
	I_CtaDepositoID      int  NOT NULL ,
	I_PeriodoID          int  NULL ,
	I_DependenciaID      int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT XPKTI_Dependencia_CtaDepo_Periodo PRIMARY KEY  CLUSTERED (I_DepCtaDepoPerID ASC),
	CONSTRAINT FK_Periodo_DependenciaCtaPagoPeriodo FOREIGN KEY (I_PeriodoID) REFERENCES TC_Periodo(I_PeriodoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_DependenciaUNFV_DependenciaCtaDepoPeriodo FOREIGN KEY (I_DependenciaID) REFERENCES TC_DependenciaUNFV(I_DependenciaID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_CuentaDeposito_DependenciaCtaDepoPeriodo FOREIGN KEY (I_CtaDepositoID) REFERENCES TC_CuentaDeposito(I_CtaDepositoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TC_TipoArchivo
( 
	I_TipoArchivoID      int IDENTITY ( 1,1 ) ,
	T_TipoArchivDesc     varchar(150)  NOT NULL ,
	B_ArchivoEntrada     bit  NULL ,
	B_ArchivoSalida      bit  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_TipoArchivo PRIMARY KEY  CLUSTERED (I_TipoArchivoID ASC)
)
GO



CREATE TABLE TI_TipoArchivo_EntidadFinanciera
( 
	I_TipArchivoEntFinanID int IDENTITY ( 1,1 ) ,
	I_EntidadFinanID     int  NULL ,
	I_TipoArchivoID      int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT XPKTI_TipoArchivo_EntidadFinanciera PRIMARY KEY  CLUSTERED (I_TipArchivoEntFinanID ASC),
	CONSTRAINT FK_EntidadFinanciera_TipoArchivoEntidadFinanciera FOREIGN KEY (I_EntidadFinanID) REFERENCES TC_EntidadFinanciera(I_EntidadFinanID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_TipoArchivo_TipoArchivoEntidadFinanciera FOREIGN KEY (I_TipoArchivoID) REFERENCES TC_TipoArchivo(I_TipoArchivoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TC_EstructFilasArchivo
( 
	I_EstructFilaID      int IDENTITY ( 1,1 ) ,
	T_EstructFilDesc     varchar(50)  NOT NULL ,
	I_FilaInicio         smallint  NOT NULL ,
	I_FilaFin            smallint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	I_TipArchivoEntFinanID int  NULL ,
	CONSTRAINT PK_EstructFilasArchivo PRIMARY KEY  CLUSTERED (I_EstructFilaID ASC),
	CONSTRAINT FK_TipoArchivoEntidadFinanciera_EstructFilasArchivo FOREIGN KEY (I_TipArchivoEntFinanID) REFERENCES TI_TipoArchivo_EntidadFinanciera(I_TipArchivoEntFinanID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TC_EstructColumnasArchivo
( 
	I_EstructColumnaID   int IDENTITY ( 1,1 ) ,
	T_EstructColDesc     varchar(50)  NOT NULL ,
	I_ColumnaInicio      char(18)  NULL ,
	I_ColumnaFin         char(18)  NULL ,
	I_EstructFilaID      int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_EstructColumnasArchivo PRIMARY KEY  CLUSTERED (I_EstructColumnaID ASC),
	CONSTRAINT FK_EstructFilasArchivo_EstructColumnasArchivo FOREIGN KEY (I_EstructFilaID) REFERENCES TC_EstructFilasArchivo(I_EstructFilaID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TC_CuentaDeposito_TipoPeriodo
( 
	I_TipPerCtaDepoID    int IDENTITY ( 1,1 ) ,
	I_CtaDepositoID      int  NOT NULL ,
	I_TipoPeriodoID      int  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CuentaDeposito_TipoPeriodo PRIMARY KEY  CLUSTERED (I_TipPerCtaDepoID ASC),
	CONSTRAINT FK_CuentaDeposito_CuentaDepositoTipoPeriodo FOREIGN KEY (I_CtaDepositoID) REFERENCES TC_CuentaDeposito(I_CtaDepositoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_TipoPeriodo_CuentaDepositoTipoPeriodo FOREIGN KEY (I_TipoPeriodoID) REFERENCES TC_TipoPeriodo(I_TipoPeriodoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO



CREATE TABLE TC_ConceptoPago
( 
	I_ConceptoID         int IDENTITY ( 1,1 ) ,
	T_ConceptoDesc       varchar(250)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ConceptoPago PRIMARY KEY  CLUSTERED (I_ConceptoID ASC)
)
GO



CREATE TABLE TI_ConceptoPago_Periodo
( 
	I_ConcPagPerID       int IDENTITY ( 1,1 ) ,
	I_PeriodoID          int  NOT NULL ,
	I_ConceptoID         int  NOT NULL ,
	B_Fraccionable       bit  NULL ,
	B_ConceptoGeneral    bit  NULL ,
	B_AgrupaConcepto     bit  NULL ,
	I_AlumnosDestino     int  NULL ,
	I_GradoDestino       int  NULL ,
	I_TipoObligacion     int  NULL ,
	T_Clasificador       varchar(250)  NULL ,
	T_Clasificador5      varchar(250)  NULL ,
	B_Calculado          bit  NULL ,
	I_Calculado          int  NULL ,
	B_AnioPeriodo        bit  NULL ,
	I_Anio               int  NULL ,
	I_Periodo            int  NULL ,
	B_Especialidad       bit  NULL ,
	C_CodRc              char(3)  NULL ,
	B_Dependencia        bit  NULL ,
	C_DepCod             int  NULL ,
	B_GrupoCodRc         bit  NULL ,
	I_GrupoCodRc         int  NULL ,
	B_ModalidadIngreso   bit  NULL ,
	I_ModalidadIngresoID int  NULL ,
	B_ConceptoAgrupa     bit  NULL ,
	I_ConceptoAgrupaID   int  NULL ,
	B_ConceptoAfecta     bit  NULL ,
	I_ConceptoAfectaID   int  NULL ,
	N_NroPagos           int  NULL ,
	B_Porcentaje         bit  NULL ,
	M_Monto              decimal(10,4)  NULL ,
	M_MontoMinimo        decimal(10,4)  NULL ,
	T_DescripcionLarga   varchar(250)  NULL ,
	T_Documento          varchar(250)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ConceptoPago_Periodo PRIMARY KEY  CLUSTERED (I_ConcPagPerID ASC),
	CONSTRAINT FK_ConceptoPago_Periodo FOREIGN KEY (I_ConceptoID) REFERENCES TC_ConceptoPago(I_ConceptoID),
CONSTRAINT FK_Periodo_ConceptoPagoPeriodo FOREIGN KEY (I_PeriodoID) REFERENCES TC_Periodo(I_PeriodoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO
