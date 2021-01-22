select * from cp_des WHERE DESCRIPCIO LIKE '%SERV%'
select * from cp_des WHERE DESCRIPCIO LIKE '%OTR%REG%'
select * from cp_des WHERE DESCRIPCIO LIKE '%OTR%IN%'
select * from cp_des WHERE DESCRIPCIO LIKE '%OTR%' 
select * from cp_des WHERE DESCRIPCIO LIKE '%EUPG%' 
select * from cp_des WHERE DESCRIPCIO LIKE '%TASAS%' 



select * from temporal_pagos..ec_det where concepto in (
select LEN(descrip_l) from cp_pri p left join cp_des d on p.cuota_pago = d.CUOTA_PAGO)



--dbcc checkident(TI_ConceptoPago)
select * from TI_ConceptoPago WHERE I_TipoObligacion = 9

SET IDENTITY_INSERT TI_ConceptoPago ON

INSERT INTO TI_ConceptoPago (I_ConcPagID, I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_AlumnosDestino, I_GradoDestino, I_TipoObligacion, 
							 T_Clasificador, C_CodTasa, B_Calculado, I_Calculado, B_AnioPeriodo, I_Anio, I_Periodo, B_Especialidad, C_CodRc, B_Dependencia, C_DepCod, B_GrupoCodRc, I_GrupoCodRc, 
							 B_ModalidadIngreso, I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, B_ConceptoAfecta, I_ConceptoAfectaID, N_NroPagos, B_Porcentaje, C_Moneda, M_Monto, 
							 M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Migrado, B_Habilitado, B_Eliminado, I_TipoDescuentoID) 
					 SELECT cp.id_cp, cp.cuota_pago, 0, cp.descripcio, cp.fraccionab, cp.concepto_g, cp.agrupa, co_tipoAlumno.I_OpcionID, co_grado.I_OpcionID, co_tipOblg.I_OpcionID,
							cp.clasificad, cp.clasific_5, CASE WHEN co_calc.I_OpcionID IS NULL THEN 0 ELSE 1 END, co_calc.I_OpcionID, CASE CAST(cp.ano AS int) WHEN 0 THEN 0 ELSE 1 END, 
							CASE CAST(cp.ano AS int) WHEN 0 THEN NULL ELSE CAST(cp.ano AS int) END, co_periodo.I_OpcionID, CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN 0 ELSE 1 END, 
							CASE LEN(LTRIM(RTRIM(cp.cod_rc))) WHEN 0 THEN NULL ELSE cp.cod_rc END, CASE LEN(LTRIM(RTRIM(cp.cod_dep_pl))) WHEN 0 THEN 0 ELSE 1 END, unfv_dep.I_DependenciaID, 
							CASE WHEN co_grpRc.I_OpcionID IS NULL THEN 0 ELSE 1 END, co_grpRc.I_OpcionID, CASE WHEN co_codIng.I_OpcionID IS NULL THEN 0 ELSE 1 END, co_codIng.I_OpcionID, 
							CASE cp.id_cp_agrp WHEN 0 THEN NULL ELSE 1 END, CASE cp.id_cp_agrp WHEN 0 THEN NULL ELSE cp.id_cp_agrp END, CASE cp.id_cp_afec WHEN 0 THEN NULL ELSE 1 END, 
							CASE cp.id_cp_afec WHEN 0 THEN NULL ELSE cp.id_cp_afec END, cp.nro_pagos, cp.porcentaje, 'PEN', cp.monto, cp.monto_min, cp.descrip_l, cp.documento, 1, 0, 0, NULL 							

					 FROM	temporal_pagos.dbo.cp_pri cp
							LEFT JOIN temporal_pagos.dbo.cp_des cd ON cp.cuota_pago = cd.CUOTA_PAGO AND Cd.eliminado = 0 
							LEFT JOIN TC_CatalogoOpcion co_tipoAlumno ON CAST(co_tipoAlumno.T_OpcionCod AS float) = cp.tip_alumno AND co_tipoAlumno.I_ParametroID = 1
							LEFT JOIN TC_CatalogoOpcion co_grado ON CAST(co_grado.T_OpcionCod AS float) = cp.grado AND co_grado.I_ParametroID = 2
							LEFT JOIN TC_CatalogoOpcion co_tipOblg ON CAST(co_tipOblg.T_OpcionCod AS bit) = cp.tipo_oblig AND co_tipOblg.I_ParametroID = 3
							LEFT JOIN TC_CatalogoOpcion co_calc ON co_calc.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.calcular COLLATE DATABASE_DEFAULT AND co_calc.I_ParametroID = 4
							LEFT JOIN TC_CatalogoOpcion co_periodo ON co_periodo.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.p COLLATE DATABASE_DEFAULT AND co_periodo.I_ParametroID = 5
							LEFT JOIN TC_CatalogoOpcion co_grpRc ON co_grpRc.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.grupo_rc COLLATE DATABASE_DEFAULT AND co_grpRc.I_ParametroID = 6
							LEFT JOIN TC_CatalogoOpcion co_codIng ON co_codIng.T_OpcionCod COLLATE DATABASE_DEFAULT = cp.cod_ing COLLATE DATABASE_DEFAULT AND co_codIng.I_ParametroID = 7
							LEFT JOIN TC_DependenciaUNFV unfv_dep on unfv_dep.C_DepCodPl COLLATE DATABASE_DEFAULT = cp.cod_dep_pl COLLATE DATABASE_DEFAULT AND LEN(unfv_dep.C_DepCodPl) > 0 
					 WHERE cd.cuota_pago IS not NULL
							AND NOT EXISTS (SELECT id_cp, descripcio, 0, ISNULL(eliminado, 0) FROM temporal_pagos.dbo.cp_pri B WHERE cp.ID_CP IN (3899,3898,3897,3896) AND cp.eliminado = 1)
					 ORDER BY id_cp

