USE BD_OCEF_CtasPorCobrar
GO

/*
Actualización en la fecha de vencimiento de pensiones EUPG 2022-1, según PROVEIDO N° 8227-2022-DIGA-UNFV.
*/

SET NOCOUNT ON;

BEGIN TRAN
BEGIN TRY
	--1RA PENSION
	UPDATE c SET c.D_FecVencto = '20221117' FROM dbo.TR_ObligacionAluCab c 
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND c.B_Pagado = 0 AND 
		DATEDIFF(DAY, c.D_FecVencto, '20220930') = 0

	UPDATE d SET d.D_FecVencto = '20221117' FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND 
		DATEDIFF(DAY, d.D_FecVencto, '20220930') = 0

	--2DA PENSIÓN
	UPDATE c SET c.D_FecVencto = '20221217' FROM dbo.TR_ObligacionAluCab c 
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND c.B_Pagado = 0 AND 
		(DATEDIFF(DAY, c.D_FecVencto, '20221030') = 0 OR DATEDIFF(DAY, c.D_FecVencto, '20221031') = 0)

	UPDATE d SET d.D_FecVencto = '20221217' FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND 
		(DATEDIFF(DAY, d.D_FecVencto, '20221030') = 0 OR DATEDIFF(DAY, d.D_FecVencto, '20221031') = 0)

	--3RA PENSIÓN
	UPDATE c SET c.D_FecVencto = '20230117' FROM dbo.TR_ObligacionAluCab c 
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND c.B_Pagado = 0 AND 
		DATEDIFF(DAY, c.D_FecVencto, '20221130') = 0

	UPDATE d SET d.D_FecVencto = '20230117' FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND 
		DATEDIFF(DAY, d.D_FecVencto, '20221130') = 0

	--4TA PENSIÓN
	UPDATE c SET c.D_FecVencto = '20230217' FROM dbo.TR_ObligacionAluCab c 
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND c.B_Pagado = 0 AND 
		(DATEDIFF(DAY, c.D_FecVencto, '20221230') = 0 OR DATEDIFF(DAY, c.D_FecVencto, '20221231') = 0)

	UPDATE d SET d.D_FecVencto = '20230217' FROM dbo.TR_ObligacionAluCab c
	INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID IN (523, 526) AND 
		(DATEDIFF(DAY, d.D_FecVencto, '20221230') = 0 OR DATEDIFF(DAY, d.D_FecVencto, '20221231') = 0)

	COMMIT TRAN

	PRINT 'Actualización correcta.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	PRINT ERROR_MESSAGE()
END CATCH
GO