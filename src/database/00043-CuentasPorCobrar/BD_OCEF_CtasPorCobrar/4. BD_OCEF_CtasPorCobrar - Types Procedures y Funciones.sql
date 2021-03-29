USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCuentaCorreo')
	DROP PROCEDURE [dbo].[USP_I_GrabarCuentaCorreo]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarCuentaCorreo]
	 @I_CorreoID	int
	,@T_DireccionCorreo	varchar(50)
	,@T_PasswordCorreo	varchar(500)
	,@T_Seguridad		varchar(10)
	,@T_HostName		varchar(50)
	,@I_Puerto			smallint
	,@D_FecUpdate		datetime

	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TS_CorreoAplicacion  
			SET	B_Habilitado = 0
				, D_FecUpdate = @D_FecUpdate
			
		INSERT INTO TS_CorreoAplicacion (T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, B_Habilitado, D_FecUpdate, B_Eliminado)
								VALUES	 (@T_DireccionCorreo, @T_PasswordCorreo, @T_Seguridad, @T_HostName, @I_Puerto, 1, @D_FecUpdate, 0)
		

		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos de correo correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_GrabarCuentaCorreo')
	DROP PROCEDURE [dbo].[USP_U_GrabarCuentaCorreo]
GO

CREATE PROCEDURE [dbo].[USP_U_GrabarCuentaCorreo]
	 @I_CorreoID	int
	,@T_DireccionCorreo	varchar(50)
	,@T_PasswordCorreo	varchar(500)
	,@T_Seguridad		varchar(10)
	,@T_HostName		varchar(50)
	,@I_Puerto			smallint
	,@D_FecUpdate		datetime

	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TS_CorreoAplicacion 
		SET	T_DireccionCorreo = @T_DireccionCorreo
			, T_PasswordCorreo = @T_PasswordCorreo
			, T_Seguridad = @T_Seguridad
			, T_HostName = @T_HostName
			, I_Puerto = @I_Puerto
			, D_FecUpdate = @D_FecUpdate
		WHERE	I_CorreoID = @I_CorreoID
			
		
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos de correo correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoCuentaCorreo')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoCuentaCorreo]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoCuentaCorreo]
	 @I_CorreoID		int
	,@B_Habilitado		bit
	,@D_FecUpdate		datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		IF(@B_Habilitado = 1)
		BEGIN
			UPDATE	TS_CorreoAplicacion 
			SET		B_Habilitado = 0,
					D_FecUpdate = @D_FecUpdate
					WHERE	I_CorreoID <> @I_CorreoID
		END 

		UPDATE	TS_CorreoAplicacion 
		SET		B_Habilitado = @B_Habilitado,
				D_FecUpdate = @D_FecUpdate
		WHERE	I_CorreoID = @I_CorreoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos de correo correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_U_ActualizarEstadoUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoUsuario]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoUsuario]
	 @UserId			int
	,@B_Habilitado		bit
	,@D_FecActualiza	datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		UPDATE	TC_Usuario 
		   SET	B_Habilitado = @B_Habilitado,
				D_FecActualiza = @D_FecActualiza
		 WHERE	UserId = @UserId

	 	SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_CuentaDeposito_Habilitadas')
	DROP PROCEDURE dbo.USP_S_CuentaDeposito_Habilitadas
GO

CREATE PROCEDURE dbo.USP_S_CuentaDeposito_Habilitadas
@I_CatPagoID int
AS
BEGIN
	SET NOCOUNT ON;
	SELECT cd.I_CtaDepositoID, cd.T_DescCuenta, cd.C_NumeroCuenta, ef.I_EntidadFinanID, ef.T_EntidadDesc 
	FROM dbo.TC_CuentaDeposito_CategoriaPago cp
		INNER JOIN dbo.TC_CuentaDeposito cd ON cp.I_CtaDepositoID = cd.I_CtaDepositoID
		INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = cd.I_EntidadFinanID
	WHERE cp.B_Habilitado = 1 AND cp.B_Eliminado = 0 AND 
	cd.B_Habilitado = 1 AND cd.B_Eliminado = 0 AND
	ef.B_Habilitado = 1 AND ef.B_Eliminado = 0 AND
	cp.I_CatPagoID = @I_CatPagoID
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_Procesos')
	DROP PROCEDURE dbo.USP_S_Procesos
GO

CREATE PROCEDURE dbo.USP_S_Procesos
AS
BEGIN
	SET NOCOUNT ON;
	SELECT p.I_ProcesoID, cp.I_CatPagoID, cp.T_CatPagoDesc, T_OpcionDesc AS T_PeriodoDesc, I_Periodo, T_OpcionCod AS C_PeriodoCod, 
		   p.I_Anio, p.D_FecVencto, p.I_Prioridad, p.N_CodBanco, p.T_ProcesoDesc, cp.B_Obligacion
	FROM dbo.TC_Proceso p
		INNER JOIN dbo.TC_CategoriaPago cp ON p.I_CatPagoID = cp.I_CatPagoID
		LEFT JOIN dbo.TC_CatalogoOpcion co ON co.I_OpcionID = p.I_Periodo
	WHERE p.B_Eliminado = 0
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarProceso')
	DROP PROCEDURE dbo.USP_I_GrabarProceso
GO


