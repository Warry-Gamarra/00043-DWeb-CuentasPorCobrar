USE BD_UNFV_Repositorio
GO


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_Alumnos')
	DROP VIEW [dbo].[VW_Alumnos]
GO

CREATE VIEW [dbo].[VW_Alumnos]
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







USE BD_OCEF_CtasPorCobrar
GO


ALTER TABLE TR_PagoBanco ADD I_ProcesoIDArchivo INT NULL
GO

ALTER TABLE TR_PagoBanco ADD T_ProcesoDescArchivo VARCHAR(250) NULL
GO

ALTER TABLE TR_PagoBanco ADD D_FecVenctoArchivo DATE NULL
GO



UPDATE b SET
	b.I_ProcesoIDArchivo = (SELECT TOP 1 cab.I_ProcesoID FROM dbo.TRI_PagoProcesadoUnfv pr 
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pr.I_ObligacionAluDetID
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID
		WHERE pr.B_Anulado = 0 AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND pr.I_PagoBancoID = b.I_PagoBancoID),

	b.T_ProcesoDescArchivo = (SELECT TOP 1 pro.T_ProcesoDesc FROM dbo.TRI_PagoProcesadoUnfv pr 
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pr.I_ObligacionAluDetID
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID
		INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID
		WHERE pr.B_Anulado = 0 AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND pr.I_PagoBancoID = b.I_PagoBancoID),

	b.D_FecVenctoArchivo = (SELECT TOP 1 cab.D_FecVencto FROM dbo.TRI_PagoProcesadoUnfv pr 
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pr.I_ObligacionAluDetID
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID
		WHERE pr.B_Anulado = 0 AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND pr.I_PagoBancoID = b.I_PagoBancoID)
FROM dbo.TR_PagoBanco b
WHERE b.B_Anulado = 0 AND b.I_TipoPagoID = 133 AND b.I_CondicionPagoID = 131
GO



UPDATE b SET
	b.I_ProcesoIDArchivo = SUBSTRING(b.T_InformacionAdicional, 7, 3),
	b.T_ProcesoDescArchivo = (SELECT p.T_ProcesoDesc FROM dbo.TC_Proceso p WHERE p.I_ProcesoID = SUBSTRING(b.T_InformacionAdicional, 7, 3)),
	b.D_FecVenctoArchivo = (SELECT p.D_FecVencto FROM dbo.TC_Proceso p WHERE p.I_ProcesoID = SUBSTRING(b.T_InformacionAdicional, 7, 3))
FROM dbo.TR_PagoBanco b
WHERE b.B_Anulado = 0 AND b.I_EntidadFinanID = 2 AND b.I_TipoPagoID = 133 AND NOT b.I_CondicionPagoID = 131 AND LEN(b.T_InformacionAdicional) = 24
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_MatriculaAlumno')
	DROP VIEW [dbo].[VW_MatriculaAlumno]
GO

CREATE VIEW [dbo].[VW_MatriculaAlumno]
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



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CuotasPago_X_Ciclo')
	DROP VIEW [dbo].[VW_CuotasPago_X_Ciclo]
GO

CREATE VIEW [dbo].[VW_CuotasPago_X_Ciclo]
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



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CuotasPago_General')
	DROP VIEW [dbo].[VW_CuotasPago_General]
GO
  
CREATE VIEW [dbo].[VW_CuotasPago_General]  
AS  
	SELECT   
		ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,  
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



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoBancoObligaciones')
	DROP VIEW [dbo].[VW_PagoBancoObligaciones]
GO
  
