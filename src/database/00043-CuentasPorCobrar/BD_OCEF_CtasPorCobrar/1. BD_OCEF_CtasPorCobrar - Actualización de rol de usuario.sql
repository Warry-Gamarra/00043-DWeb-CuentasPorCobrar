USE BD_OCEF_CtasPorCobrar
GO

/*
Descripci�n: Script para actualizar el rol del usuario "jmoreno" a "tesorer�a".
Fecha: 09-12-2021 16:21
*/

BEGIN TRAN
BEGIN TRY
	DECLARE @UserId INT = (SELECT UserId FROM dbo.TC_Usuario where UserName = 'jmoreno'),
			@RoleId INT = (SELECT RoleId FROM dbo.webpages_Roles WHERE RoleName = 'Tesorer�a')


	IF EXISTS(SELECT * FROM dbo.webpages_UsersInRoles WHERE UserId = @UserId) BEGIN
		UPDATE dbo.webpages_UsersInRoles SET RoleId = @RoleId WHERE UserId = @UserId
	END 
	ELSE BEGIN
		INSERT dbo.webpages_UsersInRoles(UserId, RoleID) VALUES(@UserId, @RoleId)
	END

	IF (@@ROWCOUNT > 0) BEGIN
		COMMIT TRAN
		PRINT 'Rol actualizado.'
	END
	ELSE BEGIN
		ROLLBACK TRAN
		PRINT 'No se realiz� ninguna actualizaci�n.'
	END
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE()
END CATCH
GO