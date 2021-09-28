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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaAlumno')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaAlumno]
GO

CREATE PROCEDURE USP_IU_CopiarTablaAlumno	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaAlumno @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_Alu int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion			  varchar(20), 
		C_RcCod			  varchar(3), 
		C_CodAlu		  varchar(20), 
		INS_C_NumDNI	  varchar(20), 
		INS_C_CodTipDoc   varchar(5),
		INS_T_ApePaterno  varchar(50), 
		INS_T_ApeMaterno  varchar(50), 
		INS_T_Nombre	  varchar(50), 
		INS_C_Sexo		  char(1), 
		INS_D_FecNac	  date, 
		INS_C_CodModIng	  varchar(2), 
		INS_C_AnioIngreso smallint, 
		DEL_C_NumDNI	  varchar(20), 
		DEL_C_CodTipDoc   varchar(5),
		DEL_T_ApePaterno  varchar(50), 
		DEL_T_ApeMaterno  varchar(50), 
		DEL_T_Nombre	  varchar(50), 
		DEL_C_Sexo		  char(1), 
		DEL_D_FecNac	  date, 
		DEL_C_CodModIng	  varchar(2), 
		DEL_C_AnioIngreso smallint, 
		B_Removido	bit
	)

	BEGIN TRY 
	
		MERGE TR_MG_Alumnos AS TRG
		USING (SELECT DISTINCT * FROM alumnos) AS SRC
		ON	TRG.C_CodAlu = SRC.C_CODALU 
			AND TRG.C_RcCod = SRC.C_RCCOD
			AND ISNULL(TRG.C_CodModIng, '') = ISNULL(SRC.C_CODMODIN, '')
		WHEN MATCHED THEN
			UPDATE SET	TRG.C_NumDNI = SRC.C_NUMDNI,
						TRG.C_CodTipDoc = SRC.C_CODTIPDO,
						TRG.T_ApePaterno = REPLACE(SRC.T_APEPATER, '-', ' '),
						TRG.T_ApeMaterno = REPLACE(SRC.T_APEMATER, '-', ' '),
						TRG.T_Nombre = REPLACE(SRC.T_NOMBRE, '-', ' '),
						TRG.C_Sexo = SRC.C_SEXO,
						TRG.D_FecNac = CONVERT(DATE, SRC.D_FECNAC, 103),
						TRG.C_AnioIngreso = SRC.C_ANIOINGR
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (C_RcCod, C_CodAlu, C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, D_FecNac, C_CodModIng, C_AnioIngreso, D_FecCarga, B_Actualizado)
			VALUES (SRC.C_RCCOD, SRC.C_CODALU, SRC.C_NUMDNI, SRC.C_CODTIPDO, REPLACE(SRC.T_APEPATER, '-', ' '), REPLACE(SRC.T_APEMATER, '-', ' '), REPLACE(SRC.T_NOMBRE, '-', ' '), 
					SRC.C_SEXO, CONVERT(DATE, SRC.D_FECNAC, 103), SRC.C_CODMODIN, SRC.C_ANIOINGR, @D_FecProceso, 1)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET TRG.B_Removido = 1, 
					   TRG.D_FecRemovido = @D_FecProceso
		OUTPUT	$ACTION, inserted.C_RcCod, inserted.C_CodAlu, inserted.C_NumDNI, inserted.C_CodTipDoc, inserted.T_ApePaterno,   
				inserted.T_ApeMaterno, inserted.T_Nombre, inserted.C_Sexo, inserted.D_FecNac, inserted.C_CodModIng, inserted.C_AnioIngreso, 
				deleted.C_NumDNI, deleted.C_CodTipDoc, deleted.T_ApePaterno, deleted.T_ApeMaterno, deleted.T_Nombre, 
				deleted.C_Sexo, deleted.D_FecNac, deleted.C_CodModIng, deleted.C_AnioIngreso, deleted.B_Removido INTO @Tbl_output;
		
		UPDATE	TR_MG_Alumnos 
				SET	B_Actualizado = 0, B_Migrable = 1, D_FecMigrado = NULL, B_Migrado = 0

		UPDATE	t_Alu
		SET		t_Alu.B_Actualizado = 1,
				t_Alu.D_FecActualiza = @D_FecProceso
		FROM TR_MG_Alumnos AS t_Alu
				INNER JOIN 	@Tbl_output as t_out ON t_out.C_RcCod = t_Alu.C_RcCod 
				AND t_out.C_CodAlu = t_Alu.C_CodAlu AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_C_NumDNI <> t_out.DEL_C_NumDNI OR
				t_out.INS_C_CodTipDoc <> t_out.DEL_C_CodTipDoc OR
				t_out.INS_T_ApePaterno <> t_out.DEL_T_ApePaterno OR
				t_out.INS_T_ApeMaterno <> t_out.DEL_T_ApeMaterno OR
				t_out.INS_T_Nombre <> t_out.DEL_T_Nombre OR
				t_out.INS_C_Sexo <> t_out.DEL_C_Sexo OR
				ISNULL(t_out.INS_D_FecNac, '19010101') <> ISNULL(t_out.DEL_D_FecNac, '19010101') OR
				ISNULL(t_out.INS_C_CodModIng, '') <> ISNULL(t_out.DEL_C_CodModIng, '') OR
				t_out.INS_C_AnioIngreso <> t_out.DEL_C_AnioIngreso

		SET @I_Alu = (SELECT COUNT(*) FROM alumnos)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Removidos = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_Alu AS tot_alumnos, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ValidarCaracteresEspeciales')
	DROP PROCEDURE [dbo].[USP_U_ValidarCaracteresEspeciales]
GO

CREATE PROCEDURE USP_U_ValidarCaracteresEspeciales	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_ValidarCaracteresEspeciales @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_Actualizados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 
	DECLARE @I_ObservID int = 1
	DECLARE @I_TablaID int = 1

	BEGIN TRY 
		UPDATE	TR_MG_Alumnos
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso
		WHERE	
				PATINDEX('%[^a-zA-Z0-9.'' ]%', REPLACE(T_Nombre, '-', ' ')) <> 0 
				OR PATINDEX('%[^a-zA-Z0-9.'' ]%', REPLACE(T_ApePaterno, '-', ' ')) <> 0 
				OR PATINDEX('%[^a-zA-Z0-9.'' ]%', REPLACE(T_ApeMaterno, '-', ' ')) <> 0

		INSERT INTO TI_ObservacionRegistroTabla (I_ObservID, I_TablaID, I_FilaTablaID, D_FecRegistro)
		SELECT	@I_ObservID, @I_TablaID, I_RowID, @D_FecProceso
		FROM	TR_MG_Alumnos
		WHERE	
				PATINDEX('%[^a-zA-Z0-9.'' ]%', REPLACE(T_Nombre, '-', ' ')) <> 0 
				OR PATINDEX('%[^a-zA-Z0-9.'' ]%', REPLACE(T_ApePaterno, '-', ' ')) <> 0 
				OR PATINDEX('%[^a-zA-Z0-9.'' ]%', REPLACE(T_ApeMaterno, '-', ' ')) <> 0

		SET @I_Actualizados = (SELECT COUNT(*) FROM TI_ObservacionRegistroTabla WHERE @I_ObservID = 1 AND @I_TablaID = 1)

		SELECT @I_Actualizados as cant_updated, @D_FecProceso as fec_proceso
				
		SET @B_Resultado = 1
		SET @T_Message = CAST(@I_Actualizados AS varchar)
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ValidarCodigosAlumnoRepetidos')
	DROP PROCEDURE [dbo].[USP_U_ValidarCodigosAlumnoRepetidos]