CREATE PROCEDURE dbo.USP_I_GrabarProceso
	@I_CatPagoID int,
	@I_Anio smallint = null,
	@D_FecVencto datetime = null,
	@I_Prioridad tinyint = null,
	@I_Periodo int = null,
	@N_CodBanco varchar(10) = null,
	@T_ProcesoDesc varchar(250) = null,
	@I_UsuarioCre int,
	@I_ProcesoID int OUTPUT,
	@B_Result bit OUTPUT,
	@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
  	BEGIN TRY
		INSERT dbo.TC_Proceso(I_CatPagoID, I_Anio, D_FecVencto, T_ProcesoDesc, N_CodBanco, I_Prioridad, I_Periodo, B_Migrado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
		VALUES(@I_CatPagoID, @I_Anio, @D_FecVencto, @T_ProcesoDesc, @N_CodBanco, @I_Prioridad, @I_Periodo, 0, 1, 0, @I_UsuarioCre, getdate())
		
		SET @I_ProcesoID = SCOPE_IDENTITY()
		SET @B_Result = 1
		SET @T_Message = 'Inserción de datos correcta.'
	END TRY
	BEGIN CATCH
		SET @I_ProcesoID = 0
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarProceso')
	DROP PROCEDURE dbo.USP_U_ActualizarProceso
GO


CREATE PROCEDURE dbo.USP_U_ActualizarProceso
	@I_ProcesoID int,
	@I_CatPagoID int,
	@I_Anio smallint = null,
	@D_FecVencto datetime = null,
	@I_Prioridad tinyint = null,
	@N_CodBanco varchar(10) = null,
	@T_ProcesoDesc varchar(250) = null,
	@B_Habilitado bit,
	@I_UsuarioMod int,
	@B_Result bit OUTPUT,
	@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
  	BEGIN TRY
		UPDATE dbo.TC_Proceso SET
			I_CatPagoID = @I_CatPagoID, 
			I_Anio = @I_Anio, 
			D_FecVencto = @D_FecVencto, 
			I_Prioridad = @I_Prioridad,
			N_CodBanco = @N_CodBanco,
			T_ProcesoDesc = @T_ProcesoDesc,
			B_Habilitado = @B_Habilitado,
			I_UsuarioMod = @I_UsuarioMod,
			D_FecMod = getdate()
		WHERE I_ProcesoID = @I_ProcesoID
		
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCtaDeposito_Proceso')
	DROP PROCEDURE dbo.USP_I_GrabarCtaDeposito_Proceso
GO


CREATE PROCEDURE dbo.USP_I_GrabarCtaDeposito_Proceso
@I_CtaDepositoID int,
@I_ProcesoID int,
@I_UsuarioCre int,
@I_CtaDepoProID int OUTPUT,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT ON
  	BEGIN TRY
		INSERT dbo.TI_CtaDepo_Proceso(I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
		VALUES(@I_CtaDepositoID, @I_ProcesoID, 1, 0, @I_UsuarioCre, getdate())
		
		SET @I_CtaDepoProID = SCOPE_IDENTITY()

		SET @B_Result = 1
		SET @T_Message = 'Inserción de datos correcta.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarCtaDeposito_Proceso')
	DROP PROCEDURE dbo.USP_U_ActualizarCtaDeposito_Proceso
GO


CREATE PROCEDURE dbo.USP_U_ActualizarCtaDeposito_Proceso
@I_CtaDepoProID int,
@I_CtaDepositoID int,
@I_ProcesoID int,
@B_Habilitado bit,
@I_UsuarioMod int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT ON
  	BEGIN TRY
		UPDATE dbo.TI_CtaDepo_Proceso SET
		I_CtaDepositoID = @I_CtaDepositoID, 
		I_ProcesoID = @I_ProcesoID, 
		B_Habilitado = @B_Habilitado,
		I_UsuarioMod = @I_UsuarioMod,
		D_FecMod = getdate()
		WHERE I_CtaDepoProID = @I_CtaDepoProID
		
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_CtaDepo_Proceso')
	DROP PROCEDURE dbo.USP_S_CtaDepo_Proceso
GO


CREATE PROCEDURE dbo.USP_S_CtaDepo_Proceso
	@I_ProcesoID int
AS
BEGIN
	SET NOCOUNT ON
  	SELECT cp.I_CtaDepoProID, cp.I_CtaDepositoID, c.T_DescCuenta, cp.I_ProcesoID, cp.B_Habilitado, c.C_NumeroCuenta, c.I_EntidadFinanID, e.T_EntidadDesc 
	FROM dbo.TI_CtaDepo_Proceso cp
		INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cp.I_CtaDepositoID
		INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID = c.I_EntidadFinanID
	WHERE cp.B_Eliminado = 0 AND cp.I_ProcesoID = @I_ProcesoID
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ConceptoPago')
	DROP PROCEDURE dbo.USP_S_ConceptoPago
GO

CREATE PROCEDURE dbo.USP_S_ConceptoPago
	@I_ProcesoID int = null,
	@B_Obligacion int = null
AS
BEGIN
	SET NOCOUNT ON;
	SELECT c.I_ConcPagID, catg.T_CatPagoDesc, p.T_ProcesoDesc, ISNULL(c.T_ConceptoPagoDesc, cp.T_ConceptoDesc) as T_ConceptoDesc, c.I_Anio, 
			c.I_Periodo, c.M_Monto, c.M_MontoMinimo 
	FROM dbo.TI_ConceptoPago c
		INNER JOIN dbo.TC_Concepto cp ON cp.I_ConceptoID = c.I_ConceptoID
		INNER JOIN dbo.TC_Proceso p ON p.I_ProcesoID = c.I_ProcesoID
		INNER JOIN dbo.TC_CategoriaPago catg ON catg.I_CatPagoID = p.I_CatPagoID
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 
			AND (@I_ProcesoID IS NULL OR c.I_ProcesoID = @I_ProcesoID)
			AND (@B_Obligacion IS NULL OR catg.B_Obligacion = @B_Obligacion)
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarConceptoPago')
	DROP PROCEDURE dbo.USP_I_GrabarConceptoPago
GO

CREATE PROCEDURE dbo.USP_I_GrabarConceptoPago
@I_ProcesoID int,
@I_ConceptoID int,
@T_ConceptoPagoDesc varchar(250),
@B_Fraccionable bit = null,
@B_ConceptoGeneral bit = null,
@B_AgrupaConcepto bit = null,
@I_AlumnosDestino int = null,
@I_GradoDestino int = null,
@I_TipoObligacion int = null,
@T_Clasificador varchar(250) = null,
@C_CodTasa varchar(250) = null,
@B_Calculado bit = null,
@I_Calculado int = null,
@B_AnioPeriodo bit = null,
@I_Anio int = null,
@I_Periodo int = null,
@B_Especialidad bit = null,
@C_CodRc char(3) = null,
@B_Dependencia bit = null,
@C_DepCod int = null,
@B_GrupoCodRc bit = null,
@I_GrupoCodRc int = null,
@B_ModalidadIngreso bit = null,
@I_ModalidadIngresoID int = null,
@B_ConceptoAgrupa bit = null,
@I_ConceptoAgrupaID int = null,
@B_ConceptoAfecta bit = null,
@I_ConceptoAfectaID int = null,
@N_NroPagos int = null,
@B_Porcentaje bit = null,
@M_Monto decimal(10,4) = null,
@M_MontoMinimo decimal(10,4) = null,
@T_DescripcionLarga varchar(250) = null,
@T_Documento varchar(250) = null,
@I_UsuarioCre int,
@I_ConcPagID int OUTPUT,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
  	BEGIN TRY
		INSERT dbo.TI_ConceptoPago(I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, 
			I_AlumnosDestino, I_GradoDestino, I_TipoObligacion, T_Clasificador, C_CodTasa, B_Calculado, I_Calculado, 
			B_AnioPeriodo, I_Anio, I_Periodo, B_Especialidad, C_CodRc, B_Dependencia, C_DepCod, B_GrupoCodRc, I_GrupoCodRc, 
			B_ModalidadIngreso, I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, B_ConceptoAfecta, I_ConceptoAfectaID, 
			N_NroPagos, B_Porcentaje, M_Monto, M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Migrado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
		
		VALUES(@I_ProcesoID, @I_ConceptoID, @T_ConceptoPagoDesc, @B_Fraccionable, @B_ConceptoGeneral, @B_AgrupaConcepto, 
			@I_AlumnosDestino, @I_GradoDestino, @I_TipoObligacion, @T_Clasificador, @C_CodTasa, @B_Calculado, @I_Calculado, 
			@B_AnioPeriodo, @I_Anio, @I_Periodo, @B_Especialidad, @C_CodRc, @B_Dependencia, @C_DepCod, @B_GrupoCodRc, @I_GrupoCodRc,
			@B_ModalidadIngreso, @I_ModalidadIngresoID, @B_ConceptoAgrupa, @I_ConceptoAgrupaID, @B_ConceptoAfecta, @I_ConceptoAfectaID, 
			@N_NroPagos, @B_Porcentaje, @M_Monto, @M_MontoMinimo, @T_DescripcionLarga, @T_Documento, 0, 1, 0, @I_UsuarioCre, getdate())
		
		SET @I_ConcPagID = SCOPE_IDENTITY()
		SET @B_Result = 1
		SET @T_Message = 'Inserción de datos correcta.'
	END TRY
	BEGIN CATCH
		SET @I_ConcPagID = 0
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarConceptoPago')
	DROP PROCEDURE dbo.USP_U_ActualizarConceptoPago
GO

CREATE PROCEDURE dbo.USP_U_ActualizarConceptoPago
@I_ConcPagID int,
@I_ProcesoID int,
@I_ConceptoID int,
@T_ConceptoPagoDesc varchar(250),
@B_Fraccionable bit = null,
@B_ConceptoGeneral bit = null,
@B_AgrupaConcepto bit = null,
@I_AlumnosDestino int = null,
@I_GradoDestino int = null,
@I_TipoObligacion int = null,
@T_Clasificador varchar(250) = null,
@C_CodTasa varchar(250) = null,
@B_Calculado bit = null,
@I_Calculado int = null,
@B_AnioPeriodo bit = null,
@I_Anio int = null,
@I_Periodo int = null,
@B_Especialidad bit = null,
@C_CodRc char(3) = null,
@B_Dependencia bit = null,
@C_DepCod int = null,
@B_GrupoCodRc bit = null,
@I_GrupoCodRc int = null,
@B_ModalidadIngreso bit = null,
@I_ModalidadIngresoID int = null,
@B_ConceptoAgrupa bit = null,
@I_ConceptoAgrupaID int = null,
@B_ConceptoAfecta bit = null,
@I_ConceptoAfectaID int = null,
@N_NroPagos int = null,
@B_Porcentaje bit = null,
@M_Monto decimal(10,4) = null,
@M_MontoMinimo decimal(10,4) = null,
@T_DescripcionLarga varchar(250) = null,
@T_Documento varchar(250) = null,
@B_Habilitado bit,
@I_UsuarioMod int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
  	BEGIN TRY
		UPDATE dbo.TI_ConceptoPago SET
			I_ProcesoID = @I_ProcesoID,
			I_ConceptoID = @I_ConceptoID,
			T_ConceptoPagoDesc = @T_ConceptoPagoDesc,
			B_Fraccionable = @B_Fraccionable,
			B_ConceptoGeneral = @B_ConceptoGeneral,
			B_AgrupaConcepto = @B_AgrupaConcepto,
			I_AlumnosDestino = @I_AlumnosDestino,
			I_GradoDestino = @I_GradoDestino,
			I_TipoObligacion = @I_TipoObligacion,
			T_Clasificador = @T_Clasificador,
			C_CodTasa = @C_CodTasa,
			B_Calculado = @B_Calculado,
			I_Calculado = @I_Calculado,
			B_AnioPeriodo = @B_AnioPeriodo,
			I_Anio = @I_Anio,
			I_Periodo = @I_Periodo,
			B_Especialidad = @B_Especialidad,
			C_CodRc = @C_CodRc,
			B_Dependencia = @B_Dependencia,
			C_DepCod = @C_DepCod,
			B_GrupoCodRc = @B_GrupoCodRc,
			I_GrupoCodRc = @I_GrupoCodRc,
			B_ModalidadIngreso = @B_ModalidadIngreso,
			I_ModalidadIngresoID = @I_ModalidadIngresoID,
			B_ConceptoAgrupa = @B_ConceptoAgrupa,
			I_ConceptoAgrupaID = @I_ConceptoAgrupaID,
			B_ConceptoAfecta = @B_ConceptoAfecta,
			I_ConceptoAfectaID = @I_ConceptoAfectaID,
			N_NroPagos = @N_NroPagos,
			B_Porcentaje = @B_Porcentaje,
			M_Monto = @M_Monto,
			M_MontoMinimo = @M_MontoMinimo,
			T_DescripcionLarga = @T_DescripcionLarga,
			T_Documento = @T_Documento,
			B_Habilitado = @B_Habilitado,
			I_UsuarioMod = @I_UsuarioMod,
			D_FecMod = getdate()
		WHERE I_ConcPagID = @I_ConcPagID
		
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_I_GrabarDatosUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_I_GrabarDatosUsuario]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarDatosUsuario]
	@I_DatosUsuarioID	int	= NULL
	,@N_NumDoc			varchar(15)
	,@T_NomPersona		varchar(250)
	,@T_CorreoUsuario	varchar(100)
	,@D_FecRegistro		datetime
	,@B_Habilitado		bit
	,@UserId			int = NULL

	,@CurrentUserId		int
	,@B_Result			bit OUTPUT
	,@T_Message			nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO TC_DatosUsuario(N_NumDoc, T_NomPersona, T_CorreoUsuario, D_FecRegistro, B_Habilitado, B_Eliminado)
			VALUES(@N_NumDoc, @T_NomPersona, @T_CorreoUsuario, @D_FecRegistro, 1, 0)

		SET @I_DatosUsuarioID = SCOPE_IDENTITY()

		INSERT INTO TI_UsuarioDatosUsuario(UserId, I_DatosUsuarioID, D_FecAlta, D_FecBaja, B_Habilitado)
			VALUES(@UserId, @I_DatosUsuarioID, @D_FecRegistro, NULL, 1)

		COMMIT TRANSACTION
		SET @B_Result = 1
		SET @T_Message = 'La operación se realizó con éxito'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_U_GrabarDatosUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_U_GrabarDatosUsuario]
