USE BD_OCEF_CtasPorCobrar
GO



--REGISTRO DE TASAS
SET IDENTITY_INSERT dbo.TC_Servicios ON
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(24, '046', 'UNFV ADMISION 2017', 1, 0, 1, GETDATE())
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(25, '047', 'UNFV ADMISION 2018', 1, 0, 1, GETDATE())
GO
SET IDENTITY_INSERT dbo.TC_Servicios OFF
GO
DBCC CHECKIDENT ('dbo.TC_Servicios', RESEED, 25);  
GO  

INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 5, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(7, 6, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(1, 7, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 8, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(5, 10, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(3, 11, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 14, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 25, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(1, 21, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 24, 1, 0, 1, GETDATE())
GO

SELECT cds.I_CtaDepoServicioID, s.C_CodServicio, s.T_DescServ, cd.C_NumeroCuenta FROM TI_CtaDepo_Servicio cds
INNER JOIN TC_Servicios s ON s.I_ServicioID = cds.I_ServicioID
INNER JOIN TC_CuentaDeposito cd ON cd.I_CtaDepositoID = cds.I_CtaDepositoID
WHERE cd.I_EntidadFinanID = 1
ORDER BY s.C_CodServicio



SELECT * FROM dbo.TC_Concepto where I_ConceptoID = 11

INSERT dbo.TC_Concepto (T_ConceptoDesc, T_ClasifCorto, B_EsObligacion, B_EsPagoMatricula, B_EsPagoExtmp, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_TipoObligacion, B_Calculado, I_Calculado, B_GrupoCodRc, B_ModalidadIngreso, B_ConceptoAgrupa, N_NroPagos, B_Porcentaje, C_Moneda, I_Monto, I_MontoMinimo, B_Mora, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES ('', '', 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 1, 0, 'PEN', 00.00, 00.00, 0, 1, 0, 1, GETDATE())

SELECT * FROM dbo.TI_TasaUnfv where C_CodTasa = '80043'

INSERT dbo.TI_TasaUnfv(I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_TipoObligacion, C_CodTasa, B_Calculado, I_Calculado, B_AnioPeriodo, B_Especialidad, B_Dependencia, B_GrupoCodRc, B_ModalidadIngreso, B_ConceptoAgrupa, B_ConceptoAfecta, N_NroPagos, B_Porcentaje, C_Moneda, M_Monto, M_MontoMinimo, B_Migrado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(@I_ConceptoID, @T_ConceptoPagoDesc, 0, 0, 0, 10, @C_CodTasa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 'PEN', @M_Monto, @M_Monto, 0, 1, 0, 1, GETDATE())

SELECT * FROM dbo.TI_TasaUnfv_CtaDepoServicio where I_TasaUnfvID = 23

INSERT dbo.TI_TasaUnfv_CtaDepoServicio(I_CtaDepoServicioID, I_TasaUnfvID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(@I_CtaDepoServicioID, @I_TasaUnfvID, 1, 0, 1, GETDATE())

















--Actualización de la tabla para la devolución de dinero
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

SELECT * FROM dbo.VW_DevolucionPago

select t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto, pr.I_MontoPagado, pr.I_PagoDemas, p.I_MontoPago, * 
from dbo.TR_PagoBanco p
inner join dbo.TRI_PagoProcesadoUnfv pr on pr.I_PagoBancoID = p.I_PagoBancoID
inner join dbo.TI_TasaUnfv t on t.I_TasaUnfvID = pr.I_TasaUnfvID
where p.B_Anulado = 0 and pr.B_Anulado = 0 and p.I_TipoPagoID = 134 and t.M_Monto > 0
	and pr.I_PagoDemas > 0


SELECT * FROM TR_PagoBanco
SELECT * FROM TRI_PagoProcesadoUnfv
