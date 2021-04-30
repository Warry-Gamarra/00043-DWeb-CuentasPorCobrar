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


/*-----------------------------------------------------------*/


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarDependencia')
	DROP PROCEDURE [dbo].[USP_I_GrabarDependencia]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarDependencia]
	 @I_DependenciaID	int
	,@C_DepCod			varchar(20)
	,@C_DepCodPl		varchar(20)
	,@T_DepDesc			varchar(150)
	,@T_DepAbrev		varchar(10)
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
	BEGIN TRANSACTION
  	BEGIN TRY
		
		INSERT INTO TC_DependenciaUNFV(T_DepDesc,T_DepAbrev, C_DepCod, C_DepCodPl, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
								VALUES	 (@T_DepDesc, @T_DepAbrev, @C_DepCod, @C_DepCodPl, 1, 0, @CurrentUserId, @D_FecCre)

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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarDependencia')
	DROP PROCEDURE [dbo].[USP_U_ActualizarDependencia]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarDependencia]
	 @I_DependenciaID	int
	,@C_DepCod			varchar(20)
	,@C_DepCodPl		varchar(20)
	,@T_DepDesc			varchar(150)
	,@T_DepAbrev		varchar(10)
	,@D_FecMod  		datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_DependenciaUNFV 
		SET	T_DepDesc = @T_DepDesc
			, T_DepAbrev = @T_DepAbrev
			, C_DepCod = @C_DepCod
			, C_DepCodPl = @C_DepCodPl
			, I_UsuarioMod = @CurrentUserId
			, D_FecMod = @D_FecMod
		WHERE I_DependenciaID = @I_DependenciaID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoDependencia')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoDependencia]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoDependencia]
	 @I_DependenciaID	int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_DependenciaUNFV 
		SET		B_Habilitado = @B_Habilitado,
				I_UsuarioMod = @CurrentUserId,
				D_FecMod = @D_FecMod
				WHERE	I_DependenciaID = @I_DependenciaID
			
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
	SELECT p.I_ProcesoID, cp.I_CatPagoID, cp.T_CatPagoDesc, per.T_OpcionDesc AS T_PeriodoDesc, I_Periodo, per.T_OpcionCod AS C_PeriodoCod, 
		   p.I_Anio, p.D_FecVencto, p.I_Prioridad, p.N_CodBanco, p.T_ProcesoDesc, cp.B_Obligacion, cp.I_Nivel, niv.T_OpcionCod AS C_Nivel,
		   cp.I_TipoAlumno, tipAlu.T_OpcionDesc AS T_TipoAlumno, tipAlu.T_OpcionCod as C_TipoAlumno
	FROM dbo.TC_Proceso p
		INNER JOIN dbo.TC_CategoriaPago cp ON p.I_CatPagoID = cp.I_CatPagoID
		LEFT JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = p.I_Periodo
		LEFT JOIN dbo.TC_CatalogoOpcion niv ON niv.I_OpcionID = cp.I_Nivel
		LEFT JOIN dbo.TC_CatalogoOpcion tipAlu ON tipAlu.I_OpcionID = cp.I_TipoAlumno
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

		INSERT INTO TI_ConceptoPago
				   (I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, T_Clasificador, B_Calculado, I_Calculado, B_AnioPeriodo, I_Anio, I_Periodo, B_ConceptoAgrupa, 
				    M_Monto, M_MontoMinimo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
			SELECT @I_ProcesoID, CCP.I_ConceptoID, C.T_ConceptoDesc, C.T_Clasificador, C.B_Calculado, C.I_Calculado, 1, @I_Anio, @I_Periodo, C.B_ConceptoAgrupa,  
					C.I_Monto,C.I_MontoMinimo, 1 as B_Habilitado, 0 as B_Eliminado, @I_UsuarioCre, getdate()
			  FROM TI_ConceptoCategoriaPago CCP
				   INNER JOIN TC_Concepto C ON CCP.I_ConceptoID = C.I_ConceptoID
			 WHERE I_CatPagoID = @I_CatPagoID

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
			c.I_Periodo, c.M_Monto, c.M_MontoMinimo, c.B_Habilitado 
	FROM dbo.TI_ConceptoPago c
		INNER JOIN dbo.TC_Concepto cp ON cp.I_ConceptoID = c.I_ConceptoID
		INNER JOIN dbo.TC_Proceso p ON p.I_ProcesoID = c.I_ProcesoID
		INNER JOIN dbo.TC_CategoriaPago catg ON catg.I_CatPagoID = p.I_CatPagoID
	WHERE  c.B_Eliminado = 0 
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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoConceptoPago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoConceptoPago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoConceptoPago]
	 @I_ConcPagID	int
	,@B_Habilitado	bit
	,@D_FecMod		datetime
	,@CurrentUserId	int

	,@B_Result	bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TI_ConceptoPago
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
				WHERE I_ConcPagID = @I_ConcPagID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
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
	,@B_Archivos		bit
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

		IF (@B_Archivos = 1)
		BEGIN
			INSERT INTO TI_TipoArchivo_EntidadFinanciera(I_EntidadFinanID, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
								SELECT @I_EntidadFinanID, I_TipoArchivoID, 0, 0, @CurrentUserId, @D_FecCre
								FROM TC_TipoArchivo
		END

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

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarTiposArchivoEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_I_GrabarTiposArchivoEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarTiposArchivoEntidadFinanciera]
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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarTipoArchivoEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_I_GrabarTipoArchivoEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarTipoArchivoEntidadFinanciera]
	 @I_TipoArchivoID	int
	,@I_EntidadFinanID	int
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TI_TipoArchivo_EntidadFinanciera(I_EntidadFinanID, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							VALUES(@I_EntidadFinanID, @I_TipoArchivoID, 1, 0, @CurrentUserId, @D_FecCre)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarTipoArchivoEntidadFinanciera')
	DROP PROCEDURE [dbo].[USP_U_ActualizarTipoArchivoEntidadFinanciera]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarTipoArchivoEntidadFinanciera]
	 @I_TipArchivoEntFinanID int
	,@I_EntidadFinanID	int
	,@I_TipoArchivoID	int
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TI_TipoArchivo_EntidadFinanciera 
		SET	  I_EntidadFinanID = @I_EntidadFinanID
			, I_TipoArchivoID = @I_TipoArchivoID
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId
		WHERE I_TipArchivoEntFinanID = @I_TipArchivoEntFinanID		

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

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarConceptosCategoriaPago')
		DROP PROCEDURE [dbo].[USP_IU_GrabarConceptosCategoriaPago]

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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarConceptosCategoriaPago')
	DROP PROCEDURE [dbo].[USP_IU_GrabarConceptosCategoriaPago]
GO