GO

CREATE PROCEDURE [dbo].[USP_U_GrabarDatosUsuario]
	@I_DatosUsuarioID	int	= NULL
	,@N_NumDoc			varchar(15)
	,@T_NomPersona		varchar(250)
	,@T_CorreoUsuario	varchar(100)
	,@I_DependenciaID	int
	,@D_FecRegistro		datetime
	,@B_Habilitado		bit
	,@UserId			int = NULL

	,@CurrentUserId		int
	,@B_Result			bit OUTPUT
	,@T_Message			nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE  TC_Usuario
			SET I_DependenciaID = @I_DependenciaID,
				D_FecActualiza = @D_FecRegistro,
				I_UsuarioMod = @CurrentUserId
		  WHERE	
				UserId = @UserId

		UPDATE  TC_DatosUsuario 
			SET	N_NumDoc = @N_NumDoc, 
				T_NomPersona = @T_NomPersona, 
				T_CorreoUsuario = @T_CorreoUsuario, 
				D_FecActualiza = @D_FecRegistro,
				B_Habilitado = @B_Habilitado
			WHERE
				I_DatosUsuarioID = @I_DatosUsuarioID
			
		IF(@UserId IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT * FROM TI_UsuarioDatosUsuario WHERE UserId = @UserId AND I_DatosUsuarioID = @I_DatosUsuarioID)
			BEGIN
				INSERT INTO TI_UsuarioDatosUsuario(UserId, I_DatosUsuarioID, D_FecAlta, D_FecBaja, B_Habilitado)
					VALUES(@UserId, @I_DatosUsuarioID, @D_FecRegistro, NULL, 1)
			END
			ELSE
			BEGIN
				UPDATE	TI_UsuarioDatosUsuario
					SET	B_Habilitado = 0,
						D_FecBaja = @D_FecRegistro					
					WHERE	UserId = @UserId
						AND B_Habilitado = 1

				UPDATE	TI_UsuarioDatosUsuario 
				SET		B_Habilitado = 1,
						D_FecAlta = @D_FecRegistro
				WHERE	UserId = @UserId 
						AND I_DatosUsuarioID = @I_DatosUsuarioID
			END
		END						

		COMMIT TRANSACTION
		SET @B_Result = 1
		SET @T_Message = 'La operación se realizó con éxito'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))
	END CATCH
END
GO



/*-------------------------- */

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_I_GrabarEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarEntidadFinanciera]
	 @I_EntidadFinanID	int
	,@T_EntidadDesc		varchar(250)
	,@B_Habilitado		bit
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
	BEGIN TRANSACTION
  	BEGIN TRY
		
		INSERT INTO TC_EntidadFinanciera(T_EntidadDesc, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
								VALUES	 (@T_EntidadDesc, @B_Habilitado, 0, @CurrentUserId, @D_FecCre)

		SET @I_EntidadFinanID = SCOPE_IDENTITY();

		INSERT INTO TI_TipoArchivo_EntidadFinanciera(I_EntidadFinanID, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							SELECT @I_EntidadFinanID, I_TipoArchivoID, 0, 0, @CurrentUserId, @D_FecCre
							FROM TC_TipoArchivo

		COMMIT TRANSACTION

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEntidadFinanciera]
	 @I_EntidadFinanID	int
	,@T_EntidadDesc		varchar(250)
	,@B_Habilitado		bit
	,@D_FecMod  		datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_EntidadFinanciera 
		SET	T_EntidadDesc = @T_EntidadDesc
			, B_Habilitado = @B_Habilitado
			, I_UsuarioMod = @CurrentUserId
			, D_FecMod = @D_FecMod
		WHERE I_EntidadFinanID = @I_EntidadFinanID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoEntidadFinanciera]
	 @I_EntidadFinanID	int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_EntidadFinanciera 
		SET		B_Habilitado = @B_Habilitado,
				I_UsuarioMod = @CurrentUserId,
				D_FecMod = @D_FecMod
				WHERE	I_EntidadFinanID = @I_EntidadFinanID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarTipoArchivosEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_I_GrabarTipoArchivosEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarTipoArchivosEntidadFinanciera]
	 @I_EntidadFinanID	int
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TI_TipoArchivo_EntidadFinanciera(I_EntidadFinanID, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							SELECT @I_EntidadFinanID, I_TipoArchivoID, 0, 0, @CurrentUserId, @D_FecCre
							FROM TC_TipoArchivo

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


/*-------------------------- */

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCuentaDeposito')
	DROP PROCEDURE [dbo].[USP_I_GrabarCuentaDeposito]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarCuentaDeposito]
	 @I_CtaDepositoID	int
	,@I_EntidadFinanID	int
	,@T_DescCuenta		varchar(150)
	,@C_NumeroCuenta	varchar(50)
	,@T_Observacion		varchar(500)
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TC_CuentaDeposito(I_EntidadFinanID, T_DescCuenta, C_NumeroCuenta, T_Observacion, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
								VALUES	 (@I_EntidadFinanID, @T_DescCuenta, @C_NumeroCuenta, @T_Observacion, 1, 0, @CurrentUserId, @D_FecCre)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarCuentaDeposito')
	DROP PROCEDURE [dbo].[USP_U_ActualizarCuentaDeposito]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarCuentaDeposito]
	 @I_CtaDepositoID	int
	,@I_EntidadFinanID	int
	,@T_DescCuenta		varchar(150)
	,@C_NumeroCuenta	varchar(50)
	,@T_Observacion		varchar(500)
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_CuentaDeposito 
		SET	T_DescCuenta = @T_DescCuenta
			, C_NumeroCuenta = @C_NumeroCuenta
			, I_EntidadFinanID = @I_EntidadFinanID
			, T_Observacion = @T_Observacion
		WHERE I_CtaDepositoID = @I_CtaDepositoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoCuentaDeposito')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoCuentaDeposito]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoCuentaDeposito]
	 @I_CtaDepositoID	int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_CuentaDeposito 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
				WHERE	I_CtaDepositoID = @I_CtaDepositoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


/*-------------------------- */



/*-------------------------- */

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_SelectItems') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCategoriaPago')
		DROP PROCEDURE [dbo].[USP_I_GrabarCategoriaPago]

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarCategoriaPago')
		DROP PROCEDURE [dbo].[USP_U_ActualizarCategoriaPago]

	DROP TYPE [dbo].[type_SelectItems]
