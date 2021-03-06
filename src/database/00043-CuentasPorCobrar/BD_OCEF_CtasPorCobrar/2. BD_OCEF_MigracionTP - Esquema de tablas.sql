USE [BD_OCEF_MigracionTP]
GO

CREATE TABLE TR_MG_EcPri (
	I_RowID			int IDENTITY(1, 1) NOT NULL,
	COD_ALU			nvarchar(255)  NULL,
	COD_RC			nvarchar(255)  NULL,
	TOT_APAGAR		float  NULL,
	NRO_EC			float  NULL,
	FCH_EC			datetime  NULL,
	TOT_PAGADO		float  NULL,
	SALDO			float  NULL,
	ANO				nvarchar(255)  NULL,
	P				nvarchar(255)  NULL,
	ELIMINADO		bit  NULL,
	B_Migrado		bit  NOT NULL DEFAULT 0,
	T_Observacion	nvarchar(1000) NULL
)
GO


CREATE TABLE dbo.TR_MG_EcObl (
	I_RowID			int IDENTITY(1, 1) NOT NULL,
	ANO				nvarchar(255)  NULL,
	P				nvarchar(255)  NULL,
	COD_ALU			nvarchar(255)  NULL,
	COD_RC			nvarchar(255)  NULL,
	CUOTA_PAGO		float  NULL,
	TIPO_OBLIG		bit  NULL,
	FCH_VENC		datetime  NULL,
	MONTO			float  NULL,
	PAGADO			bit  NULL,
	B_Migrado		bit  NOT NULL DEFAULT 0,
	T_Observacion	nvarchar(1000) NULL
)
GO


CREATE TABLE TR_MG_EcDet (
	I_RowID			bigint IDENTITY(1, 1) NOT NULL,
	COD_ALU			nvarchar(50)  NULL,
	COD_RC			nvarchar(50)  NULL,
	CUOTA_PAGO		float  NULL,
	ANO				nvarchar(50)  NULL,
	P				nvarchar(50)  NULL,
	TIPO_OBLIG		varchar(50)  NULL,
	CONCEPTO		float  NULL,
	FCH_VENC		nvarchar(50)  NULL,
	NRO_RECIBO		nvarchar(50)  NULL,
	FCH_PAGO		nvarchar(50)  NULL,
	ID_LUG_PAG		nvarchar(50)  NULL,
	CANTIDAD		nvarchar(50)  NULL,
	MONTO			nvarchar(50)  NULL,
	PAGADO			nvarchar(50)  NULL,
	CONCEPTO_F		nvarchar(50)  NULL,
	FCH_ELIMIN		nvarchar(50)  NULL,
	NRO_EC			float  NULL,
	FCH_EC			nvarchar(50)  NULL,
	ELIMINADO		nvarchar(50)  NULL,
	PAG_DEMAS		nvarchar(50)  NULL,
	COD_CAJERO		nvarchar(50)  NULL,
	TIPO_PAGO		nvarchar(50)  NULL,
	NO_BANCO		nvarchar(50)  NULL,
	COD_DEP			nvarchar(50)  NULL,
	B_Migrado		bit  NOT NULL DEFAULT 0,
	T_Observacion	nvarchar(1000) NULL
) 
GO


CREATE TABLE TR_MG_CpDes(
	I_RowID			int IDENTITY(1, 1) NOT NULL,
	CUOTA_PAGO		float  NULL,
	DESCRIPCIO		nvarchar(255)  NULL,
	N_CTA_CTE		nvarchar(255)  NULL,
	ELIMINADO		bit NULL,
	CODIGO_BNC		nvarchar(255)  NULL,
	FCH_VENC		datetime  NULL,
	PRIORIDAD		nvarchar(255)  NULL,
	C_MORA			nvarchar(255)  NULL,
	B_Migrado		bit  NOT NULL DEFAULT 0,
	T_Observacion	nvarchar(1000) NULL
)
GO


CREATE TABLE TR_MG_CpPri (
	I_RowID			int IDENTITY(1, 1) NOT NULL,
	ID_CP			float  NULL,
	CUOTA_PAGO		float  NULL,
	ANO				nvarchar(255) NULL,
	P				nvarchar(255) NULL,
	COD_RC			nvarchar(255) NULL,
	COD_ING			nvarchar(255) NULL,
	TIPO_OBLIG		bit  NULL,
	CLASIFICAD		nvarchar(255) NULL,
	CLASIFIC_5		nvarchar(255) NULL,
	ID_CP_AGRP		float  NULL,
	AGRUPA			bit  NULL,
	NRO_PAGOS		float  NULL,
	ID_CP_AFEC		float  NULL,
	PORCENTAJE		bit  NULL,
	MONTO			float  NULL,
	ELIMINADO		bit  NULL,
	DESCRIPCIO		nvarchar(255)  NULL,
	CALCULAR		nvarchar(255)  NULL,
	GRADO			float  NULL,
	TIP_ALUMNO		float  NULL,
	GRUPO_RC		nvarchar(255)  NULL,
	FRACCIONAB		bit  NULL,
	CONCEPTO_G		bit  NULL,
	DOCUMENTO		nvarchar(255)  NULL,
	MONTO_MIN		nvarchar(255)  NULL,
	DESCRIP_L		nvarchar(255)  NULL,
	COD_DEP_PL		nvarchar(255)  NULL,
	OBLIG_MORA		nvarchar(255)  NULL,
	B_Migrado		bit  NOT NULL DEFAULT 0,
	T_Observacion	nvarchar(1000) NULL
)
GO

