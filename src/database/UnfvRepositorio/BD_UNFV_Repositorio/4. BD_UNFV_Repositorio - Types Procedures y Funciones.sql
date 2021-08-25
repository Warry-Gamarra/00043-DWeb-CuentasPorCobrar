USE BD_UNFV_Repositorio
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarAlumno')
	DROP PROCEDURE [dbo].[USP_I_GrabarAlumno]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarAlumno]
	 @I_PersonaID	int
	,@C_RcCod		varchar(3)
	,@C_CodAlu		varchar(20)
	,@C_CodModIng	varchar(2)
	,@C_AnioIngreso	smallint
	,@I_IdPlan		int
	,@D_FecCre		datetime
	,@I_UsuarioCre	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		INSERT INTO TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
			VALUES (@C_RcCod, @C_CodAlu, @I_PersonaID, @C_CodModIng, @C_AnioIngreso, @I_IdPlan, 1, 0, @I_UsuarioCre, @D_FecCre);

		SET @B_Result = 1;
		SET @T_Message = 'Alumno registrado.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarCarreraProfesional')
	DROP PROCEDURE [dbo].[USP_I_GrabarCarreraProfesional]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarCarreraProfesional]
	@C_RcCod		varchar(3)
	,@C_CodEsp		varchar(2)
	,@C_CodEsc		varchar(2)
	,@C_CodFac		varchar(2)
	,@I_Especialidad int
	,@T_CarProfDesc varchar(250)
	,@C_Tipo		char(1)
	,@I_Duracion	int
	,@B_Anual		bit
	,@N_Grupo		char(1)
	,@N_Grado		char(1)
	,@I_IdAplica	int = null
	,@D_FecCre		datetime
	,@I_UsuarioCre	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		INSERT INTO TI_CarreraProfesional (C_RcCod, C_CodEsp, C_CodEsc, C_CodFac, I_Especialidad, T_CarProfDesc, C_Tipo, I_Duracion, B_Anual, N_Grupo, N_Grado, I_IdAplica, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
			VALUES (@C_RcCod, @C_CodEsp, @C_CodEsc, @C_CodFac, @I_Especialidad, @T_CarProfDesc, @C_Tipo, @I_Duracion, @B_Anual, @N_Grupo, @N_Grado, @I_IdAplica, 1, 0, @I_UsuarioCre, @D_FecCre);

		SET @B_Result = 1;
		SET @T_Message = 'Carrera Profesional registrada.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPersona')
	DROP PROCEDURE [dbo].[USP_I_GrabarPersona]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPersona]
	 @C_NumDNI		varchar(20)
	,@C_CodTipDoc	varchar(5)
	,@T_ApePaterno	varchar(50)
	,@T_ApeMaterno  varchar(50) = null
	,@T_Nombre		varchar(50)
	,@D_FecNac		date = null
	,@C_Sexo		char(1) = null
	,@D_FecCre		datetime
	,@I_UsuarioCre	int
	,@I_PersonaID	int OUTPUT
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		INSERT INTO TC_Persona (C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
			VALUES (@C_NumDNI, @C_CodTipDoc, @T_ApePaterno, @T_ApeMaterno, @T_Nombre, @D_FecNac, @C_Sexo, 1, 0, @I_UsuarioCre, @D_FecCre);

		SET @I_PersonaID = SCOPE_IDENTITY();
		SET @B_Result = 1;
		SET @T_Message = 'Nueva persona registrada.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarProgramaUnfv')
	DROP PROCEDURE [dbo].[USP_I_GrabarProgramaUnfv]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarProgramaUnfv]
	 @C_CodProg		varchar(10)
	,@C_RcCod		varchar(3)
	,@T_DenomProg	varchar(250)
	,@T_Resolucion	varchar(250)
	,@C_CodGrado	varchar(5)
	,@T_DenomGrado	varchar(250)
	,@T_DenomTitulo	varchar(500)
	,@C_CodRegimenEst	varchar(5)
	,@C_CodModEst	varchar(5)
	,@B_SegundaEsp	bit
	,@D_FecCre		datetime
	,@I_UsuarioCre	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		IF NOT EXISTS (SELECT C_CodProg FROM TC_ProgramaUnfv WHERE C_CodProg = @C_CodProg)
		BEGIN
			INSERT INTO TC_ProgramaUnfv(C_CodProg, C_RcCod, T_DenomProg, T_Resolucion, C_CodGrado, T_DenomGrado, C_CodRegimenEst, C_CodModEst, B_SegundaEsp, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
				VALUES (@C_CodProg, @C_RcCod, @T_DenomProg, @T_Resolucion, @C_CodGrado, @T_DenomGrado, @C_CodRegimenEst, @C_CodModEst, @B_SegundaEsp, 1, 0, @I_UsuarioCre, @D_FecCre);
		END

		INSERT INTO TC_TituloProfesional (C_CodProg, T_DenomTitulo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES (@C_CodProg, @T_DenomTitulo, 1, 0, @I_UsuarioCre, @D_FecCre);

		SET @B_Result = 1;
		SET @T_Message = 'Nuevo programa registrado.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarAlumno')
	DROP PROCEDURE [dbo].[USP_U_ActualizarAlumno]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarAlumno]
	@C_RcCod		varchar(3)
	,@C_CodAlu		varchar(20)
	,@C_CodModIng	varchar(2)
	,@C_AnioIngreso	smallint
	,@I_IdPlan		int
	,@I_PersonaID	int
	,@B_Habilitado  bit
	,@B_Eliminado   bit
	,@D_FecMod		datetime
	,@I_UsuarioMod	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		UPDATE TC_Alumno
		   SET C_CodModIng = @C_CodModIng
		   , C_AnioIngreso = @C_AnioIngreso
		   , I_IdPlan	   = @I_IdPlan
		   , I_PersonaID   = @I_PersonaID
		   , B_Habilitado  = @B_Habilitado
		   , B_Eliminado   = @B_Eliminado 
		   , I_UsuarioMod  = @I_UsuarioMod
		   , D_FecMod	   = @D_FecMod
		WHERE C_CodAlu = @C_CodAlu
			AND C_RcCod = @C_RcCod

		SET @B_Result = 1;
		SET @T_Message = 'Datos de alumno actualizados.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarCarreraProfesional')
	DROP PROCEDURE [dbo].[USP_U_ActualizarCarreraProfesional]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarCarreraProfesional]
	@C_RcCod		varchar(3)
	,@C_CodEsp		varchar(2)
	,@C_CodEsc		varchar(2)
	,@C_CodFac		varchar(2)
	,@C_Tipo		char(1)
	,@I_Duracion	int
	,@B_Anual		bit
	,@N_Grupo		char(1)
	,@N_Grado		char(1)
	,@I_IdAplica	int = null
	,@B_Habilitado 	bit
	,@B_Eliminado	bit
	,@D_FecMod		datetime
	,@I_UsuarioMod	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		
		UPDATE TI_CarreraProfesional
		SET	C_CodEsp	= @C_CodEsp
			, C_CodEsc	= @C_CodEsc
			, C_CodFac	= @C_CodFac
			, C_Tipo	= @C_Tipo
			, I_Duracion  = @I_Duracion
			, B_Anual	= @B_Anual
			, N_Grupo	= @N_Grupo
			, N_Grado	= @N_Grado
			, I_IdAplica = @I_IdAplica
			, B_Habilitado = @B_Habilitado
			, B_Eliminado  = @B_Eliminado
			, I_UsuarioMod = @I_UsuarioMod
			, D_FecMod	   = @D_FecMod
		WHERE 
			C_RcCod = @C_RcCod

		SET @B_Result = 1;
		SET @T_Message = 'Carrera Profesional actualizada.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarPersona')
	DROP PROCEDURE [dbo].[USP_U_ActualizarPersona]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarPersona]
	@I_PersonaID	int
	,@C_NumDNI		varchar(20)
	,@C_CodTipDoc	varchar(5)
	,@T_ApePaterno	varchar(50)
	,@T_ApeMaterno  varchar(50) = null
	,@T_Nombre		varchar(50)
	,@D_FecNac		date = null
	,@C_Sexo		char(1) = null
	,@B_Habilitado 	bit
	,@B_Eliminado	bit
	,@D_FecMod		datetime
	,@I_UsuarioMod	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		UPDATE TC_Persona
		SET	C_NumDNI	= @C_NumDNI 
		  ,C_CodTipDoc	= @C_CodTipDoc
		  ,T_ApePaterno	= @T_ApePaterno
		  ,T_ApeMaterno	= @T_ApeMaterno
		  ,T_Nombre		= @T_Nombre
		  ,D_FecNac		= @D_FecNac
		  ,C_Sexo		= @C_Sexo
		  ,B_Habilitado	= @B_Habilitado
		  ,B_Eliminado	= @B_Eliminado
		  ,I_UsuarioMod	= @I_UsuarioMod
		  ,D_FecMod		= @D_FecMod
		WHERE I_PersonaID = @I_PersonaID

		SET @B_Result = 1;
		SET @T_Message = 'Los datos de persona actualizados.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarProgramaUnfv')
	DROP PROCEDURE [dbo].[USP_U_ActualizarProgramaUnfv]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarProgramaUnfv]
	 @C_CodProg		varchar(10)
	,@C_RcCod		varchar(3)
	,@T_DenomProg	varchar(250)
	,@T_Resolucion	varchar(250)
	,@C_CodGrado	varchar(5)
	,@T_DenomGrado	varchar(250)
	,@T_DenomTitulo	varchar(500)
	,@C_CodRegimenEst	varchar(5)
	,@C_CodModEst	varchar(5)
	,@I_TituloProfID int
	,@B_SegundaEsp	bit
	,@B_Habilitado 	bit
	,@B_HabTitulo 	bit
	,@B_Eliminado	bit
	,@D_FecMod		datetime
	,@I_UsuarioMod	int
	,@B_Result		bit OUTPUT
	,@T_Message		nvarchar(4000) OUTPUT	
