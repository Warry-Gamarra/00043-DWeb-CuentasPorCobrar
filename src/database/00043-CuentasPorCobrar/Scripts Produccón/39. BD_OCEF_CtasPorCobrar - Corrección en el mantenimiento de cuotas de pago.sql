USE BD_OCEF_CtasPorCobrar
GO


ALTER PROCEDURE [dbo].[USP_I_GrabarCategoriaPago]  
@I_CatPagoID int  
,@T_CatPagoDesc varchar(250)  
,@I_Nivel  int  
,@I_TipoAlumno int  
,@I_Prioridad int  
,@B_Obligacion bit  
,@N_CodBanco varchar(10)  
,@Tbl_Cuentas  [dbo].[type_SelectItems] READONLY  
,@D_FecCre  datetime  
,@CurrentUserId int  
  
,@B_Result bit OUTPUT  
,@T_Message nvarchar(4000) OUTPUT   
AS  
BEGIN  
	SET NOCOUNT ON;

	BEGIN TRY    
		INSERT INTO TC_CategoriaPago (T_CatPagoDesc, I_Nivel, I_Prioridad, I_TipoAlumno, B_Obligacion, N_CodBanco, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)  
		VALUES (@T_CatPagoDesc, @I_Nivel, @I_Prioridad, @I_TipoAlumno, @B_Obligacion, @N_CodBanco, 1, 0, @CurrentUserId, @D_FecCre)  
    
		SET @I_CatPagoID = SCOPE_IDENTITY()  
		
		INSERT TC_CuentaDeposito_CategoriaPago(I_CatPagoID, I_CtaDepositoID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)  
		SELECT @I_CatPagoID, c.C_ID, 1, 0, @CurrentUserId, @D_FecCre FROM @Tbl_Cuentas c

		SET @B_Result = 1  
		SET @T_Message = 'Nuevo registro agregado.'  
	END TRY  
	BEGIN CATCH  
		SET @B_Result = 0  
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))   
	END CATCH  
END  
GO



ALTER PROCEDURE [dbo].[USP_U_ActualizarCategoriaPago]
@I_CatPagoID int  
,@T_CatPagoDesc varchar(250)  
,@I_Nivel  int  
,@I_TipoAlumno int  
,@I_Prioridad int  
,@B_Obligacion bit  
,@N_CodBanco varchar(10)  
,@Tbl_Cuentas [dbo].[type_SelectItems] READONLY  
,@D_FecMod  datetime  
,@CurrentUserId int
,@B_Result bit OUTPUT  
,@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE TC_CategoriaPago SET
			T_CatPagoDesc = @T_CatPagoDesc,
			I_Nivel = @I_Nivel,
			I_Prioridad = @I_Prioridad,
			I_TipoAlumno = @I_TipoAlumno,
			B_Obligacion = @B_Obligacion,
			N_CodBanco = @N_CodBanco,
			D_FecMod = @D_FecMod,
			I_UsuarioMod = @CurrentUserId
		WHERE I_CatPagoID = @I_CatPagoID

		UPDATE TC_CuentaDeposito_CategoriaPago SET 
			B_Habilitado = 0, 
			D_FecMod = @D_FecMod 
		WHERE I_CatPagoID = @I_CatPagoID

		MERGE TC_CuentaDeposito_CategoriaPago AS TRG
		USING @Tbl_Cuentas AS SRC
		ON  TRG.I_CatPagoID = @I_CatPagoID AND TRG.I_CtaDepositoID = SRC.C_ID
		WHEN MATCHED THEN
			UPDATE SET
				TRG.B_Habilitado = 1,
				TRG.D_FecMod = @D_FecMod,
				TRG.I_UsuarioMod = @CurrentUserId
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (I_CatPagoID, I_CtaDepositoID, B_Habilitado,B_Eliminado, I_UsuarioCre, D_FecCre)
			VALUES (@I_CatPagoID, SRC.C_ID, SRC.B_Habilitado, 0, @CurrentUserId, @D_FecMod);
  
		SET @B_Result = 1  
		SET @T_Message = 'Actualización de datos correcta'  
	END TRY  
	BEGIN CATCH  
		SET @B_Result = 0  
		SET @T_Message = ERROR_MESSAGE() + ' LINE: ' + CAST(ERROR_LINE() AS varchar(10))   
	END CATCH
END  
GO
