USE BD_OCEF_CtasPorCobrar
GO


SET IDENTITY_INSERT TC_EstadoComprobante ON
INSERT dbo.TC_EstadoComprobante(I_EstadoComprobanteID, C_EstadoComprobanteCod, T_EstadoComprobanteDesc, B_Habilitado, I_UsuarioCre, D_FecCre) VALUES(5, 'BAJ', 'Baja', 1, 1, GETDATE())
SET IDENTITY_INSERT TC_EstadoComprobante OFF
GO
DBCC CHECKIDENT (TC_EstadoComprobante, RESEED, 5)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_DarBajaComprobante')
	DROP PROCEDURE [dbo].[USP_U_DarBajaComprobante]
GO
 
CREATE PROCEDURE dbo.USP_U_DarBajaComprobante
@I_ComprobanteID INT,
@D_FecBaja DATETIME,
@T_MotivoBaja VARCHAR(250),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME,
			@I_EstadoComprobanteID INT;

	BEGIN TRAN
	BEGIN TRY
		SET @D_FechaAccion = GETDATE();
		SET @I_EstadoComprobanteID = (SELECT I_EstadoComprobanteID FROM dbo.TC_EstadoComprobante e WHERE e.C_EstadoComprobanteCod = 'BAJ');
			
		UPDATE pb SET 
			pb.B_Habilitado = 0,
			pb.I_UsuarioMod = @UserID,
			pb.D_FecMod = @D_FechaAccion
		FROM dbo.TR_Comprobante c
		INNER JOIN dbo.TR_Comprobante_PagoBanco pb ON pb.I_ComprobanteID = c.I_ComprobanteID AND pb.B_Habilitado = 1
		WHERE c.I_ComprobanteID = @I_ComprobanteID;

		UPDATE dbo.TR_Comprobante SET 
			I_EstadoComprobanteID = @I_EstadoComprobanteID,
			D_FecBaja = @D_FecBaja,
			T_MotivoBaja = @T_MotivoBaja,
			I_UsuarioMod = @UserID,
			D_FecMod = @D_FechaAccion
		WHERE I_ComprobanteID = @I_ComprobanteID;

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Acción realizada con éxito.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ListarComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarComprobantePago]
@I_TipoPagoID INT = NULL,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL,
@C_CodOperacion VARCHAR(50) = NULL,
@C_CodigoInterno VARCHAR(250) = NULL,
@C_CodDepositante VARCHAR(20) = NULL,
@T_NomDepositante VARCHAR(200) = NULL,
@D_FechaInicio DATETIME = NULL,
@D_FechaFin DATETIME = NULL,
@I_TipoComprobanteID INT = NULL,
@I_EstadoGeneracion BIT = NULL,
@I_EstadoComprobanteID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@SQLString NVARCHAR(MAX),
			@SQLHabilitados NVARCHAR(MAX),
			@SQLDeshabilitados NVARCHAR(MAX),
			@ParmDefinition NVARCHAR(MAX);

	SET @SQLHabilitados = N'(SELECT b.I_PagoBancoID,e.I_EntidadFinanID,e.T_EntidadDesc,c.C_NumeroCuenta,b.C_CodOperacion,b.C_CodigoInterno,
b.C_CodDepositante,b.T_NomDepositante,b.D_FecPago,b.I_MontoPago,b.I_InteresMora,b.T_LugarPago,cond.T_OpcionDesc AS ''T_Condicion'',b.I_TipoPagoID,
com.I_ComprobanteID,ser.I_SerieID,ser.I_NumeroSerie,com.I_NumeroComprobante,com.D_FechaEmision,com.B_EsGravado,com.T_Ruc,com.T_Direccion,
t.I_TipoComprobanteID,t.C_TipoComprobanteCod,t.T_TipoComprobanteDesc,t.T_Inicial,estCom.C_EstadoComprobanteCod,estCom.T_EstadoComprobanteDesc
FROM dbo.TR_PagoBanco b
INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID=b.I_EntidadFinanID
INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID=b.I_CtaDepositoID
INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID=b.I_CondicionPagoID
LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID=b.I_PagoBancoID AND cpb.B_Habilitado=1
LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID=cpb.I_ComprobanteID
LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID=com.I_SerieID
LEFT JOIN dbo.TC_TipoComprobante t ON t.I_TipoComprobanteID=com.I_TipoComprobanteID
LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID=com.I_EstadoComprobanteID
WHERE b.B_Anulado=0 AND NOT b.I_TipoPagoID=132
' + CASE WHEN @I_TipoPagoID IS NULL THEN N'' ELSE N'AND b.I_TipoPagoID=@I_TipoPagoID' END + N'
' + CASE WHEN @I_EntidadFinanID IS NULL THEN N'' ELSE N'AND b.I_EntidadFinanID=@I_EntidadFinanID' END + N'
' + CASE WHEN @I_CtaDepositoID IS NULL THEN N'' ELSE N'AND b.I_CtaDepositoID=@I_CtaDepositoID' END + N'
' + CASE WHEN @C_CodOperacion IS NULL THEN N'' ELSE N'AND b.C_CodOperacion LIKE ''%''+@C_CodOperacion' END + N'
' + CASE WHEN @C_CodigoInterno IS NULL THEN N'' ELSE N'AND b.C_CodigoInterno LIKE ''%''+@C_CodigoInterno' END + N'
' + CASE WHEN @C_CodDepositante IS NULL THEN N'' ELSE N'AND b.C_CodDepositante LIKE ''%''+@C_CodDepositante' END + N'
' + CASE WHEN @T_NomDepositante IS NULL THEN N'' ELSE N'AND b.T_NomDepositante LIKE ''%''+@T_NomDepositante+''%'' COLLATE Modern_Spanish_CI_AI' END + N'
' + CASE WHEN @D_FechaInicio IS NULL THEN N'' ELSE N'AND DATEDIFF(DAY,b.D_FecPago,@D_FechaInicio)<=0' END + N'
' + CASE WHEN @D_FechaFin IS NULL THEN N'' ELSE N'AND DATEDIFF(DAY,b.D_FecPago,@D_FechaFin)>=0' END + N'
' + CASE WHEN @I_TipoComprobanteID IS NULL THEN N'' ELSE N'AND com.I_TipoComprobanteID=@I_TipoComprobanteID' END + N'
' + CASE WHEN @I_EstadoGeneracion IS NULL THEN N'' ELSE (CASE WHEN @I_EstadoGeneracion = 1 THEN N'AND com.I_ComprobanteID IS NOT NULL' ELSE N'AND com.I_ComprobanteID IS NULL' END) END + N'
' + CASE WHEN @I_EstadoComprobanteID IS NULL THEN N'' ELSE N'AND com.I_EstadoComprobanteID=@I_EstadoComprobanteID' END + N')';

	SET @SQLDeshabilitados = N'(SELECT b.I_PagoBancoID,e.I_EntidadFinanID,e.T_EntidadDesc,c.C_NumeroCuenta,b.C_CodOperacion,b.C_CodigoInterno,
b.C_CodDepositante,b.T_NomDepositante,b.D_FecPago,b.I_MontoPago,b.I_InteresMora,b.T_LugarPago,cond.T_OpcionDesc AS ''T_Condicion'',b.I_TipoPagoID,
com.I_ComprobanteID,ser.I_SerieID,ser.I_NumeroSerie,com.I_NumeroComprobante,com.D_FechaEmision,com.B_EsGravado,com.T_Ruc,com.T_Direccion,
t.I_TipoComprobanteID,t.C_TipoComprobanteCod,t.T_TipoComprobanteDesc,t.T_Inicial,estCom.C_EstadoComprobanteCod,estCom.T_EstadoComprobanteDesc
FROM dbo.TR_PagoBanco b
INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID=b.I_EntidadFinanID
INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID=b.I_CtaDepositoID
INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID=b.I_CondicionPagoID
INNER JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID=b.I_PagoBancoID
INNER JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID=cpb.I_ComprobanteID	
INNER JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID=com.I_SerieID
INNER JOIN dbo.TC_TipoComprobante t ON t.I_TipoComprobanteID=com.I_TipoComprobanteID
INNER JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID=com.I_EstadoComprobanteID
WHERE cpb.B_Habilitado=0 AND com.I_EstadoComprobanteID=5
' + CASE WHEN @I_TipoPagoID IS NULL THEN N'' ELSE N'AND b.I_TipoPagoID=@I_TipoPagoID' END + N'
' + CASE WHEN @I_EntidadFinanID IS NULL THEN N'' ELSE N'AND b.I_EntidadFinanID=@I_EntidadFinanID' END + N'
' + CASE WHEN @I_CtaDepositoID IS NULL THEN N'' ELSE N'AND b.I_CtaDepositoID=@I_CtaDepositoID' END + N'
' + CASE WHEN @C_CodOperacion IS NULL THEN N'' ELSE N'AND b.C_CodOperacion LIKE ''%''+@C_CodOperacion' END + N'
' + CASE WHEN @C_CodigoInterno IS NULL THEN N'' ELSE N'AND b.C_CodigoInterno LIKE ''%''+@C_CodigoInterno' END + N'
' + CASE WHEN @C_CodDepositante IS NULL THEN N'' ELSE N'AND b.C_CodDepositante LIKE ''%''+@C_CodDepositante' END + N'
' + CASE WHEN @T_NomDepositante IS NULL THEN N'' ELSE N'AND b.T_NomDepositante LIKE ''%''+@T_NomDepositante+''%'' COLLATE Modern_Spanish_CI_AI' END + N'
' + CASE WHEN @D_FechaInicio IS NULL THEN N'' ELSE N'AND DATEDIFF(DAY,b.D_FecPago,@D_FechaInicio)<=0' END + N'
' + CASE WHEN @D_FechaFin IS NULL THEN N'' ELSE N'AND DATEDIFF(DAY,b.D_FecPago,@D_FechaFin)>=0' END + N'
' + CASE WHEN @I_TipoComprobanteID IS NULL THEN N'' ELSE N'AND com.I_TipoComprobanteID=@I_TipoComprobanteID' END + N'
' + CASE WHEN @I_EstadoGeneracion IS NULL THEN N'' ELSE (CASE WHEN @I_EstadoGeneracion = 1 THEN N'AND com.I_ComprobanteID IS NOT NULL' ELSE N'AND com.I_ComprobanteID IS NULL' END) END + N'
' + CASE WHEN @I_EstadoComprobanteID IS NULL THEN N'' ELSE N'AND com.I_EstadoComprobanteID=@I_EstadoComprobanteID' END + N')';
	
	SET @SQLString = @SQLHabilitados + N' UNION ' + @SQLDeshabilitados + N' ORDER BY D_FecPago DESC';

	SET @ParmDefinition = N'@I_TipoPagoID INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @C_CodOperacion VARCHAR(50), @C_CodigoInterno VARCHAR(250),
		@C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200), @D_FechaInicio DATETIME, @D_FechaFin DATETIME, @I_TipoComprobanteID INT, @I_EstadoComprobanteID INT';

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_TipoPagoID = @I_TipoPagoID,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID,
		@C_CodOperacion = @C_CodOperacion,
		@C_CodigoInterno = @C_CodigoInterno,
		@C_CodDepositante = @C_CodDepositante,
		@T_NomDepositante = @T_NomDepositante,
		@D_FechaInicio = @D_FechaInicio,
		@D_FechaFin = @D_FechaFin,
		@I_TipoComprobanteID = @I_TipoComprobanteID,
		@I_EstadoComprobanteID = @I_EstadoComprobanteID;
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ObtenerComprobantePago')
	DROP PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
GO

