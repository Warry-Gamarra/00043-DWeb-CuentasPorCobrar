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
		
		UPDATE	TR_MG_CpDes 
				SET	B_Actualizado = 0, B_Migrable = 1, D_FecMigrado = NULL, B_Migrado = 0, T_Observacion = NULL,
					I_Anio = NULL, I_CatPagoID = NULL, I_Periodo = NULL

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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_MarcarRepetidosCuotaDePago')
	DROP PROCEDURE [dbo].[USP_U_MarcarRepetidosCuotaDePago]
GO

CREATE PROCEDURE USP_U_MarcarRepetidosCuotaDePago
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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataCuotaDePagoCtasPorCobrar')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataCuotaDePagoCtasPorCobrar]
GO

CREATE PROCEDURE USP_IU_MigrarDataCuotaDePagoCtasPorCobrar
	@I_AnioIni	  int = NULL,
	@I_AnioFin	  int = NULL,
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
--exec USP_IU_MigrarDataCuotaDePagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	DECLARE @Tbl_outputProceso AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputCtas AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputCtasCat AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @I_Proc_Inserted int = 0
	DECLARE @I_Proc_Updated int = 0
	DECLARE @I_Ctas_Inserted int = 0
	DECLARE @I_Ctas_Updated int = 0
	DECLARE @I_CtaCat_Inserted int = 0
	DECLARE @I_CtaCat_Updated int = 0

	BEGIN TRANSACTION;
	BEGIN TRY 
		SET @I_AnioIni = (SELECT ISNULL(@I_AnioIni, 0))
		SET @I_AnioFin = (SELECT ISNULL(@I_AnioFin, 3000))

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso ON;

		MERGE INTO  BD_OCEF_CtasPorCobrar.dbo.TC_Proceso AS TRG
		USING (SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO 
		WHEN NOT MATCHED BY TARGET THEN 
			 INSERT (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, D_FecCre, B_Habilitado, B_Eliminado)
			 VALUES (CUOTA_PAGO, I_CatPagoID, DESCRIPCIO, I_Anio, I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, 
					CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END, 1, @D_FecProceso, 1, ELIMINADO)
		WHEN MATCHED AND TRG.B_Migrado = 1 AND TRG.I_UsuarioMod IS NULL THEN 
			 UPDATE SET I_CatPagoID = SRC.I_CatPagoID, 
					 T_ProcesoDesc = SRC.DESCRIPCIO, 
					 I_Anio = SRC.I_Anio, 
					 I_Periodo = SRC.I_Periodo,
					 N_CodBanco = SRC.CODIGO_BNC, 
					 D_FecVencto = SRC.FCH_VENC, 
					 I_Prioridad = SRC.PRIORIDAD, 
					 D_FecMod = @D_FecProceso,
					 B_Mora = (CASE SRC.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END)
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputProceso;
		
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF
		
		DECLARE @I_ProcesoID	int
		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, @I_ProcesoID)
		

		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso AS TRG
		USING (SELECT CD.I_CtaDepositoID, TP_CD.* FROM TR_MG_CpDes TP_CD
				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado, D_FecCre)
			VALUES (I_CtaDepositoID, CUOTA_PAGO, 1, ELIMINADO, @D_FecProceso)
		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
			UPDATE SET	B_Eliminado = ELIMINADO,
						D_FecMod = @D_FecProceso
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputCtas;


		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito_CategoriaPago AS TRG
		USING (SELECT DISTINCT CD.I_CtaDepositoID, TP_CD.I_CatPagoID FROM TR_MG_CpDes TP_CD
				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_CatPagoID = SRC.I_CatPagoID AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado, D_FecCre)
			VALUES (I_CtaDepositoID, I_CatPagoID, 1, 0, @D_FecProceso)
		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
			UPDATE SET	D_FecMod = @D_FecProceso
		OUTPUT $action, SRC.I_CatPagoID INTO @Tbl_outputCtasCat;
		
		UPDATE	TR_MG_CpDes 
		SET		B_Migrado = 1, 
				D_FecMigrado = @D_FecProceso
		WHERE	I_RowID IN (SELECT I_RowID FROM @Tbl_outputProceso)

		UPDATE	TR_MG_CpDes 
		SET		T_Observacion = '000 - EXTERNO: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago ha sido ingresada o modificada desde una fuente externa.|',
				B_Migrado = 0 
		WHERE	I_RowID IN (SELECT CD.I_RowID FROM TR_MG_CpDes CD LEFT JOIN @Tbl_outputProceso O ON CD.I_RowID = o.I_RowID 
							WHERE CD.B_Migrable = 1 AND O.I_RowID IS NULL)

		SET @I_Proc_Inserted = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'INSERT')
		SET @I_Proc_Updated = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'UPDATE')
		SET @I_Ctas_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'INSERT')
		SET @I_Ctas_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'UPDATE')
		SET @I_CtaCat_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'INSERT')
		SET @I_CtaCat_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'UPDATE')

		SELECT @I_Proc_Inserted AS proc_count_insert, @I_Proc_Updated AS proc_count_update, 
				@I_Ctas_Inserted AS ctas_count_insert, @I_Ctas_Updated AS ctas_count_update,
				@I_CtaCat_Inserted AS ctas_count_insert, @I_CtaCat_Updated AS ctas_count_update

		COMMIT TRANSACTION;

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
		ROLLBACK TRANSACTION;
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaObligacionesPago')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaObligacionesPago]
GO

