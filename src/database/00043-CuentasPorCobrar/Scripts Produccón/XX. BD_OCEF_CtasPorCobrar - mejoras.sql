USE [master]
GO

RESTORE DATABASE [BD_OCEF_CtasPorCobrar]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_OCEF_CtasPorCobrar_20230825.bak' WITH FILE = 1, 
     MOVE N'BD_OCEF_CtasPorCobrar' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar.mdf', 
     MOVE N'BD_OCEF_CtasPorCobrar_log' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;
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
  INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0 AND cab.B_Habilitado = 1
  INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0 AND det.B_Habilitado = 1
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
