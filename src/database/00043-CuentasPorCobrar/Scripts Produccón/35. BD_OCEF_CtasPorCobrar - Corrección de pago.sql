USE BD_OCEF_CtasPorCobrar
GO


BEGIN TRAN
BEGIN TRY

	DECLARE @D_FecMod DATETIME = GETDATE(),
			@C_CodDepositante VARCHAR(10) = '2022032465',
			@C_CodOperacion VARCHAR(10) = '3014313061'

	UPDATE p SET p.B_Anulado = 1, p.I_UsuarioMod = 1, p.D_FecMod = @D_FecMod FROM dbo.TR_PagoBanco b
	INNER JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID
	WHERE b.I_ProcesoIDArchivo = 531 AND b.I_EntidadFinanID = 1 AND b.I_TipoPagoID = 133 AND b.C_CodDepositante = @C_CodDepositante AND b.C_CodOperacion = @C_CodOperacion AND b.I_CondicionPagoID = 131

	UPDATE b SET b.I_CondicionPagoID = 137, b.I_UsuarioMod = 1, b.D_FecMod = @D_FecMod FROM dbo.TR_PagoBanco b
	WHERE b.I_ProcesoIDArchivo = 531 AND b.I_EntidadFinanID = 1 AND b.I_TipoPagoID = 133 AND b.C_CodDepositante = @C_CodDepositante AND b.C_CodOperacion = @C_CodOperacion AND b.I_CondicionPagoID = 131

	COMMIT TRAN

	PRINT 'Actualización correcta.'
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'Error al actualizar.'
END CATCH
GO