CREATE PROCEDURE [dbo].[USP_IU_GrabarConceptosCategoriaPago]
	 @I_CatPagoID	int
	,@Tbl_Conceptos	[dbo].[type_SelectItems] READONLY

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY				
		MERGE TI_ConceptoCategoriaPago AS TRG
		USING @Tbl_Conceptos AS SRC
		ON  TRG.I_CatPagoID = @I_CatPagoID AND TRG.I_ConceptoID = SRC.C_ID
		WHEN NOT MATCHED BY TARGET THEN 
				INSERT (I_CatPagoID, I_ConceptoID )
				VALUES	(@I_CatPagoID, CAST(SRC.C_ID as int))
		WHEN NOT MATCHED BY SOURCE AND TRG.I_CatPagoID = @I_CatPagoID THEN 
				DELETE;

		SET @B_Result = 1
		SET @T_Message = 'Conceptos registrados.'
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
	,@T_Clasificador	varchar(50)
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
		INSERT INTO TC_Concepto(T_ConceptoDesc, T_Clasificador, I_Monto, I_MontoMinimo, B_EsPagoMatricula, B_EsPagoExtmp, B_ConceptoAgrupa, 
								B_Calculado, I_Calculado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
						VALUES (@T_ConceptoDesc, @T_Clasificador, @I_Monto, @I_MontoMinimo, @B_EsPagoMatricula, @B_EsPagoExtmp, @B_ConceptoAgrupa,
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
	,@T_Clasificador	varchar(50)
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
			, T_Clasificador = @T_Clasificador
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
	,@B_AlumnosPregrado bit
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
		
			CREATE TABLE #Tmp_Matricula
			(
				C_CodRC			VARCHAR(3),
				C_CodAlu		VARCHAR(20),
				I_Anio			INT,
				C_Periodo		VARCHAR(50),
				I_Periodo		INT,
				C_EstMat		VARCHAR(2),
				C_Ciclo			VARCHAR(2),
				B_Ingresante	BIT,
				I_CredDesaprob	TINYINT,
				B_ActObl		BIT
			)

			CREATE TABLE #Tmp_AlumnosSinOglibaciones
			(
				C_CodRC			VARCHAR(3),
				C_CodAlu		VARCHAR(20),
				I_Anio			INT,
				C_Periodo		VARCHAR(50),
				I_Periodo		INT,
				C_EstMat		VARCHAR(2),
				C_Ciclo			VARCHAR(2),
				B_Ingresante	BIT,
				I_CredDesaprob	TINYINT,
				B_ActObl		BIT
			)

			IF (@B_AlumnosPregrado = 1) BEGIN
				INSERT #Tmp_Matricula(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob, B_ActObl)
				SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, c.I_OpcionID AS I_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_ActObl
				FROM @Tbl_Matricula AS m
				INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = m.C_Periodo
				INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = a.C_RcCod
				WHERE c.B_Eliminado = 0 AND a.N_Grado = '1';
			END 
			ELSE BEGIN
				INSERT #Tmp_Matricula(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob, B_ActObl)
				SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, c.I_OpcionID AS I_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_ActObl
				FROM @Tbl_Matricula AS m
				INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = m.C_Periodo
				INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = a.C_RcCod
				WHERE c.B_Eliminado = 0 AND a.N_Grado IN ('2', '3');
			END;

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
			
			
			--Actualizo información de alumnos que tengan obligaciones generadas pero que NO esten pagas.
			UPDATE mat SET
				mat.C_EstMat = tmp.C_EstMat, mat.C_Ciclo = tmp.C_Ciclo, mat.B_Ingresante = tmp.B_Ingresante, mat.I_CredDesaprob = tmp.I_CredDesaprob,
				mat.I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
			FROM dbo.TC_MatriculaAlumno mat
			INNER JOIN #Tmp_Matricula AS tmp ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo
			WHERE mat.B_Eliminado = 0 AND NOT EXISTS(
				SELECT m.I_MatAluID FROM dbo.TC_MatriculaAlumno m
				INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = m.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1
				WHERE m.B_Eliminado = 0 AND tmp.C_CodRc = m.C_CodRc AND tmp.C_CodAlu = m.C_CodAlu AND tmp.I_Anio = m.I_Anio AND tmp.I_Periodo = m.I_Periodo
			)

			--Después elimino dichas obligaciones(en detalle) para que se generen de nuevo.
			UPDATE det SET det.B_Habilitado = 0, det.B_Eliminado = 1, det.I_UsuarioMod = @UserID, det.D_FecMod = @D_FecRegistro
			FROM #Tmp_Matricula tmp
			INNER JOIN dbo.TC_MatriculaAlumno mat ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo AND mat.B_Eliminado = 0
			INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0
			WHERE NOT EXISTS(
				SELECT m.I_MatAluID FROM dbo.TC_MatriculaAlumno m
				INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = m.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1
				WHERE m.B_Eliminado = 0 AND tmp.C_CodRc = m.C_CodRc AND tmp.C_CodAlu = m.C_CodAlu AND tmp.I_Anio = m.I_Anio AND tmp.I_Periodo = m.I_Periodo
			)

			--Después elimino dichas obligaciones(en cabecera) para que se generen de nuevo.
			UPDATE cab SET cab.B_Habilitado = 0, cab.B_Eliminado = 1, cab.I_UsuarioMod = @UserID, cab.D_FecMod = @D_FecRegistro
			FROM #Tmp_Matricula tmp
			INNER JOIN dbo.TC_MatriculaAlumno mat ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo AND mat.B_Eliminado = 0
			INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
			WHERE NOT EXISTS(
				SELECT m.I_MatAluID FROM dbo.TC_MatriculaAlumno m
				INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = m.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1
				WHERE m.B_Eliminado = 0 AND tmp.C_CodRc = m.C_CodRc AND tmp.C_CodAlu = m.C_CodAlu AND tmp.I_Anio = m.I_Anio AND tmp.I_Periodo = m.I_Periodo
			)

			--Insert para alumnos nuevos
			MERGE INTO TC_MatriculaAlumno AS trg USING #Tmp_Matricula AS src
			ON trg.C_CodRc = src.C_CodRc AND trg.C_CodAlu = src.C_CodAlu AND trg.I_Anio = src.I_Anio AND trg.I_Periodo = src.I_Periodo AND trg.B_Eliminado = 0
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
			 	VALUES (src.C_CodRc, src.C_CodAlu, src.I_Anio, src.I_Periodo, src.C_EstMat, src.C_Ciclo, src.B_Ingresante, src.I_CredDesaprob, 1, 0, @UserID, @D_FecRegistro);

			--Informar relación de alumnos que ya tienen obligaciones pagadas y de alumnos inexistentes.
			SELECT DISTINCT tmp.C_CodRC, tmp.C_CodAlu, tmp.I_Anio, tmp.C_Periodo, tmp.C_EstMat, tmp.C_Ciclo, tmp.B_Ingresante, tmp.I_CredDesaprob, 0 as B_Success, 'El alumno tiene obligaciones pagadas.' AS T_Message 
			FROM #Tmp_Matricula tmp
			INNER JOIN dbo.TC_MatriculaAlumno mat ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo AND mat.B_Eliminado = 0
			INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = mat.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1
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
	declare @N_GradoBachiller char(1) = '1'

	select p.I_ProcesoID, p.D_FecVencto, cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,
	conpag.B_Calculado, conpag.I_Calculado, conpag.B_GrupoCodRc, gr.T_OpcionCod AS I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng, 
	con.B_EsPagoMatricula, con.B_EsPagoExtmp, conpag.N_NroPagos, cp.I_Prioridad
	into #tmp_conceptos_pregrado
	from dbo.TC_Proceso p
	inner join dbo.TC_CategoriaPago cp on cp.I_CatPagoID = p.I_CatPagoID
	inner join dbo.TI_ConceptoPago conpag on conpag.I_ProcesoID = p.I_ProcesoID
	inner join dbo.TC_Concepto con on con.I_ConceptoID = conpag.I_ConceptoID
	left join dbo.TC_CatalogoOpcion moding on moding.I_ParametroID = 7 and moding.I_OpcionID = conpag.I_ModalidadIngresoID
	left join dbo.TC_CatalogoOpcion gr on gr.I_ParametroID = 6 and gr.I_OpcionID = conpag.I_GrupoCodRc
	where p.B_Habilitado = 1 and p.B_Eliminado = 0 and
		conpag.B_Habilitado = 1 and conpag.B_Eliminado = 0 and
		cp.B_Obligacion = 1 and p.I_Anio = @I_Anio and p.I_Periodo = @I_Periodo and cp.I_Nivel = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod = @N_GradoBachiller)
	
	--2do Obtengo la relación de alumnos
	declare @Tmp_MatriculaAlumno table (id int identity(1,1), I_MatAluID int, C_CodRc varchar(3), C_CodAlu varchar(20), C_EstMat varchar(2), B_Ingresante bit, C_CodModIng varchar(2), N_Grupo char(1), I_CredDesaprob tinyint)
	
	if (@C_CodAlu is not null) and (@C_CodRc is not null) begin
		insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
		select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) 
		from dbo.TC_MatriculaAlumno m 
		inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
		where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado = @N_GradoBachiller and
			m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
	end else begin
		if (@C_CodFac is null) or (@C_CodFac = '') begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) 
			from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado = @N_GradoBachiller and
				m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo
		end else begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) 
			from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado = @N_GradoBachiller and
				m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and a.C_CodFac = @C_CodFac
		end
	end

	--3ro Comienzo con el calculo las obligaciones por alumno almacenandolas en @Tmp_Procesos.
	declare @Tmp_Procesos table (I_ProcesoID int, I_ConcPagID int, M_Monto decimal(15,2), D_FecVencto datetime, I_TipoObligacion int, I_Prioridad tinyint)

	declare @C_Moneda varchar(3) = 'PEN',
			@D_CurrentDate datetime = getdate(),
			@I_FilaActual int = 1,
			@I_CantRegistros int = (select max(id) from @Tmp_MatriculaAlumno),
			
			--Tipo de alumno
			@I_AlumnoRegular int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '1'),
			@I_AlumnoIngresante int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '2'),
			
			--Tipo obligación
			@I_Matricula int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '1'),
			@I_OtrosPagos int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '0'),

			--Campo calculado
			@I_CrdtDesaprobados int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '1'),
			@I_DeudasAnteriores int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '2'),
			@I_Pensiones int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '3'),
			
			--Otras variables
			@I_ObligacionAluID int,
			@I_MatAluID int,
			@C_EstMat varchar(2),
			@C_CodModIng varchar(2),
			@N_Grupo char(1),
			@I_TipoAlumno int,
			@I_MontoDeuda decimal(15,2),
			@I_CredDesaprob tinyint,
			@N_NroPagos tinyint,

			--Variables para comprobar modificaciones
			@I_MontoInicial decimal(15,2),
			@I_MontoActual decimal(15,2),
			@D_FecVenctoInicial datetime,
			@D_FecVenctoActual datetime,
			@I_ProcesoID int,
			@B_Pagado bit

	declare @Tmp_grupo_otros_pagos table (id int, I_ProcesoID int)
	declare @I_FilaActual_OtrsPag int,
			@I_CantRegistros_OtrsPag int,
			@I_ProcesoID_OtrsPag int

	while (@I_FilaActual <= @I_CantRegistros) begin
		begin tran
		begin try
			
			--4to obtengo la información alumno por alumno e inicializo variables
			select @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, 
				@N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0), 
				@I_TipoAlumno = (case when B_Ingresante = 0 then @I_AlumnoRegular else @I_AlumnoIngresante end) 
			from @Tmp_MatriculaAlumno 
			where id = @I_FilaActual

			delete @Tmp_Procesos

			--Pagos de Matrícula
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng
			end
			else
			begin
				if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1) = 1
				begin
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
						B_EsPagoMatricula = 1
				end	
			end

			--Pagos generales de matrícula
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
			select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and
				B_EsPagoMatricula = 0 and B_Calculado = 0 and B_GrupoCodRc = 0 and B_EsPagoExtmp = 0

			--Pagos de laboratorio
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 0 and B_GrupoCodRc = 1 and I_GrupoCodRc = @N_Grupo) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_GrupoCodRc = 1 and I_GrupoCodRc = @N_Grupo
			end

			--Pagos extemoráneos
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0
			end

			--Monto de deuda anterior
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado 
				where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores) = 1
			begin
				set @I_MontoDeuda = isnull((select SUM(cab.I_MontoOblig) from dbo.TR_ObligacionAluCab cab
					inner join (select top 1 m.I_MatAluID from dbo.TC_MatriculaAlumno m 
						where m.B_Eliminado = 0 and not m.I_MatAluID = @I_MatAluID and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
						order by m.I_Anio desc, m.C_Ciclo desc) mat on mat.I_MatAluID = cab.I_MatAluID
					where cab.B_Eliminado = 0 and cab.B_Pagado = 0), 0)

				if (@I_MontoDeuda > 0)
				begin
					set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores), 1);

					with CTE_Recursivo as
					(
						select 1 as num, I_ProcesoID, I_ConcPagID, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores
						union all
						select num + 1, I_ProcesoID, I_ConcPagID, D_FecVencto, I_TipoObligacion, I_Prioridad
						from CTE_Recursivo
						where num < @N_NroPagos
					)
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, dbo.FN_CalcularCuotasDeuda(@I_MontoDeuda, @N_NroPagos, num) AS M_Monto, 
						DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
					from CTE_Recursivo;
				end
			end
			
			--Monto de cursos desaprobados
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados) = 1
			begin
				if (@I_CredDesaprob > 0)
				begin
					set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados), 1);

					with CTE_Recursivo as
					(
						select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados
						union all
						select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
						from CTE_Recursivo
						where num < @N_NroPagos
					)
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, cast((M_Monto * @I_CredDesaprob) / @N_NroPagos as decimal(15,2)), 
						DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
					from CTE_Recursivo
				end
			end

			--Monto de Pensión de enseñanza
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng) = 1
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, cast(M_Monto / @N_NroPagos as decimal(15,2)) as M_Monto, 
					DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
				from CTE_Recursivo
			end

			--Grabando pago de matrícula
			set @I_ProcesoID = 0

			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)
			begin
				set @I_ProcesoID = (select distinct p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)

				if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID)
				begin
					select @I_MontoInicial = cab.I_MontoOblig, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

					select @D_FecVenctoActual = p.D_FecVencto, @I_MontoActual = Sum(p.M_Monto) from @Tmp_Procesos p 
					where p.I_Prioridad = 1 group by p.D_FecVencto

					if (@B_Pagado = 0)
					begin
						if Not (DATEDIFF(Day, @D_FecVenctoInicial, @D_FecVenctoActual) = 0) Or Not (@I_MontoInicial = @I_MontoActual)
						begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 1 
							group by p.I_ProcesoID, p.D_FecVencto

							set @I_ObligacionAluID = SCOPE_IDENTITY()

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
							where p.I_Prioridad = 1
						end
					end
				end
				else
				begin
					--insert
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 1 
					group by p.I_ProcesoID, p.D_FecVencto

					set @I_ObligacionAluID = SCOPE_IDENTITY()

					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
					where p.I_Prioridad = 1
				end
			end

			--Grabando otros pagos
			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2)
			begin
				if not exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
					where cab.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and
						cab.I_ProcesoID in (select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2))
				begin
					--Nuevos registros de obligaciones

					--Insert de cabecera
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID, p.D_FecVencto

					--Insert de detalle
					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
					inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID and cab.I_MatAluID = @I_MatAluID and
						DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
					where p.I_Prioridad = 2
				end
				else
				begin
					--Edición de obligaciones

					if exists(select id from @Tmp_grupo_otros_pagos) begin
						delete @Tmp_grupo_otros_pagos
					end

					insert @Tmp_grupo_otros_pagos(id, I_ProcesoID)
					select ROW_NUMBER() OVER (ORDER BY I_ProcesoID), I_ProcesoID from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID
					
					set @I_FilaActual_OtrsPag = 1
					set @I_CantRegistros_OtrsPag = (select max(id) from @Tmp_grupo_otros_pagos)

					while (@I_FilaActual_OtrsPag <= @I_CantRegistros_OtrsPag) begin
						--Los otros pagos se agrupan primero por proceso y luego por fecha de vcto.
						set @I_ProcesoID_OtrsPag = (select I_ProcesoID from @Tmp_grupo_otros_pagos where id = @I_FilaActual_OtrsPag)

						if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
							inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
							where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and 
							cab.I_ProcesoID = @I_ProcesoID_OtrsPag AND cab.B_Pagado = 1) begin
							
							print 'Existen al menos un pago realizado.'

						end
						else begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID_OtrsPag

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID_OtrsPag

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
							group by p.I_ProcesoID, p.D_FecVencto

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
							inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID  and cab.I_MatAluID = @I_MatAluID and
								DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
						end

						set @I_FilaActual_OtrsPag = (@I_FilaActual_OtrsPag + 1)
					end
				end
			end

			commit tran
		end try
		begin catch
			rollback tran

			print ERROR_MESSAGE()
			print ERROR_LINE()
		end catch

		set @I_FilaActual = (@I_FilaActual +1)
	end

	set @B_Result = 1
	set @T_Message = 'El proceso finalizó correctamente.'