AS
BEGIN
	SET NOCOUNT OFF;
	
	BEGIN TRY
		UPDATE TC_ProgramaUnfv
		SET	C_RcCod	= @C_RcCod
			,T_DenomProg  = @T_DenomProg
			,T_Resolucion = @T_Resolucion
			,C_CodGrado	  = @C_CodGrado
			,T_DenomGrado = @T_DenomGrado
			,C_CodRegimenEst = @C_CodRegimenEst
			,C_CodModEst	= @C_CodModEst
			,B_SegundaEsp	= @B_SegundaEsp
			,B_Habilitado	= @B_Habilitado
			,B_Eliminado	= @B_Eliminado
			,I_UsuarioMod	= @I_UsuarioMod
			,D_FecMod		= @D_FecMod
		WHERE C_CodProg	= @C_CodProg


		UPDATE TC_TituloProfesional
		SET T_DenomTitulo = @T_DenomTitulo
			, B_Habilitado = @B_HabTitulo
			, B_Eliminado = @B_Eliminado
			, I_UsuarioMod = @I_UsuarioMod
			, D_FecMod = @D_FecMod
		WHERE I_TituloProfID = @I_TituloProfID

		SET @B_Result = 1;
		SET @T_Message = 'Datos de programa actualizados.'; 

	END TRY
	BEGIN CATCH
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + '. LINEA: ' + ERROR_LINE() + '.'; 
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_Alumnos')
	DROP VIEW [dbo].[VW_Alumnos]
