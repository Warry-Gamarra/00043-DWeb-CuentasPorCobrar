USE BD_OCEF_CtasPorCobrar
GO


--Registro de código de servicio 054.
BEGIN TRAN
BEGIN TRY
	DECLARE @I_ServicioID INT,
			@I_CtaDepositoID INT;

	INSERT dbo.TC_Servicios(C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado) VALUES('054', 'ALQ. AUDITORIO/EXTERNO (01 HR)', 1, 0);

	SET @I_ServicioID = IDENT_CURRENT('TC_Servicios');

	SET @I_CtaDepositoID = (SELECT I_CtaDepositoID FROM dbo.TC_CuentaDeposito WHERE C_NumeroCuenta = '110-01-0414438');

	INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(@I_CtaDepositoID, @I_ServicioID, 1, 0, 1, GETDATE())

	COMMIT TRAN
	PRINT 'Registro exitoso.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE()
END CATCH
GO


--Corrección de código de servicio con tasa.
UPDATE dbo.TI_TasaUnfv_CtaDepoServicio SET B_Habilitado = 0, B_Eliminado = 1 WHERE I_TasaUnfvID = 33 AND I_CtaDepoServicioID = 4;
GO


--Corrección en la fecha de vencimiento en la tabla detalle.
UPDATE d SET d.D_FecVencto = c.D_FecVencto
FROM dbo.TR_ObligacionAluDet d
INNER JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = d.I_ObligacionAluID
INNER JOIN dbo.TC_MatriculaAlumno m ON m.I_MatAluID = c.I_MatAluID
WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND
	c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND
	NOT DATEDIFF(DAY, c.D_FecVencto, d.D_FecVencto) = 0;
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListadoEstadoObligaciones')
	DROP PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