/*

declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPregrado_X_Ciclo @I_Anio = 2021, @I_Periodo = 15, 
@C_CodFac = null, @C_CodAlu = null, @C_CodRc = null, @I_UsuarioCre = 1,
@B_Result = @B_Result OUTPUT,
@T_Message = @T_Message OUTPUT
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
@C_CodAlu varchar(20) = null,
@C_CodRc varchar(3) = null,
@I_UsuarioCre int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	declare @N_GradoMaestria char(1) = '2'
	declare @N_Doctorado char(1) = '3'
	 
	--1ro Obtener los conceptos según año y periodo
	select p.I_ProcesoID, p.D_FecVencto, cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,
	conpag.B_Calculado, conpag.I_Calculado, conpag.B_GrupoCodRc,  conpag.I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng, 
	con.B_EsPagoMatricula, con.B_EsPagoExtmp, conpag.N_NroPagos, cp.I_Prioridad, cp.I_Nivel, niv.T_OpcionCod as C_Nivel
	into #tmp_conceptos_posgrado
	from dbo.TC_Proceso p
	inner join dbo.TC_CategoriaPago cp on cp.I_CatPagoID = p.I_CatPagoID
	inner join dbo.TI_ConceptoPago conpag on conpag.I_ProcesoID = p.I_ProcesoID
	inner join dbo.TC_Concepto con on con.I_ConceptoID = conpag.I_ConceptoID
	left join dbo.TC_CatalogoOpcion moding on moding.I_ParametroID = 7 and moding.I_OpcionID = conpag.I_ModalidadIngresoID
	left join dbo.TC_CatalogoOpcion gr on gr.I_ParametroID = 6 and gr.I_OpcionID = conpag.I_GrupoCodRc
	left join dbo.TC_CatalogoOpcion niv on niv.I_ParametroID = 2 and niv.I_OpcionID = cp.I_Nivel
	where p.B_Habilitado = 1 and p.B_Eliminado = 0 and
		conpag.B_Habilitado = 1 and conpag.B_Eliminado = 0 and
		cp.B_Obligacion = 1 and p.I_Anio = @I_Anio and p.I_Periodo = @I_Periodo and cp.I_Nivel in (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod IN (@N_GradoMaestria, @N_Doctorado))
		--cp.B_Obligacion = 1 and p.I_Anio = 2021 and p.I_Periodo = 19 and cp.I_Nivel in (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod IN ('2', '3'))

	--2do Obtengo la relación de alumnos
	declare @Tmp_MatriculaAlumno table (id int identity(1,1), I_MatAluID int, C_CodRc varchar(3), C_CodAlu varchar(20), C_EstMat varchar(2), 
		B_Ingresante bit, C_CodModIng varchar(2), N_Grupo char(1), I_CredDesaprob tinyint, N_Grado char(1))
	
	if (@C_CodAlu is not null) and (@C_CodRc is not null) begin
		insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob, N_Grado)
		select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0), a.N_Grado 
		from dbo.TC_MatriculaAlumno m 
		inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
		where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado IN (@N_GradoMaestria, @N_Doctorado) and
			m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
	end else begin
		insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob, N_Grado)
		select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0), a.N_Grado
		from dbo.TC_MatriculaAlumno m 
		inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
		where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado in (@N_GradoMaestria, @N_Doctorado) and
			m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo
	end
	
	--3ro Comienzo con el calculo las obligaciones por alumno almacenandolas en @Tmp_Procesos.
	declare @Tmp_Procesos table (I_ProcesoID int, I_ConcPagID int, M_Monto decimal(15,2), D_FecVencto datetime, I_TipoObligacion int, I_Prioridad tinyint)

	declare @C_Moneda varchar(3) = 'PEN',
			@D_CurrentDate datetime = getdate(),
			@I_FilaActual int = 1,
			@I_CantRegistros int = (select max(id) from @Tmp_MatriculaAlumno),


			--Tipo de alumno
			@I_AlumnoRegular int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '1'),
			@I_AlumnoIngresante int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '2'),


			--Tipo obligación
			@I_Matricula int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '1'),
			@I_OtrosPagos int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '0'),


			--Campo calculado
			@I_CrdtDesaprobados int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '1'),
			@I_DeudasAnteriores int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '2'),
			@I_Pensiones int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '3'),

			--Otras variables
			@I_ObligacionAluID int,
			@I_MatAluID int,
			@C_EstMat varchar(2),
			@C_CodModIng varchar(2),
			@N_Grupo char(1),
			@I_TipoAlumno int,
			@I_MontoDeuda decimal(15,2),
			@I_CredDesaprob tinyint,
			@N_NroPagos tinyint,
			@N_Grado char(1),

			--Variables para comprobar modificaciones
			@I_MontoInicial decimal(15,2),
			@I_MontoActual decimal(15,2),
			@D_FecVenctoInicial datetime,
			@D_FecVenctoActual datetime,
			@I_ProcesoID int,
			@B_Pagado bit

	declare @Tmp_grupo_otros_pagos table (id int, I_ProcesoID int)
	declare @I_FilaActual_OtrsPag int,
			@I_CantRegistros_OtrsPag int,
			@I_ProcesoID_OtrsPag int

	while (@I_FilaActual <= @I_CantRegistros) begin
		begin tran
		begin try
			--4to obtengo la información alumno por alumno e inicializo variables
			select @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, 
				@N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0), @N_Grado = N_Grado,
				@I_TipoAlumno = (case when B_Ingresante = 0 then @I_AlumnoRegular else @I_AlumnoIngresante end) 
			from @Tmp_MatriculaAlumno 
			where id = @I_FilaActual

			delete @Tmp_Procesos

			--Pagos de Matrícula
			if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng and C_Nivel = @N_Grado) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng and C_Nivel = @N_Grado
			end
			else
			begin
				if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_Nivel = @N_Grado) = 1
				begin
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
						B_EsPagoMatricula = 1 and C_Nivel = @N_Grado
				end	
			end

			--Pagos generales de matrícula
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
			select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and
				B_EsPagoMatricula = 0 and B_Calculado = 0 and B_GrupoCodRc = 0 and B_EsPagoExtmp = 0 and C_Nivel = @N_Grado

			--Pagos extemoráneos
			if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and C_Nivel = @N_Grado and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and C_Nivel = @N_Grado and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0
			end

			----Monto de deuda anterior
			--if (select count(I_ProcesoID) from #tmp_conceptos_posgrado 
			--	where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores and C_Nivel = @N_Grado) = 1
			--begin
			--	set @I_MontoDeuda = isnull((select SUM(cab.I_MontoOblig) from dbo.TR_ObligacionAluCab cab
			--		inner join (select top 1 m.I_MatAluID from dbo.TC_MatriculaAlumno m 
			--			where m.B_Eliminado = 0 and not m.I_MatAluID = @I_MatAluID and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
			--			order by m.I_Anio desc, m.C_Ciclo desc) mat on mat.I_MatAluID = cab.I_MatAluID
			--		where cab.B_Eliminado = 0 and cab.B_Pagado = 0), 0)

			--	if (@I_MontoDeuda > 0)
			--	begin
			--		set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
			--			where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores and C_Nivel = @N_Grado), 1);

			--		with CTE_Recursivo as
			--		(
			--			select 1 as num, I_ProcesoID, I_ConcPagID, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
			--			where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores and C_Nivel = @N_Grado
			--			union all
			--			select num + 1, I_ProcesoID, I_ConcPagID, D_FecVencto, I_TipoObligacion, I_Prioridad
			--			from CTE_Recursivo
			--			where num < @N_NroPagos
			--		)
			--		insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
			--		select I_ProcesoID, I_ConcPagID, dbo.FN_CalcularCuotasDeuda(@I_MontoDeuda, @N_NroPagos, num) AS M_Monto, 
			--			DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
			--		from CTE_Recursivo;
			--	end
			--end

			------Monto de cursos desaprobados
			--if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
			--		where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados and C_Nivel = @N_Grado) = 1
			--begin
			--	if (@I_CredDesaprob > 0)
			--	begin
			--		set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
			--			where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados and C_Nivel = @N_Grado), 1);

			--		with CTE_Recursivo as
			--		(
			--			select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
			--			where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados and C_Nivel = @N_Grado
			--			union all
			--			select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
			--			from CTE_Recursivo
			--			where num < @N_NroPagos
			--		)
			--		insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
			--		select I_ProcesoID, I_ConcPagID, cast((M_Monto * @I_CredDesaprob) / @N_NroPagos as decimal(15,2)), 
			--			DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
			--		from CTE_Recursivo
			--	end
			--end
			
			--Monto de Pensión de enseñanza
			if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_Nivel = @N_Grado) = 1
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_Nivel = @N_Grado), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_Nivel = @N_Grado
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, cast(M_Monto / @N_NroPagos as decimal(15,2)) as M_Monto, 
					DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
				from CTE_Recursivo
			end

			--Grabando pago de matrícula
			set @I_ProcesoID = 0

			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)
			begin
				set @I_ProcesoID = (select distinct p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)

				if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID)
				begin
					select @I_MontoInicial = cab.I_MontoOblig, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

					select @D_FecVenctoActual = p.D_FecVencto, @I_MontoActual = Sum(p.M_Monto) from @Tmp_Procesos p 
					where p.I_Prioridad = 1 group by p.D_FecVencto

					if (@B_Pagado = 0)
					begin
						if Not (DATEDIFF(Day, @D_FecVenctoInicial, @D_FecVenctoActual) = 0) Or Not (@I_MontoInicial = @I_MontoActual)
						begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 1 
							group by p.I_ProcesoID, p.D_FecVencto

							set @I_ObligacionAluID = SCOPE_IDENTITY()

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
							where p.I_Prioridad = 1
						end
					end
				end
				else
				begin
					--insert
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 1 
					group by p.I_ProcesoID, p.D_FecVencto

					set @I_ObligacionAluID = SCOPE_IDENTITY()

					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
					where p.I_Prioridad = 1
				end
			end

			--Grabando otros pagos
			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2)
			begin
				if not exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
					where cab.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and
						cab.I_ProcesoID in (select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2))
				begin
					--Nuevos registros de obligaciones

					--Insert de cabecera
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID, p.D_FecVencto

					--Insert de detalle
					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
					inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID and cab.I_MatAluID = @I_MatAluID and
						DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
					where p.I_Prioridad = 2
				end
				else
				begin
					--Edición de obligaciones

					if exists(select id from @Tmp_grupo_otros_pagos) begin
						delete @Tmp_grupo_otros_pagos
					end

					insert @Tmp_grupo_otros_pagos(id, I_ProcesoID)
					select ROW_NUMBER() OVER (ORDER BY I_ProcesoID), I_ProcesoID from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID
					
					set @I_FilaActual_OtrsPag = 1
					set @I_CantRegistros_OtrsPag = (select max(id) from @Tmp_grupo_otros_pagos)

					while (@I_FilaActual_OtrsPag <= @I_CantRegistros_OtrsPag) begin
						--Los otros pagos se agrupan primero por proceso y luego por fecha de vcto.
						set @I_ProcesoID_OtrsPag = (select I_ProcesoID from @Tmp_grupo_otros_pagos where id = @I_FilaActual_OtrsPag)

						if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
							inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
							where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and 
							cab.I_ProcesoID = @I_ProcesoID_OtrsPag AND cab.B_Pagado = 1) begin
							
							print 'Existen al menos un pago realizado.'

						end
						else begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID_OtrsPag

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID_OtrsPag

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
							group by p.I_ProcesoID, p.D_FecVencto

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
							inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID  and cab.I_MatAluID = @I_MatAluID and
								DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
						end

						set @I_FilaActual_OtrsPag = (@I_FilaActual_OtrsPag + 1)
					end
				end
			end

			commit tran
		end try
		begin catch
			rollback tran

			print ERROR_MESSAGE()
			print ERROR_LINE()
		end catch

		set @I_FilaActual = (@I_FilaActual +1)
	end

	set @B_Result = 1
	set @T_Message = 'El proceso finalizó correctamente.'
/*
declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPosgrado_X_Ciclo  2021, 19, NULL, NULL, 1,
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
SELECT 
	cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_CodRc, a.C_CodFac, a.T_Nombre, a.T_ApePaterno, a.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, 
	pro.T_ProcesoDesc, ISNULL(cp.T_ConceptoPagoDesc, con.T_ConceptoDesc) AS T_ConceptoDesc, cat.T_CatPagoDesc, det.I_Monto, det.B_Pagado, cab.D_FecVencto, pro.I_Prioridad,
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
SELECT 
	ROW_NUMBER() OVER(PARTITION BY mat.I_Anio, mat.I_Periodo, mat.C_CodRc, mat.C_CodAlu ORDER BY pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
	cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_CodRc, a.C_CodFac, a.T_Nombre, a.T_ApePaterno, a.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,
	niv.T_OpcionCod AS C_Nivel, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,
	cab.B_Pagado, pagban.C_CodOperacion, pagban.D_FecPago, pagban.T_LugarPago
FROM dbo.TC_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = mat.C_CodAlu AND a.C_RcCod = mat.C_CodRc
LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0
LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_MatriculaAlumno')
	DROP VIEW [dbo].[VW_MatriculaAlumno]
GO

CREATE VIEW [dbo].[VW_MatriculaAlumno]
AS
SELECT 
	m.I_MatAluID, a.C_CodAlu, a.C_RcCod, a.T_Nombre, a.T_ApePaterno, a.T_ApeMaterno, a.N_Grado, m.I_Anio, m.I_Periodo, 
	a.C_CodFac, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_Habilitado
FROM TC_MatriculaAlumno m 
INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRc
WHERE m.B_Eliminado = 0
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
	SET NOCOUNT ON;

	DECLARE @Tmp_PagoObligacion TABLE (
		id INT IDENTITY(1,1),
		I_ObligacionAluID	int,
		C_CodOperacion		varchar(50),
		C_CodDepositante	varchar(20),
		T_NomDepositante	varchar(200),
		C_Referencia		varchar(50),
		D_FecPago			datetime,
		I_Cantidad			int,
		C_Moneda			varchar(3),
		I_MontoOblig		decimal(15,2),
		I_MontoPago			decimal(15,2),
		T_LugarPago			varchar(250)
	);

	WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto, B_Pagado, I_MontoOblig)
	AS 
	(
		SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto, cab.B_Pagado, cab.I_MontoOblig 
		FROM dbo.TC_MatriculaAlumno m
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID
		WHERE m.B_Eliminado = 0 AND cab.B_Eliminado = 0 AND cab.B_Pagado = 0
	)
	INSERT @Tmp_PagoObligacion(I_ObligacionAluID, C_CodOperacion, C_CodDepositante, T_NomDepositante, 
		C_Referencia, D_FecPago, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, T_LugarPago)
	SELECT m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,
		p.C_Referencia, p.D_FecPago, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, p.T_LugarPago 
	FROM @Tbl_Pagos p
	INNER JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND 
		m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0 --AND m.I_MontoOblig = p.I_MontoPago

	--select * FROM @Tmp_PagoObligacion

	DECLARE @I_FilaActual		int = 1,
			@I_CantRegistros	int = (select count(id) from @Tmp_PagoObligacion),
			@I_CantPagosRegistrados int = 0,
			@B_Pagado bit,
			-----------------------------------------------------------
			@I_PagoBancoID		int,
			@I_ObligacionAluID	int,
			@C_CodOperacion		varchar(50),
			@C_CodDepositante	varchar(20),
			@T_NomDepositante	varchar(200),
			@C_Referencia		varchar(50),
			@D_FecPago			datetime,
			@I_Cantidad			int,
			@C_Moneda			varchar(3),
			@I_MontoOblig		decimal(15,2),
			@I_MontoPago		decimal(15,2),
			@I_SaldoAPagar		decimal(15,2),
			@I_PagoDemas		decimal(15,2),
			@B_PagoDemas		decimal(15,2),
			@T_LugarPago		varchar(250)
	
	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN
		
		--PRINT 'FILA: ' + CAST(@I_FilaActual AS VARCHAR)

		BEGIN TRANSACTION
		BEGIN TRY
			SELECT 
				@I_ObligacionAluID = I_ObligacionAluID, 
				@C_CodOperacion = C_CodOperacion, 
				@C_CodDepositante = C_CodDepositante, 
				@T_NomDepositante = T_NomDepositante, 
				@C_Referencia = C_Referencia, 
				@D_FecPago = D_FecPago, 
				@I_Cantidad = I_Cantidad,
				@C_Moneda = C_Moneda, 
				@I_MontoOblig = I_MontoOblig,
				@I_MontoPago = I_MontoPago, 
				@T_LugarPago= T_LugarPago
			FROM @Tmp_PagoObligacion WHERE id = @I_FilaActual

			INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad, 
				C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre)
			VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad, 
				@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro)

			SET @I_PagoBancoID = SCOPE_IDENTITY()

			--PRINT '@I_PagoBancoID: ' + CAST(@I_PagoBancoID AS VARCHAR)

			SET @I_SaldoAPagar = CASE WHEN (@I_MontoOblig > @I_MontoPago) THEN (@I_MontoOblig - @I_MontoPago) ELSE 0 END

			SET @B_Pagado = CASE WHEN (@I_SaldoAPagar = 0) THEN 1 ELSE 0 END

			SET @I_PagoDemas = CASE WHEN (@I_MontoPago > @I_MontoOblig) THEN (@I_MontoPago - @I_MontoOblig) ELSE 0 END

			SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END

			INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,
				B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado)
			VALUES(@I_PagoBancoID, @I_ObligacionAluID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas, 
				@B_PagoDemas, @D_FecRegistro, @UserID, 0)

			UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
			WHERE I_ObligacionAluID = @I_ObligacionAluID
			
			UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
			WHERE I_ObligacionAluID = @I_ObligacionAluID

			SET @I_CantPagosRegistrados = @I_CantPagosRegistrados + 1

			COMMIT TRANSACTION
			--PRINT 'COMMIT TRANSACTION'
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			--PRINT 'ROLLBACK TRANSACTION'
		END CATCH

		SET @I_FilaActual = @I_FilaActual + 1
	END

	SET @B_Result = 1
	SET @T_Message = 'Se han analizado "' + CAST(@I_CantRegistros AS VARCHAR) + 
		'" pago(s). Se han registrado "' + CAST(@I_CantPagosRegistrados AS VARCHAR) + '" pago(s).'
END
GO





IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CtaDepositoProceso')
	DROP VIEW [dbo].[VW_CtaDepositoProceso]
GO

CREATE VIEW [dbo].[VW_CtaDepositoProceso]
AS
SELECT 
	ctapro.I_CtaDepoProID, e.I_EntidadFinanID, e.T_EntidadDesc, ctadepo.I_CtaDepositoID, ctadepo.C_NumeroCuenta, ctadepo.T_DescCuenta, 
	p.I_ProcesoID, p.T_ProcesoDesc, p.I_Prioridad, p.I_Anio, p.I_Periodo, per.T_OpcionCod as C_Periodo, per.T_OpcionDesc as T_PeriodoDesc, cat.I_Nivel, niv.T_OpcionCod AS C_Nivel, ctapro.B_Habilitado 
FROM dbo.TC_Proceso p
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = p.I_CatPagoID and cat.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TI_CtaDepo_Proceso ctapro ON ctapro.I_ProcesoID = p.I_ProcesoID AND ctapro.B_Eliminado = 0
INNER JOIN dbo.TC_CuentaDeposito ctadepo ON ctadepo.I_CtaDepositoID = ctapro.I_CtaDepositoID AND ctadepo.B_Eliminado = 0
INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID = ctadepo.I_EntidadFinanID AND e.B_Eliminado = 0
LEFT JOIN dbo.TC_CatalogoOpcion per on per.I_ParametroID = 5 and per.I_OpcionID = p.I_Periodo
WHERE p.B_Eliminado = 0
GO

/*---------------------------- -------------*/


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarSeccionArchivo')
	DROP PROCEDURE [dbo].[USP_I_GrabarSeccionArchivo]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarSeccionArchivo]
	 @I_SecArchivoID	int
	,@T_SecArchivoDesc	varchar(50)
	,@I_TipoSeccion		tinyint
	,@I_FilaInicio		smallint
	,@I_FilaFin			smallint
	,@I_TipArchivoEntFinanID	int
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TC_SeccionArchivo(T_SecArchivoDesc, I_TipoSeccion, I_FilaInicio, I_FilaFin, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_TipArchivoEntFinanID)
							  VALUES (@T_SecArchivoDesc, @I_TipoSeccion, @I_FilaInicio, @I_FilaFin, 1, 0, @CurrentUserId, @D_FecCre, @I_TipArchivoEntFinanID)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarSeccionArchivo')
	DROP PROCEDURE [dbo].[USP_U_ActualizarSeccionArchivo]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarSeccionArchivo]
	 @I_SecArchivoID	int
	,@T_SecArchivoDesc	varchar(50)
	,@I_TipoSeccion		tinyint
	,@I_FilaInicio		smallint
	,@I_FilaFin			smallint
	,@I_TipArchivoEntFinanID	int
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_SeccionArchivo 
		SET	T_SecArchivoDesc = @T_SecArchivoDesc
			, I_FilaInicio = @I_FilaInicio
			, I_TipoSeccion = @I_TipoSeccion
			, I_FilaFin = @I_FilaFin
			, I_TipArchivoEntFinanID = @I_TipArchivoEntFinanID
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId
		WHERE I_SecArchivoID = @I_SecArchivoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoSeccionArchivo')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoSeccionArchivo]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoSeccionArchivo]
	 @I_SecArchivoID	int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_SeccionArchivo 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
		WHERE I_SecArchivoID = @I_SecArchivoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


