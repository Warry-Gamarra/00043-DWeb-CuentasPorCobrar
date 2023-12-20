USE BD_OCEF_CtasPorCobrar
GO


UPDATE dbo.TC_CatalogoOpcion SET T_OpcionCod = '6' WHERE I_OpcionID = 8

INSERT dbo.TC_CatalogoOpcion(I_ParametroID, T_OpcionCod, T_OpcionDesc, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(2, '5', 'Residentado Médico', 1, 0, 1, GETDATE())
GO

ALTER VIEW [dbo].[VW_Pagos]  
AS  
 SELECT   
  ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,  
  cta.I_CtaDepositoID, ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, pagban.C_CodOperacion, pagban.C_CodDepositante, pagban.I_PagoBancoID,  
  pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod AS C_Periodo,  
  CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre) AS T_NomAlumno,
  cab.I_ObligacionAluID, pro.I_ProcesoID, pro.I_CuotaPagoID, mat.C_CodAlu, mat.C_RcCod, pro.I_Anio,
  (CAST(pro.I_Anio AS varchar) + '-' + tipPer.T_OpcionCod + ' ' + cat.T_CatPagoDesc) AS T_Concepto, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,
  pagban.T_LugarPago, SUM(pagpro.I_MontoPagado) AS I_MontoPagado, ISNULL(srv.C_CodServicio, '') AS C_CodServicio,   
  pagban.C_Referencia, pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc, 
  ISNULL(pagban.T_InformacionAdicional, '') AS T_InformacionAdicional, mat.I_DependenciaID, tipEs.T_OpcionCod as C_Nivel
 FROM dbo.VW_MatriculaAlumno mat  
  INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0 AND cab.B_Habilitado = 1
  INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0 AND det.B_Habilitado = 1
  INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
  INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0  
  LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0  
  INNER JOIN dbo.TC_CatalogoOpcion tipEs ON tipEs.I_ParametroID = 2 AND tipEs.I_OpcionID = cat.I_Nivel
  INNER JOIN dbo.TC_CatalogoOpcion tipPer ON tipPer.I_ParametroID = 5 AND tipPer.I_OpcionID = pro.I_Periodo  
  INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0  
  INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0  
  INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID  
  INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID  
 WHERE pagban.I_TipoPagoID = 133  
 GROUP BY  
  mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto,  
  cta.I_CtaDepositoID, C_NumeroCuenta, pagban.C_CodOperacion, pagban.C_CodDepositante, pagban.I_PagoBancoID,
  pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod,
  CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre), cat.T_CatPagoDesc,  
  cab.I_ObligacionAluID, pro.I_ProcesoID, pro.I_CuotaPagoID, mat.C_CodAlu, mat.C_RcCod,
  cab.C_Moneda, pagban.T_LugarPago, ISNULL(srv.C_CodServicio, ''),  
  pagban.C_Referencia, pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, ''),
  ISNULL(pagban.T_InformacionAdicional, ''), mat.I_DependenciaID, tipEs.T_OpcionCod
GO


ALTER VIEW [dbo].[VW_PagoTasas]  
AS  
 SELECT pag.I_PagoBancoID, tu.I_TasaUnfvID, pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc,  
  tu.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto,  
  pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre, pag.D_FecMod,  
  pag.C_CodigoInterno, pag.T_Observacion,  
  cons.I_AnioConstancia, cons.I_NroConstancia, pag.I_CondicionPagoID, cond.T_OpcionDesc AS T_Condicion
 FROM dbo.TR_PagoBanco pag  
 INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID  
 INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID  
 INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID  
 INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID  
 INNER JOIN dbo.TI_TasaUnfv tu ON tu.I_TasaUnfvID = pr.I_TasaUnfvID 
 INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pag.I_CondicionPagoID
 LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = tu.T_Clasificador  
 LEFT JOIN dbo.TR_ConstanciaPago cons ON cons.I_PagoBancoID = pag.I_PagoBancoID  
 WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND t.B_Eliminado = 0 AND ef.B_Eliminado = 0 AND tu.B_Eliminado = 0  
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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_Listar_ObligacionesPendientes_Pregrado')
	DROP PROCEDURE [dbo].[USP_S_Listar_ObligacionesPendientes_Pregrado]
