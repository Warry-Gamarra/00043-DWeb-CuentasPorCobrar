USE BD_OCEF_CtasPorCobrar
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataPago') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
		DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]

	DROP TYPE [dbo].[type_dataPago]
END
GO

CREATE TYPE [dbo].[type_dataPago] AS TABLE(
	--Datos de pago
	C_CodOperacion		varchar(50),
	T_NomDepositante	varchar(200),
	C_Referencia		varchar(50),
	D_FecPago			datetime,
	I_Cantidad			int,
	C_Moneda			varchar(3),
	I_MontoPago			decimal(15,2),
	I_InteresMora		decimal(15,2),
	T_LugarPago			varchar(250),
	--Identificar obligaciones
	C_CodAlu			varchar(20),
	C_CodRc				varchar(3),
	I_ProcesoID			int,
	D_FecVencto			datetime,
	I_EntidadFinanID	int,
	I_CtaDepositoID		int,
	T_InformacionAdicional varchar(250),
	T_ProcesoDesc varchar(250),
	I_CondicionPagoID	int,
	T_Observacion		varchar(250)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
(
	 @Tbl_Pagos	[dbo].[type_dataPago]	READONLY
	,@Observacion	varchar(250)
	,@D_FecRegistro datetime
	,@UserID		int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Tmp_PagoObligacion TABLE (
		id INT IDENTITY(1,1),
		I_ProcesoID			int NULL,
		I_ObligacionAluID	int NULL,
		C_CodOperacion		varchar(50),
		C_CodDepositante	varchar(20),
		T_NomDepositante	varchar(200),
		C_Referencia		varchar(50),
		D_FecPago			datetime,
		D_FecVencto			datetime,
		D_FecVenctoBD		datetime,
		I_Cantidad			int,
		C_Moneda			varchar(3),
		I_MontoOblig		decimal(15,2) NULL,
		I_MontoPago			decimal(15,2),
		I_InteresMora		decimal(15,2),
		T_LugarPago			varchar(250),
		I_EntidadFinanID	int,
		I_CtaDepositoID		int,
		B_Pagado			bit NULL,
		B_Success			bit,
		T_ErrorMessage		varchar(250),
		T_InformacionAdicional		varchar(250),
		T_ProcesoDesc		varchar(250),
		I_CondicionPagoID	int,
		T_Observacion		varchar(250)
	);

	DECLARE @Tmp_DetalleObligacion TABLE(
		id INT,
		I_ObligacionAluDetID int,
		I_MontoDet			decimal(15,2),
		I_MontoPagadoDet	decimal(15,2)
	);

	WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto, B_Pagado, I_MontoOblig)
	AS 
	(
		SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto, cab.B_Pagado, cab.I_MontoOblig
		FROM dbo.TC_MatriculaAlumno m
		LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID AND cab.B_Eliminado = 0
		WHERE m.B_Eliminado = 0
	)
	INSERT @Tmp_PagoObligacion(I_ProcesoID, I_ObligacionAluID, C_CodOperacion, C_CodDepositante, T_NomDepositante, 
		C_Referencia, D_FecPago, D_FecVencto, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, I_InteresMora, T_LugarPago, I_EntidadFinanID, I_CtaDepositoID, B_Pagado,
		T_InformacionAdicional, T_ProcesoDesc, D_FecVenctoBD, I_CondicionPagoID, T_Observacion)
	
	SELECT m.I_ProcesoID, m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,
		p.C_Referencia, p.D_FecPago, p.D_FecVencto, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.I_EntidadFinanID, I_CtaDepositoID, m.B_Pagado,
		p.T_InformacionAdicional, p.T_ProcesoDesc, m.D_FecVencto, p.I_CondicionPagoID, p.T_Observacion

	FROM @Tbl_Pagos p
	LEFT JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND 
		m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0

	DECLARE @I_FilaActual		int = 1,
			@I_CantRegistros	int = (select count(id) from @Tmp_PagoObligacion),
			@I_ProcesoID		int,
			@I_ObligacionAluID	int,
			--PAGO EN BANCO
			@I_PagoBancoID		int,			
			@C_CodOperacion		varchar(50),
			@C_CodDepositante	varchar(20),
			@T_NomDepositante	varchar(200),
			@C_Referencia		varchar(50),
			@D_FecPago			datetime,
			@I_Cantidad			int,
			@C_Moneda			varchar(3),
			@I_MontoPago		decimal(15,2),
			@I_InteresMora		decimal(15,2),
			@T_LugarPago		varchar(250),
			@I_EntidadFinanID	int,
			@I_CtaDepositoID	int,
			@T_InformacionAdicional	varchar(250),
			@I_CondicionPagoID	int,
			@T_Observacion		varchar(250),
			--PAGO DETALLE
			@I_FilaActualDet	int,
			@I_CantRegistrosDet	int,
			@I_ObligacionAluDetID	int,			
			@I_MontoOligacionDet	decimal(15,2),
			@I_MontoPagadoActual	decimal(15,2),
			@I_SaldoPendiente	decimal(15,2),
			@I_MontoAPagar		decimal(15,2),
			@I_NuevoSaldoPend	decimal(15,2),
			@I_PagoDemas		decimal(15,2),
			@B_PagoDemas		bit,
			@B_Pagado			bit,
			--MORA
			@I_ConcPagID		int,
			@D_FecVencto		datetime,
			--CONTROL ERRORES
			@D_FecVenctoBD		datetime,
			@B_ExisteError		bit,
			@B_CodOpeCorrecto	bit,
			@B_ObligPagada		bit,
			--Constantes
			@CondicionCorrecto	int = 131,--PAGO CORRECTO
			@CondicionExtorno	int = 132,--PAGO EXTORNADO
			@PagoTipoObligacion	int = 133--OBLIGACION

	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN
		
		SET @B_ExisteError = 0

		SELECT  @I_ProcesoID = I_ProcesoID,
				@I_ObligacionAluID = I_ObligacionAluID, 
				@C_CodOperacion = C_CodOperacion, 
				@C_CodDepositante = C_CodDepositante, 
				@T_NomDepositante = T_NomDepositante, 
				@C_Referencia = C_Referencia, 
				@D_FecPago = D_FecPago, 
				@D_FecVencto = D_FecVencto,
				@I_Cantidad = I_Cantidad,
				@C_Moneda = C_Moneda, 
				@I_MontoPago = I_MontoPago,
				@I_InteresMora = I_InteresMora,
				@T_LugarPago= T_LugarPago,
				@I_EntidadFinanID = I_EntidadFinanID,
				@I_CtaDepositoID = I_CtaDepositoID,
				@B_ObligPagada = B_Pagado,
				@T_InformacionAdicional = T_InformacionAdicional,
				@D_FecVenctoBD = D_FecVenctoBD,
				@I_CondicionPagoID = I_CondicionPagoID,
				@T_Observacion = CASE WHEN (I_CondicionPagoID = @CondicionCorrecto) THEN @Observacion ELSE T_Observacion END
			FROM @Tmp_PagoObligacion WHERE id = @I_FilaActual

		IF (@I_ObligacionAluID IS NULL) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe obligaciones para este alumno.' WHERE id = @I_FilaActual
		END

		IF (@B_ExisteError = 0) AND NOT(@I_CondicionPagoID = @CondicionExtorno) AND (@B_ObligPagada = 1) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'Esta obligación ya ha sido pagada con anterioridad.' WHERE id = @I_FilaActual
		END

		IF  (@B_ExisteError = 0) BEGIN
			EXEC dbo.USP_S_ValidarCodOperacionObligacion @C_CodOperacion, @C_CodDepositante, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT

			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1
				
				UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual
			END
		END

		IF (@B_ExisteError = 0) AND NOT(@I_CondicionPagoID = @CondicionExtorno) AND (@I_InteresMora > 0) AND
			NOT EXISTS(SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1) BEGIN

			SET @B_ExisteError = 1
				
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe un concepto para guardar el Interés moratorio.' WHERE id = @I_FilaActual
		END
		

		IF (@B_ExisteError = 0) AND (@I_CtaDepositoID IS NULL) BEGIN
			SET @I_CtaDepositoID = (SELECT cta.I_CtaDepositoID FROM dbo.TI_CtaDepo_Proceso cta
				INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cta.I_CtaDepositoID
				WHERE cta.B_Habilitado = 1 AND cta.B_Eliminado = 0 AND 
					cta.I_ProcesoID = @I_ProcesoID and c.I_EntidadFinanID = @I_EntidadFinanID)

			IF (@I_CtaDepositoID IS NULL) BEGIN
				SET @B_ExisteError = 1
				
				UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe una Cuenta asignada para registrar la obligación.' WHERE id = @I_FilaActual
			END
		END

		IF (@B_ExisteError = 0) BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad, 
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad, 
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @T_Observacion,
					@T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoObligacion, @I_CtaDepositoID, @I_InteresMora)

				SET @I_PagoBancoID = SCOPE_IDENTITY()

				IF (@I_CondicionPagoID = @CondicionCorrecto) BEGIN

					DELETE FROM @Tmp_DetalleObligacion

					INSERT @Tmp_DetalleObligacion(id, I_ObligacionAluDetID, I_MontoDet, I_MontoPagadoDet)
					SELECT ROW_NUMBER() OVER (ORDER BY det.I_Monto ASC), det.I_ObligacionAluDetID, det.I_Monto, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoPagado 
					FROM dbo.TR_ObligacionAluDet det
					LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND p.B_Anulado = 0
					WHERE det.I_ObligacionAluID = @I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 0 AND det.B_Pagado = 0
					GROUP BY det.I_ObligacionAluDetID, det.I_Monto
					ORDER BY det.I_Monto ASC

					SET @I_FilaActualDet = 1
					SET @I_CantRegistrosDet = (SELECT COUNT(*) FROM @Tmp_DetalleObligacion)

					WHILE (@I_FilaActualDet <= @I_CantRegistrosDet AND @I_MontoPago > 0) BEGIN

						SELECT
							@I_ObligacionAluDetID = I_ObligacionAluDetID, 
							@I_MontoOligacionDet = I_MontoDet, 
							@I_MontoPagadoActual = I_MontoPagadoDet 
						FROM @Tmp_DetalleObligacion WHERE id = @I_FilaActualDet

						SET @I_SaldoPendiente = @I_MontoOligacionDet - @I_MontoPagadoActual

						EXEC dbo.USP_AsignarPagoDetalleObligacion
							@I_FilaActualDet = @I_FilaActualDet,
							@I_CantRegistrosDet = @I_CantRegistrosDet,
							@I_SaldoPendiente  = @I_SaldoPendiente,
							@I_MontoPago = @I_MontoPago OUTPUT,
							@B_Pagado = @B_Pagado OUTPUT,
							@I_MontoAPagar = @I_MontoAPagar OUTPUT,
							@I_NuevoSaldoPend = @I_NuevoSaldoPend OUTPUT,
							@I_PagoDemas = @I_PagoDemas OUTPUT,
							@B_PagoDemas = @B_PagoDemas OUTPUT
				
						INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,
							D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
						VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_MontoAPagar, @I_NuevoSaldoPend, @I_PagoDemas, @B_PagoDemas,
							@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)

						IF (@B_Pagado = 1) BEGIN
							UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
							WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID
						END

						SET @I_FilaActualDet = @I_FilaActualDet + 1
					END
				
					IF NOT EXISTS (SELECT d.I_ObligacionAluID FROM dbo.TR_ObligacionAluDet d 
						WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND d.B_Mora = 0 AND d.B_Pagado = 0)
					BEGIN
						UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = 1, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
						WHERE I_ObligacionAluID = @I_ObligacionAluID
					END

					IF (@I_InteresMora > 0) BEGIN
						SET @I_ConcPagID = (SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1)

						INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
						VALUES (@I_ObligacionAluID, @I_ConcPagID, @I_InteresMora, 1, @D_FecVencto, 1, 0, @UserID, @D_FecRegistro, 1)

						SET @I_ObligacionAluDetID = SCOPE_IDENTITY()

						INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas, 
							D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
						VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_InteresMora, 0, 0, 0,@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)
					END

					UPDATE @Tmp_PagoObligacion SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual
				
				END ELSE BEGIN
					UPDATE @Tmp_PagoObligacion SET B_Success = 1, T_ErrorMessage = @T_Observacion WHERE id = @I_FilaActual
				END

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION

				UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual
			END CATCH
		END

		SET @I_FilaActual = @I_FilaActual + 1
	END

	SELECT * FROM @Tmp_PagoObligacion
END
GO
