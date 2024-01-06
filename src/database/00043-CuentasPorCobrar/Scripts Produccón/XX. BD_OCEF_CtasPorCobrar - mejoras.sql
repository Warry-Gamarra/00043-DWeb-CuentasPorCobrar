/*

USE [master]
GO
ALTER DATABASE [BD_UNFV_Repositorio] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [BD_UNFV_Repositorio]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_UNFV_Repositorio_20231017.bak' WITH FILE = 1, 
     MOVE N'BD_UNFV_Repositorio' TO N'F:\Microsoft SQL Server\DATA\BD_UNFV_Repositorio.mdf', 
     MOVE N'BD_UNFV_Repositorio_log' TO N'F:\Microsoft SQL Server\DATA\BD_UNFV_Repositorio_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;

ALTER DATABASE [BD_UNFV_Repositorio] SET MULTI_USER;
GO

USE BD_UNFV_Repositorio
GO

DROP USER [UserUNFV];
DROP USER [UserOCEF];
DROP USER [uweb_general]; 
CREATE USER [UserOCEF] FOR LOGIN [UserOCEF] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE [db_owner] ADD MEMBER [UserOCEF];
GO
---------------------------------------------------------------------------------------------------------------------
USE [master]
GO
ALTER DATABASE [BD_OCEF_CtasPorCobrar] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [BD_OCEF_CtasPorCobrar]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_OCEF_CtasPorCobrar_20240105_PRUEBAS.bak' WITH FILE = 1, 
     MOVE N'BD_OCEF_CtasPorCobrar' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar.mdf', 
     MOVE N'BD_OCEF_CtasPorCobrar_log' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;

ALTER DATABASE [BD_OCEF_CtasPorCobrar] SET MULTI_USER;
GO

USE BD_OCEF_CtasPorCobrar
GO

DROP USER [UserUNFV];
DROP USER [UserOCEF];
DROP USER [uweb_general]; 
CREATE USER [UserOCEF] FOR LOGIN [UserOCEF] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE [db_owner] ADD MEMBER [UserOCEF];
GO
*/


USE BD_OCEF_CtasPorCobrar
GO


ALTER TABLE dbo.TR_Comprobante ADD T_Direccion VARCHAR(250), T_Ruc VARCHAR(250)
GO

INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('NOF', 'Sin archivo', 1, 1, GETDATE())
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarComprobantePago')
	DROP PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
