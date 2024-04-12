USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ObtenerComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
@I_PagoBancoID INT,
@I_ComprobanteID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @C_CodDepositante VARCHAR(250),
			@I_EntidadFinanID INT,
			@C_CodOperacion VARCHAR(250),
			@D_FecPago DATETIME,
			@OBLIGACION INT = 133,
			@TASA INT = 134;
	IF (@I_ComprobanteID IS NULL) BEGIN
		SELECT
			@C_CodDepositante = b.C_CodDepositante,
			@I_EntidadFinanID = b.I_EntidadFinanID,
			@C_CodOperacion = b.C_CodOperacion,
			@D_FecPago = D_FecPago
		FROM dbo.TR_PagoBanco b
		WHERE b.I_PagoBancoID = @I_PagoBancoID;

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
			pagBan.I_Cantidad,
			ISNULL((SELECT t.C_CodTasa FROM dbo.TR_PagoBanco b
			INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
			INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = p.I_TasaUnfvID
			WHERE b.B_Anulado = 0 AND p.B_Anulado = 0 AND b.I_TipoPagoID = 134 AND p.I_TasaUnfvID IS NOT NULL AND b.I_PagoBancoID = pagBan.I_PagoBancoID), '') AS C_CodTasa
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
	ELSE BEGIN
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
			pagBan.I_Cantidad,
			ISNULL((SELECT t.C_CodTasa FROM dbo.TR_PagoBanco b
			INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
			INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = p.I_TasaUnfvID
			WHERE b.B_Anulado = 0 AND p.B_Anulado = 0 AND b.I_TipoPagoID = 134 AND p.I_TasaUnfvID IS NOT NULL AND b.I_PagoBancoID = pagBan.I_PagoBancoID), '') AS C_CodTasa
		FROM dbo.TR_PagoBanco pagBan
		INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
		INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
		INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
		INNER JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID
		INNER JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
		INNER JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
		INNER JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
		INNER JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
		WHERE com.I_ComprobanteID = @I_ComprobanteID
		ORDER BY pagBan.D_FecVenctoArchivo;
	END
END
GO


