USE BD_OCEF_CtasPorCobrar
GO

--T_InformacionAdicional
UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 14, I_ColumnaFin = 27, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 40
GO

--C_CodigoInterno
UPDATE dbo.TC_ColumnaSeccion SET I_ColumnaInicio = 196, I_ColumnaFin = 203, I_UsuarioMod = 1, D_FecMod = GETDATE() WHERE I_ColSecID = 66
GO