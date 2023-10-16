/*

USE [master]
GO
ALTER DATABASE [BD_UNFV_Repositorio] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [BD_UNFV_Repositorio]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_UNFV_Repositorio_20231012.bak' WITH FILE = 1, 
     MOVE N'BD_UNFV_Repositorio' TO N'F:\Microsoft SQL Server\DATA\BD_UNFV_Repositorio.mdf', 
     MOVE N'BD_UNFV_Repositorio_log' TO N'F:\Microsoft SQL Server\DATA\BD_UNFV_Repositorio_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;

ALTER DATABASE [BD_UNFV_Repositorio] SET MULTI_USER;
GO

USE BD_UNFV_Repositorio
GO

DROP USER [UserUNFV];
DROP USER [UserOCEF];
DROP USER [uweb_general]; 
CREATE USER [UserOCEF] FOR LOGIN [UserOCEF] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE [db_owner] ADD MEMBER [UserOCEF];
GO
---------------------------------------------------------------------------------------------------------------------
USE [master]
GO
ALTER DATABASE [BD_OCEF_CtasPorCobrar] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [BD_OCEF_CtasPorCobrar]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_OCEF_CtasPorCobrar_20231012.bak' WITH FILE = 1, 
     MOVE N'BD_OCEF_CtasPorCobrar' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar.mdf', 
     MOVE N'BD_OCEF_CtasPorCobrar_log' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;

ALTER DATABASE [BD_OCEF_CtasPorCobrar] SET MULTI_USER;
GO

USE BD_OCEF_CtasPorCobrar
GO

DROP USER [UserUNFV];
DROP USER [UserOCEF];
DROP USER [uweb_general]; 
CREATE USER [UserOCEF] FOR LOGIN [UserOCEF] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE [db_owner] ADD MEMBER [UserOCEF];
GO
*/


USE BD_UNFV_Repositorio
GO

ALTER TABLE dbo.TI_CarreraProfesional ALTER COLUMN B_Habilitado BIT NOT NULL;
GO
ALTER TABLE dbo.TI_CarreraProfesional ALTER COLUMN B_Eliminado BIT NOT NULL;
GO
ALTER VIEW [dbo].[VW_CarreraProfesional]  
AS  
SELECT  
 cprof.C_RcCod, cprof.C_CodEsp, cprof.C_CodEsc, cprof.C_CodFac, esp.T_EspDesc, esc.T_EscDesc, fac.T_FacDesc, cprof.T_CarProfDesc,  
 cprof.C_Tipo, cprof.I_Duracion, cprof.B_Anual, cprof.N_Grupo, cprof.N_Grado, cprof.I_IdAplica, cprof.B_Habilitado, cprof.B_Eliminado,
 fac.I_DependenciaID
FROM dbo.TI_CarreraProfesional cprof  
LEFT JOIN dbo.TC_Especialidad esp ON   
 esp.C_CodEsp = cprof.C_CodEsp AND esp.C_CodEsc = cprof.C_CodEsc AND esp.C_CodFac = cprof.C_CodFac AND esp.I_Especialidad = cprof.I_Especialidad AND esp.B_Eliminado = 0  
INNER JOIN dbo.TC_Escuela esc ON esc.C_CodEsc = cprof.C_CodEsc AND esc.C_CodFac = cprof.C_CodFac AND esc.B_Eliminado = 0  
INNER JOIN dbo.TC_Facultad fac ON fac.C_CodFac = cprof.C_CodFac AND fac.B_Eliminado = 0
WHERE cprof.B_Eliminado = 0
GO



USE BD_OCEF_CtasPorCobrar
GO

UPDATE dbo.TC_CatalogoOpcion SET T_OpcionCod = '6' WHERE I_OpcionID = 8

INSERT dbo.TC_CatalogoOpcion(I_ParametroID, T_OpcionCod, T_OpcionDesc, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(2, '5', 'Residentado Médico', 1, 0, 1, GETDATE())
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores]
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia]
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarMatriculaPosgrado')
	DROP PROCEDURE [dbo].[USP_IU_GrabarMatriculaPosgrado]
GO

CREATE PROCEDURE [dbo].[USP_IU_GrabarMatriculaPosgrado]
@Tbl_Matricula [dbo].[type_dataMatricula] READONLY  
,@I_TipoEstudio INT
,@D_FecRegistro datetime    
,@UserID  int    
,@B_Result  bit    OUTPUT    
,@T_Message  nvarchar(4000) OUTPUT
AS    
BEGIN  
	SET NOCOUNT ON;  
  
	BEGIN TRY  
	BEGIN TRANSACTION  
		CREATE TABLE #Tmp_Matricula    
		(    
			C_CodRC   VARCHAR(3),  
			C_CodAlu  VARCHAR(20),    
			I_Anio   INT,    
			C_Periodo  VARCHAR(50),    
			I_Periodo  INT,    
			C_EstMat  VARCHAR(2),    
			C_Ciclo   VARCHAR(2),    
			B_Ingresante BIT,    
			I_CredDesaprob TINYINT    
		);
   
		IF (@I_TipoEstudio = 2) 
		BEGIN
			INSERT #Tmp_Matricula(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob)    
			SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, c.I_OpcionID AS I_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob    
			FROM @Tbl_Matricula AS m    
			INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = m.C_Periodo    
			INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRC    
			WHERE c.B_Eliminado = 0 AND a.N_Grado IN ('2', '3');
		END
		ELSE
		BEGIN
			IF (@I_TipoEstudio = 3)
			BEGIN
				INSERT #Tmp_Matricula(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob)    
				SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, c.I_OpcionID AS I_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob    
				FROM @Tbl_Matricula AS m    
				INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = m.C_Periodo    
				INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRC    
				WHERE c.B_Eliminado = 0 AND a.N_Grado = '4';
			END
			ELSE
			BEGIN
				INSERT #Tmp_Matricula(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob)    
				SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, c.I_OpcionID AS I_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob    
				FROM @Tbl_Matricula AS m    
				INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = m.C_Periodo    
				INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRC    
				WHERE c.B_Eliminado = 0 AND a.N_Grado = '5';
			END;
		END;

		--Update para alumnos sin obligaciones    
		WITH Tmp_SinObligaciones(I_MatAluID, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob)    
		AS    
		(    
			SELECT mat.I_MatAluID, tmp.C_EstMat, tmp.C_Ciclo, tmp.B_Ingresante, tmp.I_CredDesaprob FROM dbo.TC_MatriculaAlumno mat    
			LEFT JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = mat.I_MatAluID AND obl.B_Eliminado = 0    
			INNER JOIN #Tmp_Matricula AS tmp ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo    
			WHERE mat.B_Eliminado = 0 AND obl.I_MatAluID IS NULL    
		)    
		MERGE INTO dbo.TC_MatriculaAlumno AS trg USING Tmp_SinObligaciones AS src ON trg.I_MatAluID = src.I_MatAluID    
		WHEN MATCHED THEN    
		UPDATE SET   C_EstMat = src.C_EstMat    
		, C_Ciclo = src.C_Ciclo    
		, B_Ingresante = src.B_Ingresante    
		, I_CredDesaprob = src.I_CredDesaprob    
		, I_UsuarioMod = @UserID    
		, D_FecMod = @D_FecRegistro;

		--Actualizo información de alumnos que tengan obligaciones generadas pero que NO esten pagas.    
		UPDATE mat SET    
			mat.C_EstMat = tmp.C_EstMat, mat.C_Ciclo = tmp.C_Ciclo, mat.B_Ingresante = tmp.B_Ingresante, mat.I_CredDesaprob = tmp.I_CredDesaprob,    
			mat.I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro    
		FROM dbo.TC_MatriculaAlumno mat    
		INNER JOIN #Tmp_Matricula AS tmp ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo    
		WHERE mat.B_Eliminado = 0 AND NOT EXISTS(    
				SELECT m.I_MatAluID FROM dbo.TC_MatriculaAlumno m    
				INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = m.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1    
				WHERE m.B_Eliminado = 0 AND tmp.C_CodRc = m.C_CodRc AND tmp.C_CodAlu = m.C_CodAlu AND tmp.I_Anio = m.I_Anio AND tmp.I_Periodo = m.I_Periodo    
			);
    
		--Después elimino dichas obligaciones(en detalle) para que se generen de nuevo.    
		UPDATE det SET det.B_Habilitado = 0, det.B_Eliminado = 1, det.I_UsuarioMod = @UserID, det.D_FecMod = @D_FecRegistro    
		FROM #Tmp_Matricula tmp    
		INNER JOIN dbo.TC_MatriculaAlumno mat ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo AND mat.B_Eliminado = 0    
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0    
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0    
		WHERE NOT EXISTS(    
				SELECT m.I_MatAluID FROM dbo.TC_MatriculaAlumno m    
				INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = m.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1    
				WHERE m.B_Eliminado = 0 AND tmp.C_CodRc = m.C_CodRc AND tmp.C_CodAlu = m.C_CodAlu AND tmp.I_Anio = m.I_Anio AND tmp.I_Periodo = m.I_Periodo    
			);
    
		--Después elimino dichas obligaciones(en cabecera) para que se generen de nuevo.    
		UPDATE cab SET cab.B_Habilitado = 0, cab.B_Eliminado = 1, cab.I_UsuarioMod = @UserID, cab.D_FecMod = @D_FecRegistro    
		FROM #Tmp_Matricula tmp    
		INNER JOIN dbo.TC_MatriculaAlumno mat ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo AND mat.B_Eliminado = 0    
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0    
		WHERE NOT EXISTS(    
				SELECT m.I_MatAluID FROM dbo.TC_MatriculaAlumno m    
				INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = m.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1    
				WHERE m.B_Eliminado = 0 AND tmp.C_CodRc = m.C_CodRc AND tmp.C_CodAlu = m.C_CodAlu AND tmp.I_Anio = m.I_Anio AND tmp.I_Periodo = m.I_Periodo    
			);
    
    
		--Insert para alumnos nuevos    
		MERGE INTO TC_MatriculaAlumno AS trg USING #Tmp_Matricula AS src    
		ON trg.C_CodRc = src.C_CodRc AND trg.C_CodAlu = src.C_CodAlu AND trg.I_Anio = src.I_Anio AND trg.I_Periodo = src.I_Periodo AND trg.B_Eliminado = 0    
		WHEN NOT MATCHED BY TARGET THEN    
		INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, C_EstMat, C_Ciclo, B_Ingresante, I_CredDesaprob, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Migrado)    
		VALUES (src.C_CodRc, src.C_CodAlu, src.I_Anio, src.I_Periodo, src.C_EstMat, src.C_Ciclo, src.B_Ingresante, src.I_CredDesaprob, 1, 0, @UserID, @D_FecRegistro, 0);    
    
		--Informar relación de alumnos que ya tienen obligaciones pagadas y de alumnos inexistentes.    
		SELECT DISTINCT tmp.C_CodRC, tmp.C_CodAlu, tmp.I_Anio, tmp.C_Periodo, tmp.C_EstMat, tmp.C_Ciclo, tmp.B_Ingresante, tmp.I_CredDesaprob, 0 as B_Success, 'El alumno tiene obligaciones pagadas.' AS T_Message     
		FROM #Tmp_Matricula tmp    
		INNER JOIN dbo.TC_MatriculaAlumno mat ON tmp.C_CodRc = mat.C_CodRc AND tmp.C_CodAlu = mat.C_CodAlu AND tmp.I_Anio = mat.I_Anio AND tmp.I_Periodo = mat.I_Periodo AND mat.B_Eliminado = 0    
		INNER JOIN dbo.TR_ObligacionAluCab obl ON obl.I_MatAluID = mat.I_MatAluID AND obl.B_Eliminado = 0 AND obl.B_Pagado = 1    
		UNION    
		SELECT m.C_CodRC, m.C_CodAlu, m.I_Anio, m.C_Periodo, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, 0 AS B_Success, 'El Código de alumno no existe.' AS T_Message FROM @Tbl_Matricula AS m    
		LEFT JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRC    
		WHERE a.C_CodAlu IS NULL;
    
		COMMIT TRANSACTION
    
		SET @B_Result = 1;
		SET @T_Message = 'La importación de datos de alumno finalizó de manera exitosa';
      
	END TRY  
	BEGIN CATCH    
		ROLLBACK TRANSACTION
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH  
END
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
/*  
EXEC USP_S_ListadoEstadoObligaciones  
@I_TipoEstudio = 3,
@I_Anio = 2023,
@I_Periodo = 19,
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
@I_DependenciaID = NULL
GO
*/  
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ReportePagoObligacionesPregrado')
	DROP PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPregrado]
