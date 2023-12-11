/*
- AGREGAR CRITERIO DE SIN NÚMERO DE COMPROBANTE.
- Pagos con fecha de antiguedad  7 días o según criterio.
- Mantenimiento de Número de Serie y comprobante.
- Mantenimiento de Tipo de Comprobante.
- Mantenimiento para asignar fecha de antiguedad.
- Agregar validación para OMITIR PAGOS QUE YA TIENEN NÚMERO DE COMPROBANTES.
- Generar el TXT según formato de digiflow y almacenarlo en una carpeta.
*/

USE BD_OCEF_CtasPorCobrar
GO

CREATE TABLE dbo.TC_TipoComprobante
(
	I_TipoComprobanteID INT IDENTITY(1,1),
	C_TipoComprobanteCod VARCHAR(50) NOT NULL,
	T_TipoComprobanteDesc VARCHAR(250) NOT NULL,
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_TipoComprobante PRIMARY KEY (I_TipoComprobanteID)
)
GO

CREATE TABLE dbo.TC_EstadoComprobante
(
	I_EstadoComprobanteID INT IDENTITY(1,1),
	C_EstadoComprobanteCod VARCHAR(50) NOT NULL,
	T_EstadoComprobanteDesc VARCHAR(250) NOT NULL,
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_EstadoComprobante PRIMARY KEY (I_EstadoComprobanteID)
)
GO

CREATE TABLE dbo.TC_SerieComprobante(
	I_SerieID INT IDENTITY(1,1),
	I_NumeroSerie INT NOT NULL,
	B_Habilitado INT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_SerieComprobante PRIMARY KEY (I_SerieID)
)
GO

CREATE TABLE dbo.TR_ComprobantePago(
	I_ComprobantePagoID INT IDENTITY(1,1),
	I_TipoComprobanteID INT NOT NULL,
	I_SerieID INT NOT NULL,
	I_NumeroComprobante INT NOT NULL,	
	B_EsGravado BIT NOT NULL,--EN EL EXCEL GRE->CATALOGOSUNAT->CELDA 109 HAY UNA TABLA TIPO DE AFECTO, CONSULTAR SI ESTE VALOR SE OBTIENE DE AHÍ, o lo dejo como booleano.
	D_FechaEmision DATETIME NOT NULL,
	I_EstadoComprobanteID INT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_ComprobantePago PRIMARY KEY (I_ComprobantePagoID),
	CONSTRAINT FK_TipoComprobante_ComprobantePago FOREIGN KEY (I_TipoComprobanteID) REFERENCES TC_TipoComprobante(I_TipoComprobanteID),
	CONSTRAINT FK_Estado_ComprobantePago FOREIGN KEY (I_EstadoComprobanteID) REFERENCES TC_EstadoComprobante(I_EstadoComprobanteID),
	CONSTRAINT UQ_ComprobantePago UNIQUE (I_SerieID, I_NumeroComprobante),
	CONSTRAINT FK_SerieComprobante_ComprobantePago FOREIGN KEY (I_SerieID) REFERENCES TC_SerieComprobante(I_SerieID)
)
GO

ALTER TABLE dbo.TR_PagoBanco ADD I_ComprobantePagoID INT
GO

ALTER TABLE dbo.TR_PagoBanco ADD CONSTRAINT FK_ComprobantePago_PagoBanco FOREIGN KEY (I_ComprobantePagoID) REFERENCES TR_ComprobantePago(I_ComprobantePagoID)
GO