GO

CREATE PROCEDURE [dbo].[USP_S_Listar_ObligacionesPendientes_Pregrado]
@I_Anio INT,
@I_Nivel INT,
@I_Periodo INT = NULL,
@C_CodFac VARCHAR(2) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
	ROW_NUMBER() OVER(PARTITION BY mat.I_Anio, mat.I_Periodo, mat.C_CodRc, mat.C_CodAlu ORDER BY pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
	mat.I_Anio,
	mat.I_Periodo,
	mat.C_CodRc,
	mat.C_CodAlu,
	alu.C_CodFac,
	alu.C_CodEsc,
	alu.T_Nombre,
	alu.T_ApePaterno,
	alu.T_ApeMaterno,
	pro.I_ProcesoID,
	per.T_OpcionCod AS C_Periodo,
	pro.I_Prioridad,
	pro.N_CodBanco,
	ISNULL(srv.C_CodServicio, '') AS C_CodServicio,
	cab.D_FecVencto,
	cab.I_MontoOblig,
	ISNULL((SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro
		INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID
		WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0 AND det.B_Mora = 0), 0) AS I_MontoPagadoSinMora
	FROM dbo.TC_MatriculaAlumno mat
	INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos alu ON alu.C_CodAlu = mat.C_CodAlu AND alu.C_RcCod = mat.C_CodRc 
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
	INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
	LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
	INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = pro.I_Periodo
	WHERE mat.B_Eliminado = 0 AND mat.B_Habilitado = 1 AND cat.I_Nivel = @I_Nivel AND cab.B_Pagado = 0 AND cab.I_MontoOblig > 0 AND
		mat.I_Anio = @I_Anio AND 
		mat.I_Periodo = ISNULL(@I_Periodo, mat.I_Periodo) AND 
		alu.C_CodFac = ISNULL(@C_CodFac, alu.C_CodFac)
END
GO



CREATE TABLE dbo.TC_TipoComprobante
(
	I_TipoComprobanteID INT IDENTITY(1,1),
	C_TipoComprobanteCod VARCHAR(50) NOT NULL,
	T_TipoComprobanteDesc VARCHAR(250) NOT NULL,
	T_Inicial VARCHAR(5),
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_TipoComprobante PRIMARY KEY (I_TipoComprobanteID)
)
GO

CREATE TABLE dbo.TC_EstadoComprobante
(
	I_EstadoComprobanteID INT IDENTITY(1,1),
	C_EstadoComprobanteCod VARCHAR(50) NOT NULL,
	T_EstadoComprobanteDesc VARCHAR(250) NOT NULL,
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_EstadoComprobante PRIMARY KEY (I_EstadoComprobanteID)
)
GO

CREATE TABLE dbo.TC_SerieComprobante(
	I_SerieID INT IDENTITY(1,1),
	I_NumeroSerie INT NOT NULL,
	I_FinNumeroComprobante INT NOT NULL,
	I_DiasAnterioresPermitido INT NOT NULL,
	B_Habilitado INT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_SerieComprobante PRIMARY KEY (I_SerieID)
)
GO

CREATE TABLE dbo.TR_Comprobante(
	I_ComprobanteID INT IDENTITY(1,1),
	I_TipoComprobanteID INT NOT NULL,
	I_SerieID INT NOT NULL,
	I_NumeroComprobante INT NOT NULL,	
	B_EsGravado BIT NOT NULL,
	D_FechaEmision DATETIME NOT NULL,
	I_EstadoComprobanteID INT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_Comprobante PRIMARY KEY (I_ComprobanteID),
	CONSTRAINT FK_TipoComprobante_ComprobantePago FOREIGN KEY (I_TipoComprobanteID) REFERENCES TC_TipoComprobante(I_TipoComprobanteID),
	CONSTRAINT FK_Estado_ComprobantePago FOREIGN KEY (I_EstadoComprobanteID) REFERENCES TC_EstadoComprobante(I_EstadoComprobanteID),
	CONSTRAINT UQ_ComprobantePago UNIQUE (I_SerieID, I_NumeroComprobante),
	CONSTRAINT FK_SerieComprobante_ComprobantePago FOREIGN KEY (I_SerieID) REFERENCES TC_SerieComprobante(I_SerieID)
)
GO

CREATE TABLE dbo.TR_Comprobante_PagoBanco(
	I_ComprobantePagoBancoID INT IDENTITY(1,1),
	I_ComprobanteID INT NOT NULL,
	I_PagoBancoID INT NOT NULL,
	B_Habilitado BIT NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	I_UsuarioMod INT,
	D_FecMod DATETIME,
	CONSTRAINT PK_ComprobantePagoBanco PRIMARY KEY(I_ComprobantePagoBancoID),
	CONSTRAINT FK_ComprobantePago_ComprobantePagoBanco FOREIGN KEY (I_ComprobanteID) REFERENCES TR_Comprobante(I_ComprobanteID),
	CONSTRAINT FK_PagoBanco_ComprobantePagoBanco FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco(I_PagoBancoID)
)
GO

INSERT dbo.TC_SerieComprobante(I_NumeroSerie, I_FinNumeroComprobante, I_DiasAnterioresPermitido, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES(1, 99999999, 7, 1, 1, GETDATE())
GO

INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, T_Inicial, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('01', 'Factura', 'F', 0, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, T_Inicial, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('03', 'Boleta de venta', 'B', 1, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, T_Inicial, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('07', 'Nota de crédito', '', 0, 1, GETDATE())
INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, T_Inicial, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('08', 'Nota de débito', '', 0, 1, GETDATE())
GO

INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('PEN', 'Pendiente', 1, 1, GETDATE())
INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('PRO', 'Procesado', 1, 1, GETDATE())
INSERT dbo.TC_EstadoComprobante(C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES('ERR', 'Error', 1, 1, GETDATE())
GO

CREATE TYPE dbo.type_Ids AS TABLE(ID INT)
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarComprobantePago')
	DROP PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarComprobantePago]
@PagoBancoIDs [dbo].[type_Ids] READONLY,
@I_TipoComprobanteID INT,
@I_SerieID INT,
@B_EsGravado BIT,
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	DECLARE @I_ComprobanteID INT,
			@I_NuevoNumeroComprobante INT,
			@D_FechaAccion DATETIME,
			@D_FechaEmision DATETIME,
			@I_EstadoComprobanteID INT,
			--VALIDACIONES
			@I_FinNumeroComprobante INT,
			@D_FecPago DATETIME,
			@I_DiasPermitidos INT;

	SET @I_NuevoNumeroComprobante = (SELECT ISNULL(MAX(c.I_NumeroComprobante), 0) FROM dbo.TR_Comprobante c WHERE c.I_SerieID = @I_SerieID) + 1;

	SET @D_FecPago = (SELECT TOP 1 b.D_FecPago FROM dbo.TR_PagoBanco b WHERE b.I_PagoBancoID IN (SELECT i.ID FROM @PagoBancoIDs i))

	SELECT @I_FinNumeroComprobante = s.I_FinNumeroComprobante, @I_DiasPermitidos = s.I_DiasAnterioresPermitido 
	FROM dbo.TC_SerieComprobante s WHERE s.I_SerieID = @I_SerieID;

	IF (@I_NuevoNumeroComprobante <= @I_FinNumeroComprobante) BEGIN
		IF (DATEDIFF(DAY, @D_FecPago, GETDATE()) <= @I_DiasPermitidos) BEGIN

			SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante WHERE C_EstadoComprobanteCod = 'PEN');
		
			SET @D_FechaAccion = GETDATE();
		
			SET @D_FechaEmision = GETDATE();

			BEGIN TRAN
			BEGIN TRY
				INSERT dbo.TR_Comprobante(I_TipoComprobanteID, I_SerieID, I_NumeroComprobante, B_EsGravado, D_FechaEmision, I_EstadoComprobanteID, I_UsuarioCre, D_FecCre)
				VALUES(@I_TipoComprobanteID, @I_SerieID, @I_NuevoNumeroComprobante, @B_EsGravado, @D_FechaEmision, @I_EstadoComprobanteID, @UserID, @D_FechaAccion);

				SET @I_ComprobanteID = SCOPE_IDENTITY();

				UPDATE dbo.TR_Comprobante_PagoBanco SET 
					B_Habilitado = 0,
					I_UsuarioMod = @UserID,
					D_FecMod = @D_FechaAccion
				WHERE I_PagoBancoID IN (SELECT ID FROM @PagoBancoIDs) AND B_Habilitado = 1;

				INSERT dbo.TR_Comprobante_PagoBanco(I_ComprobanteID, I_PagoBancoID, B_Habilitado, I_UsuarioCre, D_FecCre)
				SELECT @I_ComprobanteID, ID, 1, @UserID, @D_FechaAccion FROM @PagoBancoIDs;

				COMMIT TRAN
				SET @B_Result = 1;
				SET @T_Message = 'Generación de número de comprobante (' + CAST(@I_NuevoNumeroComprobante AS VARCHAR(20)) + ') exitoso.';
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN
				SET @B_Result = 0;
				SET @T_Message = ERROR_MESSAGE();
			END CATCH

		END ELSE BEGIN
			SET @B_Result = 0;
			SET @T_Message = 'Se excedió la cantidad de días de antigüedad (' + CAST(@I_DiasPermitidos AS VARCHAR) + ') del pago para generar el número de comprobante.';
		END
	END ELSE BEGIN
		SET @B_Result = 0;
		SET @T_Message = 'Se excedió el valor permitido (' + CAST(@I_FinNumeroComprobante AS VARCHAR(100)) + ') para el número de comprobante.';
	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoComprobantePago')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoComprobantePago]
@I_NumeroSerie INT,
@I_NumeroComprobante INT,
@C_EstadoComprobanteCod VARCHAR(50),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	DECLARE @D_FechaAccion DATETIME,
			@I_EstadoComprobanteID INT;

	IF EXISTS(SELECT c.I_ComprobanteID FROM dbo.TR_Comprobante c INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
		WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante) BEGIN
		
		IF EXISTS(SELECT c.I_ComprobanteID FROM dbo.TR_Comprobante c 
			INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
			INNER JOIN TR_Comprobante_PagoBanco cp ON cp.I_ComprobanteID = c.I_ComprobanteID
			WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante AND cp.B_Habilitado = 1) BEGIN

			IF EXISTS(SELECT c.I_ComprobanteID FROM dbo.TR_Comprobante c 
				INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
				INNER JOIN dbo.TC_EstadoComprobante e ON e.I_EstadoComprobanteID = c.I_EstadoComprobanteID
				WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante AND e.C_EstadoComprobanteCod = 'PEN') BEGIN

				SET @D_FechaAccion = GETDATE();

				SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante WHERE C_EstadoComprobanteCod = @C_EstadoComprobanteCod);

				BEGIN TRAN
				BEGIN TRY
					UPDATE c SET 
						c.I_EstadoComprobanteID = @I_EstadoComprobanteID,
						c.I_UsuarioMod = @UserID,
						c.D_FecMod = @D_FechaAccion
					FROM dbo.TR_Comprobante c
					INNER JOIN dbo.TC_SerieComprobante s ON s.I_SerieID = c.I_SerieID
					WHERE s.I_NumeroSerie = @I_NumeroSerie AND c.I_NumeroComprobante = @I_NumeroComprobante

					COMMIT TRAN
					SET @B_Result = 1;
					SET @T_Message = 'Actualización de estado correcta.';
				END TRY
				BEGIN CATCH
					ROLLBACK TRAN
					SET @B_Result = 0;
					SET @T_Message = ERROR_MESSAGE();
				END CATCH

			END ELSE BEGIN
				SET @B_Result = 1;
				SET @T_Message = 'El comprobante con serie "' + CAST(@I_NumeroSerie AS VARCHAR) + '" y número "' + CAST(@I_NumeroComprobante AS VARCHAR(20)) + '" ya tiene actualizado el estado.';
			END

		END ELSE BEGIN
			SET @B_Result = 1;
			SET @T_Message = 'El comprobante con serie "' + CAST(@I_NumeroSerie AS VARCHAR) + '" y número "' + CAST(@I_NumeroComprobante AS VARCHAR(20)) + '" está deshabilitado.';
		END
	END ELSE BEGIN
		SET @B_Result = 0;
		SET @T_Message = 'No existe el comprobante con serie "' + CAST(@I_NumeroSerie AS VARCHAR) + '" y número "' + CAST(@I_NumeroComprobante AS VARCHAR(20)) + '".';
	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ListarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarComprobantePago]
@I_TipoPagoID INT = NULL,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL,
@C_CodOperacion VARCHAR(50) = NULL,
@C_CodigoInterno VARCHAR(250) = NULL,
@C_CodDepositante VARCHAR(20) = NULL,
@T_NomDepositante VARCHAR(200) = NULL,
@D_FechaInicio DATETIME = NULL,
@D_FechaFin DATETIME = NULL,
@I_TipoComprobanteID INT = NULL,
@I_EstadoGeneracion BIT = NULL,
@I_EstadoComprobanteID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @SQLString NVARCHAR(4000),  
			@ParmDefinition NVARCHAR(500);

	SET @SQLString = N'SELECT
		pagBan.I_PagoBancoID,
		ban.I_EntidadFinanID,
		ban.T_EntidadDesc,
		cta.C_NumeroCuenta,
		pagBan.C_CodOperacion,
		pagBan.C_CodigoInterno,
		pagBan.C_CodDepositante,
		pagban.T_NomDepositante,
		pagBan.D_FecPago,
		pagBan.I_MontoPago,
		pagBan.I_InteresMora,
		pagBan.T_LugarPago,
		cond.T_OpcionDesc AS ''T_Condicion'',
		pagBan.I_TipoPagoID,
		com.I_ComprobanteID,
		ser.I_NumeroSerie,
		com.I_NumeroComprobante,
		com.D_FechaEmision,
		com.B_EsGravado,
		tipCom.C_TipoComprobanteCod,
		tipCom.T_TipoComprobanteDesc,
		tipCom.T_Inicial,
		estCom.C_EstadoComprobanteCod,
		estCom.T_EstadoComprobanteDesc
	FROM dbo.TR_PagoBanco pagBan
	INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
	LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID AND cpb.B_Habilitado = 1
	LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
	LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
	LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
	LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
	WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_TipoPagoID = 132
	' + CASE WHEN @I_TipoPagoID IS NULL THEN '' ELSE 'AND pagBan.I_TipoPagoID = @I_TipoPagoID' END + '
	' + CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND pagBan.I_EntidadFinanID = @I_EntidadFinanID' END + '
	' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND pagBan.I_CtaDepositoID = @I_CtaDepositoID' END + '
	' + CASE WHEN @C_CodOperacion IS NULL THEN '' ELSE 'AND pagBan.C_CodOperacion LIKE ''%'' + @C_CodOperacion' END + '
	' + CASE WHEN @C_CodigoInterno IS NULL THEN '' ELSE 'AND pagBan.C_CodigoInterno LIKE ''%'' + @C_CodigoInterno' END + '
	' + CASE WHEN @C_CodDepositante IS NULL THEN '' ELSE 'AND pagBan.C_CodDepositante LIKE ''%'' + @C_CodDepositante' END + '
	' + CASE WHEN @T_NomDepositante IS NULL THEN '' ELSE 'AND pagBan.T_NomDepositante LIKE ''%'' + @T_NomDepositante + ''%'' COLLATE Modern_Spanish_CI_AI' END + '
	' + CASE WHEN @D_FechaInicio IS NULL THEN '' ELSE 'AND DATEDIFF(DAY, pagBan.D_FecPago, @D_FechaInicio) <= 0' END + '
	' + CASE WHEN @D_FechaFin IS NULL THEN '' ELSE 'AND DATEDIFF(DAY, pagBan.D_FecPago, @D_FechaFin) >= 0' END + '
	' + CASE WHEN @I_TipoComprobanteID IS NULL THEN '' ELSE 'AND com.I_TipoComprobanteID = @I_TipoComprobanteID' END + '
	' + CASE WHEN @I_EstadoGeneracion IS NULL THEN '' ELSE (CASE WHEN @I_EstadoGeneracion = 1 THEN 'AND com.I_ComprobanteID IS NOT NULL' ELSE 'AND com.I_ComprobanteID IS NULL' END) END + '
	' + CASE WHEN @I_EstadoComprobanteID IS NULL THEN '' ELSE 'AND com.I_EstadoComprobanteID = @I_EstadoComprobanteID' END + '
	ORDER BY pagBan.D_FecPago DESC';
	
	SET @ParmDefinition = N'@I_TipoPagoID INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @C_CodOperacion VARCHAR(50), @C_CodigoInterno VARCHAR(250),
		@C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200), @D_FechaInicio DATETIME, @D_FechaFin DATETIME, @I_TipoComprobanteID INT, @I_EstadoComprobanteID INT';

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_TipoPagoID = @I_TipoPagoID,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID,
		@C_CodOperacion = @C_CodOperacion,
		@C_CodigoInterno = @C_CodigoInterno,
		@C_CodDepositante = @C_CodDepositante,
		@T_NomDepositante = @T_NomDepositante,
		@D_FechaInicio = @D_FechaInicio,
		@D_FechaFin = @D_FechaFin,
		@I_TipoComprobanteID = @I_TipoComprobanteID,
		@I_EstadoComprobanteID = @I_EstadoComprobanteID;
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ObtenerComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
@I_PagoBancoID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @C_CodDepositante VARCHAR(250),
			@I_EntidadFinanID INT,
			@C_CodOperacion VARCHAR(250),
			@D_FecPago DATETIME,
			@OBLIGACION INT = 133,
			@TASA INT = 134;

	SELECT 
		@C_CodDepositante = b.C_CodDepositante,
		@I_EntidadFinanID = b.I_EntidadFinanID,
		@C_CodOperacion = b.C_CodOperacion,
		@D_FecPago = D_FecPago
	FROM dbo.TR_PagoBanco b
	WHERE b.I_PagoBancoID = @I_PagoBancoID ;

	SELECT
		pagBan.I_PagoBancoID,
		ban.I_EntidadFinanID,
		ban.T_EntidadDesc,
		cta.C_NumeroCuenta,
		pagBan.C_CodOperacion,
		pagBan.C_CodigoInterno,
		pagBan.C_CodDepositante,
		pagban.T_NomDepositante,
		pagBan.D_FecPago,
		pagBan.I_MontoPago,
		pagBan.I_InteresMora,
		pagBan.T_LugarPago,
		cond.T_OpcionDesc AS 'T_Condicion',
		pagBan.I_TipoPagoID,
		com.I_ComprobanteID,
		ser.I_NumeroSerie,
		com.I_NumeroComprobante,
		com.D_FechaEmision,
		com.B_EsGravado,
		tipCom.C_TipoComprobanteCod,
		tipCom.T_TipoComprobanteDesc,
		tipCom.T_Inicial,
		estCom.C_EstadoComprobanteCod,
		estCom.T_EstadoComprobanteDesc,
		CASE WHEN pagBan.I_TipoPagoID = @OBLIGACION THEN pagBan.T_ProcesoDescArchivo  + ' (F.VCTO.' + CONVERT(VARCHAR(10), pagBan.D_FecVenctoArchivo, 103) + ')'
			ELSE (SELECT t.T_ConceptoPagoDesc FROM dbo.TRI_PagoProcesadoUnfv pr INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
			WHERE pr.B_Anulado = 0 AND pr.I_PagoBancoID = pagBan.I_PagoBancoID) END AS T_Concepto,
		pagBan.I_Cantidad
	FROM dbo.TR_PagoBanco pagBan
	INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
	LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID AND cpb.B_Habilitado = 1
	LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
	LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
	LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
	LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
	WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_CondicionPagoID = 132 AND 
		pagBan.C_CodDepositante	 = @C_CodDepositante AND
		pagBan.I_EntidadFinanID = @I_EntidadFinanID AND
		pagBan.C_CodOperacion = @C_CodOperacion AND
		DATEDIFF(SECOND, pagBan.D_FecPago, @D_FecPago) = 0
	ORDER BY pagBan.D_FecVenctoArchivo;
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarTipoComprobante')
	DROP PROCEDURE [dbo].[USP_I_GrabarTipoComprobante]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarTipoComprobante]
