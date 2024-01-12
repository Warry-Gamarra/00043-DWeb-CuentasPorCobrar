USE BD_OCEF_CtasPorCobrar
GO

ALTER TABLE dbo.TR_Comprobante ADD D_FecBaja DATETIME, T_MotivoBaja VARCHAR(250);
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_DarBajaComprobante')
	DROP PROCEDURE [dbo].[USP_U_DarBajaComprobante]
GO
 
CREATE PROCEDURE dbo.USP_U_DarBajaComprobante
@I_ComprobanteID INT,
@D_FecBaja DATETIME,
@T_MotivoBaja VARCHAR(250),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	BEGIN TRAN
	BEGIN TRY
		SET @D_FechaAccion = GETDATE();
			
		UPDATE pb SET 
			pb.B_Habilitado = 0,
			pb.I_UsuarioMod = @UserID,
			pb.D_FecMod = @D_FechaAccion
		FROM dbo.TR_Comprobante c
		INNER JOIN dbo.TR_Comprobante_PagoBanco pb ON pb.I_ComprobanteID = c.I_ComprobanteID AND pb.B_Habilitado = 1
		WHERE c.I_ComprobanteID = @I_ComprobanteID;

		UPDATE dbo.TR_Comprobante SET 
			D_FecBaja = @D_FecBaja,
			T_MotivoBaja = @T_MotivoBaja,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_ComprobanteID = @I_ComprobanteID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Acción realizada con éxito.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO
