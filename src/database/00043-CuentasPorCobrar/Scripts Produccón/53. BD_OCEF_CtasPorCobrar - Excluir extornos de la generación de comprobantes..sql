USE BD_OCEF_CtasPorCobrar
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_DarBajaComprobante')
	DROP PROCEDURE [dbo].[USP_U_DarBajaComprobante]
GO
 
CREATE PROCEDURE dbo.USP_U_DarBajaComprobante
@I_ComprobanteID INT,
@D_FecBaja DATETIME,
@T_MotivoBaja VARCHAR(250),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME,
			@I_EstadoComprobanteID INT;

	BEGIN TRAN
	BEGIN TRY
		SET @D_FechaAccion = GETDATE();
		SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante e WHERE e.C_EstadoComprobanteCod = 'BAJ');
			
		UPDATE dbo.TR_Comprobante SET 
			I_EstadoComprobanteID = @I_EstadoComprobanteID,
			D_FecBaja = @D_FecBaja,
			T_MotivoBaja = @T_MotivoBaja,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_ComprobanteID = @I_ComprobanteID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Acción realizada con éxito.';
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
@D_FechaFin DATETIME = NULL,
@I_TipoComprobanteID INT = NULL,
@I_EstadoGeneracion BIT = NULL,
@I_EstadoComprobanteID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(4000);

	SET @SQLString = N'SELECT b.I_PagoBancoID,e.I_EntidadFinanID,e.T_EntidadDesc,c.C_NumeroCuenta,b.C_CodOperacion,b.C_CodigoInterno,
		b.C_CodDepositante,b.T_NomDepositante,b.D_FecPago,b.I_MontoPago,b.I_InteresMora,b.T_LugarPago,cond.T_OpcionDesc AS ''T_Condicion'',b.I_TipoPagoID,
		com.I_ComprobanteID,ser.I_SerieID,ser.I_NumeroSerie,com.I_NumeroComprobante,com.D_FechaEmision,com.B_EsGravado,com.T_Ruc,com.T_Direccion,
		t.I_TipoComprobanteID,t.C_TipoComprobanteCod,t.T_TipoComprobanteDesc,t.T_Inicial,estCom.C_EstadoComprobanteCod,estCom.T_EstadoComprobanteDesc
		FROM dbo.TR_PagoBanco b
		INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID=b.I_EntidadFinanID
		INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID=b.I_CtaDepositoID
		INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID=b.I_CondicionPagoID
		LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID=b.I_PagoBancoID AND cpb.B_Habilitado=1
		LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID=cpb.I_ComprobanteID
		LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID=com.I_SerieID
		LEFT JOIN dbo.TC_TipoComprobante t ON t.I_TipoComprobanteID=com.I_TipoComprobanteID
		LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID=com.I_EstadoComprobanteID
		WHERE b.B_Anulado=0 AND NOT b.I_CondicionPagoID=132
		' + CASE WHEN @I_TipoPagoID IS NULL THEN N'' ELSE N'AND b.I_TipoPagoID=@I_TipoPagoID' END + N'
		' + CASE WHEN @I_EntidadFinanID IS NULL THEN N'' ELSE N'AND b.I_EntidadFinanID=@I_EntidadFinanID' END + N'
		' + CASE WHEN @I_CtaDepositoID IS NULL THEN N'' ELSE N'AND b.I_CtaDepositoID=@I_CtaDepositoID' END + N'
		' + CASE WHEN @C_CodOperacion IS NULL THEN N'' ELSE N'AND b.C_CodOperacion LIKE ''%''+@C_CodOperacion' END + N'
		' + CASE WHEN @C_CodigoInterno IS NULL THEN N'' ELSE N'AND b.C_CodigoInterno LIKE ''%''+@C_CodigoInterno' END + N'
		' + CASE WHEN @C_CodDepositante IS NULL THEN N'' ELSE N'AND b.C_CodDepositante LIKE ''%''+@C_CodDepositante' END + N'
		' + CASE WHEN @T_NomDepositante IS NULL THEN N'' ELSE N'AND b.T_NomDepositante LIKE ''%''+@T_NomDepositante+''%'' COLLATE Modern_Spanish_CI_AI' END + N'
		' + CASE WHEN @D_FechaInicio IS NULL THEN N'' ELSE N'AND DATEDIFF(DAY,b.D_FecPago,@D_FechaInicio)<=0' END + N'
		' + CASE WHEN @D_FechaFin IS NULL THEN N'' ELSE N'AND DATEDIFF(DAY,b.D_FecPago,@D_FechaFin)>=0' END + N'
		' + CASE WHEN @I_TipoComprobanteID IS NULL THEN N'' ELSE N'AND com.I_TipoComprobanteID=@I_TipoComprobanteID' END + N'
		' + CASE WHEN @I_EstadoGeneracion IS NULL THEN N'' ELSE (CASE WHEN @I_EstadoGeneracion = 1 THEN N'AND com.I_ComprobanteID IS NOT NULL' ELSE N'AND com.I_ComprobanteID IS NULL' END) END + N'
		' + CASE WHEN @I_EstadoComprobanteID IS NULL THEN N'' ELSE N'AND com.I_EstadoComprobanteID=@I_EstadoComprobanteID' END + N'
		ORDER BY D_FecPago DESC';

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
