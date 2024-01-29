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
	pagban.T_InformacionAdicional,
	CASE WHEN pagban.I_CondicionPagoID = 131 OR comp.I_ComprobantePagoBancoID IS NOT NULL THEN 0 ELSE 1 END B_DevolucionPermitida
FROM dbo.TR_PagoBanco pagban
	LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_PagoBancoID = pagban.I_PagoBancoID AND pagpro.B_Anulado = 0
	LEFT JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Eliminado = 0 AND det.B_Habilitado = 1
	LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Eliminado = 0 AND cab.B_Habilitado = 1
	LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
	LEFT JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
	LEFT JOIN dbo.TC_CatalogoOpcion tipPer ON tipPer.I_ParametroID = 5 AND tipPer.I_OpcionID = pro.I_Periodo
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagban.I_CtaDepositoID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
	LEFT JOIN dbo.TR_Comprobante_PagoBanco comp ON comp.I_PagoBancoID = pagban.I_PagoBancoID AND comp.B_Habilitado = 1
WHERE pagban.B_Anulado = 0 AND pagban.I_TipoPagoID = 133 AND NOT pagban.I_CondicionPagoID = 132
GROUP BY pagBan.I_TipoPagoID, pagban.I_PagoBancoID, pagban.C_CodOperacion, pagban.C_CodigoInterno, pagban.C_CodDepositante, pagban.T_NomDepositante,
	ef.I_EntidadFinanID, ef.T_EntidadDesc, cta.I_CtaDepositoID, cta.C_NumeroCuenta,	 pagban.D_FecPago, pagban.I_Cantidad, pagban.C_Moneda,
	pagpro.I_PagoProcesID, pagban.T_ProcesoDescArchivo, pro.I_Anio, tipPer.T_OpcionCod, cat.T_CatPagoDesc, pagban.T_LugarPago, pagBan.I_MontoPago, pagBan.I_InteresMora, 
	pagban.T_InformacionAdicional, pagban.I_CondicionPagoID, comp.I_ComprobantePagoBancoID)

UNION

(SELECT 
	pagban.I_TipoPagoID,
	pagban.I_PagoBancoID,
	pagban.C_CodOperacion,
	pagban.C_CodigoInterno,
	pagban.C_CodDepositante,
	pagban.T_NomDepositante,
	pagban.I_EntidadFinanID,
	ef.T_EntidadDesc,
	cta.I_CtaDepositoID,
	cta.C_NumeroCuenta,
	pagban.D_FecPago,
	pagban.I_Cantidad,
	pagban.C_Moneda,
	t.T_ConceptoPagoDesc AS T_Concepto,
	pagban.T_LugarPago,
	pagban.I_MontoPago,
	pagban.I_InteresMora,
	pagban.T_InformacionAdicional,
	CASE WHEN cons.I_ConstanciaPagoID IS NOT NULL OR comp.I_ComprobantePagoBancoID IS NOT NULL THEN 0 ELSE 1 END B_DevolucionPermitida
FROM dbo.TR_PagoBanco pagban    
	INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_PagoBancoID = pagban.I_PagoBancoID
	INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pagpro.I_TasaUnfvID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
	LEFT JOIN dbo.TR_ConstanciaPago cons ON cons.I_PagoBancoID = pagban.I_PagoBancoID
	LEFT JOIN dbo.TR_Comprobante_PagoBanco comp ON comp.I_PagoBancoID = pagban.I_PagoBancoID AND comp.B_Habilitado = 1
WHERE pagban.B_Anulado = 0 AND pagpro.B_Anulado = 0 AND pagban.I_TipoPagoID = 134 AND NOT pagban.I_CondicionPagoID = 132)
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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Dia')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dia]
GO

CREATE PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dia]
@I_Anio INT,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL,
@I_CondicionPagoID INT = NULL
AS
/*
EXEC USP_S_ResumenAnualPagoDeObligaciones_X_Dia
@I_Anio = 2023,
@I_EntidadFinanID = 2,
@I_CtaDepositoID = NULL,
@I_CondicionPagoID = NULL
GO
*/
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @PagoObligacion INT = 133;
     
	DECLARE @SQLString NVARCHAR(4000),
	@ParmDefinition NVARCHAR(500);

	SET @SQLString = N'
	SELECT
	I_Dia,
	ISNULL([1], 0) AS Enero,
	ISNULL([2], 0) AS Febrero,
	ISNULL([3], 0) AS Marzo,
	ISNULL([4], 0) AS Abril,
	ISNULL([5], 0) AS Mayo,
	ISNULL([6], 0) AS Junio,
	ISNULL([7], 0) AS Julio,
	ISNULL([8], 0) AS Agosto,
	ISNULL([9], 0) AS Setiembre,
	ISNULL([10], 0) AS Octubre,
	ISNULL([11], 0) AS Noviembre,
	ISNULL([12], 0) AS Diciembre
	FROM
	(
	SELECT MONTH(b.D_FecPago) AS I_Month, DAY(b.D_FecPago) AS I_Dia, SUM(b.I_MontoPago + b.I_InteresMora - ISNULL(d.I_MontoPagoDev, 0)) AS I_MontoTotal
	FROM dbo.TR_PagoBanco b
	LEFT JOIN dbo.TR_DevolucionPago d ON d.I_PagoBancoID = b.I_PagoBancoID AND d.B_Anulado = 0
	WHERE b.B_Anulado = 0 AND Year(b.D_FecPago) = @I_Anio AND b.I_TipoPagoID = @I_TipoPagoID ' +
	CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND b.I_EntidadFinanID = @I_EntidadFinanID' END + '
	' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND b.I_CtaDepositoID = @I_CtaDepositoID' END + '
	' + CASE WHEN @I_CondicionPagoID IS NULL THEN 'AND NOT b.I_CondicionPagoID = 132' ELSE 'AND b.I_CondicionPagoID = @I_CondicionPagoID' END + '
	GROUP BY MONTH(b.D_FecPago), DAY(b.D_FecPago)
	) p
	PIVOT
	(
	SUM(p.I_MontoTotal)
	FOR p.I_Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
	) AS pvt'
    
	SET @ParmDefinition = N'@I_TipoPagoID INT, @I_Anio INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @I_CondicionPagoID INT'
	
	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_TipoPagoID = @PagoObligacion,
		@I_Anio = @I_Anio,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID,
		@I_CondicionPagoID = @I_CondicionPagoID

