USE BD_OCEF_MigracionTP
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION' AND ROUTINE_NAME = 'Func_B_ValidarExisteTablaDatos')
	DROP FUNCTION [dbo].[Func_B_ValidarExisteTablaDatos]
GO

CREATE FUNCTION Func_B_ValidarExisteTablaDatos 
(
	@T_NombreTabla	varchar(50)
)
RETURNS  bit
AS
BEGIN
	DECLARE  @B_Result bit;

	IF EXIStS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @T_NombreTabla)
	BEGIN
		SET @B_Result = 1;
	END
	ELSE
	BEGIN
		SET @B_Result = 0;
	END

	RETURN @B_Result;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_CambiarEstadoMigrableCuotaPago')
	DROP PROCEDURE [dbo].[USP_U_CambiarEstadoMigrableCuotaPago]
GO
CREATE PROCEDURE USP_U_CambiarEstadoMigrableCuotaPago
	@I_RowID	  int,
	@B_Migrable	  bit,
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	UPDATE TR_MG_CpDes
	SET B_Migrable = @B_Migrable
	WHERE I_RowID = @I_RowID
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaCuotaDePago')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaCuotaDePago]
GO

CREATE PROCEDURE USP_IU_CopiarTablaCuotaDePago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaCuotaDePago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_CpDes int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion  varchar(20), 
		CUOTA_PAGO	float, 
		ELIMINADO bit,
		INS_DESCRIPCIO varchar(255), 
		INS_N_CTA_CTE varchar(255), 
		INS_CODIGO_BNC varchar(255), 
		INS_FCH_VENC datetime, 
		INS_PRIORIDAD varchar(255), 
		INS_C_MORA varchar(255), 
		DEL_DESCRIPCIO varchar(255), 
		DEL_N_CTA_CTE varchar(255), 
		DEL_CODIGO_BNC varchar(255), 
		DEL_FCH_VENC datetime, 
		DEL_PRIORIDAD varchar(255), 
		DEL_C_MORA varchar(255),
		B_Removido	bit
	)

	BEGIN TRY 
		UPDATE	TR_MG_CpDes SET	B_Actualizado = 0,
								B_Migrable = 1			

		MERGE TR_MG_CpDes AS TRG
		USING cp_des AS SRC
		ON	TRG.CUOTA_PAGO = SRC.CUOTA_PAGO 
			AND TRG.ELIMINADO = SRC.ELIMINADO
		WHEN MATCHED THEN
			UPDATE SET	TRG.DESCRIPCIO = SRC.DESCRIPCIO,
						TRG.N_CTA_CTE = SRC.N_CTA_CTE,
						TRG.CODIGO_BNC = SRC.CODIGO_BNC,
						TRG.FCH_VENC = SRC.FCH_VENC,
						TRG.PRIORIDAD = SRC.PRIORIDAD,
						TRG.C_MORA = SRC.C_MORA
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (CUOTA_PAGO, DESCRIPCIO, N_CTA_CTE, ELIMINADO, CODIGO_BNC, FCH_VENC, PRIORIDAD, C_MORA, D_FecCarga, B_Actualizado)
			VALUES (SRC.CUOTA_PAGO, SRC.DESCRIPCIO, SRC.N_CTA_CTE, SRC.ELIMINADO, SRC.CODIGO_BNC, SRC.FCH_VENC, SRC.PRIORIDAD, SRC.C_MORA, @D_FecProceso, 1)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET TRG.B_Removido = 1, 
					   TRG.D_FecRemovido = @D_FecProceso
		OUTPUT	$ACTION, inserted.CUOTA_PAGO, inserted.ELIMINADO, inserted.DESCRIPCIO, inserted.N_CTA_CTE,  
				inserted.CODIGO_BNC, inserted.FCH_VENC, inserted.PRIORIDAD, inserted.C_MORA, deleted.DESCRIPCIO, 
				deleted.N_CTA_CTE, deleted.CODIGO_BNC, deleted.FCH_VENC, deleted.PRIORIDAD, deleted.C_MORA, 
				deleted.B_Removido INTO @Tbl_output;
				

		UPDATE	t_CpDes
		SET		t_CpDes.B_Actualizado = 1,
				t_CpDes.D_FecActualiza = @D_FecProceso
		FROM TR_MG_CpDes AS t_CpDes
		INNER JOIN 	@Tbl_output as t_out ON t_out.CUOTA_PAGO = t_CpDes.CUOTA_PAGO 
					AND t_out.ELIMINADO = t_CpDes.ELIMINADO AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_DESCRIPCIO <> t_out.DEL_DESCRIPCIO OR
				t_out.INS_N_CTA_CTE <> t_out.DEL_N_CTA_CTE OR
				t_out.INS_CODIGO_BNC <> t_out.DEL_CODIGO_BNC OR
				t_out.INS_FCH_VENC <> t_out.DEL_FCH_VENC OR
				t_out.INS_PRIORIDAD <> t_out.DEL_PRIORIDAD OR
				t_out.INS_C_MORA <> t_out.DEL_C_MORA

		SET @I_CpDes = (SELECT COUNT(*) FROM cp_des)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_CpDes AS tot_cuotaPago, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MarcarRepetidosCuotaDePago')
	DROP PROCEDURE [dbo].[USP_IU_MarcarRepetidosCuotaDePago]