GO

CREATE PROCEDURE USP_U_ValidarCodigosAlumnoRepetidos	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_ValidarCodigosAlumnoRepetidos @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_Actualizados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	BEGIN TRY 
		UPDATE	TR_MG_Alumnos
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '021 - REPETIDOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La combinación código de carrera + código de alumno se encuentran repetidos.|'
		WHERE	EXISTS (SELECT C_CodAlu, C_RcCod, COUNT(*) FROM TR_MG_Alumnos A 
						WHERE A.C_CodAlu = TR_MG_Alumnos.C_CodAlu AND A.C_RcCod = TR_MG_Alumnos.C_RcCod
						GROUP BY C_CodAlu, C_RcCod HAVING COUNT(*) > 1)
				

		SET @I_Actualizados = (SELECT COUNT(*) FROM TR_MG_Alumnos WHERE T_Observacion LIKE '%021%')

		SELECT @I_Actualizados as cant_updated, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ValidarCodigosAlumnoRepetidos')
	DROP PROCEDURE [dbo].[USP_U_ValidarCodigosAlumnoRepetidos]
GO

CREATE PROCEDURE USP_U_ValidarCodigosAlumnoRepetidos	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_ValidarCodigosAlumnoRepetidos @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_Actualizados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	BEGIN TRY 
		UPDATE	TR_MG_Alumnos
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '021 - REPETIDOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + ').  La combinación código de carrera + código de alumno se encuentran repetidos.|'
		WHERE	EXISTS (SELECT C_CodAlu, C_RcCod, COUNT(*) FROM TR_MG_Alumnos A 
						WHERE A.C_CodAlu = TR_MG_Alumnos.C_CodAlu AND A.C_RcCod = TR_MG_Alumnos.C_RcCod
						GROUP BY C_CodAlu, C_RcCod HAVING COUNT(*) > 1)
				

		SET @I_Actualizados = (SELECT COUNT(*) FROM TR_MG_Alumnos WHERE T_Observacion LIKE '%021%')

		SELECT @I_Actualizados as cant_updated, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataAlumnosUnfvRepositorio')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataAlumnosUnfvRepositorio]
GO

CREATE PROCEDURE USP_IU_MigrarDataAlumnosUnfvRepositorio	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_MigrarDataAlumnosUnfvRepositorio @B_Resultado output, @T_Message output
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
		SET @I_Removidos = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

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
				@I_CtaCat_Inserted AS ctas_cat_count_insert, @I_CtaCat_Updated AS ctas_cat_count_update

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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaConceptoDePago')
	DROP PROCEDURE [dbo].[USP_IU_CopiarTablaConceptoDePago]
GO

CREATE PROCEDURE USP_IU_CopiarTablaConceptoDePago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_CopiarTablaConceptoDePago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @I_CpPri int = 0
	DECLARE @I_Removidos int = 0
	DECLARE @I_Actualizados int = 0
	DECLARE @I_Insertados int = 0
	DECLARE @D_FecProceso datetime = GETDATE() 

	DECLARE @Tbl_output AS TABLE 
	(
		accion		varchar(20), 
		ID_CP		float,
		ELIMINADO	bit,
		B_Removido	bit,
		INS_CUOTA_PAGO	float,			INS_OBLIG_MORA	nvarchar(255),	
		INS_ANO			nvarchar(255), 	INS_P			nvarchar(255),
		INS_COD_RC		nvarchar(255),	INS_COD_ING		nvarchar(255),
		INS_TIPO_OBLIG	bit,			INS_CLASIFICAD	nvarchar(255),
		INS_CLASIFIC_5	nvarchar(255),	INS_ID_CP_AGRP	float,
		INS_AGRUPA		bit,			INS_NRO_PAGOS	float,
		INS_ID_CP_AFEC	float,			INS_PORCENTAJE	bit,
		INS_MONTO		float,			INS_DESCRIPCIO	nvarchar(255),
		INS_CALCULAR	nvarchar(255),	INS_GRADO		float,
		INS_TIP_ALUMNO	float,			INS_GRUPO_RC	nvarchar(255),
		INS_FRACCIONAB	bit,			INS_CONCEPTO_G	bit,
		INS_DOCUMENTO	nvarchar(255),	INS_MONTO_MIN	nvarchar(255),
		INS_DESCRIP_L	nvarchar(255),	INS_COD_DEP_PL	nvarchar(255),
		
		DEL_CUOTA_PAGO	float, 			DEL_ANO			nvarchar(255),		
		DEL_P			nvarchar(255),	DEL_COD_RC		nvarchar(255),
		DEL_COD_ING		nvarchar(255), 	DEL_TIPO_OBLIG	bit,		
		DEL_CLASIFICAD	nvarchar(255),	DEL_CLASIFIC_5	nvarchar(255),		
		DEL_ID_CP_AGRP	float,			DEL_AGRUPA		bit,		
		DEL_NRO_PAGOS	float,			DEL_ID_CP_AFEC	float,
		DEL_PORCENTAJE	bit,			DEL_MONTO		float,
		DEL_DESCRIPCIO	nvarchar(255),	DEL_CALCULAR	nvarchar(255),
		DEL_GRADO		float,			DEL_TIP_ALUMNO	float,
		DEL_GRUPO_RC	nvarchar(255),	DEL_FRACCIONAB	bit,
		DEL_CONCEPTO_G	bit,			DEL_DOCUMENTO	nvarchar(255),
		DEL_MONTO_MIN	nvarchar(255),	DEL_DESCRIP_L	nvarchar(255),
		DEL_COD_DEP_PL	nvarchar(255),	DEL_OBLIG_MORA	nvarchar(255)
	)

	BEGIN TRY 
		
		MERGE TR_MG_CpPri AS TRG
		USING cp_pri AS SRC
		ON	TRG.ID_CP = SRC.ID_CP 
			AND TRG.ELIMINADO = SRC.ELIMINADO
		WHEN MATCHED THEN
			UPDATE SET	TRG.CUOTA_PAGO = SRC.CUOTA_PAGO, TRG.ANO = SRC.ANO, TRG.P = SRC.P,
						TRG.COD_RC = SRC.COD_RC, TRG.COD_ING = SRC.COD_ING, TRG.TIPO_OBLIG = SRC.TIPO_OBLIG,
						TRG.CLASIFICAD = SRC.CLASIFICAD, TRG.CLASIFIC_5 = SRC.CLASIFIC_5, 
						TRG.AGRUPA = SRC.AGRUPA, TRG.NRO_PAGOS = SRC.NRO_PAGOS, TRG.ID_CP_AFEC = SRC.ID_CP_AFEC,
						TRG.PORCENTAJE = SRC.PORCENTAJE, TRG.MONTO = SRC.MONTO, TRG.ID_CP_AGRP = SRC.ID_CP_AGRP,
						TRG.DESCRIPCIO = SRC.DESCRIPCIO, TRG.CALCULAR = SRC.CALCULAR, TRG.GRADO = SRC.GRADO,
						TRG.TIP_ALUMNO = SRC.TIP_ALUMNO, TRG.GRUPO_RC = SRC.GRUPO_RC, TRG.FRACCIONAB = SRC.FRACCIONAB,
						TRG.CONCEPTO_G = SRC.CONCEPTO_G, TRG.DOCUMENTO = SRC.DOCUMENTO, TRG.MONTO_MIN = SRC.MONTO_MIN,
						TRG.DESCRIP_L = SRC.DESCRIP_L, TRG.COD_DEP_PL = SRC.COD_DEP_PL, TRG.OBLIG_MORA = SRC.OBLIG_MORA
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ID_CP, CUOTA_PAGO, ANO, P, COD_RC, COD_ING, TIPO_OBLIG, CLASIFICAD, CLASIFIC_5, ID_CP_AGRP, AGRUPA, NRO_PAGOS, ID_CP_AFEC, PORCENTAJE, MONTO, 
					ELIMINADO, DESCRIPCIO, CALCULAR, GRADO, TIP_ALUMNO, GRUPO_RC, FRACCIONAB, CONCEPTO_G, DOCUMENTO, MONTO_MIN, DESCRIP_L, COD_DEP_PL, OBLIG_MORA,
					D_FecCarga)
			VALUES (ID_CP, CUOTA_PAGO, ANO, P, COD_RC, COD_ING, TIPO_OBLIG, CLASIFICAD, CLASIFIC_5, ID_CP_AGRP, AGRUPA, NRO_PAGOS, ID_CP_AFEC, PORCENTAJE, MONTO, 
					ELIMINADO, DESCRIPCIO, CALCULAR, GRADO, TIP_ALUMNO, GRUPO_RC, FRACCIONAB, CONCEPTO_G, DOCUMENTO, MONTO_MIN, DESCRIP_L, COD_DEP_PL, OBLIG_MORA,
					@D_FecProceso)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET TRG.B_Removido = 1, 
					   TRG.D_FecRemovido = @D_FecProceso
		OUTPUT	$ACTION, inserted.ID_CP, inserted.ELIMINADO, deleted.B_Removido, inserted.CUOTA_PAGO, inserted.OBLIG_MORA, inserted.ANO, inserted.P, 
				inserted.COD_RC, inserted.COD_ING, inserted.TIPO_OBLIG, inserted.CLASIFICAD, inserted.CLASIFIC_5, inserted.ID_CP_AGRP, inserted.AGRUPA, 
				inserted.NRO_PAGOS, inserted.ID_CP_AFEC, inserted.PORCENTAJE, inserted.MONTO, inserted.DESCRIPCIO, inserted.CALCULAR, inserted.GRADO, 
				inserted.TIP_ALUMNO, inserted.GRUPO_RC, inserted.FRACCIONAB, inserted.CONCEPTO_G, inserted.DOCUMENTO, inserted.MONTO_MIN, inserted.DESCRIP_L, 
				inserted.COD_DEP_PL, 
				deleted.CUOTA_PAGO, deleted.ANO, deleted.P, deleted.COD_RC, deleted.COD_ING, deleted.TIPO_OBLIG, deleted.CLASIFICAD, deleted.CLASIFIC_5, 
				deleted.ID_CP_AGRP, deleted.AGRUPA, deleted.NRO_PAGOS, deleted.ID_CP_AFEC, deleted.PORCENTAJE, deleted.MONTO, deleted.DESCRIPCIO, deleted.CALCULAR, 
				deleted.GRADO, deleted.TIP_ALUMNO, deleted.GRUPO_RC, deleted.FRACCIONAB, deleted.CONCEPTO_G, deleted.DOCUMENTO, deleted.MONTO_MIN, deleted.DESCRIP_L, 
				deleted.COD_DEP_PL, deleted.OBLIG_MORA INTO @Tbl_output;
		
		UPDATE	TR_MG_CpPri 
				SET	B_Actualizado = 0, B_Migrable = 1, D_FecMigrado = NULL, B_Migrado = 0, T_Observacion = NULL,
					I_TipAluID = NULL, I_TipGradoID = NULL, I_TipOblID = NULL, I_TipCalcID = NULL, 
					I_TipPerID = NULL, I_DepID = NULL, I_TipGrpRc = NULL, I_CodIngID = NULL

		UPDATE	t_CpPri
		SET		t_CpPri.B_Actualizado = 1,
				t_CpPri.D_FecActualiza = @D_FecProceso
		FROM TR_MG_CpPri AS t_CpPri
		INNER JOIN 	@Tbl_output as t_out ON t_out.ID_CP = t_CpPri.ID_CP AND t_out.ELIMINADO = t_CpPri.ELIMINADO 
					AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_CUOTA_PAGO <> t_out.DEL_CUOTA_PAGO OR
				t_out.INS_ANO		 <> t_out.DEL_ANO		 OR
				t_out.INS_P			 <> t_out.DEL_P			 OR
				t_out.INS_COD_RC	 <> t_out.DEL_COD_RC	 OR
				t_out.INS_COD_ING	 <> t_out.DEL_COD_ING	 OR
				t_out.INS_TIPO_OBLIG <> t_out.DEL_TIPO_OBLIG OR
				t_out.INS_CLASIFICAD <> t_out.DEL_CLASIFICAD OR
				t_out.INS_CLASIFIC_5 <> t_out.DEL_CLASIFIC_5 OR
				t_out.INS_ID_CP_AGRP <> t_out.DEL_ID_CP_AGRP OR
				t_out.INS_AGRUPA	 <> t_out.DEL_AGRUPA	 OR
				t_out.INS_NRO_PAGOS	 <> t_out.DEL_NRO_PAGOS	 OR
				t_out.INS_ID_CP_AFEC <> t_out.DEL_ID_CP_AFEC OR
				t_out.INS_PORCENTAJE <> t_out.DEL_PORCENTAJE OR
				t_out.INS_MONTO		 <> t_out.DEL_MONTO		 OR
				t_out.INS_DESCRIPCIO <> t_out.DEL_DESCRIPCIO OR
				t_out.INS_CALCULAR	 <> t_out.DEL_CALCULAR	 OR
				t_out.INS_GRADO		 <> t_out.DEL_GRADO		 OR
				t_out.INS_TIP_ALUMNO <> t_out.DEL_TIP_ALUMNO OR
				t_out.INS_GRUPO_RC	 <> t_out.DEL_GRUPO_RC	 OR
				t_out.INS_FRACCIONAB <> t_out.DEL_FRACCIONAB OR
				t_out.INS_CONCEPTO_G <> t_out.DEL_CONCEPTO_G OR
				t_out.INS_DOCUMENTO  <> t_out.DEL_DOCUMENTO  OR
				t_out.INS_MONTO_MIN  <> t_out.DEL_MONTO_MIN  OR
				t_out.INS_DESCRIP_L  <> t_out.DEL_DESCRIP_L  OR
				t_out.INS_COD_DEP_PL <> t_out.DEL_COD_DEP_PL OR
				t_out.INS_OBLIG_MORA <> t_out.DEL_OBLIG_MORA


		SET @I_CpPri = (SELECT COUNT(*) FROM cp_pri)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Removidos = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_CpPri AS tot_concetoPago, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_MarcarConceptosPagoRepetidos')
	DROP PROCEDURE [dbo].[USP_U_MarcarConceptosPagoRepetidos]