@PagoBancoIDs [dbo].[type_Ids] READONLY,
@I_TipoComprobanteID INT,
@I_SerieID INT,
@B_EsGravado BIT,
@T_Ruc VARCHAR(250),
@T_Direccion VARCHAR(250),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	DECLARE @I_ComprobanteID INT,
			@I_NuevoNumeroComprobante INT,
			@D_FechaAccion DATETIME,
			@D_FechaEmision DATETIME,
			@I_EstadoComprobanteID INT,
			--VALIDACIONES
			@I_FinNumeroComprobante INT,
			@D_FecPago DATETIME,
			@I_DiasPermitidos INT;

	SET @I_NuevoNumeroComprobante = (SELECT ISNULL(MAX(c.I_NumeroComprobante), 0) FROM dbo.TR_Comprobante c WHERE c.I_SerieID = @I_SerieID) + 1;

	SET @D_FecPago = (SELECT TOP 1 b.D_FecPago FROM dbo.TR_PagoBanco b WHERE b.I_PagoBancoID IN (SELECT i.ID FROM @PagoBancoIDs i))

	SELECT @I_FinNumeroComprobante = s.I_FinNumeroComprobante, @I_DiasPermitidos = s.I_DiasAnterioresPermitido 
	FROM dbo.TC_SerieComprobante s WHERE s.I_SerieID = @I_SerieID;

	IF (@I_NuevoNumeroComprobante <= @I_FinNumeroComprobante) BEGIN
		IF (DATEDIFF(DAY, @D_FecPago, GETDATE()) <= @I_DiasPermitidos) BEGIN

			SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante WHERE C_EstadoComprobanteCod = 'PEN');
		
			SET @D_FechaAccion = GETDATE();
		
			SET @D_FechaEmision = GETDATE();

			BEGIN TRAN
			BEGIN TRY
				INSERT dbo.TR_Comprobante(I_TipoComprobanteID, I_SerieID, I_NumeroComprobante, B_EsGravado, D_FechaEmision, I_EstadoComprobanteID, I_UsuarioCre, D_FecCre,
					T_Ruc, T_Direccion)
				VALUES(@I_TipoComprobanteID, @I_SerieID, @I_NuevoNumeroComprobante, @B_EsGravado, @D_FechaEmision, @I_EstadoComprobanteID, @UserID, @D_FechaAccion,
					@T_Ruc, @T_Direccion);

				SET @I_ComprobanteID = SCOPE_IDENTITY();

				UPDATE dbo.TR_Comprobante_PagoBanco SET 
					B_Habilitado = 0,
					I_UsuarioMod = @UserID,
					D_FecMod = @D_FechaAccion
				WHERE I_PagoBancoID IN (SELECT ID FROM @PagoBancoIDs) AND B_Habilitado = 1;

				INSERT dbo.TR_Comprobante_PagoBanco(I_ComprobanteID, I_PagoBancoID, B_Habilitado, I_UsuarioCre, D_FecCre)
				SELECT @I_ComprobanteID, ID, 1, @UserID, @D_FechaAccion FROM @PagoBancoIDs;

				COMMIT TRAN
				SET @B_Result = 1;
				SET @T_Message = 'Generación exitosa del número de comprobante "' + CAST(@I_NuevoNumeroComprobante AS VARCHAR(20)) + '".';
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN
				SET @B_Result = 0;
				SET @T_Message = ERROR_MESSAGE();
			END CATCH

		END ELSE BEGIN
			SET @B_Result = 0;
			SET @T_Message = 'Se excedió la cantidad de días de antigüedad (' + CAST(@I_DiasPermitidos AS VARCHAR) + ') del pago para generar el número de comprobante.';
		END
	END ELSE BEGIN
		SET @B_Result = 0;
		SET @T_Message = 'Se excedió el valor permitido (' + CAST(@I_FinNumeroComprobante AS VARCHAR(100)) + ') para el número de comprobante.';
	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoComprobantePago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoComprobantePago]