CREATE VIEW [dbo].[VW_PagoBancoObligaciones]
AS  
	SELECT b.I_PagoBancoID, e.I_EntidadFinanID, e.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, b.C_CodOperacion, b.C_CodDepositante,   
		c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, m.N_Grado,
		b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc AS T_Condicion, b.T_Observacion,   
		b.T_MotivoCoreccion, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoProcesado, b.C_CodigoInterno, 
		ISNULL(pro.T_ProcesoDesc, b.T_ProcesoDescArchivo) AS T_ProcesoDesc,
		ISNULL(pro.D_FecVencto, b.D_FecVenctoArchivo) AS D_FecVencto
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
	b.C_CodigoInterno, pro.T_ProcesoDesc, b.T_ProcesoDescArchivo, pro.D_FecVencto, b.D_FecVenctoArchivo
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
	mat.I_Periodo,  
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
	mat.I_Anio, mat.I_Periodo, mat.T_Periodo, pro.T_ProcesoDesc, cab.I_MontoOblig, cab.D_FecVencto, cab.B_Pagado, cab.D_FecCre, cab.D_FecMod  
	' + CASE WHEN @B_MontoPagadoDiff IS NULL OR @B_MontoPagadoDiff = 0 THEN '' ELSE 'HAVING NOT cab.I_MontoOblig = SUM(pagpro.I_MontoPagado)' END + '  
	ORDER BY mat.T_FacDesc, mat.T_DenomProg, mat.T_ApePaterno, mat.T_ApeMaterno';  
   
	SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_Periodo INT = NULL,   
	@C_CodFac VARCHAR(2), @C_CodEsc VARCHAR(2), @C_RcCod VARCHAR(3) = NULL , @B_Ingresante BIT = NULL, @B_Pagado BIT = NULL, @F_FecIni DATE = NULL, @F_FecFin DATE = NULL,  
	@C_CodAlu VARCHAR(10), @T_NomAlu VARCHAR(50), @T_ApePaternoAlu VARCHAR(50), @T_ApeMaternoAlu VARCHAR(50), @I_DependenciaID INT = NULL';

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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ValidarCodOperacionObligacion')
	DROP PROCEDURE [dbo].[USP_S_ValidarCodOperacionObligacion]
GO
  
CREATE PROCEDURE [dbo].[USP_S_ValidarCodOperacionObligacion]  
@C_CodOperacion VARCHAR(50),  
@C_CodDepositante VARCHAR(20) = NULL,  
@I_EntidadFinanID INT,  
@D_FecPago DATETIME =  NULL,  
@I_ProcesoIDArchivo INT = NULL,
@D_FecVenctoArchivo DATE = NULL,
@B_Correct BIT OUTPUT  
AS  
BEGIN  
	SET NOCOUNT ON;  
  
	DECLARE @I_BcoComercio INT = 1,  
	@I_BcoCredito INT = 2  
  
	SET @B_Correct = 0  
  
	IF (@I_EntidadFinanID = @I_BcoComercio) BEGIN  
		SET @B_Correct = CASE WHEN EXISTS(SELECT p.I_PagoBancoID FROM dbo.TR_PagoBanco p  
			WHERE p.B_Anulado = 0 AND p.I_EntidadFinanID = @I_BcoComercio AND  
				C_CodOperacion = @C_CodOperacion) THEN 0 ELSE 1 END  
	END  
  
	IF (@I_EntidadFinanID = @I_BcoCredito) BEGIN  
		SET @B_Correct = CASE WHEN EXISTS(SELECT p.I_PagoBancoID FROM dbo.TR_PagoBanco p  
			WHERE p.B_Anulado = 0 AND p.I_EntidadFinanID = @I_BcoCredito AND 
				((NOT p.C_CodDepositante = @C_CodDepositante AND DATEDIFF(HOUR, p.D_FecPago, @D_FecPago) = 0 AND C_CodOperacion = @C_CodOperacion) 
				OR 
				(p.I_ProcesoIDArchivo = @I_ProcesoIDArchivo AND p.C_CodOperacion = @C_CodOperacion AND DATEDIFF(SECOND, p.D_FecPago, @D_FecPago) = 0 AND DATEDIFF(DAY, p.D_FecVenctoArchivo, @D_FecVenctoArchivo) = 0))
			) THEN 0 ELSE 1 END  
	END  
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
@Tbl_Pagos [dbo].[type_dataPago] READONLY,
@Observacion varchar(250),
@D_FecRegistro datetime, 
@UserID  int
AS    
BEGIN    
	SET NOCOUNT ON;    
    
	DECLARE @Tmp_PagoObligacion TABLE (    
		id INT IDENTITY(1,1),    
		I_ProcesoID   int NULL,    
		I_ObligacionAluID int NULL,    
		C_CodOperacion  varchar(50),    
		C_CodDepositante varchar(20),    
		T_NomDepositante varchar(200),    
		C_Referencia  varchar(50),    
		D_FecPago   datetime,    
		D_FecVencto   datetime,    
		D_FecVenctoBD  datetime,    
		I_Cantidad   int,    
		C_Moneda   varchar(3),    
		I_MontoOblig  decimal(15,2) NULL,    
		I_MontoPago   decimal(15,2),    
		I_InteresMora  decimal(15,2),    
		T_LugarPago   varchar(250),    
		I_EntidadFinanID int,    
		I_CtaDepositoID  int,    
		B_Pagado   bit NULL,    
		B_Success   bit,    
		T_ErrorMessage  varchar(250),    
		T_InformacionAdicional  varchar(250),    
		T_ProcesoDesc  varchar(250),    
		I_CondicionPagoID int,    
		T_Observacion  varchar(250),  
		C_CodigoInterno  varchar(250)
	);  
    
	DECLARE @Tmp_DetalleObligacion TABLE(    
		id INT,    
		I_ObligacionAluDetID int,    
		I_MontoDet   decimal(15,2),    
		I_MontoPagadoDet decimal(15,2)    
	);    
    
	WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto, B_Pagado, I_MontoOblig)    
	AS     
	(    
		SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto, cab.B_Pagado, cab.I_MontoOblig    
		FROM dbo.TC_MatriculaAlumno m
		LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID AND cab.B_Eliminado = 0    
		WHERE m.B_Eliminado = 0
	)    
	INSERT @Tmp_PagoObligacion(I_ProcesoID, I_ObligacionAluID, C_CodOperacion, C_CodDepositante, T_NomDepositante,     
	C_Referencia, D_FecPago, D_FecVencto, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, I_InteresMora, T_LugarPago, I_EntidadFinanID, I_CtaDepositoID, B_Pagado,    
	T_InformacionAdicional, T_ProcesoDesc, D_FecVenctoBD, I_CondicionPagoID, T_Observacion, C_CodigoInterno)    
     
	SELECT p.I_ProcesoID, m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,    
		p.C_Referencia, p.D_FecPago, p.D_FecVencto, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.I_EntidadFinanID, I_CtaDepositoID, m.B_Pagado,    
		p.T_InformacionAdicional, p.T_ProcesoDesc, m.D_FecVencto, p.I_CondicionPagoID, p.T_Observacion, p.C_CodigoInterno    
	FROM @Tbl_Pagos p    
	LEFT JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND     
	m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0    
    
	DECLARE @I_FilaActual  int = 1,    
		@I_CantRegistros int = (select count(id) from @Tmp_PagoObligacion),    
		@I_ProcesoID  int,    
		@T_ProcesoDesc  varchar(250),    
		@I_ObligacionAluID int,    
		--PAGO EN BANCO    
		@I_PagoBancoID  int,       
		@C_CodOperacion  varchar(50),    
		@C_CodDepositante varchar(20),    
		@T_NomDepositante varchar(200),    
		@C_Referencia  varchar(50),    
		@D_FecPago   datetime,    
		@I_Cantidad   int,    
		@C_Moneda   varchar(3),    
		@I_MontoPago  decimal(15,2),    
		@I_InteresMora  decimal(15,2),    
		@T_LugarPago  varchar(250),    
		@I_EntidadFinanID int,    
		@I_CtaDepositoID int,    
		@T_InformacionAdicional varchar(250),    
		@I_CondicionPagoID int,    
		@T_Observacion  varchar(250),    
		@C_CodigoInterno varchar(250),  
		--PAGO DETALLE    
		@I_FilaActualDet int,    
		@I_CantRegistrosDet int,    
		@I_ObligacionAluDetID int,       
		@I_MontoOligacionDet decimal(15,2),    
		@I_MontoPagadoActual decimal(15,2),    
		@I_SaldoPendiente decimal(15,2),    
		@I_MontoAPagar  decimal(15,2),    
		@I_NuevoSaldoPend decimal(15,2),    
		@I_PagoDemas  decimal(15,2),    
		@B_PagoDemas  bit,    
		@B_Pagado   bit,    
		--MORA    
		@I_ConcPagID  int,    
		@D_FecVencto  datetime,    
		--CONTROL ERRORES    
		@D_FecVenctoBD  datetime,    
		@B_ExisteError  bit,
		@B_CodOpeCorrecto bit,    
		@B_ObligPagada  bit,    
		--Constantes    
		@CondicionCorrecto int = 131,--PAGO CORRECTO    
		@CondicionExtorno int = 132,--PAGO EXTORNADO
		@CondicionDoblePago int = 135,--DOBLE PAGO A UNA MISMA OBLIGACIÓN
		@CondicionNoExisteOblg int = 136,--PAGO A UNA OBLIGACIÓN INEXISTENTE
		@PagoTipoObligacion int = 133--OBLIGACION    
    
	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN    
      
		SET @B_ExisteError = 0
    
		SELECT  @I_ProcesoID = I_ProcesoID,    
			@T_ProcesoDesc = T_ProcesoDesc,
			@I_ObligacionAluID = I_ObligacionAluID,     
			@C_CodOperacion = C_CodOperacion,     
			@C_CodDepositante = C_CodDepositante,     
			@T_NomDepositante = T_NomDepositante,     
			@C_Referencia = C_Referencia,     
			@D_FecPago = D_FecPago,     
			@D_FecVencto = D_FecVencto,    
			@I_Cantidad = I_Cantidad,    
			@C_Moneda = C_Moneda,     
			@I_MontoPago = I_MontoPago,    
			@I_InteresMora = I_InteresMora,    
			@T_LugarPago= T_LugarPago,    
			@I_EntidadFinanID = I_EntidadFinanID,    
			@I_CtaDepositoID = I_CtaDepositoID,    
			@B_ObligPagada = B_Pagado,    
			@T_InformacionAdicional = T_InformacionAdicional,    
			@D_FecVenctoBD = D_FecVenctoBD,    
			@I_CondicionPagoID = I_CondicionPagoID,    
			@T_Observacion = CASE WHEN (I_CondicionPagoID = @CondicionCorrecto) THEN @Observacion ELSE T_Observacion END  ,  
			@C_CodigoInterno = C_CodigoInterno
		FROM @Tmp_PagoObligacion 
		WHERE id = @I_FilaActual    
    
		IF (@I_ObligacionAluID IS NULL) BEGIN
			SET @I_CondicionPagoID = @CondicionNoExisteOblg
			SET @T_Observacion = 'No existe obligaciones para este alumno.'
		END
    
		IF NOT(@I_CondicionPagoID IN (@CondicionExtorno, @CondicionNoExisteOblg)) AND (@B_ObligPagada = 1) BEGIN	
			SET @I_CondicionPagoID = @CondicionDoblePago
			SET @T_Observacion = 'Esta obligación ya ha sido pagada con anterioridad.'
		END
    
		IF  (@B_ExisteError = 0) BEGIN
			EXEC dbo.USP_S_ValidarCodOperacionObligacion 
				@C_CodOperacion, 
				@C_CodDepositante, 
				@I_EntidadFinanID, 
				@D_FecPago, 
				@I_ProcesoID,
				@D_FecVencto,
				@B_CodOpeCorrecto OUTPUT
    
			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1
        
				UPDATE @Tmp_PagoObligacion SET 
					B_Success = 0, 
					T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.'
				WHERE id = @I_FilaActual
			END
		END
    
		IF (@B_ExisteError = 0) AND NOT(@I_CondicionPagoID = @CondicionExtorno) AND (@I_InteresMora > 0) AND    
			NOT EXISTS(SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1) BEGIN
    
			SET @B_ExisteError = 1
        
			UPDATE @Tmp_PagoObligacion SET 
				B_Success = 0,
				T_ErrorMessage = 'No existe un concepto para guardar el Interés moratorio.'
			WHERE id = @I_FilaActual
		END
          
		IF (@B_ExisteError = 0) AND (@I_CtaDepositoID IS NULL) BEGIN    
			SET @I_CtaDepositoID = (SELECT cta.I_CtaDepositoID FROM dbo.TI_CtaDepo_Proceso cta
				INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cta.I_CtaDepositoID
				WHERE cta.B_Habilitado = 1 AND cta.B_Eliminado = 0 AND
					cta.I_ProcesoID = @I_ProcesoID and c.I_EntidadFinanID = @I_EntidadFinanID)
    
			IF (@I_CtaDepositoID IS NULL) BEGIN
				SET @B_ExisteError = 1
        
				UPDATE @Tmp_PagoObligacion SET 
					B_Success = 0, 
					T_ErrorMessage = 'No existe una Cuenta asignada para registrar la obligación.' 
				WHERE id = @I_FilaActual
			END
		END
    
		BEGIN TRANSACTION
		BEGIN TRY
			IF (@B_ExisteError = 0) BEGIN
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno,
					I_ProcesoIDArchivo, T_ProcesoDescArchivo, D_FecVenctoArchivo)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @T_Observacion,
					@T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoObligacion, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno,
					@I_ProcesoID, @T_ProcesoDesc, @D_FecVencto)
    
				SET @I_PagoBancoID = SCOPE_IDENTITY()   
    
				IF (@I_CondicionPagoID = @CondicionCorrecto) BEGIN    
    
					DELETE FROM @Tmp_DetalleObligacion    
    
					INSERT @Tmp_DetalleObligacion(id, I_ObligacionAluDetID, I_MontoDet, I_MontoPagadoDet)    
					SELECT ROW_NUMBER() OVER (ORDER BY det.I_Monto ASC), det.I_ObligacionAluDetID, det.I_Monto, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoPagado     
					FROM dbo.TR_ObligacionAluDet det    
					LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND p.B_Anulado = 0    
					WHERE det.I_ObligacionAluID = @I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 0 AND det.B_Pagado = 0    
					GROUP BY det.I_ObligacionAluDetID, det.I_Monto    
					ORDER BY det.I_Monto ASC    
    
					SET @I_FilaActualDet = 1    
					SET @I_CantRegistrosDet = (SELECT COUNT(*) FROM @Tmp_DetalleObligacion)    
    
					WHILE (@I_FilaActualDet <= @I_CantRegistrosDet AND @I_MontoPago > 0) BEGIN    
    
						SELECT    
							@I_ObligacionAluDetID = I_ObligacionAluDetID,     
							@I_MontoOligacionDet = I_MontoDet,     
							@I_MontoPagadoActual = I_MontoPagadoDet     
						FROM @Tmp_DetalleObligacion WHERE id = @I_FilaActualDet    
    
						SET @I_SaldoPendiente = @I_MontoOligacionDet - @I_MontoPagadoActual    
    
						EXEC dbo.USP_AsignarPagoDetalleObligacion    
							@I_FilaActualDet = @I_FilaActualDet,    
							@I_CantRegistrosDet = @I_CantRegistrosDet,    
							@I_SaldoPendiente  = @I_SaldoPendiente,    
							@I_MontoPago = @I_MontoPago OUTPUT,    
							@B_Pagado = @B_Pagado OUTPUT,    
							@I_MontoAPagar = @I_MontoAPagar OUTPUT,    
							@I_NuevoSaldoPend = @I_NuevoSaldoPend OUTPUT,    
							@I_PagoDemas = @I_PagoDemas OUTPUT,    
							@B_PagoDemas = @B_PagoDemas OUTPUT    
        
						INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,    
						D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)    
						VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_MontoAPagar, @I_NuevoSaldoPend, @I_PagoDemas, @B_PagoDemas,    
						@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)    
    
						IF (@B_Pagado = 1) BEGIN    
							UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro    
							WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID    
						END    
    
						SET @I_FilaActualDet = @I_FilaActualDet + 1    
					END    
        
					IF NOT EXISTS (SELECT d.I_ObligacionAluID FROM dbo.TR_ObligacionAluDet d     
						WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND d.B_Mora = 0 AND d.B_Pagado = 0)    
					BEGIN    
						UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = 1, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro    
						WHERE I_ObligacionAluID = @I_ObligacionAluID    
					END    
    
					IF (@I_InteresMora > 0) BEGIN    
						SET @I_ConcPagID = (SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1)    
    
						INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)    
						VALUES (@I_ObligacionAluID, @I_ConcPagID, @I_InteresMora, 1, @D_FecVencto, 1, 0, @UserID, @D_FecRegistro, 1)    
    
						SET @I_ObligacionAluDetID = SCOPE_IDENTITY()    
    
						INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,     
						D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)    
						VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_InteresMora, 0, 0, 0,@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)    
					END    
    
					SET @T_Observacion = 'Registro correcto.'
				END

				UPDATE @Tmp_PagoObligacion SET B_Success = 1, I_CondicionPagoID = @I_CondicionPagoID, T_ErrorMessage = @T_Observacion WHERE id = @I_FilaActual
			END

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION    
    
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual    
		END CATCH    
    
		SET @I_FilaActual = @I_FilaActual + 1    
	END    
    
	SELECT * FROM @Tmp_PagoObligacion    
END    
GO