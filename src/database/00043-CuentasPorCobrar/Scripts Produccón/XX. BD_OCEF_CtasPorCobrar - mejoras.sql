USE BD_OCEF_CtasPorCobrar
GO

--SELECT * FROM dbo.TC_ColumnaSeccion WHERE I_SecArchivoID = 4 ORDER BY I_ColSecID

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



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DevolucionPago')
	DROP VIEW [dbo].[VW_DevolucionPago]
GO

CREATE VIEW [dbo].[VW_DevolucionPago]  
AS  
(  
  --SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago    
  -- , EF.T_EntidadDesc, '' AS C_CodClasificador    
  -- , PR.T_ProcesoDesc AS T_ConceptoPagoDesc     
  --  FROM TR_DevolucionPago DP    
  -- INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID     
  -- INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID    
  -- INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID    
  -- INNER JOIN TR_ObligacionAluCab OC ON OC.I_ObligacionAluID = PP.I_ObligacionAluID  
  -- INNER JOIN TC_Proceso PR ON PR.I_ProcesoID = OC.I_ProcesoID  
  --UNION    
  --SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago    
  -- , EF.T_EntidadDesc, (CL.C_TipoTransCod + '.' + CL.C_GenericaCod + '.' + CL.C_SubGeneCod + '.' + CL.C_EspecificaCod) AS C_CodClasificador    
  -- , TU.T_ConceptoPagoDesc    
  --  FROM TR_DevolucionPago DP    
  -- INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID     
  -- INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID    
  -- INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID    
  -- INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID    
  -- LEFT JOIN VW_Clasificadores cl ON cl.C_ClasificConceptoCod = TU.T_Clasificador    
  
 SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago  
     , EF.T_EntidadDesc, (CL.C_TipoTransCod + '.' + CL.C_GenericaCod + '.' + CL.C_SubGeneCod + '.' + CL.C_EspecificaCod) AS C_CodClasificador  
     , CP.T_ConceptoPagoDesc   
   FROM TR_DevolucionPago DP  
     INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID   
     INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID  
     INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID  
     INNER JOIN TR_ObligacionAluDet OD ON OD.I_ObligacionAluDetID = PP.I_ObligacionAluDetID   
     INNER JOIN TR_ObligacionAluCab OC ON OC.I_ObligacionAluID = OD.I_ObligacionAluID  
     INNER JOIN TI_ConceptoPago CP ON CP.I_ConcPagID = OD.I_ConcPagID  
     LEFT JOIN VW_Clasificadores cl ON cl.C_ClasificConceptoCod = CP.T_Clasificador  
 UNION  
 SELECT DP.*, PP.I_MontoPagado, PP.N_NroSIAF, PB.I_EntidadFinanID, PB.C_CodOperacion, PB.C_Referencia, PB.D_FecPago  
     , EF.T_EntidadDesc, (CL.C_TipoTransCod + '.' + CL.C_GenericaCod + '.' + CL.C_SubGeneCod + '.' + CL.C_EspecificaCod) AS C_CodClasificador  
     , TU.T_ConceptoPagoDesc  
   FROM TR_DevolucionPago DP  
     INNER JOIN TRI_PagoProcesadoUnfv PP ON DP.I_PagoProcesID = PP.I_PagoProcesID   
     INNER JOIN TR_PagoBanco PB ON PP.I_PagoBancoID = PB.I_PagoBancoID  
     INNER JOIN TC_EntidadFinanciera EF ON PB.I_EntidadFinanID = EF.I_EntidadFinanID  
     INNER JOIN TI_TasaUnfv TU ON TU.I_TasaUnfvID = PP.I_TasaUnfvID  
     LEFT JOIN VW_Clasificadores cl ON cl.C_ClasificConceptoCod = TU.T_Clasificador  
  
)  
GO

SELECT * FROM TR_DevolucionPago