CREATE PROCEDURE [dbo].[USP_S_ObtenerComprobantePago]
@I_PagoBancoID INT,
@I_ComprobanteID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @C_CodDepositante VARCHAR(250),
			@I_EntidadFinanID INT,
			@C_CodOperacion VARCHAR(250),
			@D_FecPago DATETIME,
			@OBLIGACION INT = 133,
			@TASA INT = 134;
	IF (@I_ComprobanteID IS NULL) BEGIN
		SELECT
			@C_CodDepositante = b.C_CodDepositante,
			@I_EntidadFinanID = b.I_EntidadFinanID,
			@C_CodOperacion = b.C_CodOperacion,
			@D_FecPago = D_FecPago
		FROM dbo.TR_PagoBanco b
		WHERE b.I_PagoBancoID = @I_PagoBancoID;

		SELECT
			pagBan.I_PagoBancoID,
			ban.I_EntidadFinanID,
			ban.T_EntidadDesc,
			cta.C_NumeroCuenta,
			pagBan.C_CodOperacion,
			pagBan.C_CodigoInterno,
			pagBan.C_CodDepositante,
			pagban.T_NomDepositante,
			pagBan.D_FecPago,
			pagBan.I_MontoPago,
			pagBan.I_InteresMora,
			pagBan.T_LugarPago,
			cond.T_OpcionDesc AS 'T_Condicion',
			pagBan.I_TipoPagoID,
			com.I_ComprobanteID,
			ser.I_SerieID,
			ser.I_NumeroSerie,
			com.I_NumeroComprobante,
			com.D_FechaEmision,
			com.B_EsGravado,
			com.T_Ruc,
			com.T_Direccion,
			tipCom.I_TipoComprobanteID,
			tipCom.C_TipoComprobanteCod,
			tipCom.T_TipoComprobanteDesc,
			tipCom.T_Inicial,
			estCom.C_EstadoComprobanteCod,
			estCom.T_EstadoComprobanteDesc,
			CASE WHEN pagBan.I_TipoPagoID = @OBLIGACION THEN pagBan.T_ProcesoDescArchivo  + ' (F.VCTO.' + CONVERT(VARCHAR(10), pagBan.D_FecVenctoArchivo, 103) + ')'
				ELSE (SELECT t.T_ConceptoPagoDesc FROM dbo.TRI_PagoProcesadoUnfv pr INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
				WHERE pr.B_Anulado = 0 AND pr.I_PagoBancoID = pagBan.I_PagoBancoID) END AS T_Concepto,
			pagBan.I_Cantidad
		FROM dbo.TR_PagoBanco pagBan
		INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
		INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
		INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
		LEFT JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID AND cpb.B_Habilitado = 1
		LEFT JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
		LEFT JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
		LEFT JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
		LEFT JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
		WHERE pagBan.B_Anulado = 0 AND NOT pagBan.I_CondicionPagoID = 132 AND 
			pagBan.C_CodDepositante	 = @C_CodDepositante AND
			pagBan.I_EntidadFinanID = @I_EntidadFinanID AND
			pagBan.C_CodOperacion = @C_CodOperacion AND
			DATEDIFF(SECOND, pagBan.D_FecPago, @D_FecPago) = 0
		ORDER BY pagBan.D_FecVenctoArchivo;
	END
	ELSE BEGIN
		SELECT
			pagBan.I_PagoBancoID,
			ban.I_EntidadFinanID,
			ban.T_EntidadDesc,
			cta.C_NumeroCuenta,
			pagBan.C_CodOperacion,
			pagBan.C_CodigoInterno,
			pagBan.C_CodDepositante,
			pagban.T_NomDepositante,
			pagBan.D_FecPago,
			pagBan.I_MontoPago,
			pagBan.I_InteresMora,
			pagBan.T_LugarPago,
			cond.T_OpcionDesc AS 'T_Condicion',
			pagBan.I_TipoPagoID,
			com.I_ComprobanteID,
			ser.I_SerieID,
			ser.I_NumeroSerie,
			com.I_NumeroComprobante,
			com.D_FechaEmision,
			com.B_EsGravado,
			com.T_Ruc,
			com.T_Direccion,
			tipCom.I_TipoComprobanteID,
			tipCom.C_TipoComprobanteCod,
			tipCom.T_TipoComprobanteDesc,
			tipCom.T_Inicial,
			estCom.C_EstadoComprobanteCod,
			estCom.T_EstadoComprobanteDesc,
			CASE WHEN pagBan.I_TipoPagoID = @OBLIGACION THEN pagBan.T_ProcesoDescArchivo  + ' (F.VCTO.' + CONVERT(VARCHAR(10), pagBan.D_FecVenctoArchivo, 103) + ')'
				ELSE (SELECT t.T_ConceptoPagoDesc FROM dbo.TRI_PagoProcesadoUnfv pr INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
				WHERE pr.B_Anulado = 0 AND pr.I_PagoBancoID = pagBan.I_PagoBancoID) END AS T_Concepto,
			pagBan.I_Cantidad
		FROM dbo.TR_PagoBanco pagBan
		INNER JOIN dbo.TC_EntidadFinanciera ban ON ban.I_EntidadFinanID = pagBan.I_EntidadFinanID
		INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagBan.I_CtaDepositoID
		INNER JOIN dbo.TC_CatalogoOpcion cond ON cond.I_OpcionID = pagBan.I_CondicionPagoID
		INNER JOIN dbo.TR_Comprobante_PagoBanco cpb ON cpb.I_PagoBancoID = pagBan.I_PagoBancoID
		INNER JOIN dbo.TR_Comprobante com ON com.I_ComprobanteID = cpb.I_ComprobanteID	
		INNER JOIN dbo.TC_SerieComprobante ser ON ser.I_SerieID = com.I_SerieID
		INNER JOIN dbo.TC_TipoComprobante tipCom ON tipCom.I_TipoComprobanteID = com.I_TipoComprobanteID
		INNER JOIN dbo.TC_EstadoComprobante estCom ON estCom.I_EstadoComprobanteID = com.I_EstadoComprobanteID
		WHERE com.I_ComprobanteID = @I_ComprobanteID
		ORDER BY pagBan.D_FecVenctoArchivo;
	END
END
GO



ALTER TABLE TC_Proceso ADD D_FecVenctoExt DATETIME
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarProceso')
	DROP PROCEDURE [dbo].[USP_I_GrabarProceso]
GO

