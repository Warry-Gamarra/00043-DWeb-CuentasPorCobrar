USE BD_OCEF_CtasPorCobrar
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoBancoObligaciones')
	DROP VIEW [dbo].[VW_PagoBancoObligaciones]
GO
  
CREATE VIEW [dbo].[VW_PagoBancoObligaciones]
AS  
 SELECT b.I_PagoBancoID, e.I_EntidadFinanID, e.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, b.C_CodOperacion, b.C_CodDepositante,   
  c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, m.N_Grado,
  b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc AS T_Condicion, b.T_Observacion,   
  b.T_MotivoCoreccion, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoProcesado, b.C_CodigoInterno, pro.T_ProcesoDesc
 FROM TR_PagoBanco b  
 LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID AND p.B_Anulado = 0  
 LEFT JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluDetID = p.I_ObligacionAluDetID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0  
 LEFT JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = d.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0  
 LEFT JOIN dbo.VW_MatriculaAlumno m ON m.I_MatAluID = c.I_MatAluID  
 LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = c.I_ProcesoID
 INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID = b.I_EntidadFinanID  
 INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = b.I_CtaDepositoID  
 INNER JOIN dbo.TC_CatalogoOpcion cn ON cn.I_OpcionID = b.I_CondicionPagoID  
 WHERE b.I_TipoPagoID = 133 AND b.B_Anulado = 0  
 GROUP BY b.I_PagoBancoID, e.I_EntidadFinanID, cd.I_CtaDepositoID, cd.C_NumeroCuenta, e.T_EntidadDesc, b.C_CodOperacion, b.C_CodDepositante, 
	c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, m.N_Grado,
	b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc, b.T_Observacion, b.T_MotivoCoreccion, 
	b.C_CodigoInterno, pro.T_ProcesoDesc
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListadoEstadoObligaciones')
	DROP PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
