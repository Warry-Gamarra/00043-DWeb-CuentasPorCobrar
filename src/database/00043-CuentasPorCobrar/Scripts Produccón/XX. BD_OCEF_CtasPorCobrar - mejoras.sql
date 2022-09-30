USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Dia')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dia]
GO
 
CREATE PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dia]  
@I_Anio    INT,  
@I_EntidadFinanID INT = NULL,  
@I_CtaDepositoID INT = NULL,  
@I_CondicionPagoID INT = NULL  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @PagoObligacion INT = 133   
   
 DECLARE @SQLString NVARCHAR(4000),  
   @ParmDefinition NVARCHAR(500)  
  
 SET @SQLString = N'  
  SELECT  
   I_Dia,  
   ISNULL([1], 0) AS Enero,  
   ISNULL([2], 0) AS Febrero,  
   ISNULL([3], 0) AS Marzo,  
   ISNULL([4], 0) AS Abril,  
   ISNULL([5], 0) AS Mayo,  
   ISNULL([6], 0) AS Junio,  
   ISNULL([7], 0) AS Julio,  
   ISNULL([8], 0) AS Agosto,  
   ISNULL([9], 0) AS Setiembre,  
   ISNULL([10], 0) AS Octubre,  
   ISNULL([11], 0) AS Noviembre,  
   ISNULL([12], 0) AS Diciembre  
  FROM  
  (  
  SELECT MONTH(b.D_FecPago) AS I_Month, DAY(b.D_FecPago) AS I_Dia, SUM(b.I_MontoPago + b.I_InteresMora) AS I_MontoTotal  
  FROM dbo.TR_PagoBanco b   
  WHERE b.B_Anulado = 0 AND Year(b.D_FecPago) = @I_Anio AND b.I_TipoPagoID = @I_TipoPagoID ' +  
   CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND b.I_EntidadFinanID = @I_EntidadFinanID' END + '  
   ' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND b.I_CtaDepositoID = @I_CtaDepositoID' END + '  
   ' + CASE WHEN @I_CondicionPagoID IS NULL THEN '' ELSE 'AND b.I_CondicionPagoID = @I_CondicionPagoID' END + '  
  GROUP BY MONTH(b.D_FecPago), DAY(b.D_FecPago)
  ) p  
  PIVOT  
  (  
   SUM(p.I_MontoTotal)   
   FOR p.I_Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])  
  ) AS pvt'  
  
 SET @ParmDefinition = N'@I_TipoPagoID INT, @I_Anio INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @I_CondicionPagoID INT'  
   
 EXECUTE sp_executesql @SQLString, @ParmDefinition,  
  @I_TipoPagoID = @PagoObligacion,  
  @I_Anio = @I_Anio,  
  @I_EntidadFinanID = @I_EntidadFinanID,  
  @I_CtaDepositoID = @I_CtaDepositoID,  
  @I_CondicionPagoID = @I_CondicionPagoID  
/*  
EXEC USP_S_ResumenAnualPagoDeObligaciones_X_Dia   
 @I_Anio = 2021,  
 @I_EntidadFinanID = 1,  
 @I_CtaDepositoID = NULL,  
 @I_CondicionPagoID = NULL  
GO  
*/  
END  
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_CantidadDePagosRegistrados_X_Dia')
	DROP PROCEDURE [dbo].[USP_S_CantidadDePagosRegistrados_X_Dia]
GO

CREATE PROCEDURE [dbo].[USP_S_CantidadDePagosRegistrados_X_Dia]
@I_Anio INT,
@I_TipoPagoID INT,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL,
@I_CondicionPagoID INT = NULL
AS  
BEGIN
 SET NOCOUNT ON;
   
 DECLARE	@SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500)

 SET @SQLString = N'
  SELECT
   I_Dia,
   ISNULL([1], 0) AS Enero,
   ISNULL([2], 0) AS Febrero,
   ISNULL([3], 0) AS Marzo,
   ISNULL([4], 0) AS Abril,
   ISNULL([5], 0) AS Mayo,
   ISNULL([6], 0) AS Junio,
   ISNULL([7], 0) AS Julio,
   ISNULL([8], 0) AS Agosto,
   ISNULL([9], 0) AS Setiembre,
   ISNULL([10], 0) AS Octubre,
   ISNULL([11], 0) AS Noviembre,
   ISNULL([12], 0) AS Diciembre
  FROM
  (
  SELECT MONTH(b.D_FecPago) AS I_Month, DAY(b.D_FecPago) AS I_Dia, COUNT(b.I_PagoBancoID) AS I_Cantidad
  FROM dbo.TR_PagoBanco b
  WHERE b.B_Anulado = 0 AND Year(b.D_FecPago) = @I_Anio AND b.I_TipoPagoID = @I_TipoPagoID ' +
   CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND b.I_EntidadFinanID = @I_EntidadFinanID' END + '
   ' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND b.I_CtaDepositoID = @I_CtaDepositoID' END + '
   ' + CASE WHEN @I_CondicionPagoID IS NULL THEN '' ELSE 'AND b.I_CondicionPagoID = @I_CondicionPagoID' END + '
  GROUP BY MONTH(b.D_FecPago), DAY(b.D_FecPago)
  ) p
  PIVOT
  (
   SUM(p.I_Cantidad)
   FOR p.I_Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
  ) AS pvt'
  
 SET @ParmDefinition = N'@I_TipoPagoID INT, @I_Anio INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @I_CondicionPagoID INT'  
   
 EXECUTE sp_executesql @SQLString, @ParmDefinition,  
	  @I_TipoPagoID = @I_TipoPagoID,  
	  @I_Anio = @I_Anio,  
	  @I_EntidadFinanID = @I_EntidadFinanID,  
	  @I_CtaDepositoID = @I_CtaDepositoID,  
	  @I_CondicionPagoID = @I_CondicionPagoID  
/*  
EXEC USP_S_CantidadDePagosRegistrados_X_Dia   
@I_Anio = 2022,
@I_TipoPagoID = 133,
@I_EntidadFinanID = NULL,
@I_CtaDepositoID = NULL,
@I_CondicionPagoID = NULL
GO
*/  
END
GO