SET IDENTITY_INSERT TI_ConceptoPago OFF
GO



select len(null)
select * from TC_Parametro
select * from TC_CatalogoOpcion
 where I_ParametroID = 3

SELECT * FROM TC_DependenciaUNFV WHERE  C_DepCodPl = '03110OLFAC'

SELECT C_DepCodPl, COUNT(C_DepCodPl) FROM TC_DependenciaUNFV GROUP BY C_DepCodPl HAVING COUNT(C_DepCodPl) > 1



SELECT *
FROM	temporal_pagos.dbo.cp_pri cp 
LEFT JOIN temporal_pagos.dbo.cp_des cd on cp.cuota_pago = cd.CUOTA_PAGO AND Cd.eliminado = 0 
LEFT JOIN TC_DependenciaUNFV unfv_dep on unfv_dep.C_DepCodPl COLLATE DATABASE_DEFAULT = cp.cod_dep_pl COLLATE DATABASE_DEFAULT AND LEN(unfv_dep.C_DepCodPl) > 0 

WHERE unfv_dep.I_DependenciaID is null
  AND LEN(cod_dep_pl) > 0 	 

select count(*) from temporal_pagos..ec_pri --369787
select count(*) from temporal_pagos..ec_obl --708965
select count(*) from temporal_pagos..ec_det


select * from temporal_pagos..ec_pri ep
inner join temporal_pagos..ec_obl eo ON ep.COD_ALU = eo.COD_ALU and ep.COD_RC = eo.COD_RC AND ep.ANO = eo.ANO and ep.P = eo.p
--708812

select * from temporal_pagos..ec_pri ep
right join temporal_pagos..ec_obl eo ON ep.COD_ALU = eo.COD_ALU and ep.COD_RC = eo.COD_RC AND ep.ANO = eo.ANO and ep.P = eo.p
where ep.COD_ALU IS NULL


select * from temporal_pagos..ec_pri ep
right join temporal_pagos..ec_obl eo ON ep.COD_ALU = eo.COD_ALU and ep.COD_RC = eo.COD_RC AND ep.ANO = eo.ANO
where ep.COD_ALU IS NULL

select distinct tipo_oblig from temporal_pagos..ec_obl

SELECT id_cp, descripcio, * FROM cp_pri WHERE cuota_pago IN (
 '53'
,'54'
,'55'
,'56'
,'57'
,'58'
)


UPDATE cp_pri 
SET descripcio = 'ANAL.CLIN.' + SUBSTRING(descripcio, 11, LEN(descripcio)) FROM cp_pri
WHERE SUBSTRING(descripcio, 1, 10) = 'AN?L.CL?N.'

