USE BD_OCEF_CtasPorCobrar
GO

--AMPLIACIÓN DE CRÉDITOS: VARGAS COCHACHIN, DIANA EMPERATRIZ
--MATRÍCULA
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(544, 523132, 'PEN', 250, '20230916', 0, 1, 0, 1, GETDATE());

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7719, 250, 0, '20230916', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0);
GO

--PENSIÓN 1
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523132, 'PEN', 325, '20230915', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20230915', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 2
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523132, 'PEN', 325, '20231015', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231015', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 3
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523132, 'PEN', 325, '20231115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231115', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO


--PENSIÓN 4
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523132, 'PEN', 325, '20231215', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231215', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO



--AMPLIACIÓN DE CRÉDITOS: ZEVALLOS PIZAN, VILMA GREGORIA
--MATRÍCULA
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(544, 523134, 'PEN', 250, '20230916', 0, 1, 0, 1, GETDATE());

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7719, 250, 0, '20230916', 138, 'PROVEIDO N° 10530-2023-DIGA-UNFV NT 66526. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0);
GO

--PENSIÓN 1
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523134, 'PEN', 325, '20230915', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20230915', 138, 'PROVEIDO N° 10530-2023-DIGA-UNFV NT 66526. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 2
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523134, 'PEN', 325, '20231015', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231015', 138, 'PROVEIDO N° 10530-2023-DIGA-UNFV NT 66526. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 3
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523134, 'PEN', 325, '20231115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231115', 138, 'PROVEIDO N° 10530-2023-DIGA-UNFV NT 66526. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO


--PENSIÓN 4
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523134, 'PEN', 325, '20231215', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231215', 138, 'PROVEIDO N° 10530-2023-DIGA-UNFV NT 66526. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO



--AMPLIACIÓN DE CRÉDITOS: AGUIRRE VEIZAGA, GLADYS
--MATRÍCULA
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(542, 523003, 'PEN', 125, '20230930', 0, 1, 0, 1, GETDATE());

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7714, 125, 0, '20230930', 138, 'PROVEIDO N° 9176-2023-DIGA-UNFV NT 58940. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0);
GO

--PENSIÓN 1
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523003, 'PEN', 150, '20231015', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231015', 138, 'PROVEIDO N° 9176-2023-DIGA-UNFV NT 58940. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 2
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523003, 'PEN', 150, '20231115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231115', 138, 'PROVEIDO N° 9176-2023-DIGA-UNFV NT 58940. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 3
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523003, 'PEN', 150, '20231215', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20231215', 138, 'PROVEIDO N° 9176-2023-DIGA-UNFV NT 58940. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO


--PENSIÓN 4
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(543, 523003, 'PEN', 150, '20240115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7717, 150, 0, '20240115', 138, 'PROVEIDO N° 9176-2023-DIGA-UNFV NT 58940. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO




--AMPLIACIÓN DE CRÉDITOS: MARES SALAS MIGUEL ANGEL ODION
--MATRÍCULA
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(544, 523508, 'PEN', 250, '20230916', 0, 1, 0, 1, GETDATE());

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7719, 250, 0, '20230916', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0);
GO

--PENSIÓN 1
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523508, 'PEN', 325, '20230915', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20230915', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 2
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523508, 'PEN', 325, '20231015', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231015', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO

--PENSIÓN 3
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523508, 'PEN', 325, '20231115', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231115', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO


--PENSIÓN 4
DECLARE @I_ObligacionAluID INT

INSERT dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, D_FecVencto, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
VALUES(545, 523508, 'PEN', 325, '20231215', 0, 1, 0, 1, GETDATE())

SET @I_ObligacionAluID = SCOPE_IDENTITY();

INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, I_TipoDocumento, T_DescDocumento, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
VALUES(@I_ObligacionAluID, 7722, 325, 0, '20231215', 138, 'PROVEIDO N° 9739-2023-DIGA-UNFV NT 62773. Ampliación de Créditos', 1, 0, 1, GETDATE(), 0)
GO