/*---------------------------- -------------*/


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarColumnaSeccion')
	DROP PROCEDURE [dbo].[USP_I_GrabarColumnaSeccion]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarColumnaSeccion]
	 @I_SecArchivoID	int
	,@I_CampoPagoID		int
	,@T_ColSecDesc		varchar(50)
	,@I_ColumnaInicio	smallint
	,@I_ColumnaFin		smallint
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TC_ColumnaSeccion (T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, I_CampoPagoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_SecArchivoID)
							   VALUES (@T_ColSecDesc, @I_ColumnaInicio, @I_ColumnaFin, @I_CampoPagoID, 1, 0, @CurrentUserId, @D_FecCre, @I_SecArchivoID)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarColumnaSeccion')
	DROP PROCEDURE [dbo].[USP_U_ActualizarColumnaSeccion]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarColumnaSeccion]
	 @I_ColSecID		int
	,@T_ColSecDesc		varchar(50)
	,@I_ColumnaInicio	smallint
	,@I_ColumnaFin		smallint
	,@I_SecArchivoID	int
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TC_ColumnaSeccion 
		SET	T_ColSecDesc = @T_ColSecDesc
			, I_ColumnaInicio = @I_ColumnaInicio
			, I_ColumnaFin = @I_ColumnaFin
			, I_SecArchivoID = @I_SecArchivoID
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId
		WHERE I_ColSecID = @I_ColSecID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoColumnaSeccion')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoColumnaSeccion]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoColumnaSeccion]
	 @I_ColSecID		int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TC_ColumnaSeccion 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
		WHERE   I_ColSecID = @I_ColSecID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


