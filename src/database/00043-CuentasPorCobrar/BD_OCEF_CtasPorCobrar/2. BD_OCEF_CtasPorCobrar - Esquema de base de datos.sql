USE [BD_OCEF_CtasPorCobrar]
GO


/*	-----------------------  Mantenimientos	-----------------------  */


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



CREATE TABLE TC_DependenciaUNFV
( 
	I_DependenciaID      int IDENTITY ( 1,1 ) ,
	T_DepDesc            varchar(150)  NULL ,
	C_DepCod             varchar(20)  NOT NULL ,
	C_DepCodPl           varchar(20)  NULL ,
	T_DepAbrev           varchar(10)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_DependenciaUNFV PRIMARY KEY  CLUSTERED (I_DependenciaID ASC)
)
go



CREATE TABLE TC_Parametro
( 
	I_ParametroID        int IDENTITY ( 1,1 ) ,
	T_ParametroDesc      varchar(250)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Parametro PRIMARY KEY  CLUSTERED (I_ParametroID ASC)
)
go



CREATE TABLE TC_CatalogoOpcion
( 
	I_OpcionID           int IDENTITY ( 1,1 ) ,
	I_ParametroID        int  NOT NULL ,
	T_OpcionCod          varchar(50)  NULL ,
	T_OpcionDesc         varchar(250)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CatalogoOpcion PRIMARY KEY  CLUSTERED (I_OpcionID ASC),
	CONSTRAINT FK_Parametro_CatalogoOpcion FOREIGN KEY (I_ParametroID) REFERENCES TC_Parametro(I_ParametroID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



/*	-----------------------  Autenticacion	-----------------------  */


CREATE TABLE TC_Usuario
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
	I_DependenciaID      int  NULL ,
	CONSTRAINT PK_Usuario PRIMARY KEY  NONCLUSTERED (UserId ASC),
	CONSTRAINT FK_Usuario_Usuario_UsuarioCrea FOREIGN KEY (I_UsuarioCrea) REFERENCES TC_Usuario(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_DependenciaUNFV_Usuario FOREIGN KEY (I_DependenciaID) REFERENCES TC_DependenciaUNFV(I_DependenciaID)
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
CONSTRAINT FK_Usuario_UsersInRoles FOREIGN KEY (UserId) REFERENCES TC_Usuario(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE webpages_Roles
( 
	RoleId               int IDENTITY ( 1,1 ) ,
	RoleName             varchar(50)  NOT NULL ,
	CONSTRAINT PK_Roles PRIMARY KEY  NONCLUSTERED (RoleId ASC)
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
	CONSTRAINT FK_Usuario_Membership FOREIGN KEY (UserId) REFERENCES TC_Usuario(UserId)
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
	CONSTRAINT FK_Usuario_UsuarioDatosUsuario FOREIGN KEY (UserId) REFERENCES TC_Usuario(UserId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_DatosUsuario_UsuarioDatosUsuario FOREIGN KEY (I_DatosUsuarioID) REFERENCES TC_DatosUsuario(I_DatosUsuarioID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



/*	-----------------------  Documentacion	-----------------------  */



CREATE TABLE TS_RutaDocumentacion
( 
	I_RutaDocID          int IDENTITY ( 1,1 ) ,
	T_DocDesc            varchar(200)  NULL ,
	T_RutaDocumento      nvarchar(4000)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_RutaDocumentacion PRIMARY KEY  CLUSTERED (I_RutaDocID ASC)
)
go



CREATE TABLE TS_DocumentosRoles
( 
	I_RutaDocID          int  NOT NULL ,
	RoleId               int  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_DocumentosRoles PRIMARY KEY  CLUSTERED (I_RutaDocID ASC,RoleId ASC),
	CONSTRAINT FK_Roles_DocumentosRoles FOREIGN KEY (RoleId) REFERENCES webpages_Roles(RoleId)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_RutaDocumentacion_DocumentosRoles FOREIGN KEY (I_RutaDocID) REFERENCES TS_RutaDocumentacion(I_RutaDocID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go





/*	-----------------------  Obligaciones y pagos	-----------------------  */



CREATE TABLE TR_PagoBanco
( 
	I_PagoBancoID        int IDENTITY ( 1,1 ) ,
	C_CodOperacion       varchar(50)  NULL ,
	C_CodDepositante     varchar(20)  NULL ,
	T_NomDepositante     varchar(200)  NULL ,
	C_Referencia         varchar(50)  NULL ,
	D_FecPago            datetime  NULL ,
	I_Cantidad           int  NULL ,
	C_Moneda             varchar(3)  NULL ,
	I_MontoPago          decimal(15,2)  NULL ,
	T_LugarPago          varchar(250)  NULL ,
	B_Anulado            bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	CONSTRAINT PK_PagoBanco PRIMARY KEY  CLUSTERED (I_PagoBancoID ASC)
)
go



CREATE TABLE TC_CategoriaPago
( 
	I_CatPagoID          int IDENTITY ( 1,1 ) ,
	T_CatPagoDesc        varchar(250)  NOT NULL ,
	I_Prioridad          tinyint  NULL ,
	B_Obligacion         bit  NULL ,
	I_Nivel              int  NULL ,
	I_TipoAlumno         int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CategoriaPago PRIMARY KEY  CLUSTERED (I_CatPagoID ASC)
)
go



CREATE TABLE TC_Proceso
( 
	I_ProcesoID          int IDENTITY ( 1,1 ) ,
	I_CatPagoID          int  NULL ,
	T_ProcesoDesc        varchar(250)  NULL ,
	I_Anio               smallint  NOT NULL ,
	I_Periodo            int  NULL ,
	N_CodBanco           varchar(10)  NULL ,
	D_FecVencto          date  NULL ,
	I_Prioridad          tinyint  NULL ,
	B_Mora               bit  NULL ,
	B_Migrado            bit  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Proceso PRIMARY KEY  CLUSTERED (I_ProcesoID ASC),
	CONSTRAINT FK_CategoriaPago_Periodo FOREIGN KEY (I_CatPagoID) REFERENCES TC_CategoriaPago(I_CatPagoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_MatriculaAlumno
( 
	I_MatAluID           int IDENTITY ( 1,1 ) ,
	C_CodRc              varchar(3)  NOT NULL ,
	C_CodAlu             varchar(20)  NOT NULL ,
	I_Anio               int  NOT NULL ,
	I_Periodo            int  NOT NULL ,
	C_EstMat             varchar(2)  NOT NULL ,
	C_Ciclo              varchar(2)  NULL ,
	B_Ingresante         bit  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_MatriculaAlumno PRIMARY KEY  CLUSTERED (I_MatAluID ASC)
)
go



CREATE TABLE TR_ObligacionAluCab
( 
	I_ObligacionAluID    int IDENTITY ( 1,1 ) ,
	I_ProcesoID          int  NULL ,
	I_MatAluID           int  NULL ,
	C_Moneda             varchar(3)  NULL ,
	I_MontoOblig         decimal(15,2)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ObligacionAluCab PRIMARY KEY  CLUSTERED (I_ObligacionAluID ASC),
	CONSTRAINT FK_Proceso_ObligacionAluCab FOREIGN KEY (I_ProcesoID) REFERENCES TC_Proceso(I_ProcesoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_MatriculaAlumno_ObligacionAluCab FOREIGN KEY (I_MatAluID) REFERENCES TC_MatriculaAlumno(I_MatAluID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_Concepto
( 
	I_ConceptoID         int IDENTITY ( 1,1 ) ,
	T_ConceptoDesc       varchar(250)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Concepto PRIMARY KEY  CLUSTERED (I_ConceptoID ASC)
)
go



CREATE TABLE TC_TipoDescuento
( 
	I_TipoDescuentoID    int IDENTITY ( 1,1 ) ,
	T_TipDescuentoDesc   varchar(50)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_TipoDescuento PRIMARY KEY  CLUSTERED (I_TipoDescuentoID ASC)
)
go



CREATE TABLE TI_ConceptoPago
( 
	I_ConcPagID          int IDENTITY ( 1,1 ) ,
	I_ProcesoID          int  NOT NULL ,
	I_ConceptoID         int  NOT NULL ,
	T_ConceptoPagoDesc   varchar(250)  NULL ,
	B_Fraccionable       bit  NULL ,
	B_ConceptoGeneral    bit  NULL ,
	B_AgrupaConcepto     bit  NULL ,
	I_AlumnosDestino     int  NULL ,
	I_GradoDestino       int  NULL ,
	I_TipoObligacion     int  NULL ,
	T_Clasificador       varchar(250)  NULL ,
	C_CodTasa            varchar(20)  NULL ,
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
	N_NroPagos           tinyint  NULL ,
	B_Porcentaje         bit  NULL ,
	C_Moneda             char(18)  NULL ,
	M_Monto              decimal(15,2)  NULL ,
	M_MontoMinimo        decimal(10,4)  NULL ,
	T_DescripcionLarga   varchar(250)  NULL ,
	T_Documento          varchar(250)  NULL ,
	B_Migrado            bit  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	I_TipoDescuentoID    int  NULL ,
	CONSTRAINT PK_ConceptoPago PRIMARY KEY  CLUSTERED (I_ConcPagID ASC),
	CONSTRAINT FK_Concepto_ConceptoPago FOREIGN KEY (I_ConceptoID) REFERENCES TC_Concepto(I_ConceptoID),
CONSTRAINT FK_Periodo_ConceptoPagoPeriodo FOREIGN KEY (I_ProcesoID) REFERENCES TC_Proceso(I_ProcesoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_TipoDescuento_ConceptoPago FOREIGN KEY (I_TipoDescuentoID) REFERENCES TC_TipoDescuento(I_TipoDescuentoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TR_TasaUnfv
( 
	I_TasaUnfvID         int IDENTITY ( 1,1 ) ,
	C_CodTasa            varchar(20)  NULL ,
	I_MontoTasa          decimal(15,2)  NULL ,
	I_NroPagos           tinyint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_ConcPagID          int  NOT NULL ,
	CONSTRAINT PK_TasaUnfv PRIMARY KEY  CLUSTERED (I_TasaUnfvID ASC),
	CONSTRAINT FK_ConceptoPago_TasaUnfv FOREIGN KEY (I_ConcPagID) REFERENCES TI_ConceptoPago(I_ConcPagID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TRI_PagoProcesadoUnfv
( 
	I_PagoProcesID       int IDENTITY ( 1,1 ) ,
	I_TasaUnfvID         int  NULL ,
	I_PagoBancoID        int  NOT NULL ,
	I_ObligacionAluID    int  NOT NULL ,
	I_MontoPagado        decimal(15,2)  NULL ,
	I_SaldoAPagar        decimal(15,2)  NULL ,
	I_PagoDemas          decimal(15,2)  NULL ,
	B_PagoDemas          bit  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioCre         int  NULL ,
	B_Anulado            bit  NOT NULL ,
	CONSTRAINT PK_PagoProcesadoUnfv PRIMARY KEY  CLUSTERED (I_PagoProcesID ASC),
	CONSTRAINT FK_PagoBanco_PagoProcesadoUnfv FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco(I_PagoBancoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_ObligacionAluCab_PagoProcesadoUnfv FOREIGN KEY (I_ObligacionAluID) REFERENCES TR_ObligacionAluCab(I_ObligacionAluID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_TasaUnfv_PagoProcesadoUnfv FOREIGN KEY (I_TasaUnfvID) REFERENCES TR_TasaUnfv(I_TasaUnfvID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TR_ObligacionAluDet
( 
	I_ObligacionAluID    int  NOT NULL ,
	I_ConcPagID          int  NOT NULL ,
	I_Monto              decimal(15,2)  NULL ,
	B_Pagado             bit  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ObligacionAluDet PRIMARY KEY  CLUSTERED (I_ObligacionAluID ASC,I_ConcPagID ASC),
	CONSTRAINT FK_ConceptoPago_ObligacionAluDet FOREIGN KEY (I_ConcPagID) REFERENCES TI_ConceptoPago(I_ConcPagID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_ObligacionAluCab_ObligacionAluDet FOREIGN KEY (I_ObligacionAluID) REFERENCES TR_ObligacionAluCab(I_ObligacionAluID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_ClasificadorIngreso
( 
	I_ClasificadorID     int IDENTITY ( 1,1 ) ,
	T_ClasificadorDesc   varchar(250)  NOT NULL ,
	T_ClasificadorCod    varchar(50)  NULL ,
	T_ClasificadorUnfv   varchar(50)  NULL ,
	N_Anio				 varchar(4)  NULL,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ClasificadorIngreso PRIMARY KEY  CLUSTERED (I_ClasificadorID ASC)
)
go



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
go



CREATE TABLE TC_CuentaDeposito
( 
	I_CtaDepositoID      int IDENTITY ( 1,1 ) ,
	I_EntidadFinanID     int  NULL ,
	C_NumeroCuenta       varchar(50)  NOT NULL ,
	T_Observacion        varchar(500)  NULL ,
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
go



CREATE TABLE TI_CtaDepo_Proceso
( 
	I_CtaDepoProID       int IDENTITY ( 1,1 ) ,
	I_CtaDepositoID      int  NOT NULL ,
	I_ProcesoID          int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CtaDepo_Proceso PRIMARY KEY  CLUSTERED (I_CtaDepoProID ASC),
	CONSTRAINT FK_Proceso_CuentaDepoProceso FOREIGN KEY (I_ProcesoID) REFERENCES TC_Proceso(I_ProcesoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_CuentaDeposito_CtaDepoProceso FOREIGN KEY (I_CtaDepositoID) REFERENCES TC_CuentaDeposito(I_CtaDepositoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



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
go



CREATE TABLE TI_TipoArchivo_EntidadFinanciera
( 
	I_TipArchivoEntFinanID int IDENTITY ( 1,1 ) ,
	I_EntidadFinanID     int  NULL ,
	I_TipoArchivoID      int  NULL ,
	T_NombreVista        varchar(100)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_TipoArchivo_EntidadFinanciera PRIMARY KEY  CLUSTERED (I_TipArchivoEntFinanID ASC),
	CONSTRAINT FK_EntidadFinanciera_TipoArchivoEntidadFinanciera FOREIGN KEY (I_EntidadFinanID) REFERENCES TC_EntidadFinanciera(I_EntidadFinanID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_TipoArchivo_TipoArchivoEntidadFinanciera FOREIGN KEY (I_TipoArchivoID) REFERENCES TC_TipoArchivo(I_TipoArchivoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_SeccionArchivo
( 
	I_SecArchivoID       int IDENTITY ( 1,1 ) ,
	T_SecArchivoDesc     varchar(50)  NOT NULL ,
	I_FilaInicio         smallint  NOT NULL ,
	I_FilaFin            smallint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	I_TipArchivoEntFinanID int  NULL ,
	CONSTRAINT PK_SeccionArchivo PRIMARY KEY  CLUSTERED (I_SecArchivoID ASC),
	CONSTRAINT FK_TipoArchivoEntidadFinanciera_SeccionArchivo FOREIGN KEY (I_TipArchivoEntFinanID) REFERENCES TI_TipoArchivo_EntidadFinanciera(I_TipArchivoEntFinanID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_ColumnaSeccion
( 
	I_ColSecID           int IDENTITY ( 1,1 ) ,
	T_ColSecDesc         varchar(50)  NOT NULL ,
	I_ColumnaInicio      smallint  NULL ,
	I_ColumnaFin         smallint  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	I_SecArchivoID       int  NULL ,
	CONSTRAINT PK_ColumnaSeccion PRIMARY KEY  CLUSTERED (I_ColSecID ASC),
	CONSTRAINT FK_SeccionArchivo_ColumnasSeccion FOREIGN KEY (I_SecArchivoID) REFERENCES TC_SeccionArchivo(I_SecArchivoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_CuentaDeposito_CategoriaPago
( 
	I_TipPerCtaDepoID    int IDENTITY ( 1,1 ) ,
	I_CatPagoID          int  NULL ,
	I_CtaDepositoID      int  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CuentaDeposito_CategoriaPago PRIMARY KEY  CLUSTERED (I_TipPerCtaDepoID ASC),
	CONSTRAINT FK_CuentaDeposito_CuentaDepositoCategoriaPago FOREIGN KEY (I_CtaDepositoID) REFERENCES TC_CuentaDeposito(I_CtaDepositoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
CONSTRAINT FK_CategoriaPago_CuentaDepositoCategoriaPago FOREIGN KEY (I_CatPagoID) REFERENCES TC_CategoriaPago(I_CatPagoID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go






