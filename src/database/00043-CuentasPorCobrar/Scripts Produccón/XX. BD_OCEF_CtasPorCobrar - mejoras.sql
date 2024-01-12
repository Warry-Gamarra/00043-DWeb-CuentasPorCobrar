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


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DetalleObligaciones')
	DROP VIEW [dbo].[VW_DetalleObligaciones]
GO
  
CREATE VIEW [dbo].[VW_DetalleObligaciones]  
AS  
SELECT   
 det.I_ObligacionAluDetID, cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, 
 mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, mat.C_CodModIng,  
 per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo,   
 pro.T_ProcesoDesc, ISNULL(cp.T_ConceptoPagoDesc, con.T_ConceptoDesc) AS T_ConceptoDesc, cat.T_CatPagoDesc, det.I_Monto, det.B_Pagado, det.D_FecVencto, pro.I_Prioridad,  
 cab.C_Moneda, cp.I_TipoObligacion, cat.I_Nivel, niv.T_OpcionCod AS C_Nivel, niv.T_OpcionDesc AS T_Nivel, cat.I_TipoAlumno, tipal.T_OpcionCod AS C_TipoAlumno,   
 tipal.T_OpcionDesc AS T_TipoAlumno, cp.B_Mora, det.I_TipoDocumento, det.T_DescDocumento, cp.B_EsPagoMatricula
FROM dbo.VW_MatriculaAlumno mat  
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0   
INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID and det.B_Habilitado = 1 AND det.B_Eliminado = 0  
INNER JOIN dbo.TI_ConceptoPago cp ON cp.I_ConcPagID = det.I_ConcPagID AND det.B_Eliminado = 0  
INNER JOIN dbo.TC_Concepto con ON con.I_ConceptoID = cp.I_ConceptoID AND con.B_Eliminado = 0  
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cp.I_ProcesoID AND pro.B_Eliminado = 0  
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0  
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo  
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_OpcionID = cat.I_Nivel  
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_OpcionID = cat.I_TipoAlumno
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