/*---------------------------- -------------*/


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCampoTablaPago')
	DROP PROCEDURE [dbo].[USP_I_GrabarCampoTablaPago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarCampoTablaPago]
	 @I_CampoPagoID		int
	,@T_TablaPagoNom	varchar(50)
	,@T_CampoPagoNom	varchar(50)
	,@T_CampoInfoDesc	varchar(50)
	,@I_TipoArchivoID	int
	,@D_FecCre			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		INSERT INTO TS_CampoTablaPago (T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							   VALUES (@T_TablaPagoNom, @T_CampoPagoNom, @T_CampoInfoDesc, @I_TipoArchivoID, 1, 0, @CurrentUserId, @D_FecCre)

		SET @B_Result = 1
		SET @T_Message = 'Nuevo registro agregado.'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarCampoTablaPago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarCampoTablaPago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarCampoTablaPago]
	 @I_CampoPagoID		int
	,@T_TablaPagoNom	varchar(50)
	,@T_CampoPagoNom	varchar(50)
	,@T_CampoInfoDesc	varchar(50)
	,@I_TipoArchivoID	int
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
	UPDATE	TS_CampoTablaPago 
		SET	T_TablaPagoNom = @T_TablaPagoNom
			, T_CampoPagoNom = @T_CampoPagoNom
			, T_CampoInfoDesc = @T_CampoInfoDesc
			, I_TipoArchivoID = @I_TipoArchivoID
			, D_FecMod = @D_FecMod
			, I_UsuarioMod = @CurrentUserId
		WHERE I_CampoPagoID = @I_CampoPagoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH

