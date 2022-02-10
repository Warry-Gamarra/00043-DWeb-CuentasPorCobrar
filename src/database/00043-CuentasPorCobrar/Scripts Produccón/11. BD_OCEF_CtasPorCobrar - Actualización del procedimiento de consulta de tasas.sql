use BD_OCEF_CtasPorCobrar
go


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarPagoTasas')
	DROP PROCEDURE [dbo].[USP_S_ListarPagoTasas]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarPagoTasas]  
@I_EntidadFinanID INT = NULL,  
@C_CodOperacion  VARCHAR(50) = NULL,  
@C_CodDepositante VARCHAR(20) = NULL,  
@T_NomDepositante VARCHAR(200) = NULL,  
@D_FechaInicio  DATETIME = NULL,  
@D_FechaFin   DATETIME = NULL  
AS  
BEGIN
--Se actualizó el filtro de fechas para buscar incluir los minutos en la fecha de pago.
 SET NOCOUNT ON;  
  
 DECLARE @SQLString NVARCHAR(2000),  
   @SQLParmString NVARCHAR(2000) = '',  
   @ParmDefinition NVARCHAR(500)  
  
 SET @SQLString = N'SELECT t.T_EntidadDesc, t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto,   
  t.C_CodOperacion, t.C_CodDepositante, t.T_NomDepositante, t.D_FecPago, I_MontoPagado  
 FROM dbo.VW_PagoTasas t '  
  
 IF (@I_EntidadFinanID IS NOT NULL) BEGIN  
  SET @SQLParmString = 'WHERE t.I_EntidadFinanID = @I_EntidadFinanID '  
 END  
  
 IF (@C_CodOperacion IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.C_CodOperacion = @C_CodOperacion '  
 END  
  
 IF (@C_CodDepositante IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.C_CodDepositante = @C_CodDepositante '  
 END  
  
 IF (@T_NomDepositante IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.T_NomDepositante LIKE ''%''+@T_NomDepositante+''%'' '  
 END  
  
 IF (@D_FechaInicio IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 'DATEDIFF(MINUTE, t.D_FecPago, @D_FechaInicio) <= 0 '  
 END  
  
 IF (@D_FechaFin IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 'DATEDIFF(MINUTE, t.D_FecPago, @D_FechaFin) >= 0 '  
 END  
  
 SET @ParmDefinition = N'@I_EntidadFinanID INT = NULL, @C_CodOperacion VARCHAR(50), @C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200),   
  @D_FechaInicio DATETIME, @D_FechaFin DATETIME'  
  
 SET @SQLString = @SQLString + @SQLParmString  
  
 EXECUTE sp_executesql @SQLString, @ParmDefinition,  
  @I_EntidadFinanID = @I_EntidadFinanID,  
  @C_CodOperacion = @C_CodOperacion,  
  @C_CodDepositante = @C_CodDepositante,  
  @T_NomDepositante = @T_NomDepositante,  
  @D_FechaInicio = @D_FechaInicio,  
  @D_FechaFin = @D_FechaFin  
/*  
EXEC USP_S_ListarPagoTasas   
 @I_EntidadFinanID = 2,  
 @C_CodOperacion = NULL,  
 @C_CodDepositante = NULL,  
 @T_NomDepositante = NULL,  
 @D_FechaInicio = '20210913 13:30:00',  
 @D_FechaFin = '20210913 14:30:59'  
GO
*/  
END
GO

