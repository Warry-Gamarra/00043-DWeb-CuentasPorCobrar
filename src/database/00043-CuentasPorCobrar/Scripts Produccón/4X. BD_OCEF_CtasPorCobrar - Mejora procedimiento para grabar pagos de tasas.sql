USE BD_OCEF_CtasPorCobrar
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
@Tbl_Pagos [dbo].[type_dataPagoTasa] READONLY,
@Observacion VARCHAR(250),
@D_FecRegistro DATETIME,
@UserID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Tmp_PagoTasas TABLE (
		id INT identity(1,1),
		I_TasaUnfvID INT,
		I_MontoTasa DECIMAL(15,2),
		C_CodDepositante VARCHAR(20),
		T_NomDepositante VARCHAR(200),
		C_CodTasa VARCHAR(20),
		T_TasaDesc VARCHAR(250),
		C_CodOperacion VARCHAR(50),
		C_Referencia VARCHAR(50),
		I_EntidadFinanID INT,
		I_CtaDepositoID INT,
		D_FecPago DATETIME,
		I_Cantidad INT,
		C_Moneda VARCHAR(3),
		I_MontoPago DECIMAL(15,2),
		I_InteresMora DECIMAL(15,2),
		T_LugarPago VARCHAR(250),
		T_InformacionAdicional VARCHAR(250),
		B_Success BIT,
		T_ErrorMessage VARCHAR(250),
		C_CodigoInterno VARCHAR(250),
		T_SourceFileName VARCHAR(250),
		C_Extorno VARCHAR(1),
		C_CodServicio VARCHAR(20)
	);

	INSERT @Tmp_PagoTasas(I_TasaUnfvID, I_MontoTasa, C_CodDepositante, T_NomDepositante, C_CodTasa,
		T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, D_FecPago,
		I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional,
		C_CodigoInterno, T_SourceFileName, C_Extorno, C_CodServicio)
	SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,
		CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,
		p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID, p.I_CtaDepositoID, p.D_FecPago,
		p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional,
		p.C_CodigoInterno, p.T_SourceFileName, C_Extorno, p.C_CodServicio
	FROM @Tbl_Pagos p
	LEFT JOIN dbo.TI_TasaUnfv t ON t.C_CodTasa = p.C_CodTasa AND t.B_Habilitado = 1 AND t.B_Eliminado = 0;
    
	DECLARE @I_FilaActual  INT = 1,    
		@I_CantRegistros INT = (SELECT COUNT(id) FROM @Tmp_PagoTasas),    
		@I_SaldoAPagar  DECIMAL(15,2),    
		@I_PagoDemas  DECIMAL(15,2),    
		@B_PagoDemas  BIT,    
		@I_CantCuentasBancarias INT,
		-----------------------------------------------------------    
		@I_PagoBancoID  INT,    
		@I_TasaUnfvID  INT,    
		@I_MontoTasa  DECIMAL(15,2),    
		@C_CodDepositante VARCHAR(20),    
		@T_NomDepositante VARCHAR(200),    
		@C_CodTasa   VARCHAR(20),    
		@T_TasaDesc   VARCHAR(250),    
		@C_CodOperacion  VARCHAR(50),    
		@C_Referencia  VARCHAR(50),    
		@I_EntidadFinanID INT,    
		@I_CtaDepositoID INT,    
		@D_FecPago   DATETIME,    
		@I_Cantidad   INT,    
		@C_Moneda   VARCHAR(3),    
		@I_MontoPago  DECIMAL(15,2),    
		@I_InteresMora  DECIMAL(15,2),    
		@T_LugarPago  VARCHAR(250),     
		@T_InformacionAdicional VARCHAR(250),    
		@C_CodigoInterno VARCHAR(250),  
		@B_ExisteError  BIT,    
		@B_CodOpeCorrecto BIT,    
		@C_Extorno VARCHAR(1),
		@C_CodServicio VARCHAR(20),
		@I_CondicionPagoID INT,
		--Constantes    
		@CondicionCorrecto INT = 131,--CONDICIÓN: PAGO CORRECTO
		@Extornado INT = 132,--CONDICIÓN: EXTORNO
		@PagoTipoTasa  INT = 134;--TIPO PAGO: TASA

	WHILE (@I_FilaActual <= @I_CantRegistros)
	BEGIN    
      
		SET @B_ExisteError = 0;
    
		SELECT  
			@I_TasaUnfvID = I_TasaUnfvID,
			@I_MontoTasa = I_MontoTasa,
			@C_CodDepositante = C_CodDepositante,
			@T_NomDepositante = T_NomDepositante,
			@C_CodTasa = C_CodTasa,
			@T_TasaDesc = T_TasaDesc,
			@C_CodOperacion = C_CodOperacion,
			@C_Referencia = C_Referencia,
			@I_EntidadFinanID = I_EntidadFinanID,
			@I_CtaDepositoID = I_CtaDepositoID,
			@D_FecPago = D_FecPago,
			@I_Cantidad = I_Cantidad,
			@C_Moneda = C_Moneda,
			@I_MontoPago = I_MontoPago,
			@I_InteresMora = I_InteresMora,
			@T_LugarPago = T_LugarPago,
			@T_InformacionAdicional = T_InformacionAdicional,
			@C_CodigoInterno = C_CodigoInterno,
			@C_Extorno = C_Extorno,
			@C_CodServicio = C_CodServicio
		FROM @Tmp_PagoTasas WHERE id = @I_FilaActual    
    
		IF (@I_TasaUnfvID IS NULL) BEGIN
			IF (@I_EntidadFinanID = 2) BEGIN
				SELECT @I_TasaUnfvID = t.I_TasaUnfvID, @I_CtaDepositoID = t.I_CtaDepositoID 
				FROM VW_PagoTasas_X_Cuenta t
				WHERE t.C_CodTasa = '00000' AND t.I_EntidadFinanID = 2;
			END
			ELSE BEGIN
				SET @B_ExisteError = 1;

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'No existe el código de tasa.' WHERE id = @I_FilaActual;
			END
		END
    
		IF (@B_ExisteError = 0 AND @I_CtaDepositoID IS NULL) BEGIN
			SET @I_CantCuentasBancarias = (SELECT COUNT(I_CtaDepositoID) FROM VW_PagoTasas_X_Cuenta 
				WHERE C_CodTasa = @C_CodTasa AND C_CodServicio = @C_CodServicio AND I_EntidadFinanID = @I_EntidadFinanID);

			IF (@I_CantCuentasBancarias = 0) BEGIN
				SET @B_ExisteError = 1;

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Esta tasa no tiene asignado una cuenta.' WHERE id = @I_FilaActual;
			END

			IF (@I_CantCuentasBancarias = 1) BEGIN
				SET @I_CtaDepositoID = (SELECT I_CtaDepositoID FROM VW_PagoTasas_X_Cuenta
					WHERE C_CodTasa = @C_CodTasa AND C_CodServicio = @C_CodServicio AND I_EntidadFinanID = @I_EntidadFinanID);
			END

			IF (@I_CantCuentasBancarias > 1) BEGIN
				SET @B_ExisteError = 1;

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Existe más de una cuenta bancaria para este servicio y tasa.' WHERE id = @I_FilaActual;
			END
		END
    
		IF  (@B_ExisteError = 0) BEGIN
			EXEC USP_S_ValidarCodOperacionTasa @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT;
    
			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1;
        
				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual;
			END
		END
    
		IF (@B_ExisteError = 0)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
  
				SET @I_CondicionPagoID = (CASE WHEN @C_Extorno = 'E' THEN @Extornado ELSE @CondicionCorrecto END);
  
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,
					@T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoTasa, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno);
    
				SET @I_PagoBancoID = SCOPE_IDENTITY();
  
				IF (@I_CondicionPagoID = @CondicionCorrecto)
				BEGIN
					--Pago menor    
					SET @I_SaldoAPagar = @I_MontoTasa - @I_MontoPago;
     
					SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END;
    
					--Pago excedente    
					SET @I_PagoDemas = @I_MontoPago - @I_MontoTasa;
         
					SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END;
    
					SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END;
    
					INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_TasaUnfvID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,
						B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
					VALUES(@I_PagoBancoID, @I_TasaUnfvID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas,
						@B_PagoDemas, @D_FecRegistro, @UserID, 0, @I_CtaDepositoID);
  
					UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual;
				END
				ELSE BEGIN
					UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto (Extorno).' WHERE id = @I_FilaActual;
				END

				COMMIT TRANSACTION;
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION;
    
				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual;
			END CATCH
		END
    
		SET @I_FilaActual = @I_FilaActual + 1;
	END    
    
	SELECT * FROM @Tmp_PagoTasas;
END  
GO
