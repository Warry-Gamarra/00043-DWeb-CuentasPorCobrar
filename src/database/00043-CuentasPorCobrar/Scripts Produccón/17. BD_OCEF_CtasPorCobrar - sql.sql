use BD_UNFV_Repositorio
go

select * from dbo.TC_DependenciaUnfv d
inner join dbo.TC_Facultad f on f.I_DependenciaID = d.I_DependenciaID
order by f.T_FacDesc

select * from dbo.TC_Facultad



use BD_OCEF_CtasPorCobrar
go

select * from dbo.webpages_Roles

select * from dbo.TC_Usuario where UserId = 6

select * from dbo.webpages_UsersInRoles where UserId = 6

select * from BD_UNFV_Repositorio.dbo.TC_Facultad
select * from BD_UNFV_Repositorio.dbo.TC_Escuela
select * from BD_UNFV_Repositorio.dbo.TC_Especialidad
select * from BD_UNFV_Repositorio.dbo.TI_CarreraProfesional
select * from BD_UNFV_Repositorio.dbo.TC_ProgramaUnfv
select * from dbo.TC_DependenciaUNFV


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
@T_ApeMaternoAlu VARCHAR(50) = NULL,
@I_DependenciaID INT = NULL
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
   ' + CASE WHEN @I_DependenciaID IS NULL THEN '' ELSE 'and mat.I_DependenciaID = @I_DependenciaID' END + '  
  GROUP BY mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno,   
   mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,  
   mat.I_Anio, mat.T_Periodo, pro.T_ProcesoDesc, cab.I_MontoOblig, cab.D_FecVencto, cab.B_Pagado, cab.D_FecCre, cab.D_FecMod  
  ' + CASE WHEN @B_MontoPagadoDiff IS NULL OR @B_MontoPagadoDiff = 0 THEN '' ELSE 'HAVING NOT cab.I_MontoOblig = SUM(pagpro.I_MontoPagado)' END + '  
  ORDER BY mat.T_FacDesc, mat.T_DenomProg, mat.T_ApePaterno, mat.T_ApeMaterno';  
   
 SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_Periodo INT = NULL,   
  @C_CodFac VARCHAR(2), @C_CodEsc VARCHAR(2), @C_RcCod VARCHAR(3) = NULL , @B_Ingresante BIT = NULL, @B_Pagado BIT = NULL, @F_FecIni DATE = NULL, @F_FecFin DATE = NULL,  
  @C_CodAlu VARCHAR(10), @T_NomAlu VARCHAR(50), @T_ApePaternoAlu VARCHAR(50), @T_ApeMaternoAlu VARCHAR(50), @I_DependenciaID INT = NULL';

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
  @T_ApeMaternoAlu = @T_ApeMaternoAlu,
  @I_DependenciaID = @I_DependenciaID
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
@C_CodAlu = NULL,
@T_NomAlu = NULL,
@T_ApePaternoAlu = NULL,
@T_ApeMaternoAlu = NULL,
@I_DependenciaID = 35
GO
*/  
END
GO



ALTER VIEW [dbo].[VW_Alumnos]
AS
SELECT
	p.I_PersonaID, p.C_CodTipDoc, tdoc.T_TipDocDesc, p.C_NumDNI, p.T_ApePaterno, p.T_ApeMaterno, p.T_Nombre, p.D_FecNac, p.C_Sexo, a.C_CodAlu, a.C_RcCod, 
	ISNULL(car.C_CodEsp, '') AS C_CodEsp, ISNULL(esp.T_EspDesc, '') AS T_EspDesc, 
	car.C_CodEsc, esc.T_EscDesc, 
	car.C_CodFac, fac.T_FacDesc, 
	ISNULL(prog.C_CodProg, '') AS C_CodProg, ISNULL(prog.T_DenomProg, '') AS T_DenomProg, 
	a.C_CodModIng, modIng.T_ModIngDesc, 
	car.N_Grado, grad.T_GradoDesc, car.N_Grupo, a.C_AnioIngreso, 
	a.I_IdPlan, a.B_Habilitado, a.B_Eliminado, fac.I_DependenciaID FROM dbo.TC_Persona p
