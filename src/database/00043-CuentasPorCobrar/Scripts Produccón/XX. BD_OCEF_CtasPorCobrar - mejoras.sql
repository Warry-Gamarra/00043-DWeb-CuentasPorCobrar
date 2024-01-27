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

--Actualización de la tabla par a la DEVOLUCIÓN DE DINERO
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
	WHERE Dp.B_Anulado = 0 AND pb.I_TipoPagoID = 133)
	UNION
	(SELECT DP.*, PP.I_MontoPagado, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, TU.T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TRI_PagoProcesadoUnfv PP ON PB.I_PagoBancoID = PP.I_PagoBancoID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID
	WHERE DP.B_Anulado = 0 AND pb.I_TipoPagoID = 134)
)
GO




IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagosParaDevolucion')
	DROP VIEW [dbo].[VW_PagosParaDevolucion]
GO

CREATE VIEW [dbo].[VW_PagosParaDevolucion]
AS
(SELECT
	pagBan.I_TipoPagoID,
	pagban.I_PagoBancoID,
	pagban.C_CodOperacion,
	pagban.C_CodigoInterno,
	pagban.C_CodDepositante,
	pagban.T_NomDepositante,
	ef.I_EntidadFinanID,
	ef.T_EntidadDesc,
	cta.I_CtaDepositoID,
	cta.C_NumeroCuenta,	
	pagban.D_FecPago,
	pagban.I_Cantidad,
	pagban.C_Moneda,
	CASE WHEN pagpro.I_PagoProcesID IS NULL THEN pagban.T_ProcesoDescArchivo ELSE (CAST(pro.I_Anio AS varchar) + '-' + tipPer.T_OpcionCod + ' ' + cat.T_CatPagoDesc) END AS T_Concepto,
	pagban.T_LugarPago, 
	pagBan.I_MontoPago,
	pagBan.I_InteresMora,
	pagban.T_InformacionAdicional
FROM dbo.TR_PagoBanco pagban
	LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_PagoBancoID = pagban.I_PagoBancoID AND pagpro.B_Anulado = 0
	LEFT JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Eliminado = 0 AND det.B_Habilitado = 1
	LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Eliminado = 0 AND cab.B_Habilitado = 1
	LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
	LEFT JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
	LEFT JOIN dbo.TC_CatalogoOpcion tipPer ON tipPer.I_ParametroID = 5 AND tipPer.I_OpcionID = pro.I_Periodo
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagban.I_CtaDepositoID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
WHERE pagban.B_Anulado = 0 AND pagban.I_TipoPagoID = 133 AND NOT pagban.I_CondicionPagoID = 132
GROUP BY pagBan.I_TipoPagoID, pagban.I_PagoBancoID, pagban.C_CodOperacion, pagban.C_CodigoInterno, pagban.C_CodDepositante, pagban.T_NomDepositante,
	ef.I_EntidadFinanID, ef.T_EntidadDesc, cta.I_CtaDepositoID, cta.C_NumeroCuenta,	 pagban.D_FecPago, pagban.I_Cantidad, pagban.C_Moneda,
	pagpro.I_PagoProcesID, pagban.T_ProcesoDescArchivo, pro.I_Anio, tipPer.T_OpcionCod, cat.T_CatPagoDesc, pagban.T_LugarPago, pagBan.I_MontoPago, pagBan.I_InteresMora, pagban.T_InformacionAdicional)
	
UNION

(SELECT 
	pag.I_TipoPagoID,
	pag.I_PagoBancoID,
	pag.C_CodOperacion,
	pag.C_CodigoInterno,
	pag.C_CodDepositante,
	pag.T_NomDepositante,
	pag.I_EntidadFinanID,
	ef.T_EntidadDesc,
	cd.I_CtaDepositoID,
	cd.C_NumeroCuenta,
	pag.D_FecPago,
	pag.I_Cantidad,
	pag.C_Moneda,
	t.T_ConceptoPagoDesc AS T_Concepto,
	pag.T_LugarPago,
	pag.I_MontoPago,
	pag.I_InteresMora,
	pag.T_InformacionAdicional
	--cons.I_AnioConstancia, cons.I_NroConstancia
FROM dbo.TR_PagoBanco pag    
	INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID
	INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID
	LEFT JOIN dbo.TR_ConstanciaPago cons ON cons.I_PagoBancoID = pag.I_PagoBancoID
WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND pag.I_TipoPagoID = 134 AND NOT pag.I_CondicionPagoID = 132)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarDevolucionPago')
	DROP PROCEDURE [dbo].[USP_I_GrabarDevolucionPago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarDevolucionPago]
@I_PagoBancoID int
,@I_MontoPagoDev decimal(15,2)
,@D_FecDevAprob  datetime
,@D_FecDevPago  datetime
,@D_FecProc   datetime
,@T_Comentario  varchar(500)
,@D_FecCre   datetime
,@CurrentUserId  int
,@B_Result bit OUTPUT
,@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		INSERT INTO TR_DevolucionPago (I_PagoBancoID, I_MontoPagoDev, D_FecDevAprob, D_FecDevPago, D_FecProc, T_Comentario, B_Anulado, I_UsuarioCre, D_FecCre)
		VALUES (@I_PagoBancoID, @I_MontoPagoDev, @D_FecDevAprob, @D_FecDevPago, @D_FecProc, @T_Comentario, 0, @CurrentUserId, @D_FecCre);

		SET @B_Result = 1;
		SET @T_Message = 'Registro correcto.';
	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas')
	DROP VIEW [dbo].[VW_PagoTasas]
GO

CREATE VIEW [dbo].[VW_PagoTasas]
AS
	SELECT
		pag.I_PagoBancoID, t.I_TasaUnfvID, pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc,
		t.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto,
		pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre, pag.D_FecMod,
		pag.C_CodigoInterno, pag.T_Observacion,
		cons.I_AnioConstancia, cons.I_NroConstancia, pag.I_CondicionPagoID, cond.T_OpcionDesc AS T_Condicion,
		pag.T_LugarPago, pag.I_Cantidad
	FROM dbo.TR_PagoBanco pag
		INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID
		INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
		INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID
		INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID
		INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pag.I_CondicionPagoID
		LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = t.T_Clasificador
		LEFT JOIN dbo.TR_ConstanciaPago cons ON cons.I_PagoBancoID = pag.I_PagoBancoID
	WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND t.B_Eliminado = 0 AND ef.B_Eliminado = 0
GO