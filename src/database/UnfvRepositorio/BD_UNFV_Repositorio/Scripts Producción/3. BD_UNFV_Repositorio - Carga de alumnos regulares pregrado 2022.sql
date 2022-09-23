USE BD_UNFV_Repositorio
GO

SET NOCOUNT ON;

DECLARE @nro_doc VARCHAR(8) = '42529536', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'MEDINA', 'CASTRO', 'MICHAEL REYNALDO', NULL, 'M', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('034', '2016120025', @I_PersonaID, 'SP', '2016', 0, 1, 0, 1, GETDATE());  

	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO


DECLARE @nro_doc VARCHAR(8) = '10665225', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'REMICIO', 'CHUCHON', 'ALEX ADRIAN', NULL, 'M', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('070', '2002000354', @I_PersonaID, 'AD', '2002', 0, 1, 0, 1, GETDATE());  

	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO



DECLARE @nro_doc VARCHAR(8) = '45147230', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'HUARANCCA', 'SAIRITUPAC', 'YOVANA', NULL, 'F', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('070', '2008040294', @I_PersonaID, 'AD', '2008', 0, 1, 0, 1, GETDATE());  

	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO



DECLARE @nro_doc VARCHAR(8) = '77142724', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'VICENTE', 'FLORES', 'NESTOR STEVENS BARTS', NULL, 'M', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('070', '2013019711', @I_PersonaID, 'AD', '2013', 0, 1, 0, 1, GETDATE());  

	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO



DECLARE @nro_doc VARCHAR(8) = '48490597', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'CONTRERAS', 'VIDAL', 'FRANCO RENATO DANIEL', NULL, 'M', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('076', '2015028538', @I_PersonaID, 'AD', '2015', 0, 1, 0, 1, GETDATE());  

	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO



DECLARE @nro_doc VARCHAR(8) = '71114527', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'FERNANDEZ', 'NAVARRETE', 'MARIELA LAURA LUZMILA', NULL, 'F', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('096', '2014024805', @I_PersonaID, 'AD', '2014', 0, 1, 0, 1, GETDATE());  

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
	VALUES('QUISPE', 'MOLINA', 'JUAN ANTONY', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('070', '2012000588', @I_PersonaID, 'AD', '2012', 0, 1, 0, 1, GETDATE());
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
	VALUES('MORCCOLLA', 'YUTO', 'ALEX', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('027', '2012019931', @I_PersonaID, 'AD', '2012', 0, 1, 0, 1, GETDATE());
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
	VALUES('CASTILLO', 'ORE', 'DAVID', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('027', '2012233744', @I_PersonaID, 'CE', '2012', 0, 1, 0, 1, GETDATE());
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
	VALUES('OLIVERA', 'TORRES', 'JUNIOR', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('006', '2013010934', @I_PersonaID, 'AD', '2013', 0, 1, 0, 1, GETDATE());
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
	VALUES('APAZA', 'YATACO', 'LUIS ANTONIO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('027', '2014231382', @I_PersonaID, 'CE', '2014', 0, 1, 0, 1, GETDATE());
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
	VALUES('ZÁRATE', 'ORMEÑO', 'JHORDAN ALEJANDRO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('006', '2015017723', @I_PersonaID, 'AD', '2015', 0, 1, 0, 1, GETDATE());
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
	VALUES('CELIS', 'MEZA', 'PABLO GRAZZIANI', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2015235337', @I_PersonaID, 'CE', '2015', 0, 1, 0, 1, GETDATE());
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
	VALUES('NECIOSUP', 'ZARPAN', 'JHANZ WILMER', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('006', '2015237073', @I_PersonaID, 'CE', '2015', 0, 1, 0, 1, GETDATE());
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
	VALUES('ALVAREZ', 'FERNANDEZ', 'BRUNO JHONATAN', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('027', '2016001089', @I_PersonaID, 'AD', '2016', 0, 1, 0, 1, GETDATE());
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
	VALUES('CHAVEZ', 'ARIAS', 'WALTER RUBEN', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('006', '2016007276', @I_PersonaID, 'AD', '2016', 0, 1, 0, 1, GETDATE());
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
	VALUES('HUAMANI', 'LLANTOY', 'ROMARIO CLAUDIO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('028', '2016014619', @I_PersonaID, 'AD', '2016', 0, 1, 0, 1, GETDATE());
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
	VALUES('MORENO', 'GUERRERO', 'SOLANGE KIMBERLY', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('027', '2016020476', @I_PersonaID, 'AD', '2016', 0, 1, 0, 1, GETDATE());
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
	VALUES('KAYAP', 'NAUPE', 'JOSUE JAIME', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2017015726', @I_PersonaID, 'AD', '2017', 0, 1, 0, 1, GETDATE());
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
	VALUES('RODRIGUEZ', 'CARRASCO', 'LESLYE DAYHAM', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('006', '2017026612', @I_PersonaID, 'AD', '2017', 0, 1, 0, 1, GETDATE());
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
	VALUES('SUCNO', 'CHIVILCHES', 'CARLOS EDMUNDO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2017029764', @I_PersonaID, 'AD', '2017', 0, 1, 0, 1, GETDATE());
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
	VALUES('ARIAS', 'OROZCO', 'VICTOR ANTONIO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2018001451', @I_PersonaID, 'AD', '2018', 0, 1, 0, 1, GETDATE());
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
	VALUES('RIMAC', 'ANTARA', 'HEYDI MISHEL', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('099', '2018028208', @I_PersonaID, 'CE', '2018', 0, 1, 0, 1, GETDATE());
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
	VALUES('CAMPOS', 'FANOLA', 'IVONNE NOHELIA', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('104', '2019013462', @I_PersonaID, 'AD', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('ESTRELLA', 'RUIZ', 'CEFORA RUT', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019013845', @I_PersonaID, 'AD', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('MATOS', 'PEREZ', 'DANIEL ANTHONY', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019013854', @I_PersonaID, 'AD', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('SILGUERA', 'GUEVARA', 'GIANELLA BRISSETH', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019013863', @I_PersonaID, 'AD', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('MISAICO', 'CASTILLO', 'MERCEDEZ VIOLETA', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019013872', @I_PersonaID, 'AD', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('SARAVIA', 'DE LA CRUZ', 'YAMPIERE ALFREDO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019013881', @I_PersonaID, 'AD', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('NAVARRO', 'MEDINA', 'ANGELA MERCEDES', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('104', '2019232117', @I_PersonaID, 'BO', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('CORONEL', 'CHERRES', 'FELIX ALEJANDRO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019235144', @I_PersonaID, 'CE', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('MORALES', 'MONCA', 'DIANA', 'F', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('112', '2019235153', @I_PersonaID, 'CE', '2019', 0, 1, 0, 1, GETDATE());
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
	VALUES('ESQUIVEL', 'DEZA', 'JUAN MARIANO', 'M', 1, 0, 1, GETDATE());
	SET @I_PersonaID = @@IDENTITY;
	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('051', '2020006691', @I_PersonaID, 'AD', '2020', 0, 1, 0, 1, GETDATE());
	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO


DECLARE @nro_doc VARCHAR(8) = '74891669', 
		@tip_doc CHAR(2) = 'DI', @I_PersonaID INT;  

BEGIN TRAN  
BEGIN TRY  
	IF EXISTS(SELECT * FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc) 
	BEGIN   
		SET @I_PersonaID = (SELECT TOP 1 p.I_PersonaID FROM dbo.TC_Persona p WHERE p.C_NumDNI = @nro_doc AND p.C_CodTipDoc = @tip_doc);  
	END ELSE BEGIN   
		INSERT dbo.TC_Persona(C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, D_FecNac, C_Sexo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
		VALUES(@nro_doc, @tip_doc, 'RAMIREZ', 'MAYLLE', 'PATRICIA FIORELA', NULL, 'F', 1, 0, 1, GETDATE());
		SET @I_PersonaID = @@IDENTITY;  
	END  

	INSERT dbo.TC_Alumno(C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
	VALUES('044', '2016025042', @I_PersonaID, 'AD', '2016', 109, 1, 0, 1, GETDATE());  

	COMMIT TRAN;
END TRY  
BEGIN CATCH  
	ROLLBACK TRAN;  
	PRINT ERROR_MESSAGE();  
END CATCH  
GO