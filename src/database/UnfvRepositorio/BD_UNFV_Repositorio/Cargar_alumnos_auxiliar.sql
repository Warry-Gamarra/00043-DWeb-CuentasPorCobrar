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

INSERT INTO TC_Persona (C_NumDNI, C_CodTipDoc, T_ApePaterno, T_ApeMaterno, T_Nombre, C_Sexo, B_Habilitado, B_Eliminado, COD_ALU)
     SELECT DISTINCT C_numdni, C_codtipdoc, T_apepater, T_apemater, t_nombre, c_sexo, 1, 0, C_codalu FROM alu 
go

INSERT INTO TC_Alumno (C_RcCod, C_CodAlu, I_PersonaID, C_CodModIng, C_AnioIngreso, I_IdPlan, B_Habilitado, B_Eliminado) 
	 SELECT DISTINCT CP.C_RcCod, C.C_rccod, C.C_codalu, P.I_PersonaID, C.c_codmodig, C.c_anioingr, NULL, 1, 0 FROM alu C
	 INNER JOIN TC_Persona P ON C.C_codalu = P.COD_ALU
	 left JOIN TI_CarreraProfesional CP ON CP.C_RcCod = C.C_rccod
	 WHERE P.B_Eliminado = 0
go


ALTER TABLE TC_Persona
	DROP COLUMN COD_ALU
go

ALTER TABLE TC_Persona
	DROP COLUMN COD_RC
go