CREATE PROCEDURE dbo.USP_I_GrabarProceso
 @I_CatPagoID int,  
 @I_Anio smallint = null,  
 @D_FecVencto datetime = null,  
 @D_FecVenctoExt datetime = null,  
 @I_Prioridad tinyint = null,  
 @I_Periodo int = null,  
 @N_CodBanco varchar(10) = null,  
 @T_ProcesoDesc varchar(250) = null,  
 @I_UsuarioCre int,  
 @I_CuotaPagoID INT,  
 @I_ProcesoID int OUTPUT,  
 @B_Result bit OUTPUT,  
 @T_Message nvarchar(4000) OUTPUT  
AS  
BEGIN  
 SET NOCOUNT ON;  
    
 BEGIN TRAN  
  
 BEGIN TRY  
  DECLARE @I_Grado INT,    
  @I_AlumnoDestino INT    
    
  INSERT dbo.TC_Proceso(I_CatPagoID, I_Anio, D_FecVencto, T_ProcesoDesc, N_CodBanco, I_Prioridad, I_Periodo, B_Migrado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre,  
  I_CuotaPagoID, D_FecVenctoExt)    
  VALUES(@I_CatPagoID, @I_Anio, @D_FecVencto, @T_ProcesoDesc, @N_CodBanco, @I_Prioridad, @I_Periodo, 0, 1, 0, @I_UsuarioCre, getdate(), @I_CuotaPagoID, @D_FecVenctoExt)    
        
  SET @I_ProcesoID = SCOPE_IDENTITY()    
      
  SELECT @I_Grado = I_Nivel, @I_AlumnoDestino = I_TipoAlumno FROM dbo.TC_CategoriaPago     
   WHERE I_CatPagoID = @I_CatPagoID    
    
  INSERT INTO TI_ConceptoPago    
   (I_ProcesoID, I_ConceptoID, T_ConceptoPagoDesc, B_Fraccionable, B_ConceptoGeneral, B_AgrupaConcepto, I_AlumnosDestino, I_GradoDestino, I_TipoObligacion,    
   T_Clasificador, B_Calculado, I_Calculado, B_AnioPeriodo, I_Anio, I_Periodo, B_Especialidad, B_Dependencia, B_GrupoCodRc, I_GrupoCodRc,    
   B_ModalidadIngreso, I_ModalidadIngresoID, B_ConceptoAgrupa, I_ConceptoAgrupaID, B_ConceptoAfecta, N_NroPagos, B_Porcentaje, C_Moneda,    
   M_Monto, M_MontoMinimo, T_DescripcionLarga, T_Documento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Migrado)    
      
  SELECT @I_ProcesoID, CCP.I_ConceptoID, C.T_ConceptoDesc, 0, 0, 0, @I_AlumnoDestino, @I_Grado, 9,    
  C.T_Clasificador, C.B_Calculado, C.I_Calculado, 1, @I_Anio, @I_Periodo, 0, 0, c.B_GrupoCodRc, c.I_GrupoCodRc,    
  c.B_ModalidadIngreso, c.I_ModalidadIngresoID, c.B_ConceptoAgrupa, c.I_ConceptoAgrupaID, 0, c.N_NroPagos, c.B_Porcentaje, c.C_Moneda,    
  c.I_Monto, c.I_MontoMinimo, c.T_DescripcionLarga, c.T_Documento, 1, 0, @I_UsuarioCre, getdate(), 0    
  FROM TI_ConceptoCategoriaPago CCP    
  INNER JOIN TC_Concepto C ON CCP.I_ConceptoID = C.I_ConceptoID    
  WHERE I_CatPagoID = @I_CatPagoID    
      
  COMMIT TRAN  
  
  SET @B_Result = 1    
  SET @T_Message = 'Inserción de datos correcta.'  
 END TRY  
 BEGIN CATCH  
  ROLLBACK TRAN  
  SET @I_ProcesoID = 0  
  SET @B_Result = 0  
  SET @T_Message = ERROR_MESSAGE()  
 END CATCH  
END  
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_ActualizarProceso')
DROP PROCEDURE [dbo].[USP_U_ActualizarProceso]
GO

CREATE PROCEDURE dbo.USP_U_ActualizarProceso  
@I_ProcesoID int,    
@I_CatPagoID int,    
@I_Anio smallint = null,    
@D_FecVencto datetime = null,    
@D_FecVenctoExt DATETIME = NULL,
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
			D_FecVenctoExt = @D_FecVenctoExt,
			I_Prioridad = @I_Prioridad,    
			N_CodBanco = @N_CodBanco,    
			T_ProcesoDesc = @T_ProcesoDesc,    
			B_Habilitado = @B_Habilitado,    
			I_UsuarioMod = @I_UsuarioMod,    
			D_FecMod = @CurrentDate,  
			I_CuotaPagoID = @I_CuotaPagoID  
		WHERE I_ProcesoID = @I_ProcesoID;  
      
		IF (@B_EditarFecha = 1) BEGIN    
			
			SET @D_FecVencto = CASE WHEN @D_FecVenctoExt IS NOT NULL 
				THEN (CASE WHEN DATEDIFF(DAY, @CurrentDate, @D_FecVencto) >= 0 THEN @D_FecVencto ELSE @D_FecVenctoExt END) 
				ELSE @D_FecVencto END;

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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_Procesos')
	DROP PROCEDURE [dbo].[USP_S_Procesos]
GO

CREATE PROCEDURE dbo.USP_S_Procesos  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SELECT p.I_ProcesoID, cp.I_CatPagoID, cp.T_CatPagoDesc, per.T_OpcionDesc AS T_PeriodoDesc, I_Periodo, per.T_OpcionCod AS C_PeriodoCod,  
  p.I_Anio, p.D_FecVencto, p.I_Prioridad, p.N_CodBanco, p.T_ProcesoDesc, cp.B_Obligacion, cp.I_Nivel, niv.T_OpcionCod AS C_Nivel,  
  cp.I_TipoAlumno, tipAlu.T_OpcionDesc AS T_TipoAlumno, tipAlu.T_OpcionCod as C_TipoAlumno, I_CuotaPagoID, p.D_FecVenctoExt
 FROM dbo.TC_Proceso p  
 INNER JOIN dbo.TC_CategoriaPago cp ON p.I_CatPagoID = cp.I_CatPagoID  
 LEFT JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = p.I_Periodo  
 LEFT JOIN dbo.TC_CatalogoOpcion niv ON niv.I_OpcionID = cp.I_Nivel  
 LEFT JOIN dbo.TC_CatalogoOpcion tipAlu ON tipAlu.I_OpcionID = cp.I_TipoAlumno  
 WHERE p.B_Eliminado = 0;
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DetalleObligaciones')
	DROP VIEW [dbo].[VW_DetalleObligaciones]