@C_TipoComprobanteCod VARCHAR(50),
@T_TipoComprobanteDesc VARCHAR(250),
@T_Inicial VARCHAR(5),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	SET @D_FechaAccion = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		INSERT dbo.TC_TipoComprobante(C_TipoComprobanteCod, T_TipoComprobanteDesc, T_Inicial, B_Habilitado, I_UsuarioCre, D_FecCre)
		VALUES(@C_TipoComprobanteCod, @T_TipoComprobanteDesc, @T_Inicial, 1, @UserID, @D_FechaAccion);

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Grabación correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarTipoComprobante')
	DROP PROCEDURE [dbo].[USP_U_ActualizarTipoComprobante]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarTipoComprobante]
@I_TipoComprobanteID INT,
@C_TipoComprobanteCod VARCHAR(250),
@T_TipoComprobanteDesc VARCHAR(250),
@T_Inicial VARCHAR(5),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	SET @D_FechaAccion = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		UPDATE dbo.TC_TipoComprobante SET
			C_TipoComprobanteCod = @C_TipoComprobanteCod,
			T_TipoComprobanteDesc = @T_TipoComprobanteDesc,
			T_Inicial = @T_Inicial,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_TipoComprobanteID = @I_TipoComprobanteID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Actualización correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoTipoComprobante')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoTipoComprobante]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoTipoComprobante]
