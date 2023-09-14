USE BD_OCEF_CtasPorCobrar
GO


ALTER VIEW [dbo].[VW_MatriculaAlumno]  
AS  
SELECT   
	 m.I_MatAluID, a.C_CodAlu, a.C_RcCod, a.T_Nombre, a.T_ApePaterno, ISNULL(a.T_ApeMaterno, '') AS T_ApeMaterno, a.N_Grado, m.I_Anio, m.I_Periodo,
	 a.C_CodFac, a.T_FacDesc, a.C_CodEsc, a.T_EscDesc, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_Habilitado, cat.T_OpcionCod as C_Periodo, cat.T_OpcionDesc as T_Periodo,
	 a.T_DenomProg, a.C_CodModIng, A.T_ModIngDesc, CASE WHEN nv.I_AluMultaID IS NULL THEN 0 ELSE 1 END B_TieneMultaPorNoVotar, a.I_DependenciaID
FROM TC_MatriculaAlumno m
INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRc
LEFT JOIN dbo.TC_CatalogoOpcion cat ON cat.I_OpcionID = m.I_Periodo
LEFT JOIN dbo.TC_AlumnoMultaNoVotar nv ON nv.B_Eliminado = 0 and nv.C_CodAlu = m.C_CodAlu and nv.C_CodRc = m.C_CodRc and nv.I_Periodo = m.I_Periodo and nv.I_Anio = m.I_Anio
WHERE m.B_Habilitado = 1 AND m.B_Eliminado = 0
GO



DROP VIEW [dbo].[VW_CuotasPago_X_Ciclo]
GO



DROP VIEW [dbo].[VW_CuotasPago_General]
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
		@CondicionCorrecto INT = 131,--CONDICI�N: PAGO CORRECTO
		@Extornado INT = 132,--CONDICI�N: EXTORNO
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

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'No existe el c�digo de tasa.' WHERE id = @I_FilaActual;
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

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Existe m�s de una cuenta bancaria para este servicio y tasa.' WHERE id = @I_FilaActual;
			END
		END
    
		IF  (@B_ExisteError = 0) BEGIN
			EXEC USP_S_ValidarCodOperacionTasa @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT;
    
			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1;
        
				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'El c�digo de operaci�n "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual;
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



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_S_ListarCuotasPagos_X_Periodo]
@C_CodAlu VARCHAR(10),
@I_Anio INT,
@I_PeriodoID INT
AS
/*
EXEC USP_S_ListarCuotasPagos_X_Periodo '2016029912',2022, 19
GO
*/
BEGIN
	SET NOCOUNT ON;

	SELECT 
		mat.C_CodAlu,
		mat.T_ApePaterno,
		mat.T_ApeMaterno,
		mat.T_Nombre,
		mat.C_RcCod,
		mat.T_DenomProg, 
		pro.T_ProcesoDesc,
		mat.I_Anio,
		per.T_OpcionDesc AS T_Periodo,
		cab.D_FecVencto,
		cab.B_Pagado,
		cab.I_MontoOblig,
		null AS D_FecPago,
		'' as C_CodOperacion, 
		'' as C_NumeroCuenta, 
		'' as T_EntidadDesc
	FROM dbo.VW_MatriculaAlumno mat
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID
	INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo  
	WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND
		mat.C_CodAlu = @C_CodAlu AND mat.I_Anio = @I_Anio AND mat.I_Periodo = @I_PeriodoID AND pro.I_Prioridad = 1
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_S_ListarIngresos_X_CuotasPagos]
@C_CodAlu VARCHAR(10),
@I_Anio INT,
@I_PeriodoID INT
AS
/*
EXEC USP_S_ListarIngresos_X_CuotasPagos '2016029912',2022, 19
GO
*/
BEGIN
	SET NOCOUNT ON;

	SELECT
		cab.I_ObligacionAluID, 
		pagban.I_MontoPago + pagban.I_InteresMora AS I_MontoPago,
		pagban.D_FecPago,
		pagban.C_CodOperacion,
		cta.C_NumeroCuenta,
		ef.T_EntidadDesc
	FROM dbo.TC_MatriculaAlumno mat
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID
	INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID
	INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID
	INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
	WHERE mat.B_Habilitado = 1 AND mat.B_Eliminado = 0 AND
		cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND
		det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND
		pagpro.B_Anulado = 0 AND pagban.B_Anulado = 0 AND
		mat.C_CodAlu = @C_CodAlu AND mat.I_Anio = @I_Anio AND mat.I_Periodo = @I_PeriodoID AND pro.I_Prioridad = 1
	GROUP BY cab.I_ObligacionAluID, pagban.I_MontoPago + pagban.I_InteresMora, pagban.D_FecPago, pagban.C_CodOperacion, cta.C_NumeroCuenta, ef.T_EntidadDesc
	ORDER BY pagban.D_FecPago
END
GO


 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_U_ActualizarMontoObligaciones]  
@I_ObligacionAluDetID INT,  
@I_Monto decimal(15, 2),  
@I_TipoDocumento INT,  
@T_DescDocumento VARCHAR(250),  
@CurrentUserId INT,  
@B_Result BIT OUTPUT,  
@T_Message NVARCHAR(4000) OUTPUT   
AS
/*
DECLARE @B_Result bit, @T_Message nvarchar(4000)  
  
EXEC USP_U_ActualizarMontoObligaciones  
	@I_ObligacionAluDetID = 1,  
	@I_Monto = 10,  
	@I_TipoDocumento = 1,  
	@T_DescDocumento = 'r.r. xxxx-2-21 del 01/01/2025',  
	@CurrentUserId = 1,  
	@B_Result = @B_Result output,  
	@T_Message = @T_Message output  
  
SELECT @B_Result as B_Result, @T_Message as T_Message  
GO
*/
BEGIN  
	SET NOCOUNT ON;

	DECLARE @I_ObligacionAluID INT,  
		@I_MontoOblig DECIMAL(15, 2),  
		@I_MontoObligPagado DECIMAL(15, 2),
		@B_Pagado BIT,  
		@CurrentDate datetime = getdate()  
   
	SET @I_ObligacionAluID = (SELECT I_ObligacionAluID FROM TR_ObligacionAluDet   
		WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID AND B_Habilitado = 1 AND B_Eliminado = 0)  
   
	IF (@I_ObligacionAluID IS NOT NULL)  
	BEGIN  
    
		SET @B_Pagado = (SELECT B_Pagado FROM TR_ObligacionAluDet   
			WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID AND B_Habilitado = 1 AND B_Eliminado = 0)  
  
		IF (@B_Pagado = 0)
		BEGIN  
  
			BEGIN TRAN  
			BEGIN TRY  
				UPDATE TR_ObligacionAluDet SET  
					I_Monto = @I_Monto,  
					I_TipoDocumento = @I_TipoDocumento,  
					T_DescDocumento = @T_DescDocumento,  
					I_UsuarioMod = @CurrentUserId,  
					D_FecMod = @CurrentDate  
				WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID  
  
				SET @I_MontoOblig = (SELECT SUM(d.I_Monto) from TR_ObligacionAluDet d  
					WHERE d.I_ObligacionAluID = @I_ObligacionAluID and d.B_Habilitado = 1 and d.B_Eliminado = 0 AND d.B_Mora = 0)  

				SET @I_MontoObligPagado = (SELECT SUM(pro.I_MontoPagado) FROM dbo.TR_ObligacionAluDet d
					INNER JOIN dbo.TRI_PagoProcesadoUnfv pro ON pro.I_ObligacionAluDetID = d.I_ObligacionAluDetID
					WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND d.B_Mora = 0 AND pro.B_Anulado = 0 AND d.I_ObligacionAluID = @I_ObligacionAluID)

				IF (@I_MontoOblig = @I_MontoObligPagado) BEGIN
					UPDATE TR_ObligacionAluCab SET   
						I_MontoOblig = @I_MontoOblig,  
						B_Pagado = 1,
						I_UsuarioMod = @CurrentUserId,  
						D_FecMod = @CurrentDate 
					WHERE I_ObligacionAluID = @I_ObligacionAluID

					UPDATE TR_ObligacionAluDet SET 
						B_Pagado = 1,
						I_UsuarioMod = @CurrentUserId,  
						D_FecMod = @CurrentDate 
					WHERE I_ObligacionAluID = @I_ObligacionAluID AND B_Habilitado = 1  AND B_Eliminado = 0 AND B_Pagado = 0
				END
				ELSE BEGIN
					UPDATE TR_ObligacionAluCab SET   
						I_MontoOblig = @I_MontoOblig,  
						I_UsuarioMod = @CurrentUserId,  
						D_FecMod = @CurrentDate  
					WHERE I_ObligacionAluID = @I_ObligacionAluID
				END
     
				COMMIT TRAN  
				SET @B_Result = 1  
				SET @T_Message = 'Actualizaci�n correcta.'  
			END TRY  
			BEGIN CATCH  
				ROLLBACK TRAN  
				SET @B_Result = 0  
				SET @T_Message = ERROR_MESSAGE()  
			END CATCH
		END  
		ELSE
		BEGIN  
			SET @B_Result = 0  
			SET @T_Message = 'La obligaci�n ya ha sido pagada.'  
		END  
	END  
	ELSE 
	BEGIN  
		SET @B_Result = 0  
		SET @T_Message = 'La obligaci�n seleccionada no existe.'  
	END
