USE BD_OCEF_MigracionTP
GO

IF EXIStS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cp_des')
BEGIN
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cp_des' AND COLUMN_NAME = 'B_Migrado')
		ALTER TABLE cp_des ADD B_Migrado  bit  NOT NULL DEFAULT 0;
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cp_des' AND COLUMN_NAME = 'T_Observacion')
		ALTER TABLE cp_des ADD T_Observacion  bit  NULL DEFAULT 0;
END
ELSE
BEGIN
	PRINT 'No se encontró la tabla "cp_des" requerida para el proceso de migración.' + char(13)+CHAR(10) +
		 'Debe importar el archivo "cp_des.dbf" o "cp_des.xlsx" desde el asistente de importación de sql y renombar la tabla importada como "cp_des".'
END
GO


IF EXIStS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cp_pri')
BEGIN
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cp_pri' AND COLUMN_NAME = 'B_Migrado')
		ALTER TABLE cp_pri ADD B_Migrado  bit  NOT NULL DEFAULT 0;
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'cp_pri' AND COLUMN_NAME = 'T_Observacion')
		ALTER TABLE cp_pri ADD T_Observacion  bit  NOT NULL DEFAULT 0;
END
ELSE
BEGIN
	PRINT 'No se encontró la tabla "cp_pri" requerida para el proceso de migración.' + char(13)+CHAR(10) +
		 'Debe importar el archivo "cp_pri.dbf" o "cp_pri.xlsx" desde el asistente de importación de sql y renombar la tabla importada como "cp_pri".'
END
GO