GO

CREATE PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPregrado]  
@I_TipoReporte int,  
@I_TipoEstudio int,
@C_CodFac varchar(2) = NULL,  
@D_FechaIni date,  
@D_FechaFin date,  
@I_EntidadFinanID int = NULL,  
@I_CtaDeposito int  = NULL  
AS
/*  
EXEC USP_S_ReportePagoObligacionesPregrado   
@I_TipoReporte = 2,  
@I_TipoEstudio = 2,
@C_CodFac = NULL,  
@D_FechaIni = '20210101',   
@D_FechaFin = '20211231',  
@I_EntidadFinanID = NULL,  
@I_CtaDeposito = NULL  
GO  
*/  
BEGIN  
	SET NOCOUNT ON;  
	DECLARE @Pregrado char(1) = '1',
	@SegundaEspecialidad char(2) = '4',
	@Residentado char(4) = '5',
	@N_Grado char(1);

	SET @N_Grado = CASE WHEN @I_TipoEstudio = 1 THEN @Pregrado ELSE (CASE WHEN @I_TipoEstudio = 3 THEN @SegundaEspecialidad ELSE @Residentado END) END
  
	--@I_TipoReporte: 1: Pagos agrupados por facultad.  
	if (@I_TipoReporte = 1) begin  
		select mat.T_FacDesc, mat.C_CodFac, SUM(pagpro.I_MontoPagado) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
		and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
		and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
		and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_FacDesc, mat.C_CodFac  
		order by mat.T_FacDesc  
	end  
  
	--@I_TipoReporte: 2: Pagos agrupados por concepto.  
	if (@I_TipoReporte = 2) begin  
		select conpag.I_ConceptoID, cl.T_ClasificadorDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc, SUM(pagpro.I_MontoPagado) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
		and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
		and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
		and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by conpag.I_ConceptoID, cl.T_ClasificadorDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
  
	--@I_TipoReporte: 3: Facultad y Concepto.  
	if (@I_TipoReporte = 3) begin  
		select mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc, SUM(pagpro.I_MontoPagado) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
		and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0  
		and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
		and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by mat.T_FacDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end  
  
   
	--@I_TipoReporte: 4: Concepto por Facultad.  
	if (@I_TipoReporte = 4) begin  
		select mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc,   
		COUNT(pagban.I_PagoBancoID) AS I_Cantidad,  
		SUM(pagpro.I_MontoPagado) AS I_MontoTotal   
		from dbo.TR_PagoBanco pagban  
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID  
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID  
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID  
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador  
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @N_Grado  
		and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0   
		and mat.C_CodFac = @C_CodFac  
		and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)  
		and pagban.I_CtaDepositoID = ISNULL(@I_CtaDeposito, pagban.I_CtaDepositoID)  
		group by mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, cl.T_ClasificadorDesc, conpag.T_ConceptoPagoDesc  
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc  
	end