INSERT dbo.TC_SerieComprobante(I_NumeroSerie, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES(1, 1, 1, GETDATE())
GO

INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('01', 'Factura', 0, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('03', 'Boleta de venta', 1, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('07', 'Nota de crédito', 0, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('08', 'Nota de débito', 0, 1, GETDATE())
GO

INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('PEN', 'Pendiente', 1, 1, GETDATE())
INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('PRO', 'Procesado', 1, 1, GETDATE())
INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('ERR', 'Error', 1, 1, GETDATE())
GO

CREATE TYPE dbo.type_Ids AS TABLE(ID INT)
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarComprobantePago')
	DROP PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
@PagoBancoIDs [dbo].[type_Ids] READONLY,
@I_TipoComprobanteID INT,
@I_SerieID INT,
@B_EsGravado BIT,
@UserID INT,
@B_Result BIT OUTPUT,  
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	DECLARE @I_ComprobantePagoID INT,
			@I_NumeroComprobante INT,
			@D_FechaEmision DATETIME,
			@I_EstadoComprobanteID INT;

	BEGIN TRAN
	BEGIN TRY

		SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante WHERE C_EstadoComprobanteCod = 'PEN');
		
		SET @I_NumeroComprobante = (SELECT ISNULL(MAX(c.I_NumeroComprobante), 0) FROM dbo.TR_ComprobantePago c WHERE c.I_SerieID = @I_SerieID) + 1;

		SET @D_FechaEmision = GETDATE();

		INSERT dbo.TR_ComprobantePago(I_TipoComprobanteID, I_SerieID, I_NumeroComprobante, B_EsGravado, D_FechaEmision, I_EstadoComprobanteID, I_UsuarioCre, D_FecCre)
		VALUES(@I_TipoComprobanteID, @I_SerieID, @I_NumeroComprobante, @B_EsGravado, @D_FechaEmision, @I_EstadoComprobanteID, @UserID, @D_FechaEmision);

		SET @I_ComprobantePagoID = SCOPE_IDENTITY();

		UPDATE dbo.TR_PagoBanco SET 
			I_ComprobantePagoID = @I_ComprobantePagoID,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaEmision
		WHERE I_PagoBancoID IN (SELECT ID FROM @PagoBancoIDs);
		
		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Generación de número de comprobante exitoso.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ListarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarComprobantePago]
@I_TipoPagoID INT = NULL,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL,
@C_CodOperacion VARCHAR(50) = NULL,
@C_CodigoInterno VARCHAR(250) = NULL,
@C_CodDepositante VARCHAR(20) = NULL,
@T_NomDepositante VARCHAR(200) = NULL,
@D_FechaInicio DATETIME = NULL,
@D_FechaFin DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @SQLString NVARCHAR(4000),  
			@ParmDefinition NVARCHAR(500);

	SET @SQLString = N'SELECT TOP 1000
		pagBan.I_PagoBancoID,
		ban.I_EntidadFinanID,
		ban.T_EntidadDesc,
		cta.C_NumeroCuenta,
		pagBan.C_CodOperacion,
		pagBan.C_CodigoInterno,
		pagBan.C_CodDepositante,
		pagban.T_NomDepositante,
		pagBan.D_FecPago,
		pagBan.I_MontoPago,
		pagBan.I_InteresMora,
		pagBan.T_LugarPago,
		cond.T_OpcionDesc AS ''T_Condicion'',
		pagBan.I_TipoPagoID,
		com.I_ComprobantePagoID,
		ser.I_NumeroSerie,
		com.I_NumeroComprobante,
		com.D_FechaEmision,
		com.B_EsGravado,
		tipCom.T_TipoComprobanteDesc,
		estCom.T_EstadoComprobanteDesc
	FROM dbo.TR_PagoBanco pagBan
	INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
	LEFT JOIN dbo.TR_ComprobantePago com ON com.I_ComprobantePagoID = pagBan.I_ComprobantePagoID
	LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
	LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
	LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
	WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_TipoPagoID = 132
	' + CASE WHEN @I_TipoPagoID IS NULL THEN '' ELSE 'AND pagBan.I_TipoPagoID = @I_TipoPagoID ' END + '
	' + CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND pagBan.I_EntidadFinanID = @I_EntidadFinanID' END + '
	' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND pagBan.I_CtaDepositoID = @I_CtaDepositoID' END + '
	' + CASE WHEN @C_CodOperacion IS NULL THEN '' ELSE 'AND pagBan.C_CodOperacion LIKE ''%'' + @C_CodOperacion' END + '
	' + CASE WHEN @C_CodigoInterno IS NULL THEN '' ELSE 'AND pagBan.C_CodigoInterno LIKE ''%'' + @C_CodigoInterno' END + '
	' + CASE WHEN @C_CodDepositante IS NULL THEN '' ELSE 'AND pagBan.C_CodDepositante LIKE ''%'' + @C_CodDepositante' END + '
	' + CASE WHEN @T_NomDepositante IS NULL THEN '' ELSE 'AND pagBan.T_NomDepositante LIKE ''%'' + @T_NomDepositante + ''%'' COLLATE Modern_Spanish_CI_AI' END + '
	' + CASE WHEN @D_FechaInicio IS NULL THEN '' ELSE 'AND DATEDIFF(DAY, pagBan.D_FecPago, @D_FechaInicio) <= 0' END + '
	' + CASE WHEN @D_FechaFin IS NULL THEN '' ELSE 'AND DATEDIFF(DAY, pagBan.D_FecPago, @D_FechaFin) >= 0' END + '
	ORDER BY pagBan.D_FecPago DESC';

	SET @ParmDefinition = N'@I_TipoPagoID INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @C_CodOperacion VARCHAR(50), @C_CodigoInterno VARCHAR(250),
		@C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200), @D_FechaInicio DATETIME, @D_FechaFin DATETIME';

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_TipoPagoID = @I_TipoPagoID,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID,
		@C_CodOperacion = @C_CodOperacion,
		@C_CodigoInterno = @C_CodigoInterno,
		@C_CodDepositante = @C_CodDepositante,
		@T_NomDepositante = @T_NomDepositante,
		@D_FechaInicio = @D_FechaInicio,
		@D_FechaFin = @D_FechaFin;
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ObtenerComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
@I_PagoBancoID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @C_CodDepositante VARCHAR(250),
			@I_EntidadFinanID INT,
			@C_CodOperacion VARCHAR(250),
			@D_FecPago DATETIME;

	SELECT 
		@C_CodDepositante = b.C_CodDepositante,
		@I_EntidadFinanID = b.I_EntidadFinanID,
		@C_CodOperacion = b.C_CodOperacion,
		@D_FecPago = D_FecPago
	FROM dbo.TR_PagoBanco b
	WHERE b.I_PagoBancoID = @I_PagoBancoID ;

	SELECT
		pagBan.I_PagoBancoID,
		ban.I_EntidadFinanID,
		ban.T_EntidadDesc,
		cta.C_NumeroCuenta,
		pagBan.C_CodOperacion,
		pagBan.C_CodigoInterno,
		pagBan.C_CodDepositante,
		pagban.T_NomDepositante,
		pagBan.D_FecPago,
		pagBan.I_MontoPago,
		pagBan.I_InteresMora,
		pagBan.T_LugarPago,
		cond.T_OpcionDesc AS 'T_Condicion',
		pagBan.I_TipoPagoID,
		com.I_ComprobantePagoID,
		ser.I_NumeroSerie,
		com.I_NumeroComprobante,
		com.D_FechaEmision,
		com.B_EsGravado,
		tipCom.T_TipoComprobanteDesc,
		estCom.T_EstadoComprobanteDesc
	FROM dbo.TR_PagoBanco pagBan
	INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
	LEFT JOIN dbo.TR_ComprobantePago com ON com.I_ComprobantePagoID = pagBan.I_ComprobantePagoID
	LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
	LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
	LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
	WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_TipoPagoID = 132 AND 
		pagBan.C_CodDepositante	 = @C_CodDepositante AND
		pagBan.I_EntidadFinanID = @I_EntidadFinanID AND
		pagBan.C_CodOperacion = @C_CodOperacion AND
		DATEDIFF(SECOND, pagBan.D_FecPago, @D_FecPago) = 0;
END
GO


EXEC USP_S_ListarComprobantePago @C_CodOperacion = '738724';
EXEC USP_S_ObtenerComprobantePago @I_PagoBancoID = 609301;