GO

CREATE PROCEDURE USP_U_MarcarConceptosPagoRepetidos	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_MarcarConceptosPagoRepetidos @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	
	BEGIN TRY 
		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '010 - REPETIDA: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). El concepto de pago se encuentra repetido y con estado ACTIVO.|'
		WHERE	ID_CP IN (SELECT ID_CP FROM TR_MG_CpPri WHERE ELIMINADO = 0 
								GROUP BY ID_CP HAVING COUNT(ID_CP) > 1)

		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '010 - REPETIDA: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). El concepto de pago se encuentra repetido y con estado ACTIVO.|'
		WHERE	ID_CP IN (SELECT ID_CP FROM TR_MG_CpPri WHERE ELIMINADO = 1 
								GROUP BY ID_CP HAVING COUNT(ID_CP) > 1)

		SELECT * FROM TR_MG_CpPri WHERE B_Migrable = 0 AND T_Observacion LIKE '%010%'

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_MarcarConceptosPagoObligSinAnioAsignado')
	DROP PROCEDURE [dbo].[USP_U_MarcarConceptosPagoObligSinAnioAsignado]
GO

CREATE PROCEDURE USP_U_MarcarConceptosPagoObligSinAnioAsignado	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_MarcarConceptosPagoObligSinAnioAsignado @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	
	BEGIN TRY 
		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '011 - 0 AÑOS: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). Concepto de pago de obligacion sin año asignado.|'
		WHERE	(ANO IS NULL OR ANO = 0) AND TIPO_OBLIG = 1

		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '012 - NO COINCIDE AÑO : ('+ CONVERT(varchar, @D_FecProceso, 112) + '). Año del concepto de pago de obligacion no coincide con el año de la cuota de pagos.|'
		WHERE	NOT EXISTS (SELECT * FROM TR_MG_CpDes WHERE I_Anio = TR_MG_CpPri.ANO) AND TIPO_OBLIG = 1


		SELECT * FROM TR_MG_CpPri WHERE B_Migrable = 0 AND T_Observacion LIKE '%011%' OR T_Observacion LIKE '%012%'

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_MarcarConceptosPagoObligSinPeriodoAsignado')
	DROP PROCEDURE [dbo].[USP_U_MarcarConceptosPagoObligSinPeriodoAsignado]
GO

CREATE PROCEDURE USP_U_MarcarConceptosPagoObligSinPeriodoAsignado	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_MarcarConceptosPagoObligSinPeriodoAsignado @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	
	BEGIN TRY 
		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '013 - 0 Periodo: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). Concepto de pago de obligacion sin año asignado.|'
		WHERE	(ANO IS NULL OR ANO = 0) AND TIPO_OBLIG = 1

		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '012 - NO COINCIDE AÑO : ('+ CONVERT(varchar, @D_FecProceso, 112) + '). Año del concepto de pago de obligacion no coincide con el año de la cuota de pagos.|'
		WHERE	NOT EXISTS (SELECT * FROM TR_MG_CpDes WHERE I_Anio = TR_MG_CpPri.ANO) AND TIPO_OBLIG = 1

		SELECT * FROM TR_MG_CpPri WHERE B_Migrable = 0 AND T_Observacion LIKE '%011%' OR T_Observacion LIKE '%012%'

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_MarcarConceptosPagoObligSinCuotaPago')
	DROP PROCEDURE [dbo].[USP_U_MarcarConceptosPagoObligSinCuotaPago]
GO

CREATE PROCEDURE USP_U_MarcarConceptosPagoObligSinCuotaPago	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_MarcarConceptosPagoObligSinCuotaPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	
	BEGIN TRY 
		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '013 - SIN CUOTA PAGO: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). Concepto de pago de obligacion sin cuota de pago.|'
		WHERE	NOT EXISTS (SELECT * FROM TR_MG_CpDes WHERE CUOTA_PAGO = TR_MG_CpPri.CUOTA_PAGO) AND TIPO_OBLIG = 1

		UPDATE	TR_MG_CpPri
		SET		B_Migrable = 0,
				D_FecEvalua = @D_FecProceso,
				T_Observacion = ISNULL(T_Observacion, '') + '014 - CUOTA PAGO SM: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago asociada no fue migrada.|'
		WHERE	EXISTS (SELECT * FROM TR_MG_CpDes WHERE CUOTA_PAGO = TR_MG_CpPri.CUOTA_PAGO AND B_Migrable = 0)

		SELECT * FROM TR_MG_CpPri WHERE B_Migrable = 0 AND (T_Observacion LIKE '%013%' OR  T_Observacion LIKE '%014%') AND TIPO_OBLIG = 1

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_AsignarIdEquivalenciasConceptoPago')
	DROP PROCEDURE [dbo].[USP_U_AsignarIdEquivalenciasConceptoPago]
GO

