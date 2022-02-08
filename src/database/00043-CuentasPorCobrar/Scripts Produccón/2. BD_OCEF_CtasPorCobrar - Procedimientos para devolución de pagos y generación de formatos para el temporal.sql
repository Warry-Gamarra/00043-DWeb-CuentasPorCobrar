USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DevolucionPago')
	DROP VIEW [dbo].[VW_DevolucionPago]
GO

CREATE VIEW [dbo].[VW_DevolucionPago]
AS
(
	 --SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago  
		-- , EF.T_EntidadDesc, '' AS C_CodClasificador  
		-- , PR.T_ProcesoDesc AS T_ConceptoPagoDesc   
	 --  FROM TR_DevolucionPago DP  
		-- INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID   
		-- INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID  
		-- INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID  
		-- INNER JOIN TR_ObligacionAluCab OC ON OC.I_ObligacionAluID = PP.I_ObligacionAluID
		-- INNER JOIN TC_Proceso PR ON PR.I_ProcesoID = OC.I_ProcesoID
	 --UNION  
	 --SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago  
		-- , EF.T_EntidadDesc, (CL.C_TipoTransCod + '.' + CL.C_GenericaCod + '.' + CL.C_SubGeneCod + '.' + CL.C_EspecificaCod) AS C_CodClasificador  
		-- , TU.T_ConceptoPagoDesc  
	 --  FROM TR_DevolucionPago DP  
		-- INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID   
		-- INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID  
		-- INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID  
		-- INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID  
		-- LEFT JOIN VW_Clasificadores cl ON cl.C_ClasificConceptoCod = TU.T_Clasificador  

	SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago
		   , EF.T_EntidadDesc, (CL.C_TipoTransCod + '.' + CL.C_GenericaCod + '.' + CL.C_SubGeneCod + '.' + CL.C_EspecificaCod) AS C_CodClasificador
		   , CP.T_ConceptoPagoDesc 
	  FROM TR_DevolucionPago DP
		   INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID 
		   INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID
		   INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		   INNER JOIN TR_ObligacionAluDet OD ON OD.I_ObligacionAluDetID = PP.I_ObligacionAluDetID 
		   INNER JOIN TR_ObligacionAluCab OC ON OC.I_ObligacionAluID = OD.I_ObligacionAluID
		   INNER JOIN TI_ConceptoPago CP ON CP.I_ConcPagID = OD.I_ConcPagID
		   LEFT JOIN VW_Clasificadores cl ON cl.C_ClasificConceptoCod = CP.T_Clasificador
	UNION
	SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago
		   , EF.T_EntidadDesc, (CL.C_TipoTransCod + '.' + CL.C_GenericaCod + '.' + CL.C_SubGeneCod + '.' + CL.C_EspecificaCod) AS C_CodClasificador
		   , TU.T_ConceptoPagoDesc
	  FROM TR_DevolucionPago DP
		   INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID 
		   INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID
		   INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		   INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID
		   LEFT JOIN VW_Clasificadores cl ON cl.C_ClasificConceptoCod = TU.T_Clasificador

)
GO




IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagosDetalle')
	DROP VIEW [dbo].[VW_PagosDetalle]
GO

