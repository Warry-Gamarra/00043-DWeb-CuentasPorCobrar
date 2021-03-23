USE BD_OCEF_CtasPorCobrar
GO


/* -------------------------------- TC_CuentaDeposito ------------------------------------ */

/*	SI DURANTE LA MIGRACION EXISTEN MAS NUMEROS DE CUENTA QUE LOS REGISTRADOS INICIALMENTE SE
	INSERTAN EN LA TABLA TC_CuentaDeposito
*/


IF EXISTS (SELECT DISTINCT N_CTA_CTE FROM temporal_pagos..cp_des 
			WHERE ELIMINADO = 0 AND NOT EXISTS (
			SELECT * FROM TC_CuentaDeposito CD 
			WHERE N_CTA_CTE COLLATE DATABASE_DEFAULT = C_NumeroCuenta COLLATE DATABASE_DEFAULT))
BEGIN
	INSERT TC_CuentaDeposito(I_EntidadFinanID, C_NumeroCuenta, B_Habilitado, B_Eliminado)
	SELECT DISTINCT 1, N_CTA_CTE, 1, 0 FROM temporal_pagos..cp_des 
			WHERE ELIMINADO = 0 AND NOT EXISTS (
			SELECT * FROM TC_CuentaDeposito CD 
			WHERE N_CTA_CTE COLLATE DATABASE_DEFAULT = C_NumeroCuenta COLLATE DATABASE_DEFAULT)
END
GO


/* -------------------------------- TC_CuentaDeposito_CategoriaPago ------------------------------------ */

INSERT TC_CuentaDeposito_CategoriaPago(I_CtaDepositoID, I_CatPagoID, B_Habilitado, B_Eliminado)
SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
FROM TC_CategoriaPago CP 
	 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
				 FROM TC_CuentaDeposito CD  
				 	 INNER JOIN temporal_pagos..cp_des TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
				 WHERE ELIMINADO = 0
) BNC ON CP.N_CodBanco = BNC.CODIGO_BNC
UNION
SELECT BNC.I_CtaDepositoID, CP.I_CatPagoID, 1 AS B_Habilitado, 0 as B_Eliminado--, C_NumeroCuenta, CODIGO_BNC    
FROM TC_CategoriaPago CP 
	 INNER JOIN (SELECT DISTINCT I_CtaDepositoID, C_NumeroCuenta, TP_CP.CODIGO_BNC COLLATE DATABASE_DEFAULT AS CODIGO_BNC
				 FROM TC_CuentaDeposito CD  
 				 		INNER JOIN temporal_pagos..cp_des TP_CP ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CP.N_CTA_CTE COLLATE DATABASE_DEFAULT
				 WHERE CODIGO_BNC IS NULL AND ELIMINADO = 0
) BNC ON CP.N_CodBanco IS NULL
GO


/* -------------------------------- TC_Proceso - TI_CtaDepo_Proceso ------------------------------------ */

SET IDENTITY_INSERT TC_Proceso ON
GO

WITH TEMP_PROC (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, B_Habilitado, B_Eliminado)
AS
(
	SELECT CAST(TP_CD.CUOTA_PAGO AS INT) CUOTA_PAGO, I_CatPagoID, TP_CD.DESCRIPCIO, 
	   CASE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4))) WHEN 1 THEN SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4) ELSE NULL END AS I_Anio, 
	    CODIGO_BNC, FCH_VENC, PRIORIDAD, CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 ELSE NULL END AS C_MORA,
		1 AS B_Migrado, 1 AS B_Habilitado, TP_CD.ELIMINADO
	FROM TC_CategoriaPago CP  
		  INNER JOIN temporal_pagos..cp_des TP_CD ON CP.N_CodBanco COLLATE DATABASE_DEFAULT = TP_CD.CODIGO_BNC COLLATE DATABASE_DEFAULT
	WHERE TP_CD.ELIMINADO = 0 AND CODIGO_BNC IN (
			'0635','0636','0638','0670','0671','0674',
			'0675','0678','0679','0680','0681','0682',
			'0683','0689','0690','0691','0692','0695',
			'0696','0697','0698'
			)
)

