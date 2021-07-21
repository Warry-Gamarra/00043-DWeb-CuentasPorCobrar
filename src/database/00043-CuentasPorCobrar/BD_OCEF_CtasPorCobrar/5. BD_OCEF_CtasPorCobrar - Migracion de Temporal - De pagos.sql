USE BD_OCEF_CtasPorCobrar
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_GrabarProcesosYCuentasMigracion')
	DROP PROCEDURE [dbo].[USP_U_AsignarCategoriaCuotaPago]
GO

CREATE PROCEDURE USP_IU_GrabarProcesosYCuentasMigracion
	@I_AnioIni	  int = NULL,
	@I_AnioFin	  int = NULL,
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
--declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int,
--		@T_Message	  nvarchar(4000)
--exec USP_IU_GrabarProcesosYCuentasMigracion @B_Resultado output, @T_Message output
--select @B_Resultado as resultado, @T_Message as mensaje
BEGIN
	DECLARE @D_FecProceso datetime = GETDATE() 
	DECLARE @Tbl_output AS TABLE (T_Action varchar(20), I_RowID int)
	DECLARE @I_Inserted int = 0
	DECLARE @I_Updated int = 0

	BEGIN TRANSACTION;
	BEGIN TRY 
		SET @I_AnioIni = (SELECT ISNULL(@I_AnioIni, 0))
		SET @I_AnioFin = (SELECT ISNULL(@I_AnioFin, 3000))

		ALTER TABLE TC_Proceso ADD I_RowID int;

		SET IDENTITY_INSERT TC_Proceso ON
		MERGE INTO TC_Proceso AS TRG
		USING BD_OCEF_MigracionTP.dbo.TR_MG_CpDes AS SRC
		ON TRG.I_ProcesoID = SRC.CUOTA_PAGO AND SRC.B_Migrable = 1 AND SRC.I_Anio BETWEEN @I_AnioIni AND @I_AnioFin
		WHEN NOT MATCHED BY TARGET THEN 
			 INSERT (I_RowID, I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, D_FecCre, B_Habilitado, B_Eliminado)
			 VALUES (I_RowID, CUOTA_PAGO, I_CatPagoID, DESCRIPCIO, I_Anio, I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, 
					CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END, 1, @D_FecProceso, 1, ELIMINADO)
		WHEN MATCHED AND TRG.I_UsuarioMod IS NULL THEN 
			 UPDATE SET I_CatPagoID = SRC.I_CatPagoID, 
					 T_ProcesoDesc = SRC.DESCRIPCIO, 
					 I_Anio = SRC.I_Anio, 
					 I_Periodo = SRC.I_Periodo,
					 N_CodBanco = SRC.CODIGO_BNC, 
					 D_FecVencto = SRC.FCH_VENC, 
					 I_Prioridad = SRC.PRIORIDAD, 
					 B_Mora = (CASE SRC.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 WHEN 'True' THEN 1 WHEN 'False' THEN 0 ELSE NULL END)
		OUTPUT $action, inserted.I_RowID INTO @Tbl_output;
		
		SET IDENTITY_INSERT TC_Proceso OFF
		
		ALTER TABLE TC_Proceso DROP COLUMN I_RowID;

		UPDATE	BD_OCEF_MigracionTP.dbo.TR_MG_CpDes 
		SET		B_Migrado = 1
		WHERE	I_RowID IN (SELECT I_RowID FROM @Tbl_output)

		SET @I_Inserted = (SELECT COUNT(*) FROM @Tbl_output WHERE T_Action = 'INSERT')
		SET @I_Updated = (SELECT COUNT(*) FROM @Tbl_output WHERE T_Action = 'UPDATE')

		SELECT @I_Inserted AS count_insert, @I_Updated AS count_update

		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
		ROLLBACK TRANSACTION;
	END CATCH
END
