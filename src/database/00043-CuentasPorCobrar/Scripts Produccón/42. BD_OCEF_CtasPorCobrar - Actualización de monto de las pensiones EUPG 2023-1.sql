USE BD_OCEF_CtasPorCobrar
GO

BEGIN TRAN
BEGIN TRY

	--PENSIONES MAESTRÍA (543)

	UPDATE d SET 
		d.I_Monto = CASE WHEN d.I_Monto = 480 THEN 500 ELSE (CASE WHEN d.I_Monto = 240 THEN 250 ELSE d.I_Monto END) END,
		d.B_Pagado = CASE WHEN d.I_Monto = 480 THEN 0 ELSE (CASE WHEN d.I_Monto = 240 THEN 0 ELSE d.B_Pagado END) END
	FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID = 543 AND c.B_Pagado = 0;

	UPDATE c SET
		c.I_MontoOblig = CASE WHEN c.I_MontoOblig = 480 THEN 500 ELSE (CASE WHEN c.I_MontoOblig = 240 THEN 250 ELSE c.I_MontoOblig END) END,
		c.B_Pagado = CASE WHEN c.I_MontoOblig = 480 THEN 0 ELSE (CASE WHEN c.I_MontoOblig = 240 THEN 0 ELSE c.B_Pagado END) END
	FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID = 543 AND c.B_Pagado = 0;


	--PENSIONES DOCTORADO (545)

	UPDATE d SET 
		d.I_Monto = CASE WHEN d.I_Monto = 600 THEN 650 ELSE (CASE WHEN d.I_Monto = 300 THEN 325 ELSE d.I_Monto END) END,
		d.B_Pagado = CASE WHEN d.I_Monto = 600 THEN 0 ELSE (CASE WHEN d.I_Monto = 300 THEN 0 ELSE d.B_Pagado END) END
	FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID = 545 AND c.B_Pagado = 0;

	UPDATE c SET
		c.I_MontoOblig = CASE WHEN c.I_MontoOblig = 600 THEN 650 ELSE (CASE WHEN c.I_MontoOblig = 300 THEN 325 ELSE c.I_MontoOblig END) END,
		c.B_Pagado = CASE WHEN c.I_MontoOblig = 600 THEN 0 ELSE (CASE WHEN c.I_MontoOblig = 300 THEN 0 ELSE c.B_Pagado END) END
	FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID = 545 AND c.B_Pagado = 0;

	COMMIT TRAN
	
	PRINT 'Actualización correcta.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	PRINT ERROR_MESSAGE()
END CATCH
GO