INSERT INTO TC_Proceso (I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, B_Habilitado, B_Eliminado)
SELECT	I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, co_periodo.I_OpcionID AS I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, B_Migrado, TEMP.B_Habilitado, TEMP.B_Eliminado
FROM	TEMP_PROC TEMP
		LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM temporal_pagos..cp_pri WHERE eliminado = 0) TP_CP ON TP_CP.cuota_pago = TEMP.I_ProcesoID
		LEFT JOIN TC_CatalogoOpcion co_periodo ON co_periodo.T_OpcionCod COLLATE DATABASE_DEFAULT = TP_CP.p COLLATE DATABASE_DEFAULT AND co_periodo.I_ParametroID = 5
WHERE	NOT EXISTS (
			SELECT TP_CD2.I_ProcesoID , COUNT(TP_CD2.I_ProcesoID)
			  FROM TEMP_PROC TP_CD2
				   LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM temporal_pagos..cp_pri WHERE eliminado = 0) TP_CP ON TP_CP.cuota_pago = TP_CD2.I_ProcesoID
			 WHERE TP_CD2.I_ProcesoID = TEMP.I_ProcesoID
			GROUP BY TP_CD2.I_ProcesoID
			HAVING COUNT(TP_CD2.I_ProcesoID) > 1
		)
UNION
SELECT	I_ProcesoID, I_CatPagoID, T_ProcesoDesc, I_Anio, NULL AS I_Periodo, N_CodBanco, D_FecVencto, I_Prioridad, B_Mora, 
		B_Migrado, TEMP.B_Habilitado, TEMP.B_Eliminado
FROM	TEMP_PROC TEMP
WHERE	EXISTS (
			SELECT TP_CD2.I_ProcesoID , COUNT(TP_CD2.I_ProcesoID)
			  FROM TEMP_PROC TP_CD2
				   LEFT JOIN (SELECT DISTINCT cuota_pago, ano, p FROM temporal_pagos..cp_pri WHERE eliminado = 0) TP_CP ON TP_CP.cuota_pago = TP_CD2.I_ProcesoID
			 WHERE TP_CD2.I_ProcesoID = TEMP.I_ProcesoID
			GROUP BY TP_CD2.I_ProcesoID
			HAVING COUNT(TP_CD2.I_ProcesoID) > 1
		)
UNION
SELECT CAST(TP_CD.CUOTA_PAGO AS INT) CUOTA_PAGO, I_CatPagoID, TP_CD.DESCRIPCIO, 
	   CASE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4))) WHEN 1 THEN SUBSTRING(LTRIM(TP_CD.DESCRIPCIO),1,4) ELSE NULL END AS I_Anio, 
	    NULL AS I_Periodo, CODIGO_BNC, FCH_VENC, PRIORIDAD, CASE C_MORA WHEN 'VERDADERO' THEN 1 WHEN 'FALSO' THEN 0 ELSE NULL END AS C_MORA,
		1 AS B_Migrado, 1 AS B_Habilitado, TP_CD.ELIMINADO
FROM TC_CategoriaPago CP  
	  INNER JOIN temporal_pagos..cp_des TP_CD ON TP_CD.CODIGO_BNC IS NULL AND CP.B_Obligacion = 0 
WHERE TP_CD.ELIMINADO = 0

SET IDENTITY_INSERT TC_Proceso OFF
GO

INSERT INTO TI_CtaDepo_Proceso (I_CtaDepositoID, I_ProcesoID, B_Habilitado, B_Eliminado)
SELECT CD.I_CtaDepositoID, P.I_ProcesoID, 1 AS B_Habilitado, 0 AS B_Eliminado
FROM TC_Proceso P
	INNER JOIN temporal_pagos..cp_des TP_CD ON TP_CD.CUOTA_PAGO = P.I_ProcesoID AND TP_CD.ELIMINADO = 0
	INNER JOIN TC_CuentaDeposito CD ON CD.C_NumeroCuenta COLLATE DATABASE_DEFAULT = TP_CD.N_CTA_CTE COLLATE DATABASE_DEFAULT
GO


/* -------------------------------- TC_Concepto - TI_ConceptoPago ------------------------------------ */