SELECT * FROM (select * from cp_des WHERE DESCRIPCIO LIKE '%OTR%') A
LEFT JOIN (select * from cp_des WHERE DESCRIPCIO LIKE '%OTR%REG%') B ON A.CUOTA_PAGO = B.CUOTA_PAGO
WHERE B.CUOTA_PAGO IS NULL


SELECT * FROM cp_pri WHERE cuota_pago IN (
31
,32
,33
,38
,39
,40
,43
,44
,45
,46
,143
,330
,331
,438
,439)



SELECT * FROM cp_des WHERE CUOTA_PAGO IN(
31
,32
,33
,38
,39
,40
,43
,44
,45
,46
,143
,330
,331
,438
,439)

SELECT * FROM TI_ConceptoPago

SELECT * FROM cp_pri ORDER BY id_cp ASC


select CUOTA_PAGO, COUNT(*) from cp_des GROUP BY CUOTA_PAGO HAVING COUNT(*) > 1

IF (ISNUMERIC('Y') = 1)
	PRINT('ES NUMERO')
ELSE
	PRINT('NO ES NUMERO')

SELECT CAST('-' AS numeric)

SELECT CUOTA_PAGO, DESCRIPCIO , SUBSTRING(LTRIM(DESCRIPCIO),1,4), SUBSTRING(LTRIM(DESCRIPCIO),5,1), 
	   LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO)))--, COUNT(*)
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 1 
	AND SUBSTRING(LTRIM(DESCRIPCIO),5,1) = ' '
--GROUP BY LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO)))--, PRIORIDAD
--ORDER BY 2 DESC

SELECT CUOTA_PAGO, DESCRIPCIO , SUBSTRING(LTRIM(DESCRIPCIO),1,4), SUBSTRING(LTRIM(DESCRIPCIO),5,1), 
		LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO)))--, COUNT(*)
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 1 
	AND ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,1))) = 1
--GROUP BY LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO)))
--ORDER BY 2 DESC

SELECT CUOTA_PAGO, DESCRIPCIO , SUBSTRING(LTRIM(DESCRIPCIO),1,4), SUBSTRING(LTRIM(DESCRIPCIO),5,1), 
		LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO)))--, COUNT(*)
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 0 
	AND SUBSTRING(LTRIM(DESCRIPCIO),5,1) <> ''
--GROUP BY LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO)))
--ORDER BY 2 DESC

SELECT COUNT(*) FROM cp_des

select SUBSTRING(LTRIM(DESCRIPCIO),1,4), SUBSTRING(LTRIM(DESCRIPCIO),5,1),SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO))  from cp_des

SELECT * FROM cp_pri
WHERE CUOTA_PAGO IN(
SELECT CUOTA_PAGO
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 0
)

SELECT * FROM ec_det 
WHERE ano is null


SELECT Concepto,ID_CP, P.DESCRIPCIO, D.Cuota_pago, CD.DESCRIPCIO, COUNT(Concepto)  FROM ec_det D
INNER JOIN cp_pri P ON D.Concepto = cast(P.ID_CP as varchar)
INNER JOIN cp_des CD ON cast(CD.CUOTA_PAGO as varchar) = D.Cuota_pago
GROUP BY Concepto,ID_CP, P.DESCRIPCIO, D.Cuota_pago, CD.DESCRIPCIO ORDER BY 1 DESC



SELECT D.DESCRIPCIO, P.DESCRIPCIO, O.* FROM ec_det O 
INNER JOIN cp_des D ON O.CUOTA_PAGO = cast(D.CUOTA_PAGO as varchar)
INNER JOIN cp_pri P ON cast(P.ID_CP as varchar) = O.Concepto
WHERE O.CUOTA_PAGO IN(
SELECT CUOTA_PAGO
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 1
)

select * from cp_des where CUOTA_PAGO = 491


SELECT ID_CP, P.DESCRIPCIO, cD.Cuota_pago, CD.DESCRIPCIO, COUNT(P.Cuota_pago)  FROM cp_pri P 
INNER JOIN cp_des CD ON CD.CUOTA_PAGO = P.Cuota_pago
GROUP BY ID_CP, P.DESCRIPCIO, CD.Cuota_pago, CD.DESCRIPCIO ORDER BY 3



