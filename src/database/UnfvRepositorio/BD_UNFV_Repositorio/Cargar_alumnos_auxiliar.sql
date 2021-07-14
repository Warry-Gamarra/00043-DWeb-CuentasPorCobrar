use BD_UNFV_Repositorio
go

ALTER TABLE TC_Persona
	ADD COD_ALU varchar(20) NULL
go

ALTER TABLE TC_Persona
	ADD COD_RC varchar(10) NULL
go


--INSERT INTO TC_Persona (C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, COD_ALU, COD_RC)
--     SELECT DISTINCT DOC_IDEN#Column3, DOC_IDEN#Column2, NOM_PAT, NOM_MAT, NOM_NOM, SEXO, 1, 0, COD_ALU, COD_RC FROM Combinar 
--go

--SELECT COD_ALU 
--INTO ##tmp_codigosRepetidos
--FROM Combinar GROUP BY COD_ALU, COD_RC HAVING COUNT(COD_ALU) > 1 AND COUNT(COD_RC) > 1
--go

--INSERT INTO TC_Alumno (C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado) 
--	 SELECT DISTINCT C.COD_RC, C.COD_ALU, P.I_PersonaID, C.COD_ING, C.ANO_ING, NULL, 1, 0 FROM Combinar C
--	 INNER JOIN TC_Persona P ON C.COD_ALU = P.COD_ALU AND C.COD_RC = P.COD_RC
--	 INNER JOIN TI_CarreraProfesional CP ON CP.C_RcCod = C.COD_RC
--	 WHERE P.B_Eliminado = 0 AND C.COD_ALU NOT IN (select COD_ALU from ##tmp_codigosRepetidos)
--go


--DELETE TC_Alumno
--DELETE TC_Persona

--DBCC CHECKIDENT(TC_Persona, RESEED, 0)

INSERT INTO TC_Persona (C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, COD_ALU, COD_RC)
     SELECT DISTINCT C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, c_sexo, 1, 0, C.C_CodAlu, C.C_RcCod FROM alumnos_temporal C
	 	 INNER JOIN (SELECT  C_RcCod, C_CodAlu, id_plan FROM doctorado
				 UNION SELECT  C_RcCod, C_CodAlu, id_plan FROM maestria) APTOS ON C.C_codalu = APTOS.C_CodAlu AND APTOS.C_RcCod = C.C_RcCod
go

INSERT INTO TC_Alumno (C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado) 
	 SELECT DISTINCT CP.C_RcCod, C.C_CodAlu, P.I_PersonaID, C.C_CodModIng, C.C_AnioIngreso, APTOS.id_plan, 1, 0 FROM alumnos_temporal C
	 INNER JOIN TC_Persona P ON C.C_codalu = P.COD_ALU AND P.COD_RC = C.C_RcCod
	 INNER JOIN TI_CarreraProfesional CP ON CP.C_RcCod = C.C_rccod
	 INNER JOIN TC_ModalidadIngreso MI ON C.C_CodModIng = MI.C_CodModIng
	 INNER JOIN (SELECT  C_RcCod, C_CodAlu, id_plan FROM doctorado
				 UNION SELECT  C_RcCod, C_CodAlu, id_plan FROM maestria) APTOS ON C.C_codalu = APTOS.C_CodAlu AND APTOS.C_RcCod = C.C_RcCod
	 WHERE P.B_Eliminado = 0

	 --AND C_CodAlu NOT IN (
		--'0004030902',
		--'0008495851',
		--'000B021024',
		--'000B022515',
		--'0009812424',
		--'0008617748',
		--'009191413M',
		--'1999155112')
go

/*
Se encontró en la data de alumno_temporal:
- CODIGOS DE INGRESO QUE NO EXISTEN EN EL CATALOGO
- CODIGOS DE CARRERAS PROFESIONALES QUE NO SE ENCUENTRAN EN EL CATALOGO
- CODIGOS REPETIDOS CON DIFERENTE ESPECIALIDAD PARA DIFERENTES PERSONAS, 
- CODIGOS REPETIDOS CON DIFERENTE ESPECIALIDAD PARA LA MISMA PERSONA, 
- SOLO SE IMPORTÓ DATA DE POSTGRADO
*/

/*IMPORTACION PREGRADO */

INSERT INTO TC_Persona (C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, COD_ALU, COD_RC)
     SELECT DISTINCT C_NUMDNI, C_CODTIPDO, T_APEPATER, T_APEMATER, T_NOMBRE, C_SEXO, 1, 0, C_CODALU, C.C_RcCod FROM alumnos2 C
	 	 INNER JOIN pregrado APTOS ON C.C_CODALU = APTOS.COD_ALU AND APTOS.COD_RC = C.C_RcCod
go

INSERT INTO TC_Alumno (C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado) 
	 SELECT DISTINCT CP.C_RcCod, APTOS.COD_ALU, P.I_PersonaID, APTOS.COD_ING, APTOS.ANO_ING, APTOS.ID_PLAN, 1, 0 FROM pregrado APTOS
	 INNER JOIN TC_Persona P ON APTOS.COD_ALU = P.COD_ALU AND P.COD_RC = APTOS.COD_RC
	 INNER JOIN TI_CarreraProfesional CP ON CP.C_RcCod = APTOS.COD_RC
	 INNER JOIN TC_ModalidadIngreso MI ON APTOS.COD_ING = MI.C_CodModIng
	 WHERE P.B_Eliminado = 0



ALTER TABLE TC_Persona
	DROP COLUMN COD_ALU
go

ALTER TABLE TC_Persona
	DROP COLUMN COD_RC
go




