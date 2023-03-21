USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas')
	DROP VIEW [dbo].[VW_PagoTasas]
GO

CREATE VIEW [dbo].[VW_PagoTasas]    
AS    
 SELECT pag.I_PagoBancoID, tu.I_TasaUnfvID, pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc,     
  tu.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto,     
  pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre,  
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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarPagoTasa')
	DROP PROCEDURE [dbo].[USP_U_ActualizarPagoTasa]
GO

CREATE PROCEDURE USP_U_ActualizarPagoTasa
@I_PagoBancoID INT,
@C_CodDepositante VARCHAR(20),
@I_TasaUnfvId INT,
@T_Observacion VARCHAR(250),
@I_CurrentUserID INT,
@B_Result BIT OUTPUT,
@T_Message VARCHAR(250) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY
		IF (@T_Observacion IS NULL OR LEN(LTRIM(RTRIM(@T_Observacion))) = 0) BEGIN
			RAISERROR('El campo observación es obligatorio.', 11, 1);
		END

		IF (@C_CodDepositante IS NULL OR LEN(LTRIM(RTRIM(@C_CodDepositante))) = 0) BEGIN
			RAISERROR('El campo Código de Depositante es obligatorio.', 11, 1);
		END

		DECLARE @D_FecMod DATETIME = GETDATE()

		DECLARE @I_MontoTasa DECIMAL(15,2) = (SELECT M_Monto FROM dbo.TI_TasaUnfv WHERE I_TasaUnfvID = @I_TasaUnfvId),
				@I_MontoPago DECIMAL(15,2) = (SELECT I_MontoPago FROM dbo.TR_PagoBanco WHERE I_PagoBancoID = @I_PagoBancoID),
				@I_SaldoAPagar DECIMAL(15,2),
				@I_PagoDemas DECIMAL(15,2),
				@B_PagoDemas BIT

		--Pago menor
		SET @I_SaldoAPagar = @I_MontoTasa - @I_MontoPago

		SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END  

		--Pago excedente
		SET @I_PagoDemas = @I_MontoPago - @I_MontoTasa  

		SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END  
		
		SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END  

		UPDATE dbo.TR_PagoBanco SET 
			C_CodDepositante = @C_CodDepositante,
			T_Observacion = @T_Observacion,
			I_UsuarioMod = @I_CurrentUserID,
			D_FecMod = @D_FecMod
		WHERE I_PagoBancoID = @I_PagoBancoID

		UPDATE dbo.TRI_PagoProcesadoUnfv SET
			I_TasaUnfvID = @I_TasaUnfvId,
			I_SaldoAPagar = @I_SaldoAPagar,
			I_PagoDemas = @I_PagoDemas,
			B_PagoDemas = @B_PagoDemas,
			I_UsuarioMod = @I_CurrentUserID,
			D_FecMod = @D_FecMod
		WHERE I_PagoBancoID = @I_PagoBancoID

		COMMIT TRAN

		SET @B_Result = 1
		SET @T_Message = 'Actualización correcta.'
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE()
	END CATCH
END
GO
