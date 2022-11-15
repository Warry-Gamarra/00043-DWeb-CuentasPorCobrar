USE BD_OCEF_CtasPorCobrar
GO
select * from dbo.TC_CuentaDeposito

SELECT * FROM dbo.TC_TipoArchivo WHERE I_TipoArchivoID = 4

SELECT * FROM dbo.TI_TipoArchivo_EntidadFinanciera WHERE I_EntidadFinanID = 2 AND I_TipoArchivoID = 4

SELECT * FROM dbo.TC_SeccionArchivo WHERE I_TipArchivoEntFinanID = 4

SELECT * FROM dbo.TC_ColumnaSeccion WHERE I_SecArchivoID = 4 ORDER BY I_ColSecID

SELECT I_ColumnaFin - I_ColumnaInicio + 1 as cantidad_caracteres,* FROM dbo.TC_ColumnaSeccion WHERE I_CampoPagoID IN (25,26)

BEGIN TRAN
BEGIN TRY
	--C_CodDepositante
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 14, I_ColumnaFin = 27, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 38

	--T_NomDepositante
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 1, I_ColumnaFin = 0, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 39

	--C_CodTasa
	UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 28, I_ColumnaFin = 32, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 34

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

SELECT * FROM dbo.TC_Concepto

SELECT * FROM dbo.TI_TasaUnfv

SELECT * FROM dbo.TI_TasaUnfv_CtaDepoServicio

SELECT * FROM dbo.TI_CtaDepo_Servicio

SELECT * FROM dbo.TC_Servicios

--CREATE PROCEDURE [dbo].[USP_I_GrabarAlumnoMultaNoVotar]  
--(  
--  @Tbl_AlumnosMultaNoVotar [dbo].[type_dataAlumnoMultaNoVotar] READONLY  
-- ,@D_FecRegistro datetime  
-- ,@UserID  int  
-- ,@B_Result  bit    OUTPUT  
-- ,@T_Message  nvarchar(4000) OUTPUT  
--)  
--AS  
--BEGIN  
-- SET NOCOUNT ON  
-- BEGIN TRY  
--   BEGIN TRANSACTION  
       
--   CREATE TABLE #Tmp_AlumnoMultaNoVotar  
--   (  
--    C_CodRC   VARCHAR(3),  
--    C_CodAlu  VARCHAR(20),  
--    I_Anio   INT,  
--    C_Periodo  VARCHAR(50),  
--    I_Periodo  INT  
--   )  
  
     
--   INSERT #Tmp_AlumnoMultaNoVotar(C_CodRC, C_CodAlu, I_Anio, C_Periodo, I_Periodo)  
--   SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, c.I_OpcionID AS I_Periodo  
--   FROM @Tbl_AlumnosMultaNoVotar AS am  
--   INNER JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = am.C_Periodo  
--   INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = am.C_CodAlu and a.C_RcCod = am.C_CodRC  
--   WHERE c.B_Eliminado = 0 AND a.N_Grado = '1';  
     
--   --Insert para alumnos nuevos  
--   MERGE INTO TC_AlumnoMultaNoVotar AS trg USING #Tmp_AlumnoMultaNoVotar AS src  
--   ON trg.C_CodRc = src.C_CodRc AND trg.C_CodAlu = src.C_CodAlu AND trg.I_Anio = src.I_Anio AND trg.I_Periodo = src.I_Periodo AND trg.B_Eliminado = 0  
--   WHEN NOT MATCHED BY TARGET THEN  
--    INSERT (C_CodRc, C_CodAlu, I_Anio, I_Periodo, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)  
--     VALUES (src.C_CodRc, src.C_CodAlu, src.I_Anio, src.I_Periodo, 1, 0, @UserID, @D_FecRegistro);  
  
--   --Informar los alumnos que ya tienen obligaciones (pagadas y sin pagar).  
--   (SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, 0 AS B_Success, 'El Alumno no existe en pregrado.' AS T_Message  
--   FROM @Tbl_AlumnosMultaNoVotar AS am  
--   LEFT JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = am.C_CodAlu and a.C_RcCod = am.C_CodRC AND a.N_Grado = '1'  
--   WHERE a.C_CodAlu IS NULL)  
--   UNION  
--   (SELECT am.C_CodRC, am.C_CodAlu, am.I_Anio, am.C_Periodo, 0 AS B_Success, 'El campo Periodo es incorrecto.' AS T_Message  
--   FROM @Tbl_AlumnosMultaNoVotar AS am  
--   LEFT JOIN dbo.TC_CatalogoOpcion c ON c.I_ParametroID = 5 AND c.T_OpcionCod = am.C_Periodo AND c.B_Eliminado = 0  
--   WHERE c.I_OpcionID IS NULL)  
  
  
--   COMMIT TRANSACTION  
  
--   SET @B_Result = 1  
--   SET @T_Message = 'El registro de los alumnos que no votaron finalizó de manera exitosa'  
    
-- END TRY  
-- BEGIN CATCH  
--  ROLLBACK TRANSACTION  
--  SET @B_Result = 0  
--  SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))   
-- END CATCH  
--END  



