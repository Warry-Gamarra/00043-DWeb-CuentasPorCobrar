/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Inserta todos los valores de la tabla cp_pri a la tabla TC_ConceptoPago excepto los ID_CP 3899,3898,3897,3896 con estado Eliminado = 1 por estar repetidos 
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

DECLARE @max_id int

SET IDENTITY_INSERT TC_ConceptoPago ON

INSERT INTO TC_ConceptoPago (I_ConceptoID, T_ConceptoDesc, B_Habilitado, B_Eliminado)
				SELECT ID_CP, DESCRIPCIO, 0, ISNULL(ELIMINADO, 0) FROM cp_pri A
				WHERE NOT EXISTS (SELECT ID_CP, DESCRIPCIO, 0, ISNULL(ELIMINADO, 0) FROM CP_PRI B WHERE A.ID_CP IN (3899,3898,3897,3896) AND A.ELIMINADO = 1)  
				ORDER BY A.ID_CP ASC

SET IDENTITY_INSERT TC_ConceptoPago OFF

SET @max_id = (SELECT ISNULL(MAX(I_ConceptoID),0) FROM TC_ConceptoPago)

DBCC CHECKIDENT(TC_ConceptoPago, RESEED, @max_id)

GO


/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Inserta todos los valores de la tabla cp_des a la tabla TC_TipoPeriodo  
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO TC_TipoPeriodo (T_TipoPerDesc, I_Prioridad, B_Habilitado, B_Eliminado)
SELECT DESCRIP AS T_TipoPerDesc, NULL AS I_Prioridad, 1 AS B_Habilitado, 0 AS B_Eliminado FROM (
SELECT DISTINCT LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO))) AS DESCRIP
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 1 
	AND SUBSTRING(LTRIM(DESCRIPCIO),5,1) = ' '
UNION
SELECT DISTINCT LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO))) AS DESCRIP
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 1 
	AND SUBSTRING(LTRIM(DESCRIPCIO),5,1) <> ''
UNION
SELECT DISTINCT LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),5,LEN(DESCRIPCIO))) AS DESCRIP
FROM cp_des
WHERE ISNUMERIC(LTRIM(SUBSTRING(LTRIM(DESCRIPCIO),1,4))) = 0 
	AND SUBSTRING(LTRIM(DESCRIPCIO),5,1) <> ''
) TIPO_PERIODO
ORDER BY DESCRIP ASC