END
GO

CREATE TYPE [dbo].[type_SelectItems] AS TABLE(
	C_ID	varchar(10),
	B_Habilitado bit 
)
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCategoriaPago')
	DROP PROCEDURE [dbo].[USP_I_GrabarCategoriaPago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarCategoriaPago]
	 @I_CatPagoID	int
	,@T_CatPagoDesc	varchar(250)
	,@I_Nivel		int
	,@I_TipoAlumno	int
	,@I_Prioridad	int
	,@B_Obligacion	bit
	,@N_CodBanco	varchar(10)
	,@Tbl_Cuentas		[dbo].[type_SelectItems] READONLY
	,@D_FecCre		datetime
	,@CurrentUserId	int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY		
		INSERT INTO TC_CategoriaPago (T_CatPagoDesc, I_Nivel, I_Prioridad, I_TipoAlumno, B_Obligacion, N_CodBanco, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
						  	  VALUES (@T_CatPagoDesc, @I_Nivel, @I_Prioridad, @I_TipoAlumno, @B_Obligacion, @N_CodBanco, 1, 0, @CurrentUserId, @D_FecCre)
		
		SET @I_CatPagoID = SCOPE_IDENTITY()

		MERGE TC_CuentaDeposito_CategoriaPago AS TRG
		USING @Tbl_Cuentas AS SRC
		ON  TRG.I_CatPagoID = @I_CatPagoID AND TRG.I_CtaDepositoID = SRC.C_ID
		WHEN MATCHED THEN
				UPDATE SET TRG.B_Habilitado = SRC.B_Habilitado,
					       TRG.D_FecMod = @D_FecCre,
					       TRG.I_UsuarioMod = @CurrentUserId
		WHEN NOT MATCHED BY TARGET THEN 
				INSERT (I_CatPagoID, I_CtaDepositoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
				VALUES	(@I_CatPagoID, SRC.C_ID, SRC.B_Habilitado, 0, @CurrentUserId, @D_FecCre)
		WHEN NOT MATCHED BY SOURCE THEN 
				UPDATE SET TRG.B_Habilitado = 0,
					       TRG.D_FecMod = @D_FecCre,
					       TRG.I_UsuarioMod = @CurrentUserId;



		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarCategoriaPago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarCategoriaPago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarCategoriaPago]
	 @I_CatPagoID	int
	,@T_CatPagoDesc	varchar(250)
	,@I_Nivel		int
	,@I_TipoAlumno	int
	,@I_Prioridad	int
	,@B_Obligacion	bit
	,@N_CodBanco	varchar(10)
	,@Tbl_Cuentas	[dbo].[type_SelectItems] READONLY
	,@D_FecMod		datetime
	,@CurrentUserId	int

	,@B_Result	bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_CategoriaPago 
		SET	T_CatPagoDesc = @T_CatPagoDesc
			, I_Nivel = @I_Nivel
			, I_Prioridad = @I_Prioridad
			, I_TipoAlumno = @I_TipoAlumno
			, B_Obligacion = @B_Obligacion
			, N_CodBanco = @N_CodBanco
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId

		WHERE I_CatPagoID = @I_CatPagoID
			
		MERGE TC_CuentaDeposito_CategoriaPago AS TRG
		USING @Tbl_Cuentas AS SRC
		ON  TRG.I_CatPagoID = @I_CatPagoID AND TRG.I_CtaDepositoID = SRC.C_ID
		WHEN MATCHED THEN
			UPDATE SET TRG.B_Habilitado = SRC.B_Habilitado,
					   TRG.D_FecMod = @D_FecMod,
					   TRG.I_UsuarioMod = @CurrentUserId
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (I_CatPagoID, I_CtaDepositoID, B_Habilitado,B_Eliminado, I_UsuarioCre, D_FecCre)
			VALUES	(@I_CatPagoID, SRC.C_ID, SRC.B_Habilitado, 0, @CurrentUserId, @D_FecMod);
		--WHEN NOT MATCHED BY SOURCE THEN 
		--	UPDATE SET TRG.B_Habilitado = 0,
		--			   TRG.D_FecMod = @D_FecMod,
		--			   TRG.I_UsuarioMod = @CurrentUserId;

		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoCategoriaPago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoCategoriaPago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoCategoriaPago]
	 @I_CatPagoID	int
	,@B_Habilitado	bit
	,@D_FecMod		datetime
	,@CurrentUserId	int

	,@B_Result	bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_CategoriaPago 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
				WHERE I_CatPagoID = @I_CatPagoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


/*-------------------------- */

/*-------------------------- */

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarConcepto')
	DROP PROCEDURE [dbo].[USP_I_GrabarConcepto]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarConcepto]
	 @I_ConceptoID		int
	,@T_ConceptoDesc	varchar(250)
	,@I_Monto			decimal(15,2)
	,@I_MontoMinimo		decimal(15,2)
	,@B_EsPagoMatricula	bit
	,@B_EsPagoExtmp		bit
	,@B_ConceptoAgrupa	bit
	,@B_Calculado		bit
	,@I_Calculado		int
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TC_Concepto(T_ConceptoDesc, I_Monto, I_MontoMinimo, B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, 
								B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
						VALUES (@T_ConceptoDesc, @I_Monto, @I_MontoMinimo, @B_EsPagoMatricula, @B_EsPagoExtmp, @B_ConceptoAgrupa,
								@B_Calculado, @I_Calculado, 1, 0, @CurrentUserId, @D_FecCre)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarConcepto')
	DROP PROCEDURE [dbo].[USP_U_ActualizarConcepto]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarConcepto]
	 @I_ConceptoID	int
	,@T_ConceptoDesc	varchar(250)
	,@I_Monto			decimal(15,2)
	,@I_MontoMinimo		decimal(15,2)
	,@B_EsPagoMatricula	bit
	,@B_EsPagoExtmp		bit
	,@B_ConceptoAgrupa	bit
	,@B_Calculado		bit
	,@I_Calculado		int
	,@D_FecMod		datetime
	,@CurrentUserId	int

	,@B_Result	bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_Concepto 
		SET	T_ConceptoDesc = @T_ConceptoDesc
			, I_Monto = @I_Monto
			, I_MontoMinimo = @I_MontoMinimo
			, I_Calculado = @I_Calculado
			, B_Calculado = @B_Calculado
			, B_EsPagoMatricula = @B_EsPagoMatricula
			, B_EsPagoExtmp	 = @B_EsPagoExtmp		
			, B_ConceptoAgrupa = @B_ConceptoAgrupa
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId
		WHERE I_ConceptoID = @I_ConceptoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoConcepto')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoConcepto]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoConcepto]
	 @I_ConceptoID	int
	,@B_Habilitado	bit
	,@D_FecMod		datetime
	,@CurrentUserId	int

	,@B_Result	bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_Concepto 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
				WHERE I_ConceptoID = @I_ConceptoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO

/*-------------------------- */


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarClasificadorIngreso')
	DROP PROCEDURE [dbo].[USP_I_GrabarClasificadorIngreso]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarClasificadorIngreso]
	 @I_ClasificadorID		int
	,@T_ClasificadorDesc	varchar(250)
	,@T_ClasificadorCod		varchar(50)
	,@T_ClasificadorUnfv	varchar(50)
	,@N_Anio			varchar(4)
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TC_ClasificadorIngreso(T_ClasificadorDesc,T_ClasificadorCod, T_ClasificadorUnfv, N_Anio, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
								VALUES	 (@T_ClasificadorDesc, @T_ClasificadorCod,@T_ClasificadorUnfv, @N_Anio, 1, 0, @CurrentUserId, @D_FecCre)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarClasificadorIngreso')
	DROP PROCEDURE [dbo].[USP_U_ActualizarClasificadorIngreso]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarClasificadorIngreso]
	 @I_ClasificadorID		int
	,@T_ClasificadorDesc	varchar(250)
	,@T_ClasificadorCod		varchar(50)
	,@T_ClasificadorUnfv	varchar(50)
	,@N_Anio			varchar(4)
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_ClasificadorIngreso 
		SET	T_ClasificadorDesc = @T_ClasificadorDesc
			,T_ClasificadorCod = @T_ClasificadorCod
			,T_ClasificadorUnfv = @T_ClasificadorUnfv
			,N_Anio = @N_Anio
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId
		WHERE I_ClasificadorID = @I_ClasificadorID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoClasificadorIngreso')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoClasificadorIngreso]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoClasificadorIngreso]
	 @I_ClasificadorID		int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_ClasificadorIngreso 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
				WHERE I_ClasificadorID = @I_ClasificadorID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


