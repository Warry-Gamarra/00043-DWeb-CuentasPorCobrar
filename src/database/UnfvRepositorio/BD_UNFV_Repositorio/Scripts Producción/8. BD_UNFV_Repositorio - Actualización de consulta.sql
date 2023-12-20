USE BD_UNFV_Repositorio
GO

ALTER TABLE dbo.TI_CarreraProfesional ALTER COLUMN B_Habilitado BIT NOT NULL;
GO

ALTER TABLE dbo.TI_CarreraProfesional ALTER COLUMN B_Eliminado BIT NOT NULL;
GO

ALTER VIEW [dbo].[VW_CarreraProfesional]  
AS  
	SELECT  
	cprof.C_RcCod, cprof.C_CodEsp, cprof.C_CodEsc, cprof.C_CodFac, esp.T_EspDesc, esc.T_EscDesc, fac.T_FacDesc, cprof.T_CarProfDesc,  
	cprof.C_Tipo, cprof.I_Duracion, cprof.B_Anual, cprof.N_Grupo, cprof.N_Grado, cprof.I_IdAplica, cprof.B_Habilitado, cprof.B_Eliminado,
	fac.I_DependenciaID
	FROM dbo.TI_CarreraProfesional cprof  
	LEFT JOIN dbo.TC_Especialidad esp ON   
	esp.C_CodEsp = cprof.C_CodEsp AND esp.C_CodEsc = cprof.C_CodEsc AND esp.C_CodFac = cprof.C_CodFac AND esp.I_Especialidad = cprof.I_Especialidad AND esp.B_Eliminado = 0  
	INNER JOIN dbo.TC_Escuela esc ON esc.C_CodEsc = cprof.C_CodEsc AND esc.C_CodFac = cprof.C_CodFac AND esc.B_Eliminado = 0  
	INNER JOIN dbo.TC_Facultad fac ON fac.C_CodFac = cprof.C_CodFac AND fac.B_Eliminado = 0
	WHERE cprof.B_Eliminado = 0
GO