END  
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE USP_S_ObtenerCuotaPago
@I_ObligacionAluID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		cab.I_ObligacionAluID,
		mat.C_CodAlu,
		mat.C_RcCod,
		mat.T_Nombre,
		mat.T_ApePaterno,
		mat.T_ApeMaterno,
		mat.I_Anio,
		mat.I_Periodo,
		per.T_OpcionCod AS C_Periodo,
		per.T_OpcionDesc AS T_Periodo,
		pro.I_ProcesoID,
		pro.T_ProcesoDesc,
		cab.D_FecVencto,
		pro.I_Prioridad,
		pro.N_CodBanco,
		cab.I_MontoOblig,
		ISNULL(
		(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID 
		WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual,
		ISNULL(
		(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID
		WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0 AND det.B_Mora = 0), 0) AS I_MontoPagadoSinMora,
		cab.B_Pagado,
		cab.D_FecCre
	FROM dbo.VW_MatriculaAlumno mat
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
	INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo
	WHERE cab.I_ObligacionAluID = @I_ObligacionAluID
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE USP_S_ListarCuotasPagos_X_Alumno
@I_Anio INT,
@I_Periodo INT,
@C_CodAlu VARCHAR(20),
@C_RcCod VARCHAR(3)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		ROW_NUMBER() OVER(PARTITION BY mat.I_Anio, mat.I_Periodo, mat.C_RcCod, mat.C_CodAlu ORDER BY pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
		cab.I_ObligacionAluID,
		mat.C_CodAlu,
		mat.C_RcCod,
		mat.T_Nombre,
		mat.T_ApePaterno,
		mat.T_ApeMaterno,
		mat.I_Anio,
		mat.I_Periodo,
		per.T_OpcionCod AS C_Periodo,
		per.T_OpcionDesc AS T_Periodo,
		pro.I_ProcesoID,
		pro.T_ProcesoDesc,
		cab.D_FecVencto,
		pro.I_Prioridad,
		pro.N_CodBanco,
		cab.I_MontoOblig,
		cab.B_Pagado,
		cab.D_FecCre,
		ISNULL(
		(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID 
		WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual,
		ISNULL(
		(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID
	WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0 AND det.B_Mora = 0), 0) AS I_MontoPagadoSinMora
	FROM dbo.VW_MatriculaAlumno mat
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
	INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo
	WHERE mat.I_Anio = @I_Anio AND mat.I_Periodo = @I_Periodo AND mat.C_CodAlu = @C_CodAlu AND mat.C_RcCod = @C_RcCod;
END
GO
