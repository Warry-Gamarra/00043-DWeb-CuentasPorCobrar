USE BD_OCEF_CtasPorCobrar
GO


ALTER TABLE dbo.TR_ObligacionAluCab ADD B_EsAmpliacionCred BIT DEFAULT 0;
GO

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 0;
GO

ALTER TABLE dbo.TR_ObligacionAluCab ALTER COLUMN B_EsAmpliacionCred BIT NOT NULL;
GO



--AMPLIACIÓN DE CRÉDITOS: VARGAS COCHACHIN, DIANA EMPERATRIZ
UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 544 AND I_MatAluID = 523132 AND I_MontoOblig = 250 AND D_FecVencto = '20230916' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523132 AND I_MontoOblig = 325 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523132 AND I_MontoOblig = 325 AND D_FecVencto = '20231015' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523132 AND I_MontoOblig = 325 AND D_FecVencto = '20231115' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523132 AND I_MontoOblig = 325 AND D_FecVencto = '20231215' AND B_Habilitado = 1 AND B_Eliminado = 0;
GO



--AMPLIACIÓN DE CRÉDITOS: ZEVALLOS PIZAN, VILMA GREGORIA
UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 544 AND I_MatAluID = 523134 AND I_MontoOblig = 250 AND D_FecVencto = '20230916' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523134 AND I_MontoOblig = 325 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523134 AND I_MontoOblig = 325 AND D_FecVencto = '20231015' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523134 AND I_MontoOblig = 325 AND D_FecVencto = '20231115' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523134 AND I_MontoOblig = 325 AND D_FecVencto = '20231215' AND B_Habilitado = 1 AND B_Eliminado = 0;
GO



--AMPLIACIÓN DE CRÉDITOS: AGUIRRE VEIZAGA, GLADYS
UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 542 AND I_MatAluID = 523003 AND I_MontoOblig = 225 AND D_FecVencto = '20230930' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523003 AND I_MontoOblig = 150 AND D_FecVencto = '20231015' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523003 AND I_MontoOblig = 150 AND D_FecVencto = '20231115' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523003 AND I_MontoOblig = 150 AND D_FecVencto = '20231215' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523003 AND I_MontoOblig = 150 AND D_FecVencto = '20240115' AND B_Habilitado = 1 AND B_Eliminado = 0;
GO



--AMPLIACIÓN DE CRÉDITOS: MARES SALAS MIGUEL ANGEL ODION
UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 544 AND I_MatAluID = 523508 AND I_MontoOblig = 250 AND D_FecVencto = '20230916' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523508 AND I_MontoOblig = 325 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523508 AND I_MontoOblig = 325 AND D_FecVencto = '20231015' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523508 AND I_MontoOblig = 325 AND D_FecVencto = '20231115' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 545 AND I_MatAluID = 523508 AND I_MontoOblig = 325 AND D_FecVencto = '20231215' AND B_Habilitado = 1 AND B_Eliminado = 0;
GO



--AMPLIACIÓN DE CRÉDITOS: ALBURQUEQUE CARRASCO, GERALDINE SENAIDA
UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 542 AND I_MatAluID = 523049 AND I_MontoOblig = 125 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523049 AND I_MontoOblig = 150 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523049 AND I_MontoOblig = 150 AND D_FecVencto = '20231015' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523049 AND I_MontoOblig = 150 AND D_FecVencto = '20231115' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523049 AND I_MontoOblig = 150 AND D_FecVencto = '20231215' AND B_Habilitado = 1 AND B_Eliminado = 0;
GO



--AMPLIACIÓN DE CRÉDITOS: ROMERO HAYASHI, MARCO ANTONIO
UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 542 AND I_MatAluID = 523047 AND I_MontoOblig = 125 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523047 AND I_MontoOblig = 150 AND D_FecVencto = '20230915' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523047 AND I_MontoOblig = 150 AND D_FecVencto = '20231015' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523047 AND I_MontoOblig = 150 AND D_FecVencto = '20231115' AND B_Habilitado = 1 AND B_Eliminado = 0;

UPDATE dbo.TR_ObligacionAluCab SET B_EsAmpliacionCred = 1 
WHERE I_ProcesoID = 543 AND I_MatAluID = 523047 AND I_MontoOblig = 150 AND D_FecVencto = '20231215' AND B_Habilitado = 1 AND B_Eliminado = 0;
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ObtenerFechaVencimientoObligacion')
	DROP PROCEDURE [dbo].[USP_S_ObtenerFechaVencimientoObligacion]