@I_TipoComprobanteID INT,
@B_Habilitado BIT,
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	SET @D_FechaAccion = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		UPDATE dbo.TC_TipoComprobante SET
			B_Habilitado = @B_Habilitado,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_TipoComprobanteID = @I_TipoComprobanteID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Actualización correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_D_EliminarTipoComprobante')
	DROP PROCEDURE [dbo].[USP_D_EliminarTipoComprobante]
GO

CREATE PROCEDURE [dbo].[USP_D_EliminarTipoComprobante]
@I_TipoComprobanteID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY
		DELETE dbo.TC_TipoComprobante WHERE I_TipoComprobanteID = @I_TipoComprobanteID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Eliminación correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarSerieComprobante')
	DROP PROCEDURE [dbo].[USP_I_GrabarSerieComprobante]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarSerieComprobante]
@I_NumeroSerie INT,
@I_FinNumeroComprobante INT,
@I_DiasAnterioresPermitido INT,
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	SET @D_FechaAccion = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		INSERT dbo.TC_SerieComprobante(I_NumeroSerie, I_FinNumeroComprobante, I_DiasAnterioresPermitido, B_Habilitado, I_UsuarioCre, D_FecCre)
		VALUES(@I_NumeroSerie, @I_FinNumeroComprobante, @I_DiasAnterioresPermitido, 1, @UserID, @D_FechaAccion);

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Grabación correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarSerieComprobante')
	DROP PROCEDURE [dbo].[USP_U_ActualizarSerieComprobante]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarSerieComprobante]