GO

CREATE PROCEDURE USP_IU_MarcarRepetidosCuotaDePago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_MarcarRepetidosCuotaDePago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN	
	DECLARE @D_FecProceso datetime = GETDATE() 

	BEGIN TRY 
		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '001 - REPETIDA: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago se encuentra repetida y con estado ACTIVO.|'
		WHERE	CUOTA_PAGO IN (SELECT CUOTA_PAGO FROM TR_MG_CpDes WHERE ELIMINADO = 0 
								GROUP BY CUOTA_PAGO HAVING COUNT(CUOTA_PAGO) > 1)

		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '001 - REPETIDA: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La cuota de pago se encuentra repetida con estado ELIMINADO.|'
		WHERE	CUOTA_PAGO IN (SELECT CUOTA_PAGO FROM TR_MG_CpDes GROUP BY CUOTA_PAGO HAVING COUNT(CUOTA_PAGO) > 1)
				AND ELIMINADO = 1

		SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 0 AND T_Observacion LIKE '%001%'
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_AsignarAnioPeriodoCuotaPago')
	DROP PROCEDURE [dbo].[USP_U_AsignarAnioPeriodoCuotaPago]
GO

CREATE PROCEDURE USP_U_AsignarAnioPeriodoCuotaPago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_AsignarAnioPeriodoCuotaPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 

	BEGIN TRY 
		--1. ASIGNAR AÑO CUOTA PAGO
		DECLARE @cuota_anio AS TABLE (cuota_pago int, anio_cuota varchar(4))
		DECLARE @periodo AS TABLE (cuota_pago int, I_Periodo int, C_CodPeriodo varchar(5), T_Descripcion varchar(50))

			--CUOTAS DE PAGO CON AÑO EN CP_PRI
		INSERT INTO @cuota_anio(cuota_pago, anio_cuota)
			SELECT DISTINCT D.CUOTA_PAGO, ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4)) AS ANO 
			  FROM cp_des D LEFT JOIN cp_pri P ON D.CUOTA_PAGO = P.CUOTA_PAGO 
			 WHERE ISNUMERIC(ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4))) = 1;

			--CUOTAS DE PAGO SIN AÑO EN CP_PRI PERO CON AÑO EN EC_DET
		INSERT INTO @cuota_anio(cuota_pago, anio_cuota)
		SELECT DISTINCT ed.CUOTA_PAGO, ed.ANO FROM ec_det ed 
				INNER JOIN (SELECT cd.CUOTA_PAGO FROM TR_MG_CpDes cd
							LEFT JOIN @cuota_anio ca ON cd.CUOTA_PAGO = ca.cuota_pago
							WHERE anio_cuota IS NULL) cdca
				ON cdca.CUOTA_PAGO = ed.CUOTA_PAGO

		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '002 - 1+ AÑOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago presenta más de un año asociado en las tablas cp_pri o ec_det.|' 
		WHERE	CUOTA_PAGO IN (SELECT cuota_pago FROM @cuota_anio GROUP BY cuota_pago HAVING COUNT(*) > 1)
		
		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '003 - 0 AÑOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ') La cuota de pago no presenta año asociado en las tablas cp_pri o ec_det.|' 
		WHERE	CUOTA_PAGO IN (SELECT cd.CUOTA_PAGO FROM TR_MG_CpDes cd
							  LEFT JOIN @cuota_anio ca ON cd.CUOTA_PAGO = ca.cuota_pago
							  WHERE anio_cuota IS NULL)
	
		UPDATE	tb_des  
		SET		I_Anio = a1.anio_cuota,
				D_FecEvalua = @D_FecProceso
		FROM	TR_MG_CpDes tb_des
				INNER JOIN @cuota_anio a1 ON tb_des.CUOTA_PAGO = a1.cuota_pago
				INNER JOIN (SELECT cuota_pago FROM @cuota_anio GROUP BY cuota_pago HAVING COUNT(*) = 1) a2
				ON a1.cuota_pago= a2.cuota_pago

		--2. ASIGNAR PERIODO CUOTA PAGO
		INSERT INTO @periodo (cuota_pago, I_Periodo, C_CodPeriodo, T_Descripcion)
			SELECT	DISTINCT pri.CUOTA_PAGO, I_OpcionID, T_OpcionCod, T_OpcionDesc 
			FROM	BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion per 
					INNER JOIN cp_pri pri ON per.T_OpcionCod = pri.P
			WHERE I_ParametroID = 5

		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '004 - 1+ PERIODOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La cuota de pago presenta más de un periodo asociado en la tabla cp_pri.|' 
		WHERE	CUOTA_PAGO IN (SELECT cuota_pago FROM @periodo GROUP BY cuota_pago HAVING COUNT(*) > 1)

		UPDATE	tb_des  
		SET		I_Periodo = per1.I_Periodo,
				D_FecEvalua = @D_FecProceso
		FROM	TR_MG_CpDes tb_des
				INNER JOIN @periodo per1 ON tb_des.CUOTA_PAGO = per1.cuota_pago
				INNER JOIN (SELECT cuota_pago FROM @periodo GROUP BY cuota_pago HAVING COUNT(*) = 1) per2
				ON per1.CUOTA_PAGO = per2.cuota_pago

		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '005 - 0 PERIODOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La cuota de pago no presenta un periodo asociado en la tabla cp_pri.|' 
		WHERE	I_Periodo IS NULL


		SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 0 
		AND (T_Observacion LIKE '%002%' OR T_Observacion LIKE '%003%' OR T_Observacion LIKE '%004%' OR T_Observacion LIKE '%005%')
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_AsignarCategoriaCuotaPago')
	DROP PROCEDURE [dbo].[USP_U_AsignarCategoriaCuotaPago]