GO

CREATE PROCEDURE [dbo].[USP_S_ObtenerFechaVencimientoObligacion]
@I_ProcesoID INT
AS
--EXEC USP_S_ObtenerFechaVencimientoObligacion @I_ProcesoID = 542
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT c.D_FecVencto FROM dbo.TR_ObligacionAluCab c
	WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND c.B_Pagado = 0 AND c.B_EsAmpliacionCred = 0
	ORDER BY c.D_FecVencto;
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarFechaVencimientoObligaciones')
	DROP PROCEDURE [dbo].[USP_U_ActualizarFechaVencimientoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_U_ActualizarFechaVencimientoObligaciones]
@D_NewFecVencto DATE,
@D_OldFecVencto DATE,
@I_ProcesoID INT,
@I_UsuarioMod INT,
@B_Result BIT OUTPUT,
@T_Message VARCHAR(255) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRAN
	BEGIN TRY
		UPDATE c SET c.D_FecVencto = @D_NewFecVencto FROM dbo.TR_ObligacionAluCab c 
		WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_ProcesoID  = @I_ProcesoID AND
			DATEDIFF(DAY, c.D_FecVencto, @D_OldFecVencto) = 0 AND c.B_EsAmpliacionCred = 0;

		UPDATE d SET d.D_FecVencto = @D_NewFecVencto FROM dbo.TR_ObligacionAluCab c
		INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
		WHERE d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND 
			DATEDIFF(DAY, d.D_FecVencto, @D_OldFecVencto) = 0 AND c.B_EsAmpliacionCred = 0;

		COMMIT TRAN

		SET @B_Result = 1
		SET @T_Message = 'Actualización correcta'
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0
		SET @T_Message = ERROR_MESSAGE()
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarProceso')
	DROP PROCEDURE [dbo].[USP_U_ActualizarProceso]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.USP_U_ActualizarProceso
	@I_ProcesoID int,  
	@I_CatPagoID int,  
	@I_Anio smallint = null,  
	@D_FecVencto datetime = null,  
	@I_Prioridad tinyint = null,  
	@N_CodBanco varchar(10) = null,  
	@T_ProcesoDesc varchar(250) = null,  
	@B_Habilitado bit,  
	@I_UsuarioMod int,  
	@B_EditarFecha bit,  
	@I_CuotaPagoID INT = NULL,
	@B_Result bit OUTPUT,  
	@T_Message nvarchar(4000) OUTPUT  
AS  
BEGIN  
	SET NOCOUNT ON;
	
	BEGIN TRAN
	
	BEGIN TRY
		DECLARE @CurrentDate datetime = getdate();
  
		UPDATE dbo.TC_Proceso SET  
			I_CatPagoID = @I_CatPagoID,   
			I_Anio = @I_Anio,   
			D_FecVencto = @D_FecVencto,   
			I_Prioridad = @I_Prioridad,  
			N_CodBanco = @N_CodBanco,  
			T_ProcesoDesc = @T_ProcesoDesc,  
			B_Habilitado = @B_Habilitado,  
			I_UsuarioMod = @I_UsuarioMod,  
			D_FecMod = @CurrentDate,
			I_CuotaPagoID = @I_CuotaPagoID
		WHERE I_ProcesoID = @I_ProcesoID;
    
		IF (@B_EditarFecha = 1) BEGIN  
  
			UPDATE det SET det.D_FecVencto = @D_FecVencto, I_UsuarioMod = @I_UsuarioMod, D_FecMod = @CurrentDate   
			FROM dbo.TR_ObligacionAluCab cab  
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
			WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.B_Pagado = 0 AND det.B_Pagado = 0 AND cab.I_ProcesoID = @I_ProcesoID AND cab.B_EsAmpliacionCred = 0;
  
			UPDATE cab SET cab.D_FecVencto = @D_FecVencto, I_UsuarioMod = @I_UsuarioMod, D_FecMod = @CurrentDate  
			FROM dbo.TR_ObligacionAluCab cab  
			WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.B_Pagado = 0 AND cab.I_ProcesoID = @I_ProcesoID AND cab.B_EsAmpliacionCred = 0;
		END  
  
		COMMIT TRAN

		SET @B_Result = 1;
		SET @T_Message = 'Actualización de datos correcta.';
	END TRY  
	BEGIN CATCH  
		ROLLBACK TRAN

		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10));
	END CATCH  
END  
GO