SELECT * FROM ec_det 
WHERE Cuota_pago = 4 and Concepto = 9 ORDER BY Ano DESC

SELECT ID_CP, P.DESCRIPCIO, cD.Cuota_pago, CD.DESCRIPCIO, COUNT(P.Cuota_pago)  FROM cp_pri P 
INNER JOIN cp_des CD ON CD.CUOTA_PAGO = P.Cuota_pago
where CD.CUOTA_PAGO = 4
GROUP BY ID_CP, P.DESCRIPCIO, CD.Cuota_pago, CD.DESCRIPCIO ORDER BY 3

select * from ec_det
SELECT  *FROM cp_DES
SELECT * FROM cp_pri WHERE ELIMINADO = 1  --  ID_CP IN (3899,3898,3897,3896)
SELECT ID_CP, COUNT(ID_CP) FROM cp_pri GROUP BY ID_CP HAVING COUNT(ID_CP) > 1

select * from ec_det where cast(Concepto as int) in (select id_cp from cp_pri where ID_CP IN (3899,3898,3897,3896) AND ELIMINADO = 0) 

SELECT *  FROM ec_det WHERE Ano IN ('2019', '2020') ORDER BY cast(Concepto as int) ASC

SELECT * FROM ec_det WHERE CAST(Concepto AS INT) IN (3899,3898,3897,3896)

select distinct CAST(Concepto AS INT) from ec_det order by CAST(Concepto AS INT)

SELECT LTRIM(DESCRIPCIO), COUNT(*) as repetidos
FROM cp_pri
GROUP BY LTRIM(DESCRIPCIO)
ORDER BY 2 desc


SELECT * FROM cp_pri WHERE descripcio = 'DEPORTES'

SELECT id_cp, COUNT(*) as repetidos
FROM cp_pri
GROUP BY id_cp
having COUNT(*) > 1
ORDER BY 2 desc


SELECT DISTINCT LTRIM(DESCRIPCIO), ELIMINADO FROM cp_pri ORDER BY LTRIM(DESCRIPCIO)

SELECT * FROM TC_ConceptoPago W WHERE I_ConceptoID IN (3899,3898,3897,3896)

insert into TC_ConceptoPago (T_ConceptoDesc, B_Habilitado, B_Eliminado) values ('asdasdasd', 1, 0)

SELECT D.Concepto,D.Cuota_pago, T.N_Cta_Cte, D.P, D.Ano, D.Cod_Alu, T.Des_Pri, D.Fch_ec, D.Fch_Venc, Fch_pago, Nro_recibo, d.monto as Det_Monto, D.COD_RC, p.Tot_APagar,P.Tot_pagado, o.pagado, o.monto as Obl_Monto
FROM Ec_det D 
INNER JOIN (SELECT ID_CP, Clasificad, N_Cta_Cte, Cod_RC, Monto, CP_D.Descripcio +SPACE(1) + '|' + SPACE(1) + CP_P.Descripcio AS Des_Pri, Fraccionab, Cod_dep_pl, CP_D.Cuota_Pago, CP_P.Ano, CP_P.P
FROM cp_pri CP_P INNER JOIN CP_des CP_D ON CP_D.CUOTA_PAGO=CP_P.CUOTA_PAGO 
WHERE CP_P.Eliminado=0 AND CP_D.Eliminado=0
)
T ON T.ID_CP=D.Concepto AND T.Cuota_Pago=D.Cuota_Pago AND T.ano = D.ano AND T.p = D.p
INNER JOIN Ec_PRI P ON D.ano = P.ano AND D.p = P.p AND d.cod_rc=p.cod_rc AND D.Cod_Alu = P.Cod_Alu
INNER JOIN Ec_Obl O ON P.ano = O.ano AND P.p = O.p AND P.cod_rc = O.cod_rc AND P.cod_alu = O.Cod_alu AND O.cuota_pago = D.cuota_pago AND O.tipo_oblig = D.tipo_oblig AND O.fch_venc = D.fch_venc
WHERE P.Eliminado=0 AND D.Eliminado=0 AND D.p='A' and d.Ano IN ('2019', '2020')



DELETE TC_ConceptoPago
DBCC CHECKIDENT(TC_ConceptoPago, RESEED, 0)



