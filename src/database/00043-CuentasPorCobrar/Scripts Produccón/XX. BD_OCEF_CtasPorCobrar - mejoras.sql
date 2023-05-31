USE [master]
GO

RESTORE DATABASE [BD_OCEF_CtasPorCobrar]
FROM DISK = N'F:\Microsoft SQL Server\Backup\Bk_BD_OCEF_CtasPorCobrar_20230111.bak' WITH FILE = 1, 
     MOVE N'BD_OCEF_CtasPorCobrar' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar.mdf', 
     MOVE N'BD_OCEF_CtasPorCobrar_log' TO N'F:\Microsoft SQL Server\DATA\BD_OCEF_CtasPorCobrar_log.ldf',
	 NOUNLOAD,
	 REPLACE,
	 STATS = 5;
GO


USE BD_OCEF_CtasPorCobrar
GO


--REGISTRO DE TASAS
SET IDENTITY_INSERT dbo.TC_Servicios ON
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(24, '046', 'UNFV ADMISION 2017', 1, 0, 1, GETDATE())
GO
INSERT dbo.TC_Servicios(I_ServicioID, C_CodServicio, T_DescServ, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(25, '047', 'UNFV ADMISION 2018', 1, 0, 1, GETDATE())
GO
SET IDENTITY_INSERT dbo.TC_Servicios OFF
GO
DBCC CHECKIDENT ('dbo.TC_Servicios', RESEED, 25);  
GO  

INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 5, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(7, 6, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(1, 7, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 8, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(5, 10, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(3, 11, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(2, 14, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 25, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(1, 21, 1, 0, 1, GETDATE())
INSERT dbo.TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES(4, 24, 1, 0, 1, GETDATE())
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoTasas')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
@Tbl_Pagos [dbo].[type_dataPagoTasa] READONLY,
@Observacion VARCHAR(250),
@D_FecRegistro DATETIME,
@UserID INT
AS
BEGIN  
	SET NOCOUNT ON;  
  
	DECLARE @Banco INT = (SELECT TOP 1 I_EntidadFinanID FROM @Tbl_Pagos),
			@Comercio INT = 1

	DECLARE @Tmp_PagoTasas TABLE (  
		id int identity(1,1),  
		I_TasaUnfvID int,  
		I_MontoTasa decimal(15,2),  
		C_CodDepositante varchar(20),  
		T_NomDepositante varchar(200),  
		C_CodTasa varchar(5),  
		T_TasaDesc varchar(200),  
		C_CodOperacion varchar(50),  
		C_Referencia varchar(50),  
		I_EntidadFinanID int,  
		I_CtaDepositoID int,  
		D_FecPago datetime,  
		I_Cantidad int,  
		C_Moneda varchar(3),  
		I_MontoPago decimal(15,2),  
		I_InteresMora decimal(15,2),  
		T_LugarPago varchar(250),  
		T_InformacionAdicional varchar(250),  
		B_Success bit,  
		T_ErrorMessage varchar(250),
		C_CodigoInterno varchar(250),
		T_SourceFileName varchar(250),
		C_Extorno varchar(1)
	);  
  
	IF (@Banco = @Comercio) 
	BEGIN

		INSERT @Tmp_PagoTasas(I_TasaUnfvID, I_MontoTasa, C_CodDepositante, T_NomDepositante, C_CodTasa,   
			T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, D_FecPago,   
			I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional, 
			C_CodigoInterno, T_SourceFileName, C_Extorno)  
		SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,  
			CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,  
			p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID,  
			CASE WHEN p.I_CtaDepositoID IS NULL THEN t.I_CtaDepositoID ELSE p.I_CtaDepositoID END,  
			p.D_FecPago, p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional, 
			p.C_CodigoInterno, p.T_SourceFileName, C_Extorno
		FROM @Tbl_Pagos p  
		LEFT JOIN dbo.VW_PagoTasas_X_Cuenta t ON t.C_CodTasa = p.C_CodTasa and t.I_EntidadFinanID = @Comercio and t.C_CodServicio = p.C_CodServicio
	
	END ELSE BEGIN

		INSERT @Tmp_PagoTasas(I_TasaUnfvID, I_MontoTasa, C_CodDepositante, T_NomDepositante, C_CodTasa,   
			T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, D_FecPago,   
			I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional, 
			C_CodigoInterno, T_SourceFileName, C_Extorno)  
		SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,  
			CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,  
			p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID,  
			CASE WHEN p.I_CtaDepositoID IS NULL   
			THEN   
			(SELECT tc.I_CtaDepositoID FROM VW_PagoTasas_X_Cuenta tc WHERE tc.I_TasaUnfvID = t.I_TasaUnfvID AND tc.C_CodServicio = p.C_CodServicio AND tc.I_EntidadFinanID = p.I_EntidadFinanID)  
			ELSE p.I_CtaDepositoID END,  
			p.D_FecPago, p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional, 
			p.C_CodigoInterno, p.T_SourceFileName, C_Extorno
		FROM @Tbl_Pagos p  
		LEFT JOIN dbo.TI_TasaUnfv t ON t.C_CodTasa = p.C_CodTasa and t.B_Habilitado = 1 and t.B_Eliminado = 0  
	END

	SELECT * FROM @Tmp_PagoTasas

	--DECLARE @I_FilaActual  int = 1,  
	--   @I_CantRegistros int = (select count(id) from @Tmp_PagoTasas),  
	--   @I_SaldoAPagar  decimal(15,2),  
	--   @I_PagoDemas  decimal(15,2),  
	--   @B_PagoDemas  bit,  
	--   -----------------------------------------------------------  
	--   @I_PagoBancoID  int,  
	--   @I_TasaUnfvID  int,  
	--   @I_MontoTasa  decimal(15,2),  
	--   @C_CodDepositante varchar(20),  
	--   @T_NomDepositante varchar(200),  
	--   @C_CodTasa   varchar(3),  
	--   @T_TasaDesc   varchar(3),  
	--   @C_CodOperacion  varchar(50),  
	--   @C_Referencia  varchar(50),  
	--   @I_EntidadFinanID int,  
	--   @I_CtaDepositoID int,  
	--   @D_FecPago   datetime,  
	--   @I_Cantidad   int,  
	--   @C_Moneda   varchar(3),  
	--   @I_MontoPago  decimal(15,2),  
	--   @I_InteresMora  decimal(15,2),  
	--   @T_LugarPago  varchar(250),   
	--   @T_InformacionAdicional varchar(250),  
	--   @C_CodigoInterno varchar(250),
	--   @B_ExisteError  bit,  
	--   @B_CodOpeCorrecto bit,  
	--   @C_Extorno varchar(1),
	--   --Constantes  
	--   @CondicionCorrecto int = 131,--PAGO CORRECTO
	--   @Extornado int = 132,--Extorno
	--   @I_CondicionPagoID int,
	--   @PagoTipoTasa  int = 134--OBLIGACION  
   
	-- WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN  
    
	--  SET @B_ExisteError = 0  
  
	--  SELECT  @I_TasaUnfvID = I_TasaUnfvID,  
	--	@I_MontoTasa = I_MontoTasa,  
	--	@C_CodDepositante = C_CodDepositante,  
	--	@T_NomDepositante = T_NomDepositante,  
	--	@C_CodTasa = C_CodTasa,  
	--	@T_TasaDesc = T_TasaDesc,  
	--	@C_CodOperacion = C_CodOperacion,  
	--	@C_Referencia = C_Referencia,  
	--	@I_EntidadFinanID = I_EntidadFinanID,  
	--	@I_CtaDepositoID = I_CtaDepositoID,  
	--	@D_FecPago = D_FecPago,  
	--	@I_Cantidad = I_Cantidad,  
	--	@C_Moneda = C_Moneda,  
	--	@I_MontoPago = I_MontoPago,  
	--	@I_InteresMora = I_InteresMora,  
	--	@T_LugarPago = T_LugarPago,  
	--	@T_InformacionAdicional = T_InformacionAdicional,
	--	@C_CodigoInterno = C_CodigoInterno,
	--	@C_Extorno = C_Extorno
	--   FROM @Tmp_PagoTasas WHERE id = @I_FilaActual  
  
	--  IF (@I_TasaUnfvID IS NULL) BEGIN
	--	IF (@I_EntidadFinanID = 2) BEGIN
	--		SELECT @I_TasaUnfvID = t.I_TasaUnfvID, @I_CtaDepositoID = cs.I_CtaDepositoID FROM dbo.TI_TasaUnfv t 
	--			INNER JOIN dbo.TI_TasaUnfv_CtaDepoServicio c ON c.I_TasaUnfvID = t.I_TasaUnfvID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	--			INNER JOIN dbo.TI_CtaDepo_Servicio cs ON cs.I_CtaDepoServicioID = c.I_CtaDepoServicioID AND cs.B_Habilitado = 1 AND cs.B_Eliminado = 0
	--			INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = cs.I_CtaDepositoID AND cd.B_Habilitado = 1 AND cd.B_Eliminado = 0
	--			WHERE t.B_Habilitado = 1 AND t.B_Eliminado = 0 AND cd.I_EntidadFinanID = 2 AND t.C_CodTasa = '00000'
	--	END ELSE BEGIN
	--		SET @B_ExisteError = 1  
	--		UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'No existe el código de tasa.' WHERE id = @I_FilaActual  
	--	END
	--  END  
  
	--  IF (@B_ExisteError = 0 AND @I_CtaDepositoID IS NULL) BEGIN  
	--   SET @B_ExisteError = 1  
	--   UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Esta tasa no tiene asignado una cuenta.' WHERE id = @I_FilaActual  
	--  END  
  
	--  IF  (@B_ExisteError = 0) BEGIN  
	--   EXEC USP_S_ValidarCodOperacionTasa @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT  
  
	--   IF NOT (@B_CodOpeCorrecto = 1) BEGIN  
	--	SET @B_ExisteError = 1  
      
	--	UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual  
	--   END  
	--  END  
  
	--  IF (@B_ExisteError = 0) BEGIN  
	--   BEGIN TRANSACTION  
	--   BEGIN TRY  

	--   SET @I_CondicionPagoID = (CASE WHEN @C_Extorno = 'E' THEN @Extornado ELSE @CondicionCorrecto END)

	--	INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,   
	--	 C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,  
	--	 T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno)  
	--	VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,   
	--	 @C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,  
	--	 @T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoTasa, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno)  
  
	--	SET @I_PagoBancoID = SCOPE_IDENTITY()

	--	IF (@I_CondicionPagoID = @CondicionCorrecto) BEGIN
	--		--Pago menor  
	--		SET @I_SaldoAPagar = @I_MontoTasa - @I_MontoPago  
   
	--		SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END  
  
	--		--Pago excedente  
	--		SET @I_PagoDemas = @I_MontoPago - @I_MontoTasa  
       
	--		SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END  
  
	--		SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END  
  
	--		INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_TasaUnfvID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,  
	--		 B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)  
	--		VALUES(@I_PagoBancoID, @I_TasaUnfvID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas,   
	--		 @B_PagoDemas, @D_FecRegistro, @UserID, 0, @I_CtaDepositoID)  

	--		 UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual  
	--	END
	--	ELSE BEGIN 
	--		UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto (Extorno).' WHERE id = @I_FilaActual  
	--	END
	
  
	--	COMMIT TRANSACTION  
	--   END TRY  
	--   BEGIN CATCH  
	--	ROLLBACK TRANSACTION  
  
	--	UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual
	--   END CATCH  
	--  END  
  
	--  SET @I_FilaActual = @I_FilaActual + 1
	-- END  
  
	-- SELECT * FROM @Tmp_PagoTasas
END
GO



SELECT top 13 * FROM dbo.TR_PagoBanco order by 1 desc
GO


DECLARE @tabla AS type_dataPagoTasa

INSERT @tabla(C_CodDepositante, T_NomDepositante, C_CodServicio, C_CodTasa, T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, 
D_FecPago, I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional, C_CodigoInterno, T_SourceFileName, C_Extorno)

VALUES ('72656577', 'HUMBERTO MANYARI', '', '80043', '', '00123456', 'EFECTIVO72656577', 2, NULL,
'20221227 11:31', 1, 'PEN', 63, 0, '010101', '08004372656577', '00123456', 'SOURCE.TXT', '')

SELECT * FROM @tabla

EXEC USP_I_GrabarPagoTasas @Tbl_Pagos = @tabla, @Observacion = 'SIN OBS.', @D_FecRegistro = '20221227 12:05', @UserID = 1
GO

SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,  
			CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,  
			p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID,  
			CASE WHEN p.I_CtaDepositoID IS NULL   
			THEN   
			(SELECT tc.I_CtaDepositoID FROM VW_PagoTasas_X_Cuenta tc WHERE tc.I_TasaUnfvID = t.I_TasaUnfvID AND tc.C_CodServicio = p.C_CodServicio AND tc.I_EntidadFinanID = p.I_EntidadFinanID)  
			ELSE p.I_CtaDepositoID END,  
			p.D_FecPago, p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional, 
			p.C_CodigoInterno, p.T_SourceFileName, C_Extorno
		FROM @Tbl_Pagos p  
		LEFT JOIN dbo.TI_TasaUnfv t ON t.C_CodTasa = p.C_CodTasa and t.B_Habilitado = 1 and t.B_Eliminado = 0  


SELECT * FROM dbo.TI_TasaUnfv WHERE C_CodTasa = '80043'




--Actualización de la tabla para la DEVOLUCIÓN DE DINERO
ALTER TABLE dbo.TR_DevolucionPago DROP CONSTRAINT FK_PagoProcesadoUnfv_DevolucionPago
GO

ALTER TABLE dbo.TR_DevolucionPago DROP COLUMN I_PagoProcesID
GO

ALTER TABLE dbo.TR_DevolucionPago ADD I_PagoBancoID INT NOT NULL
GO

ALTER TABLE dbo.TR_DevolucionPago ADD CONSTRAINT FK_PagoBanco_DevolucionPago 
FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco(I_PagoBancoID)
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DevolucionPago')
	DROP VIEW [dbo].[VW_DevolucionPago]
GO

CREATE VIEW [dbo].[VW_DevolucionPago]
AS
(
	(SELECT DP.*, PB.I_MontoPago, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, pr.T_ProcesoDesc AS T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		LEFT JOIN dbo.TC_Proceso pr ON pr.I_ProcesoID = pb.I_ProcesoIDArchivo
	WHERE Dp.B_Anulado = 0)
	UNION
	(SELECT DP.*, PP.I_MontoPagado, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_CodigoInterno AS C_ReferenciaBCP, PB.D_FecPago
		, EF.T_EntidadDesc, TU.T_ConceptoPagoDesc
	FROM TR_DevolucionPago DP
		INNER JOIN TR_PagoBanco PB ON DP.I_PagoBancoID = PB.I_PagoBancoID
		INNER JOIN TRI_PagoProcesadoUnfv PP ON PB.I_PagoBancoID = PP.I_PagoProcesID
		INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID
		INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID
	WHERE DP.B_Anulado = 0)
)
GO

--SELECT * FROM dbo.VW_DevolucionPago

--select t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto, pr.I_MontoPagado, pr.I_PagoDemas, p.I_MontoPago, * 
--from dbo.TR_PagoBanco p
--inner join dbo.TRI_PagoProcesadoUnfv pr on pr.I_PagoBancoID = p.I_PagoBancoID
--inner join dbo.TI_TasaUnfv t on t.I_TasaUnfvID = pr.I_TasaUnfvID
--where p.B_Anulado = 0 and pr.B_Anulado = 0 and p.I_TipoPagoID = 134 and t.M_Monto > 0
--	and pr.I_PagoDemas > 0


--SELECT * FROM TR_PagoBanco
--SELECT * FROM TRI_PagoProcesadoUnfv



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_Pagos')
	DROP VIEW [dbo].[VW_Pagos]
GO
  
CREATE VIEW [dbo].[VW_Pagos]  
AS  
 SELECT   
  ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,  
  cta.I_CtaDepositoID, ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, pagban.C_CodOperacion, pagban.C_CodDepositante, pagban.I_PagoBancoID,  
  pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod AS C_Periodo,  
  CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre) AS T_NomAlumno, tipEs.T_OpcionCod as C_Nivel,   
  cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, pro.I_Anio, tipPer.T_OpcionCod AS I_Periodo, pro.T_ProcesoDesc,   
  (CAST(pro.I_Anio AS varchar) + '-' + tipPer.T_OpcionCod + ' ' + cat.T_CatPagoDesc) AS T_Concepto, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda, cab.I_MontoOblig,  
  cab.B_Pagado, pagban.T_LugarPago, cab.D_FecCre, SUM(pagpro.I_MontoPagado) AS I_MontoPagado, ISNULL(srv.C_CodServicio, '') AS C_CodServicio,   
  pagban.C_Referencia, pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc, mat.T_FacDesc, mat.T_DenomProg,  
  ISNULL(pagban.T_InformacionAdicional, '') AS T_InformacionAdicional, 1 AS B_EsObligacion  
 FROM dbo.VW_MatriculaAlumno mat  
  INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0 AND cab.B_Habilitado = 1
  INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0 AND det.B_Habilitado = 1
  INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
  INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0  
  LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0  
  INNER JOIN dbo.TC_CatalogoOpcion tipEs ON tipEs.I_ParametroID = 2 AND tipEs.I_OpcionID = cat.I_Nivel  
  INNER JOIN dbo.TC_CatalogoOpcion tipPer ON tipPer.I_ParametroID = 5 AND tipPer.I_OpcionID = pro.I_Periodo  
  INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0  
  INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0  
  INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID  
  INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID  
 WHERE pagban.I_TipoPagoID = 133  
 GROUP BY  
  mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto,  
  cta.I_CtaDepositoID, C_NumeroCuenta, pagban.C_CodOperacion, pagban.C_CodDepositante,  
  pagban.T_NomDepositante, pagban.D_FecPago, pagban.I_Cantidad, tipPer.T_OpcionCod, pagban.I_PagoBancoID,  
  CONCAT(mat.T_ApePaterno, ' ', mat.T_ApeMaterno, ' ', mat.T_Nombre), tipEs.T_OpcionCod, cat.T_CatPagoDesc,  
  cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, tipPer.T_OpcionCod,   
  pro.T_ProcesoDesc, pro.I_Prioridad, cab.C_Moneda, cab.I_MontoOblig,  
  cab.B_Pagado, pagban.T_LugarPago, cab.D_FecCre, ISNULL(srv.C_CodServicio, ''),  
  pagban.C_Referencia, pagban.I_EntidadFinanID, ISNULL(ef.T_EntidadDesc, ''), mat.T_FacDesc, mat.T_DenomProg,  
  ISNULL(pagban.T_InformacionAdicional, '')  
GO


--------------------------------------------------------

--SELECT * FROM dbo.TR_PagoBanco
CREATE TABLE TR_ConstanciaPago
(
	I_ConstanciaPagoID INT IDENTITY(1,1),
	I_PagoBancoID INT NOT NULL,
	I_ConstanciaPagoNum INT UNIQUE NOT NULL,
	I_UsuarioCre INT NOT NULL,
	D_FecCre DATETIME NOT NULL,
	CONSTRAINT PK_ConstanciaPago PRIMARY KEY (I_ConstanciaPagoID),
	CONSTRAINT FK_PagoBanco_ConstanciaPago FOREIGN KEY (I_PagoBancoID) REFERENCES TR_PagoBanco (I_PagoBancoID)
)
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarConstanciaPago')
	DROP PROCEDURE [dbo].[USP_I_GrabarConstanciaPago]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarConstanciaPago]
@I_PagoBancoID INT,
@UserID INT
AS
BEGIN  
	SET NOCOUNT ON;

	DECLARE @I_ConstanciaPagoNum INT = ISNULL((SELECT MAX(I_ConstanciaPagoNum) FROM dbo.TR_ConstanciaPago), 0) + 1

	INSERT dbo.TR_ConstanciaPago(I_PagoBancoID, I_ConstanciaPagoNum, I_UsuarioCre, D_FecCre)
	VALUES(@I_PagoBancoID, @I_ConstanciaPagoNum, @UserID, GETDATE())
END
GO