/*
USE [master]
GO
ALTER DATABASE [BD_UNFV_Repositorio] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [BD_UNFV_Repositorio]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_UNFV_Repositorio_20240516.bak' WITH FILE = 1, 
     MOVE N'BD_UNFV_Repositorio' TO N'F:\Microsoft SQL Server\DATA\BD_UNFV_Repositorio.mdf', 
     MOVE N'BD_UNFV_Repositorio_log' TO N'F:\Microsoft SQL Server\DATA\BD_UNFV_Repositorio_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;

ALTER DATABASE [BD_UNFV_Repositorio] SET MULTI_USER;
GO

USE BD_UNFV_Repositorio
GO

DROP USER [UserUNFV];
DROP USER [UserOCEF];
DROP USER [uweb_general]; 
CREATE USER [UserOCEF] FOR LOGIN [UserOCEF] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE [db_owner] ADD MEMBER [UserOCEF];
GO
---------------------------------------------------------------------------------------------------------------------
USE [master]
GO
ALTER DATABASE [BD_OCEF_CtasPorCobrar] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [BD_OCEF_CtasPorCobrar]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_OCEF_CtasPorCobrar_20240516.bak' WITH FILE = 1, 
     MOVE N'BD_OCEF_CtasPorCobrar' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar.mdf', 
     MOVE N'BD_OCEF_CtasPorCobrar_log' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;

ALTER DATABASE [BD_OCEF_CtasPorCobrar] SET MULTI_USER;
GO

USE BD_OCEF_CtasPorCobrar
GO

DROP USER [UserUNFV];
DROP USER [UserOCEF];
DROP USER [uweb_general]; 
CREATE USER [UserOCEF] FOR LOGIN [UserOCEF] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE [db_owner] ADD MEMBER [UserOCEF];
GO
*/
USE BD_OCEF_CtasPorCobrar
GO

