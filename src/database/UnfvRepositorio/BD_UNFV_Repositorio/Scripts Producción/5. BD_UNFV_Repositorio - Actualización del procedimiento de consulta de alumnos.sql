USE BD_UNFV_Repositorio
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_Alumnos')
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
		a.I_IdPlan, a.B_Habilitado, a.B_Eliminado, fac.I_DependenciaID FROM dbo.TC_Persona p
	INNER JOIN dbo.TC_Alumno a ON a.I_PersonaID = p.I_PersonaID AND p.B_Eliminado = 0
	LEFT JOIN dbo.TC_TipoDocumentoIdentidad tdoc ON tdoc.C_CodTipDoc = p.C_CodTipDoc
	LEFT JOIN dbo.TC_ModalidadIngreso modIng ON  modIng.C_CodModIng = a.C_CodModIng
	INNER JOIN dbo.TI_CarreraProfesional car ON car.C_RcCod = a.C_RcCod
	LEFT JOIN dbo.TC_Especialidad esp ON 
		esp.C_CodEsp = car.C_CodEsp AND esp.C_CodEsc = car.C_CodEsc AND esp.C_CodFac = car.C_CodFac AND esp.B_Eliminado = 0
	INNER JOIN dbo.TC_Escuela esc ON esc.C_CodEsc = car.C_CodEsc AND esc.C_CodFac = car.C_CodFac AND esc.B_Eliminado = 0
	INNER JOIN dbo.TC_Facultad fac ON fac.C_CodFac = car.C_CodFac AND fac.B_Eliminado = 0
	LEFT JOIN dbo.TC_ProgramaUnfv prog ON prog.C_RcCod = car.C_RcCod
	LEFT JOIN dbo.TC_GradoAcademico grad ON grad.C_CodGrado = car.N_Grado
	WHERE a.B_Eliminado = 0
GO