@I_NumeroSerie INT,
@I_NumeroComprobante INT,
@C_EstadoComprobanteCod VARCHAR(50),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	DECLARE @D_FechaAccion DATETIME,
			@I_EstadoComprobanteID INT;

	IF EXISTS(SELECT c.I_ComprobanteID FROM dbo.TR_Comprobante c INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
		WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante) BEGIN
		
		IF EXISTS(SELECT c.I_ComprobanteID FROM dbo.TR_Comprobante c 
			INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
			INNER JOIN TR_Comprobante_PagoBanco cp ON cp.I_ComprobanteID = c.I_ComprobanteID
			WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante AND cp.B_Habilitado = 1) BEGIN

			IF EXISTS(SELECT c.I_ComprobanteID FROM dbo.TR_Comprobante c 
				INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
				INNER JOIN dbo.TC_EstadoComprobante e ON e.I_EstadoComprobanteID = c.I_EstadoComprobanteID
				WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante AND e.C_EstadoComprobanteCod IN ('PEN', 'NOF')) BEGIN

				SET @D_FechaAccion = GETDATE();

				SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante WHERE C_EstadoComprobanteCod = @C_EstadoComprobanteCod);

				BEGIN TRAN
				BEGIN TRY
					UPDATE c SET 
						c.I_EstadoComprobanteID = @I_EstadoComprobanteID,
						c.I_UsuarioMod = @UserID,
						c.D_FecMod = @D_FechaAccion
					FROM dbo.TR_Comprobante c
					INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
					WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante

					COMMIT TRAN
					SET @B_Result = 1;
					SET @T_Message = 'Actualización de estado correcta.';
				END TRY
				BEGIN CATCH
					ROLLBACK TRAN
					SET @B_Result = 0;
					SET @T_Message = ERROR_MESSAGE();
				END CATCH

			END ELSE BEGIN
				SET @B_Result = 1;
				SET @T_Message = 'El comprobante con serie "' + CAST(@I_NumeroSerie AS VARCHAR) + '" y número "' + CAST(@I_NumeroComprobante AS VARCHAR(20)) + '" ya tiene actualizado el estado.';
			END

		END ELSE BEGIN
			SET @B_Result = 1;
			SET @T_Message = 'El comprobante con serie "' + CAST(@I_NumeroSerie AS VARCHAR) + '" y número "' + CAST(@I_NumeroComprobante AS VARCHAR(20)) + '" está deshabilitado.';
		END
	END ELSE BEGIN
		SET @B_Result = 0;
		SET @T_Message = 'No existe el comprobante con serie "' + CAST(@I_NumeroSerie AS VARCHAR) + '" y número "' + CAST(@I_NumeroComprobante AS VARCHAR(20)) + '".';
	END
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
@D_FechaFin DATETIME = NULL,
@I_TipoComprobanteID INT = NULL,
@I_EstadoGeneracion BIT = NULL,
@I_EstadoComprobanteID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @SQLString NVARCHAR(4000),  
			@ParmDefinition NVARCHAR(500);

	SET @SQLString = N'SELECT
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
		com.I_ComprobanteID,
		ser.I_SerieID,
		ser.I_NumeroSerie,
		com.I_NumeroComprobante,
		com.D_FechaEmision,
		com.B_EsGravado,
		com.T_Ruc,
		com.T_Direccion,
		tipCom.I_TipoComprobanteID,
		tipCom.C_TipoComprobanteCod,
		tipCom.T_TipoComprobanteDesc,
		tipCom.T_Inicial,
		estCom.C_EstadoComprobanteCod,
		estCom.T_EstadoComprobanteDesc
	FROM dbo.TR_PagoBanco pagBan
	INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
	LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID AND cpb.B_Habilitado = 1
	LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
	LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
	LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
	LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
	WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_TipoPagoID = 132
	' + CASE WHEN @I_TipoPagoID IS NULL THEN '' ELSE 'AND pagBan.I_TipoPagoID = @I_TipoPagoID' END + '
	' + CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND pagBan.I_EntidadFinanID = @I_EntidadFinanID' END + '
	' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND pagBan.I_CtaDepositoID = @I_CtaDepositoID' END + '
	' + CASE WHEN @C_CodOperacion IS NULL THEN '' ELSE 'AND pagBan.C_CodOperacion LIKE ''%'' + @C_CodOperacion' END + '
	' + CASE WHEN @C_CodigoInterno IS NULL THEN '' ELSE 'AND pagBan.C_CodigoInterno LIKE ''%'' + @C_CodigoInterno' END + '
	' + CASE WHEN @C_CodDepositante IS NULL THEN '' ELSE 'AND pagBan.C_CodDepositante LIKE ''%'' + @C_CodDepositante' END + '
	' + CASE WHEN @T_NomDepositante IS NULL THEN '' ELSE 'AND pagBan.T_NomDepositante LIKE ''%'' + @T_NomDepositante + ''%'' COLLATE Modern_Spanish_CI_AI' END + '
	' + CASE WHEN @D_FechaInicio IS NULL THEN '' ELSE 'AND DATEDIFF(DAY, pagBan.D_FecPago, @D_FechaInicio) <= 0' END + '
	' + CASE WHEN @D_FechaFin IS NULL THEN '' ELSE 'AND DATEDIFF(DAY, pagBan.D_FecPago, @D_FechaFin) >= 0' END + '
	' + CASE WHEN @I_TipoComprobanteID IS NULL THEN '' ELSE 'AND com.I_TipoComprobanteID = @I_TipoComprobanteID' END + '
	' + CASE WHEN @I_EstadoGeneracion IS NULL THEN '' ELSE (CASE WHEN @I_EstadoGeneracion = 1 THEN 'AND com.I_ComprobanteID IS NOT NULL' ELSE 'AND com.I_ComprobanteID IS NULL' END) END + '
	' + CASE WHEN @I_EstadoComprobanteID IS NULL THEN '' ELSE 'AND com.I_EstadoComprobanteID = @I_EstadoComprobanteID' END + '
	ORDER BY pagBan.D_FecPago DESC';
	
	SET @ParmDefinition = N'@I_TipoPagoID INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @C_CodOperacion VARCHAR(50), @C_CodigoInterno VARCHAR(250),
		@C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200), @D_FechaInicio DATETIME, @D_FechaFin DATETIME, @I_TipoComprobanteID INT, @I_EstadoComprobanteID INT';

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_TipoPagoID = @I_TipoPagoID,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID,
		@C_CodOperacion = @C_CodOperacion,
		@C_CodigoInterno = @C_CodigoInterno,
		@C_CodDepositante = @C_CodDepositante,
		@T_NomDepositante = @T_NomDepositante,
		@D_FechaInicio = @D_FechaInicio,
		@D_FechaFin = @D_FechaFin,
		@I_TipoComprobanteID = @I_TipoComprobanteID,
		@I_EstadoComprobanteID = @I_EstadoComprobanteID;
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
			@D_FecPago DATETIME,
			@OBLIGACION INT = 133,
			@TASA INT = 134;

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
		com.I_ComprobanteID,
		ser.I_SerieID,
		ser.I_NumeroSerie,
		com.I_NumeroComprobante,
		com.D_FechaEmision,
		com.B_EsGravado,
		com.T_Ruc,
		com.T_Direccion,
		tipCom.I_TipoComprobanteID,
		tipCom.C_TipoComprobanteCod,
		tipCom.T_TipoComprobanteDesc,
		tipCom.T_Inicial,
		estCom.C_EstadoComprobanteCod,
		estCom.T_EstadoComprobanteDesc,
		CASE WHEN pagBan.I_TipoPagoID = @OBLIGACION THEN pagBan.T_ProcesoDescArchivo  + ' (F.VCTO.' + CONVERT(VARCHAR(10), pagBan.D_FecVenctoArchivo, 103) + ')'
			ELSE (SELECT t.T_ConceptoPagoDesc FROM dbo.TRI_PagoProcesadoUnfv pr INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
			WHERE pr.B_Anulado = 0 AND pr.I_PagoBancoID = pagBan.I_PagoBancoID) END AS T_Concepto,
		pagBan.I_Cantidad
	FROM dbo.TR_PagoBanco pagBan
	INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
	LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID AND cpb.B_Habilitado = 1
	LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
	LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
	LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
	LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
	WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_CondicionPagoID = 132 AND 
		pagBan.C_CodDepositante	 = @C_CodDepositante AND
		pagBan.I_EntidadFinanID = @I_EntidadFinanID AND
		pagBan.C_CodOperacion = @C_CodOperacion AND
		DATEDIFF(SECOND, pagBan.D_FecPago, @D_FecPago) = 0
	ORDER BY pagBan.D_FecVenctoArchivo;
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_EliminarMatricula')
	DROP PROCEDURE [dbo].[USP_U_EliminarMatricula]
