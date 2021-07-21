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
		SET @T_Message = CONCAT('No se encontr� la tabla "', @T_NombreTabla,'" requerida para el proceso de migraci�n.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importaci�n de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
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

		-- 2. COPIAR A�OS DE LAS CUOTAS DE PAGO DE LA TABLA CP_PRI 
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
				SET @T_Observacion = ' El n�mero de cuota de pago se encuentra repetida.';
			END

			IF (@Count_categoria > 1)
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion += ' La cuota de pago est� asociada a m�s de una categor�a en la nueva base de datos.';
			END

			IF NOT EXISTS (SELECT * FROM @cuota_anio WHERE cuota_pago = @I_CuotaPago )
			BEGIN 
				SET @B_Result = 0;
				SET @T_Observacion += ' La cuota de pago NO tiene un a�o asignado.';
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
		SET @T_Message = CONCAT('No se encontr� la tabla "', @T_NombreTabla,'" requerida para el proceso de migraci�n.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importaci�n de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
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
				SET @T_Observacion += ' El concepto de pago de obligaci�n sin a�o asignado.';
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
	@C_Anio		  nvarchar(4),
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	DECLARE @T_NombreTabla varchar(50);
	SET @T_NombreTabla = 'ec_obl'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontr� la tabla "', @T_NombreTabla,'" requerida para el proceso de migraci�n.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importaci�n de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END

	SET @T_NombreTabla = 'ec_pri'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontr� la tabla "', @T_NombreTabla,'" requerida para el proceso de migraci�n.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importaci�n de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END

	SET @T_NombreTabla = 'ec_det'
	IF (dbo.Func_B_ValidarExisteTablaDatos (@T_NombreTabla) = 0)
	BEGIN
		SET @B_Resultado = 0;
		SET @T_Message = CONCAT('No se encontr� la tabla "', @T_NombreTabla,'" requerida para el proceso de migraci�n.', char(13), CHAR(10), 
					   		    'Debe importar el archivo "', @T_NombreTabla,'" o "', @T_NombreTabla,'" desde el asistente de importaci�n de sql y renombar la tabla importada como "', @T_NombreTabla,'".')
	END

	ELSE
	BEGIN

		DECLARE @I_obl_RowID int, @I_pri_RowID int, @I_det_RowID int 
		DECLARE @I_ObligacionAluID int, @I_PagoBancoID int 
		DECLARE @cuenta_deposito as TABLE (I_CtaDepositoID int, I_ProcesoID int)
		DECLARE @periodos as TABLE (I_PeriodoID int, C_CodPeriodo varchar(10))
		DECLARE @proceso as TABLE (I_ProcesoID int, I_Anio int, I_Periodo int, D_FecVencto datetime, C_CodPer varchar(3))
		DECLARE @matricula_alumno as TABLE (I_MatAluID int, C_CodRc varchar(10), C_CodAlu varchar(20), I_Anio int, I_Periodo int, C_CodPer varchar(3))
		DECLARE @B_obl_Result bit, @B_det_Result bit
		DECLARE @B_obl_Migrado bit, @T_obl_Observacion varchar(500), @B_det_Migrado bit, @T_det_Observacion varchar(500)
		DECLARE @COD_ALU varchar(20), @COD_RC varchar(5), @I_CUOTA_PAGO as int, 
				@CUOTA_PAGO varchar(10), @ANO as varchar(4), @CONCEPTO as varchar(10),
				@P varchar(3), @TIPO_OBLIG varchar(3), @FCH_VENC varchar(20)

		PRINT 'COPIANDO DATA EC_OBL A TABLA DE MIGRACION' 
		MERGE INTO TR_MG_EcObl as TRG
		USING (SELECT * FROM ec_obl WHERE ANO = @C_Anio OR @C_Anio IS NULL) AS SRC 
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


		PRINT 'COPIANDO DATA EC_DET A TABLA DE MIGRACION' 
		MERGE INTO TR_MG_EcDet as TRG
		USING (SELECT * FROM ec_det WHERE ANO = @C_Anio OR @C_Anio IS NULL) AS SRC 
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

		PRINT 'COPIANDO DATA TC_CuentaDeposito A TABLA DE TEMPORAL' 
		INSERT INTO @cuenta_deposito (I_CtaDepositoID, I_ProcesoID) SELECT I_CtaDepositoID, I_ProcesoID FROM BD_OCEF_CtasPorCobrar.dbo.TI_CtaDepo_Proceso;

		PRINT 'COPIANDO DATA TC_CatalogoOpcion A TABLA DE TEMPORAL' 
		INSERT INTO @periodos (I_PeriodoID, C_CodPeriodo) SELECT I_OpcionID, T_OpcionCod FROM BD_OCEF_CtasPorCobrar.dbo.TC_CatalogoOpcion WHERE I_ParametroID = 5;

		PRINT 'COPIANDO DATA TC_MatriculaAlumno A TABLA DE TEMPORAL' 
		MERGE INTO BD_OCEF_CtasPorCobrar.dbo.TC_MatriculaAlumno as TRG
		USING (SELECT DISTINCT COD_ALU, COD_RC, ANO, P.I_PeriodoID FROM ec_obl obl INNER JOIN @periodos P ON obl.P = P.C_CodPeriodo WHERE ISNUMERIC(ANO) = 1) AS SRC 
		ON TRG.C_CodAlu = SRC.COD_ALU AND
		   TRG.C_CodRc = SRC.COD_RC AND
		   TRG.I_Anio = CAST(SRC.ANO as int) AND
		   TRG.I_Periodo = SRC.I_PeriodoID 
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, C_EstMat, B_Ingresante, B_Migrado, B_Habilitado, B_Eliminado)
			VALUES (SRC.COD_RC, SRC.COD_ALU, CAST(SRC.ANO as int), SRC.I_PeriodoID, 'S', 0, 1, 1, 0);

		PRINT 'COPIANDO DATA TC_MatriculaAlumno A TABLA DE TEMPORAL' 
		INSERT INTO @matricula_alumno (I_MatAluID, C_CodRc, C_CodAlu, I_Anio, I_Periodo, C_CodPer)
		  SELECT I_MatAluID, C_CodRc, C_CodAlu, I_Anio, I_Periodo, C.C_CodPeriodo  
			FROM BD_OCEF_CtasPorCobrar.dbo.TC_MatriculaAlumno M 
				 INNER JOIN @periodos C ON M.I_Periodo = C.I_PeriodoID

		PRINT 'COPIANDO DATA TC_Proceso A TABLA DE TEMPORAL' 
		INSERT INTO @proceso (I_ProcesoID, I_Anio, I_Periodo, D_FecVencto, C_CodPer)
		SELECT I_ProcesoID, I_Anio, I_Periodo, D_FecVencto, c.C_CodPeriodo FROM BD_OCEF_CtasPorCobrar.dbo.TC_Proceso P
				 INNER JOIN @periodos C ON P.I_Periodo = C.I_PeriodoID
		 
		DECLARE CUR_EC_OBL CURSOR
		FOR
			SELECT EO.I_RowID FROM TR_MG_EcObl EO 
		OPEN CUR_EC_OBL
		FETCH NEXT FROM CUR_EC_OBL INTO @I_obl_RowID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @B_obl_Result = 1;
			SET @T_obl_Observacion = ''

			SELECT @COD_ALU = COD_ALU, @COD_RC = COD_RC, @CUOTA_PAGO = CUOTA_PAGO, 
				   @ANO = ANO, @P = P, @TIPO_OBLIG = TIPO_OBLIG, @FCH_VENC = CONVERT(varchar, FCH_VENC, 112)
			FROM TR_MG_EcObl WHERE I_RowID = @I_obl_RowID

			PRINT 'Validando combinacion (COD_ALU/COD_RC/CUOTA_PAGO/ANO/P/TIPO_OBLIG/FCH_VENC) :' + CONCAT(@COD_ALU, '/', @COD_RC, '/', @CUOTA_PAGO, '/', @ANO, '/', @P, '/', @TIPO_OBLIG, '/', @FCH_VENC)
			
			IF((SELECT COUNT(*) FROM TR_MG_EcObl WHERE @COD_ALU = COD_ALU AND @COD_RC = COD_RC AND @CUOTA_PAGO = CUOTA_PAGO AND
				   @ANO = ANO AND @P = P AND @TIPO_OBLIG = TIPO_OBLIG AND @FCH_VENC = CONVERT(varchar, FCH_VENC, 112)) > 1)
			BEGIN
				SET @B_obl_Result = 0;
				SET @T_obl_Observacion = 'La combinacion (COD_ALU/COD_RC/CUOTA_PAGO/ANO/P/TIPO_OBLIG/FCH_VENC) se encuentra repetida.'
			END

			IF NOT EXISTS (SELECT O.* FROM @proceso P 
								INNER JOIN TR_MG_EcObl O ON P.I_ProcesoID = O.CUOTA_PAGO AND CAST(P.I_Anio as varchar(4)) = O.ANO AND P.C_CodPer = O.P
								WHERE O.I_RowID = @I_obl_RowID)	
			BEGIN
				SET @B_obl_Result = 0;
				SET @T_obl_Observacion = 'La cuota de pago no se encuentra en la data migrada.'
			END

			IF ((SELECT ISNUMERIC(ANO) FROM TR_MG_EcObl WHERE I_RowID = @I_obl_RowID) = 0)	
			BEGIN
				SET @B_obl_Result = 0;
				SET @T_obl_Observacion = 'El A�O no es un n�mero.'
			END

			IF(@B_obl_Result = 0)
			BEGIN
				SET @B_obl_Migrado = 0
				PRINT @T_obl_Observacion;
			END
			ELSE
			BEGIN
				BEGIN TRANSACTION TRAN_OBL
				BEGIN TRY
					PRINT 'Insertando data a TR_ObligacionAluCab...' 
					INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TR_ObligacionAluCab (I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado)
						SELECT O.CUOTA_PAGO, M.I_MatAluID, 'PEN', O.MONTO, O.FCH_VENC, O.PAGADO, 1, 0
						  FROM TR_MG_EcObl O INNER JOIN TR_MG_CpDes D ON D.CUOTA_PAGO = O.CUOTA_PAGO AND D.ELIMINADO = 0 AND D.B_Migrado = 1
							   INNER JOIN @matricula_alumno M ON O.COD_ALU = M.C_CodAlu AND O.ANO = CAST(M.I_Anio as varchar(4)) AND O.COD_RC = M.C_CodRc AND O.P = M.C_CodPer
						 WHERE O.I_RowID = @I_obl_RowID;

					SET @I_ObligacionAluID = SCOPE_IDENTITY();

					DECLARE CUR_EC_DET CURSOR
					FOR
						SELECT ED.I_RowID FROM TR_MG_EcDet ED 
						LEFT JOIN TR_MG_EcObl EO ON ED.COD_ALU = EO.COD_ALU AND ED.COD_RC = EO.COD_RC 
									AND ED.CUOTA_PAGO = EO.CUOTA_PAGO AND ED.ANO = EO.ANO AND ED.P = EO.P 
									AND CONCAT(SUBSTRING(ED.FCH_VENC,7,4),SUBSTRING(ED.FCH_VENC,1,2),SUBSTRING(ED.FCH_VENC,4,2)) = CONVERT(varchar, EO.FCH_VENC, 112)
						WHERE ED.TIPO_OBLIG = 'T' AND EO.I_RowID = @I_obl_RowID 

					OPEN CUR_EC_DET
					FETCH NEXT FROM CUR_EC_DET INTO @I_det_RowID

					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @B_det_Result = 1;
						SET @T_det_Observacion = ''

						--SELECT @COD_ALU = COD_ALU, @COD_RC = COD_RC, @CUOTA_PAGO = CUOTA_PAGO, @ANO = ANO, @P = P,@CONCEPTO = CONCEPTO, 
						--	   @TIPO_OBLIG = TIPO_OBLIG, @FCH_VENC = CONCAT(SUBSTRING(FCH_VENC,7,4),SUBSTRING(FCH_VENC,1,2),SUBSTRING(FCH_VENC,4,2))
						--  FROM TR_MG_EcDet WHERE I_RowID = @I_det_RowID

						--PRINT 'Validando combinacion (COD_ALU/COD_RC/CUOTA_PAGO/ANO/P/TIPO_OBLIG/CONCEPTO/FCH_VENC) :' + CONCAT(@COD_ALU, '/', @COD_RC, '/', @CUOTA_PAGO, '/', @ANO, '/', @P, '/', @TIPO_OBLIG, '/', @CONCEPTO, '/', @FCH_VENC)
						--IF (@Count_cuota > 1)
						--BEGIN 
						--	SET @B_Result = 0;
						--	SET @T_Observacion = ' El n�mero de cuota de pago se encuentra repetida.';
						--END

						--IF (@Count_categoria > 1)
						--BEGIN 
						--	SET @B_Result = 0;
						--	SET @T_Observacion += ' La cuota de pago est� asociada a m�s de una categor�a en la nueva base de datos.';
						--END

						--IF NOT EXISTS (SELECT * FROM @cuota_anio WHERE cuota_pago = @I_CuotaPago )
						--BEGIN 
						--	SET @B_Result = 0;
						--	SET @T_Observacion += ' La cuota de pago NO tiene un a�o asignado.';
						--END

						IF (@B_det_Result = 0)
						BEGIN
							SET @B_det_Migrado = 0;
							PRINT @T_det_Observacion;
						END
						ELSE
						BEGIN
							BEGIN TRANSACTION TRAN_DET
							BEGIN TRY
								PRINT 'Insertando registro en TR_ObligacionAluDet...'
								INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TR_ObligacionAluDet (I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado)
									SELECT  @I_ObligacionAluID, CONCEPTO, CAST(REPLACE(MONTO, ',','.') AS decimal(10,2)), CASE PAGADO WHEN 'T' THEN 1 ELSE 0 END as B_Pagado, 
											CAST(CONCAT(SUBSTRING(FCH_VENC,7,4),SUBSTRING(FCH_VENC,1,2),SUBSTRING(FCH_VENC,4,2)) as datetime) as D_FecVencto, NULL, NULL, 1, CASE ED.ELIMINADO WHEN 'T' THEN 1 ELSE 0 END
									  FROM TR_MG_EcDet ED 
									 WHERE I_RowID = @I_det_RowID AND CONCEPTO <> 0;

								PRINT 'Insertando registro en TR_PagoBanco...'
								INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TR_PagoBanco (I_EntidadFinanID, C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad, C_Moneda, I_MontoPago, T_LugarPago, B_Anulado)
									SELECT  1 AS I_EntidadFinanID, NRO_RECIBO, COD_ALU, CONCAT(MA.T_Nombre, ' ', MA.T_ApePaterno, ' ', MA.T_ApeMaterno), NRO_RECIBO, CAST(CONCAT(SUBSTRING(FCH_PAGO,7,4),SUBSTRING(FCH_PAGO,1,2),SUBSTRING(FCH_PAGO,4,2)) as datetime) as D_FecPago,
											CAST(REPLACE(CANTIDAD, ',','.') AS int), 'PEN', CAST(REPLACE(MONTO, ',','.') AS decimal(10,2)) AS I_MontoPago, CONCAT(ED.ID_LUG_PAG, ' ', ED.COD_CAJERO) AS T_LugarPago, 0
									  FROM TR_MG_EcDet ED 
										   LEFT JOIN BD_OCEF_CtasPorCobrar.dbo.VW_MatriculaAlumno MA ON MA.C_CodAlu = ED.COD_ALU
									 WHERE CONCEPTO = 0 AND I_RowID = @I_det_RowID;

								SET @I_PagoBancoID = SCOPE_IDENTITY();

								PRINT 'Insertando registro en TRI_PagoProcesadoUnfv...'
								INSERT INTO BD_OCEF_CtasPorCobrar.dbo.TRI_PagoProcesadoUnfv (I_PagoBancoID, I_CtaDepositoID, I_TasaUnfvID, I_ObligacionAluID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas, N_NroSIAF, B_Anulado)
										SELECT	@I_PagoBancoID, CTA.I_CtaDepositoID, NULL, @I_ObligacionAluID, ED.MONTO, 0, 0, CASE PAG_DEMAS WHEN 'T' THEN 1 ELSE 0 END, NULL, 0
										  FROM	TR_MG_EcDet ED
												INNER JOIN @cuenta_deposito CTA ON ED.CUOTA_PAGO = CAST(CTA.I_ProcesoID AS varchar(10))
									 WHERE CONCEPTO = 0 AND I_RowID = @I_det_RowID;

								SET @B_det_Migrado = 1;
								COMMIT TRANSACTION TRAN_DET;
							END TRY
							BEGIN CATCH
								SET @B_det_Migrado = 0;
								SET @T_det_Observacion = ERROR_MESSAGE();
								PRINT @T_det_Observacion
								ROLLBACK TRANSACTION TRAN_DET;
							END CATCH
						END
	
						UPDATE	TR_MG_EcDet
						  SET	B_Migrado = @B_det_Migrado,
								T_Observacion = @T_det_Observacion
						 WHERE	I_RowID = @I_det_RowID;

						FETCH NEXT FROM CUR_EC_DET INTO @I_det_RowID
					END
					CLOSE CUR_EC_DET;
					DEALLOCATE CUR_EC_DET;

					SET @B_obl_Migrado = 1;
					COMMIT TRANSACTION TRAN_OBL;					
				END TRY
				BEGIN CATCH
					SET @B_obl_Migrado = 0;
					SET @T_obl_Observacion = ERROR_MESSAGE();
					PRINT @T_obl_Observacion
					ROLLBACK TRANSACTION TRAN_OBL;
				END CATCH		
			END		

			UPDATE TR_MG_EcObl 
			SET B_Migrado = @B_obl_Migrado,
				T_Observacion = @T_obl_Observacion
			WHERE I_RowID = @I_obl_RowID
			
			FETCH NEXT FROM CUR_EC_OBL INTO @I_obl_RowID
		END
		CLOSE CUR_EC_OBL;
		DEALLOCATE CUR_EC_OBL;
	END
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
								B_Migrable = 0			

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

		SET @I_Insertados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'INSERT')
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 0)
		SET @I_Actualizados = (SELECT COUNT(*) FROM @Tbl_output WHERE accion = 'UPDATE' AND B_Removido = 1)

		SELECT @I_Insertados AS cant_inserted, @I_Actualizados as cant_updated, @I_Removidos as cant_removed, @D_FecProceso as fec_proceso
		
		SET @B_Resultado = 1
		SET @T_Message = 'Ok'
	END TRY
	BEGIN CATCH
		SET @B_Resultado = 0
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10)) 
	END CATCH
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaConceptosDePago')
	DROP PROCEDURE [dbo].[USP_IU_MarcarRepetidosCuotaDePago]
GO

CREATE PROCEDURE USP_IU_MarcarRepetidosCuotaDePago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_CopiarTablaObligaciones')
	DROP PROCEDURE [dbo].[USP_IU_MarcarRepetidosCuotaDePago]
GO

CREATE PROCEDURE USP_IU_MarcarRepetidosCuotaDePago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN
	
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_IU_MarcarRepetidosCuotaDePago')
	DROP PROCEDURE [dbo].[USP_IU_MarcarRepetidosCuotaDePago]
GO

CREATE PROCEDURE USP_IU_MarcarRepetidosCuotaDePago
	@B_Resultado  bit output,
	@T_Message	  nvarchar(4000) OUTPUT	
AS
BEGIN


END
GO