END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ReportePagoObligacionesPregrado')
	DROP PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPregrado]
GO

CREATE PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPregrado]  
@I_TipoReporte int,  
@I_TipoEstudio int,
@C_CodFac varchar(2) = NULL,  
@D_FechaIni date,  
@D_FechaFin date,  
@I_EntidadFinanID int = NULL,  
@I_CtaDeposito int  = NULL  
AS
/*  
EXEC USP_S_ReportePagoObligacionesPregrado   
@I_TipoReporte = 2,  
@I_TipoEstudio = 2,
@C_CodFac = NULL,  
@D_FechaIni = '20210101',   
@D_FechaFin = '20211231',  
@I_EntidadFinanID = NULL,  
@I_CtaDeposito = NULL  
GO  
*/  
BEGIN  
	SET NOCOUNT ON;  
	DECLARE @Pregrado char(1) = '1',
	@SegundaEspecialidad char(2) = '4',
	@Residentado char(4) = '5',
	@N_Grado char(1);

	SET @N_Grado = CASE WHEN @I_TipoEstudio = 1 THEN @Pregrado ELSE (CASE WHEN @I_TipoEstudio = 3 THEN @SegundaEspecialidad ELSE @Residentado END) END
  
	--@I_TipoReporte: 1: Pagos agrupados por facultad.  
	if (@I_TipoReporte = 1) begin  
		select mat.T_FacDesc, mat.C_CodFac, SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_FacDesc, mat.C_CodFac  
		order by mat.T_FacDesc  
	end  
  
	--@I_TipoReporte: 2: Pagos agrupados por concepto.  
	if (@I_TipoReporte = 2) begin  
		select conpag.I_ConceptoID, cl.T_ClasificadorDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc, 
			SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by conpag.I_ConceptoID, cl.T_ClasificadorDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
  
	--@I_TipoReporte: 3: Facultad y Concepto.  
	if (@I_TipoReporte = 3) begin  
		select mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc, 
			SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by mat.T_FacDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
  
   
	--@I_TipoReporte: 4: Concepto por Facultad.  
	if (@I_TipoReporte = 4) begin  
		select mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc,   
			COUNT(pagban.I_PagoBancoID) AS I_Cantidad,  
			SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0   
			and mat.C_CodFac = @C_CodFac  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end
END  
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ReportePagoObligacionesPosgrado')
	DROP PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPosgrado]
GO
  
CREATE PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPosgrado]  
@I_TipoReporte int,  
@C_CodEsc varchar(2) = NULL,  
@D_FechaIni date,  
@D_FechaFin date,  
@I_EntidadFinanID int = NULL,  
@I_CtaDeposito int  = NULL  
AS  
/*  
EXEC USP_S_ReportePagoObligacionesPosgrado   
@I_TipoReporte = 2,  
@C_CodEsc = NULL,  
@D_FechaIni = '20210101',   
@D_FechaFin = '20211231',  
@I_EntidadFinanID = NULL,  
@I_CtaDeposito = NULL  
GO  
*/  
BEGIN  
	SET NOCOUNT ON;  
	DECLARE @Maestria char(1) = '2',  
			@Doctorado char(1) = '3'  
  
	--@I_TipoReporte: 1: Pagos posgrado general.  
	if (@I_TipoReporte = 1) begin  
		select mat.T_EscDesc, mat.C_CodEsc,  SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_EscDesc, mat.C_CodEsc  
		order by mat.T_EscDesc DESC  
	end  
  
	--@I_TipoReporte: 2: Pagos agrupados por concepto.  
	if (@I_TipoReporte = 2) begin  
		select conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc, 
			SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
   
	--@I_TipoReporte: 3: Por Grado y Conceptos.  
	if (@I_TipoReporte = 3) begin  
		select mat.T_EscDesc, mat.C_CodEsc, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc, 
			SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0   
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_EscDesc, mat.C_CodEsc, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by mat.T_EscDesc DESC, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
  
	--@I_TipoReporte: 4: Pagos agrupados por concepto según maestría o doctorado.  
	if (@I_TipoReporte = 4) begin  
		select mat.T_EscDesc, mat.C_CodEsc, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc,   
		COUNT(pagban.I_PagoBancoID) AS I_Cantidad,  
		SUM(pagpro.I_MontoPagado - ISNULL(dev.I_MontoPagoDev, 0)) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
			inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
			inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
			inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
			inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
			left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
			LEFT JOIN dbo.TR_DevolucionPago dev ON dev.I_PagoBancoID = pagban.I_PagoBancoID AND dev.B_Anulado = 0
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)  
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0   
			and mat.C_CodEsc = @C_CodEsc  
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
			and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_EscDesc, mat.C_CodEsc, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
END  
GO