CREATE VIEW [dbo].[VW_PagosDetalle]
AS
	SELECT DISTINCT 
		ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto, cab.I_ObligacionAluID) AS I_NroOrden,
		pagpro.I_PagoProcesID, pagpro.I_PagoBancoID, cta.I_CtaDepositoID, ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, pagpro.N_NroSIAF,
		pagban.C_CodOperacion, pagban.C_CodDepositante, pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod AS C_Periodo,
		CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre) AS T_NomAlumno, tipEs.T_OpcionCod as C_Nivel, 
		cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.I_Anio, mat.I_Periodo, 
		pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda, cab.I_MontoOblig,
		cab.B_Pagado, pagban.T_LugarPago, cab.D_FecCre, pagpro.I_MontoPagado, pagpro.I_SaldoAPagar, pagpro.I_PagoDemas,
		ISNULL(srv.C_CodServicio, '') AS C_CodServicio, pagban.C_Referencia, ISNULL(NULL, pro.T_ProcesoDesc) AS T_Concepto,
		pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc, mat.T_FacDesc, mat.T_DenomProg,
		ISNULL(pagban.T_InformacionAdicional, '') AS T_InformacionAdicional, 1 AS B_EsObligacion
	FROM dbo.VW_MatriculaAlumno mat
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0
		INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
		INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
		LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
		INNER JOIN dbo.TC_CatalogoOpcion tipEs ON tipEs.I_ParametroID = 2 AND tipEs.I_OpcionID = cat.I_Nivel
		INNER JOIN dbo.TC_CatalogoOpcion tipPer ON tipPer.I_ParametroID = 5 AND tipPer.I_OpcionID = pro.I_Periodo
		INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0
		INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
		INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
		INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID		
	--UNION
	--SELECT 
	--	ROW_NUMBER() OVER(PARTITION BY pagban.D_FecPago ORDER BY pagban.D_FecPago, pagban.C_CodDepositante) AS I_NroOrden,
	--	pagpro.I_PagoProcesID, pagpro.I_PagoBancoID, cta.I_CtaDepositoID, ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, pagpro.N_NroSIAF,
	--	pagban.C_CodOperacion, pagban.C_CodDepositante, pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad,
	--	CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre) AS T_NomAlumno, tipEs.T_OpcionCod as C_Nivel,
	--	0 as I_ObligacionAluID, 0 AS I_ProcesoID, '' AS N_CodBanco, '' AS C_CodAlu, C_RcCod, mat.I_Anio, mat.I_Periodo, 
	--	pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,
	--	cab.B_Pagado, pagban.T_LugarPago, cab.D_FecCre, pagpro.I_MontoPagado, pagpro.I_SaldoAPagar, pagpro.I_PagoDemas,
	--	ISNULL(srv.C_CodServicio, '') AS C_CodServicio, pagban.C_Referencia, ISNULL(cpag.T_ConceptoPagoDesc, pro.T_ProcesoDesc) AS T_Concepto,
	--	pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc, mat.T_FacDesc, mat.T_DenomProg, 0 AS B_EsObligacion
	--FROM dbo.VW_MatriculaAlumno mat
	--	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
	--	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
	--	INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
	--	INNER JOIN dbo.TC_CatalogoOpcion tipEs ON tipEs.I_ParametroID = 2 AND tipEs.I_OpcionID = cat.I_Nivel
	--	LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
	--	INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
	--	INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0
	--	INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
	--	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
	--	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
	--	LEFT JOIN dbo.TI_ConceptoPago cpag ON cpag.I_ProcesoID = cab.I_ProcesoID
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_Pagos')
	DROP VIEW [dbo].[VW_Pagos]
GO

CREATE VIEW [dbo].[VW_Pagos]
AS
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
		cta.I_CtaDepositoID, ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, pagban.C_CodOperacion, pagban.C_CodDepositante, pagban.I_PagoBancoID,
		pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod AS C_Periodo,
		CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre) AS T_NomAlumno, tipEs.T_OpcionCod as C_Nivel, 
		cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, pro.I_Anio, tipPer.T_OpcionCod AS I_Periodo, pro.T_ProcesoDesc, 
		(CAST(pro.I_Anio AS varchar) + '-' + tipPer.T_OpcionCod + ' ' + cat.T_CatPagoDesc) AS T_Concepto, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda, cab.I_MontoOblig,
		cab.B_Pagado, pagban.T_LugarPago, cab.D_FecCre, SUM(pagpro.I_MontoPagado) AS I_MontoPagado, ISNULL(srv.C_CodServicio, '') AS C_CodServicio, 
		pagban.C_Referencia, pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc, mat.T_FacDesc, mat.T_DenomProg,
		ISNULL(pagban.T_InformacionAdicional, '') AS T_InformacionAdicional, 1 AS B_EsObligacion
	FROM dbo.VW_MatriculaAlumno mat
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0
		INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
		INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
		LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
		INNER JOIN dbo.TC_CatalogoOpcion tipEs ON tipEs.I_ParametroID = 2 AND tipEs.I_OpcionID = cat.I_Nivel
		INNER JOIN dbo.TC_CatalogoOpcion tipPer ON tipPer.I_ParametroID = 5 AND tipPer.I_OpcionID = pro.I_Periodo
		INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0
		INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
		INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
		INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
	WHERE pagban.I_TipoPagoID = 133
	GROUP BY
		mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto,
		cta.I_CtaDepositoID, C_NumeroCuenta, pagban.C_CodOperacion, pagban.C_CodDepositante,
		pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod, pagban.I_PagoBancoID,
		CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre), tipEs.T_OpcionCod, cat.T_CatPagoDesc,
		cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, tipPer.T_OpcionCod, 
		pro.T_ProcesoDesc, pro.I_Prioridad, cab.C_Moneda, cab.I_MontoOblig,
		cab.B_Pagado, pagban.T_LugarPago, cab.D_FecCre, ISNULL(srv.C_CodServicio, ''),
		pagban.C_Referencia, pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, ''), mat.T_FacDesc, mat.T_DenomProg,
		ISNULL(pagban.T_InformacionAdicional, '')
GO