GO
  
CREATE VIEW [dbo].[VW_DetalleObligaciones]  
AS  
SELECT   
 det.I_ObligacionAluDetID, cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, 
 mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, mat.C_CodModIng,  
 per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo,   
 pro.T_ProcesoDesc, ISNULL(cp.T_ConceptoPagoDesc, con.T_ConceptoDesc) AS T_ConceptoDesc, cat.T_CatPagoDesc, det.I_Monto, det.B_Pagado, det.D_FecVencto, pro.I_Prioridad,  
 cab.C_Moneda, cp.I_TipoObligacion, cat.I_Nivel, niv.T_OpcionCod AS C_Nivel, niv.T_OpcionDesc AS T_Nivel, cat.I_TipoAlumno, tipal.T_OpcionCod AS C_TipoAlumno,   
 tipal.T_OpcionDesc AS T_TipoAlumno, cp.B_Mora, det.I_TipoDocumento, det.T_DescDocumento, 
 cp.B_EsPagoMatricula, mat.I_MatAluID, cp.I_ConcPagID, cab.B_EsAmpliacionCred
FROM dbo.VW_MatriculaAlumno mat  
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0   
INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID and det.B_Habilitado = 1 AND det.B_Eliminado = 0  
INNER JOIN dbo.TI_ConceptoPago cp ON cp.I_ConcPagID = det.I_ConcPagID AND det.B_Eliminado = 0  
INNER JOIN dbo.TC_Concepto con ON con.I_ConceptoID = cp.I_ConceptoID AND con.B_Eliminado = 0  
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cp.I_ProcesoID AND pro.B_Eliminado = 0  
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0  
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo  
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_OpcionID = cat.I_Nivel  
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_OpcionID = cat.I_TipoAlumno
GO



CREATE TYPE dbo.type_ConceptosObligacion AS TABLE(I_ConcPagID INT, I_Monto DECIMAL(15, 2))
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_RegistrarAmpliacionCredito')
	DROP PROCEDURE [dbo].[USP_I_RegistrarAmpliacionCredito]
GO
 
CREATE PROCEDURE dbo.USP_I_RegistrarAmpliacionCredito
@ConceptosObligacion [dbo].[type_ConceptosObligacion] READONLY,
@I_ProcesoID INT,
@I_MatAluID INT,
@D_FecVencto DATETIME,
@I_TipoDocumento INT,
@T_DescDocumento VARCHAR(250),
@UserID INT,
@B_Result BIT OUTPUT,
@T_Message NVARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @D_FechaAccion DATETIME,
			@I_ObligacionAluID INT,
			@I_MontoOblig DECIMAL(15, 2);

	BEGIN TRAN
	BEGIN TRY
		SET @D_FechaAccion = GETDATE();

		SET @I_MontoOblig = (SELECT SUM(I_Monto) FROM @ConceptosObligacion)
			
		INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_EsAmpliacionCred)
		VALUES (@I_ProcesoID, @I_MatAluID, 'PEN', @I_MontoOblig, @D_FecVencto, 0, 1, 0, @UserID, @D_FechaAccion, 1)

		SET @I_ObligacionAluID = SCOPE_IDENTITY();

		INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
		SELECT  @I_ObligacionAluID, I_ConcPagID, I_Monto, 0, @D_FecVencto, @I_TipoDocumento, @T_DescDocumento, 1, 0, @UserID, @D_FechaAccion, 0 FROM @ConceptosObligacion

		COMMIT TRAN
		SET @B_Result = 1;
		SET @T_Message = 'Registro realizado con éxito.';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @B_Result = 0;
		SET @T_Message = ERROR_MESSAGE();
	END CATCH
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ObtenerCuotaPago')
	DROP PROCEDURE [dbo].[USP_S_ObtenerCuotaPago]
GO