GO

CREATE PROCEDURE USP_U_AsignarCategoriaCuotaPago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_AsignarCategoriaCuotaPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	
	BEGIN TRY 
		DECLARE @categoria_pago AS TABLE (cuota_pago int, I_CatPagoID int, N_CodBanco varchar(10))
		INSERT INTO @categoria_pago (cuota_pago, I_CatPagoID, N_CodBanco)
			SELECT d.CUOTA_PAGO, c.I_CatPagoID, c.N_CodBanco FROM TR_MG_CpDes d
			LEFT JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago c ON d.CODIGO_BNC = c.N_CodBanco

		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '006 - 1+ CATEGORIAS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La cuota de pago presenta más de una categoría según codBanco.|' 
		WHERE	CUOTA_PAGO IN (SELECT cuota_pago FROM @categoria_pago GROUP BY cuota_pago HAVING COUNT(*) > 1)

		UPDATE	tb_des  
		SET		I_CatPagoID = cat1.I_CatPagoID,
				D_FecEvalua = @D_FecProceso
		FROM	TR_MG_CpDes tb_des
				INNER JOIN @categoria_pago cat1 ON tb_des.CUOTA_PAGO = cat1.cuota_pago
				INNER JOIN (SELECT cuota_pago FROM @categoria_pago GROUP BY cuota_pago HAVING COUNT(*) = 1) cat2
				ON cat1.CUOTA_PAGO = cat2.cuota_pago

		UPDATE	TR_MG_CpDes
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '007 - 0 CATEGORIAS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La cuota de pago no presenta una categoria asociada según codBanco.|' 
		WHERE	I_CatPagoID IS NULL

		SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 0 AND (T_Observacion LIKE '%006%' OR T_Observacion LIKE '%007%')
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataCuotaDePago')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataCuotaDePago]
GO

CREATE PROCEDURE USP_U_AsignarCategoriaCuotaPago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS


		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END