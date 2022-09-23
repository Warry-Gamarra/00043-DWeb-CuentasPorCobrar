USE BD_OCEF_CtasPorCobrar
GO

BEGIN TRAN
BEGIN TRY

	UPDATE dbo.TR_ObligacionAluCab SET D_FecVencto = '20221031' WHERE I_ProcesoID IN (523, 526) AND DATEDIFF(DAY, D_FecVencto, '20221030') = 0

	UPDATE d SET d.D_FecVencto = '20221031' FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID
	WHERE c.I_ProcesoID IN (523, 526) AND DATEDIFF(DAY, d.D_FecVencto, '20221030') = 0

	UPDATE dbo.TR_ObligacionAluCab SET D_FecVencto = '20221231' WHERE I_ProcesoID IN (523, 526) AND DATEDIFF(DAY, D_FecVencto, '20221230') = 0

	UPDATE d SET d.D_FecVencto = '20221231' FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID
	WHERE c.I_ProcesoID IN (523, 526) AND DATEDIFF(DAY, d.D_FecVencto, '20221230') = 0

	COMMIT TRAN
	PRINT 'Actualización correcta.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE()
END CATCH
GO