CREATE PROCEDURE USP_IU_CopiarTablaObligacionesPago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaObligacionesPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_EcObl int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion  varchar(20),
		I_RowID		int, 
		ANO			nvarchar(255),
		P			nvarchar(255),
		COD_ALU		nvarchar(255),
		COD_RC		nvarchar(255),
		CUOTA_PAGO	float,
		FCH_VENC	datetime,
		TIPO_OBLIG	bit,
		INS_MONTO		float,
		INS_PAGADO		bit,
		DEL_MONTO		float,
		DEL_PAGADO		bit,
		B_Removido	bit
	)

	BEGIN TRY 
		
		MERGE TR_MG_EcObl AS TRG
		USING ec_obl AS SRC
		ON	TRG.ANO = SRC.ANO AND TRG.P = SRC.P
			AND TRG.COD_ALU	= SRC.COD_ALU AND TRG.COD_RC = SRC.COD_RC
			AND TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND TRG.FCH_VENC = SRC.FCH_VENC
			AND TRG.TIPO_OBLIG = SRC.TIPO_OBLIG
		WHEN MATCHED THEN
			UPDATE SET	TRG.PAGADO	= SRC.PAGADO,
						TRG.MONTO	= SRC.MONTO,
						TRG.B_Actualizado = 0, 
						TRG.B_Migrable	  = 1, 
						TRG.D_FecMigrado  = NULL, 
						TRG.B_Migrado	  = 0, 
						TRG.T_Observacion = NULL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ANO, P, COD_ALU, COD_RC, CUOTA_PAGO, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO, D_FecCarga, B_Migrable, B_Migrado, T_Observacion)
			VALUES (ANO, P, COD_ALU, COD_RC, CUOTA_PAGO, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO, @D_FecProceso, 1, 0, NULL)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET	TRG.B_Removido		= 1, 
						TRG.D_FecRemovido	= @D_FecProceso,
						TRG.B_Migrable		= 0, 
						TRG.D_FecMigrado	= 0, 
						TRG.B_Migrado		= 0, 
						TRG.T_Observacion	= NULL
		OUTPUT	$ACTION, inserted.I_RowID, inserted.ANO, inserted.P, inserted.COD_ALU, inserted.COD_RC, inserted.CUOTA_PAGO, inserted.FCH_VENC, inserted.TIPO_OBLIG, 
				inserted.MONTO, inserted.PAGADO, deleted.MONTO, deleted.PAGADO, deleted.B_Removido INTO @Tbl_output;
		
		UPDATE	t_EcObl
		SET		t_EcObl.B_Actualizado = 1,
				t_EcObl.D_FecActualiza = @D_FecProceso
		FROM	TR_MG_EcObl AS t_EcObl
				INNER JOIN 	@Tbl_output as t_out ON t_out.ANO = t_EcObl.ANO 
				AND t_out.P = t_EcObl.P AND t_out.COD_ALU = t_EcObl.COD_ALU
				AND t_out.COD_RC = t_EcObl.COD_RC AND t_out.CUOTA_PAGO = t_EcObl.CUOTA_PAGO
				AND t_out.FCH_VENC = t_EcObl.FCH_VENC AND t_out.TIPO_OBLIG = t_EcObl.TIPO_OBLIG
				AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_MONTO <> t_out.DEL_MONTO OR
				t_out.INS_PAGADO <> t_out.DEL_PAGADO

		SET @I_EcObl = (SELECT COUNT(*) FROM ec_obl)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_EcObl AS tot_obligaciones, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO




IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaDetalleObligacionesPago')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaDetalleObligacionesPago]
GO

