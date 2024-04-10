USE BD_OCEF_CtasPorCobrar
GO

SET NOCOUNT ON;

BEGIN TRAN
BEGIN TRY

	DECLARE @migrados TABLE(I_MigracionRowID INT, C_CodOperacion VARCHAR(50));

	--Registros observados
	WITH migrados(I_MigracionRowID, C_CodOperacion, I_CtaDepositoID)
	AS
	(
		SELECT b.I_MigracionRowID, b.C_CodOperacion, b.I_CtaDepositoID FROM dbo.TR_PagoBanco b
		WHERE b.B_Anulado = 0 AND b.B_Migrado = 1 AND b.I_EntidadFinanID = 1 AND 
			NOT EXISTS(SELECT * FROM dbo.TRI_PagoProcesadoUnfv p WHERE p.I_PagoBancoID = b.I_PagoBancoID AND p.B_Anulado = 0)
		GROUP BY b.I_MigracionRowID, b.C_CodOperacion, b.I_CtaDepositoID
	)
	INSERT @migrados(I_MigracionRowID, C_CodOperacion)
	SELECT I_MigracionRowID, C_CodOperacion AS rep FROM migrados
	GROUP BY I_MigracionRowID, C_CodOperacion
	HAVING COUNT(*) > 1;

	--Anulación de registros con número de cuenta erróneo
	UPDATE b SET b.B_Anulado = 1 
	FROM dbo.TR_PagoBanco b
	INNER JOIN @migrados m ON b.I_MigracionRowID = m.I_MigracionRowID
	WHERE b.B_Anulado = 0;

	COMMIT TRAN

	PRINT 'Anulaciones correctas.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	PRINT ERROR_MESSAGE()
END CATCH
GO