CREATE PROCEDURE USP_S_ObtenerCuotaPago
@I_ObligacionAluID INT  
AS  
BEGIN  
	SET NOCOUNT ON;  
  
	SELECT  
		cab.I_ObligacionAluID,  
		mat.C_CodAlu,  
		mat.C_RcCod,  
		mat.T_Nombre,  
		mat.T_ApePaterno,  
		mat.T_ApeMaterno,  
		mat.I_Anio,  
		mat.I_Periodo,  
		per.T_OpcionCod AS C_Periodo,  
		per.T_OpcionDesc AS T_Periodo,  
		pro.I_ProcesoID,  
		pro.T_ProcesoDesc,  
		cab.D_FecVencto,  
		pro.I_Prioridad,  
		pro.N_CodBanco,  
		cab.I_MontoOblig,  
		ISNULL(  
			(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro  
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID   
			WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual,  
		ISNULL(  
			(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro  
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID  
			WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0 AND det.B_Mora = 0), 0) AS I_MontoPagadoSinMora,  
		cab.B_Pagado,  
		cab.D_FecCre,
		cab.B_EsAmpliacionCred
	FROM dbo.VW_MatriculaAlumno mat  
	INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
	INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
	INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_OpcionID = mat.I_Periodo  
	WHERE cab.I_ObligacionAluID = @I_ObligacionAluID  
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
		set @I_MontoDeuda = isnull((SELECT SUM(cab.I_MontoOblig) FROM dbo.TR_ObligacionAluCab cab  
		 INNER JOIN (SELECT TOP 1 m.I_MatAluID FROM dbo.TC_MatriculaAlumno m   
		  WHERE m.B_Eliminado = 0 AND not m.I_MatAluID = @I_MatAluID AND m.C_CodAlu = @C_CodAlu AND m.C_CodRc = @C_CodRc  
		  order by m.I_Anio desc, m.C_Ciclo desc) mat ON mat.I_MatAluID = cab.I_MatAluID  
		 WHERE cab.B_Eliminado = 0 AND cab.B_Pagado = 0), 0)  
  
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


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_IU_GenerarObligacionesPosgrado_X_Ciclo]
@I_Anio INT,  
@I_Periodo INT,
@B_AlumnosSinObligaciones BIT,  
@C_CodEsc VARCHAR(2) = NULL,  
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
	@T_Message NVARCHAR(4000);
  
EXEC USP_IU_GenerarObligacionesPosgrado_X_Ciclo  2021, 19, NULL, NULL,  NULL, 1,  
@B_Result OUTPUT,  
@T_Message OUTPUT;
  
SELECT @B_Result, @T_Message
GO
*/  
BEGIN  
	SET NOCOUNT ON;  

	SET @B_SoloAplicarExtemporaneo = CASE WHEN @B_SoloAplicarExtemporaneo IS NULL THEN 0 ELSE @B_SoloAplicarExtemporaneo END;

	DECLARE @N_GradoMaestria CHAR(1) = '2';
	DECLARE @N_Doctorado CHAR(1) = '3';
    DECLARE @D_CurrentDate DATETIME = GETDATE();

	--1ro Obtener los conceptos según ano y periodo  
	SELECT 
		p.I_ProcesoID, p.D_FecVencto, 
		CASE WHEN p.D_FecVenctoExt IS NOT NULL THEN (CASE WHEN DATEDIFF(DAY, @D_CurrentDate, p.D_FecVencto) >=0 THEN p.D_FecVencto ELSE p.D_FecVenctoExt END) ELSE p.D_FecVencto END AS D_FecVenctoRegistro,
		cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,  
		ISNULL(conpag.B_Calculado, 0) AS B_Calculado, conpag.I_Calculado, ISNULL(conpag.B_GrupoCodRc, 0) AS B_GrupoCodRc,  conpag.I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng,   
		ISNULL(conpag.B_EsPagoMatricula, 0) AS B_EsPagoMatricula, ISNULL(conpag.B_EsPagoExtmp, 0) AS B_EsPagoExtmp, conpag.N_NroPagos, cp.I_Prioridad, cp.I_Nivel, niv.T_OpcionCod AS C_Nivel  
		INTO #tmp_conceptos_posgrado  
	FROM dbo.TC_Proceso p  
	INNER JOIN dbo.TC_CategoriaPago cp ON cp.I_CatPagoID = p.I_CatPagoID  
	INNER JOIN dbo.TI_ConceptoPago conpag ON conpag.I_ProcesoID = p.I_ProcesoID  
	INNER JOIN dbo.TC_Concepto con ON con.I_ConceptoID = conpag.I_ConceptoID  
	LEFT JOIN dbo.TC_CatalogoOpcion moding ON moding.I_ParametroID = 7 AND moding.I_OpcionID = conpag.I_ModalidadIngresoID  
	LEFT JOIN dbo.TC_CatalogoOpcion gr ON gr.I_ParametroID = 6 AND gr.I_OpcionID = conpag.I_GrupoCodRc  
	LEFT JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cp.I_Nivel  
	WHERE p.B_Habilitado = 1 AND p.B_Eliminado = 0 AND  
		conpag.B_Habilitado = 1 AND conpag.B_Eliminado = 0  AND ISNULL(conpag.B_Mora, 0) = 0 AND  
		cp.B_Obligacion = 1 AND p.I_Anio = @I_Anio AND p.I_Periodo = @I_Periodo AND cp.I_Nivel in (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 2 AND T_OpcionCod IN (@N_GradoMaestria, @N_Doctorado));
		--cp.B_Obligacion = 1 AND p.I_Anio = 2023 AND p.I_Periodo = 19 AND cp.I_Nivel in (SELECT I_OpcionID FROM dbo.TC_CatalogoOpcion WHERE I_ParametroID = 2 AND T_OpcionCod IN ('2', '3'));
  
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
		I_CredDesaprob TINYINT, 
		N_Grado CHAR(1)
	);

	DECLARE	@SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500);

	SET @SQLString = N'INSERT #Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob, N_Grado)
		SELECT m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0), a.N_Grado
		FROM dbo.TC_MatriculaAlumno m
		INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRc
		WHERE m.B_Habilitado = 1 AND m.B_Eliminado = 0 AND a.N_Grado in (@N_GradoMaestria, @N_Doctorado) AND
		m.I_Anio = @I_Anio AND m.I_Periodo = @I_Periodo ';

	IF (@C_CodAlu IS NOT NULL) AND (@C_CodRc IS NOT NULL) BEGIN
		SET @SQLString = @SQLString + N'AND m.C_CodAlu = @C_CodAlu AND m.C_CodRc = @C_CodRc ';
	END ELSE BEGIN
		IF NOT (@C_CodEsc IS NULL) AND NOT (@C_CodEsc = '') BEGIN
			SET @SQLString = @SQLString + N'AND a.C_CodEsc = @C_CodEsc ';
		END
	END

	IF (@B_Ingresante IS NOT NULL) BEGIN
		SET @SQLString = @SQLString + N'AND m.B_Ingresante = @B_Ingresante ';
	END

	IF (@B_AlumnosSinObligaciones = 1) BEGIN
		SET @SQLString = @SQLString + N'AND NOT EXISTS(SELECT c.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab c WHERE c.B_Habilitado = 1 AND c.B_Eliminado = 0 AND c.I_MatAluID = m.I_MatAluID) ';
	END

	SET @ParmDefinition = N'@N_GradoMaestria CHAR(1), @N_Doctorado CHAR(1), @I_Anio INT, @I_Periodo INT, 
		@C_CodAlu VARCHAR(20), @C_CodRc VARCHAR(3), @C_CodEsc VARCHAR(2), @B_Ingresante BIT';
   
	EXECUTE SP_EXECUTESQL @SQLString, @ParmDefinition,  
		@N_GradoMaestria = @N_GradoMaestria,
		@N_Doctorado = @N_Doctorado,  
		@I_Anio = @I_Anio,  
		@I_Periodo = @I_Periodo,  
		@C_CodAlu = @C_CodAlu,  
		@C_CodRc = @C_CodRc,
		@C_CodEsc = @C_CodEsc,
		@B_Ingresante = @B_Ingresante;

	--3ro Comienzo con el calculo las obligaciones por alumno almacenandolas en @Tmp_Procesos.  
	DECLARE @Tmp_Procesos TABLE (I_ProcesoID INT, I_ConcPagID INT, M_Monto DECIMAL(15,2), D_FecVencto DATETIME, I_TipoObligacion INT, I_Prioridad TINYINT);
  
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
  
		--Otras variables  
		@I_ObligacionAluID INT,  
		@I_MatAluID INT,  
		@C_EstMat VARCHAR(2),  
		@C_CodModIng VARCHAR(2),  
		@N_Grupo CHAR(1),  
		@I_TipoAlumno INT,  
		@I_MontoDeuda DECIMAL(15,2),  
		@I_CredDesaprob TINYINT,  
		@N_NroPagos TINYINT,  
		@N_Grado CHAR(1),
		@I_ObligacionAluDetID INT,
		@I_ConcPagID INT,
  
		--Variables para comprobar modificaciones  
		@I_MontoInicial DECIMAL(15,2),  
		@I_MontoActual DECIMAL(15,2),  
		@D_FecVenctoInicial DATETIME,  
		@D_FecVenctoActual DATETIME,  
		@I_ProcesoID INT, 
		@B_MatriculaPagada BIT,
		@B_Pagado BIT;

	DECLARE @Tmp_grupo_otros_pagos TABLE (id INT, I_ProcesoID INT);
	
	DECLARE @I_FilaActual_OtrsPag INT,  
		@I_CantRegistros_OtrsPag INT,  
		@I_ProcesoID_OtrsPag INT;
  
	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN  
		BEGIN TRAN  
		BEGIN TRY  
			--4to obtengo la información alumno por alumno e inicializo variables  
			SELECT @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng,   
				@N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0), @N_Grado = N_Grado,  
				@I_TipoAlumno = (CASE WHEN B_Ingresante = 0 THEN @I_AlumnoRegular ELSE @I_AlumnoIngresante END)   
			FROM #Tmp_MatriculaAlumno   
			WHERE id = @I_FilaActual  
  
			DELETE @Tmp_Procesos  
			
			IF (@B_SoloAplicarExtemporaneo = 0)
			BEGIN
				--Pagos de Matrícula  
				IF (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_posgrado  
				WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
				B_EsPagoMatricula = 1 AND C_CodModIng = @C_CodModIng AND C_Nivel = @N_Grado) = 1  
				BEGIN  
					INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
					SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_posgrado  
					WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
						B_EsPagoMatricula = 1 AND C_CodModIng = @C_CodModIng AND C_Nivel = @N_Grado  
				END  
				ELSE  
				BEGIN  
					IF (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_posgrado  
						WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
						B_EsPagoMatricula = 1 AND C_Nivel = @N_Grado AND C_CodModIng is NULL) = 1  
					BEGIN  
						INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
						SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_posgrado  
						WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
						B_EsPagoMatricula = 1 AND C_Nivel = @N_Grado AND C_CodModIng is NULL  
					END   
				END  
  
				--Pagos generales de matrícula  
				INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
				SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_posgrado  
				WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND  
					B_EsPagoMatricula = 0 AND B_Calculado = 0 AND B_GrupoCodRc = 0 AND B_EsPagoExtmp = 0 AND C_Nivel = @N_Grado  
  
				--Pagos extemoráneos  
				IF (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_posgrado  
				WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
					B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND C_Nivel = @N_Grado AND  
					DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0) = 1  
				BEGIN  
					INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
					SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_posgrado  
					WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
						B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND C_Nivel = @N_Grado AND  
						DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0  
				END
     
				--Monto de Pensión de ensenanza  
				IF (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_posgrado  
				WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_Pensiones AND C_Nivel = @N_Grado) = 1  
				BEGIN  
					SET @N_NroPagos = isnull((SELECT TOP 1 N_NroPagos FROM #tmp_conceptos_posgrado   
						WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_Pensiones AND C_Nivel = @N_Grado), 1);  
      
					with CTE_Recursivo AS  
					(  
						SELECT 1 AS num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_posgrado  
						WHERE I_TipoAlumno = @I_TipoAlumno AND B_Calculado = 1 AND I_Calculado = @I_Pensiones AND C_Nivel = @N_Grado  
						UNION ALL  
						SELECT num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad  
						FROM CTE_Recursivo  
						WHERE num < @N_NroPagos  
					)  
					INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
					SELECT I_ProcesoID, I_ConcPagID, CAST(M_Monto / @N_NroPagos AS DECIMAL(15,2)) AS M_Monto,   
						DATEADD(MONTH, num-1, D_FecVenctoRegistro), I_TipoObligacion, I_Prioridad  
					FROM CTE_Recursivo  
				END 
			END
			ELSE
			BEGIN
				--Pagos extemoráneos
				IF (SELECT COUNT(I_ProcesoID) FROM #tmp_conceptos_posgrado  
				WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
					B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND C_Nivel = @N_Grado AND  
					DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0) = 1  
				BEGIN  
					INSERT @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)  
					SELECT I_ProcesoID, I_ConcPagID, M_Monto, D_FecVenctoRegistro, I_TipoObligacion, I_Prioridad FROM #tmp_conceptos_posgrado  
					WHERE I_TipoAlumno = @I_TipoAlumno AND I_TipoObligacion = @I_Matricula AND   
						B_EsPagoMatricula = 0 AND B_EsPagoExtmp = 1 AND C_Nivel = @N_Grado AND  
						DATEDIFF(DAY, @D_CurrentDate, D_FecVencto) < 0
				END
			END
  
			--Grabando pago de matrícula  
			SET @I_ProcesoID = 0
			SET @B_MatriculaPagada = 0

			IF (@B_SoloAplicarExtemporaneo = 0)
			BEGIN
				IF EXISTS(SELECT p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 1)  
				BEGIN  
					SET @I_ProcesoID = (SELECT distinct p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 1);
  
					IF EXISTS(SELECT cab.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab cab   
						WHERE cab.B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID)  
					BEGIN  
						SELECT @I_MontoInicial = cab.I_MontoOblig, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado FROM dbo.TR_ObligacionAluCab cab   
						WHERE cab.B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID  
  
						SELECT @D_FecVenctoActual = p.D_FecVencto, @I_MontoActual = SUM(p.M_Monto) FROM @Tmp_Procesos p   
						WHERE p.I_Prioridad = 1 group by p.D_FecVencto  
  
						IF (@B_Pagado = 0)
						BEGIN  
							IF Not (DATEDIFF(DAY, @D_FecVenctoInicial, @D_FecVenctoActual) = 0) Or Not (@I_MontoInicial = @I_MontoActual)  
							BEGIN  
								UPDATE d SET d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate  
								FROM dbo.TR_ObligacionAluCab c  
								INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID  
								WHERE d.B_Eliminado = 0 AND c.B_Eliminado = 0 AND c.I_MatAluID = @I_MatAluID AND c.I_ProcesoID = @I_ProcesoID  
  
								UPDATE dbo.TR_ObligacionAluCab SET B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate  
								WHERE B_Eliminado = 0 AND I_MatAluID = @I_MatAluID AND I_ProcesoID = @I_ProcesoID  
  
								INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)  
								SELECT p.I_ProcesoID, @I_MatAluID, @C_Moneda, SUM(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto FROM @Tmp_Procesos p  
								WHERE p.I_Prioridad = 1   
								group by p.I_ProcesoID, p.D_FecVencto  
  
								SET @I_ObligacionAluID = SCOPE_IDENTITY()  
  
								INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)  
								SELECT @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate FROM @Tmp_Procesos p  
								WHERE p.I_Prioridad = 1  
							END  
						END
						ELSE
						BEGIN
							SET @B_MatriculaPagada = 1
						END
					END  
					ELSE  
					BEGIN  
						--INSERT  
						INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)  
						SELECT p.I_ProcesoID, @I_MatAluID, @C_Moneda, SUM(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto FROM @Tmp_Procesos p  
						WHERE p.I_Prioridad = 1   
						group by p.I_ProcesoID, p.D_FecVencto  
  
						SET @I_ObligacionAluID = SCOPE_IDENTITY()  
  
						INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)  
						SELECT @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 FROM @Tmp_Procesos p  
						WHERE p.I_Prioridad = 1  
					END  
				END  
			
				IF (@B_MatriculaPagada = 0) BEGIN			
					--Grabando otros pagos  
					IF EXISTS(SELECT p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 2)  
					BEGIN  
						IF NOT EXISTS(SELECT cab.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab cab  
							WHERE cab.B_Eliminado = 0 AND cab.I_MatAluID = @I_MatAluID AND  
							cab.I_ProcesoID in (SELECT p.I_ProcesoID FROM @Tmp_Procesos p WHERE p.I_Prioridad = 2))  
						BEGIN  
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
						END  
						ELSE  
						BEGIN  
							--Edición de obligaciones  
  
							IF EXISTS(SELECT id FROM @Tmp_grupo_otros_pagos) BEGIN  
								DELETE @Tmp_grupo_otros_pagos  
							END  
  
							INSERT @Tmp_grupo_otros_pagos(id, I_ProcesoID)  
							SELECT ROW_NUMBER() OVER (ORDER BY I_ProcesoID), I_ProcesoID FROM @Tmp_Procesos p  
							WHERE p.I_Prioridad = 2  
							group by p.I_ProcesoID  
       
							SET @I_FilaActual_OtrsPag = 1  
							SET @I_CantRegistros_OtrsPag = (SELECT MAX(id) FROM @Tmp_grupo_otros_pagos)  
  
							WHILE (@I_FilaActual_OtrsPag <= @I_CantRegistros_OtrsPag) BEGIN  
								--Los otros pagos se agrupan primero por proceso y luego por fecha de vcto.  
								SET @I_ProcesoID_OtrsPag = (SELECT I_ProcesoID FROM @Tmp_grupo_otros_pagos WHERE id = @I_FilaActual_OtrsPag)  
  
								IF EXISTS(SELECT cab.I_ObligacionAluID FROM dbo.TR_ObligacionAluCab cab  
								INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID  
								WHERE cab.B_Eliminado = 0 AND det.B_Eliminado = 0 AND cab.I_MatAluID = @I_MatAluID AND   
								cab.I_ProcesoID = @I_ProcesoID_OtrsPag AND cab.B_Pagado = 1) BEGIN  
         
									PRINT 'Existen al menos un pago realizado.'  
  
								END  
								ELSE BEGIN  
									UPDATE d SET d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate  
									FROM dbo.TR_ObligacionAluCab c  
									INNER JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluID = c.I_ObligacionAluID  
									WHERE d.B_Eliminado = 0 AND c.B_Eliminado = 0 AND c.I_MatAluID = @I_MatAluID AND c.I_ProcesoID = @I_ProcesoID_OtrsPag  
  
									UPDATE dbo.TR_ObligacionAluCab SET B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate  
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
								END  
  
								SET @I_FilaActual_OtrsPag = (@I_FilaActual_OtrsPag + 1)  
							END  
						END  
					END  
				END
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

			COMMIT TRAN

		END TRY  
		BEGIN CATCH  
			ROLLBACK TRAN  
			
			PRINT ERROR_MESSAGE()  
			PRINT ERROR_LINE()  
		END CATCH 
  
		SET @I_FilaActual = (@I_FilaActual +1)  
	END  
  
	SET @B_Result = 1;
	SET @T_Message = 'El proceso finalizó correctamente.';
END
GO