/*-----------------------------------------------------------*/
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataMatricula') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarMatricula')
		DROP PROCEDURE [dbo].[USP_IU_GrabarMatricula]

	DROP TYPE [dbo].[type_dataMatricula]
END
GO

CREATE TYPE [dbo].[type_dataMatricula] AS TABLE(
	C_CodRC			varchar(3)  NULL,
	C_CodAlu		varchar(10) NULL,
	I_Anio			int			NULL,
	C_Periodo		char(1)		NULL,
	C_EstMat		varchar(2)  NULL,
	C_Ciclo			varchar(2)  NULL,
	B_Ingresante	bit			NULL,
	I_CredDesaprob  tinyint		NULL,
	B_ActObl		bit			NULL
)
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarMatricula')
	DROP PROCEDURE [dbo].[USP_IU_GrabarMatricula]
GO

CREATE PROCEDURE [dbo].[USP_IU_GrabarMatricula]
(
	 @Tbl_Matricula	[dbo].[type_dataMatricula]	READONLY
	,@D_FecRegistro datetime
	,@UserID		int
	,@B_Result		bit				OUTPUT
	,@T_Message		nvarchar(4000)	OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
			BEGIN TRANSACTION
			
			DECLARE @Tbl_Actions AS TABLE( T_Action varchar(10), T_Codigo varchar(10));

			SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, c.I_OpcionID AS I_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_ActObl
			INTO #Tmp_Matricula FROM @Tbl_Matricula AS m
			INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = m.C_Periodo
			INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = a.C_RcCod
			WHERE c.B_Eliminado = 0;

			--Update para alumnos sin obligaciones
			WITH Tmp_SinObligaciones(I_MatAluID, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob)
			AS
			(
				SELECT mat.I_MatAluID, tmp.C_EstMat, tmp.C_Ciclo, tmp.B_Ingresante, tmp.I_CredDesaprob FROM dbo.TC_MatriculaAlumno mat
				LEFT JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = mat.I_MatAluID AND obl.B_Eliminado = 0
				INNER JOIN #Tmp_Matricula AS tmp ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo
				WHERE mat.B_Eliminado = 0 AND obl.I_MatAluID IS NULL
			)
			MERGE INTO dbo.TC_MatriculaAlumno AS trg USING Tmp_SinObligaciones AS src ON trg.I_MatAluID = src.I_MatAluID
			WHEN MATCHED THEN
			 		UPDATE SET   C_EstMat = src.C_EstMat
			 	  				, C_Ciclo = src.C_Ciclo
								, B_Ingresante = src.B_Ingresante
								, I_CredDesaprob = src.I_CredDesaprob
								, I_UsuarioMod = @UserID
								, D_FecMod = @D_FecRegistro;
			
			----Update para alumnos con obligaciones sin pagar ()
			--SELECT mat.I_MatAluID, tmp.C_EstMat, tmp.C_Ciclo, tmp.B_Ingresante, tmp.I_CredDesaprob FROM dbo.TC_MatriculaAlumno mat
			--INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = mat.I_MatAluID AND obl.B_Eliminado = 0
			--INNER JOIN #Tmp_Matricula AS tmp ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo
			--WHERE mat.B_Eliminado = 0

			--Insert para alumnos nuevos
			MERGE INTO TC_MatriculaAlumno AS trg USING #Tmp_Matricula AS src
			ON trg.C_CodRc = src.C_CodRc AND trg.C_CodAlu = src.C_CodAlu AND trg.I_Anio = src.I_Anio AND trg.I_Periodo = src.I_Periodo AND trg.B_Eliminado = 0
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
			 	VALUES (src.C_CodRc, src.C_CodAlu, src.I_Anio, src.I_Periodo, src.C_EstMat, src.C_Ciclo, src.B_Ingresante, src.I_CredDesaprob, 1, 0, @UserID, @D_FecRegistro);

			--Informar los alumnos que ya tienen obligaciones (pagadas y sin pagar).
			SELECT DISTINCT tmp.C_CodRC, tmp.C_CodAlu, tmp.I_Anio, tmp.C_Periodo, tmp.C_EstMat, tmp.C_Ciclo, tmp.B_Ingresante, tmp.I_CredDesaprob, 0 as B_Success, 'El alumno tiene obligaciones registradas.' AS T_Message FROM dbo.TC_MatriculaAlumno mat
			INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = mat.I_MatAluID AND obl.B_Eliminado = 0
			INNER JOIN #Tmp_Matricula AS tmp ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo
			WHERE mat.B_Eliminado = 0
			UNION
			SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, 0 AS B_Success, 'El Código de alumno no existe.' AS T_Message FROM @Tbl_Matricula AS m
			LEFT JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRC
			WHERE a.C_CodAlu IS NULL

			COMMIT TRANSACTION

			SET @B_Result = 1
			SET @T_Message = 'La importación de datos de alumno finalizó de manera exitosa'
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO




/*-----------------------------------------------------------*/
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_roles' AND DATA_TYPE = 'table type') BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_I_GrabarDocumentacionUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
		DROP PROCEDURE [dbo].[USP_I_GrabarDocumentacionUsuario]

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_U_GrabarDocumentacionUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
		DROP PROCEDURE [dbo].[USP_U_GrabarDocumentacionUsuario]

	DROP TYPE [dbo].[type_roles]
END
GO


CREATE TYPE [dbo].[type_roles] AS TABLE(
	RoleId			int  NULL ,
	RoleName		varchar(50)  NULL ,
	B_Habilitado	bit  NULL
)
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_I_GrabarDocumentacionUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_I_GrabarDocumentacionUsuario]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarDocumentacionUsuario]
(
	@I_RutaDocID		int
	,@T_DocDesc			varchar(200)
	,@T_RutaDocumento	nvarchar(4000)
	,@Tbl_Roles			[dbo].[type_roles] READONLY
	,@I_UserID			int

	,@B_Result			bit OUTPUT
	,@T_Message			nvarchar(4000) OUTPUT
)
AS
BEGIN
	
	BEGIN TRANSACTION
	BEGIN TRY
		
		INSERT INTO [dbo].[TS_RutaDocumentacion] (T_DocDesc, T_RutaDocumento, B_Habilitado, B_Eliminado, D_FecCre, I_UsuarioCre) 
			VALUES ( @T_DocDesc, @T_RutaDocumento, 1, 0, GETDATE(), @I_UserID)
			
		SET @I_RutaDocID = IDENT_CURRENT('TS_RutaDocumentacion')

		--EXEC USP_U_GrabarHistorialRegistroUsuario @I_UserID, 17, 'TS_RutaDocumentacion'

		INSERT INTO [dbo].[TS_DocumentosRoles] (I_RutaDocID, RoleId, B_Habilitado, B_Eliminado, D_FecCre, I_UsuarioCre)
				SELECT	@I_RutaDocID, RoleId, B_Habilitado,  0, GETDATE(), @I_UserID
				FROM @Tbl_Roles

		--EXEC USP_U_GrabarHistorialRegistroUsuario @I_UserID, 17, 'TS_DocumentosRoles'

		SET @B_Result = 1
		SET @T_Message = 'La operación se realizó correctamente.'

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_U_GrabarDocumentacionUsuario' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_U_GrabarDocumentacionUsuario]
GO

CREATE PROCEDURE [dbo].[USP_U_GrabarDocumentacionUsuario]
(
	@I_RutaDocID		tinyint
	,@T_DocDesc			varchar(200)
	,@T_RutaDocumento	nvarchar(4000)
	,@Tbl_Roles			[dbo].[type_roles] READONLY
	,@I_UserID			int

	,@B_Result			bit OUTPUT
	,@T_Message			nvarchar(4000) OUTPUT
)
AS
BEGIN
	
	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE [dbo].[TS_RutaDocumentacion]
			SET T_DocDesc = @T_DocDesc
				,T_RutaDocumento = @T_RutaDocumento
				,D_FecMod = GETDATE()
				,I_UsuarioMod = @I_UserID
			WHERE I_RutaDocID = @I_RutaDocID

		--EXEC USP_U_GrabarHistorialRegistroUsuario @I_UserID, 17, 'TS_RutaDocumentacion'

		MERGE  [dbo].[TS_DocumentosRoles]
		USING  @Tbl_Roles AS roles
		ON	roles.RoleId = [dbo].[TS_DocumentosRoles].[RoleId]
			AND [dbo].[TS_DocumentosRoles].[I_RutaDocID] = @I_RutaDocID
		WHEN MATCHED THEN
			UPDATE SET [dbo].[TS_DocumentosRoles].[B_Habilitado] = roles.B_Habilitado
				,[dbo].[TS_DocumentosRoles].[D_FecMod] = GETDATE()
				,[dbo].[TS_DocumentosRoles].[I_UsuarioMod] = @I_UserID

		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_RutaDocID, RoleId, B_Habilitado, B_Eliminado, D_FecCre, I_UsuarioCre)
			VALUES (@I_RutaDocID, roles.RoleId, roles.B_Habilitado,  0, GETDATE(), @I_UserID);

		--EXEC USP_U_GrabarHistorialRegistroUsuario @I_UserID, 17, 'TS_DocumentosRoles'

		SET @B_Result = 1
		SET @T_Message = 'La operación se realizó correctamente.'

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_U_ActualizarEstadoArchivo' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoArchivo]
GO


CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoArchivo]
	 @I_RutaDocID	int
	,@B_Habilitado	bit

	,@IdUser int
	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE	TS_RutaDocumentacion 
		SET		B_Habilitado = @B_Habilitado
		WHERE	I_RutaDocID = @I_RutaDocID

--		EXEC USP_U_GrabarHistorialRegistroUsuario @IdUser, 17, 'TS_RutaDocumentacion'

	COMMIT TRANSACTION
		SET @B_Result = 1
		SET @T_Message = 'La operación se realizó con éxito'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))
	END CATCH
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_S_DocumentacionUsuarioRoles' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_S_DocumentacionUsuarioRoles]
GO


CREATE PROCEDURE [dbo].[USP_S_DocumentacionUsuarioRoles]
AS
BEGIN
	SET NOCOUNT ON
	SELECT RD.I_RutaDocID, RD.T_DocDesc, RD.T_RutaDocumento, RD.B_Habilitado, DR.RoleId, DR.B_Habilitado As B_DocRolHabilitado
	FROM TS_RutaDocumentacion RD
		 LEFT JOIN TS_DocumentosRoles DR ON RD.[I_RutaDocID] = DR.[I_RutaDocID]
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'FN_CalcularCuotasDeuda' AND ROUTINE_TYPE = 'FUNCTION')
	DROP FUNCTION [dbo].[FN_CalcularCuotasDeuda]
GO

CREATE FUNCTION dbo.FN_CalcularCuotasDeuda (@I_MontoDeuda decimal(15,2), @N_NroPagos tinyint, @I_NroFila int)
RETURNS DECIMAL (15,2)
AS
BEGIN
	declare @resultado decimal(15,2),
			--@mod decimal(15,2),
			@parteEntera decimal(15,2),
			@parteDecimal decimal(15,2)

	set @parteEntera = FLOOR(@I_MontoDeuda)

	set @parteDecimal = @I_MontoDeuda - @parteEntera
	 
	set @resultado = (case when @N_NroPagos = 1
						then 
							@I_MontoDeuda 
						else 
							case when cast(@I_MontoDeuda / @N_NroPagos as decimal(15,2)) * @N_NroPagos = @I_MontoDeuda
								then 
									cast(@I_MontoDeuda / @N_NroPagos as decimal(15,2))
								else 
									case when @I_NroFila <= (@I_MontoDeuda % @N_NroPagos) 
										then FLOOR(@parteEntera / @N_NroPagos) + 1 + (case when @I_NroFila = 1 then @parteDecimal else 0 end)
										else FLOOR(@parteEntera / @N_NroPagos)
									end
							end
					end)
	return @resultado
END
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_IU_GenerarObligacionesPregrado_X_Ciclo' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_IU_GenerarObligacionesPregrado_X_Ciclo]
GO


CREATE PROCEDURE [dbo].[USP_IU_GenerarObligacionesPregrado_X_Ciclo]
@I_Anio int,
@I_Periodo int,
@C_CodFac varchar(2) = null,
@C_CodAlu varchar(20) = null,
@C_CodRc varchar(3) = null,
@I_UsuarioCre int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	--1ro Obtener los conceptos según año y periodo
	declare @I_Pregrado int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod = '1')
	declare @I_Bachiller int = 1

	select p.I_ProcesoID, p.D_FecVencto, cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,
	conpag.B_Calculado, conpag.I_Calculado, conpag.B_GrupoCodRc, gr.T_OpcionCod AS I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng, 
	con.B_EsPagoMatricula, con.B_EsPagoExtmp, conpag.N_NroPagos
	into #tmp_conceptos_pregrado
	from dbo.TC_Proceso p
	inner join dbo.TC_CategoriaPago cp on cp.I_CatPagoID = p.I_CatPagoID
	inner join dbo.TI_ConceptoPago conpag on conpag.I_ProcesoID = p.I_ProcesoID
	inner join dbo.TC_Concepto con on con.I_ConceptoID = conpag.I_ConceptoID
	left join dbo.TC_CatalogoOpcion moding on moding.I_ParametroID = 7 and moding.I_OpcionID = conpag.I_ModalidadIngresoID
	left join dbo.TC_CatalogoOpcion gr on gr.I_ParametroID = 6 and gr.I_OpcionID = conpag.I_GrupoCodRc
	where p.B_Habilitado = 1 and p.B_Eliminado = 0 and
		conpag.B_Habilitado = 1 and conpag.B_Eliminado = 0 and
		cp.B_Obligacion = 1 and p.I_Anio = @I_Anio and p.I_Periodo = @I_Periodo and cp.I_Nivel = @I_Pregrado
		--cp.B_Obligacion = 1 and p.I_Anio = 2021 and p.I_Periodo = 15 and cp.I_Nivel = 4

	--2do Obtengo la relación de alumnos
	declare @Tmp_MatriculaAlumno table (id int identity(1,1), I_MatAluID int, C_CodRc varchar(3), C_CodAlu varchar(20), C_EstMat varchar(2), B_Ingresante bit, C_CodModIng varchar(2), N_Grupo char(1), I_CredDesaprob tinyint)
	declare @Tmp_Procesos table (I_ProcesoID int, I_ConcPagID int, M_Monto decimal(15,2))

	if (@C_CodAlu is not null) and (@C_CodRc is not null) begin
		insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
		select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) from dbo.TC_MatriculaAlumno m 
		inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
		where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado = @I_Bachiller and
			m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
	end else begin
		if (@C_CodFac is null) or (@C_CodFac = '') begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado = @I_Bachiller and
				m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo
		end else begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado = @I_Bachiller and
				m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and a.C_CodFac = @C_CodFac
		end
		
		
	end

	declare @C_Moneda varchar(3) = 'PEN',
			@D_CurrentDate datetime = getdate(),
			@I_Posicion int = 1,
			@I_CantRegistros int = (select max(id) from @Tmp_MatriculaAlumno),
			@I_AlumnoRegular int = 1,
			@I_AlumnoIngresante int = 2,
			@I_Matricula int = 9,
			@I_OtrosPagos int = 10,
			@I_CrdtDesaprobados int = 11,
			@I_DeudasAnteriores int = 12,
			@I_Pensiones int = 13,
			----------------------------
			@I_MatAluID int,
			--@C_CodRc varchar(3),
			--@C_CodAlu varchar(20),
			@C_EstMat varchar(2),
			@C_CodModIng varchar(2),
			@N_Grupo char(1),
			@I_TipoAlumno int,
			@D_FecVencto datetime,
			@I_MontoDeuda decimal(15,2),
			@I_CredDesaprob tinyint,
			@N_NroPagos tinyint

	while (@I_Posicion <= @I_CantRegistros) begin
		begin tran
		begin try
			
			--3ro obtengo la información alumno por alumno e inicializo variables
			select @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, @N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0),
			@I_TipoAlumno = (case when B_Ingresante = 0 then @I_AlumnoRegular else @I_AlumnoIngresante end) from @Tmp_MatriculaAlumno 
			where id = @I_Posicion

			delete @Tmp_Procesos

			--Pagos de Matrícula
			if exists(select I_ProcesoID from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng)
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng

				set @D_FecVencto = (select top 1 D_FecVencto from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng)
			end
			else
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1

				set @D_FecVencto = (select top 1 D_FecVencto from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1)
			end

			--Pagos generales de matrícula
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
			select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 0 and B_Calculado = 0 and B_GrupoCodRc = 0 and B_EsPagoExtmp = 0

			--Pagos de laboratorio
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
			select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 0 and B_GrupoCodRc = 1 and I_GrupoCodRc = @N_Grupo

			--Pagos extemoráneos
			if (datediff(day, @D_CurrentDate, @D_FecVencto) < 0)
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1
			end

			--Monto de deuda anterior
			set @I_MontoDeuda = isnull((select SUM(det.I_Monto) from dbo.TR_ObligacionAluCab cab
				inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
				inner join (select top 1 m.I_MatAluID from dbo.TC_MatriculaAlumno m 
					where m.B_Eliminado = 0 and not m.I_MatAluID = @I_MatAluID and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
					order by m.I_Anio desc, m.C_Ciclo desc) mat on mat.I_MatAluID = cab.I_MatAluID
				where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and det.B_Pagado = 0), 0)
			
			if (@I_MontoDeuda > 0)
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores
					union all
					select num + 1, I_ProcesoID, I_ConcPagID
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, dbo.FN_CalcularCuotasDeuda(@I_MontoDeuda, @N_NroPagos, num) AS M_Monto
				from CTE_Recursivo;
			end

			--Monto de cursos desaprobados
			if (@I_CredDesaprob > 0)
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados), 1);

				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, cast((M_Monto * @I_CredDesaprob) / @N_NroPagos as decimal(15,2)) from CTE_Recursivo
			end
			
			--Monto de Pensión de enseñanza
			if exists(select I_ProcesoID from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
					B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng)
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, cast(M_Monto / @N_NroPagos as decimal(15,2)) as M_Monto from CTE_Recursivo
			end

			--Inserción de Cabecera
			insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
			select distinct p.I_ProcesoID, @I_MatAluID, @C_Moneda, 0, 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, @D_FecVencto from @Tmp_Procesos p
			left join dbo.TR_ObligacionAluCab cab on cab.I_ProcesoID = p.I_ProcesoID and cab.I_MatAluID = @I_MatAluID and cab.B_Eliminado = 0
			where cab.I_ProcesoID is null

			--Inserción de los Detalles
			insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
			select cab.I_ObligacionAluID, tmp.I_ConcPagID, tmp.M_Monto, 0, @D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from dbo.TR_ObligacionAluCab cab
			inner join @Tmp_Procesos tmp on tmp.I_ProcesoID = cab.I_ProcesoID
			where cab.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and 
				not exists(select det.I_ObligacionAluDetID from dbo.TR_ObligacionAluDet det 
					where det.B_Eliminado = 0 and det.I_ObligacionAluID = cab.I_ObligacionAluID and det.I_ConcPagID = tmp.I_ConcPagID)

			update dbo.TR_ObligacionAluCab set I_MontoOblig = I_Total, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
			from (select cab.I_ObligacionAluID, sum(det.I_Monto) as I_Total from dbo.TR_ObligacionAluCab cab
				inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
				where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID
				group by cab.I_ObligacionAluID) grupo where grupo.I_ObligacionAluID = dbo.TR_ObligacionAluCab.I_ObligacionAluID

			commit tran
		end try
		begin catch
			rollback tran

			print ERROR_MESSAGE()
			print ERROR_LINE()
		end catch

		set @I_Posicion = (@I_Posicion +1)
	end

	set @B_Result = 1
	set @T_Message = 'El proceso finalizó correctamente.'
