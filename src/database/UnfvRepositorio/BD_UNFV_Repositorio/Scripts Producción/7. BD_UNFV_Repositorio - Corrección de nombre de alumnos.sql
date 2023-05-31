USE BD_UNFV_Repositorio
GO

BEGIN TRAN
BEGIN TRY
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'CASTA�EDA', T_ApeMaterno = 'ABANTO', T_Nombre = 'FRANCO GAEL' WHERE I_PersonaID = 36431
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'SANCHEZ', T_ApeMaterno = 'VEGA', T_Nombre = 'PAOLO FABRIZIO NICOL�S' WHERE I_PersonaID = 36524
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'BARBOZA', T_ApeMaterno = 'VALLEJOS', T_Nombre = 'LUCERO ALELI' WHERE I_PersonaID = 36551
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'CCANTO', T_ApeMaterno = 'CHANCHA', T_Nombre = 'MARILYN M�NICA' WHERE I_PersonaID = 36556
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'VILLALBA', T_ApeMaterno = 'DELGADO', T_Nombre = 'ENRIQUE JES�S' WHERE I_PersonaID = 36566
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'GARRO', T_ApeMaterno = 'ARANA', T_Nombre = 'DANIELA SOF�A' WHERE I_PersonaID = 36578
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'CAYCHO', T_ApeMaterno = 'RAM�N', T_Nombre = 'DIEGO MART�N' WHERE I_PersonaID = 36615
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'AVALOS', T_ApeMaterno = 'AMORETTI', T_Nombre = 'RUB� VALENTINA' WHERE I_PersonaID = 36631
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'QUISPE', T_ApeMaterno = 'BALTAZAR', T_Nombre = 'ALEXS JES�S' WHERE I_PersonaID = 36632
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'DIAZ', T_ApeMaterno = 'TASAYCO', T_Nombre = 'JES�S IVAN' WHERE I_PersonaID = 36641
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'GUEVARA', T_ApeMaterno = '�VILA', T_Nombre = 'RICARDO VALENTINO' WHERE I_PersonaID = 36652
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'ARCA', T_ApeMaterno = 'RUJEL', T_Nombre = 'JHONNY ADRI�N' WHERE I_PersonaID = 36678
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'CAMONES', T_ApeMaterno = 'JAIMES', T_Nombre = 'MAYT� SOLEDAD' WHERE I_PersonaID = 36698
	UPDATE dbo.TC_Persona SET T_ApePaterno = 'PACHECO', T_ApeMaterno = 'YANQUI', T_Nombre = 'LUZ BEL�N' WHERE I_PersonaID = 36763

	COMMIT TRAN
	PRINT 'Actualizaci�n correcta.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE()
END CATCH
GO