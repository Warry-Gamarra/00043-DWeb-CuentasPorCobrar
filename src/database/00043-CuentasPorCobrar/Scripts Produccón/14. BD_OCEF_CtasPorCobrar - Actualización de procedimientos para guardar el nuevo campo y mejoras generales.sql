USE BD_OCEF_CtasPorCobrar
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListadoEstadoObligaciones')
	DROP PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
@B_EsPregrado BIT,  
@I_Anio INT,  
@I_Periodo INT = NULL,  
@C_CodFac VARCHAR(2) = NULL ,  
@C_CodEsc VARCHAR(3) = NULL ,  
@C_RcCod VARCHAR(3) = NULL ,  
@B_Ingresante BIT = NULL,  
@B_ObligacionGenerada BIT = NULL,  
@B_Pagado BIT = NULL,  
@F_FecIni DATE = NULL,  
@F_FecFin DATE = NULL,  
@B_MontoPagadoDiff BIT = null,  
@C_CodAlu VARCHAR(10) = NULL,
@T_NomAlu VARCHAR(50) = NULL,
@T_ApePaternoAlu VARCHAR(50) = NULL,
@T_ApeMaternoAlu VARCHAR(50) = NULL
AS  
BEGIN  
 SET NOCOUNT ON;  
 DECLARE @Pregrado char(1) = '1',  
   @Maestria char(1) = '2',  
   @Doctorado char(1) = '3';
 
 SET @T_NomAlu = LTRIM(RTRIM(@T_NomAlu));
 SET @T_ApePaternoAlu = LTRIM(RTRIM(@T_ApePaternoAlu));
 SET @T_ApeMaternoAlu = LTRIM(RTRIM(@T_ApeMaternoAlu));

 DECLARE @SQLString NVARCHAR(4000),  
   @ParmDefinition NVARCHAR(500);
    
 SET @SQLString = N'SELECT mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod,   
  mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno,   
  mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,  
  mat.I_Anio,   
  mat.T_Periodo,  
  ISNULL(pro.T_ProcesoDesc, '''') AS T_ProcesoDesc,  
  cab.I_MontoOblig,  
  cab.D_FecVencto,  
  cab.B_Pagado AS B_Pagado,  
  ISNULL(SUM(pagpro.I_MontoPagado), 0) AS I_MontoPagadoActual,  
  cab.D_FecCre,  
  cab.D_FecMod  
  FROM dbo.VW_MatriculaAlumno mat  
  LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
  LEFT JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
  LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0  
  LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0  
  LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0  
  WHERE mat.B_Habilitado = 1 and mat.I_Anio = @I_Anio  
   ' + CASE WHEN @C_CodAlu IS NULL THEN '' ELSE ' and mat.C_CodAlu = @C_CodAlu ' END + '  
   ' + CASE WHEN @T_NomAlu IS NULL OR LEN(@T_NomAlu) = 0 THEN '' ELSE ' and mat.T_Nombre LIKE @T_NomAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
   ' + CASE WHEN @T_ApePaternoAlu IS NULL OR LEN(@T_ApePaternoAlu) = 0 THEN '' ELSE ' and mat.T_ApePaterno LIKE @T_ApePaternoAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
   ' + CASE WHEN @T_ApeMaternoAlu IS NULL OR LEN(@T_ApeMaternoAlu) = 0 THEN '' ELSE ' and mat.T_ApeMaterno LIKE @T_ApeMaternoAlu + ''%'' COLLATE Modern_Spanish_CI_AI ' END + '  
   ' + CASE WHEN @B_EsPregrado = 1 THEN 'and mat.N_Grado = @Pregrado' ELSE 'and mat.N_Grado IN (@Maestria, @Doctorado)' END + '  
   ' + CASE WHEN @I_Periodo IS NULL THEN '' ELSE 'and mat.I_Periodo = @I_Periodo' END + '  
   ' + CASE WHEN @C_CodFac IS NULL THEN '' ELSE 'and mat.C_CodFac = @C_CodFac' END + '  
   ' + CASE WHEN @C_CodEsc IS NULL THEN '' ELSE 'and mat.C_CodEsc = @C_CodEsc' END + '  
   ' + CASE WHEN @C_RcCod IS NULL THEN '' ELSE 'and mat.C_RcCod = @C_RcCod' END + '  
   ' + CASE WHEN @B_Ingresante IS NULL THEN '' ELSE 'and mat.B_Ingresante = @B_Ingresante' END + '  
   ' + CASE WHEN @B_ObligacionGenerada IS NULL THEN '' ELSE (CASE WHEN @B_ObligacionGenerada = 1 THEN 'and cab.I_ObligacionAluID IS NOT NULL' ELSE 'and cab.I_ObligacionAluID IS NULL' END) END  + '  
   ' + CASE WHEN @B_Pagado IS NULL  THEN '' ELSE 'and cab.B_Pagado = @B_Pagado' END + '  
   ' + CASE WHEN @F_FecIni IS NULL THEN '' ELSE 'and DATEDIFF(DAY, @F_FecIni, pagban.D_FecPago) >= 0' END + '  
   ' + CASE WHEN @F_FecFin IS NULL THEN '' ELSE 'and DATEDIFF(DAY, pagban.D_FecPago, @F_FecFin) >= 0' END + '  
  GROUP BY mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno,   
   mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,  
   mat.I_Anio, mat.T_Periodo, pro.T_ProcesoDesc, cab.I_MontoOblig, cab.D_FecVencto, cab.B_Pagado, cab.D_FecCre, cab.D_FecMod  
  ' + CASE WHEN @B_MontoPagadoDiff IS NULL OR @B_MontoPagadoDiff = 0 THEN '' ELSE 'HAVING NOT cab.I_MontoOblig = SUM(pagpro.I_MontoPagado)' END + '  
  ORDER BY mat.T_FacDesc, mat.T_DenomProg, mat.T_ApePaterno, mat.T_ApeMaterno';  
   
 SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_Periodo INT = NULL,   
  @C_CodFac VARCHAR(2), @C_CodEsc VARCHAR(2), @C_RcCod VARCHAR(3) = NULL , @B_Ingresante BIT = NULL, @B_Pagado BIT = NULL, @F_FecIni DATE = NULL, @F_FecFin DATE = NULL,  
  @C_CodAlu VARCHAR(10), @T_NomAlu VARCHAR(50), @T_ApePaternoAlu VARCHAR(50), @T_ApeMaternoAlu VARCHAR(50)';    
   
 EXECUTE sp_executesql @SQLString, @ParmDefinition,   
  @Pregrado = @Pregrado,  
  @Maestria = @Maestria,  
  @Doctorado = @Doctorado,  
  @I_Anio = @I_Anio,  
  @I_Periodo = @I_Periodo,  
  @C_CodFac = @C_CodFac,  
  @C_CodEsc = @C_CodEsc,  
  @C_RcCod = @C_RcCod,  
  @B_Ingresante = @B_Ingresante,  
  @B_Pagado = @B_Pagado,  
  @F_FecIni = @F_FecIni,  
  @F_FecFin = @F_FecFin,  
  @C_CodAlu = @C_CodAlu,
  @T_NomAlu = @T_NomAlu,
  @T_ApePaternoAlu = @T_ApePaternoAlu,
  @T_ApeMaternoAlu = @T_ApeMaternoAlu
/*  
EXEC USP_S_ListadoEstadoObligaciones  
@B_EsPregrado = 1,
@I_Anio = 2021,
@I_Periodo = NULL,
@C_CodFac = NULL,  
@C_CodEsc = NULL,  
@C_RcCod = NULL,  
@B_Ingresante = NULL,  
@B_ObligacionGenerada = NULL,  
@B_Pagado = NULL,  
@F_FecIni = NULL,  
@F_FecFin = NULL,  
@B_MontoPagadoDiff = NULL,  
@C_CodAlu = NULL,
@T_NomAlu = NULL,
@T_ApePaternoAlu = 'díaz',
@T_ApeMaternoAlu = 'díaz'
GO  
*/  
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataPago') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
		DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]

	DROP TYPE [dbo].[type_dataPago]
END
GO

CREATE TYPE [dbo].[type_dataPago] AS TABLE(
	--Datos de pago
	C_CodOperacion		varchar(50),
	T_NomDepositante	varchar(200),
	C_Referencia		varchar(50),
	D_FecPago			datetime,
	I_Cantidad			int,
	C_Moneda			varchar(3),
	I_MontoPago			decimal(15,2),
	I_InteresMora		decimal(15,2),
	T_LugarPago			varchar(250),
	--Identificar obligaciones
	C_CodAlu			varchar(20),
	C_CodRc				varchar(3),
	I_ProcesoID			int,
	D_FecVencto			datetime,
	I_EntidadFinanID	int,
	I_CtaDepositoID		int,
	T_InformacionAdicional varchar(250),
	T_ProcesoDesc varchar(250),
	I_CondicionPagoID	int,
	T_Observacion		varchar(250),
	C_CodigoInterno  varchar(250)
)
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO
  
CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]  
(  
  @Tbl_Pagos [dbo].[type_dataPago] READONLY  
 ,@Observacion varchar(250)  
 ,@D_FecRegistro datetime  
 ,@UserID  int  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @Tmp_PagoObligacion TABLE (  
  id INT IDENTITY(1,1),  
  I_ProcesoID   int NULL,  
  I_ObligacionAluID int NULL,  
  C_CodOperacion  varchar(50),  
  C_CodDepositante varchar(20),  
  T_NomDepositante varchar(200),  
  C_Referencia  varchar(50),  
  D_FecPago   datetime,  
  D_FecVencto   datetime,  
  D_FecVenctoBD  datetime,  
  I_Cantidad   int,  
  C_Moneda   varchar(3),  
  I_MontoOblig  decimal(15,2) NULL,  
  I_MontoPago   decimal(15,2),  
  I_InteresMora  decimal(15,2),  
  T_LugarPago   varchar(250),  
  I_EntidadFinanID int,  
  I_CtaDepositoID  int,  
  B_Pagado   bit NULL,  
  B_Success   bit,  
  T_ErrorMessage  varchar(250),  
  T_InformacionAdicional  varchar(250),  
  T_ProcesoDesc  varchar(250),  
  I_CondicionPagoID int,  
  T_Observacion  varchar(250),
  C_CodigoInterno  varchar(250)
 );  
  
 DECLARE @Tmp_DetalleObligacion TABLE(  
  id INT,  
  I_ObligacionAluDetID int,  
  I_MontoDet   decimal(15,2),  
  I_MontoPagadoDet decimal(15,2)  
 );  
  
 WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto, B_Pagado, I_MontoOblig)  
 AS   
 (  
  SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto, cab.B_Pagado, cab.I_MontoOblig  
  FROM dbo.TC_MatriculaAlumno m  
  LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID AND cab.B_Eliminado = 0  
  WHERE m.B_Eliminado = 0  
 )  
 INSERT @Tmp_PagoObligacion(I_ProcesoID, I_ObligacionAluID, C_CodOperacion, C_CodDepositante, T_NomDepositante,   
  C_Referencia, D_FecPago, D_FecVencto, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, I_InteresMora, T_LugarPago, I_EntidadFinanID, I_CtaDepositoID, B_Pagado,  
  T_InformacionAdicional, T_ProcesoDesc, D_FecVenctoBD, I_CondicionPagoID, T_Observacion, C_CodigoInterno)  
   
 SELECT m.I_ProcesoID, m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,  
  p.C_Referencia, p.D_FecPago, p.D_FecVencto, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.I_EntidadFinanID, I_CtaDepositoID, m.B_Pagado,  
  p.T_InformacionAdicional, p.T_ProcesoDesc, m.D_FecVencto, p.I_CondicionPagoID, p.T_Observacion, p.C_CodigoInterno
  
 FROM @Tbl_Pagos p  
 LEFT JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND   
  m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0  
  
 DECLARE @I_FilaActual  int = 1,  
   @I_CantRegistros int = (select count(id) from @Tmp_PagoObligacion),  
   @I_ProcesoID  int,  
   @I_ObligacionAluID int,  
   --PAGO EN BANCO  
   @I_PagoBancoID  int,     
   @C_CodOperacion  varchar(50),  
   @C_CodDepositante varchar(20),  
   @T_NomDepositante varchar(200),  
   @C_Referencia  varchar(50),  
   @D_FecPago   datetime,  
   @I_Cantidad   int,  
   @C_Moneda   varchar(3),  
   @I_MontoPago  decimal(15,2),  
   @I_InteresMora  decimal(15,2),  
   @T_LugarPago  varchar(250),  
   @I_EntidadFinanID int,  
   @I_CtaDepositoID int,  
   @T_InformacionAdicional varchar(250),  
   @I_CondicionPagoID int,  
   @T_Observacion  varchar(250),  
   @C_CodigoInterno varchar(250),
   --PAGO DETALLE  
   @I_FilaActualDet int,  
   @I_CantRegistrosDet int,  
   @I_ObligacionAluDetID int,     
   @I_MontoOligacionDet decimal(15,2),  
   @I_MontoPagadoActual decimal(15,2),  
   @I_SaldoPendiente decimal(15,2),  
   @I_MontoAPagar  decimal(15,2),  
   @I_NuevoSaldoPend decimal(15,2),  
   @I_PagoDemas  decimal(15,2),  
   @B_PagoDemas  bit,  
   @B_Pagado   bit,  
   --MORA  
   @I_ConcPagID  int,  
   @D_FecVencto  datetime,  
   --CONTROL ERRORES  
   @D_FecVenctoBD  datetime,  
   @B_ExisteError  bit,  
   @B_CodOpeCorrecto bit,  
   @B_ObligPagada  bit,  
   --Constantes  
   @CondicionCorrecto int = 131,--PAGO CORRECTO  
   @CondicionExtorno int = 132,--PAGO EXTORNADO  
   @PagoTipoObligacion int = 133--OBLIGACION  
  
 WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN  
    
  SET @B_ExisteError = 0  
  
  SELECT  @I_ProcesoID = I_ProcesoID,  
    @I_ObligacionAluID = I_ObligacionAluID,   
    @C_CodOperacion = C_CodOperacion,   
    @C_CodDepositante = C_CodDepositante,   
    @T_NomDepositante = T_NomDepositante,   
    @C_Referencia = C_Referencia,   
    @D_FecPago = D_FecPago,   
    @D_FecVencto = D_FecVencto,  
    @I_Cantidad = I_Cantidad,  
    @C_Moneda = C_Moneda,   
    @I_MontoPago = I_MontoPago,  
    @I_InteresMora = I_InteresMora,  
    @T_LugarPago= T_LugarPago,  
    @I_EntidadFinanID = I_EntidadFinanID,  
    @I_CtaDepositoID = I_CtaDepositoID,  
    @B_ObligPagada = B_Pagado,  
    @T_InformacionAdicional = T_InformacionAdicional,  
    @D_FecVenctoBD = D_FecVenctoBD,  
    @I_CondicionPagoID = I_CondicionPagoID,  
    @T_Observacion = CASE WHEN (I_CondicionPagoID = @CondicionCorrecto) THEN @Observacion ELSE T_Observacion END  ,
	@C_CodigoInterno = C_CodigoInterno
   FROM @Tmp_PagoObligacion WHERE id = @I_FilaActual  
  
  IF (@I_ObligacionAluID IS NULL) BEGIN  
   SET @B_ExisteError = 1  
   UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe obligaciones para este alumno.' WHERE id = @I_FilaActual  
  END  
  
  IF (@B_ExisteError = 0) AND NOT(@I_CondicionPagoID = @CondicionExtorno) AND (@B_ObligPagada = 1) BEGIN  
   SET @B_ExisteError = 1  
   UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'Esta obligación ya ha sido pagada con anterioridad.' WHERE id = @I_FilaActual  
  END  
  
  IF  (@B_ExisteError = 0) BEGIN  
   EXEC dbo.USP_S_ValidarCodOperacionObligacion @C_CodOperacion, @C_CodDepositante, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT  
  
   IF NOT (@B_CodOpeCorrecto = 1) BEGIN  
    SET @B_ExisteError = 1  
      
    UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual  
   END  
  END  
  
  IF (@B_ExisteError = 0) AND NOT(@I_CondicionPagoID = @CondicionExtorno) AND (@I_InteresMora > 0) AND  
   NOT EXISTS(SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1) BEGIN  
  
   SET @B_ExisteError = 1  
      
   UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe un concepto para guardar el Interés moratorio.' WHERE id = @I_FilaActual  
  END  
    
  
  IF (@B_ExisteError = 0) AND (@I_CtaDepositoID IS NULL) BEGIN  
   SET @I_CtaDepositoID = (SELECT cta.I_CtaDepositoID FROM dbo.TI_CtaDepo_Proceso cta  
    INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cta.I_CtaDepositoID  
    WHERE cta.B_Habilitado = 1 AND cta.B_Eliminado = 0 AND   
     cta.I_ProcesoID = @I_ProcesoID and c.I_EntidadFinanID = @I_EntidadFinanID)  
  
   IF (@I_CtaDepositoID IS NULL) BEGIN  
    SET @B_ExisteError = 1  
      
    UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe una Cuenta asignada para registrar la obligación.' WHERE id = @I_FilaActual  
   END  
  END  
  
  IF (@B_ExisteError = 0) BEGIN  
   BEGIN TRANSACTION  
   BEGIN TRY  
    INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,   
     C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,  
     T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno)  
    VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,   
     @C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @T_Observacion,  
     @T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoObligacion, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno)  
  
    SET @I_PagoBancoID = SCOPE_IDENTITY()  
  
    IF (@I_CondicionPagoID = @CondicionCorrecto) BEGIN  
  
     DELETE FROM @Tmp_DetalleObligacion  
  
     INSERT @Tmp_DetalleObligacion(id, I_ObligacionAluDetID, I_MontoDet, I_MontoPagadoDet)  
     SELECT ROW_NUMBER() OVER (ORDER BY det.I_Monto ASC), det.I_ObligacionAluDetID, det.I_Monto, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoPagado   
     FROM dbo.TR_ObligacionAluDet det  
     LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND p.B_Anulado = 0  
     WHERE det.I_ObligacionAluID = @I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 0 AND det.B_Pagado = 0  
     GROUP BY det.I_ObligacionAluDetID, det.I_Monto  
     ORDER BY det.I_Monto ASC  
  
     SET @I_FilaActualDet = 1  
     SET @I_CantRegistrosDet = (SELECT COUNT(*) FROM @Tmp_DetalleObligacion)  
  
     WHILE (@I_FilaActualDet <= @I_CantRegistrosDet AND @I_MontoPago > 0) BEGIN  
  
      SELECT  
       @I_ObligacionAluDetID = I_ObligacionAluDetID,   
       @I_MontoOligacionDet = I_MontoDet,   
       @I_MontoPagadoActual = I_MontoPagadoDet   
      FROM @Tmp_DetalleObligacion WHERE id = @I_FilaActualDet  
  
      SET @I_SaldoPendiente = @I_MontoOligacionDet - @I_MontoPagadoActual  
  
      EXEC dbo.USP_AsignarPagoDetalleObligacion  
       @I_FilaActualDet = @I_FilaActualDet,  
       @I_CantRegistrosDet = @I_CantRegistrosDet,  
       @I_SaldoPendiente  = @I_SaldoPendiente,  
       @I_MontoPago = @I_MontoPago OUTPUT,  
       @B_Pagado = @B_Pagado OUTPUT,  
       @I_MontoAPagar = @I_MontoAPagar OUTPUT,  
       @I_NuevoSaldoPend = @I_NuevoSaldoPend OUTPUT,  
       @I_PagoDemas = @I_PagoDemas OUTPUT,  
       @B_PagoDemas = @B_PagoDemas OUTPUT  
      
      INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,  
       D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)  
      VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_MontoAPagar, @I_NuevoSaldoPend, @I_PagoDemas, @B_PagoDemas,  
       @D_FecRegistro, @UserID, 0, @I_CtaDepositoID)  
  
      IF (@B_Pagado = 1) BEGIN  
       UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro  
       WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID  
      END  
  
      SET @I_FilaActualDet = @I_FilaActualDet + 1  
     END  
      
     IF NOT EXISTS (SELECT d.I_ObligacionAluID FROM dbo.TR_ObligacionAluDet d   
      WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND d.B_Mora = 0 AND d.B_Pagado = 0)  
     BEGIN  
      UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = 1, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro  
      WHERE I_ObligacionAluID = @I_ObligacionAluID  
     END  
  
     IF (@I_InteresMora > 0) BEGIN  
      SET @I_ConcPagID = (SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1)  
  
      INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)  
      VALUES (@I_ObligacionAluID, @I_ConcPagID, @I_InteresMora, 1, @D_FecVencto, 1, 0, @UserID, @D_FecRegistro, 1)  
  
      SET @I_ObligacionAluDetID = SCOPE_IDENTITY()  
  
      INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,   
       D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)  
      VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_InteresMora, 0, 0, 0,@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)  
     END  
  
     UPDATE @Tmp_PagoObligacion SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual  
      
    END ELSE BEGIN  
     UPDATE @Tmp_PagoObligacion SET B_Success = 1, T_ErrorMessage = @T_Observacion WHERE id = @I_FilaActual  
    END  
  
    COMMIT TRANSACTION  
   END TRY  
   BEGIN CATCH  
    ROLLBACK TRANSACTION  
  
    UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual  
   END CATCH  
  END  
  
  SET @I_FilaActual = @I_FilaActual + 1  
 END  
  
 SELECT * FROM @Tmp_PagoObligacion  
END  
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataPagoTasa') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoTasas')
		DROP PROCEDURE [dbo].[USP_I_GrabarPagoTasas]

	DROP TYPE [dbo].[type_dataPagoTasa]
END
GO

CREATE TYPE [dbo].[type_dataPagoTasa] AS TABLE(
	C_CodDepositante	varchar(20),
	T_NomDepositante	varchar(200),
	C_CodServicio		varchar(20),
	C_CodTasa			varchar(5),
	T_TasaDesc			varchar(200),
	C_CodOperacion		varchar(50),
	C_Referencia		varchar(50),
	I_EntidadFinanID	int,
	I_CtaDepositoID		int,
	D_FecPago			datetime,
	I_Cantidad			int,
	C_Moneda			varchar(3),
	I_MontoPago			decimal(15,2),
	I_InteresMora		decimal(15,2),
	T_LugarPago			varchar(250),
	T_InformacionAdicional varchar(250),
	C_CodigoInterno varchar(250)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoTasas')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoTasas]  
(  
  @Tbl_Pagos [dbo].[type_dataPagoTasa] READONLY  
 ,@Observacion varchar(250)  
 ,@D_FecRegistro datetime  
 ,@UserID  int  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @Tmp_PagoTasas TABLE (  
  id     int identity(1,1),  
  I_TasaUnfvID  int,  
  I_MontoTasa   decimal(15,2),  
  C_CodDepositante varchar(20),  
  T_NomDepositante varchar(200),  
  C_CodTasa   varchar(5),  
  T_TasaDesc   varchar(200),  
  C_CodOperacion  varchar(50),  
  C_Referencia  varchar(50),  
  I_EntidadFinanID int,  
  I_CtaDepositoID  int,  
  D_FecPago   datetime,  
  I_Cantidad   int,  
  C_Moneda   varchar(3),  
  I_MontoPago   decimal(15,2),  
  I_InteresMora  decimal(15,2),  
  T_LugarPago   varchar(250),  
  T_InformacionAdicional varchar(250),  
  B_Success   bit,  
  T_ErrorMessage  varchar(250),
  C_CodigoInterno varchar(250)
 );  
  
 INSERT @Tmp_PagoTasas(I_TasaUnfvID, I_MontoTasa, C_CodDepositante, T_NomDepositante, C_CodTasa,   
  T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, D_FecPago,   
  I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional, C_CodigoInterno)  
 SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,  
  CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,  
  p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID,  
  CASE WHEN p.I_CtaDepositoID IS NULL   
   THEN   
    (SELECT tc.I_CtaDepositoID FROM VW_PagoTasas_X_Cuenta tc WHERE tc.I_TasaUnfvID = t.I_TasaUnfvID AND tc.C_CodServicio = p.C_CodServicio AND tc.I_EntidadFinanID = p.I_EntidadFinanID)  
   ELSE p.I_CtaDepositoID END,  
  p.D_FecPago, p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional, p.C_CodigoInterno  
 FROM @Tbl_Pagos p  
 LEFT JOIN dbo.TI_TasaUnfv t ON t.C_CodTasa = p.C_CodTasa and t.B_Habilitado = 1 and t.B_Eliminado = 0  
  
 DECLARE @I_FilaActual  int = 1,  
   @I_CantRegistros int = (select count(id) from @Tmp_PagoTasas),  
   @I_SaldoAPagar  decimal(15,2),  
   @I_PagoDemas  decimal(15,2),  
   @B_PagoDemas  bit,  
   -----------------------------------------------------------  
   @I_PagoBancoID  int,  
   @I_TasaUnfvID  int,  
   @I_MontoTasa  decimal(15,2),  
   @C_CodDepositante varchar(20),  
   @T_NomDepositante varchar(200),  
   @C_CodTasa   varchar(3),  
   @T_TasaDesc   varchar(3),  
   @C_CodOperacion  varchar(50),  
   @C_Referencia  varchar(50),  
   @I_EntidadFinanID int,  
   @I_CtaDepositoID int,  
   @D_FecPago   datetime,  
   @I_Cantidad   int,  
   @C_Moneda   varchar(3),  
   @I_MontoPago  decimal(15,2),  
   @I_InteresMora  decimal(15,2),  
   @T_LugarPago  varchar(250),   
   @T_InformacionAdicional varchar(250),  
   @C_CodigoInterno varchar(250),
   @B_ExisteError  bit,  
   @B_CodOpeCorrecto bit,  
   --Constantes  
   @CondicionCorrecto int = 131,--PAGO CORRECTO  
   @PagoTipoTasa  int = 134--OBLIGACION  
   
 WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN  
    
  SET @B_ExisteError = 0  
  
  SELECT  @I_TasaUnfvID = I_TasaUnfvID,  
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
	@C_CodigoInterno = C_CodigoInterno
   FROM @Tmp_PagoTasas WHERE id = @I_FilaActual  
  
  IF (@I_TasaUnfvID IS NULL) BEGIN  
   SET @B_ExisteError = 1  
   UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'No existe el código de tasa.' WHERE id = @I_FilaActual  
  END  
  
  IF (@B_ExisteError = 0 AND @I_CtaDepositoID IS NULL) BEGIN  
   SET @B_ExisteError = 1  
   UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Esta tasa no tiene asignado una cuenta.' WHERE id = @I_FilaActual  
  END  
  
  IF  (@B_ExisteError = 0) BEGIN  
   EXEC USP_S_ValidarCodOperacionTasa @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT  
  
   IF NOT (@B_CodOpeCorrecto = 1) BEGIN  
    SET @B_ExisteError = 1  
      
    UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual  
   END  
  END  
  
  IF (@B_ExisteError = 0) BEGIN  
   BEGIN TRANSACTION  
   BEGIN TRY  
    INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,   
     C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,  
     T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno)  
    VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,   
     @C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,  
     @T_InformacionAdicional, @CondicionCorrecto, @PagoTipoTasa, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno)  
  
    SET @I_PagoBancoID = SCOPE_IDENTITY()  
  
    --Pago menor  
    SET @I_SaldoAPagar = @I_MontoTasa - @I_MontoPago  
   
    SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END  
  
    --Pago excedente  
    SET @I_PagoDemas = @I_MontoPago - @I_MontoTasa  
       
    SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END  
  
    SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END  
  
    INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_TasaUnfvID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,  
     B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)  
    VALUES(@I_PagoBancoID, @I_TasaUnfvID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas,   
     @B_PagoDemas, @D_FecRegistro, @UserID, 0, @I_CtaDepositoID)  
  
    UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual  
  
    COMMIT TRANSACTION  
   END TRY  
   BEGIN CATCH  
    ROLLBACK TRANSACTION  
  
    UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual  
   END CATCH  
  END  
  
  SET @I_FilaActual = @I_FilaActual + 1  
 END  
  
 SELECT * FROM @Tmp_PagoTasas  
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarPagoTasas')
	DROP PROCEDURE [dbo].[USP_S_ListarPagoTasas]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarPagoTasas]  
@I_EntidadFinanID INT = NULL,  
@C_CodOperacion  VARCHAR(50) = NULL,  
@C_CodDepositante VARCHAR(20) = NULL,  
@T_NomDepositante VARCHAR(200) = NULL,  
@D_FechaInicio  DATETIME = NULL,  
@D_FechaFin   DATETIME = NULL  
AS  
BEGIN
--Se actualizó el filtro de fechas para buscar incluir los minutos en la fecha de pago.
 SET NOCOUNT ON;  
  
 DECLARE @SQLString NVARCHAR(2000),  
   @SQLParmString NVARCHAR(2000) = '',  
   @ParmDefinition NVARCHAR(500)  
  
 SET @SQLString = N'SELECT t.T_EntidadDesc, t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto,   
  t.C_CodOperacion, t.C_CodDepositante, t.T_NomDepositante, t.D_FecPago, t.I_MontoPagado
 FROM dbo.VW_PagoTasas t '  
  
 IF (@I_EntidadFinanID IS NOT NULL) BEGIN  
  SET @SQLParmString = 'WHERE t.I_EntidadFinanID = @I_EntidadFinanID '  
 END  
  
 IF (@C_CodOperacion IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.C_CodOperacion = @C_CodOperacion '  
 END  
  
 IF (@C_CodDepositante IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.C_CodDepositante = @C_CodDepositante '  
 END  
  
 IF (@T_NomDepositante IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.T_NomDepositante LIKE ''%''+@T_NomDepositante+''%'' '  
 END  
  
 IF (@D_FechaInicio IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 'DATEDIFF(MINUTE, t.D_FecPago, @D_FechaInicio) <= 0 '  
 END  
  
 IF (@D_FechaFin IS NOT NULL) BEGIN  
  SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 'DATEDIFF(MINUTE, t.D_FecPago, @D_FechaFin) >= 0 '  
 END  
  
 SET @ParmDefinition = N'@I_EntidadFinanID INT = NULL, @C_CodOperacion VARCHAR(50), @C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200),   
  @D_FechaInicio DATETIME, @D_FechaFin DATETIME'  
  
 SET @SQLString = @SQLString + @SQLParmString  
  
 EXECUTE sp_executesql @SQLString, @ParmDefinition,  
  @I_EntidadFinanID = @I_EntidadFinanID,  
  @C_CodOperacion = @C_CodOperacion,  
  @C_CodDepositante = @C_CodDepositante,  
  @T_NomDepositante = @T_NomDepositante,  
  @D_FechaInicio = @D_FechaInicio,  
  @D_FechaFin = @D_FechaFin  
/*  
EXEC USP_S_ListarPagoTasas   
 @I_EntidadFinanID = 2,  
 @C_CodOperacion = NULL,  
 @C_CodDepositante = NULL,  
 @T_NomDepositante = NULL,  
 @D_FechaInicio = '20210913 13:30',  
 @D_FechaFin = '20210913 14:30'  
GO
*/  
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoBancoObligaciones')
	DROP VIEW [dbo].[VW_PagoBancoObligaciones]
GO
  
CREATE VIEW [dbo].[VW_PagoBancoObligaciones]
AS  
 SELECT b.I_PagoBancoID, e.I_EntidadFinanID, e.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, b.C_CodOperacion, b.C_CodDepositante,   
  c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno,   
  b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc AS T_Condicion, b.T_Observacion,   
  b.T_MotivoCoreccion, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoProcesado, b.C_CodigoInterno
 FROM TR_PagoBanco b  
 LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID AND p.B_Anulado = 0  
 LEFT JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluDetID = p.I_ObligacionAluDetID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0  
 LEFT JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = d.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0  
 LEFT JOIN dbo.VW_MatriculaAlumno m ON m.I_MatAluID = c.I_MatAluID  
 INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID = b.I_EntidadFinanID  
 INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = b.I_CtaDepositoID  
 INNER JOIN dbo.TC_CatalogoOpcion cn ON cn.I_OpcionID = b.I_CondicionPagoID  
 WHERE b.I_TipoPagoID = 133 AND b.B_Anulado = 0  
 GROUP BY b.I_PagoBancoID, e.I_EntidadFinanID, cd.I_CtaDepositoID, cd.C_NumeroCuenta, e.T_EntidadDesc, b.C_CodOperacion, b.C_CodDepositante, c.I_ObligacionAluID, m.I_MatAluID, m.C_CodAlu,   
  b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno,   
  b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc, b.T_Observacion, b.T_MotivoCoreccion, b.C_CodigoInterno
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas')
	DROP VIEW [dbo].[VW_PagoTasas]
GO

CREATE VIEW [dbo].[VW_PagoTasas]  
AS  
 SELECT pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc,   
  tu.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto,   
  pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre,
  pag.C_CodigoInterno
 FROM dbo.TR_PagoBanco pag  
 INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID  
 INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID  
 INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID  
 INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID  
 INNER JOIN dbo.TI_TasaUnfv tu ON tu.I_TasaUnfvID = pr.I_TasaUnfvID  
 LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = tu.T_Clasificador  
 WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND t.B_Eliminado = 0 AND ef.B_Eliminado = 0 AND tu.B_Eliminado = 0  
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_U_DesenlazarPagoObligacion')
	DROP PROCEDURE [dbo].[USP_U_DesenlazarPagoObligacion]
GO
 
CREATE PROCEDURE [dbo].[USP_U_DesenlazarPagoObligacion]  
@I_PagoBancoID INT,  
@T_MotivoCoreccion VARCHAR(250),  
@UserID INT,  
@B_Result BIT OUTPUT,  
@T_Message VARCHAR(4000) OUTPUT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 BEGIN TRAN  
 BEGIN TRY  
  DECLARE @CurrentDate DATETIME = GETDATE(),  
    @PagoDesenlazado INT = 137  
  
  UPDATE cab SET B_Pagado = 0, cab.I_UsuarioMod = @UserID, cab.D_FecMod = @CurrentDate 
  FROM dbo.TR_ObligacionAluCab cab  
  INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0  
  INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND p.B_Anulado = 0  
  WHERE p.I_PagoBancoID = @I_PagoBancoID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0  
  
  UPDATE det SET det.B_Pagado = 0, det.I_UsuarioMod = @UserID, det.D_FecMod = @CurrentDate 
  FROM dbo.TR_ObligacionAluDet det  
  INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID  
  WHERE p.I_PagoBancoID = @I_PagoBancoID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 0

  UPDATE det SET det.B_Pagado = 0, det.B_Habilitado = 0, det.B_Eliminado = 1, det.I_UsuarioMod = @UserID, det.D_FecMod = @CurrentDate 
  FROM dbo.TR_ObligacionAluDet det  
  INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID  
  WHERE p.I_PagoBancoID = @I_PagoBancoID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 1
  
  UPDATE dbo.TR_PagoBanco SET  
   I_CondicionPagoID = @PagoDesenlazado,  
   T_MotivoCoreccion = @T_MotivoCoreccion,  
   D_FecMod = @CurrentDate,  
   I_UsuarioMod = @UserID  
  WHERE I_PagoBancoID = @I_PagoBancoID  
  
  UPDATE dbo.TRI_PagoProcesadoUnfv SET  
   B_Anulado = 1,  
   D_FecMod = @CurrentDate,  
   I_UsuarioMod = @UserID  
  WHERE I_PagoBancoID = @I_PagoBancoID  
  
  COMMIT TRAN  
  SET @T_Message = 'Acción realizada con éxito.'  
  SET @B_Result = 1  
 END TRY  
 BEGIN CATCH  
  ROLLBACK TRAN  
  SET @T_Message = ERROR_MESSAGE()  
  SET @B_Result = 0  
 END CATCH  
END  
GO