/*

declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPregrado_X_Ciclo 2021, 15, null, null, 1,
@B_Result OUTPUT,
@T_Message OUTPUT
go

*/
END
GO





IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_IU_GenerarObligacionesPosgrado_X_Ciclo' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_IU_GenerarObligacionesPosgrado_X_Ciclo]
GO


CREATE PROCEDURE [dbo].[USP_IU_GenerarObligacionesPosgrado_X_Ciclo]
@I_Anio int,
@I_Periodo int,
@I_UsuarioCre int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	--1ro Obtener los conceptos según año y periodo
	select p.I_ProcesoID, p.D_FecVencto, cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,
	conpag.B_Calculado, conpag.I_Calculado, conpag.B_GrupoCodRc, conpag.I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng, 
	con.B_EsPagoMatricula, con.B_EsPagoExtmp, conpag.N_NroPagos
	into #tmp_conceptos_posgrado
	from dbo.TC_Proceso p
	inner join dbo.TC_CategoriaPago cp on cp.I_CatPagoID = p.I_CatPagoID
	inner join dbo.TI_ConceptoPago conpag on conpag.I_ProcesoID = p.I_ProcesoID
	inner join dbo.TC_Concepto con on con.I_ConceptoID = conpag.I_ConceptoID
	left join dbo.TC_CatalogoOpcion moding on moding.I_ParametroID = 7 and moding.I_OpcionID = conpag.I_ModalidadIngresoID
	where p.B_Habilitado = 1 and p.B_Eliminado = 0 and
		conpag.B_Habilitado = 1 and conpag.B_Eliminado = 0 and
		cp.B_Obligacion = 1 and p.I_Anio = @I_Anio and p.I_Periodo = @I_Periodo and cp.I_Nivel in (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod IN ('2', '3'))
		--cp.B_Obligacion = 1 and p.I_Anio = 2021 and p.I_Periodo = 15 and cp.I_Nivel in (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod IN ('2', '3'))
	--select * from #tmp_conceptos_posgrado
	--drop table #tmp_conceptos_posgrado

	--2do Obtengo la relación de alumnos
	declare @Tmp_MatriculaAlumno table (id int identity(1,1), I_MatAluID int, C_CodRc varchar(3), C_CodAlu varchar(20), C_EstMat varchar(2), B_Ingresante bit, C_CodModIng varchar(2), N_Grupo char(1), I_CredDesaprob tinyint)
	declare @Tmp_Procesos table (I_ProcesoID int, I_ConcPagID int, M_Monto decimal(15,2))

	insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
	select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) from dbo.TC_MatriculaAlumno m 
	inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
	where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado in (2,3) and
		m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo 

	declare @C_Moneda varchar(3) = 'PEN',
			@D_CurrentDate datetime = getdate(),
			@I_Posicion int = 1,
			@I_CantRegistros int = (select max(id) from @Tmp_MatriculaAlumno),
			@I_AlumnoRegular int = 1,
			@I_AlumnoIngresante int = 2,
			@I_Matricula int = 9,
			@I_OtrosPagos int = 10,
			@I_CrdtDesaprobados int = 11,
			@I_DeudasAnteriores int = 12,
			@I_Pensiones int = 13,
			----------------------------
			@I_MatAluID int,
			@C_CodRc varchar(3),
			@C_CodAlu varchar(20),
			@C_EstMat varchar(2),
			@C_CodModIng varchar(2),
			@N_Grupo char(1),
			@I_TipoAlumno int,
			@D_FecVencto datetime,
			@I_MontoDeuda decimal(15,2),
			@I_CredDesaprob tinyint,
			@N_NroPagos tinyint

	while (@I_Posicion <= @I_CantRegistros) begin
		begin tran
		begin try
			--3ro obtengo la información alumno por alumno e inicializo variables
			select @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, @N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0),
			@I_TipoAlumno = (case when B_Ingresante = 0 then @I_AlumnoRegular else @I_AlumnoIngresante end) from @Tmp_MatriculaAlumno 
			where id = @I_Posicion

			delete @Tmp_Procesos

			--Pagos de Matrícula
			if exists(select I_ProcesoID from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng)
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng

				set @D_FecVencto = (select top 1 D_FecVencto from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng)
			end
			else
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1

				set @D_FecVencto = (select top 1 D_FecVencto from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1)
			end

			--Pagos generales de matrícula (biblioteca y laboratorio)
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
			select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_posgrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 0 and B_Calculado = 0 and B_GrupoCodRc = 0 and B_EsPagoExtmp = 0

			--Pagos extemoráneos
			if (datediff(day, @D_CurrentDate, @D_FecVencto) < 0)
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1
			end

			----Monto de deuda anterior
			--set @I_MontoDeuda = isnull((select SUM(det.I_Monto) from dbo.TR_ObligacionAluCab cab
			--	inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
			--	inner join (select top 1 m.I_MatAluID from dbo.TC_MatriculaAlumno m 
			--		where m.B_Eliminado = 0 and not m.I_MatAluID = @I_MatAluID and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
			--		order by m.I_Anio desc, m.C_Ciclo desc) mat on mat.I_MatAluID = cab.I_MatAluID
			--	where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and det.B_Pagado = 0), 0)
			
			--if (@I_MontoDeuda > 0)
			--begin
			--	set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
			--		where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
			--			B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores), 1);

			--	with CTE_Recursivo as
			--	(
			--		select 1 as num, I_ProcesoID, I_ConcPagID from #tmp_conceptos_posgrado
			--		where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
			--			B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores
			--		union all
			--		select num + 1, I_ProcesoID, I_ConcPagID
			--		from CTE_Recursivo
			--		where num < @N_NroPagos
			--	)
			--	insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
			--	select I_ProcesoID, I_ConcPagID, cast(@I_MontoDeuda / @N_NroPagos as decimal(15,2)) as M_Monto from CTE_Recursivo
			--end

			----Monto de cursos desaprobados
			--if (@I_CredDesaprob > 0)
			--begin
			--	set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
			--		where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
			--			B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados), 1);

			--	with CTE_Recursivo as
			--	(
			--		select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_posgrado
			--		where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
			--			B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados
			--		union all
			--		select num + 1, I_ProcesoID, I_ConcPagID, M_Monto
			--		from CTE_Recursivo
			--		where num < @N_NroPagos
			--	)
			--	insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
			--	select I_ProcesoID, I_ConcPagID, cast((M_Monto * @I_CredDesaprob) / @N_NroPagos as decimal(15,2)) from CTE_Recursivo
			--end
			
			--Monto de Pensión de enseñanza
			if exists(select I_ProcesoID from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
					B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng)
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_OtrosPagos and 
						B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto)
				select I_ProcesoID, I_ConcPagID, cast(M_Monto / @N_NroPagos as decimal(15,2)) as M_Monto from CTE_Recursivo
			end

			--Inserción de Cabecera
			insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
			select distinct p.I_ProcesoID, @I_MatAluID, @C_Moneda, 0, 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, @D_FecVencto from @Tmp_Procesos p
			left join dbo.TR_ObligacionAluCab cab on cab.I_ProcesoID = p.I_ProcesoID and cab.B_Eliminado = 0
			where cab.I_ProcesoID is null

			--Inserción de los Detalles
			insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
			select cab.I_ObligacionAluID, tmp.I_ConcPagID, tmp.M_Monto, 0, @D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from dbo.TR_ObligacionAluCab cab
			inner join @Tmp_Procesos tmp on tmp.I_ProcesoID = cab.I_ProcesoID
			where cab.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and 
				not exists(select det.I_ObligacionAluDetID from dbo.TR_ObligacionAluDet det 
					where det.B_Eliminado = 0 and det.I_ObligacionAluID = cab.I_ObligacionAluID and det.I_ConcPagID = tmp.I_ConcPagID)

			update dbo.TR_ObligacionAluCab set I_MontoOblig = I_Total
			from (select cab.I_ObligacionAluID, sum(det.I_Monto) as I_Total from dbo.TR_ObligacionAluCab cab
				inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
				where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID
				group by cab.I_ObligacionAluID) grupo where grupo.I_ObligacionAluID = dbo.TR_ObligacionAluCab.I_ObligacionAluID

			commit tran
		end try
		begin catch
			rollback tran
			print ERROR_MESSAGE()
			print ERROR_LINE()
		end catch

		set @I_Posicion = (@I_Posicion +1)
	end

