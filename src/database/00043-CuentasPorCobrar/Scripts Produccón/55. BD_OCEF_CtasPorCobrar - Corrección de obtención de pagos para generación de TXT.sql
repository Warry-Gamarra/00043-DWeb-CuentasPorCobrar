USE BD_OCEF_CtasPorCobrar
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_Listar_ObligacionesPendientes_Posgrado')
	DROP PROCEDURE [dbo].[USP_S_Listar_ObligacionesPendientes_Posgrado]
GO

CREATE PROCEDURE [dbo].[USP_S_Listar_ObligacionesPendientes_Posgrado]
@I_Anio INT,
@C_CodEsc VARCHAR(2) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	WITH Tmp_CuotasPosgrado(I_NroOrden, I_MatAluID, I_Anio, I_Periodo, C_CodRc, C_CodAlu, C_CodFac, C_CodEsc, T_Nombre, T_ApePaterno, T_ApeMaterno, I_ProcesoID, C_Periodo, I_Prioridad, N_CodBanco, 
		C_CodServicio, I_ObligacionAluID, D_FecVencto, I_MontoOblig, B_Pagado, I_MontoPagadoSinMora)
	AS
	(
		SELECT
		ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
		mat.I_MatAluID,
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
		cab.I_ObligacionAluID,
		cab.D_FecVencto,
		cab.I_MontoOblig,
		cab.B_Pagado,
		ISNULL(
			(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID
			WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0 AND det.B_Mora = 0), 0) AS I_MontoPagadoSinMora
		FROM dbo.TC_MatriculaAlumno mat
		INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos alu ON alu.C_CodAlu = mat.C_CodAlu AND alu.C_RcCod = mat.C_CodRc
		INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
		INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
		LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
		INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = pro.I_Periodo
		WHERE mat.B_Eliminado = 0 AND mat.B_Habilitado = 1 AND cat.I_Nivel IN (5, 6) AND alu.C_CodEsc = ISNULL(@C_CodEsc, alu.C_CodEsc)
	)
	SELECT 
		mat.I_NroOrden, mat.I_Anio, mat.I_Periodo, mat.C_CodRc, mat.C_CodAlu, mat.C_CodFac, mat.C_CodEsc, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_ProcesoID, mat.C_Periodo, mat.I_Prioridad, mat.N_CodBanco, 
		mat.C_CodServicio, mat.D_FecVencto, mat.I_MontoOblig, mat.I_MontoPagadoSinMora
	FROM Tmp_CuotasPosgrado mat
	WHERE 
		mat.B_Pagado = 0 AND
		mat.I_MontoOblig > 0 AND
		mat.I_Prioridad = 1 AND
		DATEDIFF(DAY, GETDATE(), mat.D_FecVencto) >= 0
	UNION
	SELECT 
		pen.I_NroOrden, pen.I_Anio, pen.I_Periodo, pen.C_CodRc, pen.C_CodAlu, pen.C_CodFac, pen.C_CodEsc, pen.T_Nombre, pen.T_ApePaterno, pen.T_ApeMaterno, pen.I_ProcesoID, pen.C_Periodo, pen.I_Prioridad, pen.N_CodBanco, 
		pen.C_CodServicio, pen.D_FecVencto, pen.I_MontoOblig, pen.I_MontoPagadoSinMora
	FROM Tmp_CuotasPosgrado pen
	WHERE 
		pen.I_Anio <= @I_Anio AND
		pen.B_Pagado = 0 AND
		pen.I_MontoOblig > 0 AND
		pen.I_Prioridad = 2 AND 
		(
			EXISTS (--Se muestran pensiones de alumnos que pagaron su matrícula
				SELECT mat2.I_ObligacionAluID FROM Tmp_CuotasPosgrado mat2 
				WHERE 
					mat2.I_MatAluID = pen.I_MatAluID AND 
					mat2.I_Anio = pen.I_Anio AND 
					mat2.I_Periodo = pen.I_Periodo AND
					mat2.I_Prioridad = 1 AND
					(
						(DATEDIFF(DAY, GETDATE(), mat2.D_FecVencto) >= 0 AND mat2.B_Pagado = 0) OR
						(mat2.B_Pagado = 1)
					)
			)
		OR 
			NOT EXISTS(--Se muestran alumnos que sólo pagan pensiones (caso de reservas de matrícula)
				SELECT mat3.I_ObligacionAluID FROM Tmp_CuotasPosgrado mat3
				WHERE
					mat3.I_MatAluID = pen.I_MatAluID AND 
					mat3.I_Anio = pen.I_Anio AND 
					mat3.I_Periodo = pen.I_Periodo AND
					mat3.I_Prioridad = 1
			)
		)
END
GO