END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoCampoTablaPago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoCampoTablaPago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoCampoTablaPago]
	 @I_CampoPagoID		int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TS_CampoTablaPago 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
		WHERE   I_CampoPagoID = @I_CampoPagoID
			
		SET @B_Result = 1
		SET @T_Message = 'Actualización de datos correcta'
	END TRY
	BEGIN CATCH
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoEstrucArchivoEntFinan')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoEstrucArchivoEntFinan]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoEstrucArchivoEntFinan]
	 @I_TipArchivoEntFinanID	int
	,@B_Habilitado		bit
	,@D_FecMod			datetime
	,@CurrentUserId		int

	,@B_Result bit OUTPUT
	,@T_Message nvarchar(4000) OUTPUT	
AS
BEGIN
  SET NOCOUNT ON
  	BEGIN TRY
		UPDATE	TI_TipoArchivo_EntidadFinanciera 
		SET		B_Habilitado = @B_Habilitado,
				D_FecMod = @D_FecMod,
				I_UsuarioMod = @CurrentUserId
		WHERE   I_TipArchivoEntFinanID = @I_TipArchivoEntFinanID
			
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
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataAlumnoMultaNoVotar') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarAlumnoMultaNoVotar')
		DROP PROCEDURE [dbo].[USP_I_GrabarAlumnoMultaNoVotar]

	DROP TYPE [dbo].[type_dataAlumnoMultaNoVotar]
END
GO

CREATE TYPE [dbo].[type_dataAlumnoMultaNoVotar] AS TABLE(
	I_Anio			int			NULL,
	C_Periodo		char(1)		NULL,
	C_CodAlu		varchar(10) NULL,
	C_CodRC			varchar(3)  NULL
)
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarAlumnoMultaNoVotar')
	DROP PROCEDURE [dbo].[USP_I_GrabarAlumnoMultaNoVotar]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarAlumnoMultaNoVotar]
(
	 @Tbl_AlumnosMultaNoVotar	[dbo].[type_dataAlumnoMultaNoVotar]	READONLY
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
					
			CREATE TABLE #Tmp_AlumnoMultaNoVotar
			(
				C_CodRC			VARCHAR(3),
				C_CodAlu		VARCHAR(20),
				I_Anio			INT,
				C_Periodo		VARCHAR(50),
				I_Periodo		INT
			)

			
			INSERT #Tmp_AlumnoMultaNoVotar(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo)
			SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, c.I_OpcionID AS I_Periodo
			FROM @Tbl_AlumnosMultaNoVotar AS am
			INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = am.C_Periodo
			INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = am.C_CodAlu and a.C_RcCod = am.C_CodRC
			WHERE c.B_Eliminado = 0 AND a.N_Grado = '1';
			
			--Insert para alumnos nuevos
			MERGE INTO TC_AlumnoMultaNoVotar AS trg USING #Tmp_AlumnoMultaNoVotar AS src
			ON trg.C_CodRc = src.C_CodRc AND trg.C_CodAlu = src.C_CodAlu AND trg.I_Anio = src.I_Anio AND trg.I_Periodo = src.I_Periodo AND trg.B_Eliminado = 0
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
			 	VALUES (src.C_CodRc, src.C_CodAlu, src.I_Anio, src.I_Periodo, 1, 0, @UserID, @D_FecRegistro);

			--Informar los alumnos que ya tienen obligaciones (pagadas y sin pagar).
			(SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, 0 AS B_Success, 'El Alumno no existe en pregrado.' AS T_Message
			FROM @Tbl_AlumnosMultaNoVotar AS am
			LEFT JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = am.C_CodAlu and a.C_RcCod = am.C_CodRC AND a.N_Grado = '1'
			WHERE a.C_CodAlu IS NULL)
			UNION
			(SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, 0 AS B_Success, 'El campo Periodo es incorrecto.' AS T_Message
			FROM @Tbl_AlumnosMultaNoVotar AS am
			LEFT JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = am.C_Periodo AND c.B_Eliminado = 0
			WHERE c.I_OpcionID IS NULL)


			COMMIT TRANSACTION

			SET @B_Result = 1
			SET @T_Message = 'El registro de los alumnos que no votaron finalizó de manera exitosa'
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO