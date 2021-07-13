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


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataCuotaDePago')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataCuotaDePago]
GO

CREATE PROCEDURE USP_IU_MigrarDataCuotaDePago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	DECLARE @T_NombreTabla varchar(50);
	SET @T_NombreTabla = 'cp_des'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontró la tabla "', @T_NombreTabla,'" requerida para el proceso de migración.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importación de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END
	ELSE
	BEGIN

		DECLARE @I_RowID int, @I_CuotaPago int
		DECLARE @Count_cuota int, @Count_categoria int, @B_Result bit
		DECLARE @B_Migrado bit, @T_Observacion varchar(500)

		DECLARE @cuota_anio AS TABLE (cuota_pago int, anio_cuota varchar(4))
		DECLARE @categoria_pago AS TABLE (I_CatPagoID int, N_CodBanco varchar(10))
		DECLARE @periodo AS TABLE (I_Periodo int, C_CodPeriodo varchar(5), T_Descripcion varchar(50))

		-- 1. COPIAR DATA CP_DES A TABLA DE MIGRACION 
		TRUNCATE TABLE TR_MG_CpDes;

		INSERT INTO TR_MG_CpDes (CUOTA_PAGO, DESCRIPCIO, N_CTA_CTE, ELIMINADO, CODIGO_BNC, FCH_VENC, PRIORIDAD, C_MORA) 
			 SELECT CUOTA_PAGO, DESCRIPCIO, N_CTA_CTE, ELIMINADO, CODIGO_BNC, FCH_VENC, PRIORIDAD, C_MORA FROM cp_des;

		-- 2. COPIAR AÑOS DE LAS CUOTAS DE PAGO DE LA TABLA CP_PRI 
		INSERT INTO @cuota_anio(cuota_pago, anio_cuota)
			SELECT DISTINCT D.CUOTA_PAGO, ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4)) AS ANO 
			  FROM cp_des D LEFT JOIN cp_pri P ON D.CUOTA_PAGO = P.CUOTA_PAGO 
			 WHERE ISNUMERIC(ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4))) = 1;

		-- 3. COPIAR CATEGORIAS DE PAGO Y CODIGOS DE BANCO ASOCIADOS EN BASE DE DATOS DE LA APLICACION
		INSERT INTO @categoria_pago (I_CatPagoID, N_CodBanco)
			SELECT I_CatPagoID, N_CodBanco FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @periodo (I_Periodo, C_CodPeriodo, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 5

		DECLARE CUR_CP_DES CURSOR
		FOR
			SELECT I_RowID FROM TR_MG_CpDes
		OPEN CUR_CP_DES

		FETCH NEXT FROM CUR_CP_DES INTO @I_RowID
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso ON
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @B_Result = 1;
			SET @T_Observacion = ''
			SET @I_CuotaPago = (SELECT CUOTA_PAGO FROM TR_MG_CpDes  WHERE I_RowID = @I_RowID);
			SET @Count_cuota = (SELECT COUNT(CUOTA_PAGO) FROM cp_des WHERE CUOTA_PAGO = @I_CuotaPago);
			SET @Count_categoria = (SELECT COUNT(CUOTA_PAGO) FROM cp_des cd INNER JOIN @categoria_pago cp ON cp.N_CodBanco = cd.CODIGO_BNC WHERE CUOTA_PAGO = @I_CuotaPago);

			PRINT 'Validando CUOTA DE PAGO: ' + CAST(@I_CuotaPago AS varchar(10))
			IF (@Count_cuota > 1)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion = ' El número de cuota de pago se encuentra repetida.';
			END

			IF (@Count_categoria > 1)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion += ' La cuota de pago está asociada a más de una categoría en la nueva base de datos.';
			END

			IF NOT EXISTS (SELECT * FROM @cuota_anio WHERE cuota_pago = @I_CuotaPago )
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion += ' La cuota de pago NO tiene un año asignado.';
			END

			IF (@B_Result = 0)
			BEGIN
				SET @B_Migrado = 0;
				PRINT @T_Observacion;
			END
			ELSE
			BEGIN
				BEGIN TRANSACTION
				BEGIN TRY
					PRINT 'Insertando registro en TC_Proceso...'
					INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TC_Proceso (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, B_Habilitado, B_Eliminado)
						SELECT @I_CuotaPago, cp.I_CatPagoID, cd.DESCRIPCIO, ca.anio_cuota, per.I_Periodo, cd.CODIGO_BNC, cd.FCH_VENC, cd.PRIORIDAD, CASE cd.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 ELSE NULL END, 1, 1, cd.ELIMINADO
						  FROM TR_MG_CpDes cd 
							   INNER JOIN @cuota_anio ca ON cd.CUOTA_PAGO = ca.cuota_pago
							   INNER JOIN @categoria_pago cp ON cp.N_CodBanco = cd.CODIGO_BNC
							   LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM cp_pri) pri ON pri.cuota_pago = cd.cuota_pago
							   INNER JOIN @periodo per ON per.C_CodPeriodo COLLATE DATABASE_DEFAULT = pri.p COLLATE DATABASE_DEFAULT
						WHERE cd.CUOTA_PAGO = @I_CuotaPago;

					PRINT 'Insertando registro en TI_CtaDepo_Proceso...'
					INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado)
							SELECT CD.I_CtaDepositoID, P.I_ProcesoID, 1 AS B_Habilitado, 0 AS B_Eliminado
							FROM BD_OCEF_CtasPorCobrar.dbo.TC_Proceso P
								INNER JOIN cp_des TP_CD ON TP_CD.CUOTA_PAGO = P.I_ProcesoID
								INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
							WHERE TP_CD.CUOTA_PAGO = @I_CuotaPago;

					SET @B_Migrado = 1;
					COMMIT TRANSACTION;
				END TRY
				BEGIN CATCH
					SET @B_Migrado = 0;
					SET @T_Observacion = ERROR_MESSAGE();
					PRINT @T_Observacion
					ROLLBACK TRANSACTION;
				END CATCH
			END
	
			UPDATE TR_MG_CpDes
			SET  B_Migrado = @B_Migrado,
					T_Observacion = @T_Observacion
			WHERE I_RowID = @I_RowID;

			FETCH NEXT FROM CUR_CP_DES INTO @I_RowID
		END
		CLOSE CUR_CP_DES;
		DEALLOCATE CUR_CP_DES;

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF

		DECLARE @I_ProcesoID	int
		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, 0)


		INSERT BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito_CategoriaPago(I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado)
		SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
		FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago CP 
			 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
						 FROM BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD  
				 			 INNER JOIN TR_MG_CpDes TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
						 WHERE ELIMINADO = 0
		) BNC ON CP.N_CodBanco = BNC.CODIGO_BNC
		UNION
		SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
		FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago CP 
			 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
						 FROM BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD  
 				 				INNER JOIN TR_MG_CpDes TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
						 WHERE CODIGO_BNC IS NULL AND ELIMINADO = 0
		) BNC ON CP.N_CodBanco IS NULL
	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataConceptosPago')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataConceptosPago]