INNER JOIN dbo.TC_Alumno a ON a.I_PersonaID = p.I_PersonaID AND p.B_Eliminado = 0
LEFT JOIN dbo.TC_TipoDocumentoIdentidad tdoc ON tdoc.C_CodTipDoc = p.C_CodTipDoc
LEFT JOIN dbo.TC_ModalidadIngreso modIng ON  modIng.C_CodModIng = a.C_CodModIng
INNER JOIN dbo.TI_CarreraProfesional car ON car.C_RcCod = a.C_RcCod
LEFT JOIN dbo.TC_Especialidad esp ON 
	esp.C_CodEsp = car.C_CodEsp AND esp.C_CodEsc = car.C_CodEsc AND esp.C_CodFac = car.C_CodFac AND esp.B_Eliminado = 0
INNER JOIN dbo.TC_Escuela esc ON esc.C_CodEsc = car.C_CodEsc AND esc.C_CodFac = car.C_CodFac AND esc.B_Eliminado = 0
INNER JOIN dbo.TC_Facultad fac ON fac.C_CodFac = car.C_CodFac AND fac.B_Eliminado = 0
LEFT JOIN dbo.TC_ProgramaUnfv prog ON prog.C_RcCod = car.C_RcCod
LEFT JOIN dbo.TC_GradoAcademico grad ON grad.C_CodGrado = car.N_Grado
WHERE a.B_Eliminado = 0
GO


ALTER VIEW [dbo].[VW_MatriculaAlumno]
AS
SELECT 
	m.I_MatAluID, a.C_CodAlu, a.C_RcCod, a.T_Nombre, a.T_ApePaterno, ISNULL(a.T_ApeMaterno, '') AS T_ApeMaterno, a.N_Grado, m.I_Anio, m.I_Periodo, 
	a.C_CodFac, a.T_FacDesc, a.C_CodEsc, a.T_EscDesc, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_Habilitado, cat.T_OpcionCod as C_Periodo, cat.T_OpcionDesc as T_Periodo,
	a.T_DenomProg, a.C_CodModIng, A.T_ModIngDesc, CASE WHEN nv.I_AluMultaID IS NULL THEN 0 ELSE 1 END B_TieneMultaPorNoVotar, a.I_DependenciaID
FROM TC_MatriculaAlumno m 
INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRc
LEFT JOIN dbo.TC_CatalogoOpcion cat ON cat.I_OpcionID = m.I_Periodo
LEFT JOIN dbo.TC_AlumnoMultaNoVotar nv ON nv.B_Eliminado = 0 and nv.C_CodAlu = m.C_CodAlu and nv.C_CodRc = m.C_CodRc and nv.I_Periodo = m.I_Periodo and nv.I_Anio = m.I_Anio
WHERE m.B_Eliminado = 0
GO

ALTER VIEW [dbo].[VW_CuotasPago_X_Ciclo]  
AS  
	SELECT   
		ROW_NUMBER() OVER(PARTITION BY mat.I_Anio, mat.I_Periodo, mat.C_RcCod, mat.C_CodAlu ORDER BY pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,  
		cab.I_ObligacionAluID, mat.I_MatAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.C_CodEsc, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo,   
		per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,  
		niv.T_OpcionCod AS C_Nivel, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,  
		cab.B_Pagado, cab.D_FecCre, ISNULL(srv.C_CodServicio, '') AS C_CodServicio, mat.T_FacDesc, mat.T_DenomProg,  
		ISNULL(  
		(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro   
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID   
		WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual,

		ISNULL(
		(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro   
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID   
		WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0 AND det.B_Mora = 0), 0) AS I_MontoPagadoSinMora
	FROM dbo.VW_MatriculaAlumno mat  
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
	INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0  
	LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0  
	INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo  
	INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_OpcionID = cat.I_Nivel  
	INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_OpcionID = cat.I_TipoAlumno
GO

SELECT * FROM dbo.VW_DetalleObligaciones d
WHERE d.I_Anio = 2021 AND d.I_Periodo = 19 AND d.C_CodAlu = '2015317031' AND d.C_RcCod = 'D07'
ORDER BY d.I_Anio, d.I_Periodo, d.D_FecVencto, d.C_CodAlu, d.C_RcCod, d.I_Prioridad


SELECT * FROM dbo.VW_CuotasPago_X_Ciclo c
WHERE c.I_Anio = 2021 AND c.I_Periodo = 19 AND c.C_CodAlu = '2015317031' AND c.C_RcCod = 'D07'