GO

CREATE PROCEDURE [dbo].[USP_U_EliminarMatricula]
@I_MatAluID INT,
@I_UsuarioMod INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @D_FecMod DATETIME = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		UPDATE dbo.TC_MatriculaCurso SET
			B_Habilitado = 0,
			B_Eliminado = 1,
			I_UsuMod = @I_UsuarioMod,
			D_FecMod = @D_FecMod
		WHERE I_MatAluID = @I_MatAluID AND B_Habilitado = 1 AND B_Eliminado = 0;

		UPDATE dbo.TC_MatriculaAlumno SET 
			B_Habilitado = 0, 
			B_Eliminado = 1,
			I_UsuarioMod = @I_UsuarioMod,
			D_FecMod = @D_FecMod
		WHERE I_MatAluID = @I_MatAluID AND B_Habilitado = 1 AND B_Eliminado = 0;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Eliminación correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
@Tbl_Pagos [dbo].[type_dataPago] READONLY,
@Observacion varchar(250),
@D_FecRegistro datetime, 
@UserID  int
AS    
BEGIN    
	SET NOCOUNT ON;    
    
	DECLARE @Tmp_PagoObligacion TABLE (    
		id INT IDENTITY(1,1),    
		I_ProcesoID   int NULL,    
		I_ObligacionAluID int NULL,    
		C_CodOperacion  varchar(50),    
		C_CodDepositante varchar(20),    
		T_NomDepositante varchar(200),    
		C_Referencia  varchar(50),    
		D_FecPago   datetime,    
		D_FecVencto   datetime,    
		D_FecVenctoBD  datetime,    
		I_Cantidad   int,    
		C_Moneda   varchar(3),    
		I_MontoOblig  decimal(15,2) NULL,    
		I_MontoPago   decimal(15,2),    
		I_InteresMora  decimal(15,2),    
		T_LugarPago   varchar(250),    
		I_EntidadFinanID int,    
		I_CtaDepositoID  int,    
		B_Pagado   bit NULL,    
		B_Success   bit,    
		T_ErrorMessage  varchar(250),    
		T_InformacionAdicional  varchar(250),    
		T_ProcesoDesc  varchar(250),    
		I_CondicionPagoID int,    
		T_Observacion  varchar(250),  
		C_CodigoInterno  varchar(250),
		T_SourceFileName varchar(250)
	);  
    
	DECLARE @Tmp_DetalleObligacion TABLE(    
		id INT,    
		I_ObligacionAluDetID int,    
		I_MontoDet   decimal(15,2),    
		I_MontoPagadoDet decimal(15,2)    
	);    
    
	WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto, B_Pagado, I_MontoOblig)    
	AS     
	(    
		SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto, cab.B_Pagado, cab.I_MontoOblig    
		FROM dbo.TC_MatriculaAlumno m
		LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID AND cab.B_Eliminado = 0    
		WHERE m.B_Eliminado = 0
	)
	INSERT @Tmp_PagoObligacion(I_ProcesoID, I_ObligacionAluID, C_CodOperacion, C_CodDepositante, T_NomDepositante,     
	C_Referencia, D_FecPago, D_FecVencto, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, I_InteresMora, T_LugarPago, I_EntidadFinanID, I_CtaDepositoID, B_Pagado,    
	T_InformacionAdicional, T_ProcesoDesc, D_FecVenctoBD, I_CondicionPagoID, T_Observacion, C_CodigoInterno, T_SourceFileName)    
     
	SELECT p.I_ProcesoID, m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,    
		p.C_Referencia, p.D_FecPago, p.D_FecVencto, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.I_EntidadFinanID, I_CtaDepositoID, m.B_Pagado,    
		p.T_InformacionAdicional, p.T_ProcesoDesc, m.D_FecVencto, p.I_CondicionPagoID, p.T_Observacion, p.C_CodigoInterno, p.T_SourceFileName   
	FROM @Tbl_Pagos p    
	LEFT JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND     
	m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0 AND m.I_MontoOblig = p.I_MontoPago; 
    
	DECLARE @I_FilaActual  int = 1,    
		@I_CantRegistros int = (select count(id) from @Tmp_PagoObligacion),    
		@I_ProcesoID  int,    
		@T_ProcesoDesc  varchar(250),    
		@I_ObligacionAluID int,    
		--PAGO EN BANCO    
		@I_PagoBancoID  int,       
		@C_CodOperacion  varchar(50),    
		@C_CodDepositante varchar(20),    
		@T_NomDepositante varchar(200),    
		@C_Referencia  varchar(50),    
		@D_FecPago   datetime,    
		@I_Cantidad   int,    
		@C_Moneda   varchar(3),    
		@I_MontoPago  decimal(15,2),    
		@I_InteresMora  decimal(15,2),    
		@T_LugarPago  varchar(250),    
		@I_EntidadFinanID int,    
		@I_CtaDepositoID int,    
		@T_InformacionAdicional varchar(250),    
		@I_CondicionPagoID int,    
		@T_Observacion  varchar(250),    
		@C_CodigoInterno varchar(250),  
		--PAGO DETALLE    
		@I_FilaActualDet int,    
		@I_CantRegistrosDet int,    
		@I_ObligacionAluDetID int,       
		@I_MontoOligacionDet decimal(15,2),    
		@I_MontoPagadoActual decimal(15,2),    
		@I_SaldoPendiente decimal(15,2),    
		@I_MontoAPagar  decimal(15,2),    
		@I_NuevoSaldoPend decimal(15,2),    
		@I_PagoDemas  decimal(15,2),    
		@B_PagoDemas  bit,    
		@B_Pagado   bit,    
		--MORA
		@B_RegistrarPagoConMora bit,
		@I_ConcPagID  int,    
		@D_FecVencto  datetime,    
		--CONTROL ERRORES    
		@D_FecVenctoBD  datetime,    
		@B_ExisteError  bit,
		@B_CodOpeCorrecto bit,    
		@B_ObligPagada  bit,    
		--Constantes    
		@CondicionCorrecto int = 131,--PAGO CORRECTO    
		@CondicionExtorno int = 132,--PAGO EXTORNADO
		@CondicionDoblePago int = 135,--DOBLE PAGO A UNA MISMA OBLIGACIÓN
		@CondicionNoExisteOblg int = 136,--PAGO A UNA OBLIGACIÓN INEXISTENTE,
		@CondicionNoCampoMora int = 142,--NO EXISTE CAMPO INTERES MORATORIO
		@PagoTipoObligacion int = 133--OBLIGACION    
    
	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN    
      
		SET @B_ExisteError = 0
		SET @B_RegistrarPagoConMora = 1
    
		SELECT  @I_ProcesoID = I_ProcesoID,    
			@T_ProcesoDesc = T_ProcesoDesc,
			@I_ObligacionAluID = I_ObligacionAluID,     
			@C_CodOperacion = C_CodOperacion,     
			@C_CodDepositante = C_CodDepositante,     
			@T_NomDepositante = T_NomDepositante,     
			@C_Referencia = C_Referencia,     
			@D_FecPago = D_FecPago,     
			@D_FecVencto = D_FecVencto,    
			@I_Cantidad = I_Cantidad,    
			@C_Moneda = C_Moneda,     
			@I_MontoPago = I_MontoPago,    
			@I_InteresMora = I_InteresMora,    
			@T_LugarPago= T_LugarPago,    
			@I_EntidadFinanID = I_EntidadFinanID,    
			@I_CtaDepositoID = I_CtaDepositoID,    
			@B_ObligPagada = B_Pagado,    
			@T_InformacionAdicional = T_InformacionAdicional,    
			@D_FecVenctoBD = D_FecVenctoBD,    
			@I_CondicionPagoID = I_CondicionPagoID,    
			@T_Observacion = CASE WHEN (I_CondicionPagoID = @CondicionCorrecto) THEN @Observacion ELSE T_Observacion END  ,  
			@C_CodigoInterno = C_CodigoInterno
		FROM @Tmp_PagoObligacion 
		WHERE id = @I_FilaActual    
    
		IF (@I_ObligacionAluID IS NULL) BEGIN
			SET @I_CondicionPagoID = @CondicionNoExisteOblg
			SET @T_Observacion = 'No existe obligaciones para este alumno.'
		END
    
		IF NOT(@I_CondicionPagoID IN (@CondicionExtorno, @CondicionNoExisteOblg)) AND (@B_ObligPagada = 1) BEGIN	
			SET @I_CondicionPagoID = @CondicionDoblePago
			SET @T_Observacion = 'Esta obligación ya ha sido pagada con anterioridad.'
		END
    
		IF  (@B_ExisteError = 0) BEGIN
			EXEC dbo.USP_S_ValidarCodOperacionObligacion 
				@C_CodOperacion, 
				@C_CodDepositante, 
				@I_EntidadFinanID, 
				@D_FecPago, 
				@I_ProcesoID,
				@D_FecVencto,
				@B_CodOpeCorrecto OUTPUT
    
			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1
        
				UPDATE @Tmp_PagoObligacion SET 
					B_Success = 0, 
					T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.'
				WHERE id = @I_FilaActual
			END
		END
    
		IF (@B_ExisteError = 0) AND NOT(@I_CondicionPagoID = @CondicionExtorno) AND (@I_InteresMora > 0) AND (@I_ObligacionAluID IS NOT NULL) AND
			NOT EXISTS(SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1) BEGIN
    
			SET @B_RegistrarPagoConMora = 0
			SET @I_CondicionPagoID = @CondicionNoCampoMora
			SET @T_Observacion = 'No existe un concepto para guardar el Interés moratorio.'
		END
          
		IF (@B_ExisteError = 0) AND (@I_CtaDepositoID IS NULL) BEGIN    
			SET @I_CtaDepositoID = (SELECT cta.I_CtaDepositoID FROM dbo.TI_CtaDepo_Proceso cta
				INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cta.I_CtaDepositoID
				WHERE cta.B_Habilitado = 1 AND cta.B_Eliminado = 0 AND
					cta.I_ProcesoID = @I_ProcesoID and c.I_EntidadFinanID = @I_EntidadFinanID)
    
			IF (@I_CtaDepositoID IS NULL) BEGIN
				SET @B_ExisteError = 1
        
				UPDATE @Tmp_PagoObligacion SET 
					B_Success = 0, 
					T_ErrorMessage = 'No existe una Cuenta asignada para registrar la obligación.' 
				WHERE id = @I_FilaActual
			END
		END
    
		BEGIN TRANSACTION
		BEGIN TRY
			IF (@B_ExisteError = 0) BEGIN
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno,
					I_ProcesoIDArchivo, T_ProcesoDescArchivo, D_FecVenctoArchivo)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @T_Observacion,
					@T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoObligacion, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno,
					@I_ProcesoID, @T_ProcesoDesc, @D_FecVencto)
    
				SET @I_PagoBancoID = SCOPE_IDENTITY()   
    
				IF (@I_CondicionPagoID = @CondicionCorrecto AND @B_RegistrarPagoConMora = 1) BEGIN    
    
					DELETE FROM @Tmp_DetalleObligacion    
    
					INSERT @Tmp_DetalleObligacion(id, I_ObligacionAluDetID, I_MontoDet, I_MontoPagadoDet)    
					SELECT ROW_NUMBER() OVER (ORDER BY det.I_Monto ASC), det.I_ObligacionAluDetID, det.I_Monto, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoPagado     
					FROM dbo.TR_ObligacionAluDet det    
					LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND p.B_Anulado = 0    
					WHERE det.I_ObligacionAluID = @I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 0 AND det.B_Pagado = 0    
					GROUP BY det.I_ObligacionAluDetID, det.I_Monto    
					ORDER BY det.I_Monto ASC    
    
					SET @I_FilaActualDet = 1    
					SET @I_CantRegistrosDet = (SELECT COUNT(*) FROM @Tmp_DetalleObligacion)    
    
					WHILE (@I_FilaActualDet <= @I_CantRegistrosDet AND @I_MontoPago > 0) BEGIN    
    
						SELECT    
							@I_ObligacionAluDetID = I_ObligacionAluDetID,     
							@I_MontoOligacionDet = I_MontoDet,     
							@I_MontoPagadoActual = I_MontoPagadoDet     
						FROM @Tmp_DetalleObligacion WHERE id = @I_FilaActualDet    
    
						SET @I_SaldoPendiente = @I_MontoOligacionDet - @I_MontoPagadoActual    
    
						EXEC dbo.USP_AsignarPagoDetalleObligacion    
							@I_FilaActualDet = @I_FilaActualDet,    
							@I_CantRegistrosDet = @I_CantRegistrosDet,    
							@I_SaldoPendiente  = @I_SaldoPendiente,    
							@I_MontoPago = @I_MontoPago OUTPUT,    
							@B_Pagado = @B_Pagado OUTPUT,    
							@I_MontoAPagar = @I_MontoAPagar OUTPUT,    
							@I_NuevoSaldoPend = @I_NuevoSaldoPend OUTPUT,    
							@I_PagoDemas = @I_PagoDemas OUTPUT,    
							@B_PagoDemas = @B_PagoDemas OUTPUT    
        
						INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,    
						D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)    
						VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_MontoAPagar, @I_NuevoSaldoPend, @I_PagoDemas, @B_PagoDemas,    
						@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)    
    
						IF (@B_Pagado = 1) BEGIN    
							UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro    
							WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID    
						END    
    
						SET @I_FilaActualDet = @I_FilaActualDet + 1    
					END    
        
					IF NOT EXISTS (SELECT d.I_ObligacionAluID FROM dbo.TR_ObligacionAluDet d     
						WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND d.B_Mora = 0 AND d.B_Pagado = 0)    
					BEGIN    
						UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = 1, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro    
						WHERE I_ObligacionAluID = @I_ObligacionAluID    
					END    
    
					IF (@I_InteresMora > 0) BEGIN    
						SET @I_ConcPagID = (SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1)    
    
						INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)    
						VALUES (@I_ObligacionAluID, @I_ConcPagID, @I_InteresMora, 1, @D_FecVencto, 1, 0, @UserID, @D_FecRegistro, 1)    
    
						SET @I_ObligacionAluDetID = SCOPE_IDENTITY()    
    
						INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,     
						D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)    
						VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_InteresMora, 0, 0, 0,@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)    
					END    
    
					SET @T_Observacion = 'Registro correcto.'
				END

				UPDATE @Tmp_PagoObligacion SET B_Success = 1, I_CondicionPagoID = @I_CondicionPagoID, T_ErrorMessage = @T_Observacion WHERE id = @I_FilaActual
			END

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION    
    
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual    
		END CATCH    
    
		SET @I_FilaActual = @I_FilaActual + 1    
	END    
    
	SELECT * FROM @Tmp_PagoObligacion    