CREATE PROCEDURE USP_IU_CopiarTablaDetalleObligacionesPago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaDetalleObligacionesPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_EcDet int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion  varchar(20),
		I_RowID			int, 
		COD_ALU			nvarchar(50),
		COD_RC			nvarchar(50),
		CUOTA_PAGO		float,
		ANO				nvarchar(50),
		P				nvarchar(50),
		TIPO_OBLIG		varchar(50),
		CONCEPTO		float,
		FCH_VENC		nvarchar(50),
		ELIMINADO		nvarchar(50),
		INS_NRO_RECIBO	nvarchar(50),
		INS_FCH_PAGO	nvarchar(50),
		INS_ID_LUG_PAG	nvarchar(50),
		INS_CANTIDAD	nvarchar(50),
		INS_MONTO		nvarchar(50),
		INS_PAGADO		nvarchar(50),
		INS_CONCEPTO_F	nvarchar(50),
		INS_FCH_ELIMIN	nvarchar(50),
		INS_NRO_EC		float,
		INS_FCH_EC		nvarchar(50),
		INS_PAG_DEMAS	nvarchar(50),
		INS_COD_CAJERO	nvarchar(50),
		INS_TIPO_PAGO	nvarchar(50),
		INS_NO_BANCO	nvarchar(50),
		INS_COD_DEP		nvarchar(50),
		DEL_NRO_RECIBO	nvarchar(50),
		DEL_FCH_PAGO	nvarchar(50),
		DEL_ID_LUG_PAG	nvarchar(50),
		DEL_CANTIDAD	nvarchar(50),
		DEL_MONTO		nvarchar(50),
		DEL_PAGADO		nvarchar(50),
		DEL_CONCEPTO_F	nvarchar(50),
		DEL_FCH_ELIMIN	nvarchar(50),
		DEL_NRO_EC		float,
		DEL_FCH_EC		nvarchar(50),
		DEL_PAG_DEMAS	nvarchar(50),
		DEL_COD_CAJERO	nvarchar(50),
		DEL_TIPO_PAGO	nvarchar(50),
		DEL_NO_BANCO	nvarchar(50),
		DEL_COD_DEP		nvarchar(50),
		B_Removido		bit
	)

	BEGIN TRY 		
		MERGE TR_MG_EcDet AS TRG
		USING ec_det AS SRC
		ON	  TRG.COD_ALU = SRC.COD_ALU AND
			  TRG.COD_RC = SRC.COD_RC AND
			  TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND
			  TRG.ANO = SRC.ANO AND
			  TRG.P = SRC.P AND
			  TRG.TIPO_OBLIG = SRC.TIPO_OBLIG AND
			  TRG.CONCEPTO = SRC.CONCEPTO AND
			  TRG.ELIMINADO = SRC.ELIMINADO
		WHEN MATCHED THEN
			UPDATE SET	TRG.FCH_VENC = SRC.FCH_VENC,
						TRG.NRO_RECIBO = SRC.NRO_RECIBO,
						TRG.FCH_PAGO = SRC.FCH_PAGO,
						TRG.ID_LUG_PAG = SRC.ID_LUG_PAG,
						TRG.CANTIDAD = SRC.CANTIDAD,
						TRG.MONTO = SRC.MONTO,
						TRG.PAGADO = SRC.PAGADO,
						TRG.CONCEPTO_F = SRC.CONCEPTO_F,
						TRG.FCH_ELIMIN = SRC.FCH_ELIMIN,
						TRG.NRO_EC = SRC.NRO_EC,
						TRG.FCH_EC = SRC.FCH_EC,
						TRG.PAG_DEMAS = SRC.PAG_DEMAS,
						TRG.COD_CAJERO = SRC.COD_CAJERO,
						TRG.TIPO_PAGO = SRC.TIPO_PAGO,
						TRG.NO_BANCO = SRC.NO_BANCO,
						TRG.COD_DEP	= SRC.COD_DEP,
						TRG.B_Actualizado = 0, 
						TRG.B_Migrable = 1, 
						TRG.D_FecMigrado = NULL, 
						TRG.B_Migrado = 0, 
						TRG.T_Observacion = NULL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, CONCEPTO, FCH_VENC, NRO_RECIBO, FCH_PAGO, ID_LUG_PAG, CANTIDAD, MONTO, PAGADO, CONCEPTO_F, FCH_ELIMIN, NRO_EC, FCH_EC, ELIMINADO, PAG_DEMAS, COD_CAJERO, TIPO_PAGO, NO_BANCO, COD_DEP, D_FecCarga, B_Migrable, B_Migrado, D_FecMigrado, T_Observacion)
			VALUES (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, CONCEPTO, FCH_VENC, NRO_RECIBO, FCH_PAGO, ID_LUG_PAG, CANTIDAD, MONTO, PAGADO, CONCEPTO_F, FCH_ELIMIN, NRO_EC, FCH_EC, ELIMINADO, PAG_DEMAS, COD_CAJERO, TIPO_PAGO, NO_BANCO, COD_DEP, @D_FecProceso, 1, 0, NULL, NULL)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET	TRG.B_Removido		= 1, 
						TRG.D_FecRemovido	= @D_FecProceso,
						TRG.B_Migrable		= 0, 
						TRG.D_FecMigrado	= 0, 
						TRG.B_Migrado		= 0, 
						TRG.T_Observacion	= NULL
		OUTPUT	$ACTION, inserted.I_RowID, inserted.ANO, inserted.P, inserted.COD_ALU, inserted.COD_RC, inserted.CUOTA_PAGO, inserted.FCH_VENC, inserted.TIPO_OBLIG, 
				inserted.MONTO, inserted.PAGADO, deleted.MONTO, deleted.PAGADO, deleted.B_Removido INTO @Tbl_output;
		
		UPDATE	t_EcObl
		SET		t_EcObl.B_Actualizado = 1,
				t_EcObl.D_FecActualiza = @D_FecProceso
		FROM	TR_MG_EcObl AS t_EcObl
				INNER JOIN 	@Tbl_output as t_out ON t_out.ANO = t_EcObl.ANO 
				AND t_out.P = t_EcObl.P AND t_out.COD_ALU = t_EcObl.COD_ALU
				AND t_out.COD_RC = t_EcObl.COD_RC AND t_out.CUOTA_PAGO = t_EcObl.CUOTA_PAGO
				AND t_out.FCH_VENC = t_EcObl.FCH_VENC AND t_out.TIPO_OBLIG = t_EcObl.TIPO_OBLIG
				AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_MONTO <> t_out.DEL_MONTO OR
				t_out.INS_PAGADO <> t_out.DEL_PAGADO

		SET @I_EcObl = (SELECT COUNT(*) FROM ec_obl)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_EcObl AS tot_obligaciones, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO















IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataObligacionesPagoCtasPorCobrar')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataObligacionesPagoCtasPorCobrar]
GO

CREATE PROCEDURE USP_IU_MigrarDataObligacionesPagoCtasPorCobrar
	@I_AnioIni	  int = NULL,
	@I_AnioFin	  int = NULL,
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
--exec USP_IU_MigrarDataObligacionesPagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	DECLARE @Tbl_outputObl AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputDet AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputBnc AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputProc AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @I_Obl_Inserted int = 0
	DECLARE @I_Obl_Updated int = 0
	DECLARE @I_Det_Inserted int = 0
	DECLARE @I_Det_Updated int = 0
	DECLARE @I_Bnc_Inserted int = 0
	DECLARE @I_Bnc_Updated int = 0
	DECLARE @I_Proc_Inserted int = 0
	DECLARE @I_Proc_Updated int = 0

	BEGIN TRANSACTION;
	BEGIN TRY 
		SET @I_AnioIni = (SELECT ISNULL(@I_AnioIni, 0))
		SET @I_AnioFin = (SELECT ISNULL(@I_AnioFin, 3000))

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso ON;

		MERGE INTO  BD_OCEF_CtasPorCobrar.dbo.TC_Proceso AS TRG
		USING (SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO 
		WHEN NOT MATCHED BY TARGET THEN 
			 INSERT (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, D_FecCre, B_Habilitado, B_Eliminado)
			 VALUES (CUOTA_PAGO, I_CatPagoID, DESCRIPCIO, I_Anio, I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, 
					CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END, 1, @D_FecProceso, 1, ELIMINADO)
		WHEN MATCHED AND TRG.B_Migrado = 1 AND TRG.I_UsuarioMod IS NULL THEN 
			 UPDATE SET I_CatPagoID = SRC.I_CatPagoID, 
					 T_ProcesoDesc = SRC.DESCRIPCIO, 
					 I_Anio = SRC.I_Anio, 
					 I_Periodo = SRC.I_Periodo,
					 N_CodBanco = SRC.CODIGO_BNC, 
					 D_FecVencto = SRC.FCH_VENC, 
					 I_Prioridad = SRC.PRIORIDAD, 
					 D_FecMod = @D_FecProceso,
					 B_Mora = (CASE SRC.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END)
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputProceso;
		
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF
		
		DECLARE @I_ProcesoID	int
		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, @I_ProcesoID)
		

		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso AS TRG
		USING (SELECT CD.I_CtaDepositoID, TP_CD.* FROM TR_MG_CpDes TP_CD
				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado, D_FecCre)
			VALUES (I_CtaDepositoID, CUOTA_PAGO, 1, ELIMINADO, @D_FecProceso)
		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
			UPDATE SET	B_Eliminado = ELIMINADO,
						D_FecMod = @D_FecProceso
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputCtas;


		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito_CategoriaPago AS TRG
		USING (SELECT DISTINCT CD.I_CtaDepositoID, TP_CD.I_CatPagoID FROM TR_MG_CpDes TP_CD
				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_CatPagoID = SRC.I_CatPagoID AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado, D_FecCre)
			VALUES (I_CtaDepositoID, I_CatPagoID, 1, 0, @D_FecProceso)
		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
			UPDATE SET	D_FecMod = @D_FecProceso
		OUTPUT $action, SRC.I_CatPagoID INTO @Tbl_outputCtasCat;
		
		UPDATE	TR_MG_CpDes 
		SET		B_Migrado = 1, 
				D_FecMigrado = @D_FecProceso
		WHERE	I_RowID IN (SELECT I_RowID FROM @Tbl_outputProceso)

		UPDATE	TR_MG_CpDes 
		SET		T_Observacion = '000 - EXTERNO: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago ha sido ingresada o modificada desde una fuente externa.|',
				B_Migrado = 0 
		WHERE	I_RowID IN (SELECT CD.I_RowID FROM TR_MG_CpDes CD LEFT JOIN @Tbl_outputProceso O ON CD.I_RowID = o.I_RowID 
							WHERE CD.B_Migrable = 1 AND O.I_RowID IS NULL)

		SET @I_Proc_Inserted = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'INSERT')
		SET @I_Proc_Updated = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'UPDATE')
		SET @I_Ctas_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'INSERT')
		SET @I_Ctas_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'UPDATE')
		SET @I_CtaCat_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'INSERT')
		SET @I_CtaCat_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'UPDATE')

		SELECT @I_Proc_Inserted AS proc_count_insert, @I_Proc_Updated AS proc_count_update, 
				@I_Ctas_Inserted AS ctas_count_insert, @I_Ctas_Updated AS ctas_count_update,
				@I_CtaCat_Inserted AS ctas_count_insert, @I_CtaCat_Updated AS ctas_count_update

		COMMIT TRANSACTION;

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
		ROLLBACK TRANSACTION;
	END CATCH