@I_SerieID INT,
@I_NumeroSerie INT,
@I_FinNumeroComprobante INT,
@I_DiasAnterioresPermitido INT,
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	SET @D_FechaAccion = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		UPDATE dbo.TC_SerieComprobante SET
			I_NumeroSerie = @I_NumeroSerie,
			I_FinNumeroComprobante = @I_FinNumeroComprobante,
			I_DiasAnterioresPermitido = @I_DiasAnterioresPermitido,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_SerieID = @I_SerieID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Actualización correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarEstadoSerieComprobante')
	DROP PROCEDURE [dbo].[USP_U_ActualizarEstadoSerieComprobante]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarEstadoSerieComprobante]
@I_SerieID INT,
@B_Habilitado BIT,
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME;

	SET @D_FechaAccion = GETDATE();

	BEGIN TRAN
	BEGIN TRY
		UPDATE dbo.TC_SerieComprobante SET
			B_Habilitado = @B_Habilitado,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_SerieID = @I_SerieID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Actualización correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_D_EliminarSerieComprobante')
	DROP PROCEDURE [dbo].[USP_D_EliminarSerieComprobante]
GO

CREATE PROCEDURE [dbo].[USP_D_EliminarSerieComprobante]
@I_SerieID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY
		DELETE dbo.TC_SerieComprobante WHERE I_SerieID = @I_SerieID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Eliminación correcta.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO
