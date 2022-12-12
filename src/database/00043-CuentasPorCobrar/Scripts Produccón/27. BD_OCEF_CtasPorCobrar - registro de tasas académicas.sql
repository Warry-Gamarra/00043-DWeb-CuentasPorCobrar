USE BD_OCEF_CtasPorCobrar
GO


--ACTUALIZACIÓN DEL ARCHIVO DE RESULTADO DEL BCP
BEGIN TRAN
BEGIN TRY
	--C_CodDepositante
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 20, I_ColumnaFin = 27, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 38

	--T_NomDepositante
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 1, I_ColumnaFin = 0, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 39

	--C_CodTasa
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 15, I_ColumnaFin = 19, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 34

	--T_TasaDesc
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 1, I_ColumnaFin = 0, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 35

	--C_CodOperacion
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 125, I_ColumnaFin = 130, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 45

	--T_Referencia
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 131, I_ColumnaFin = 152, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 46

	--D_FecPago
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 58, I_ColumnaFin = 65, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 36

	--D_HoraPago
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 169, I_ColumnaFin = 174, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 37

	--I_InteresMora
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 1, I_ColumnaFin = 0, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 42

	--I_MontoPago
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 74, I_ColumnaFin = 88, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 41

	--T_LugarPago
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 153, I_ColumnaFin = 156, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 43

	--T_InformacionAdicional
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 28, I_ColumnaFin = 57, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 40

	--C_CodigoInterno
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 66, I_ColumnaFin = 73, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 66
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH
GO



SET IDENTITY_INSERT dbo.TS_CampoTablaPago ON
GO
INSERT dbo.TS_CampoTablaPago(I_CampoPagoID, T_TablaPagoNom, T_CampoPagoNom, T_CampoInfoDesc, I_TipoArchivoID, B_Habilitado, B_Eliminado)
VALUES(33, 'type_dataPagoTasa', 'C_Extorno', 'Extorno', 4, 1, 0)	
GO
SET IDENTITY_INSERT dbo.TS_CampoTablaPago OFF
GO
DBCC CHECKIDENT ('dbo.TS_CampoTablaPago', RESEED, 33);  
GO

INSERT TC_ColumnaSeccion(T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, B_Habilitado, B_Eliminado, I_SecArchivoID, I_CampoPagoID) 
VALUES('C_Extorno', 187, 187, 1, 0, 4, 33)
GO

INSERT TC_ColumnaSeccion(T_ColSecDesc, I_ColumnaInicio, I_ColumnaFin, B_Habilitado, B_Eliminado, I_SecArchivoID, I_CampoPagoID) 
VALUES('C_Extorno', 1, 0, 1, 0, 3, 33)
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataPagoTasa') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoTasas') BEGIN
		DROP PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
	END

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
	C_CodigoInterno varchar(250),
	T_SourceFileName varchar(250),
	C_Extorno		varchar(1)
)
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
   @C_Extorno varchar(1),
   --Constantes  
   @CondicionCorrecto int = 131,--PAGO CORRECTO
   @Extornado int = 132,--Extorno
   @I_CondicionPagoID int,
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
	@C_CodigoInterno = C_CodigoInterno,
	@C_Extorno = C_Extorno
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

   SET @I_CondicionPagoID = (CASE WHEN @C_Extorno = 'E' THEN @Extornado ELSE @CondicionCorrecto END)

    INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad,   
     C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,  
     T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora, C_CodigoInterno)  
    VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad,   
     @C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,  
     @T_InformacionAdicional, @I_CondicionPagoID, @PagoTipoTasa, @I_CtaDepositoID, @I_InteresMora, @C_CodigoInterno)  
  
    SET @I_PagoBancoID = SCOPE_IDENTITY()

	IF (@I_CondicionPagoID = @CondicionCorrecto) BEGIN
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
	END

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



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarAlumnoMultaNoVotar')
	DROP PROCEDURE [dbo].[USP_I_GrabarAlumnoMultaNoVotar]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarAlumnoMultaNoVotar]
(  
  @Tbl_AlumnosMultaNoVotar [dbo].[type_dataAlumnoMultaNoVotar] READONLY  
 ,@D_FecRegistro datetime  
 ,@UserID  int  
 ,@B_Result  bit    OUTPUT  
 ,@T_Message  nvarchar(4000) OUTPUT  
)  
AS  
BEGIN  
 SET NOCOUNT ON  
 BEGIN TRY  
   BEGIN TRANSACTION  
       
   CREATE TABLE #Tmp_AlumnoMultaNoVotar  
   (  
	C_CodRC   VARCHAR(3),  
	C_CodAlu  VARCHAR(20),  
	I_Anio   INT,  
	C_Periodo  VARCHAR(50),  
	I_Periodo  INT  
   )  
  
     
   INSERT #Tmp_AlumnoMultaNoVotar(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo)  
   SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, c.I_OpcionID AS I_Periodo  
   FROM @Tbl_AlumnosMultaNoVotar AS am  
   INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = am.C_Periodo  
   INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = am.C_CodAlu and a.C_RcCod = am.C_CodRC  
   WHERE c.B_Eliminado = 0 AND a.N_Grado = '1';  
     
   --Insert para alumnos nuevos
   MERGE INTO TC_AlumnoMultaNoVotar AS trg USING #Tmp_AlumnoMultaNoVotar AS src  
   ON trg.C_CodRc = src.C_CodRc AND trg.C_CodAlu = src.C_CodAlu AND trg.I_Anio = src.I_Anio AND trg.I_Periodo = src.I_Periodo AND trg.B_Eliminado = 0  
   WHEN NOT MATCHED BY TARGET THEN  
    INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)  
     VALUES (src.C_CodRc, src.C_CodAlu, src.I_Anio, src.I_Periodo, 1, 0, @UserID, @D_FecRegistro);  
  
   --Informar de error en los datos.  
   (SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, 0 AS B_Success, 'El Alumno no existe en pregrado.' AS T_Message  
   FROM @Tbl_AlumnosMultaNoVotar AS am  
   LEFT JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = am.C_CodAlu and a.C_RcCod = am.C_CodRC AND a.N_Grado = '1'  
   WHERE a.C_CodAlu IS NULL)  
   UNION  
   (SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, 0 AS B_Success, 'El campo Periodo es incorrecto.' AS T_Message  
   FROM @Tbl_AlumnosMultaNoVotar AS am  
   LEFT JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = am.C_Periodo AND c.B_Eliminado = 0  
   WHERE c.I_OpcionID IS NULL)
   UNION
   SELECT mu.C_CodRC, mu.C_CodAlu, mu.I_Anio, mu.C_Periodo, 0 AS B_Success, 'El alumno ya tiene una obligación. Deberá generar la obligación nuevamente.' AS T_Message  
   FROM #Tmp_AlumnoMultaNoVotar AS mu  
   INNER JOIN dbo.TC_MatriculaAlumno m ON m.C_CodAlu = mu.C_CodAlu AND m.C_CodRc = mu.C_CodRC AND m.I_Anio = mu.I_Anio AND m.I_Periodo = mu.I_Periodo AND 
		m.B_Habilitado = 1 AND m.B_Eliminado = 0
   INNER JOIN dbo.TR_ObligacionAluCab c ON c.I_MatAluID = m.I_MatAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
  
   COMMIT TRANSACTION  
  
   SET @B_Result = 1  
   SET @T_Message = 'El registro de los alumnos que no votaron finalizó de manera exitosa'  
    
 END TRY  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
  SET @B_Result = 0  
  SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))   
 END CATCH  
END  
GO



