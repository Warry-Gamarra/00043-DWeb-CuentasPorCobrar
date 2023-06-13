USE BD_OCEF_CtasPorCobrar
GO

CREATE TABLE TR_ConstanciaPago
(
	I_ConstanciaPagoID INT IDENTITY(1,1),
	I_PagoBancoID INT NOT NULL,
	I_AnioConstancia INT NOT NULL,
	I_NroConstancia INT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	CONSTRAINT PK_ConstanciaPago PRIMARY KEY (I_ConstanciaPagoID),
	CONSTRAINT UQ_ConstanciaPago UNIQUE (I_AnioConstancia, I_NroConstancia, I_PagoBancoID),
	CONSTRAINT UQ_PagoBanco UNIQUE (I_PagoBancoID),
	CONSTRAINT FK_PagoBanco_ConstanciaPago FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco (I_PagoBancoID)
)
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarConstanciaPago')
	DROP PROCEDURE [dbo].[USP_I_GrabarConstanciaPago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarConstanciaPago]
@I_PagoBancoID INT,
@I_AnioConstancia INT,
@I_NroConstancia INT,
@UserID INT
AS
BEGIN  
	SET NOCOUNT ON;
	
	INSERT dbo.TR_ConstanciaPago(I_PagoBancoID, I_AnioConstancia, I_NroConstancia, I_UsuarioCre, D_FecCre)
	VALUES(@I_PagoBancoID, @I_AnioConstancia, @I_NroConstancia, @UserID, GETDATE())
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoBancoObligaciones')
	DROP VIEW [dbo].[VW_PagoBancoObligaciones]
GO
    
CREATE VIEW [dbo].[VW_PagoBancoObligaciones]
AS    
	SELECT b.I_PagoBancoID, e.I_EntidadFinanID, e.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, b.C_CodOperacion, b.C_CodDepositante,
		c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, m.N_Grado,
		b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc AS T_Condicion, b.T_Observacion,
		b.T_MotivoCoreccion, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoProcesado, b.C_CodigoInterno,
		ISNULL(pro.T_ProcesoDesc, b.T_ProcesoDescArchivo) AS T_ProcesoDesc,
		ISNULL(pro.D_FecVencto, b.D_FecVenctoArchivo) AS D_FecVencto,
		cons.I_AnioConstancia, cons.I_NroConstancia
	FROM TR_PagoBanco b
	LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID AND p.B_Anulado = 0
	LEFT JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluDetID = p.I_ObligacionAluDetID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0
	LEFT JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = d.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	LEFT JOIN dbo.VW_MatriculaAlumno m ON m.I_MatAluID = c.I_MatAluID
	LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = c.I_ProcesoID
	INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID = b.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = b.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cn ON cn.I_OpcionID = b.I_CondicionPagoID
	LEFT JOIN dbo.TR_ConstanciaPago cons ON cons.I_PagoBancoID = b.I_PagoBancoID
	WHERE b.I_TipoPagoID = 133 AND b.B_Anulado = 0
	GROUP BY b.I_PagoBancoID, e.I_EntidadFinanID, cd.I_CtaDepositoID, cd.C_NumeroCuenta, e.T_EntidadDesc, b.C_CodOperacion, b.C_CodDepositante,
		c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, m.N_Grado,
		b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc, b.T_Observacion, b.T_MotivoCoreccion,
		b.C_CodigoInterno, pro.T_ProcesoDesc, b.T_ProcesoDescArchivo, pro.D_FecVencto, b.D_FecVenctoArchivo,
		cons.I_AnioConstancia, cons.I_NroConstancia
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas')
	DROP VIEW [dbo].[VW_PagoTasas]
GO

CREATE VIEW [dbo].[VW_PagoTasas]
AS
	SELECT pag.I_PagoBancoID, tu.I_TasaUnfvID, pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc,
		tu.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto,
		pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre, pag.D_FecMod,
		pag.C_CodigoInterno, pag.T_Observacion,
		cons.I_AnioConstancia, cons.I_NroConstancia
	FROM dbo.TR_PagoBanco pag
	INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID
	INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID
	INNER JOIN dbo.TI_TasaUnfv tu ON tu.I_TasaUnfvID = pr.I_TasaUnfvID
	LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = tu.T_Clasificador
	LEFT JOIN dbo.TR_ConstanciaPago cons ON cons.I_PagoBancoID = pag.I_PagoBancoID
	WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND t.B_Eliminado = 0 AND ef.B_Eliminado = 0 AND tu.B_Eliminado = 0
GO