END    
GO






--Actualización de la tabla para la DEVOLUCIÓN DE DINERO
ALTER TABLE dbo.TR_DevolucionPago DROP CONSTRAINT FK_PagoProcesadoUnfv_DevolucionPago
GO

ALTER TABLE dbo.TR_DevolucionPago DROP COLUMN I_PagoProcesID
GO

ALTER TABLE dbo.TR_DevolucionPago ADD I_PagoBancoID INT NOT NULL
GO

ALTER TABLE dbo.TR_DevolucionPago ADD CONSTRAINT FK_PagoBanco_DevolucionPago 
FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco(I_PagoBancoID)
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DevolucionPago')
	DROP VIEW [dbo].[VW_DevolucionPago]
GO

CREATE VIEW [dbo].[VW_DevolucionPago]
AS
(
	(SELECT DP.*, PB.I_MontoPago, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, pr.T_ProcesoDesc AS T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		LEFT JOIN dbo.TC_Proceso pr ON pr.I_ProcesoID = pb.I_ProcesoIDArchivo
	WHERE Dp.B_Anulado = 0)
	UNION
	(SELECT DP.*, PP.I_MontoPagado, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, TU.T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TRI_PagoProcesadoUnfv PP ON PB.I_PagoBancoID = PP.I_PagoProcesID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID
	WHERE DP.B_Anulado = 0)
)
GO

--SELECT * FROM dbo.VW_DevolucionPago

--select t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto, pr.I_MontoPagado, pr.I_PagoDemas, p.I_MontoPago, * 
--from dbo.TR_PagoBanco p
--inner join dbo.TRI_PagoProcesadoUnfv pr on pr.I_PagoBancoID = p.I_PagoBancoID
--inner join dbo.TI_TasaUnfv t on t.I_TasaUnfvID = pr.I_TasaUnfvID
--where p.B_Anulado = 0 and pr.B_Anulado = 0 and p.I_TipoPagoID = 134 and t.M_Monto > 0
--	and pr.I_PagoDemas > 0


--SELECT * FROM TR_PagoBanco
--SELECT * FROM TRI_PagoProcesadoUnfv