GO


CREATE VIEW [dbo].[VW_Alumnos]
AS
SELECT
	p.I_PersonaID, p.C_CodTipDoc, tdoc.T_TipDocDesc, p.C_NumDNI, p.T_ApePaterno, p.T_ApeMaterno, p.T_Nombre, p.D_FecNac, p.C_Sexo, a.C_CodAlu, a.C_RcCod, 
	ISNULL(car.C_CodEsp, '') AS C_CodEsp, ISNULL(esp.T_EspDesc, '') AS T_EspDesc, 
	car.C_CodEsc, esc.T_EscDesc, 
	car.C_CodFac, fac.T_FacDesc, 
	ISNULL(prog.C_CodProg, '') AS C_CodProg, ISNULL(prog.T_DenomProg, '') AS T_DenomProg, 
	a.C_CodModIng, modIng.T_ModIngDesc, 
	car.N_Grado, grad.T_GradoDesc, car.N_Grupo, a.C_AnioIngreso, 
	a.I_IdPlan, a.B_Habilitado, a.B_Eliminado FROM dbo.TC_Persona p
INNER JOIN dbo.TC_Alumno a ON a.I_PersonaID = p.I_PersonaID
LEFT JOIN dbo.TC_TipoDocumentoIdentidad tdoc ON tdoc.C_CodTipDoc = p.C_CodTipDoc
LEFT JOIN dbo.TC_ModalidadIngreso modIng ON  modIng.C_CodModIng = a.C_CodModIng
INNER JOIN dbo.TI_CarreraProfesional car ON car.C_RcCod = a.C_RcCod
LEFT JOIN dbo.TC_Especialidad esp ON 
	esp.C_CodEsp = car.C_CodEsp AND esp.C_CodEsc = car.C_CodEsc AND esp.C_CodFac = car.C_CodFac AND esp.B_Eliminado = 0