CREATE PROCEDURE [dbo].[USP_U_AsignarIdEquivalenciasConceptoPago]
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_U_AsignarIdEquivalenciasConceptoPago @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	
	BEGIN TRY 
		DECLARE @tipo_alumno AS TABLE (I_TipAluID int, C_CodTipAlu varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_grado	 AS TABLE (I_TipGradoID int, C_CodTipGrado varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_obligacion AS TABLE (I_TipOblID int, C_CodTipObl varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_calculado AS TABLE (I_TipCalcID int, C_CodCalc varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_periodo	AS TABLE (I_TipPerID int, C_CodTipPer varchar(5), T_Descripcion varchar(50))
		DECLARE @grupo_rc	AS TABLE (I_TipGrpRc int, C_CodGrpRc varchar(5), T_Descripcion varchar(50))
		DECLARE @codigo_ing AS TABLE (I_CodIngID int, C_CodIng varchar(5), T_Descripcion varchar(50))
		DECLARE @unfv_dep	AS TABLE (I_DepID int, C_CodDep varchar(50), C_DepCodPl varchar(50))

		INSERT INTO @tipo_alumno (I_TipAluID, C_CodTipAlu, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 1

		INSERT INTO @tipo_grado (I_TipGradoID, C_CodTipGrado, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 2

		INSERT INTO @tipo_obligacion (I_TipOblID, C_CodTipObl, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 3

		INSERT INTO @tipo_calculado (I_TipCalcID, C_CodCalc, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4

		INSERT INTO @tipo_periodo (I_TipPerID, C_CodTipPer, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 5

		INSERT INTO @grupo_rc (I_TipGrpRc, C_CodGrpRc, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 6

		INSERT INTO @codigo_ing (I_CodIngID, C_CodIng, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 7

		INSERT INTO @unfv_dep (I_DepID, C_CodDep, C_DepCodPl)
			SELECT I_DependenciaID, C_DepCod, C_DepCodPl FROM BD_OCEF_CtasPorCobrar.dbo.TC_DependenciaUNFV

		UPDATE	tb_pri  
		SET		tb_pri.I_TipAluID	= t_alu.I_TipAluID,
				tb_pri.I_TipGradoID = t_grd.I_TipGradoID,
				tb_pri.I_TipOblID	= t_obl.I_TipOblID,
				tb_pri.I_TipCalcID	= t_clc.I_TipCalcID,
				tb_pri.I_TipPerID	= t_per.I_TipPerID,
				tb_pri.I_DepID		= dep.I_DepID,
				tb_pri.I_TipGrpRc	= t_grc.I_TipGrpRc,
				tb_pri.I_CodIngID	= c_ing.I_CodIngID
		FROM	TR_MG_CpPri tb_pri
				LEFT JOIN @tipo_alumno t_alu ON tb_pri.TIP_ALUMNO = CAST(t_alu.C_CodTipAlu AS float)
				LEFT JOIN @tipo_grado t_grd ON tb_pri.GRADO = CAST(t_grd.C_CodTipGrado AS float)
				LEFT JOIN @tipo_obligacion t_obl ON tb_pri.TIPO_OBLIG = CAST(t_obl.C_CodTipObl AS bit)
				LEFT JOIN @tipo_calculado t_clc ON tb_pri.CALCULAR = t_clc.C_CodCalc
				LEFT JOIN @tipo_periodo t_per ON tb_pri.P = t_per.C_CodTipPer
				LEFT JOIN @grupo_rc t_grc ON tb_pri.GRUPO_RC = t_grc.C_CodGrpRc
				LEFT JOIN @codigo_ing c_ing ON tb_pri.COD_ING = c_ing.C_CodIng
				LEFT JOIN @unfv_dep dep ON tb_pri.COD_DEP_PL = dep.C_DepCodPl AND LEN(dep.C_DepCodPl) > 0
		
		SELECT * FROM TR_MG_CpPri

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarTablaCatalogoConceptos')
	DROP PROCEDURE [dbo].[USP_IU_GrabarTablaCatalogoConceptos]
GO

CREATE PROCEDURE USP_IU_GrabarTablaCatalogoConceptos	
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_GrabarTablaCatalogoConceptos @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	IF NOT EXISTS (SELECT * FROM BD_OCEF_CtasPorCobrar.dbo.TC_Concepto WHERE I_ConceptoID = 0)
	BEGIN
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Concepto ON;
		INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TC_Concepto (I_ConceptoID, T_ConceptoDesc, B_EsObligacion, B_Habilitado, B_Eliminado)
													VALUES (0, 'CONCEPTO MIGRADO', 1, 1, 0);
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Concepto OFF;
	END

	SET @B_Resultado = 1
	SET @T_Message = 'Ok'
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataConceptoPagoCtasPorCobrar')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataConceptoPagoCtasPorCobrar]
GO

CREATE PROCEDURE USP_IU_MigrarDataConceptoPagoObligacionesCtasPorCobrar	
	@I_AnioIni	  int = NULL,
	@I_AnioFin	  int = NULL,
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
--exec USP_IU_MigrarDataConceptoPagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	DECLARE @I_ConceptoPago_Inserted int = 0
	DECLARE @I_ConceptoPago_Updated int = 0
	DECLARE @Tbl_outputConceptosPago AS TABLE (T_Action varchar(20), I_RowID int)

	BEGIN TRANSACTION;
	BEGIN TRY 
		SET @I_AnioIni = (SELECT ISNULL(@I_AnioIni, 0))
		SET @I_AnioFin = (SELECT ISNULL(@I_AnioFin, 3000))
	
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago ON;

		MERGE INTO  BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago AS TRG
		USING (SELECT * FROM TR_MG_CpPri WHERE B_Migrable = 1 AND TIPO_OBLIG = 1 AND ANO BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
		ON TRG.I_ConcPagID = SRC.ID_CP
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (I_ConcPagID, I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_AlumnosDestino, 
					I_GradoDestino, I_TipoObligacion, T_Clasificador, C_CodTasa, B_Calculado, I_Calculado, B_AnioPeriodo, I_Anio, I_Periodo, B_Especialidad, 
					C_CodRc, B_Dependencia, C_DepCod, B_GrupoCodRc, I_GrupoCodRc, B_ModalidadIngreso, I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, 
					B_ConceptoAfecta, I_ConceptoAfectaID, N_NroPagos, B_Porcentaje, C_Moneda, M_Monto, M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Mora, 
					B_Migrado, B_Habilitado, B_Eliminado, I_TipoDescuentoID, B_EsPagoMatricula, B_EsPagoExtmp)
			VALUES (SRC.ID_CP, SRC.CUOTA_PAGO, 0, SRC.DESCRIPCIO, SRC.FRACCIONAB, SRC.CONCEPTO_G, SRC.AGRUPA, SRC.I_TipAluID, SRC.I_TipGradoID, SRC.I_TipOblID, 
					SRC.CLASIFICAD, SRC.CLASIFIC_5, CASE WHEN SRC.I_TipCalcID IS NULL THEN 0 ELSE 1 END, SRC.I_TipCalcID, CASE CAST(SRC.ANO AS int) WHEN 0 THEN 0 ELSE 1 END, SRC.ANO, SRC.I_TipPerID, 
					CASE LEN(LTRIM(RTRIM(SRC.COD_RC))) WHEN 0 THEN 0 ELSE 1 END, CASE LEN(LTRIM(RTRIM(SRC.COD_RC))) WHEN 0 THEN NULL ELSE SRC.COD_RC END, 
					CASE LEN(LTRIM(RTRIM(SRC.COD_DEP_PL))) WHEN 0 THEN 0 ELSE 1 END, SRC.I_DepID, CASE WHEN SRC.I_TipGrpRc IS NULL THEN 0 ELSE 1 END, SRC.I_TipGrpRc, 
					CASE WHEN SRC.I_CodIngID IS NULL THEN 0 ELSE 1 END, SRC.I_CodIngID, CASE SRC.ID_CP_AGRP WHEN 0 THEN 0 ELSE 1 END, 
					CASE SRC.ID_CP_AGRP WHEN 0 THEN NULL ELSE SRC.ID_CP_AGRP END, CASE SRC.ID_CP_AFEC WHEN 0 THEN 0 ELSE 1 END,
					CASE SRC.ID_CP_AFEC WHEN 0 THEN NULL ELSE SRC.ID_CP_AFEC END, SRC.NRO_PAGOS, SRC.PORCENTAJE, 'PEN', SRC.MONTO, 
					CAST(REPLACE(SRC.MONTO_MIN, ',', '.') as float), SRC.DESCRIP_L, SRC.DOCUMENTO, 
					CASE SRC.OBLIG_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END,
					1, 1, SRC.ELIMINADO, NULL, NULL, NULL)
		WHEN MATCHED AND TRG.B_Migrado = 1 AND TRG.I_UsuarioMod IS NULL THEN 
			 UPDATE SET T_ConceptoPagoDesc = SRC.DESCRIPCIO, 
					 B_Fraccionable = SRC.FRACCIONAB, 
					 B_ConceptoGeneral = SRC.CONCEPTO_G,
					 B_AgrupaConcepto = SRC.AGRUPA, 
					 I_AlumnosDestino = SRC.I_TipAluID, 
					 I_GradoDestino = SRC.I_TipOblID, 
					 T_Clasificador = SRC.CLASIFICAD, 
					 C_CodTasa = SRC.CLASIFIC_5, 
					 B_Calculado = SRC.CALCULAR, 
					 I_Calculado = SRC.I_TipCalcID, 
					 B_AnioPeriodo = (CASE CAST(SRC.ANO AS int) WHEN 0 THEN 0 ELSE 1 END), 
					 I_Anio = SRC.ANO, 
					 I_Periodo = SRC.I_TipPerID, 
					 B_Especialidad = (CASE LEN(LTRIM(RTRIM(SRC.COD_RC))) WHEN 0 THEN 0 ELSE 1 END), 
					 C_CodRc = (CASE LEN(LTRIM(RTRIM(SRC.COD_RC))) WHEN 0 THEN NULL ELSE SRC.COD_RC END), 
					 B_Dependencia = (CASE LEN(LTRIM(RTRIM(SRC.I_DepID))) WHEN 0 THEN 0 ELSE 1 END), 
					 C_DepCod = I_DepID, 
					 B_GrupoCodRc = (CASE WHEN SRC.I_TipGrpRc IS NULL THEN 0 ELSE 1 END), 
					 I_GrupoCodRc = SRC.I_TipGrpRc, 
					 B_ModalidadIngreso = (CASE WHEN SRC.I_CodIngID IS NULL THEN 0 ELSE 1 END), 
					 I_ModalidadIngresoID = SRC.I_CodIngID, 
					 B_ConceptoAgrupa = (CASE SRC.ID_CP_AGRP WHEN 0 THEN 0 ELSE 1 END), 
					 I_ConceptoAgrupaID = SRC.ID_CP_AGRP,
					 B_ConceptoAfecta = (CASE SRC.ID_CP_AFEC WHEN 0 THEN 0 ELSE 1 END), 
					 I_ConceptoAfectaID = (CASE SRC.ID_CP_AFEC WHEN 0 THEN NULL ELSE SRC.ID_CP_AFEC END), 
					 B_Porcentaje = SRC.PORCENTAJE, 
					 M_Monto = SRC.MONTO,
					 M_MontoMinimo = CAST(REPLACE(SRC.MONTO_MIN, ',', '.') as float), 
					 T_DescripcionLarga = SRC.DESCRIP_L, 
					 T_Documento = SRC.DOCUMENTO,
					 B_Mora = (CASE SRC.OBLIG_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END), 
					 I_TipoDescuentoID = NULL, 
					 --B_EsPagoMatricula = NULL, 
					 --B_EsPagoExtmp = NULL, 
					 D_FecMod = @D_FecProceso
		WHEN NOT MATCHED BY SOURCE AND TRG.B_Migrado = 1 AND TRG.I_UsuarioMod IS NULL AND (TRG.B_EsPagoMatricula IS NULL OR TRG.B_EsPagoExtmp IS NULL)  THEN
			DELETE  		 
		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputConceptosPago;


		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago OFF;

		UPDATE	TR_MG_CpPri 
		SET		B_Migrado = 1, 
				D_FecMigrado = @D_FecProceso
		WHERE	I_RowID IN (SELECT I_RowID FROM @Tbl_outputConceptosPago)

		UPDATE	TR_MG_CpDes 
		SET		T_Observacion = '000 - EXTERNO: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). El concepto de pago ha sido ingresado o modificado desde una fuente externa.|',
				B_Migrado = 0 
		WHERE	I_RowID IN (SELECT CD.I_RowID FROM TR_MG_CpDes CD LEFT JOIN @Tbl_outputConceptosPago O ON CD.I_RowID = o.I_RowID 
							WHERE CD.B_Migrable = 1 AND O.I_RowID IS NULL)

		SET @I_ConceptoPago_Inserted = (SELECT COUNT(*) FROM @Tbl_outputConceptosPago WHERE T_Action = 'INSERT')
		SET @I_ConceptoPago_Updated = (SELECT COUNT(*) FROM @Tbl_outputConceptosPago WHERE T_Action = 'UPDATE')

		SELECT @I_ConceptoPago_Inserted AS concepto_count_insert, @I_ConceptoPago_Updated AS concepto_count_update 

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

	BEGIN TRANSACTION
	BEGIN TRY 

		UPDATE	TR_MG_EcObl
		SET		B_Actualizado = 0, 
				B_Migrable	  = 1, 
				D_FecMigrado  = NULL, 
				B_Migrado	  = 0, 
				T_Observacion = NULL		

		UPDATE	TR_MG_EcObl
		SET		TR_MG_EcObl.B_Removido		= 1, 
				TR_MG_EcObl.D_FecRemovido	= @D_FecProceso,
				TR_MG_EcObl.B_Migrable		= 0, 
				TR_MG_EcObl.T_Observacion	= NULL
		WHERE	NOT EXISTS (SELECT * FROM ec_obl SRC  
							WHERE TR_MG_EcObl.ANO = SRC.ANO AND TR_MG_EcObl.P = SRC.P AND TR_MG_EcObl.COD_ALU = SRC.COD_ALU 
							AND TR_MG_EcObl.COD_RC = SRC.COD_RC AND TR_MG_EcObl.CUOTA_PAGO = SRC.CUOTA_PAGO 
							AND ISNULL(TR_MG_EcObl.FCH_VENC, '19000101') = ISNULL(SRC.FCH_VENC, '19000101')
							AND ISNULL(TR_MG_EcObl.TIPO_OBLIG, 0) = ISNULL(SRC.TIPO_OBLIG, 0)
							AND TR_MG_EcObl.MONTO = SRC.MONTO AND TR_MG_EcObl.PAGADO = SRC.PAGADO)

		SET @I_Removidos = @@ROWCOUNT


		INSERT TR_MG_EcObl(ANO, P, COD_ALU, COD_RC, CUOTA_PAGO, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO, D_FecCarga, B_Migrable, B_Migrado, T_Observacion)
		SELECT	ANO, P, COD_ALU, COD_RC, CUOTA_PAGO, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO, @D_FecProceso, 1, 0, NULL
		FROM	ec_obl SRC
		WHERE	NOT EXISTS (SELECT * FROM TR_MG_EcObl TRG 
							WHERE TRG.ANO = SRC.ANO AND TRG.P = SRC.P AND TRG.COD_ALU = SRC.COD_ALU AND TRG.COD_RC = SRC.COD_RC 
							AND TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND ISNULL(TRG.FCH_VENC, '19000101') = ISNULL(SRC.FCH_VENC, '19000101')
							AND ISNULL(TRG.TIPO_OBLIG, 0) = ISNULL(SRC.TIPO_OBLIG, 0) AND TRG.MONTO = SRC.MONTO AND TRG.PAGADO = SRC.PAGADO)
		
		SET @I_Insertados = @@ROWCOUNT


		SET @I_EcObl = (SELECT COUNT(*) FROM ec_obl)

		SELECT @I_EcObl AS tot_obligaciones, @I_Insertados AS cant_inserted, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		COMMIT TRANSACTION
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
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
		accion			varchar(20),
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
		OUTPUT	$ACTION, inserted.I_RowID, inserted.COD_ALU, inserted.COD_RC, inserted.CUOTA_PAGO, inserted.ANO, inserted.P, inserted.TIPO_OBLIG, inserted.CONCEPTO, inserted.FCH_VENC, inserted.ELIMINADO, 
				inserted.NRO_RECIBO, inserted.FCH_PAGO, inserted.ID_LUG_PAG, inserted.CANTIDAD, inserted.MONTO, inserted.PAGADO, inserted.CONCEPTO_F, inserted.FCH_ELIMIN, inserted.NRO_EC, inserted.FCH_EC, 
				inserted.PAG_DEMAS, inserted.COD_CAJERO, inserted.TIPO_PAGO, inserted.NO_BANCO, inserted.COD_DEP, deleted.NRO_RECIBO, deleted.FCH_PAGO, deleted.ID_LUG_PAG, deleted.CANTIDAD, deleted.MONTO, 
				deleted.PAGADO, deleted.CONCEPTO_F, deleted.FCH_ELIMIN, deleted.NRO_EC, deleted.FCH_EC, deleted.PAG_DEMAS, deleted.COD_CAJERO, deleted.TIPO_PAGO, deleted.NO_BANCO, deleted.COD_DEP, 
				deleted.B_Removido INTO @Tbl_output;
				

		UPDATE	t_EcDet
		SET		t_EcDet.B_Actualizado = 1,
				t_EcDet.D_FecActualiza = @D_FecProceso
		FROM	TR_MG_EcDet AS t_EcDet
				INNER JOIN 	@Tbl_output as t_out ON t_out.ANO = t_EcDet.ANO 
				AND t_out.P = t_EcDet.P AND t_out.COD_ALU = t_EcDet.COD_ALU
				AND t_out.CONCEPTO = t_EcDet.CONCEPTO AND t_out.COD_ALU = t_EcDet.COD_ALU
				AND t_out.COD_RC = t_EcDet.COD_RC AND t_out.CUOTA_PAGO = t_EcDet.CUOTA_PAGO
				AND t_out.FCH_VENC = t_EcDet.FCH_VENC AND t_out.TIPO_OBLIG = t_EcDet.TIPO_OBLIG
				AND t_out.accion = 'UPDATE' AND t_out.B_Removido = 0
		WHERE 
				t_out.INS_NRO_RECIBO <> t_out.DEL_NRO_RECIBO OR
				t_out.INS_FCH_PAGO <> t_out.DEL_FCH_PAGO OR
				t_out.INS_ID_LUG_PAG <> t_out.DEL_ID_LUG_PAG OR
				t_out.INS_CANTIDAD <> t_out.DEL_CANTIDAD OR
				t_out.INS_MONTO	<> t_out.DEL_MONTO OR
				t_out.INS_PAGADO <> t_out.DEL_PAGADO OR
				t_out.INS_CONCEPTO_F <> t_out.DEL_CONCEPTO_F OR
				t_out.INS_FCH_ELIMIN <> t_out.DEL_FCH_ELIMIN OR
				t_out.INS_NRO_EC <> t_out.DEL_NRO_EC OR
				t_out.INS_FCH_EC <> t_out.DEL_FCH_EC OR
				t_out.INS_PAG_DEMAS <> t_out.DEL_PAG_DEMAS OR
				t_out.INS_COD_CAJERO <> t_out.DEL_COD_CAJERO OR
				t_out.INS_TIPO_PAGO <> t_out.DEL_TIPO_PAGO OR
				t_out.INS_NO_BANCO <> t_out.DEL_NO_BANCO 


		SET @I_EcDet = (SELECT COUNT(*) FROM ec_det)
		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_EcDet AS tot_obligaciones, @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
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

--CREATE PROCEDURE USP_IU_MigrarDataObligacionesPagoCtasPorCobrar	
--	@I_AnioIni	  int = NULL,
--	@I_AnioFin	  int = NULL,
--	@B_Resultado  bit output,
--	@T_Message	  nvarchar(4000) OUTPUT	
--AS
----declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
----exec USP_IU_MigrarDataObligacionesPagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
----select @B_Resultado as resultado, @T_Message as mensaje
--BEGIN
--	DECLARE @D_FecProceso datetime = GETDATE() 
--	DECLARE @Tbl_outputObl AS TABLE (T_Action varchar(20), I_RowID int)
--	DECLARE @Tbl_outputDet AS TABLE (T_Action varchar(20), I_RowID int)
--	DECLARE @Tbl_outputBnc AS TABLE (T_Action varchar(20), I_RowID int)
--	DECLARE @Tbl_outputProc AS TABLE (T_Action varchar(20), I_RowID int)
--	DECLARE @I_Obl_Inserted int = 0
--	DECLARE @I_Obl_Updated int = 0
--	DECLARE @I_Det_Inserted int = 0
--	DECLARE @I_Det_Updated int = 0
--	DECLARE @I_Bnc_Inserted int = 0
--	DECLARE @I_Bnc_Updated int = 0
--	DECLARE @I_Proc_Inserted int = 0
--	DECLARE @I_Proc_Updated int = 0

--	BEGIN TRANSACTION;
--	BEGIN TRY 
--		SET @I_AnioIni = (SELECT ISNULL(@I_AnioIni, 0))
--		SET @I_AnioFin = (SELECT ISNULL(@I_AnioFin, 3000))

--		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso ON;

--		MERGE INTO  BD_OCEF_CtasPorCobrar.dbo.TC_Proceso AS TRG
--		USING (SELECT * FROM TR_MG_CpDes WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
--		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO 
--		WHEN NOT MATCHED BY TARGET THEN 
--			 INSERT (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, D_FecCre, B_Habilitado, B_Eliminado)
--			 VALUES (CUOTA_PAGO, I_CatPagoID, DESCRIPCIO, I_Anio, I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, 
--					CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END, 1, @D_FecProceso, 1, ELIMINADO)
--		WHEN MATCHED AND TRG.B_Migrado = 1 AND TRG.I_UsuarioMod IS NULL THEN 
--			 UPDATE SET I_CatPagoID = SRC.I_CatPagoID, 
--					 T_ProcesoDesc = SRC.DESCRIPCIO, 
--					 I_Anio = SRC.I_Anio, 
--					 I_Periodo = SRC.I_Periodo,
--					 N_CodBanco = SRC.CODIGO_BNC, 
--					 D_FecVencto = SRC.FCH_VENC, 
--					 I_Prioridad = SRC.PRIORIDAD, 
--					 D_FecMod = @D_FecProceso,
--					 B_Mora = (CASE SRC.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END)
--		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputProceso;
		
--		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF
		
--		DECLARE @I_ProcesoID	int
--		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

--		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, @I_ProcesoID)
		

--		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso AS TRG
--		USING (SELECT CD.I_CtaDepositoID, TP_CD.* FROM TR_MG_CpDes TP_CD
--				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
--				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
--		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
--		WHEN NOT MATCHED BY TARGET THEN
--			INSERT (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado, D_FecCre)
--			VALUES (I_CtaDepositoID, CUOTA_PAGO, 1, ELIMINADO, @D_FecProceso)
--		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
--			UPDATE SET	B_Eliminado = ELIMINADO,
--						D_FecMod = @D_FecProceso
--		OUTPUT $action, SRC.I_RowID INTO @Tbl_outputCtas;


--		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito_CategoriaPago AS TRG
--		USING (SELECT DISTINCT CD.I_CtaDepositoID, TP_CD.I_CatPagoID FROM TR_MG_CpDes TP_CD
--				INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
--				WHERE B_Migrable = 1 AND I_Anio BETWEEN @I_AnioIni AND @I_AnioFin) AS SRC
--		ON TRG.I_CatPagoID = SRC.I_CatPagoID AND TRG.I_CtaDepositoID = SRC.I_CtaDepositoID
--		WHEN NOT MATCHED BY TARGET THEN
--			INSERT (I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado, D_FecCre)
--			VALUES (I_CtaDepositoID, I_CatPagoID, 1, 0, @D_FecProceso)
--		WHEN MATCHED AND TRG.I_UsuarioCre IS NULL AND TRG.I_UsuarioMod IS NULL THEN
--			UPDATE SET	D_FecMod = @D_FecProceso
--		OUTPUT $action, SRC.I_CatPagoID INTO @Tbl_outputCtasCat;
		
--		UPDATE	TR_MG_CpDes 
--		SET		B_Migrado = 1, 
--				D_FecMigrado = @D_FecProceso
--		WHERE	I_RowID IN (SELECT I_RowID FROM @Tbl_outputProceso)

--		UPDATE	TR_MG_CpDes 
--		SET		T_Observacion = '000 - EXTERNO: ('+ CONVERT(varchar, @D_FecProceso, 112) + '). La cuota de pago ha sido ingresada o modificada desde una fuente externa.|',
--				B_Migrado = 0 
--		WHERE	I_RowID IN (SELECT CD.I_RowID FROM TR_MG_CpDes CD LEFT JOIN @Tbl_outputProceso O ON CD.I_RowID = o.I_RowID 
--							WHERE CD.B_Migrable = 1 AND O.I_RowID IS NULL)

--		SET @I_Proc_Inserted = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'INSERT')
--		SET @I_Proc_Updated = (SELECT COUNT(*) FROM @Tbl_outputProceso WHERE T_Action = 'UPDATE')
--		SET @I_Ctas_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'INSERT')
--		SET @I_Ctas_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtas WHERE T_Action = 'UPDATE')
--		SET @I_CtaCat_Inserted = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'INSERT')
--		SET @I_CtaCat_Updated = (SELECT COUNT(*) FROM @Tbl_outputCtasCat WHERE T_Action = 'UPDATE')

--		SELECT @I_Proc_Inserted AS proc_count_insert, @I_Proc_Updated AS proc_count_update, 
--				@I_Ctas_Inserted AS ctas_count_insert, @I_Ctas_Updated AS ctas_count_update,
--				@I_CtaCat_Inserted AS ctas_count_insert, @I_CtaCat_Updated AS ctas_count_update

--		COMMIT TRANSACTION;

--		SET @B_Resultado = 1
--		SET @T_Message = 'Ok'
--	END TRY
--	BEGIN CATCH
--		SET @B_Resultado = 0
--		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
--		ROLLBACK TRANSACTION;
--	END CATCH
--END
--GO



CREATE VIEW VW_ObservacionesTabla
AS
(
	SELECT  I_ObsTablaID, ORT.D_FecRegistro, ORT.I_TablaID, T_TablaNom, ORT.I_ObservID, CO.T_ObservDesc,
			ORT.I_FilaTablaID, CO.T_ObservCod, CO.I_Severidad
	FROM	TI_ObservacionRegistroTabla ORT
			INNER JOIN TC_CatalogoTabla CT ON ORT.I_TablaID = CT.I_TablaID
			INNER JOIN TC_CatalogoObservacion CO ON ORT.I_ObservID = CO.I_ObservID
)
GO