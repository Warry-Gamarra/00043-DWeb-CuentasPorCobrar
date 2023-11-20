USE BD_OCEF_CtasPorCobrar
GO

--AMPLIACI�N DE CR�DITOS: ALBURQUEQUE CARRASCO, GERALDINE SENAIDA
--MATR�CULA
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(542, 523049, 'PEN', 125, '20230915', 0, 1, 0, 1, GETDATE());

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7714, 125, 0, '20230915', 141, 'PROVEIDO N� 11547-2023-DIGA-UNFV NT 72112. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0);
GO

--PENSI�N 1
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523049, 'PEN', 150, '20230915', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20230915', 141, 'PROVEIDO N� 11547-2023-DIGA-UNFV NT 72112. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSI�N 2
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523049, 'PEN', 150, '20231015', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231015', 141, 'PROVEIDO N� 11547-2023-DIGA-UNFV NT 72112. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSI�N 3
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523049, 'PEN', 150, '20231115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231115', 141, 'PROVEIDO N� 11547-2023-DIGA-UNFV NT 72112. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO


--PENSI�N 4
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523049, 'PEN', 150, '20231215', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231215', 141, 'PROVEIDO N� 11547-2023-DIGA-UNFV NT 72112. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO



--AMPLIACI�N DE CR�DITOS: ROMERO HAYASHI, MARCO ANTONIO
--MATR�CULA
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(542, 523047, 'PEN', 125, '20230915', 0, 1, 0, 1, GETDATE());

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7714, 125, 0, '20230915', 141, 'PROVEIDO N� 11038-2023-DIGA-UNFV NT 63872. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0);
GO

--PENSI�N 1
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523047, 'PEN', 150, '20230915', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20230915', 141, 'PROVEIDO N� 11038-2023-DIGA-UNFV NT 63872. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSI�N 2
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523047, 'PEN', 150, '20231015', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231015', 141, 'PROVEIDO N� 11038-2023-DIGA-UNFV NT 63872. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSI�N 3
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523047, 'PEN', 150, '20231115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231115', 141, 'PROVEIDO N� 11038-2023-DIGA-UNFV NT 63872. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSI�N 4
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523047, 'PEN', 150, '20231215', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231215', 141, 'PROVEIDO N� 11038-2023-DIGA-UNFV NT 63872. Ampliaci�n de Cr�ditos', 1, 0, 1, GETDATE(), 0)
GO