END
GO





IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaObligacionesPago')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaObligacionesPago]
GO

CREATE PROCEDURE USP_IU_CopiarTablaObligacionesPago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaObligacionesPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_EcObl int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion  varchar(20),
		I_RowID		int, 
		ANO			nvarchar(255),
		P			nvarchar(255),
		COD_ALU		nvarchar(255),
		COD_RC		nvarchar(255),
		CUOTA_PAGO	float,
		FCH_VENC	datetime,
		TIPO_OBLIG	bit,
		INS_MONTO		float,
		INS_PAGADO		bit,
		DEL_MONTO		float,
		DEL_PAGADO		bit,
		B_Removido	bit
	)

	BEGIN TRY 
		
		MERGE TR_MG_EcObl AS TRG
		USING ec_obl AS SRC
		ON	TRG.ANO = SRC.ANO AND TRG.P = SRC.P
			AND TRG.COD_ALU	= SRC.COD_ALU AND TRG.COD_RC = SRC.COD_RC
			AND TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND TRG.FCH_VENC = SRC.FCH_VENC
			AND TRG.TIPO_OBLIG = SRC.TIPO_OBLIG
		WHEN MATCHED THEN
			UPDATE SET	TRG.PAGADO	= SRC.PAGADO,
						TRG.MONTO	= SRC.MONTO,
						TRG.B_Actualizado = 0, 
						TRG.B_Migrable	  = 1, 
						TRG.D_FecMigrado  = NULL, 
						TRG.B_Migrado	  = 0, 
						TRG.T_Observacion = NULL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ANO, P, COD_ALU, COD_RC, CUOTA_PAGO, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO, D_FecCarga, B_Migrable, B_Migrado, T_Observacion)
			VALUES (ANO, P, COD_ALU, COD_RC, CUOTA_PAGO, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO, @D_FecProceso, 1, 0, NULL)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET	TRG.B_Removido		= 1, 
						TRG.D_FecRemovido	= @D_FecProceso,
						TRG.B_Migrable		= 0, 
						TRG.D_FecMigrado	= 0, 
						TRG.B_Migrado		= 0, 
						TRG.T_Observacion	= NULL
		OUTPUT	$ACTION, inserted.I_RowID, inserted.ANO, inserted.P, inserted.COD_ALU, inserted.COD_RC, inserted.CUOTA_PAGO, inserted.FCH_VENC, inserted.TIPO_OBLIG, 
				inserted.MONTO, inserted.PAGADO, deleted.MONTO, deleted.PAGADO, deleted.B_Removido INTO @Tbl_output;
		
		UPDATE	t_EcObl
		SET		t_EcObl.B_Actualizado = 1,
				t_EcObl.D_FecActualiza = @D_FecProceso
		FROM	TR_MG_EcObl AS t_EcObl
				INNER JOIN 	@Tbl_output as t_out ON t_out.ANO = t_EcObl.ANO 
				AND t_out.P = t_EcObl.P AND t_out.COD_ALU = t_EcObl.COD_ALU
				AND t_out.COD_RC = t_EcObl.COD_RC AND t_out.CUOTA_PAGO = t_EcObl.CUOTA_PAGO
				AND t_out.FCH_VENC = t_EcObl.FCH_VENC AND t_out.TIPO_OBLIG = t_EcObl.TIPO_OBLIG
				AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_MONTO <> t_out.DEL_MONTO OR
				t_out.INS_PAGADO <> t_out.DEL_PAGADO

		SET @I_EcObl = (SELECT COUNT(*) FROM ec_obl)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_EcObl AS tot_obligaciones, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO




IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaDetalleObligacionesPago')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaDetalleObligacionesPago]
GO

CREATE PROCEDURE USP_IU_CopiarTablaDetalleObligacionesPago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaDetalleObligacionesPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_EcDet int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion  varchar(20),
		I_RowID			int, 
		COD_ALU			nvarchar(50),
		COD_RC			nvarchar(50),
		CUOTA_PAGO		float,
		ANO				nvarchar(50),
		P				nvarchar(50),
		TIPO_OBLIG		varchar(50),
		CONCEPTO		float,
		FCH_VENC		nvarchar(50),
		ELIMINADO		nvarchar(50),
		INS_NRO_RECIBO	nvarchar(50),
		INS_FCH_PAGO	nvarchar(50),
		INS_ID_LUG_PAG	nvarchar(50),
		INS_CANTIDAD	nvarchar(50),
		INS_MONTO		nvarchar(50),
		INS_PAGADO		nvarchar(50),
		INS_CONCEPTO_F	nvarchar(50),
		INS_FCH_ELIMIN	nvarchar(50),
		INS_NRO_EC		float,
		INS_FCH_EC		nvarchar(50),
		INS_PAG_DEMAS	nvarchar(50),
		INS_COD_CAJERO	nvarchar(50),
		INS_TIPO_PAGO	nvarchar(50),
		INS_NO_BANCO	nvarchar(50),
		INS_COD_DEP		nvarchar(50),
		DEL_NRO_RECIBO	nvarchar(50),
		DEL_FCH_PAGO	nvarchar(50),
		DEL_ID_LUG_PAG	nvarchar(50),
		DEL_CANTIDAD	nvarchar(50),
		DEL_MONTO		nvarchar(50),
		DEL_PAGADO		nvarchar(50),
		DEL_CONCEPTO_F	nvarchar(50),
		DEL_FCH_ELIMIN	nvarchar(50),
		DEL_NRO_EC		float,
		DEL_FCH_EC		nvarchar(50),
		DEL_PAG_DEMAS	nvarchar(50),
		DEL_COD_CAJERO	nvarchar(50),
		DEL_TIPO_PAGO	nvarchar(50),
		DEL_NO_BANCO	nvarchar(50),
		DEL_COD_DEP		nvarchar(50),
		B_Removido		bit
	)

	BEGIN TRY 		
		MERGE TR_MG_EcDet AS TRG
		USING ec_det AS SRC
		ON	  TRG.COD_ALU = SRC.COD_ALU AND
			  TRG.COD_RC = SRC.COD_RC AND
			  TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND
			  TRG.ANO = SRC.ANO AND
			  TRG.P = SRC.P AND
			  TRG.TIPO_OBLIG = SRC.TIPO_OBLIG AND
			  TRG.CONCEPTO = SRC.CONCEPTO AND
			  TRG.ELIMINADO = SRC.ELIMINADO
		WHEN MATCHED THEN
			UPDATE SET	TRG.FCH_VENC = SRC.FCH_VENC,
						TRG.NRO_RECIBO = SRC.NRO_RECIBO,
						TRG.FCH_PAGO = SRC.FCH_PAGO,
						TRG.ID_LUG_PAG = SRC.ID_LUG_PAG,
						TRG.CANTIDAD = SRC.CANTIDAD,
						TRG.MONTO = SRC.MONTO,
						TRG.PAGADO = SRC.PAGADO,
						TRG.CONCEPTO_F = SRC.CONCEPTO_F,
						TRG.FCH_ELIMIN = SRC.FCH_ELIMIN,
						TRG.NRO_EC = SRC.NRO_EC,
						TRG.FCH_EC = SRC.FCH_EC,
						TRG.PAG_DEMAS = SRC.PAG_DEMAS,
						TRG.COD_CAJERO = SRC.COD_CAJERO,
						TRG.TIPO_PAGO = SRC.TIPO_PAGO,
						TRG.NO_BANCO = SRC.NO_BANCO,
						TRG.COD_DEP	= SRC.COD_DEP,
						TRG.B_Actualizado = 0, 
						TRG.B_Migrable = 1, 
						TRG.D_FecMigrado = NULL, 
						TRG.B_Migrado = 0, 
						TRG.T_Observacion = NULL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, CONCEPTO, FCH_VENC, NRO_RECIBO, FCH_PAGO, ID_LUG_PAG, CANTIDAD, MONTO, PAGADO, CONCEPTO_F, FCH_ELIMIN, NRO_EC, FCH_EC, ELIMINADO, PAG_DEMAS, COD_CAJERO, TIPO_PAGO, NO_BANCO, COD_DEP, D_FecCarga, B_Migrable, B_Migrado, D_FecMigrado, T_Observacion)
			VALUES (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, CONCEPTO, FCH_VENC, NRO_RECIBO, FCH_PAGO, ID_LUG_PAG, CANTIDAD, MONTO, PAGADO, CONCEPTO_F, FCH_ELIMIN, NRO_EC, FCH_EC, ELIMINADO, PAG_DEMAS, COD_CAJERO, TIPO_PAGO, NO_BANCO, COD_DEP, @D_FecProceso, 1, 0, NULL, NULL)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET	TRG.B_Removido		= 1, 
						TRG.D_FecRemovido	= @D_FecProceso,
						TRG.B_Migrable		= 0, 
						TRG.D_FecMigrado	= 0, 
						TRG.B_Migrado		= 0, 
						TRG.T_Observacion	= NULL
		OUTPUT	$ACTION, inserted.I_RowID, inserted.ANO, inserted.P, inserted.COD_ALU, inserted.COD_RC, inserted.CUOTA_PAGO, inserted.FCH_VENC, inserted.TIPO_OBLIG, 
				inserted.MONTO, inserted.PAGADO, deleted.MONTO, deleted.PAGADO, deleted.B_Removido INTO @Tbl_output;
		
		UPDATE	t_EcObl
		SET		t_EcObl.B_Actualizado = 1,
				t_EcObl.D_FecActualiza = @D_FecProceso
		FROM	TR_MG_EcObl AS t_EcObl
				INNER JOIN 	@Tbl_output as t_out ON t_out.ANO = t_EcObl.ANO 
				AND t_out.P = t_EcObl.P AND t_out.COD_ALU = t_EcObl.COD_ALU
				AND t_out.COD_RC = t_EcObl.COD_RC AND t_out.CUOTA_PAGO = t_EcObl.CUOTA_PAGO
				AND t_out.FCH_VENC = t_EcObl.FCH_VENC AND t_out.TIPO_OBLIG = t_EcObl.TIPO_OBLIG
				AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_MONTO <> t_out.DEL_MONTO OR
				t_out.INS_PAGADO <> t_out.DEL_PAGADO

		SET @I_EcObl = (SELECT COUNT(*) FROM ec_obl)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_EcObl AS tot_obligaciones, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO















IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataObligacionesPagoCtasPorCobrar')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataObligacionesPagoCtasPorCobrar]
GO

CREATE PROCEDURE USP_IU_MigrarDataObligacionesPagoCtasPorCobrar
	@I_AnioIni	  int = NULL,
	@I_AnioFin	  int = NULL,
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
--exec USP_IU_MigrarDataObligacionesPagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	DECLARE @Tbl_outputObl AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputDet AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputBnc AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @Tbl_outputProc AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @I_Obl_Inserted int = 0
	DECLARE @I_Obl_Updated int = 0
	DECLARE @I_Det_Inserted int = 0
	DECLARE @I_Det_Updated int = 0
	DECLARE @I_Bnc_Inserted int = 0
	DECLARE @I_Bnc_Updated int = 0
	DECLARE @I_Proc_Inserted int = 0
	DECLARE @I_Proc_Updated int = 0

	BEGIN TRANSACTION;
	BEGIN TRY 
		SET @I_AnioIni = (SELECT ISNULL(@I_AnioIni, 0))
		SET @I_AnioFin = (SELECT ISNULL(@I_AnioFin, 3000))

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso ON;

		MERGE INTO  BD_OCEF_CtasPorCobrar.dbo.TC_Proceso AS TRG
		USING (SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO 
		WHEN NOT MATCHED BY TARGET THEN 
			 INSERT (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, D_FecCre, B_Habilitado, B_Eliminado)
			 VALUES (CUOTA_PAGO, I_CatPagoID, DESCRIPCIO, I_Anio, I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, 
					CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END, 1, @D_FecProceso, 1, ELIMINADO)
		WHEN MATCHED AND TRG.B_Migrado = 1 AND TRG.I_UsuarioMod IS NULL THEN 
			 UPDATE SET I_CatPagoID = SRC.I_CatPagoID, 
					 T_ProcesoDesc = SRC.DESCRIPCIO, 
					 I_Anio = SRC.I_Anio, 
					 I_Periodo = SRC.I_Periodo,
					 N_CodBanco = SRC.CODIGO_BNC, 
					 D_FecVencto = SRC.FCH_VENC, 
					 I_Prioridad = SRC.PRIORIDAD, 
					 D_FecMod = @D_FecProceso,
					 B_Mora = (CASE SRC.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END)
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputProceso;
		
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF
		
		DECLARE @I_ProcesoID	int
		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, @I_ProcesoID)
		

		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso AS TRG
		USING (SELECT CD.I_CtaDepositoID, TP_CD.* FROM TR_MG_CpDes TP_CD
				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado, D_FecCre)
			VALUES (I_CtaDepositoID, CUOTA_PAGO, 1, ELIMINADO, @D_FecProceso)
		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
			UPDATE SET	B_Eliminado = ELIMINADO,
						D_FecMod = @D_FecProceso
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputCtas;


		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito_CategoriaPago AS TRG
		USING (SELECT DISTINCT CD.I_CtaDepositoID, TP_CD.I_CatPagoID FROM TR_MG_CpDes TP_CD
				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_CatPagoID = SRC.I_CatPagoID AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado, D_FecCre)
			VALUES (I_CtaDepositoID, I_CatPagoID, 1, 0, @D_FecProceso)
		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
			UPDATE SET	D_FecMod = @D_FecProceso
		OUTPUT $action, SRC.I_CatPagoID INTO @Tbl_outputCtasCat;
		
		UPDATE	TR_MG_CpDes 
		SET		B_Migrado = 1, 
				D_FecMigrado = @D_FecProceso
		WHERE	I_RowID IN (SELECT I_RowID FROM @Tbl_outputProceso)

		UPDATE	TR_MG_CpDes 
		SET		T_Observacion = '000 - EXTERNO: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago ha sido ingresada o modificada desde una fuente externa.|',
				B_Migrado = 0 
		WHERE	I_RowID IN (SELECT CD.I_RowID FROM TR_MG_CpDes CD LEFT JOIN @Tbl_outputProceso O ON CD.I_RowID = o.I_RowID 
							WHERE CD.B_Migrable = 1 AND O.I_RowID IS NULL)

		SET @I_Proc_Inserted = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'INSERT')
		SET @I_Proc_Updated = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'UPDATE')
		SET @I_Ctas_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'INSERT')
		SET @I_Ctas_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'UPDATE')
		SET @I_CtaCat_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'INSERT')
		SET @I_CtaCat_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'UPDATE')

		SELECT @I_Proc_Inserted AS proc_count_insert, @I_Proc_Updated AS proc_count_update, 
				@I_Ctas_Inserted AS ctas_count_insert, @I_Ctas_Updated AS ctas_count_update,
				@I_CtaCat_Inserted AS ctas_count_insert, @I_CtaCat_Updated AS ctas_count_update

		COMMIT TRANSACTION;

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
		ROLLBACK TRANSACTION;
	END CATCH
END
GO