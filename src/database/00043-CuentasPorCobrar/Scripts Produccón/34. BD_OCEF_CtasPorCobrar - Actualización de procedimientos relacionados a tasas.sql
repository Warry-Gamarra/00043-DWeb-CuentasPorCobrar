USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas')
	DROP VIEW [dbo].[VW_PagoTasas]
GO

CREATE VIEW [dbo].[VW_PagoTasas]    
AS    
 SELECT pag.I_PagoBancoID, tu.I_TasaUnfvID, pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc,     
  tu.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto,     
  pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre, pag.D_FecMod,
  pag.C_CodigoInterno, pag.T_Observacion
 FROM dbo.TR_PagoBanco pag    
 INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID    
 INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID    
 INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID    
 INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID    
 INNER JOIN dbo.TI_TasaUnfv tu ON tu.I_TasaUnfvID = pr.I_TasaUnfvID    
 LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = tu.T_Clasificador    
 WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND t.B_Eliminado = 0 AND ef.B_Eliminado = 0 AND tu.B_Eliminado = 0    
GO





IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ValidarCodOperacionTasa')
	DROP PROCEDURE [dbo].[USP_S_ValidarCodOperacionTasa]
GO

CREATE PROCEDURE [dbo].[USP_S_ValidarCodOperacionTasa]  
@C_CodOperacion VARCHAR(50),  
@I_EntidadFinanID INT,  
@D_FecPago DATETIME,  
@B_Correct BIT OUTPUT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @I_BcoComercio INT = 1,  
   @I_BcoCredito INT = 2  
  
 SET @B_Correct = 0  
  
 IF (@I_EntidadFinanID = @I_BcoComercio) BEGIN  
  SET @B_Correct = CASE WHEN EXISTS(SELECT b.I_PagoBancoID FROM dbo.TR_PagoBanco b  
   INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = b.I_PagoBancoID  
   WHERE b.B_Anulado = 0 AND pr.B_Anulado = 0 AND pr.I_TasaUnfvID IS NOT NULL AND b.I_EntidadFinanID = @I_BcoComercio AND  
    b.C_CodOperacion = @C_CodOperacion AND DATEDIFF(YEAR, b.D_FecPago, @D_FecPago) = 0) THEN 0 ELSE 1 END  
 END  
  
 IF (@I_EntidadFinanID = @I_BcoCredito) BEGIN  
  SET @B_Correct = CASE WHEN EXISTS(SELECT B.I_PagoBancoID FROM dbo.TR_PagoBanco b  
   WHERE b.B_Anulado = 0 AND b.I_TipoPagoID = 134 AND   
    b.I_EntidadFinanID = @I_BcoCredito AND b.C_CodOperacion = @C_CodOperacion AND  
    DATEDIFF(HOUR, b.D_FecPago, @D_FecPago) = 0) THEN 0 ELSE 1 END  
 END  
END  
GO