USE BD_OCEF_CtasPorCobrar
GO

BEGIN  TRAN
BEGIN TRY
	DECLARE @rowCount INT = 0

	UPDATE p SET 
		p.B_Anulado = 1,
		p.I_UsuarioMod = 1,
		p.D_FecMod = GETDATE()
	FROM dbo.TR_PagoBanco b
	INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
	WHERE 
		b.B_Anulado = 0 AND 
		p.B_Anulado = 0 AND 
		DATEDIFF (DAY, b.D_FecPago, '20230418') = 0 AND 
		p.I_TasaUnfvID = 33 AND 
		b.C_CodOperacion IN (
			'330962',
			'619376',
			'668569',
			'045310',
			'048516',
			'051502',
			'054158',
			'066249',
			'368815')
	
	SET @rowCount = @@ROWCOUNT

	UPDATE b SET 
		b.B_Anulado = 1,
		b.I_UsuarioMod = 1,
		b.D_FecMod = GETDATE()
	FROM dbo.TR_PagoBanco b
	INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
	WHERE 
		b.B_Anulado = 0 AND
		DATEDIFF (DAY, b.D_FecPago, '20230418') = 0 AND 
		p.I_TasaUnfvID = 33 AND 
		b.C_CodOperacion IN (
			'330962',
			'619376',
			'668569',
			'045310',
			'048516',
			'051502',
			'054158',
			'066249',
			'368815')
	
	SET @rowCount = @rowCount + @@ROWCOUNT
	
	IF (@rowCount = 18) BEGIN
		COMMIT TRAN
		PRINT 'Actualización correcta.'
	END ELSE BEGIN
		ROLLBACK TRAN
		PRINT 'Ocurrió un error en los filtros aplicados.'
	END
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE()
END CATCH
GO
