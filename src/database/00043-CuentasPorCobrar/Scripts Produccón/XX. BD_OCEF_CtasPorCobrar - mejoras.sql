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
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_OCEF_CtasPorCobrar_20231024.bak' WITH FILE = 1, 
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