/*
Modificar para:
--Se registren pagos con tasas no registradas en el sistema (Comercio)
--Se registren pagos con códigos de servicio no registrado en el sistema (Comercio)
--Crear nuevas observaciones para los 2 casos anteriores.
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
@Tbl_Pagos [dbo].[type_dataPagoTasa] READONLY,
@Observacion VARCHAR(250),
@D_FecRegistro DATETIME,
@UserID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Tmp_PagoTasas TABLE (
		id INT identity(1,1),
		I_TasaUnfvID INT,
		I_MontoTasa DECIMAL(15,2),
		C_CodDepositante VARCHAR(20),
		T_NomDepositante VARCHAR(200),
		C_CodTasa VARCHAR(20),
		T_TasaDesc VARCHAR(250),
		C_CodOperacion VARCHAR(50),
		C_Referencia VARCHAR(50),
		I_EntidadFinanID INT,
		I_CtaDepositoID INT,
		D_FecPago DATETIME,
		I_Cantidad INT,
		C_Moneda VARCHAR(3),
		I_MontoPago DECIMAL(15,2),
		I_InteresMora DECIMAL(15,2),
		T_LugarPago VARCHAR(250),
		T_InformacionAdicional VARCHAR(250),
		B_Success BIT,
		T_ErrorMessage VARCHAR(250),
		C_CodigoInterno VARCHAR(250),
		T_SourceFileName VARCHAR(250),
		C_Extorno VARCHAR(1),
		C_CodServicio VARCHAR(20)
	);

	INSERT @Tmp_PagoTasas(I_TasaUnfvID, I_MontoTasa, C_CodDepositante, T_NomDepositante, C_CodTasa,
		T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, D_FecPago,
		I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional,
		C_CodigoInterno, T_SourceFileName, C_Extorno, C_CodServicio)
	SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,
		CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,
		p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID, p.I_CtaDepositoID, p.D_FecPago,
		p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional,
		p.C_CodigoInterno, p.T_SourceFileName, C_Extorno, p.C_CodServicio
	FROM @Tbl_Pagos p
	LEFT JOIN dbo.TI_TasaUnfv t ON t.C_CodTasa = p.C_CodTasa AND t.B_Habilitado = 1 AND t.B_Eliminado = 0;
    
	DECLARE @I_FilaActual  INT = 1,    
		@I_CantRegistros INT = (SELECT COUNT(id) FROM @Tmp_PagoTasas),    
		@I_SaldoAPagar  DECIMAL(15,2),    
		@I_PagoDemas  DECIMAL(15,2),    
		@B_PagoDemas  BIT,    
		@I_CantCuentasBancarias INT,
		-----------------------------------------------------------    
		@I_PagoBancoID  INT,    
		@I_TasaUnfvID  INT,    
		@I_MontoTasa  DECIMAL(15,2),    
		@C_CodDepositante VARCHAR(20),    
		@T_NomDepositante VARCHAR(200),    
		@C_CodTasa   VARCHAR(20),    
		@T_TasaDesc   VARCHAR(250),    
		@C_CodOperacion  VARCHAR(50),    
		@C_Referencia  VARCHAR(50),    
		@I_EntidadFinanID INT,    
		@I_CtaDepositoID INT,    
		@D_FecPago   DATETIME,    
		@I_Cantidad   INT,    
		@C_Moneda   VARCHAR(3),    
		@I_MontoPago  DECIMAL(15,2),    
		@I_InteresMora  DECIMAL(15,2),    
		@T_LugarPago  VARCHAR(250),     
		@T_InformacionAdicional VARCHAR(250),    
		@C_CodigoInterno VARCHAR(250),  
		@B_ExisteError  BIT,    
		@B_CodOpeCorrecto BIT,    
		@C_Extorno VARCHAR(1),
		@C_CodServicio VARCHAR(20),
		@I_CondicionPagoID INT,
		--Constantes    
		@CondicionCorrecto INT = 131,--CONDICIÓN: PAGO CORRECTO
		@Extornado INT = 132,--CONDICIÓN: EXTORNO
		@PagoTipoTasa  INT = 134;--TIPO PAGO: TASA

	WHILE (@I_FilaActual <= @I_CantRegistros)
	BEGIN    
      
		SET @B_ExisteError = 0;
    
		SELECT  
			@I_TasaUnfvID = I_TasaUnfvID,
			@I_MontoTasa = I_MontoTasa,
			@C_CodDepositante = C_CodDepositante,
			@T_NomDepositante = T_NomDepositante,
			@C_CodTasa = C_CodTasa,
			@T_TasaDesc = T_TasaDesc,
			@C_CodOperacion = C_CodOperacion,
			@C_Referencia = C_Referencia,
			@I_EntidadFinanID = I_EntidadFinanID,
			@I_CtaDepositoID = I_CtaDepositoID,
			@D_FecPago = D_FecPago,
			@I_Cantidad = I_Cantidad,
			@C_Moneda = C_Moneda,
			@I_MontoPago = I_MontoPago,
			@I_InteresMora = I_InteresMora,
			@T_LugarPago = T_LugarPago,
			@T_InformacionAdicional = T_InformacionAdicional,
			@C_CodigoInterno = C_CodigoInterno,
			@C_Extorno = C_Extorno,
			@C_CodServicio = C_CodServicio
		FROM @Tmp_PagoTasas WHERE id = @I_FilaActual    
    
		IF (@I_TasaUnfvID IS NULL) BEGIN
			IF (@I_EntidadFinanID = 2) BEGIN
				SELECT @I_TasaUnfvID = t.I_TasaUnfvID, @I_CtaDepositoID = t.I_CtaDepositoID 
				FROM VW_PagoTasas_X_Cuenta t
				WHERE t.C_CodTasa = '00000' AND t.I_EntidadFinanID = 2;
			END
			ELSE BEGIN
				SET @B_ExisteError = 1;

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'No existe el código de tasa.' WHERE id = @I_FilaActual;
			END
		END
    
		IF (@B_ExisteError = 0 AND @I_CtaDepositoID IS NULL) BEGIN
			SET @I_CantCuentasBancarias = (SELECT COUNT(I_CtaDepositoID) FROM VW_PagoTasas_X_Cuenta 
				WHERE C_CodTasa = @C_CodTasa AND C_CodServicio = @C_CodServicio AND I_EntidadFinanID = @I_EntidadFinanID);

			IF (@I_CantCuentasBancarias = 0) BEGIN
				SET @B_ExisteError = 1;

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Esta tasa no tiene asignado una cuenta.' WHERE id = @I_FilaActual;
			END

			IF (@I_CantCuentasBancarias = 1) BEGIN
				SET @I_CtaDepositoID = (SELECT I_CtaDepositoID FROM VW_PagoTasas_X_Cuenta
					WHERE C_CodTasa = @C_CodTasa AND C_CodServicio = @C_CodServicio AND I_EntidadFinanID = @I_EntidadFinanID);
			END

			IF (@I_CantCuentasBancarias > 1) BEGIN
				SET @B_ExisteError = 1;

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Existe más de una cuenta bancaria para este servicio y tasa.' WHERE id = @I_FilaActual;
			END
		END
    
		IF  (@B_ExisteError = 0) BEGIN
			EXEC USP_S_ValidarCodOperacionTasa @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT;
    
			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1;
        
				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual;
			END
		END
    
		IF (@B_ExisteError = 0)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
  
				SET @I_CondicionPagoID = (CASE WHEN @C_Extorno = 'E' THEN @Extornado ELSE @CondicionCorrecto END);
  
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,
					@T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoTasa, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno);
    
				SET @I_PagoBancoID = SCOPE_IDENTITY();
  
				IF (@I_CondicionPagoID = @CondicionCorrecto)
				BEGIN
					--Pago menor    
					SET @I_SaldoAPagar = @I_MontoTasa - @I_MontoPago;
     
					SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END;
    
					--Pago excedente    
					SET @I_PagoDemas = @I_MontoPago - @I_MontoTasa;
         
					SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END;
    
					SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END;
    
					INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_TasaUnfvID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,
						B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
					VALUES(@I_PagoBancoID, @I_TasaUnfvID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas,
						@B_PagoDemas, @D_FecRegistro, @UserID, 0, @I_CtaDepositoID);
  
					UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual;
				END
				ELSE BEGIN
					UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto (Extorno).' WHERE id = @I_FilaActual;
				END

				COMMIT TRANSACTION;
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION;
    
				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual;
			END CATCH
		END
    
		SET @I_FilaActual = @I_FilaActual + 1;
	END    
    
	SELECT * FROM @Tmp_PagoTasas;
END  
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_IU_GenerarObligacionesPregrado_X_Ciclo]
@I_Anio INT,
@I_Periodo INT,
@B_AlumnosSinObligaciones BIT,
@C_CodFac VARCHAR(2) = NULL,
@C_CodAlu VARCHAR(20) = NULL,
@C_CodRc VARCHAR(3) = NULL,
@B_Ingresante BIT = NULL,
@B_SoloAplicarExtemporaneo BIT = NULL,
@I_UsuarioCre INT,  
@B_Result BIT OUTPUT,  
@T_Message NVARCHAR(4000) OUTPUT  
AS
/*  
  
DECLARE @B_Result BIT,  
  @T_Message NVARCHAR(4000)  
  
exec USP_IU_GenerarObligacionesPregrado_X_Ciclo @I_Anio = 2021, @I_Periodo = 15,   
@C_CodFac = NULL, @C_CodAlu = NULL, @C_CodRc = NULL, @I_UsuarioCre = 1,  
@B_Result = @B_Result OUTPUT,  
@T_Message = @T_Message OUTPUT  
go  
  
*/
BEGIN  
 SET NOCOUNT ON;  
  SET @B_SoloAplicarExtemporaneo = CASE WHEN @B_SoloAplicarExtemporaneo IS NULL THEN 0 ELSE @B_SoloAplicarExtemporaneo END;
 --1ro Obtener los conceptos según año y periodo  
 DECLARE @N_GradoBachiller CHAR(1) = '1'  
 DECLARE @D_CurrentDate DATETIME = GETDATE();
  
 SELECT 
	p.I_ProcesoID, p.D_FecVencto,
	CASE WHEN p.D_FecVenctoExt IS NOT NULL THEN (CASE WHEN DATEDIFF(DAY, @D_CurrentDate, p.D_FecVencto) >=0 THEN p.D_FecVencto ELSE p.D_FecVenctoExt END) ELSE p.D_FecVencto END AS D_FecVenctoRegistro,
    cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,  
	ISNULL(conpag.B_Calculado, 0) AS B_Calculado, conpag.I_Calculado, ISNULL(conpag.B_GrupoCodRc, 0) AS B_GrupoCodRc, gr.T_OpcionCod AS I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng,   
	ISNULL(conpag.B_EsPagoMatricula, 0) AS B_EsPagoMatricula, ISNULL(con.B_EsPagoExtmp, 0) AS B_EsPagoExtmp, conpag.N_NroPagos, cp.I_Prioridad  
 INTO #tmp_conceptos_pregrado  
 FROM dbo.TC_Proceso p  
 INNER JOIN dbo.TC_CategoriaPago cp ON cp.I_CatPagoID = p.I_CatPagoID  
 INNER JOIN dbo.TI_ConceptoPago conpag ON conpag.I_ProcesoID = p.I_ProcesoID  
 INNER JOIN dbo.TC_Concepto con ON con.I_ConceptoID = conpag.I_ConceptoID  
 LEFT JOIN dbo.TC_CatalogoOpcion moding ON moding.I_ParametroID = 7 AND moding.I_OpcionID = conpag.I_ModalidadIngresoID  
 LEFT JOIN dbo.TC_CatalogoOpcion gr ON gr.I_ParametroID = 6 AND gr.I_OpcionID = conpag.I_GrupoCodRc  
 WHERE p.B_Habilitado = 1 AND p.B_Eliminado = 0 AND  
  conpag.B_Habilitado = 1 AND conpag.B_Eliminado = 0 AND ISNULL(conpag.B_Mora, 0) = 0 AND  
  cp.B_Obligacion = 1 AND p.I_Anio = @I_Anio AND p.I_Periodo = @I_Periodo AND cp.I_Nivel = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 2 AND T_OpcionCod = @N_GradoBachiller)  
  
 --2do Obtengo la relación de alumnos  
	CREATE TABLE #Tmp_MatriculaAlumno (
		id INT IDENTITY(1,1), 
		I_MatAluID INT, 
		C_CodRc VARCHAR(3), 
		C_CodAlu VARCHAR(20), 
		C_EstMat VARCHAR(2), 
		B_Ingresante BIT, 
		C_CodModIng VARCHAR(2), 
		N_Grupo CHAR(1), 
		I_CredDesaprob TINYINT
	)
         
	DECLARE	@SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500)

	SET @SQLString = N'INSERT #Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
	SELECT m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0)
	FROM dbo.TC_MatriculaAlumno m
	INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRc
	WHERE m.B_Habilitado = 1 AND m.B_Eliminado = 0 and
	a.N_Grado = @N_GradoBachiller AND m.I_Anio = @I_Anio AND m.I_Periodo = @I_Periodo ';

	IF (@C_CodAlu is not NULL) AND (@C_CodRc is not NULL) BEGIN
		SET @SQLString = @SQLString + N'AND m.C_CodAlu = @C_CodAlu AND m.C_CodRc = @C_CodRc '
	END ELSE BEGIN
		IF NOT(@C_CodFac is NULL) AND NOT(@C_CodFac = '') BEGIN
			SET @SQLString = @SQLString + N'AND a.C_CodFac = @C_CodFac '
		END
	END

	IF (@B_Ingresante IS NOT NULL) BEGIN
		SET @SQLString = @SQLString + N'AND m.B_Ingresante = @B_Ingresante '
	END

	IF (@B_AlumnosSinObligaciones = 1) BEGIN
		SET @SQLString = @SQLString + N'AND NOT EXISTS(SELECT c.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab c WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_MatAluID = m.I_MatAluID) '
	END

	SET @ParmDefinition = N'@N_GradoBachiller CHAR(1), @I_Anio INT, @I_Periodo INT, @C_CodAlu VARCHAR(20), 
		@C_CodRc VARCHAR(3), @C_CodFac VARCHAR(2), @B_Ingresante BIT'
  
	EXECUTE SP_EXECUTESQL @SQLString, @ParmDefinition,  
		@N_GradoBachiller = @N_GradoBachiller,  
		@I_Anio = @I_Anio,  
		@I_Periodo = @I_Periodo,  
		@C_CodAlu = @C_CodAlu,  
		@C_CodRc = @C_CodRc,
		@C_CodFac = @C_CodFac,
		@B_Ingresante = @B_Ingresante

 --3ro Comienzo con el calculo las obligaciones por alumno almacenandolas en @Tmp_Procesos.  
 DECLARE @Tmp_Procesos TABLE (I_ProcesoID INT, I_ConcPagID INT, M_Monto DECIMAL(15,2), D_FecVencto DATETIME, I_TipoObligacion INT, I_Prioridad TINYINT)  
  
 DECLARE @C_Moneda VARCHAR(3) = 'PEN',  
   @I_FilaActual INT = 1,  
   @I_CantRegistros INT = (SELECT MAX(id) FROM #Tmp_MatriculaAlumno),  
     
   --Tipo de alumno  
   @I_AlumnoRegular INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 1 AND T_OpcionCod = '1'),  
   @I_AlumnoIngresante INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 1 AND T_OpcionCod = '2'),  
     
   --Tipo obligación  
   @I_Matricula INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 3 AND T_OpcionCod = '1'),  
   @I_OtrosPagos INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 3 AND T_OpcionCod = '0'),  
  
   --Campo calculado  
   @I_CrdtDesaprobados INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4 AND T_OpcionCod = '1'),  
   @I_DeudasAnteriores INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4 AND T_OpcionCod = '2'),  
   @I_Pensiones INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4 AND T_OpcionCod = '3'),  
   @I_MultaNoVotar INT = (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4 AND T_OpcionCod = '4'),  
     
   --Otras variables  
   @I_ObligacionAluID INT,  
   @I_MatAluID INT,  
   @C_EstMat VARCHAR(2),  
   @C_CodModIng VARCHAR(2),  
   @N_Grupo CHAR(1),  
   @I_TipoAlumno INT,  
   @I_MontoDeuda DECIMAL(15,2),  
   @I_CredDesaprob TINYINT,  
   @I_MultiplicMontoCredt INT,  
   @N_NroPagos TINYINT,
   @I_ObligacionAluDetID INT,
   @I_ConcPagID INT,
  
   --Variables para comprobar modificaciones  
   @I_MontoInicial DECIMAL(15,2),  
   @I_MontoActual DECIMAL(15,2),  
   @D_FecVenctoInicial DATETIME,  
   @D_FecVenctoActual DATETIME,  
   @I_ProcesoID INT,  
   @B_Pagado BIT  
  
 DECLARE @Tmp_grupo_otros_pagos TABLE (id INT, I_ProcesoID INT)  
 DECLARE @I_FilaActual_OtrsPag INT,  
   @I_CantRegistros_OtrsPag INT,  
   @I_ProcesoID_OtrsPag INT  
  
 while (@I_FilaActual <= @I_CantRegistros) begin  
  begin tran  
  begin try  
     
   --4to obtengo la información alumno por alumno e inicializo variables  
   SELECT @I_MatAluID = I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng,   
    @N_Grupo = N_Grupo, @I_TipoAlumno = (CASE WHEN B_Ingresante = 0 THEN @I_AlumnoRegular else @I_AlumnoIngresante end)   
   FROM #Tmp_MatriculaAlumno   
   WHERE id = @I_FilaActual  
  
   delete @Tmp_Procesos  

   IF (@B_SoloAplicarExtemporaneo = 0)
   BEGIN
  
	   --Pagos de Matrícula  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		B_EsPagoMatricula = 1 AND C_CodModIng = @C_CodModIng) = 1  
	   begin  
		INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 1 AND C_CodModIng = @C_CodModIng  
	   end  
	   else  
	   begin  
		if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		 WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 1 AND C_CodModIng is NULL) = 1  
		begin  
		 INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		 SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		 WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		  B_EsPagoMatricula = 1 AND C_CodModIng is NULL  
		end   
	   end  
  
	   --Pagos generales de matrícula  
	   INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
	   SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
	   WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND  
		B_EsPagoMatricula = 0 AND B_Calculado = 0 AND B_GrupoCodRc = 0 AND B_EsPagoExtmp = 0  
  
	   --Pagos de laboratorio  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		B_EsPagoMatricula = 0 AND B_GrupoCodRc = 1 AND I_GrupoCodRc = @N_Grupo) = 1  
	   begin  
		INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 0 AND B_GrupoCodRc = 1 AND I_GrupoCodRc = @N_Grupo  
	   end  
  
	   --Multa por no votar  
	   if (@I_TipoAlumno = @I_AlumnoRegular) AND (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado   
		WHERE I_TipoAlumno = @I_AlumnoRegular AND I_TipoObligacion = @I_Matricula AND  
		 B_EsPagoMatricula = 0 AND B_Calculado = 1 AND I_Calculado = @I_MultaNoVotar) = 1  
	   begin  
		if exists(SELECT * FROM dbo.TC_AlumnoMultaNoVotar nv   
		 WHERE nv.B_Eliminado = 0 AND nv.C_CodAlu = @C_CodAlu AND nv.C_CodRc = @C_CodRc AND nv.I_Anio = @I_Anio AND nv.I_Periodo = @I_Periodo)  
		begin  
		 INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		 SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		 WHERE I_TipoAlumno = @I_AlumnoRegular AND I_TipoObligacion = @I_Matricula AND  
		  B_EsPagoMatricula = 0 AND B_Calculado = 1 AND I_Calculado = @I_MultaNoVotar  
		end  
	   end  
  
	   --Pagos extemoráneos  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND  
		 DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0) = 1  
	   begin  
		INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND  
		 DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0  
	   end  
  
	   --Monto de deuda anterior  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado   
		WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_DeudasAnteriores) = 1  
	   begin  
		set @I_MontoDeuda = isnull((
			SELECT SUM(cab.I_MontoOblig) FROM dbo.TR_ObligacionAluCab cab  
			INNER JOIN dbo.TC_MatriculaAlumno mat ON mat.I_MatAluID = cab.I_MatAluID  AND mat.B_Habilitado = 1 AND mat.B_Eliminado =0
			WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.B_Pagado = 0 AND mat.C_CodAlu = @C_CodAlu AND mat.C_CodRc = @C_CodRc AND 
				mat.I_Anio = (SELECT TOP 1 m.I_Anio FROM dbo.TC_MatriculaAlumno m   
					WHERE m.B_Eliminado = 0 AND m.B_Habilitado = 1 AND NOT m.I_MatAluID = @I_MatAluID AND m.C_CodAlu = @C_CodAlu AND m.C_CodRc = @C_CodRc  
					ORDER BY m.I_Anio DESC)), 0);
  
		if (@I_MontoDeuda > 0)  
		begin  
		 set @N_NroPagos = isnull((SELECT TOP 1 N_NroPagos FROM #tmp_conceptos_pregrado   
		  WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_DeudasAnteriores), 1);  
  
		 with CTE_Recursivo AS  
		 (  
		  SELECT 1 AS num, I_ProcesoID, I_ConcPagID, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		  WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_DeudasAnteriores  
		  UNION ALL  
		  SELECT num + 1, I_ProcesoID, I_ConcPagID, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad  
		  FROM CTE_Recursivo  
		  WHERE num < @N_NroPagos  
		 )  
		 INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		 SELECT I_ProcesoID, I_ConcPagID, dbo.FN_CalcularCuotasDeuda(@I_MontoDeuda, @N_NroPagos, num) AS M_Monto,   
		  DATEADD(MONTH, num-1, D_FecVenctoRegistro), I_TipoObligacion, I_Prioridad  
		 FROM CTE_Recursivo;  
		end  
	   end  
     
	   --Monto de cursos desaprobados  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		 WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_CrdtDesaprobados) = 1  
	   begin  
		SET @I_CredDesaprob = (SELECT SUM(c.I_CredDesaprob) FROM dbo.TC_MatriculaCurso c WHERE c.I_MatAluID = @I_MatAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0)  
  
		if (@I_CredDesaprob > 0)  
		begin  
		 set @N_NroPagos = isnull((SELECT TOP 1 N_NroPagos FROM #tmp_conceptos_pregrado   
		  WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_CrdtDesaprobados), 1);  
  
		 set @I_MultiplicMontoCredt = (SELECT SUM(c.I_CredDesaprob * (c.I_Vez - 1)) FROM dbo.TC_MatriculaCurso c WHERE c.I_MatAluID = @I_MatAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0);      
      
		 with CTE_Recursivo AS  
		 (  
		  SELECT 1 AS num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		  WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_CrdtDesaprobados  
		  UNION ALL  
		  SELECT num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad  
		  FROM CTE_Recursivo  
		  WHERE num < @N_NroPagos  
		 )  
		 INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		 SELECT I_ProcesoID, I_ConcPagID, CAST((M_Monto * @I_MultiplicMontoCredt) / @N_NroPagos AS DECIMAL(15,2)),   
		  DATEADD(MONTH, num-1, D_FecVenctoRegistro), I_TipoObligacion, I_Prioridad  
		 FROM CTE_Recursivo  
		end  
	   end  
  
	   --Monto de Pensión de enseñanza  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_Pensiones AND C_CodModIng = @C_CodModIng) = 1  
	   begin  
		set @N_NroPagos = isnull((SELECT TOP 1 N_NroPagos FROM #tmp_conceptos_pregrado   
		 WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_Pensiones AND C_CodModIng = @C_CodModIng), 1);  
      
		with CTE_Recursivo AS  
		(  
		 SELECT 1 AS num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		 WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_Pensiones AND C_CodModIng = @C_CodModIng  
		 UNION ALL  
		 SELECT num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad  
		 FROM CTE_Recursivo  
		 WHERE num < @N_NroPagos  
		)  
		INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		SELECT I_ProcesoID, I_ConcPagID, CAST(M_Monto / @N_NroPagos AS DECIMAL(15,2)) AS M_Monto,   
		 DATEADD(MONTH, num-1, D_FecVenctoRegistro), I_TipoObligacion, I_Prioridad  
		FROM CTE_Recursivo  
	   end  
	END
	ELSE BEGIN
		--Pagos extemoráneos  
	   if (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND  
		 DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0) = 1  
	   begin  
		INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
		SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_pregrado  
		WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
		 B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND  
		 DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0  
	   end  
	END
  
   --Grabando pago de matrícula  
   set @I_ProcesoID = 0  

   IF (@B_SoloAplicarExtemporaneo = 0)
   BEGIN
  
	   if exists(SELECT p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 1)  
	   begin  
		set @I_ProcesoID = (SELECT distinct p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 1)  
  
		if exists(SELECT cab.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab cab   
		 WHERE cab.B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID)  
		begin  
		 SELECT @I_MontoInicial = cab.I_MontoOblig, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado FROM dbo.TR_ObligacionAluCab cab   
		 WHERE cab.B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID  
  
		 SELECT @D_FecVenctoActual = p.D_FecVencto, @I_MontoActual = SUM(p.M_Monto) FROM @Tmp_Procesos p   
		 WHERE p.I_Prioridad = 1 group by p.D_FecVencto  
  
		 if (@B_Pagado = 0)  
		 begin  
		  if Not (DATEDIFF(DAY, @D_FecVenctoInicial, @D_FecVenctoActual) = 0) Or Not (@I_MontoInicial = @I_MontoActual)  
		  begin  
		   update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate  
		   FROM dbo.TR_ObligacionAluCab c  
		   INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID  
		   WHERE d.B_Eliminado = 0 AND c.B_Eliminado = 0 AND c.I_MatAluID = @I_MatAluID AND c.I_ProcesoID = @I_ProcesoID  
  
		   update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate  
		   WHERE B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID  
  
		   INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)  
		   SELECT p.I_ProcesoID, @I_MatAluID, @C_Moneda, SUM(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto FROM @Tmp_Procesos p  
		   WHERE p.I_Prioridad = 1   
		   group by p.I_ProcesoID, p.D_FecVencto  
  
		   set @I_ObligacionAluID = SCOPE_IDENTITY()  
  
		   INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)  
		   SELECT @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 FROM @Tmp_Procesos p  
		   WHERE p.I_Prioridad = 1  
		  end  
		 end  
		end  
		else  
		begin  
		 --INSERT  
		 INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)  
		 SELECT p.I_ProcesoID, @I_MatAluID, @C_Moneda, SUM(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto FROM @Tmp_Procesos p  
		 WHERE p.I_Prioridad = 1   
		 group by p.I_ProcesoID, p.D_FecVencto  
  
		 set @I_ObligacionAluID = SCOPE_IDENTITY()  
  
		 INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)  
		 SELECT @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 FROM @Tmp_Procesos p  
		 WHERE p.I_Prioridad = 1  
		end  
	   end  
  
	   --Grabando otros pagos  
	   if exists(SELECT p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 2)  
	   begin  
		if not exists(SELECT cab.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab cab  
		 WHERE cab.B_Eliminado = 0 AND cab.I_MatAluID = @I_MatAluID AND  
		  cab.I_ProcesoID in (SELECT p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 2))  
		begin  
		 --Nuevos registros de obligaciones  
  
		 --Insert de cabecera  
		 INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)  
		 SELECT p.I_ProcesoID, @I_MatAluID, @C_Moneda, SUM(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto FROM @Tmp_Procesos p  
		 WHERE p.I_Prioridad = 2  
		 group by p.I_ProcesoID, p.D_FecVencto  
  
		 --Insert de detalle  
		 INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)  
		 SELECT cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 FROM @Tmp_Procesos p  
		 INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND p.I_ProcesoID = cab.I_ProcesoID AND cab.I_MatAluID = @I_MatAluID AND  
		  DATEDIFF(DAY, p.D_FecVencto, cab.D_FecVencto) = 0  
		 WHERE p.I_Prioridad = 2  
		end  
		else  
		begin  
		 --Edición de obligaciones  
  
		 if exists(SELECT id FROM @Tmp_grupo_otros_pagos) begin  
		  delete @Tmp_grupo_otros_pagos  
		 end  
  
		 INSERT @Tmp_grupo_otros_pagos(id, I_ProcesoID)  
		 SELECT ROW_NUMBER() OVER (ORDER BY I_ProcesoID), I_ProcesoID FROM @Tmp_Procesos p  
		 WHERE p.I_Prioridad = 2  
		 group by p.I_ProcesoID  
       
		 set @I_FilaActual_OtrsPag = 1  
		 set @I_CantRegistros_OtrsPag = (SELECT MAX(id) FROM @Tmp_grupo_otros_pagos)  
  
		 while (@I_FilaActual_OtrsPag <= @I_CantRegistros_OtrsPag) begin  
		  --Los otros pagos se agrupan primero por proceso y luego por fecha de vcto.  
		  set @I_ProcesoID_OtrsPag = (SELECT I_ProcesoID FROM @Tmp_grupo_otros_pagos WHERE id = @I_FilaActual_OtrsPag)  
  
		  if exists(SELECT cab.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab cab  
		   INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID  
		   WHERE cab.B_Eliminado = 0 AND det.B_Eliminado = 0 AND cab.I_MatAluID = @I_MatAluID AND   
		   cab.I_ProcesoID = @I_ProcesoID_OtrsPag AND cab.B_Pagado = 1) begin  
         
		   print 'Existen al menos un pago realizado.'  
  
		  end  
		  else begin  
		   update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate  
		   FROM dbo.TR_ObligacionAluCab c  
		   INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID  
		   WHERE d.B_Eliminado = 0 AND c.B_Eliminado = 0 AND c.I_MatAluID = @I_MatAluID AND c.I_ProcesoID = @I_ProcesoID_OtrsPag  
  
		   update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate  
		   WHERE B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID_OtrsPag  
  
		   INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)  
		   SELECT p.I_ProcesoID, @I_MatAluID, @C_Moneda, SUM(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto FROM @Tmp_Procesos p  
		   WHERE p.I_Prioridad = 2 AND p.I_ProcesoID = @I_ProcesoID_OtrsPag  
		   group by p.I_ProcesoID, p.D_FecVencto  
  
		   INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)  
		   SELECT cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 FROM @Tmp_Procesos p  
		   INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND p.I_ProcesoID = cab.I_ProcesoID  AND cab.I_MatAluID = @I_MatAluID AND  
			DATEDIFF(DAY, p.D_FecVencto, cab.D_FecVencto) = 0  
		   WHERE p.I_Prioridad = 2 AND p.I_ProcesoID = @I_ProcesoID_OtrsPag  
		  end  
  
		  set @I_FilaActual_OtrsPag = (@I_FilaActual_OtrsPag + 1)  
		 end  
		end  
	   end  
  
	END
	ELSE
	BEGIN
		--Sólo se agregará el pago extemporáneo
		IF ((SELECT COUNT(*) FROM @Tmp_Procesos) = 1) BEGIN	
					
			SELECT @I_ProcesoID = p.I_ProcesoID, @I_ConcPagID = I_ConcPagID, @I_MontoActual = p.M_Monto 
			FROM @Tmp_Procesos p WHERE p.I_Prioridad = 1;

			IF ((SELECT COUNT(cab.I_ObligacionAluID) FROM dbo.TR_ObligacionAluCab cab   
				WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.I_MatAluID = @I_MatAluID AND cab.I_ProcesoID = @I_ProcesoID AND cab.B_EsAmpliacionCred = 0) = 1) BEGIN

				SELECT @I_ObligacionAluID = cab.I_ObligacionAluID, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado 
				FROM dbo.TR_ObligacionAluCab cab
				WHERE cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 AND cab.I_MatAluID = @I_MatAluID AND cab.I_ProcesoID = @I_ProcesoID AND cab.B_EsAmpliacionCred = 0;

				IF (@B_Pagado = 0) BEGIN
					IF EXISTS(SELECT d.I_ObligacionAluDetID FROM dbo.TR_ObligacionAluDet d 
						WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.I_ConcPagID = @I_ConcPagID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0)
					BEGIN
						SELECT @I_ObligacionAluDetID = d.I_ObligacionAluDetID, @I_MontoInicial = d.I_Monto, @B_Pagado = d.B_Pagado
						FROM dbo.TR_ObligacionAluDet d 
	 					WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.I_ConcPagID = @I_ConcPagID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0

						IF (@B_Pagado = 0 AND NOT (@I_MontoActual = @I_MontoInicial))
						BEGIN
							UPDATE dbo.TR_ObligacionAluDet SET 
								I_Monto = @I_MontoActual, 
								I_UsuarioMod = @I_UsuarioCre, 
								D_FecMod = @D_CurrentDate
							WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID

							UPDATE dbo.TR_ObligacionAluCab SET
								I_MontoOblig = (I_MontoOblig - @I_MontoInicial + @I_MontoActual),
									I_UsuarioMod = @I_UsuarioCre,
									D_FecMod = @D_CurrentDate
							WHERE I_ObligacionAluID = @I_ObligacionAluID
						END
					END
					ELSE 
					BEGIN
						INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
						SELECT @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, @D_FecVenctoInicial, 1, 0, @I_UsuarioCre, @D_CurrentDate FROM @Tmp_Procesos p
							
						UPDATE dbo.TR_ObligacionAluCab SET
							I_MontoOblig = (I_MontoOblig + (SELECT SUM(p.M_Monto) FROM @Tmp_Procesos p)),
							I_UsuarioMod = @I_UsuarioCre, 
							D_FecMod = @D_CurrentDate
						WHERE I_ObligacionAluID = @I_ObligacionAluID
					END
				END
			END
		END
	END
   commit tran  
  end try  
  begin catch  
   rollback tran  
  
   print ERROR_MESSAGE()  
   print ERROR_LINE()  
  end catch  
  
  set @I_FilaActual = (@I_FilaActual +1)  
 end  
  
 set @B_Result = 1  
 set @T_Message = 'El proceso finalizó correctamente.'  
END  
GO