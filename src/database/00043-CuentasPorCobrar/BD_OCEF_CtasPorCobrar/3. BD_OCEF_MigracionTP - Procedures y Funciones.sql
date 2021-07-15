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

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, @I_ProcesoID)


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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataConceptosPagoObligacion')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataConceptosPagoObligacion]
GO

CREATE PROCEDURE USP_IU_MigrarDataConceptosPagoObligacion
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

		DECLARE @cuota_anio AS TABLE (I_ProcesoID int, anio_cuota int)
		DECLARE @tipo_alumno AS TABLE (I_TipAluID int, C_CodTipAlu varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_grado	 AS TABLE (I_TipGradoID int, C_CodTipGrado varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_obligacion AS TABLE (I_TipOblID int, C_CodTipObl varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_periodo	 AS TABLE (I_TipPerID int, C_CodTipPer varchar(5), T_Descripcion varchar(50))
		DECLARE @grupo_rc	AS TABLE (I_TipGrpRc int, C_CodGrpRc varchar(5), T_Descripcion varchar(50))
		DECLARE @codigo_ing AS TABLE (I_CodIngID int, C_CodIng varchar(5), T_Descripcion varchar(50))
		DECLARE @tipo_calculado AS TABLE (I_TipCalcID int, C_CodCalc varchar(5), T_Descripcion varchar(50))
		DECLARE @unfv_dep	AS TABLE (I_DepID int, C_CodDep varchar(50), C_DepCodPl varchar(50))

		IF NOT EXISTS (SELECT * FROM BD_OCEF_CtasPorCobrar.dbo.TC_Concepto WHERE I_ConceptoID = 0)
		BEGIN
			SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Concepto ON;
			INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TC_Concepto (I_ConceptoID, T_ConceptoDesc, B_EsObligacion, B_Habilitado, B_Eliminado)
													   VALUES (0, 'CONCEPTO MIGRADO', 1, 1, 0);
			SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Concepto OFF;
		END

		-- 1. COPIAR DATA CP_PRI A TABLA DE MIGRACION 
		TRUNCATE TABLE TR_MG_CpPri;

		INSERT INTO TR_MG_CpPri (ID_CP, CUOTA_PAGO, ANO, P, COD_RC, COD_ING, TIPO_OBLIG, CLASIFICAD, CLASIFIC_5, ID_CP_AGRP, AGRUPA, NRO_PAGOS, ID_CP_AFEC, PORCENTAJE, MONTO, ELIMINADO, 
								 DESCRIPCIO, CALCULAR, GRADO, TIP_ALUMNO, GRUPO_RC, FRACCIONAB, CONCEPTO_G, DOCUMENTO, MONTO_MIN, DESCRIP_L, COD_DEP_PL, OBLIG_MORA) 
						  SELECT ID_CP, CUOTA_PAGO, ANO, P, COD_RC, COD_ING, TIPO_OBLIG, CLASIFICAD, CLASIFIC_5, ID_CP_AGRP, AGRUPA, NRO_PAGOS, ID_CP_AFEC, PORCENTAJE, MONTO, ELIMINADO, 
								 DESCRIPCIO, CALCULAR, GRADO, TIP_ALUMNO, GRUPO_RC, FRACCIONAB, CONCEPTO_G, DOCUMENTO, MONTO_MIN, DESCRIP_L, COD_DEP_PL, OBLIG_MORA FROM cp_pri;

		-- 2. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE TIPO DE ALUMNO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_alumno (I_TipAluID, C_CodTipAlu, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 1

		-- 3. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE TIPO DE GRADO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_grado (I_TipGradoID, C_CodTipGrado, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 2

		-- 4. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE TIPO DE OBLIGACION EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_obligacion (I_TipOblID, C_CodTipObl, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 3

		-- 5. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE TIPO DE CAMPO CALCULADO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_calculado (I_TipCalcID, C_CodCalc, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4

		-- 6. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE PERIODO ACADEMICO EN EL TEMPORAL DE PAGOS 
		INSERT INTO @tipo_periodo (I_TipPerID, C_CodTipPer, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 5

		-- 7. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE GRUPO RC EN EL TEMPORAL DE PAGOS 
		INSERT INTO @grupo_rc (I_TipGrpRc, C_CodGrpRc, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 6

		-- 8. COPIAR ID EQUIVALENTES PARA LOS CODIGOS DE INGRESOES EN EL TEMPORAL DE PAGOS 
		INSERT INTO @codigo_ing (I_CodIngID, C_CodIng, T_Descripcion)
			SELECT I_OpcionID, T_OpcionCod, T_OpcionDesc FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 7

		-- 9. COPIAR IDs DE PROCESO DE BASE DE DATOS DE CTAS POR COBRAR
		INSERT INTO @cuota_anio (anio_cuota, I_ProcesoID)
			SELECT I_Anio, I_ProcesoID FROM BD_OCEF_CtasPorCobrar.dbo.TC_Proceso

		-- 9. COPIAR IDs DE PROCESO DE BASE DE DATOS DE CTAS POR COBRAR
		INSERT INTO @unfv_dep (I_DepID, C_CodDep, C_DepCodPl)
			SELECT I_DependenciaID, C_DepCod, C_DepCodPl FROM BD_OCEF_CtasPorCobrar.dbo.TC_DependenciaUNFV

		DECLARE CUR_CP_PRI CURSOR
		FOR
			SELECT I_RowID FROM TR_MG_CpPri WHERE TIPO_OBLIG = 1
		OPEN CUR_CP_PRI

		FETCH NEXT FROM CUR_CP_PRI INTO @I_RowID
		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago ON
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @B_Result = 1;
			SET @T_Observacion = '';
			SET @I_ConceptoPagoID = (SELECT ID_CP FROM TR_MG_CpPri  WHERE I_RowID = @I_RowID);
			SET @Count_ConcPago = (SELECT COUNT(ID_CP) FROM cp_pri WHERE ID_CP = @I_ConceptoPagoID);

			PRINT 'Validando ID del concepto de pago: ' + CAST(@I_ConceptoPagoID AS varchar(10))
			IF (@Count_ConcPago > 1)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion = ' El concepto pago se encuentra repetida.';
			END

			IF ((SELECT ANO FROM TR_MG_CpPri WHERE I_RowID = @I_RowID) IS NULL)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion += ' El concepto de pago de obligación sin año asignado.';
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
					PRINT 'Insertando registro en TI_ConceptoPago...'
					INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago (I_ConcPagID, I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, 
																		   I_AlumnosDestino, I_GradoDestino, I_TipoObligacion, T_Clasificador, C_CodTasa, B_Calculado, I_Calculado, B_AnioPeriodo, 
																		   I_Anio, I_Periodo, B_Especialidad, C_CodRc, B_Dependencia, C_DepCod, B_GrupoCodRc, I_GrupoCodRc, B_ModalidadIngreso, 
																		   I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, B_ConceptoAfecta, I_ConceptoAfectaID, N_NroPagos, B_Porcentaje, 
																		   C_Moneda, M_Monto, M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Mora, B_Migrado, B_Habilitado, B_Eliminado, I_TipoDescuentoID)
															SELECT  cp.ID_CP, ca.I_ProcesoID, 0 AS I_ConceptoID, cp.DESCRIPCIO, cp.FRACCIONAB, cp.CONCEPTO_G, cp.AGRUPA, ta.I_TipAluID, tg.I_TipGradoID,
																	tob.I_TipOblID, cp.CLASIFICAD, cp.CLASIFIC_5, CASE WHEN tc.I_TipCalcID IS NULL THEN 0 ELSE 1 END as B_Calculado, tc.I_TipCalcID, 
																	CASE CAST(cp.ano AS int) WHEN 0 THEN 0 ELSE 1 END as B_AnioPeriodo, cp.ANO, tp.I_TipPerID, CASE LEN(LTRIM(RTRIM(cp.COD_RC))) WHEN 0 THEN 0 ELSE 1 END as B_Especialidad, 
																	CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN NULL ELSE cp.cod_rc END, CASE LEN(LTRIM(RTRIM(cp.cod_dep_pl))) WHEN 0 THEN 0 ELSE 1 END as B_Dependencia, 
																	dep.I_DepID, CASE WHEN gr.I_TipGrpRc IS NULL THEN 0 ELSE 1 END as B_GrupoCodRc, gr.I_TipGrpRc, CASE WHEN ci.I_CodIngID IS NULL THEN 0 ELSE 1 END as B_ModalidadIngreso, 
																	ci.I_CodIngID, CASE cp.ID_CP_AGRP WHEN 0 THEN 0 ELSE 1 END as B_ConceptoAgrupa, CASE cp.ID_CP_AGRP WHEN 0 THEN NULL ELSE cp.ID_CP_AGRP END, 
																	CASE cp.ID_CP_AFEC WHEN 0 THEN 0 ELSE 1 END as B_ConceptoAfecta, CASE cp.ID_CP_AFEC WHEN 0 THEN NULL ELSE cp.ID_CP_AFEC END, cp.NRO_PAGOS, cp.PORCENTAJE, 
																	'PEN' as moneda, cp.MONTO, CAST(REPLACE(cp.MONTO_MIN, ',', '.') as float) as M_MontoMinimo, cp.DESCRIP_L, cp.DOCUMENTO, 
																	CASE cp.OBLIG_MORA WHEN 'VERDADERO' THEN 1 ELSE 0 END as B_Mora, 1 as B_Migrado, 1 as B_Habilitado, cp.eliminado, NULL as I_TipoDescuentoID
															FROM	TR_MG_CpPri cp
																	INNER JOIN @cuota_anio ca ON ca.I_ProcesoID = cp.CUOTA_PAGO
																	LEFT JOIN @tipo_alumno ta ON CAST(ta.C_CodTipAlu AS float) = cp.tip_alumno
																	LEFT JOIN @tipo_grado tg ON CAST(tg.C_CodTipGrado AS float) = cp.grado
																	LEFT JOIN @tipo_obligacion tob ON CAST(tob.C_CodTipObl AS bit) = cp.tipo_oblig
																	LEFT JOIN @tipo_calculado tc ON tc.C_CodCalc = cp.calcular
																	LEFT JOIN @tipo_periodo tp ON tp.C_CodTipPer = cp.p
																	LEFT JOIN @grupo_rc gr ON gr.C_CodGrpRc = cp.grupo_rc
																	LEFT JOIN @codigo_ing ci ON ci.C_CodIng = cp.cod_ing
																	LEFT JOIN @unfv_dep dep ON dep.C_DepCodPl = cp.COD_DEP_PL AND LEN(dep.C_DepCodPl) > 0
															WHERE	I_RowID = @I_RowID
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
	
			UPDATE TR_MG_CpPri
			SET  B_Migrado = @B_Migrado,
				 T_Observacion = @T_Observacion
			WHERE I_RowID = @I_RowID;

			FETCH NEXT FROM CUR_CP_PRI INTO @I_RowID
		END
		CLOSE CUR_CP_PRI;
		DEALLOCATE CUR_CP_PRI;

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago OFF

		UPDATE TR_MG_CpPri
		SET  B_Migrado = 0,
				T_Observacion = 'No es concepto de obligacion'
		WHERE TIPO_OBLIG <> 1;

		DECLARE @I_ConcPagID	int
		SET @I_ConcPagID = (SELECT MAX(CAST(ID_CP as int)) FROM TR_MG_CpPri) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TI_ConceptoPago], RESEED, @I_ConcPagID)

	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MigrarDataPagosObligaciones')
	DROP PROCEDURE [dbo].[USP_IU_MigrarDataPagosObligaciones]
GO

CREATE PROCEDURE USP_IU_MigrarDataPagosObligaciones
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	DECLARE @T_NombreTabla varchar(50);
	SET @T_NombreTabla = 'ec_obl'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontró la tabla "', @T_NombreTabla,'" requerida para el proceso de migración.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importación de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END

	SET @T_NombreTabla = 'ec_pri'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontró la tabla "', @T_NombreTabla,'" requerida para el proceso de migración.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importación de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END

	SET @T_NombreTabla = 'ec_det'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontró la tabla "', @T_NombreTabla,'" requerida para el proceso de migración.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importación de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END

	ELSE
	BEGIN

		DECLARE @I_obl_RowID int, @I_pri_RowID int, @I_det_RowID int 
		DECLARE @I_ObligacionAluID int 
		DECLARE @cuenta_deposito as TABLE (I_CtaDepositoID int, C_NumeroCuenta varchar(50))
		DECLARE @B_obl_Result bit, @B_det_Result bit
		DECLARE @B_obl_Migrado bit, @T_obl_Observacion varchar(500), @B_det_Migrado bit, @T_det_Observacion varchar(500)
		DECLARE @COD_ALU varchar(20), @COD_RC varchar(5), 
				@CUOTA_PAGO varchar(10), @ANO as varchar(4), 
				@P varchar(3), @TIPO_OBLIG varchar(3), @FCH_VENC varchar(20)

		-- 1. COPIAR DATA EC_OBL A TABLA DE MIGRACION 
		MERGE INTO TR_MG_EcObl as TRG
		USING ec_obl AS SRC 
		ON TRG.COD_ALU = SRC.COD_ALU AND
		   TRG.COD_RC = SRC.COD_RC AND
		   TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND
		   TRG.ANO = SRC.ANO AND
		   TRG.P = SRC.P AND
		   TRG.TIPO_OBLIG = SRC.TIPO_OBLIG AND
		   TRG.FCH_VENC = SRC.FCH_VENC AND
		   TRG.MONTO = SRC.MONTO AND
		   TRG.PAGADO = SRC.PAGADO
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO) 
			VALUES (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, FCH_VENC, MONTO, PAGADO);


		-- 2. COPIAR DATA EC_DET A TABLA DE MIGRACION 
		MERGE INTO TR_MG_EcDet as TRG
		USING ec_det AS SRC 
		ON TRG.COD_ALU = SRC.COD_ALU AND
		   TRG.COD_RC = SRC.COD_RC AND
		   TRG.CUOTA_PAGO = SRC.CUOTA_PAGO AND
		   TRG.ANO = SRC.ANO AND
		   TRG.P = SRC.P AND
		   TRG.TIPO_OBLIG = SRC.TIPO_OBLIG AND
		   TRG.CONCEPTO = SRC.CONCEPTO AND
		   TRG.FCH_VENC = SRC.FCH_VENC AND
		   TRG.MONTO = SRC.MONTO AND
		   TRG.ELIMINADO = SRC.ELIMINADO
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, CONCEPTO, FCH_VENC, NRO_RECIBO, FCH_PAGO, ID_LUG_PAG, CANTIDAD, MONTO, PAGADO, CONCEPTO_F, FCH_ELIMIN, NRO_EC, FCH_EC, ELIMINADO, PAG_DEMAS, COD_CAJERO, TIPO_PAGO, NO_BANCO, COD_DEP) 
			VALUES (COD_ALU, COD_RC, CUOTA_PAGO, ANO, P, TIPO_OBLIG, CONCEPTO, FCH_VENC, NRO_RECIBO, FCH_PAGO, ID_LUG_PAG, CANTIDAD, MONTO, PAGADO, CONCEPTO_F, FCH_ELIMIN, NRO_EC, FCH_EC, ELIMINADO, PAG_DEMAS, COD_CAJERO, TIPO_PAGO, NO_BANCO, COD_DEP);

		-- 3. COPIAR DATA TC_CuentaDeposito A TABLA DE TEMPORAL 
		INSERT INTO @cuenta_deposito (I_CtaDepositoID, C_NumeroCuenta) SELECT I_CtaDepositoID, C_NumeroCuenta FROM BD_OCEF_CtasPorCobrar.dbo.TC_CuentaDeposito;


		DECLARE CUR_EC_OBL CURSOR
		FOR
			SELECT EO.I_RowID FROM TR_MG_EcObl EO 
		OPEN CUR_EC_OBL
		FETCH NEXT FROM CUR_EC_OBL INTO @I_obl_RowID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @B_Result = 1;
			SET @T_obl_Observacion = ''

			SELECT @COD_ALU = COD_ALU, @COD_RC = COD_RC, @CUOTA_PAGO = CUOTA_PAGO, 
				   @ANO = ANO, @P = P, @TIPO_OBLIG = TIPO_OBLIG, @FCH_VENC = CONVERT(varchar, FCH_VENC, 112)
			FROM TR_MG_EcObl WHERE I_RowID = @I_obl_RowID

			PRINT 'Validando combinacion (COD_ALU/COD_RC/CUOTA_PAGO/ANO/P/TIPO_OBLIG/FCH_VENC) :' + CONCAT(@COD_ALU, '/', @COD_RC, '/', @CUOTA_PAGO, '/', @ANO, '/', @P, '/', @TIPO_OBLIG, '/', @FCH_VENC)
			
			IF((SELECT COUNT(*) FROM TR_MG_EcObl WHERE @COD_ALU = COD_ALU AND @COD_RC = COD_RC AND @CUOTA_PAGO = CUOTA_PAGO AND
				   @ANO = ANO AND @P = P AND @TIPO_OBLIG = TIPO_OBLIG AND @FCH_VENC = CONVERT(varchar, FCH_VENC, 112)) > 1)
			BEGIN
				SET @B_Result = 0;
				SET @T_obl_Observacion = 'La combinacion (COD_ALU/COD_RC/CUOTA_PAGO/ANO/P/TIPO_OBLIG/FCH_VENC) se encuentra repetida.'
			END
			ELSE
			BEGIN
				DECLARE CUR_EC_DET CURSOR
				FOR
					SELECT ED.I_RowID FROM TR_MG_EcDet ED 
					LEFT JOIN TR_MG_EcObl EO ON ED.COD_ALU = EO.COD_ALU AND ED.COD_RC = EO.COD_RC 
								AND ED.CUOTA_PAGO = EO.CUOTA_PAGO AND ED.ANO = EO.ANO AND ED.P = EO.P 
								AND ED.FCH_VENC = EO.FCH_VENC
					WHERE ED.TIPO_OBLIG = 'T' AND EO.I_RowID = @I_obl_RowID 

				OPEN CUR_EC_DET
				FETCH NEXT FROM CUR_EC_DET INTO @I_det_RowID

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @B_Result = 1;
					SET @T_Observacion = ''

					PRINT 'Validando combinacion: ' + CAST(@I_CuotaPago AS varchar(10))
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

					FETCH NEXT FROM CUR_EC_DET INTO @I_det_RowID
				END
				CLOSE CUR_EC_DET;
				DEALLOCATE CUR_EC_DET;

				FETCH NEXT FROM CUR_EC_OBL INTO @I_obl_RowID
			END
			
			if
			UPDATE TR_MG_EcObl SET B_Migrado = @B_Migrado 
		END
		CLOSE CUR_EC_OBL;
		DEALLOCATE CUR_EC_OBL;

		SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF

		DECLARE @I_ProcesoID	int
		SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

		DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, @I_ProcesoID)


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



--select 
--		p.ID_CP, p.DESCRIPCIO,
--		o.*, 
--		d.* 
--from ec_det d
--left join ec_obl o ON o.COD_ALU = d.COD_ALU 
--			and o.COD_RC = d.COD_RC 
--			and o.CUOTA_PAGO = d.CUOTA_PAGO
--			and o.ANO = d.ANO 
--			and o.P = d.P
--			and o.FCH_VENC = CAST(d.FCH_VENC as datetime)
--left join cp_pri p ON p.ID_CP = d.CONCEPTO
--where d.ANO = '2020' and d.TIPO_OBLIG = 'T' and d.COD_ALU = '2019316456'
--and d.ELIMINADO = 'F' AND d.P = '1'

--select * from cp_des WHERE CUOTA_PAGO = 488


--DECLARE	@B_Resultado  bit,@T_Message	  nvarchar(4000)	
--EXEC USP_IU_MigrarDataCuotaDePago @B_Resultado OUTPUT, @T_Message OUTPUT
--GO

--DECLARE	@B_Resultado  bit,@T_Message	  nvarchar(4000)	
--EXEC USP_IU_MigrarDataConceptosPagoObligacion @B_Resultado OUTPUT, @T_Message OUTPUT