/*
declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPosgrado_X_Ciclo  2021, 15, 1,
@B_Result OUTPUT,
@T_Message OUTPUT
go
*/
END
GO




IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DetalleObligaciones')
	DROP VIEW [dbo].[VW_DetalleObligaciones]
GO


CREATE VIEW [dbo].[VW_DetalleObligaciones]
AS
SELECT pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_CodRc, a.C_CodFac, a.T_Nombre, a.T_ApePaterno, a.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, 
	con.T_ConceptoDesc, cat.T_CatPagoDesc, det.I_Monto, det.B_Pagado, det.D_FecVencto, pro.I_Prioridad,
	pagban.C_CodOperacion, pagban.D_FecPago, pagban.T_LugarPago, cab.C_Moneda, cp.I_TipoObligacion, 
	cat.I_Nivel, niv.T_OpcionCod AS C_Nivel, niv.T_OpcionDesc AS T_Nivel, cat.I_TipoAlumno, tipal.T_OpcionCod AS C_TipoAlumno, tipal.T_OpcionDesc AS T_TipoAlumno
FROM dbo.TC_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0 
INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0
INNER JOIN dbo.TI_ConceptoPago cp ON cp.I_ConcPagID = det.I_ConcPagID AND det.B_Eliminado = 0
INNER JOIN dbo.TC_Concepto con ON con.I_ConceptoID = cp.I_ConceptoID AND con.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cp.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = mat.C_CodAlu AND a.C_RcCod = mat.C_CodRc
LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0
LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
WHERE mat.B_Eliminado = 0
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CuotasPago')
	DROP VIEW [dbo].[VW_CuotasPago]
GO

CREATE VIEW [dbo].[VW_CuotasPago]
AS
WITH CuotasPago(I_ProcesoID, N_CodBanco, C_CodAlu, C_CodRc, C_CodFac, T_Nombre, T_ApePaterno, T_ApeMaterno, I_Anio, I_Periodo, C_Periodo, T_Periodo, 
	T_CatPagoDesc, D_FecVencto, I_Prioridad, C_Moneda, I_TipoObligacion, C_Nivel, C_TipoAlumno, I_MontoTotal)
AS
(
	SELECT d.I_ProcesoID, d.N_CodBanco, d.C_CodAlu, d.C_CodRc, d.C_CodFac, d.T_Nombre, d.T_ApePaterno, d.T_ApeMaterno, d.I_Anio, d.I_Periodo, d.C_Periodo, d.T_Periodo, 
		d.T_CatPagoDesc, d.D_FecVencto, d.I_Prioridad, d.C_Moneda, d.I_TipoObligacion, d.C_Nivel, d.C_TipoAlumno,
		SUM(d.I_Monto) AS I_MontoTotal 
	FROM VW_DetalleObligaciones d
	GROUP BY d.I_ProcesoID, d.N_CodBanco, d.C_CodAlu, d.C_CodRc, d.C_CodFac, d.T_Nombre, d.T_ApePaterno, d.T_ApeMaterno, d.I_Anio, d.I_Periodo, d.C_Periodo, d.T_Periodo, 
		d.T_CatPagoDesc, d.D_FecVencto, d.I_Prioridad, d.C_Moneda, d.I_TipoObligacion, C_Nivel, C_TipoAlumno
)
SELECT ROW_NUMBER() OVER(PARTITION BY C_CodAlu, C_CodRc ORDER BY I_Prioridad, D_FecVencto) AS I_NroOrden,
	I_ProcesoID, N_CodBanco, C_CodAlu, C_CodRc, C_CodFac, T_Nombre, T_ApePaterno, T_ApeMaterno, 
	I_Anio, I_Periodo, C_Periodo, T_Periodo, T_CatPagoDesc, D_FecVencto, C_Moneda, I_TipoObligacion, C_Nivel, C_TipoAlumno, I_MontoTotal
FROM CuotasPago
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
	T_NomDepositante	varchar(20),
	C_Referencia		varchar(50),
	D_FecPago			datetime,
	I_Cantidad			int,
	C_Moneda			varchar(3),
	I_MontoPago			decimal(15,2),
	T_LugarPago			varchar(250),
	--Identificar obligaciones
	C_CodAlu			varchar(20),
	C_CodRc				varchar(3),
	I_ProcesoID			int,
	D_FecVencto			datetime
)
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
(
	 @Tbl_Pagos	[dbo].[type_dataPago]	READONLY
	,@D_FecRegistro datetime
	,@UserID		int
	,@B_Result		bit				OUTPUT
	,@T_Message		nvarchar(4000)	OUTPUT
)
AS
BEGIN
	SELECT * FROM dbo.TR_PagoBanco
	SELECT * FROM dbo.TRI_PagoProcesadoUnfv	
	SELECT * FROM dbo.TR_ObligacionAluCab
	SELECT * FROM dbo.TR_ObligacionAluDet

	DECLARE @Tmp_PagoObligacion TABLE (
		id INT IDENTITY(1,1),
		I_ObligacionAluID	int,
		C_CodOperacion		varchar(50),
		T_NomDepositante	varchar(20),
		C_Referencia		varchar(50),
		D_FecPago			datetime,
		I_Cantidad			int,
		C_Moneda			varchar(3),
		I_MontoPago			decimal(15,2),
		T_LugarPago			varchar(250)
	);

	WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto)
	AS 
	(
		SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto FROM dbo.TC_MatriculaAlumno m
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID
		WHERE m.B_Eliminado = 0 AND cab.B_Eliminado = 0
	)
	INSERT @Tmp_PagoObligacion(I_ObligacionAluID, C_CodOperacion, T_NomDepositante, 
		C_Referencia, D_FecPago, I_Cantidad, C_Moneda, I_MontoPago, T_LugarPago)
	SELECT m.I_ObligacionAluID, p.C_CodOperacion, p.T_NomDepositante, p.C_Referencia, p.D_FecPago, 
		p.I_Cantidad, p.C_Moneda, p.I_MontoPago, p.T_LugarPago FROM @Tbl_Pagos p
	INNER JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND 
		m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0
	
	DECLARE @I_PagoBanco INT

	BEGIN TRANSACTION
	BEGIN TRY
		
		



		--INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,
		--	C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre)
		


		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END
GO