END  
GO














--Actualización de la tabla para la DEVOLUCIÓN DE DINERO
ALTER TABLE dbo.TR_DevolucionPago DROP CONSTRAINT FK_PagoProcesadoUnfv_DevolucionPago
GO

ALTER TABLE dbo.TR_DevolucionPago DROP COLUMN I_PagoProcesID
GO

ALTER TABLE dbo.TR_DevolucionPago ADD I_PagoBancoID INT NOT NULL
GO

ALTER TABLE dbo.TR_DevolucionPago ADD CONSTRAINT FK_PagoBanco_DevolucionPago 
FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco(I_PagoBancoID)
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DevolucionPago')
	DROP VIEW [dbo].[VW_DevolucionPago]
GO

CREATE VIEW [dbo].[VW_DevolucionPago]
AS
(
	(SELECT DP.*, PB.I_MontoPago, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, pr.T_ProcesoDesc AS T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		LEFT JOIN dbo.TC_Proceso pr ON pr.I_ProcesoID = pb.I_ProcesoIDArchivo
	WHERE Dp.B_Anulado = 0)
	UNION
	(SELECT DP.*, PP.I_MontoPagado, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, TU.T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TRI_PagoProcesadoUnfv PP ON PB.I_PagoBancoID = PP.I_PagoProcesID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID
	WHERE DP.B_Anulado = 0)
)
GO

--SELECT * FROM dbo.VW_DevolucionPago

--select t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto, pr.I_MontoPagado, pr.I_PagoDemas, p.I_MontoPago, * 
--from dbo.TR_PagoBanco p
--inner join dbo.TRI_PagoProcesadoUnfv pr on pr.I_PagoBancoID = p.I_PagoBancoID
--inner join dbo.TI_TasaUnfv t on t.I_TasaUnfvID = pr.I_TasaUnfvID
--where p.B_Anulado = 0 and pr.B_Anulado = 0 and p.I_TipoPagoID = 134 and t.M_Monto > 0
--	and pr.I_PagoDemas > 0


--SELECT * FROM TR_PagoBanco
--SELECT * FROM TRI_PagoProcesadoUnfv


