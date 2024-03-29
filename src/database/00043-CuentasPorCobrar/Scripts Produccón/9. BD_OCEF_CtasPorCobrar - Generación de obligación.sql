USE [BD_OCEF_CtasPorCobrar]
GO

/*
Generación de obligaciones para: Elias Ramirez Juan Eduardo.
*/

declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPosgrado_X_Ciclo 
	@I_Anio = 2021, 
	@I_Periodo = 20, 
	@C_CodEsc = NULL, 
	@C_CodAlu = '2018040162', 
	@C_CodRc = 'G06', 
	@I_UsuarioCre = 1, 
	@B_Result = @B_Result OUTPUT,
	@T_Message = @T_Message OUTPUT

select @B_Result, @T_Message
go
