USE [BD_OCEF_CtasPorCobrar]
GO


/*------------------------------------------ Correos ---------------------------------------------------*/


INSERT INTO [dbo].[TS_CorreoAplicacion](T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, D_FecUpdate, B_Habilitado)
	 VALUES (N'wgamarra@unfv.edu.pe', N'WABIAFMATwBuAG8ASwAyAEAAMgAwADEANgA=', 'TLS', 'smtp.office365.com', 587, GETDATE(), 1)






/* -------------------------------- TC_TipoDocumento ------------------------------------ */

INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'RR', N'RESOL. RECTORAL', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'RF', N'RESOL. DE FACULTAD', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'RD', N'RESOL. DIRECTORAL', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'PR', N'PROVEIDO', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'OF', N'OFICIO', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'OB', N'OBSERVACION', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'RC', N'RESOL. VRAC', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'RA', N'RESOL. VRAD', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'AC', N'ACUERDO CONSEJO UNIV', 1);
INSERT INTO TC_TipoDocumento (C_DocCod, T_DocDesc, B_DocEstado) VALUES (N'MM', N'MEMORANDO', 1);
GO


/* -------------------------------- TC_TipoResolucion ------------------------------------ */

INSERT INTO TC_TipoResolucion (C_ResolucionCod,T_ResolucionDesc,B_ResolucionEstado) VALUES (N'RD', N'RESOLUCION DIRECTORAL', 1)
INSERT INTO TC_TipoResolucion (C_ResolucionCod,T_ResolucionDesc,B_ResolucionEstado) VALUES (N'RR', N'RESOLUCION RECTORAL', 1)
INSERT INTO TC_TipoResolucion (C_ResolucionCod,T_ResolucionDesc,B_ResolucionEstado) VALUES (N'RF', N'RESOLUCION DE FACULTAD', 1)
GO