@I_TipoEstudio INT,  
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
/*
EXEC USP_S_ListadoEstadoObligaciones  
@I_TipoEstudio = 2,
@I_Anio = 2023,
@I_Periodo = 20,
@C_CodFac = NULL,  
@C_CodEsc = NULL,  
@C_RcCod = NULL,  
@B_Ingresante = NULL,  
@B_ObligacionGenerada = NULL,  
@B_Pagado = NULL,  
@F_FecIni = NULL,  
@F_FecFin = NULL,  
@B_MontoPagadoDiff = NULL,  
@C_CodAlu = '2019920039',
@T_NomAlu = NULL,
@T_ApePaternoAlu = NULL,
@T_ApeMaternoAlu = NULL,
@I_DependenciaID = NULL
GO
*/  
BEGIN  
	SET NOCOUNT ON;  

	DECLARE @Pregrado CHAR(1) = '1',  
	@Maestria CHAR(1) = '2',  
	@Doctorado CHAR(1) = '3',
	@SegundaEspecialidad CHAR(1) = '4',
	@Residentado CHAR(1) = '5';
 
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
	SUM(pagpro.I_MontoPagado + pagpro.I_PagoDemas) AS I_MontoPagadoActual,
	cab.D_FecCre,  
	cab.D_FecMod,
	STUFF(( SELECT '', '' + CAST(pagban1.I_MontoPago AS VARCHAR)
		FROM dbo.TR_PagoBanco pagban1
		WHERE EXISTS(
				SELECT * FROM dbo.TRI_PagoProcesadoUnfv pagpro1
				INNER JOIN dbo.TR_ObligacionAluDet det1 ON det1.I_ObligacionAluDetID = pagpro1.I_ObligacionAluDetID
				WHERE pagpro1.I_PagoBancoID = pagban1.I_PagoBancoID AND pagpro1.B_Anulado = 0 AND 
					det1.B_Habilitado = 1 AND det1.B_Eliminado = 0 AND det1.B_Mora = 0 AND det1.I_ObligacionAluID = cab.I_ObligacionAluID
			)
		FOR XML PATH('''')), 1, 1,'''') AS T_MontoPagos,
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
	LEFT JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  AND det.B_Mora = 0
	LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
	LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0  
	LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0  
	WHERE mat.B_Habilitado = 1 and mat.I_Anio = @I_Anio  
	' + CASE WHEN @C_CodAlu IS NULL THEN '' ELSE ' and mat.C_CodAlu = @C_CodAlu ' END + '  
	' + CASE WHEN @T_NomAlu IS NULL OR LEN(@T_NomAlu) = 0 THEN '' ELSE ' and mat.T_Nombre LIKE @T_NomAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
	' + CASE WHEN @T_ApePaternoAlu IS NULL OR LEN(@T_ApePaternoAlu) = 0 THEN '' ELSE ' and mat.T_ApePaterno LIKE @T_ApePaternoAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
	' + CASE WHEN @T_ApeMaternoAlu IS NULL OR LEN(@T_ApeMaternoAlu) = 0 THEN '' ELSE ' and mat.T_ApeMaterno LIKE @T_ApeMaternoAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
	' + CASE WHEN @I_TipoEstudio = 1 THEN 'and mat.N_Grado = @Pregrado' ELSE (CASE WHEN @I_TipoEstudio = 2 THEN 'and mat.N_Grado IN (@Maestria, @Doctorado)' ELSE (CASE WHEN @I_TipoEstudio = 3 THEN 'and mat.N_Grado = @SegundaEspecialidad' ELSE 'and mat.N_Grado = @Residentado' END) END) END + '  
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
   
	SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @SegundaEspecialidad CHAR(1), @Residentado CHAR(1), @I_Anio INT, @I_Periodo INT = NULL,   
	@C_CodFac VARCHAR(2), @C_CodEsc VARCHAR(2), @C_RcCod VARCHAR(3) = NULL , @B_Ingresante BIT = NULL, @B_Pagado BIT = NULL, @F_FecIni DATE = NULL, @F_FecFin DATE = NULL,  
	@C_CodAlu VARCHAR(10), @T_NomAlu VARCHAR(50), @T_ApePaternoAlu VARCHAR(50), @T_ApeMaternoAlu VARCHAR(50), @I_DependenciaID INT = NULL';

	EXECUTE sp_executesql @SQLString, @ParmDefinition,   
		@Pregrado = @Pregrado,  
		@Maestria = @Maestria,  
		@Doctorado = @Doctorado,  
		@SegundaEspecialidad = @SegundaEspecialidad,
		@Residentado = @Residentado,
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
		@I_DependenciaID = @I_DependenciaID;
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarProceso')
DROP PROCEDURE [dbo].[USP_U_ActualizarProceso]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarProceso]
@I_ProcesoID INT,    
@I_CatPagoID INT,    
@I_Anio SMALLINT = null,    
@D_FecVencto DATETIME = null,    
@D_FecVenctoExt DATETIME = NULL,
@I_Prioridad TINYINT = null,    
@N_CodBanco VARCHAR(10) = null,    
@T_ProcesoDesc VARCHAR(250) = null,    
@B_Habilitado BIT,    
@I_UsuarioMod INT,    
@B_EditarFecha BIT,    
@I_CuotaPagoID INT = NULL,  
@B_Result BIT OUTPUT,    
@T_Message NVARCHAR(4000) OUTPUT    
AS    
BEGIN    
	SET NOCOUNT ON;

	BEGIN TRAN

	BEGIN TRY
		DECLARE @CurrentDate DATETIME = GETDATE();

		UPDATE dbo.TC_Proceso SET
			I_CatPagoID = @I_CatPagoID,
			I_Anio = @I_Anio,
			D_FecVencto = @D_FecVencto,
			D_FecVenctoExt = @D_FecVenctoExt,
			I_Prioridad = @I_Prioridad,
			N_CodBanco = @N_CodBanco,
			T_ProcesoDesc = @T_ProcesoDesc,
			B_Habilitado = @B_Habilitado,
			I_UsuarioMod = @I_UsuarioMod,
			D_FecMod = @CurrentDate,
			I_CuotaPagoID = @I_CuotaPagoID
		WHERE I_ProcesoID = @I_ProcesoID;

		IF (@B_EditarFecha = 1) BEGIN

			SET @D_FecVencto = CASE WHEN @D_FecVenctoExt IS NOT NULL
				THEN (CASE WHEN DATEDIFF(DAY, @CurrentDate, @D_FecVencto) >= 0 THEN @D_FecVencto ELSE @D_FecVenctoExt END)
				ELSE @D_FecVencto END;

			UPDATE det SET 
				det.D_FecVencto = @D_FecVencto,
				I_UsuarioMod = @I_UsuarioMod,
				D_FecMod = @CurrentDate
			FROM dbo.TR_ObligacionAluCab cab
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
			WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.B_Pagado = 0 AND cab.I_ProcesoID = @I_ProcesoID AND cab.B_EsAmpliacionCred = 0;

			UPDATE cab SET 
				cab.D_FecVencto = @D_FecVencto,
				I_UsuarioMod = @I_UsuarioMod,
				D_FecMod = @CurrentDate
			FROM dbo.TR_ObligacionAluCab cab
			WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.B_Pagado = 0 AND cab.I_ProcesoID = @I_ProcesoID AND cab.B_EsAmpliacionCred = 0;
		END

		COMMIT TRAN

		SET @B_Result = 1;
		SET @T_Message = 'Actualización de datos correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10));
	END CATCH
END
GO