INNER JOIN dbo.TC_Escuela esc ON esc.C_CodEsc = car.C_CodEsc AND esc.C_CodFac = car.C_CodFac AND esc.B_Eliminado = 0
INNER JOIN dbo.TC_Facultad fac ON fac.C_CodFac = car.C_CodFac AND fac.B_Eliminado = 0
LEFT JOIN dbo.TC_ProgramaUnfv prog ON prog.C_RcCod = car.C_RcCod
LEFT JOIN dbo.TC_GradoAcademico grad ON grad.C_CodGrado = car.N_Grado
WHERE a.B_Eliminado = 0 AND p.B_Eliminado = 0
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CarreraProfesional')
	DROP VIEW [dbo].[VW_CarreraProfesional]
GO


CREATE VIEW [dbo].[VW_CarreraProfesional]
AS
SELECT
	cprof.C_RcCod, cprof.C_CodEsp, cprof.C_CodEsc, cprof.C_CodFac, esp.T_EspDesc, esc.T_EscDesc, fac.T_FacDesc, cprof.T_CarProfDesc,
	cprof.C_Tipo, cprof.I_Duracion, cprof.B_Anual, cprof.N_Grupo, cprof.N_Grado, cprof.I_IdAplica, cprof.B_Habilitado, cprof.B_Eliminado 
FROM dbo.TI_CarreraProfesional cprof
LEFT JOIN dbo.TC_Especialidad esp ON 
	esp.C_CodEsp = cprof.C_CodEsp AND esp.C_CodEsc = cprof.C_CodEsc AND esp.C_CodFac = cprof.C_CodFac AND esp.I_Especialidad = cprof.I_Especialidad AND esp.B_Eliminado = 0
INNER JOIN dbo.TC_Escuela esc ON esc.C_CodEsc = cprof.C_CodEsc AND esc.C_CodFac = cprof.C_CodFac AND esc.B_Eliminado = 0
INNER JOIN dbo.TC_Facultad fac ON fac.C_CodFac = cprof.C_CodFac AND fac.B_Eliminado = 0
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_ProgramaUnfv')
	DROP VIEW [dbo].[VW_ProgramaUnfv]
GO


CREATE VIEW [dbo].[VW_ProgramaUnfv]
AS
SELECT 
	prog.C_CodProg, prog.C_RcCod, c.C_CodEsp, c.C_CodEsc, c.C_CodFac, c.T_EspDesc, c.T_EscDesc, c.T_FacDesc, 
	prog.T_DenomProg, prog.T_Resolucion, prog.T_DenomGrado, titl.T_DenomTitulo, prog.C_CodRegimenEst, prog.C_CodModEst, prog.B_SegundaEsp, prog.C_CodGrado,
	c.C_Tipo, c.I_Duracion, c.B_Anual, c.N_Grupo, c.N_Grado, c.I_IdAplica, prog.B_Habilitado, prog.B_Eliminado 
FROM dbo.TC_ProgramaUnfv prog
INNER JOIN TC_TituloProfesional titl ON titl.C_CodProg = prog.C_CodProg
LEFT JOIN dbo.VW_CarreraProfesional c ON c.C_RcCod = prog.C_RcCod AND c.B_Eliminado = 0
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_Facultad')
	DROP VIEW [dbo].[VW_Facultad]
GO


CREATE VIEW [dbo].[VW_Facultad]
AS
SELECT f.C_CodFac, f.T_FacDesc, f.T_FacAbrev, f.B_Habilitado FROM dbo.TC_Facultad f
WHERE f.B_Eliminado = 0
GO