GO

CREATE PROCEDURE USP_IU_MigrarDataConceptosPago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	DECLARE @T_NombreTabla varchar(50);
	SET @T_NombreTabla = 'cp_pri'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontró la tabla "', @T_NombreTabla,'" requerida para el proceso de migración.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importación de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END
	ELSE
	BEGIN

		DECLARE @I_RowID int, @I_ConceptoPagoID int
		DECLARE @Count_ConcPago int, @Count_cuota int, @B_Result bit
		DECLARE @B_Migrado bit, @T_Observacion varchar(500)

		DECLARE @cuota_anio AS TABLE (cuota_pago int, anio_cuota varchar(4))
		DECLARE @categoria_pago AS TABLE (I_CatPagoID int, N_CodBanco varchar(10))

		DECLARE @tipo_alumno AS TABLE (I_TipAluID int, C_CodTipAlu varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_grado	 AS TABLE (I_TipGradoID int, C_CodTipGrado varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_obligacion AS TABLE (I_TipOblID int, C_CodTipObl varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_periodo	 AS TABLE (I_TipPerID int, C_CodTipPer varchar(5), T_Descripcion varchar(50))
		DECLARE @grupo_rc	AS TABLE (I_TipGrpRc int, C_CodGrpRc varchar(5), T_Descripcion varchar(50))
		DECLARE @codigo_ing AS TABLE (I_CodIngID int, C_CodIng varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_calculado AS TABLE (I_TipCalcID int, C_CodCalc varchar(5), T_Descripcion varchar(50))
		DECLARE @unfv_dep	AS TABLE (I_DepID int, C_CodDep varchar(5), T_Descripcion varchar(50))

		-- 1. COPIAR DATA CP_PRI A TABLA DE MIGRACION 
		TRUNCATE TABLE TR_MG_CpDes;

		INSERT INTO TR_MG_CpPri (ID_CP, CUOTA_PAGO, ANO, P, COD_RC, COD_ING, TIPO_OBLIG, CLASIFICAD, CLASIFIC_5, ID_CP_AGRP, AGRUPA, NRO_PAGOS, ID_CP_AFEC, PORCENTAJE, MONTO, ELIMINADO, 
								 DESCRIPCIO, CALCULAR, GRADO, TIP_ALUMNO, GRUPO_RC, FRACCIONAB, CONCEPTO_G, DOCUMENTO, MONTO_MIN, DESCRIP_L, COD_DEP_PL, OBLIG_MORA) 
						  SELECT ID_CP, CUOTA_PAGO, ANO, P, COD_RC, COD_ING, TIPO_OBLIG, CLASIFICAD, CLASIFIC_5, ID_CP_AGRP, AGRUPA, NRO_PAGOS, ID_CP_AFEC, PORCENTAJE, MONTO, ELIMINADO, 
								 DESCRIPCIO, CALCULAR, GRADO, TIP_ALUMNO, GRUPO_RC, FRACCIONAB, CONCEPTO_G, DOCUMENTO, MONTO_MIN, DESCRIP_L, COD_DEP_PL, OBLIG_MORA FROM cp_pri;

		---- 2. COPIAR AÑOS DE LAS CUOTAS DE PAGO DE LA TABLA CP_PRI 
		--INSERT INTO @cuota_anio(cuota_pago, anio_cuota)
		--	SELECT DISTINCT D.CUOTA_PAGO, ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4)) AS ANO 
		--	  FROM cp_des D LEFT JOIN cp_pri P ON D.CUOTA_PAGO = P.CUOTA_PAGO 
		--	 WHERE ISNUMERIC(ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4))) = 1;

		---- 3. COPIAR CATEGORIAS DE PAGO Y CODIGOS DE BANCO ASOCIADOS EN BASE DE DATOS DE LA APLICACION
		--INSERT INTO @categoria_pago (I_CatPagoID, N_CodBanco)
		--	SELECT I_CatPagoID, N_CodBanco FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_alumno (I_TipAluID, C_CodTipAlu, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 1

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_grado (I_TipGradoID, C_CodTipGrado, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 2

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_obligacion (I_TipOblID, C_CodTipObl, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 3

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE TIPO DE CAMPO CALCULADO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_calculado (I_TipCalcID, C_CodCalc, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_periodo (I_TipPerID, C_CodTipPer, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 5

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @grupo_rc (I_TipGrpRc, C_CodGrpRc, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 6

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @codigo_ing (I_CodIngID, C_CodIng, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 7

		---- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		--INSERT INTO @unfv_dep (I_DepID, C_CodDep, T_Descripcion)
		--	SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 5


		DECLARE CUR_CP_PRI CURSOR
		FOR
			SELECT I_RowID FROM TR_MG_CpPri
		OPEN CUR_CP_PRI

		FETCH NEXT FROM CUR_CP_PRI INTO @I_RowID
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago ON
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @B_Result = 1;
			SET @T_Observacion = '';
			SET @I_ConceptoPagoID = (SELECT ID_CP FROM TR_MG_CpPri  WHERE I_RowID = @I_RowID);
			SET @Count_ConcPago = (SELECT COUNT(CUOTA_PAGO) FROM cp_pri WHERE ID_CP = @I_ConceptoPagoID);
			--SET @Count_cuota = (SELECT COUNT(CUOTA_PAGO) FROM cp_pri cd INNER JOIN @categoria_pago cp ON cp.N_CodBanco = cd.CODIGO_BNC WHERE CUOTA_PAGO = @I_CuotaPago);

			PRINT 'Validando ID del concepto de pago: ' + CAST(@I_ConceptoPagoID AS varchar(10))
			IF (@Count_ConcPago > 1)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion = ' El concepto pago se encuentra repetida.';
			END

			IF NOT EXISTS (SELECT * FROM @cuota_anio WHERE cuota_pago = @I_CuotaPago)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion += ' La cuota de pago NO tiene un año asignado.';
			END

			IF (@B_Result = 0)
			BEGIN
				SET @B_Migrado = 0;
				PRINT @T_Observacion;
			END
			ELSE
			BEGIN
				BEGIN TRANSACTION
				BEGIN TRY
					PRINT 'Insertando registro en TC_Proceso...'
					INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TC_Proceso (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, B_Habilitado, B_Eliminado)
						SELECT @I_CuotaPago, cp.I_CatPagoID, cd.DESCRIPCIO, ca.anio_cuota, per.I_Periodo, cd.CODIGO_BNC, cd.FCH_VENC, cd.PRIORIDAD, CASE cd.C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 ELSE NULL END, 1, 1, cd.ELIMINADO
						  FROM TR_MG_CpDes cd 
							   INNER JOIN @cuota_anio ca ON cd.CUOTA_PAGO = ca.cuota_pago
							   INNER JOIN @categoria_pago cp ON cp.N_CodBanco = cd.CODIGO_BNC
							   LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM cp_pri) pri ON pri.cuota_pago = cd.cuota_pago
							   INNER JOIN @periodo per ON per.C_CodPeriodo COLLATE DATABASE_DEFAULT = pri.p COLLATE DATABASE_DEFAULT
						WHERE cd.CUOTA_PAGO = @I_CuotaPago;

					PRINT 'Insertando registro en TI_CtaDepo_Proceso...'
					INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado)
							SELECT CD.I_CtaDepositoID, P.I_ProcesoID, 1 AS B_Habilitado, 0 AS B_Eliminado
							  FROM BD_OCEF_CtasPorCobrar.dbo.TC_Proceso P
								   INNER JOIN cp_des TP_CD ON TP_CD.CUOTA_PAGO = P.I_ProcesoID
								   INNER JOIN BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
							WHERE TP_CD.CUOTA_PAGO = @I_CuotaPago;

					SET @B_Migrado = 1;
					COMMIT TRANSACTION;
				END TRY
				BEGIN CATCH
					SET @B_Migrado = 0;
					SET @T_Observacion = ERROR_MESSAGE();
					PRINT @T_Observacion
					ROLLBACK TRANSACTION;
				END CATCH
			END
	
			UPDATE TR_MG_CpDes
			SET  B_Migrado = @B_Migrado,
					T_Observacion = @T_Observacion
			WHERE I_RowID = @I_RowID;

			FETCH NEXT FROM CUR_CP_DES INTO @I_RowID
		END
		CLOSE CUR_CP_DES;
		DEALLOCATE CUR_CP_DES;

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF

		DECLARE @I_ProcesoID	int
		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, 0)


		INSERT BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito_CategoriaPago(I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado)
		SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
		FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago CP 
			 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
						 FROM BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD  
				 			 INNER JOIN TR_MG_CpDes TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
						 WHERE ELIMINADO = 0
		) BNC ON CP.N_CodBanco = BNC.CODIGO_BNC
		UNION
		SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
		FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago CP 
			 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
						 FROM BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito CD  
 				 				INNER JOIN TR_MG_CpDes TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
						 WHERE CODIGO_BNC IS NULL AND ELIMINADO = 0
		) BNC ON CP.N_CodBanco IS NULL
	END
END
GO
