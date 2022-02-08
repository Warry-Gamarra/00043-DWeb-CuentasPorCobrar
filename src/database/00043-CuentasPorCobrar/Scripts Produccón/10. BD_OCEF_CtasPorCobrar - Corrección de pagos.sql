USE BD_OCEF_CtasPorCobrar
GO


/*
Corrección del pago de ENGRACIO SALINAS, JORGE AURELIO para la Matrícula EUPG 2021-2
*/

UPDATE dbo.TRI_PagoProcesadoUnfv SET B_Anulado = 1, D_FecMod = GETDATE(), I_UsuarioMod = 1 WHERE I_PagoProcesID IN (41377, 41378)
GO

UPDATE dbo.TR_PagoBanco SET I_CondicionPagoID = 137, D_FecMod = GETDATE(), I_UsuarioMod = 1 WHERE I_PagoBancoID = 35564
GO