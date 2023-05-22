USE BD_UNFV_Repositorio
GO

BEGIN TRAN
BEGIN TRY
	INSERT dbo.TC_Especialidad(C_CodEsp, C_CodEsc, C_CodFac, T_EspDesc, B_Habilitado, B_Eliminado) 
	VALUES('LC', 'LA', 'TM', 'LABORATORIO CLÍNICO Y ANATOMÍA PATOLÓGICA', 1, 0)

	DECLARE @I_Especialidad INT = IDENT_CURRENT('dbo.TC_Especialidad')

	INSERT TI_CarreraProfesional(C_RcCod, C_CodEsp, C_CodEsc, C_CodFac, I_Especialidad, T_CarProfDesc, C_Tipo, I_Duracion, B_Anual, N_Grupo, N_Grado, I_IdAplica, B_Habilitado, B_Eliminado)
	VALUES('628', 'LC', 'LA', 'TM', @I_Especialidad, 'LABORATORIO CLÍNICO Y ANATOMÍA PATOLÓGICA', 'L', 5, 1, '2', '1', 0, 1, 0)

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH
GO
