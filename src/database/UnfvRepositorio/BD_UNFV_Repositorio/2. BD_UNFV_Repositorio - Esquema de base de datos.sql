USE BD_UNFV_Repositorio
go

CREATE TABLE TC_DependenciaUnfv
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
	CONSTRAINT PK_DependenciaUnfv PRIMARY KEY  CLUSTERED (I_DependenciaID ASC)
)
go



CREATE TABLE TC_Facultad
( 
	C_CodFac             varchar(2)  NOT NULL ,
	T_FacDesc            varchar(80)  NULL ,
	T_FacAbrev           varchar(10)  NULL ,
	I_DependenciaID      int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Facultad PRIMARY KEY  CLUSTERED (C_CodFac ASC),
	CONSTRAINT FK_DependenciaUnfv_Facultad FOREIGN KEY (I_DependenciaID) REFERENCES TC_DependenciaUnfv(I_DependenciaID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_Escuela
( 
	C_CodEsc             varchar(2)  NOT NULL ,
	C_CodFac             varchar(2)  NOT NULL ,
	T_EscDesc            varchar(80)  NOT NULL ,
	T_EscAbrev           varchar(10)  NULL ,
	C_Tipo               varchar(1)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Escuela PRIMARY KEY  CLUSTERED (C_CodEsc ASC,C_CodFac ASC),
	CONSTRAINT FK_Facultad_Escuela FOREIGN KEY (C_CodFac) REFERENCES TC_Facultad(C_CodFac)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_Especialidad
( 
	C_CodEsp             varchar(2)  NOT NULL ,
	C_CodEsc             varchar(2)  NOT NULL ,
	C_CodFac             varchar(2)  NOT NULL ,
	T_EspDesc            varchar(150)  NOT NULL ,
	T_EspAbrev           varchar(10)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Especialidad PRIMARY KEY  CLUSTERED (C_CodEsp ASC,C_CodEsc ASC,C_CodFac ASC),
	CONSTRAINT FK_Escuela_Especialidad FOREIGN KEY (C_CodEsc,C_CodFac) REFERENCES TC_Escuela(C_CodEsc,C_CodFac)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TI_CarreraProfesional
( 
	C_RcCod              varchar(3)  NOT NULL ,
	C_CodEsp             varchar(2)  NULL ,
	C_CodEsc             varchar(2)  NOT NULL ,
	C_CodFac             varchar(2)  NOT NULL ,
	C_Tipo               char(1)  NULL ,
	I_Duracion           integer  NULL ,
	B_Anual              bit  NULL ,
	N_Grupo              char(1)  NULL ,
	N_Grado              char(1)  NULL ,
	I_IdAplica           int  NULL ,
	B_Habilitado         integer  NOT NULL ,
	B_Eliminado          integer  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_CarreraProfesional PRIMARY KEY  CLUSTERED (C_RcCod ASC),
	CONSTRAINT FK_Especialidad_CarreraProfesional FOREIGN KEY (C_CodEsp,C_CodEsc,C_CodFac) REFERENCES TC_Especialidad(C_CodEsp,C_CodEsc,C_CodFac)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_Escuela_CarreraProfesional FOREIGN KEY (C_CodEsc,C_CodFac) REFERENCES TC_Escuela(C_CodEsc,C_CodFac)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_GradoAcademico
( 
	C_CodGrado           varchar(5)  NOT NULL ,
	T_GradoDesc          varchar(150)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_GradoAcademico PRIMARY KEY  CLUSTERED (C_CodGrado ASC)
)
go



CREATE TABLE TC_ModalidadEstudio
( 
	C_CodModEst          varchar(5)  NOT NULL ,
	T_ModEstDesc         varchar(150)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ModalidadEstudio PRIMARY KEY  CLUSTERED (C_CodModEst ASC)
)
go



CREATE TABLE TC_RegimenEstudio
( 
	C_CodRegimenEst      varchar(5)  NOT NULL ,
	T_RegimenEstDesc     varchar(150)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_RegimenEstudio PRIMARY KEY  CLUSTERED (C_CodRegimenEst ASC)
)
go



CREATE TABLE TC_ProgramaUnfv
( 
	C_CodProg            varchar(10)  NOT NULL ,
	C_RcCod              varchar(3)  NULL ,
	T_DenomProg          varchar(250)  NOT NULL ,
	T_Resolucion         varchar(250)  NULL ,
	T_DenomGrado         varchar(250)  NULL ,
	T_DenomTitulo        varchar(500)  NULL ,
	C_CodModEst          varchar(5)  NULL ,
	B_SegundaEsp         bit  NOT NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	C_CodRegimenEst      varchar(5)  NULL ,
	C_CodGrado           varchar(5)  NULL ,
	CONSTRAINT PK_ProgramaUnfv PRIMARY KEY  CLUSTERED (C_CodProg ASC),
	CONSTRAINT FK_CarreraProfesional_ProgramaPregrado FOREIGN KEY (C_RcCod) REFERENCES TI_CarreraProfesional(C_RcCod)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT TC_GradoAcademico_ProgramaUnfv FOREIGN KEY (C_CodGrado) REFERENCES TC_GradoAcademico(C_CodGrado)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_ModalidadEstudio_ProgramaUnfv FOREIGN KEY (C_CodModEst) REFERENCES TC_ModalidadEstudio(C_CodModEst)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_RegimenEstudio_ProgramaUnfv FOREIGN KEY (C_CodRegimenEst) REFERENCES TC_RegimenEstudio(C_CodRegimenEst)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_TipoDocumentoIdentidad
( 
	C_CodTipDoc          varchar(5)  NOT NULL ,
	T_TipDocDesc         varchar(150)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_TipoDocumentoIdentidad PRIMARY KEY  CLUSTERED (C_CodTipDoc ASC)
)
go



CREATE TABLE TC_Persona
( 
	I_PersonaID          int  IDENTITY (1,1),
	C_NumDNI             varchar(20)  NULL ,
	C_CodTipDoc          varchar(5)  NULL ,
	T_ApePaterno         varchar(50)  NOT NULL ,
	T_ApeMaterno         varchar(50)  NULL ,
	T_Nombre             varchar(50)  NULL ,
	D_FecNac             date  NULL ,
	C_Sexo               char(1)  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Persona PRIMARY KEY  CLUSTERED (I_PersonaID ASC),
	CONSTRAINT FK_TipoDocumento_Persona FOREIGN KEY (C_CodTipDoc) REFERENCES TC_TipoDocumentoIdentidad(C_CodTipDoc)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go



CREATE TABLE TC_ModalidadIngreso
( 
	C_CodModIng          varchar(2)  NOT NULL ,
	T_ModIngDesc         varchar(150)  NULL ,
	I_IdAplica			 smallint NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_ModalidadIngreso PRIMARY KEY  CLUSTERED (C_CodModIng ASC)
)
go



CREATE TABLE TC_Alumno
( 
	C_RcCod              varchar(3)  NOT NULL ,
	C_CodAlu             varchar(20)  NOT NULL ,
	I_PersonaID          int  NOT NULL ,
	C_CodModIng          varchar(2)  NULL ,
	C_AnioIngreso        int  NULL ,
	I_IdPlan             int  NULL ,
	B_Habilitado         bit  NOT NULL ,
	B_Eliminado          bit  NOT NULL ,
	I_UsuarioCre         int  NULL ,
	D_FecCre             datetime  NULL ,
	I_UsuarioMod         int  NULL ,
	D_FecMod             datetime  NULL ,
	CONSTRAINT PK_Alumno PRIMARY KEY  CLUSTERED (C_RcCod ASC,C_CodAlu ASC),
	CONSTRAINT FK_Persona_Alumno FOREIGN KEY (I_PersonaID) REFERENCES TC_Persona(I_PersonaID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_CarreraProfesional_Alumno FOREIGN KEY (C_RcCod) REFERENCES TI_CarreraProfesional(C_RcCod)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT FK_ModalidadIngreso_Alumno FOREIGN KEY (C_CodModIng) REFERENCES TC_ModalidadIngreso(C_CodModIng)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
go

