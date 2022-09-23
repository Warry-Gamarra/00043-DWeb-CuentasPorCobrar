USE BD_UNFV_Repositorio
GO

SET NOCOUNT ON;

DECLARE @I_PersonaID INT;  
BEGIN TRAN  
BEGIN TRY  
	INSERT dbo.TC_Persona(T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
	VALUES('ARROYO', 'TICONA', 'LUIS ALVARO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('017', '2011019224', @I_PersonaID, 'AD', '2011', 0, 1, 0, 1, GETDATE());
	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO


DECLARE @I_PersonaID INT;  
BEGIN TRAN  
BEGIN TRY  
	INSERT dbo.TC_Persona(T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
	VALUES('BENITES', 'VÍA', 'OMAR AYMAR', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('040', '2007012689', @I_PersonaID, 'AD', '2007', 0, 1, 0, 1, GETDATE());
	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO


DECLARE @I_PersonaID INT;  
BEGIN TRAN  
BEGIN TRY  
	INSERT dbo.TC_Persona(T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
	VALUES('CULE', 'ANTEZANA', 'LESLY', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('072', '2021020499', @I_PersonaID, 'AD', '2021', 0, 1, 0, 1, GETDATE());
	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO
