
DECLARE @I_RowID int, @I_CuotaPago int
DECLARE @Count_cuota int, @Count_categoria int, @B_Result bit
DECLARE @B_Migrado bit, @T_Observacion varchar(500)

DECLARE @cuota_anio AS TABLE (cuota_pago int, anio_cuota varchar(4))
DECLARE @categoria_pago AS TABLE (I_CatPagoID int, N_CodBanco varchar(10))
DECLARE @periodo AS TABLE (I_Periodo int, C_CodPeriodo varchar(5), T_Descripion varchar(50))

/* 1. COPIAR DATA CP_DES A TABLA DE MIGRACION */

TRUNCATE TABLE TR_MG_CpDes;

INSERT INTO TR_MG_CpDes (CUOTA_PAGO, DESCRIPCIO, N_CTA_CTE, ELIMINADO, CODIGO_BNC, FCH_VENC, PRIORIDAD, C_MORA) 
	 SELECT CUOTA_PAGO, DESCRIPCIO, N_CTA_CTE, ELIMINADO, CODIGO_BNC, FCH_VENC, PRIORIDAD, C_MORA FROM cp_des;

INSERT INTO @cuota_anio(cuota_pago, anio_cuota)
SELECT DISTINCT D.CUOTA_PAGO, ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4)) AS ANO 
FROM cp_des D LEFT JOIN cp_pri P ON D.CUOTA_PAGO = P.CUOTA_PAGO 
WHERE ISNUMERIC(ISNULL(P.ANO, SUBSTRING(D.DESCRIPCIO, 1,4))) = 1;

INSERT INTO @categoria_pago (I_CatPagoID, N_CodBanco)
	SELECT I_CatPagoID, N_CodBanco FROM BD_OCEF_CtasPorCobrar.dbo.TC_CategoriaPago

INSERT INTO @periodo (I_Periodo, C_CodPeriodo, T_Descripion)
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
	SET @I_CuotaPago = (SELECT CUOTA_PAGO FROM TR_MG_CpDes WHERE I_RowID = @I_RowID)
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
		PRINT @T_Observacion
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
	WHERE I_RowID = @I_RowID

	FETCH NEXT FROM CUR_CP_DES INTO @I_RowID
END
CLOSE CUR_CP_DES
DEALLOCATE CUR_CP_DES

SET IDENTITY_INSERT BD_OCEF_CtasPorCobrar.dbo.TC_Proceso OFF

DECLARE @I_ProcesoID	int
SET @I_ProcesoID = (SELECT MAX(CAST(CUOTA_PAGO as int)) FROM TR_MG_CpDes) + 1 

DBCC CHECKIDENT([BD_OCEF_CtasPorCobrar.dbo.TC_Proceso], RESEED, 0)











declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_IU_CopiarTablaCuotaDePago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_MarcarRepetidosCuotaDePago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_AsignarAnioPeriodoCuotaPago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_AsignarCategoriaCuotaPago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
exec USP_IU_MigrarDataCuotaDePagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO





declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_IU_CopiarTablaConceptoDePago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_AsignarIdEquivalenciasConceptoPago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_MarcarConceptosPagoRepetidos @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_MarcarConceptosPagoObligSinAnioAsignado @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_U_MarcarConceptosPagoObligSinCuotaPago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO


declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_IU_GrabarTablaCatalogoConceptos @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO

declare @B_Resultado  bit, @I_AnioIni int, @I_AnioFin int, @T_Message	  nvarchar(4000)
exec USP_IU_MigrarDataConceptoPagoCtasPorCobrar @I_AnioIni = null, @I_AnioFin = null, @B_Resultado = @B_Resultado output, @T_Message = @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje
GO




declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_IU_CopiarTablaObligacionesPago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje


declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_IU_CopiarTablaDetalleObligacionesPago @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje


declare @B_Resultado  bit,
		@T_Message	  nvarchar(4000)
exec USP_IU_CopiarTablaAlumno @B_Resultado output, @T_Message output
select @B_Resultado as resultado, @T_Message as mensaje


