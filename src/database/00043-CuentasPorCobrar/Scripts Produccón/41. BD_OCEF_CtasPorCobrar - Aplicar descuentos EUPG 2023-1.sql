USE [BD_OCEF_CtasPorCobrar]
GO


DECLARE @B_Result BIT,  
	@T_Message nvarchar(4000);
  
EXEC USP_IU_GenerarObligacionesPosgrado_X_Ciclo 
	@I_Anio = 2023, 
	@I_Periodo = 19, 
	@B_AlumnosSinObligaciones = 0, 
	@B_SoloAplicarExtemporaneo = 1,
	@I_UsuarioCre = 1,
	@B_Result = @B_Result OUTPUT,
	@T_Message = @T_Message OUTPUT;
  
SELECT @B_Result, @T_Message
GO