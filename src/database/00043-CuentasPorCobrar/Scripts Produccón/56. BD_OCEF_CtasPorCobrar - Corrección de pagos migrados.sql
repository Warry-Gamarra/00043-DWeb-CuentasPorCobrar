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

	SELECT b.* FROM dbo.TR_PagoBanco b
	INNER JOIN @migrados m  ON b.I_MigracionRowID = m.I_MigracionRowID
	WHERE b.B_Anulado = 0 AND b.I_CtaDepositoID = 9
		AND b.I_MontoPago = 11.50
	ORDER BY 1;

	----Anulación de registros con número de cuenta erróneo
	--UPDATE b SET b.B_Anulado = 1 FROM dbo.TR_PagoBanco b
	--INNER JOIN @migrados m ON b.I_MigracionRowID = m.I_MigracionRowID
	--WHERE b.B_Anulado = 0 AND b.I_CtaDepositoID = 9;

	----Cambio de estado de registros con número de cuenta correcto
	--UPDATE b SET b.I_CondicionPagoID = 135 FROM dbo.TR_PagoBanco b
	--INNER JOIN @migrados m ON b.I_MigracionRowID = m.I_MigracionRowID
	--WHERE b.B_Anulado = 0 AND b.I_CtaDepositoID = 7;

	COMMIT TRAN

	PRINT 'Actualizaciones correctas.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	PRINT ERROR_MESSAGE()
END CATCH
GO

--135	Pago a una obligación pagada anteriormente
--136	Pago a obligación inexistente
--137	Pago desenlazado de una obligación
--142	No existe concepto de interés moratorio

select * from dbo.TR_PagoBanco where I_MontoPago = '2022018081'