@B_EsPregrado BIT,  
@I_Anio INT,  
@I_Periodo INT = NULL,  
@C_CodFac VARCHAR(2) = NULL ,  
@C_CodEsc VARCHAR(3) = NULL ,  
@C_RcCod VARCHAR(3) = NULL ,  
@B_Ingresante BIT = NULL,  
@B_ObligacionGenerada BIT = NULL,  
@B_Pagado BIT = NULL,  
@F_FecIni DATE = NULL,  
@F_FecFin DATE = NULL,  
@B_MontoPagadoDiff BIT = null,  
@C_CodAlu VARCHAR(10) = NULL,
@T_NomAlu VARCHAR(50) = NULL,
@T_ApePaternoAlu VARCHAR(50) = NULL,
@T_ApeMaternoAlu VARCHAR(50) = NULL
AS  
BEGIN  
 SET NOCOUNT ON;  
 DECLARE @Pregrado char(1) = '1',  
   @Maestria char(1) = '2',  
   @Doctorado char(1) = '3';
 
 SET @T_NomAlu = LTRIM(RTRIM(@T_NomAlu));
 SET @T_ApePaternoAlu = LTRIM(RTRIM(@T_ApePaternoAlu));
 SET @T_ApeMaternoAlu = LTRIM(RTRIM(@T_ApeMaternoAlu));

 DECLARE @SQLString NVARCHAR(4000),  
   @ParmDefinition NVARCHAR(500);
    
 SET @SQLString = N'SELECT mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod,   
  mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno,   
  mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,  
  mat.I_Anio,   
  mat.T_Periodo,  
  ISNULL(pro.T_ProcesoDesc, '''') AS T_ProcesoDesc,  
  cab.I_MontoOblig,  
  cab.D_FecVencto,  
  cab.B_Pagado AS B_Pagado,  
  ISNULL(SUM(pagpro.I_MontoPagado), 0) AS I_MontoPagadoActual,  
  cab.D_FecCre,  
  cab.D_FecMod,
  STUFF(( SELECT '', '' + CONVERT(VARCHAR, pagban2.D_FecPago, 103)
        FROM dbo.TR_PagoBanco pagban2
        WHERE EXISTS(
				SELECT * FROM dbo.TRI_PagoProcesadoUnfv pagpro2 
				INNER JOIN dbo.TR_ObligacionAluDet det2 ON det2.I_ObligacionAluDetID = pagpro2.I_ObligacionAluDetID
				WHERE pagpro2.I_PagoBancoID = pagban2.I_PagoBancoID AND pagpro2.B_Anulado = 0 AND 
					det2.B_Habilitado = 1 AND det2.B_Eliminado = 0 AND det2.I_ObligacionAluID = cab.I_ObligacionAluID
			)
        FOR XML PATH('''')), 1, 1,'''') AS T_FecPagos
  FROM dbo.VW_MatriculaAlumno mat  
  LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
  LEFT JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
  LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
  LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0  
  LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0  
  WHERE mat.B_Habilitado = 1 and mat.I_Anio = @I_Anio  
   ' + CASE WHEN @C_CodAlu IS NULL THEN '' ELSE ' and mat.C_CodAlu = @C_CodAlu ' END + '  
   ' + CASE WHEN @T_NomAlu IS NULL OR LEN(@T_NomAlu) = 0 THEN '' ELSE ' and mat.T_Nombre LIKE @T_NomAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
   ' + CASE WHEN @T_ApePaternoAlu IS NULL OR LEN(@T_ApePaternoAlu) = 0 THEN '' ELSE ' and mat.T_ApePaterno LIKE @T_ApePaternoAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
   ' + CASE WHEN @T_ApeMaternoAlu IS NULL OR LEN(@T_ApeMaternoAlu) = 0 THEN '' ELSE ' and mat.T_ApeMaterno LIKE @T_ApeMaternoAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
   ' + CASE WHEN @B_EsPregrado = 1 THEN 'and mat.N_Grado = @Pregrado' ELSE 'and mat.N_Grado IN (@Maestria, @Doctorado)' END + '  
   ' + CASE WHEN @I_Periodo IS NULL THEN '' ELSE 'and mat.I_Periodo = @I_Periodo' END + '  
   ' + CASE WHEN @C_CodFac IS NULL THEN '' ELSE 'and mat.C_CodFac = @C_CodFac' END + '  
   ' + CASE WHEN @C_CodEsc IS NULL THEN '' ELSE 'and mat.C_CodEsc = @C_CodEsc' END + '  
   ' + CASE WHEN @C_RcCod IS NULL THEN '' ELSE 'and mat.C_RcCod = @C_RcCod' END + '  
   ' + CASE WHEN @B_Ingresante IS NULL THEN '' ELSE 'and mat.B_Ingresante = @B_Ingresante' END + '  
   ' + CASE WHEN @B_ObligacionGenerada IS NULL THEN '' ELSE (CASE WHEN @B_ObligacionGenerada = 1 THEN 'and cab.I_ObligacionAluID IS NOT NULL' ELSE 'and cab.I_ObligacionAluID IS NULL' END) END  + '  
   ' + CASE WHEN @B_Pagado IS NULL  THEN '' ELSE 'and cab.B_Pagado = @B_Pagado' END + '  
   ' + CASE WHEN @F_FecIni IS NULL THEN '' ELSE 'and DATEDIFF(DAY, @F_FecIni, pagban.D_FecPago) >= 0' END + '  
   ' + CASE WHEN @F_FecFin IS NULL THEN '' ELSE 'and DATEDIFF(DAY, pagban.D_FecPago, @F_FecFin) >= 0' END + '  
  GROUP BY mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno,   
   mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,  
   mat.I_Anio, mat.T_Periodo, pro.T_ProcesoDesc, cab.I_MontoOblig, cab.D_FecVencto, cab.B_Pagado, cab.D_FecCre, cab.D_FecMod  
  ' + CASE WHEN @B_MontoPagadoDiff IS NULL OR @B_MontoPagadoDiff = 0 THEN '' ELSE 'HAVING NOT cab.I_MontoOblig = SUM(pagpro.I_MontoPagado)' END + '  
  ORDER BY mat.T_FacDesc, mat.T_DenomProg, mat.T_ApePaterno, mat.T_ApeMaterno';  
   
 SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_Periodo INT = NULL,   
  @C_CodFac VARCHAR(2), @C_CodEsc VARCHAR(2), @C_RcCod VARCHAR(3) = NULL , @B_Ingresante BIT = NULL, @B_Pagado BIT = NULL, @F_FecIni DATE = NULL, @F_FecFin DATE = NULL,  
  @C_CodAlu VARCHAR(10), @T_NomAlu VARCHAR(50), @T_ApePaternoAlu VARCHAR(50), @T_ApeMaternoAlu VARCHAR(50)';    

print @SQLString

 EXECUTE sp_executesql @SQLString, @ParmDefinition,   
  @Pregrado = @Pregrado,  
  @Maestria = @Maestria,  
  @Doctorado = @Doctorado,  
  @I_Anio = @I_Anio,  
  @I_Periodo = @I_Periodo,  
  @C_CodFac = @C_CodFac,  
  @C_CodEsc = @C_CodEsc,  
  @C_RcCod = @C_RcCod,  
  @B_Ingresante = @B_Ingresante,  
  @B_Pagado = @B_Pagado,  
  @F_FecIni = @F_FecIni,  
  @F_FecFin = @F_FecFin,  
  @C_CodAlu = @C_CodAlu,
  @T_NomAlu = @T_NomAlu,
  @T_ApePaternoAlu = @T_ApePaternoAlu,
  @T_ApeMaternoAlu = @T_ApeMaternoAlu
/*  
EXEC USP_S_ListadoEstadoObligaciones  
@B_EsPregrado = 1,
@I_Anio = 2021,
@I_Periodo = NULL,
@C_CodFac = NULL,  
@C_CodEsc = NULL,  
@C_RcCod = NULL,  
@B_Ingresante = NULL,  
@B_ObligacionGenerada = NULL,  
@B_Pagado = NULL,  
@F_FecIni = NULL,  
@F_FecFin = NULL,  
@B_MontoPagadoDiff = NULL,  
@C_CodAlu = '2018005074',
@T_NomAlu = NULL,
@T_ApePaternoAlu = NULL,
@T_ApeMaternoAlu = NULL
GO
*/  
END
GO