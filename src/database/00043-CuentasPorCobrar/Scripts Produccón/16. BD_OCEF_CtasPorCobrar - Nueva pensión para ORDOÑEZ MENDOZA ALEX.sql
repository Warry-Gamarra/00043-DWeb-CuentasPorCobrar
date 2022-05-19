USE BD_OCEF_CtasPorCobrar
GO


DECLARE @I_ObligacionAluID INT,
		@I_ProcesoID INT,
		@I_MatAluID INT,
		@I_MontoOblig INT = 970,
		@D_FecVencto DATE = '20220531',
		@D_FecCre DATE = GETDATE(),
		@I_UsuarioCre INT = 1



SELECT TOP 1 @I_ProcesoID = I_ProcesoID, @I_MatAluID = I_MatAluID FROM dbo.VW_CuotasPago_General 
WHERE C_CodAlu = '2014319842' AND I_Anio = 2021 and C_Periodo = '2' AND I_Prioridad = 2 AND I_MontoOblig = 300

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(@I_ProcesoID, @I_MatAluID, 'PEN', @I_MontoOblig, @D_FecVencto, 0, 1, 0, @I_UsuarioCre, @D_FecCre)

SET @I_ObligacionAluID = IDENT_CURRENT('TR_ObligacionAluCab')

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
SELECT TOP 1 @I_ObligacionAluID, I_ConcPagID,  @I_MontoOblig, 0, @D_FecVencto, 1, 0, @I_UsuarioCre, @D_FecCre, 0 FROM dbo.TR_ObligacionAluDet
WHERE I_ObligacionAluID = (SELECT TOP 1 I_ObligacionAluID FROM dbo.VW_CuotasPago_General 
	WHERE C_CodAlu = '2014319842' AND I_Anio = 2021 and C_Periodo = '2' AND I_Prioridad = 2 AND I_MontoOblig = 300)
GO