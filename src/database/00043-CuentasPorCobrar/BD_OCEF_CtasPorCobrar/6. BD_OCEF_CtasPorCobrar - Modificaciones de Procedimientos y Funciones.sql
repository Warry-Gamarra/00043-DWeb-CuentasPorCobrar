USE BD_OCEF_CtasPorCobrar
GO


ALTER TABLE TR_PagoBanco ADD I_InteresMora DECIMAL(15,2)
GO

UPDATE TR_PagoBanco SET I_InteresMora = 0
GO

ALTER TABLE TR_PagoBanco ALTER COLUMN I_InteresMora DECIMAL(15,2) NOT NULL
GO




IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_IU_GenerarObligacionesPregrado_X_Ciclo' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_IU_GenerarObligacionesPregrado_X_Ciclo]
GO


CREATE PROCEDURE [dbo].[USP_IU_GenerarObligacionesPregrado_X_Ciclo]
@I_Anio int,
@I_Periodo int,
@C_CodFac varchar(2) = null,
@C_CodAlu varchar(20) = null,
@C_CodRc varchar(3) = null, 
@I_UsuarioCre int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	--1ro Obtener los conceptos según año y periodo
	declare @N_GradoBachiller char(1) = '1'

	select p.I_ProcesoID, p.D_FecVencto, cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,
	ISNULL(conpag.B_Calculado, 0) AS B_Calculado, conpag.I_Calculado, ISNULL(conpag.B_GrupoCodRc, 0) AS B_GrupoCodRc, gr.T_OpcionCod AS I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng, 
	ISNULL(conpag.B_EsPagoMatricula, 0) AS B_EsPagoMatricula, ISNULL(con.B_EsPagoExtmp, 0) AS B_EsPagoExtmp, conpag.N_NroPagos, cp.I_Prioridad
	into #tmp_conceptos_pregrado
	from dbo.TC_Proceso p
	inner join dbo.TC_CategoriaPago cp on cp.I_CatPagoID = p.I_CatPagoID
	inner join dbo.TI_ConceptoPago conpag on conpag.I_ProcesoID = p.I_ProcesoID
	inner join dbo.TC_Concepto con on con.I_ConceptoID = conpag.I_ConceptoID
	left join dbo.TC_CatalogoOpcion moding on moding.I_ParametroID = 7 and moding.I_OpcionID = conpag.I_ModalidadIngresoID
	left join dbo.TC_CatalogoOpcion gr on gr.I_ParametroID = 6 and gr.I_OpcionID = conpag.I_GrupoCodRc
	where p.B_Habilitado = 1 and p.B_Eliminado = 0 and
		conpag.B_Habilitado = 1 and conpag.B_Eliminado = 0 and ISNULL(conpag.B_Mora, 0) = 0 and
		cp.B_Obligacion = 1 and p.I_Anio = @I_Anio and p.I_Periodo = @I_Periodo and cp.I_Nivel = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod = @N_GradoBachiller)
		--cp.B_Obligacion = 1 and p.I_Anio = 2021 and p.I_Periodo = 15 and cp.I_Nivel = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod = '1')

	--2do Obtengo la relación de alumnos
	declare @Tmp_MatriculaAlumno table (id int identity(1,1), I_MatAluID int, C_CodRc varchar(3), C_CodAlu varchar(20), C_EstMat varchar(2), B_Ingresante bit, C_CodModIng varchar(2), N_Grupo char(1), I_CredDesaprob tinyint)
	
	if (@C_CodAlu is not null) and (@C_CodRc is not null) begin
		insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
		select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) 
		from dbo.TC_MatriculaAlumno m 
		inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
		where m.B_Habilitado = 1 and m.B_Eliminado = 0 and 
			a.N_Grado = @N_GradoBachiller and m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
	end else begin
		if (@C_CodFac is null) or (@C_CodFac = '') begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) 
			from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and 
				a.N_Grado = @N_GradoBachiller and m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo
		end else begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0) 
			from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and 
				a.N_Grado = @N_GradoBachiller and m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and a.C_CodFac = @C_CodFac
		end
	end

	--3ro Comienzo con el calculo las obligaciones por alumno almacenandolas en @Tmp_Procesos.
	declare @Tmp_Procesos table (I_ProcesoID int, I_ConcPagID int, M_Monto decimal(15,2), D_FecVencto datetime, I_TipoObligacion int, I_Prioridad tinyint)

	declare @C_Moneda varchar(3) = 'PEN',
			@D_CurrentDate datetime = getdate(),
			@I_FilaActual int = 1,
			@I_CantRegistros int = (select max(id) from @Tmp_MatriculaAlumno),
			
			--Tipo de alumno
			@I_AlumnoRegular int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '1'),
			@I_AlumnoIngresante int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '2'),
			
			--Tipo obligación
			@I_Matricula int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '1'),
			@I_OtrosPagos int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '0'),

			--Campo calculado
			@I_CrdtDesaprobados int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '1'),
			@I_DeudasAnteriores int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '2'),
			@I_Pensiones int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '3'),
			@I_MultaNoVotar int = (select I_OpcionID from dbo.TC_CatalogoOpcion WHERE I_ParametroID = 4 and T_OpcionCod = '4'),
			
			--Otras variables
			@I_ObligacionAluID int,
			@I_MatAluID int,
			@C_EstMat varchar(2),
			@C_CodModIng varchar(2),
			@N_Grupo char(1),
			@I_TipoAlumno int,
			@I_MontoDeuda decimal(15,2),
			@I_CredDesaprob tinyint,
			@N_NroPagos tinyint,

			--Variables para comprobar modificaciones
			@I_MontoInicial decimal(15,2),
			@I_MontoActual decimal(15,2),
			@D_FecVenctoInicial datetime,
			@D_FecVenctoActual datetime,
			@I_ProcesoID int,
			@B_Pagado bit

	declare @Tmp_grupo_otros_pagos table (id int, I_ProcesoID int)
	declare @I_FilaActual_OtrsPag int,
			@I_CantRegistros_OtrsPag int,
			@I_ProcesoID_OtrsPag int

	while (@I_FilaActual <= @I_CantRegistros) begin
		begin tran
		begin try
			
			--4to obtengo la información alumno por alumno e inicializo variables
			select @I_MatAluID = I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, 
				@N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0), 
				@I_TipoAlumno = (case when B_Ingresante = 0 then @I_AlumnoRegular else @I_AlumnoIngresante end) 
			from @Tmp_MatriculaAlumno 
			where id = @I_FilaActual

			delete @Tmp_Procesos

			--Pagos de Matrícula
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng
			end
			else
			begin
				if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng is null) = 1
				begin
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
						B_EsPagoMatricula = 1 and C_CodModIng is null
				end	
			end

			--Pagos generales de matrícula
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
			select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and
				B_EsPagoMatricula = 0 and B_Calculado = 0 and B_GrupoCodRc = 0 and B_EsPagoExtmp = 0

			--Pagos de laboratorio
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 0 and B_GrupoCodRc = 1 and I_GrupoCodRc = @N_Grupo) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_GrupoCodRc = 1 and I_GrupoCodRc = @N_Grupo
			end

			--Multa por no votar
			if (@I_TipoAlumno = @I_AlumnoRegular) and (select count(I_ProcesoID) from #tmp_conceptos_pregrado 
				where I_TipoAlumno = @I_AlumnoRegular and I_TipoObligacion = @I_Matricula and
					B_EsPagoMatricula = 0 and B_Calculado = 1 and I_Calculado = @I_MultaNoVotar) = 1
			begin
				if exists(select * from dbo.TC_AlumnoMultaNoVotar nv 
					where nv.B_Eliminado = 0 and nv.C_CodAlu = @C_CodAlu and nv.C_CodRc = @C_CodRc and nv.I_Anio = @I_Anio and nv.I_Periodo = @I_Periodo)
				begin
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_AlumnoRegular and I_TipoObligacion = @I_Matricula and
						B_EsPagoMatricula = 0 and B_Calculado = 1 and I_Calculado = @I_MultaNoVotar
				end
			end

			--Pagos extemoráneos
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0
			end

			--Monto de deuda anterior
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado 
				where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores) = 1
			begin
				set @I_MontoDeuda = isnull((select SUM(cab.I_MontoOblig) from dbo.TR_ObligacionAluCab cab
					inner join (select top 1 m.I_MatAluID from dbo.TC_MatriculaAlumno m 
						where m.B_Eliminado = 0 and not m.I_MatAluID = @I_MatAluID and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
						order by m.I_Anio desc, m.C_Ciclo desc) mat on mat.I_MatAluID = cab.I_MatAluID
					where cab.B_Eliminado = 0 and cab.B_Pagado = 0), 0)

				if (@I_MontoDeuda > 0)
				begin
					set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores), 1);

					with CTE_Recursivo as
					(
						select 1 as num, I_ProcesoID, I_ConcPagID, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_DeudasAnteriores
						union all
						select num + 1, I_ProcesoID, I_ConcPagID, D_FecVencto, I_TipoObligacion, I_Prioridad
						from CTE_Recursivo
						where num < @N_NroPagos
					)
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, dbo.FN_CalcularCuotasDeuda(@I_MontoDeuda, @N_NroPagos, num) AS M_Monto, 
						DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
					from CTE_Recursivo;
				end
			end
			
			--Monto de cursos desaprobados
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados) = 1
			begin
				if (@I_CredDesaprob > 0)
				begin
					set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados), 1);

					with CTE_Recursivo as
					(
						select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
						where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_CrdtDesaprobados
						union all
						select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
						from CTE_Recursivo
						where num < @N_NroPagos
					)
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, cast((M_Monto * @I_CredDesaprob) / @N_NroPagos as decimal(15,2)), 
						DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
					from CTE_Recursivo
				end
			end

			--Monto de Pensión de enseñanza
			if (select count(I_ProcesoID) from #tmp_conceptos_pregrado
				where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng) = 1
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_pregrado 
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_pregrado
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_CodModIng = @C_CodModIng
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, cast(M_Monto / @N_NroPagos as decimal(15,2)) as M_Monto, 
					DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
				from CTE_Recursivo
			end

			--Grabando pago de matrícula
			set @I_ProcesoID = 0

			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)
			begin
				set @I_ProcesoID = (select distinct p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)

				if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID)
				begin
					select @I_MontoInicial = cab.I_MontoOblig, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

					select @D_FecVenctoActual = p.D_FecVencto, @I_MontoActual = Sum(p.M_Monto) from @Tmp_Procesos p 
					where p.I_Prioridad = 1 group by p.D_FecVencto

					if (@B_Pagado = 0)
					begin
						if Not (DATEDIFF(Day, @D_FecVenctoInicial, @D_FecVenctoActual) = 0) Or Not (@I_MontoInicial = @I_MontoActual)
						begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 1 
							group by p.I_ProcesoID, p.D_FecVencto

							set @I_ObligacionAluID = SCOPE_IDENTITY()

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
							select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
							where p.I_Prioridad = 1
						end
					end
				end
				else
				begin
					--insert
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 1 
					group by p.I_ProcesoID, p.D_FecVencto

					set @I_ObligacionAluID = SCOPE_IDENTITY()

					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
					select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
					where p.I_Prioridad = 1
				end
			end

			--Grabando otros pagos
			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2)
			begin
				if not exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
					where cab.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and
						cab.I_ProcesoID in (select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2))
				begin
					--Nuevos registros de obligaciones

					--Insert de cabecera
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID, p.D_FecVencto

					--Insert de detalle
					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
					select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
					inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID and cab.I_MatAluID = @I_MatAluID and
						DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
					where p.I_Prioridad = 2
				end
				else
				begin
					--Edición de obligaciones

					if exists(select id from @Tmp_grupo_otros_pagos) begin
						delete @Tmp_grupo_otros_pagos
					end

					insert @Tmp_grupo_otros_pagos(id, I_ProcesoID)
					select ROW_NUMBER() OVER (ORDER BY I_ProcesoID), I_ProcesoID from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID
					
					set @I_FilaActual_OtrsPag = 1
					set @I_CantRegistros_OtrsPag = (select max(id) from @Tmp_grupo_otros_pagos)

					while (@I_FilaActual_OtrsPag <= @I_CantRegistros_OtrsPag) begin
						--Los otros pagos se agrupan primero por proceso y luego por fecha de vcto.
						set @I_ProcesoID_OtrsPag = (select I_ProcesoID from @Tmp_grupo_otros_pagos where id = @I_FilaActual_OtrsPag)

						if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
							inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
							where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and 
							cab.I_ProcesoID = @I_ProcesoID_OtrsPag AND cab.B_Pagado = 1) begin
							
							print 'Existen al menos un pago realizado.'

						end
						else begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID_OtrsPag

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID_OtrsPag

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
							group by p.I_ProcesoID, p.D_FecVencto

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
							select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
							inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID  and cab.I_MatAluID = @I_MatAluID and
								DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
						end

						set @I_FilaActual_OtrsPag = (@I_FilaActual_OtrsPag + 1)
					end
				end
			end

			commit tran
		end try
		begin catch
			rollback tran

			print ERROR_MESSAGE()
			print ERROR_LINE()
		end catch

		set @I_FilaActual = (@I_FilaActual +1)
	end

	set @B_Result = 1
	set @T_Message = 'El proceso finalizó correctamente.'
/*

declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPregrado_X_Ciclo @I_Anio = 2021, @I_Periodo = 15, 
@C_CodFac = null, @C_CodAlu = null, @C_CodRc = null, @I_UsuarioCre = 1,
@B_Result = @B_Result OUTPUT,
@T_Message = @T_Message OUTPUT
go

*/
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'USP_IU_GenerarObligacionesPosgrado_X_Ciclo' AND ROUTINE_TYPE = 'PROCEDURE')
	DROP PROCEDURE [dbo].[USP_IU_GenerarObligacionesPosgrado_X_Ciclo]
GO


CREATE PROCEDURE [dbo].[USP_IU_GenerarObligacionesPosgrado_X_Ciclo]
@I_Anio int,
@I_Periodo int,
@C_CodEsc varchar(2) = null,
@C_CodAlu varchar(20) = null,
@C_CodRc varchar(3) = null,
@I_UsuarioCre int,
@B_Result bit OUTPUT,
@T_Message nvarchar(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	declare @N_GradoMaestria char(1) = '2'
	declare @N_Doctorado char(1) = '3'
	 
	--1ro Obtener los conceptos según año y periodo
	select p.I_ProcesoID, p.D_FecVencto, cp.T_CatPagoDesc, conpag.I_ConcPagID, con.T_ConceptoDesc, cp.I_TipoAlumno, conpag.M_Monto, conpag.M_MontoMinimo, conpag.I_TipoObligacion,
	ISNULL(conpag.B_Calculado, 0) AS B_Calculado, conpag.I_Calculado, ISNULL(conpag.B_GrupoCodRc, 0) AS B_GrupoCodRc,  conpag.I_GrupoCodRc, conpag.B_ModalidadIngreso, moding.T_OpcionCod AS C_CodModIng, 
	ISNULL(conpag.B_EsPagoMatricula, 0) AS B_EsPagoMatricula, ISNULL(conpag.B_EsPagoExtmp, 0) AS B_EsPagoExtmp, conpag.N_NroPagos, cp.I_Prioridad, cp.I_Nivel, niv.T_OpcionCod as C_Nivel
	into #tmp_conceptos_posgrado
	from dbo.TC_Proceso p
	inner join dbo.TC_CategoriaPago cp on cp.I_CatPagoID = p.I_CatPagoID
	inner join dbo.TI_ConceptoPago conpag on conpag.I_ProcesoID = p.I_ProcesoID
	inner join dbo.TC_Concepto con on con.I_ConceptoID = conpag.I_ConceptoID
	left join dbo.TC_CatalogoOpcion moding on moding.I_ParametroID = 7 and moding.I_OpcionID = conpag.I_ModalidadIngresoID
	left join dbo.TC_CatalogoOpcion gr on gr.I_ParametroID = 6 and gr.I_OpcionID = conpag.I_GrupoCodRc
	left join dbo.TC_CatalogoOpcion niv on niv.I_ParametroID = 2 and niv.I_OpcionID = cp.I_Nivel
	where p.B_Habilitado = 1 and p.B_Eliminado = 0 and
		conpag.B_Habilitado = 1 and conpag.B_Eliminado = 0  and ISNULL(conpag.B_Mora, 0) = 0 and
		cp.B_Obligacion = 1 and p.I_Anio = @I_Anio and p.I_Periodo = @I_Periodo and cp.I_Nivel in (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod IN (@N_GradoMaestria, @N_Doctorado))
		--cp.B_Obligacion = 1 and p.I_Anio = 2021 and p.I_Periodo = 19 and cp.I_Nivel in (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 2 and T_OpcionCod IN ('2', '3'))

	--2do Obtengo la relación de alumnos
	declare @Tmp_MatriculaAlumno table (id int identity(1,1), I_MatAluID int, C_CodRc varchar(3), C_CodAlu varchar(20), C_EstMat varchar(2), 
		B_Ingresante bit, C_CodModIng varchar(2), N_Grupo char(1), I_CredDesaprob tinyint, N_Grado char(1))
	
	if (@C_CodAlu is not null) and (@C_CodRc is not null) begin
		insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob, N_Grado)
		select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0), a.N_Grado 
		from dbo.TC_MatriculaAlumno m 
		inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
		where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado IN (@N_GradoMaestria, @N_Doctorado) and
			m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and m.C_CodAlu = @C_CodAlu and m.C_CodRc = @C_CodRc
	end else begin
		if (@C_CodEsc is null) or (@C_CodEsc = '') begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob, N_Grado)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0), a.N_Grado
			from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado in (@N_GradoMaestria, @N_Doctorado) and
				m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo
			--where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado in ('2', '3') and m.I_Anio = 2021 and m.I_Periodo = 19
			--and not exists(select * from dbo.TR_ObligacionAluCab cab where cab.I_MatAluID = m.I_MatAluID)
		end else begin
			insert @Tmp_MatriculaAlumno(I_MatAluID, C_CodRc, C_CodAlu, C_EstMat, B_Ingresante, C_CodModIng, N_Grupo, I_CredDesaprob, N_Grado)
			select m.I_MatAluID, m.C_CodRc, m.C_CodAlu, m.C_EstMat, m.B_Ingresante, a.C_CodModIng, a.N_Grupo, ISNULL(m.I_CredDesaprob, 0), a.N_Grado
			from dbo.TC_MatriculaAlumno m 
			inner join BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu and a.C_RcCod = m.C_CodRc
			where m.B_Habilitado = 1 and m.B_Eliminado = 0 and a.N_Grado in (@N_GradoMaestria, @N_Doctorado) and
				m.I_Anio = @I_Anio and m.I_Periodo = @I_Periodo and a.C_CodEsc = @C_CodEsc
		end
	end
	
	--3ro Comienzo con el calculo las obligaciones por alumno almacenandolas en @Tmp_Procesos.
	declare @Tmp_Procesos table (I_ProcesoID int, I_ConcPagID int, M_Monto decimal(15,2), D_FecVencto datetime, I_TipoObligacion int, I_Prioridad tinyint)

	declare @C_Moneda varchar(3) = 'PEN',
			@D_CurrentDate datetime = getdate(),
			@I_FilaActual int = 1,
			@I_CantRegistros int = (select max(id) from @Tmp_MatriculaAlumno),


			--Tipo de alumno
			@I_AlumnoRegular int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '1'),
			@I_AlumnoIngresante int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 1 and T_OpcionCod = '2'),


			--Tipo obligación
			@I_Matricula int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '1'),
			@I_OtrosPagos int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 3 and T_OpcionCod = '0'),


			--Campo calculado
			@I_CrdtDesaprobados int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '1'),
			@I_DeudasAnteriores int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '2'),
			@I_Pensiones int = (select I_OpcionID from dbo.TC_CatalogoOpcion where I_ParametroID = 4 and T_OpcionCod = '3'),

			--Otras variables
			@I_ObligacionAluID int,
			@I_MatAluID int,
			@C_EstMat varchar(2),
			@C_CodModIng varchar(2),
			@N_Grupo char(1),
			@I_TipoAlumno int,
			@I_MontoDeuda decimal(15,2),
			@I_CredDesaprob tinyint,
			@N_NroPagos tinyint,
			@N_Grado char(1),

			--Variables para comprobar modificaciones
			@I_MontoInicial decimal(15,2),
			@I_MontoActual decimal(15,2),
			@D_FecVenctoInicial datetime,
			@D_FecVenctoActual datetime,
			@I_ProcesoID int,
			@B_Pagado bit

	declare @Tmp_grupo_otros_pagos table (id int, I_ProcesoID int)
	declare @I_FilaActual_OtrsPag int,
			@I_CantRegistros_OtrsPag int,
			@I_ProcesoID_OtrsPag int

	while (@I_FilaActual <= @I_CantRegistros) begin
		begin tran
		begin try
			--4to obtengo la información alumno por alumno e inicializo variables
			select @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, 
				@N_Grupo = N_Grupo, @I_CredDesaprob = ISNULL(I_CredDesaprob, 0), @N_Grado = N_Grado,
				@I_TipoAlumno = (case when B_Ingresante = 0 then @I_AlumnoRegular else @I_AlumnoIngresante end) 
			from @Tmp_MatriculaAlumno 
			where id = @I_FilaActual

			delete @Tmp_Procesos

			--Pagos de Matrícula
			if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
				B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng and C_Nivel = @N_Grado) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_CodModIng = @C_CodModIng and C_Nivel = @N_Grado
			end
			else
			begin
				if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 1 and C_Nivel = @N_Grado and C_CodModIng is null) = 1
				begin
					insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
					select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
						B_EsPagoMatricula = 1 and C_Nivel = @N_Grado and C_CodModIng is null
				end	
			end

			--Pagos generales de matrícula
			insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
			select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
			where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and
				B_EsPagoMatricula = 0 and B_Calculado = 0 and B_GrupoCodRc = 0 and B_EsPagoExtmp = 0 and C_Nivel = @N_Grado

			--Pagos extemoráneos
			if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and C_Nivel = @N_Grado and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0) = 1
			begin
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and I_TipoObligacion = @I_Matricula and 
					B_EsPagoMatricula = 0 and B_EsPagoExtmp = 1 and C_Nivel = @N_Grado and
					datediff(day, @D_CurrentDate, D_FecVencto) < 0
			end
			
			--Monto de Pensión de enseñanza
			if (select count(I_ProcesoID) from #tmp_conceptos_posgrado
				where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_Nivel = @N_Grado) = 1
			begin
				set @N_NroPagos = isnull((select top 1 N_NroPagos from #tmp_conceptos_posgrado 
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_Nivel = @N_Grado), 1);
				
				with CTE_Recursivo as
				(
					select 1 as num, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad from #tmp_conceptos_posgrado
					where I_TipoAlumno = @I_TipoAlumno and B_Calculado = 1 and I_Calculado = @I_Pensiones and C_Nivel = @N_Grado
					union all
					select num + 1, I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad
					from CTE_Recursivo
					where num < @N_NroPagos
				)
				insert @Tmp_Procesos(I_ProcesoID, I_ConcPagID, M_Monto, D_FecVencto, I_TipoObligacion, I_Prioridad)
				select I_ProcesoID, I_ConcPagID, cast(M_Monto / @N_NroPagos as decimal(15,2)) as M_Monto, 
					DATEADD(MONTH, num-1, D_FecVencto), I_TipoObligacion, I_Prioridad
				from CTE_Recursivo
			end

			--Grabando pago de matrícula
			set @I_ProcesoID = 0

			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)
			begin
				set @I_ProcesoID = (select distinct p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 1)

				if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID)
				begin
					select @I_MontoInicial = cab.I_MontoOblig, @D_FecVenctoInicial = cab.D_FecVencto, @B_Pagado = cab.B_Pagado from dbo.TR_ObligacionAluCab cab 
					where cab.B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

					select @D_FecVenctoActual = p.D_FecVencto, @I_MontoActual = Sum(p.M_Monto) from @Tmp_Procesos p 
					where p.I_Prioridad = 1 group by p.D_FecVencto

					if (@B_Pagado = 0)
					begin
						if Not (DATEDIFF(Day, @D_FecVenctoInicial, @D_FecVenctoActual) = 0) Or Not (@I_MontoInicial = @I_MontoActual)
						begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 1 
							group by p.I_ProcesoID, p.D_FecVencto

							set @I_ObligacionAluID = SCOPE_IDENTITY()

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
							where p.I_Prioridad = 1
						end
					end
				end
				else
				begin
					--insert
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 1 
					group by p.I_ProcesoID, p.D_FecVencto

					set @I_ObligacionAluID = SCOPE_IDENTITY()

					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
					select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
					where p.I_Prioridad = 1
				end
			end

			--Grabando otros pagos
			if exists(select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2)
			begin
				if not exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
					where cab.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and
						cab.I_ProcesoID in (select p.I_ProcesoID from @Tmp_Procesos p where p.I_Prioridad = 2))
				begin
					--Nuevos registros de obligaciones

					--Insert de cabecera
					insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
					select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID, p.D_FecVencto

					--Insert de detalle
					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
					select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
					inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID and cab.I_MatAluID = @I_MatAluID and
						DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
					where p.I_Prioridad = 2
				end
				else
				begin
					--Edición de obligaciones

					if exists(select id from @Tmp_grupo_otros_pagos) begin
						delete @Tmp_grupo_otros_pagos
					end

					insert @Tmp_grupo_otros_pagos(id, I_ProcesoID)
					select ROW_NUMBER() OVER (ORDER BY I_ProcesoID), I_ProcesoID from @Tmp_Procesos p
					where p.I_Prioridad = 2
					group by p.I_ProcesoID
					
					set @I_FilaActual_OtrsPag = 1
					set @I_CantRegistros_OtrsPag = (select max(id) from @Tmp_grupo_otros_pagos)

					while (@I_FilaActual_OtrsPag <= @I_CantRegistros_OtrsPag) begin
						--Los otros pagos se agrupan primero por proceso y luego por fecha de vcto.
						set @I_ProcesoID_OtrsPag = (select I_ProcesoID from @Tmp_grupo_otros_pagos where id = @I_FilaActual_OtrsPag)

						if exists(select cab.I_ObligacionAluID from dbo.TR_ObligacionAluCab cab
							inner join dbo.TR_ObligacionAluDet det on det.I_ObligacionAluID = cab.I_ObligacionAluID
							where cab.B_Eliminado = 0 and det.B_Eliminado = 0 and cab.I_MatAluID = @I_MatAluID and 
							cab.I_ProcesoID = @I_ProcesoID_OtrsPag AND cab.B_Pagado = 1) begin
							
							print 'Existen al menos un pago realizado.'

						end
						else begin
							update d set d.B_Habilitado = 0, d.B_Eliminado = 1, d.I_UsuarioMod = @I_UsuarioCre, d.D_FecMod = @D_CurrentDate
							from dbo.TR_ObligacionAluCab c
							inner join dbo.TR_ObligacionAluDet d on d.I_ObligacionAluID = c.I_ObligacionAluID
							where d.B_Eliminado = 0 and c.B_Eliminado = 0 and c.I_MatAluID = @I_MatAluID and c.I_ProcesoID = @I_ProcesoID_OtrsPag

							update dbo.TR_ObligacionAluCab set B_Habilitado = 0, B_Eliminado = 1, I_UsuarioMod = @I_UsuarioCre, D_FecMod = @D_CurrentDate
							where B_Eliminado = 0 and I_MatAluID = @I_MatAluID and I_ProcesoID = @I_ProcesoID_OtrsPag

							insert dbo.TR_ObligacionAluCab(I_ProcesoID, I_MatAluID, C_Moneda, I_MontoOblig, B_Pagado, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, D_FecVencto)
							select p.I_ProcesoID, @I_MatAluID, @C_Moneda, Sum(p.M_Monto), 0, 1, 0, @I_UsuarioCre, @D_CurrentDate, p.D_FecVencto from @Tmp_Procesos p
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
							group by p.I_ProcesoID, p.D_FecVencto

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
							select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate, 0 from @Tmp_Procesos p
							inner join dbo.TR_ObligacionAluCab cab on cab.B_Habilitado = 1 and cab.B_Eliminado = 0 and p.I_ProcesoID = cab.I_ProcesoID  and cab.I_MatAluID = @I_MatAluID and
								DATEDIFF(Day, p.D_FecVencto, cab.D_FecVencto) = 0
							where p.I_Prioridad = 2 and p.I_ProcesoID = @I_ProcesoID_OtrsPag
						end

						set @I_FilaActual_OtrsPag = (@I_FilaActual_OtrsPag + 1)
					end
				end
			end

			commit tran
		end try
		begin catch
			rollback tran

			print ERROR_MESSAGE()
			print ERROR_LINE()
		end catch

		set @I_FilaActual = (@I_FilaActual +1)
	end

	set @B_Result = 1
	set @T_Message = 'El proceso finalizó correctamente.'
/*
declare @B_Result bit,
		@T_Message nvarchar(4000)

exec USP_IU_GenerarObligacionesPosgrado_X_Ciclo  2021, 19, NULL, NULL,  NULL, 1,
@B_Result OUTPUT,
@T_Message OUTPUT

select @B_Result, @T_Message
go
--24 seg , 26, 33
*/
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ValidarCodOperacionObligacion')
	DROP PROCEDURE [dbo].[USP_S_ValidarCodOperacionObligacion]
GO


CREATE PROCEDURE [dbo].[USP_S_ValidarCodOperacionObligacion]
@C_CodOperacion VARCHAR(50),
@C_CodDepositante VARCHAR(20) = NULL,
@I_EntidadFinanID INT,
@D_FecPago DATETIME =  NULL,
@B_Correct BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @I_BcoComercio INT = 1,
			@I_BcoCredito INT = 2

	SET @B_Correct = 0

	IF (@I_EntidadFinanID = @I_BcoComercio) BEGIN
		SET @B_Correct = CASE WHEN EXISTS(SELECT p.I_PagoBancoID FROM dbo.TR_PagoBanco p
			WHERE p.B_Anulado = 0 AND p.I_EntidadFinanID = @I_BcoComercio AND
				C_CodOperacion = @C_CodOperacion) THEN 0 ELSE 1 END
	END

	IF (@I_EntidadFinanID = @I_BcoCredito) BEGIN
		SET @B_Correct = CASE WHEN EXISTS(SELECT p.I_PagoBancoID FROM dbo.TR_PagoBanco p
			WHERE p.B_Anulado = 0 AND p.I_EntidadFinanID = @I_BcoCredito AND NOT p.C_CodDepositante = @C_CodDepositante AND
				DATEDIFF(HOUR, p.D_FecPago, @D_FecPago) = 0 AND C_CodOperacion = @C_CodOperacion) THEN 0 ELSE 1 END
	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataPago') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
		DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]

	DROP TYPE [dbo].[type_dataPago]
END
GO

CREATE TYPE [dbo].[type_dataPago] AS TABLE(
	--Datos de pago
	C_CodOperacion		varchar(50),
	T_NomDepositante	varchar(200),
	C_Referencia		varchar(50),
	D_FecPago			datetime,
	I_Cantidad			int,
	C_Moneda			varchar(3),
	I_MontoPago			decimal(15,2),
	I_InteresMora		decimal(15,2),
	T_LugarPago			varchar(250),
	--Identificar obligaciones
	C_CodAlu			varchar(20),
	C_CodRc				varchar(3),
	I_ProcesoID			int,
	D_FecVencto			datetime,
	I_EntidadFinanID	int,
	I_CtaDepositoID		int,
	T_InformacionAdicional varchar(250),
	T_ProcesoDesc varchar(250)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
(
	 @Tbl_Pagos	[dbo].[type_dataPago]	READONLY
	,@Observacion	varchar(250)
	,@D_FecRegistro datetime
	,@UserID		int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Tmp_PagoObligacion TABLE (
		id INT IDENTITY(1,1),
		I_ProcesoID			int NULL,
		I_ObligacionAluID	int NULL,
		C_CodOperacion		varchar(50),
		C_CodDepositante	varchar(20),
		T_NomDepositante	varchar(200),
		C_Referencia		varchar(50),
		D_FecPago			datetime,
		D_FecVencto			datetime,
		D_FecVenctoBD		datetime,
		I_Cantidad			int,
		C_Moneda			varchar(3),
		I_MontoOblig		decimal(15,2) NULL,
		I_MontoPago			decimal(15,2),
		I_InteresMora		decimal(15,2),
		T_LugarPago			varchar(250),
		I_EntidadFinanID	int,
		I_CtaDepositoID		int,
		B_Pagado			bit NULL,
		B_Success			bit,
		T_ErrorMessage		varchar(250),
		T_InformacionAdicional		varchar(250),
		T_ProcesoDesc		varchar(250)
	);

	DECLARE @Tmp_DetalleObligacion TABLE(
		id INT,
		I_ObligacionAluDetID int,
		I_MontoDet			decimal(15,2),
		I_MontoPagadoDet	decimal(15,2)
	);

	WITH Matriculados(I_ObligacionAluID, C_CodAlu, C_CodRc, I_ProcesoID, D_FecVencto, B_Pagado, I_MontoOblig)
	AS 
	(
		SELECT cab.I_ObligacionAluID, m.C_CodAlu, m.C_CodRc, cab.I_ProcesoID, cab.D_FecVencto, cab.B_Pagado, cab.I_MontoOblig
		FROM dbo.TC_MatriculaAlumno m
		LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = m.I_MatAluID AND cab.B_Eliminado = 0
		WHERE m.B_Eliminado = 0
	)
	INSERT @Tmp_PagoObligacion(I_ProcesoID, I_ObligacionAluID, C_CodOperacion, C_CodDepositante, T_NomDepositante, 
		C_Referencia, D_FecPago, D_FecVencto, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, I_InteresMora, T_LugarPago, I_EntidadFinanID, I_CtaDepositoID, B_Pagado,
		T_InformacionAdicional, T_ProcesoDesc, D_FecVenctoBD)
	SELECT m.I_ProcesoID, m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,
		p.C_Referencia, p.D_FecPago, p.D_FecVencto, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.I_EntidadFinanID, I_CtaDepositoID, m.B_Pagado,
		p.T_InformacionAdicional, p.T_ProcesoDesc, m.D_FecVencto
	FROM @Tbl_Pagos p
	LEFT JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND 
		m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0

	DECLARE @I_FilaActual		int = 1,
			@I_CantRegistros	int = (select count(id) from @Tmp_PagoObligacion),
			@I_ProcesoID		int,
			@I_ObligacionAluID	int,
			--PAGO EN BANCO
			@I_PagoBancoID		int,			
			@C_CodOperacion		varchar(50),
			@C_CodDepositante	varchar(20),
			@T_NomDepositante	varchar(200),
			@C_Referencia		varchar(50),
			@D_FecPago			datetime,
			@I_Cantidad			int,
			@C_Moneda			varchar(3),
			@I_MontoPago		decimal(15,2),
			@I_InteresMora		decimal(15,2),
			@T_LugarPago		varchar(250),
			@I_EntidadFinanID	int,
			@I_CtaDepositoID	int,
			@T_InformacionAdicional	varchar(250),
			--PAGO DETALLE
			@I_FilaActualDet	int,
			@I_CantRegistrosDet	int,
			@I_ObligacionAluDetID	int,			
			@I_MontoOligacionDet	decimal(15,2),
			@I_MontoPagadoActual	decimal(15,2),
			@I_SaldoPendiente	decimal(15,2),
			@I_MontoAPagar		decimal(15,2),
			@I_NuevoSaldoPend	decimal(15,2),
			@I_PagoDemas		decimal(15,2),
			@B_PagoDemas		bit,
			@B_Pagado			bit,
			--MORA
			@I_ConcPagID		int,
			@D_FecVencto		datetime,
			--CONTROL ERRORES
			@D_FecVenctoBD		datetime,
			@B_ExisteError		bit,
			@B_CodOpeCorrecto	bit,
			@B_ObligPagada		bit,
			--Constantes
			@CondicionCorrecto	int = 131,--PAGO CORRECTO
			@PagoTipoObligacion	int = 133--OBLIGACION

	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN
		
		SET @B_ExisteError = 0

		SELECT  @I_ProcesoID = I_ProcesoID,
				@I_ObligacionAluID = I_ObligacionAluID, 
				@C_CodOperacion = C_CodOperacion, 
				@C_CodDepositante = C_CodDepositante, 
				@T_NomDepositante = T_NomDepositante, 
				@C_Referencia = C_Referencia, 
				@D_FecPago = D_FecPago, 
				@D_FecVencto = D_FecVencto,
				@I_Cantidad = I_Cantidad,
				@C_Moneda = C_Moneda, 
				@I_MontoPago = I_MontoPago,
				@I_InteresMora = I_InteresMora,
				@T_LugarPago= T_LugarPago,
				@I_EntidadFinanID = I_EntidadFinanID,
				@I_CtaDepositoID = I_CtaDepositoID,
				@B_ObligPagada = B_Pagado,
				@T_InformacionAdicional = T_InformacionAdicional,
				@D_FecVenctoBD = D_FecVenctoBD
			FROM @Tmp_PagoObligacion WHERE id = @I_FilaActual

		IF (@I_ObligacionAluID IS NULL) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe obligaciones para este alumno.' WHERE id = @I_FilaActual
		END

		IF (@B_ExisteError = 0) AND (@B_ObligPagada = 1) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'Esta obligación ya ha sido pagada con anterioridad.' WHERE id = @I_FilaActual
		END

		IF  (@B_ExisteError = 0) BEGIN
			EXEC dbo.USP_S_ValidarCodOperacionObligacion @C_CodOperacion, @C_CodDepositante, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT

			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1
				
				UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual
			END
		END

		IF (@B_ExisteError = 0) AND (@I_InteresMora > 0) AND 
			NOT EXISTS(SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1) BEGIN

			SET @B_ExisteError = 1
				
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe un concepto para guardar el Interés moratorio.' WHERE id = @I_FilaActual
		END

		IF (@B_ExisteError = 0) AND (@I_CtaDepositoID IS NULL) BEGIN
			SET @I_CtaDepositoID = (SELECT cta.I_CtaDepositoID FROM dbo.TI_CtaDepo_Proceso cta
				INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cta.I_CtaDepositoID
				WHERE cta.B_Habilitado = 1 AND cta.B_Eliminado = 0 AND 
					cta.I_ProcesoID = @I_ProcesoID and c.I_EntidadFinanID = @I_EntidadFinanID)

			IF (@I_CtaDepositoID IS NULL) BEGIN
				SET @B_ExisteError = 1
				
				UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe una Cuenta asignada para registrar la obligación.' WHERE id = @I_FilaActual
			END
		END

		IF (@B_ExisteError = 0) BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad, 
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad, 
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,
					@T_InformacionAdicional, @CondicionCorrecto, @PagoTipoObligacion, @I_CtaDepositoID, @I_InteresMora)

				SET @I_PagoBancoID = SCOPE_IDENTITY()

				DELETE FROM @Tmp_DetalleObligacion

				INSERT @Tmp_DetalleObligacion(id, I_ObligacionAluDetID, I_MontoDet, I_MontoPagadoDet)
				SELECT ROW_NUMBER() OVER (ORDER BY det.I_Monto ASC), det.I_ObligacionAluDetID, det.I_Monto, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoPagado 
				FROM dbo.TR_ObligacionAluDet det
				LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND p.B_Anulado = 0
				WHERE det.I_ObligacionAluID = @I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND det.B_Mora = 0 AND det.B_Pagado = 0
				GROUP BY det.I_ObligacionAluDetID, det.I_Monto
				ORDER BY det.I_Monto ASC

				SET @I_FilaActualDet = 1
				SET @I_CantRegistrosDet = (SELECT COUNT(*) FROM @Tmp_DetalleObligacion)

				WHILE (@I_FilaActualDet <= @I_CantRegistrosDet AND @I_MontoPago > 0) BEGIN

					SELECT
						@I_ObligacionAluDetID = I_ObligacionAluDetID, 
						@I_MontoOligacionDet = I_MontoDet, 
						@I_MontoPagadoActual = I_MontoPagadoDet 
					FROM @Tmp_DetalleObligacion WHERE id = @I_FilaActualDet

					SET @I_SaldoPendiente = @I_MontoOligacionDet - @I_MontoPagadoActual

					EXEC dbo.USP_AsignarPagoDetalleObligacion
						@I_FilaActualDet = @I_FilaActualDet,
						@I_CantRegistrosDet = @I_CantRegistrosDet,
						@I_SaldoPendiente  = @I_SaldoPendiente,
						@I_MontoPago = @I_MontoPago OUTPUT,
						@B_Pagado = @B_Pagado OUTPUT,
						@I_MontoAPagar = @I_MontoAPagar OUTPUT,
						@I_NuevoSaldoPend = @I_NuevoSaldoPend OUTPUT,
						@I_PagoDemas = @I_PagoDemas OUTPUT,
						@B_PagoDemas = @B_PagoDemas OUTPUT
				
					INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas,
						D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
					VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_MontoAPagar, @I_NuevoSaldoPend, @I_PagoDemas, @B_PagoDemas,
						@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)

					IF (@B_Pagado = 1) BEGIN
						UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
						WHERE I_ObligacionAluDetID = @I_ObligacionAluDetID
					END

					SET @I_FilaActualDet = @I_FilaActualDet + 1
				END
				
				IF NOT EXISTS (SELECT d.I_ObligacionAluID FROM dbo.TR_ObligacionAluDet d 
					WHERE d.I_ObligacionAluID = @I_ObligacionAluID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0 AND d.B_Mora = 0 AND d.B_Pagado = 0)
				BEGIN
					UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = 1, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
					WHERE I_ObligacionAluID = @I_ObligacionAluID
				END

				IF (@I_InteresMora > 0) BEGIN
					SET @I_ConcPagID = (SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1)

					INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, B_Mora)
					VALUES (@I_ObligacionAluID, @I_ConcPagID, @I_InteresMora, 1, @D_FecVencto, 1, 0, @UserID, @D_FecRegistro, 1)

					SET @I_ObligacionAluDetID = SCOPE_IDENTITY()

					INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluDetID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas, B_PagoDemas, 
						D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
					VALUES(@I_PagoBancoID, @I_ObligacionAluDetID, @I_InteresMora, 0, 0, 0,@D_FecRegistro, @UserID, 0, @I_CtaDepositoID)
				END

				UPDATE @Tmp_PagoObligacion SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION

				UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual
			END CATCH
		END

		SET @I_FilaActual = @I_FilaActual + 1
	END

	SELECT * FROM @Tmp_PagoObligacion
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ValidarCodOperacionTasa')
	DROP PROCEDURE [dbo].[USP_S_ValidarCodOperacionTasa]
GO


CREATE PROCEDURE [dbo].[USP_S_ValidarCodOperacionTasa]
@C_CodOperacion VARCHAR(50),
@I_EntidadFinanID INT,
@D_FecPago DATETIME =  NULL,
@B_Correct BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @I_BcoComercio INT = 1,
			@I_BcoCredito INT = 2

	SET @B_Correct = 0

	IF (@I_EntidadFinanID = @I_BcoComercio) BEGIN
		SET @B_Correct = CASE WHEN EXISTS(SELECT b.I_PagoBancoID FROM dbo.TR_PagoBanco b
			INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = b.I_PagoBancoID
			WHERE b.B_Anulado = 0 AND pr.B_Anulado = 0 AND pr.I_TasaUnfvID IS NOT NULL AND b.I_EntidadFinanID = @I_BcoComercio AND
				b.C_CodOperacion = @C_CodOperacion) THEN 0 ELSE 1 END
	END

	IF (@I_EntidadFinanID = @I_BcoCredito) BEGIN
		SET @B_Correct = CASE WHEN EXISTS(SELECT B.I_PagoBancoID FROM dbo.TR_PagoBanco b
			INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = b.I_PagoBancoID
			WHERE b.B_Anulado = 0 AND pr.B_Anulado = 0 AND pr.I_TasaUnfvID IS NOT NULL AND 
				b.I_EntidadFinanID = @I_BcoCredito AND b.C_CodOperacion = @C_CodOperacion AND
				DATEDIFF(HOUR, b.D_FecPago, @D_FecPago) = 0) THEN 0 ELSE 1 END
	END
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.DOMAINS WHERE DOMAIN_NAME = 'type_dataPagoTasa') BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoTasas')
		DROP PROCEDURE [dbo].[USP_I_GrabarPagoTasas]

	DROP TYPE [dbo].[type_dataPagoTasa]
END
GO

CREATE TYPE [dbo].[type_dataPagoTasa] AS TABLE(
	C_CodDepositante	varchar(20),
	T_NomDepositante	varchar(200),
	C_CodServicio		varchar(20),
	C_CodTasa			varchar(5),
	T_TasaDesc			varchar(200),
	C_CodOperacion		varchar(50),
	C_Referencia		varchar(50),
	I_EntidadFinanID	int,
	I_CtaDepositoID		int,
	D_FecPago			datetime,
	I_Cantidad			int,
	C_Moneda			varchar(3),
	I_MontoPago			decimal(15,2),
	I_InteresMora		decimal(15,2),
	T_LugarPago			varchar(250),
	T_InformacionAdicional varchar(250)
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoTasas')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoTasas]
(
	 @Tbl_Pagos	[dbo].[type_dataPagoTasa]	READONLY
	,@Observacion	varchar(250)
	,@D_FecRegistro datetime
	,@UserID		int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Tmp_PagoTasas TABLE (
		id					int identity(1,1),
		I_TasaUnfvID		int,
		I_MontoTasa			decimal(15,2),
		C_CodDepositante	varchar(20),
		T_NomDepositante	varchar(200),
		C_CodTasa			varchar(5),
		T_TasaDesc			varchar(200),
		C_CodOperacion		varchar(50),
		C_Referencia		varchar(50),
		I_EntidadFinanID	int,
		I_CtaDepositoID		int,
		D_FecPago			datetime,
		I_Cantidad			int,
		C_Moneda			varchar(3),
		I_MontoPago			decimal(15,2),
		I_InteresMora		decimal(15,2),
		T_LugarPago			varchar(250),
		T_InformacionAdicional varchar(250),
		B_Success			bit,
		T_ErrorMessage		varchar(250)
	);

	INSERT @Tmp_PagoTasas(I_TasaUnfvID, I_MontoTasa, C_CodDepositante, T_NomDepositante, C_CodTasa, 
		T_TasaDesc, C_CodOperacion, C_Referencia, I_EntidadFinanID, I_CtaDepositoID, D_FecPago, 
		I_Cantidad, C_Moneda, I_MontoPago, I_InteresMora, T_LugarPago, T_InformacionAdicional)
	SELECT t.I_TasaUnfvID, t.M_Monto, p.C_CodDepositante, p.T_NomDepositante, p.C_CodTasa,
		CASE WHEN t.I_TasaUnfvID IS NULL THEN p.T_TasaDesc ELSE t.T_ConceptoPagoDesc END,
		p.C_CodOperacion, p.C_Referencia, p.I_EntidadFinanID,
		CASE WHEN p.I_CtaDepositoID IS NULL 
			THEN 
				(SELECT tc.I_CtaDepositoID FROM VW_PagoTasas_X_Cuenta tc WHERE tc.I_TasaUnfvID = t.I_TasaUnfvID AND tc.C_CodServicio = p.C_CodServicio AND tc.I_EntidadFinanID = p.I_EntidadFinanID)
			ELSE p.I_CtaDepositoID END,
		p.D_FecPago, p.I_Cantidad, p.C_Moneda, p.I_MontoPago, ISNULL(p.I_InteresMora, 0), p.T_LugarPago, p.T_InformacionAdicional
	FROM @Tbl_Pagos p
	LEFT JOIN dbo.TI_TasaUnfv t ON t.C_CodTasa = p.C_CodTasa and t.B_Habilitado = 1 and t.B_Eliminado = 0

	DECLARE @I_FilaActual		int = 1,
			@I_CantRegistros	int = (select count(id) from @Tmp_PagoTasas),
			@I_SaldoAPagar		decimal(15,2),
			@I_PagoDemas		decimal(15,2),
			@B_PagoDemas		bit,
			-----------------------------------------------------------
			@I_PagoBancoID		int,
			@I_TasaUnfvID		int,
			@I_MontoTasa		decimal(15,2),
			@C_CodDepositante	varchar(20),
			@T_NomDepositante	varchar(200),
			@C_CodTasa			varchar(3),
			@T_TasaDesc			varchar(3),
			@C_CodOperacion		varchar(50),
			@C_Referencia		varchar(50),
			@I_EntidadFinanID	int,
			@I_CtaDepositoID	int,
			@D_FecPago			datetime,
			@I_Cantidad			int,
			@C_Moneda			varchar(3),
			@I_MontoPago		decimal(15,2),
			@I_InteresMora		decimal(15,2),
			@T_LugarPago		varchar(250),	
			@T_InformacionAdicional varchar(250),
			@B_ExisteError		bit,
			@B_CodOpeCorrecto	bit,
			--Constantes
			@CondicionCorrecto	int = 131,--PAGO CORRECTO
			@PagoTipoTasa		int = 134--OBLIGACION
	
	WHILE (@I_FilaActual <= @I_CantRegistros) BEGIN
		
		SET @B_ExisteError = 0

		SELECT  @I_TasaUnfvID = I_TasaUnfvID,
				@I_MontoTasa = I_MontoTasa,
				@C_CodDepositante = C_CodDepositante,
				@T_NomDepositante = T_NomDepositante,
				@C_CodTasa = C_CodTasa,
				@T_TasaDesc = T_TasaDesc,
				@C_CodOperacion = C_CodOperacion,
				@C_Referencia = C_Referencia,
				@I_EntidadFinanID = I_EntidadFinanID,
				@I_CtaDepositoID = I_CtaDepositoID,
				@D_FecPago = D_FecPago,
				@I_Cantidad = I_Cantidad,
				@C_Moneda = C_Moneda,
				@I_MontoPago = I_MontoPago,
				@I_InteresMora = I_InteresMora,
				@T_LugarPago = T_LugarPago,
				@T_InformacionAdicional = T_InformacionAdicional
			FROM @Tmp_PagoTasas WHERE id = @I_FilaActual

		IF (@I_TasaUnfvID IS NULL) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'No existe el código de tasa.' WHERE id = @I_FilaActual
		END

		IF (@B_ExisteError = 0 AND @I_CtaDepositoID IS NULL) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'Esta tasa no tiene asignado una cuenta.' WHERE id = @I_FilaActual
		END

		IF  (@B_ExisteError = 0) BEGIN
			EXEC USP_S_ValidarCodOperacionTasa @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT

			IF NOT (@B_CodOpeCorrecto = 1) BEGIN
				SET @B_ExisteError = 1
				
				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = 'El código de operación "' + @C_CodOperacion + '" se encuentra duplicado en el sistema.' WHERE id = @I_FilaActual
			END
		END

		IF (@B_ExisteError = 0) BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad, 
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID, T_Observacion,
					T_InformacionAdicional, I_CondicionPagoID, I_TipoPagoID, I_CtaDepositoID, I_InteresMora)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad, 
					@C_Moneda, @I_MontoPago, @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID, @Observacion,
					@T_InformacionAdicional, @CondicionCorrecto, @PagoTipoTasa, @I_CtaDepositoID, @I_InteresMora)

				SET @I_PagoBancoID = SCOPE_IDENTITY()

				--Pago menor
				SET @I_SaldoAPagar = @I_MontoTasa - @I_MontoPago
	
				SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END

				--Pago excedente
				SET @I_PagoDemas = @I_MontoPago - @I_MontoTasa
					
				SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END

				SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END

				INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_TasaUnfvID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,
					B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
				VALUES(@I_PagoBancoID, @I_TasaUnfvID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas, 
					@B_PagoDemas, @D_FecRegistro, @UserID, 0, @I_CtaDepositoID)

				UPDATE @Tmp_PagoTasas SET B_Success = 1, T_ErrorMessage = 'Registro correcto.' WHERE id = @I_FilaActual

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION

				UPDATE @Tmp_PagoTasas SET B_Success = 0, T_ErrorMessage = ERROR_MESSAGE() WHERE id = @I_FilaActual
			END CATCH
		END

		SET @I_FilaActual = @I_FilaActual + 1
	END

	SELECT * FROM @Tmp_PagoTasas
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_MatriculaAlumno')
	DROP VIEW [dbo].[VW_MatriculaAlumno]
GO

CREATE VIEW [dbo].[VW_MatriculaAlumno]
AS
SELECT 
	m.I_MatAluID, a.C_CodAlu, a.C_RcCod, a.T_Nombre, a.T_ApePaterno, ISNULL(a.T_ApeMaterno, '') AS T_ApeMaterno, a.N_Grado, m.I_Anio, m.I_Periodo, 
	a.C_CodFac, a.T_FacDesc, a.C_CodEsc, a.T_EscDesc, m.C_EstMat, m.C_Ciclo, m.B_Ingresante, m.I_CredDesaprob, m.B_Habilitado, cat.T_OpcionCod as C_Periodo, cat.T_OpcionDesc as T_Periodo,
	a.T_DenomProg, a.C_CodModIng, A.T_ModIngDesc, CASE WHEN nv.I_AluMultaID IS NULL THEN 0 ELSE 1 END B_TieneMultaPorNoVotar
FROM TC_MatriculaAlumno m 
INNER JOIN BD_UNFV_Repositorio.dbo.VW_Alumnos a ON a.C_CodAlu = m.C_CodAlu AND a.C_RcCod = m.C_CodRc
LEFT JOIN dbo.TC_CatalogoOpcion cat ON cat.I_ParametroID = 5 and cat.I_OpcionID = m.I_Periodo
LEFT JOIN dbo.TC_AlumnoMultaNoVotar nv ON nv.B_Eliminado = 0 and nv.C_CodAlu = m.C_CodAlu and nv.C_CodRc = m.C_CodRc and nv.I_Periodo = m.I_Periodo and nv.I_Anio = m.I_Anio
WHERE m.B_Eliminado = 0
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DetalleObligaciones')
	DROP VIEW [dbo].[VW_DetalleObligaciones]
GO


CREATE VIEW [dbo].[VW_DetalleObligaciones]
AS
SELECT 
	cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, mat.C_CodModIng,
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, 
	pro.T_ProcesoDesc, ISNULL(cp.T_ConceptoPagoDesc, con.T_ConceptoDesc) AS T_ConceptoDesc, cat.T_CatPagoDesc, det.I_Monto, det.B_Pagado, det.D_FecVencto, pro.I_Prioridad,
	cab.C_Moneda, cp.I_TipoObligacion, cat.I_Nivel, niv.T_OpcionCod AS C_Nivel, niv.T_OpcionDesc AS T_Nivel, cat.I_TipoAlumno, tipal.T_OpcionCod AS C_TipoAlumno, 
	tipal.T_OpcionDesc AS T_TipoAlumno, cp.B_Mora
FROM dbo.VW_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0 
INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID and det.B_Habilitado = 1 AND det.B_Eliminado = 0
INNER JOIN dbo.TI_ConceptoPago cp ON cp.I_ConcPagID = det.I_ConcPagID AND det.B_Eliminado = 0
INNER JOIN dbo.TC_Concepto con ON con.I_ConceptoID = cp.I_ConceptoID AND con.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cp.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CuotasPago_X_Ciclo')
	DROP VIEW [dbo].[VW_CuotasPago_X_Ciclo]
GO

CREATE VIEW [dbo].[VW_CuotasPago_X_Ciclo]
AS
SELECT 
	ROW_NUMBER() OVER(PARTITION BY mat.I_Anio, mat.I_Periodo, mat.C_RcCod, mat.C_CodAlu ORDER BY pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
	cab.I_ObligacionAluID, mat.I_MatAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.C_CodEsc, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,
	niv.T_OpcionCod AS C_Nivel, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,
	cab.B_Pagado, cab.D_FecCre,	ISNULL(srv.C_CodServicio, '') AS C_CodServicio, mat.T_FacDesc, mat.T_DenomProg,
	ISNULL(
	(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro 
	INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID 
	WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual
FROM dbo.VW_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CuotasPago_General')
	DROP VIEW [dbo].[VW_CuotasPago_General]
GO

CREATE VIEW [dbo].[VW_CuotasPago_General]
AS
SELECT 
	ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
	cab.I_ObligacionAluID, mat.I_MatAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.C_CodEsc, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,
	niv.T_OpcionCod AS C_Nivel, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,
	cab.B_Pagado, cab.D_FecCre, ISNULL(srv.C_CodServicio, '') AS C_CodServicio, mat.T_FacDesc, mat.T_DenomProg,
	ISNULL(
	(SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro 
	INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID 
	WHERE det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0 AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual
FROM dbo.VW_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListadoEstadoObligaciones')
	DROP PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_S_ListadoEstadoObligaciones]
@B_EsPregrado BIT,
@I_Anio INT,
@I_Periodo INT = NULL,
@C_CodFac VARCHAR(2) = NULL ,
@C_CodEsc VARCHAR(3) = NULL ,
@C_RcCod VARCHAR(3) = NULL ,
@B_Ingresante BIT = NULL,
@B_ObligacionGenerada BIT = NULL,
@B_Pagado BIT = NULL,
@F_FecIni DATE = NULL,
@F_FecFin DATE = NULL,
@B_MontoPagadoDiff BIT = null--,
--@I_CtaDeposito
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Pregrado char(1) = '1',
			@Maestria char(1) = '2',
			@Doctorado char(1) = '3'

	DECLARE @SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500)
  
	SET @SQLString = N'SELECT mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod, 
		mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, 
		mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,
		mat.I_Anio, 
		mat.T_Periodo,
		ISNULL(pro.T_ProcesoDesc, '''') AS T_ProcesoDesc,
		cab.I_MontoOblig,
		cab.D_FecVencto,
		cab.B_Pagado AS B_Pagado,
		ISNULL(SUM(pagpro.I_MontoPagado), 0) AS I_MontoPagadoActual,
		cab.D_FecCre,
		cab.D_FecMod
		FROM dbo.VW_MatriculaAlumno mat
		LEFT JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		LEFT JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		LEFT JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
		LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0
		LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
		WHERE mat.B_Habilitado = 1 and mat.I_Anio = @I_Anio
			' + CASE WHEN @B_EsPregrado = 1 THEN 'and mat.N_Grado = @Pregrado' ELSE 'and mat.N_Grado IN (@Maestria, @Doctorado)' END + '
			' + CASE WHEN @I_Periodo IS NULL THEN '' ELSE 'and mat.I_Periodo = @I_Periodo' END + '
			' + CASE WHEN @C_CodFac IS NULL THEN '' ELSE 'and mat.C_CodFac = @C_CodFac' END + '
			' + CASE WHEN @C_CodEsc IS NULL THEN '' ELSE 'and mat.C_CodEsc = @C_CodEsc' END + '
			' + CASE WHEN @C_RcCod IS NULL THEN '' ELSE 'and mat.C_RcCod = @C_RcCod' END + '
			' + CASE WHEN @B_Ingresante IS NULL THEN '' ELSE 'and mat.B_Ingresante = @B_Ingresante' END + '
			' + CASE WHEN @B_ObligacionGenerada IS NULL THEN '' ELSE (CASE WHEN @B_ObligacionGenerada = 1 THEN 'and cab.I_ObligacionAluID IS NOT NULL' ELSE 'and cab.I_ObligacionAluID IS NULL' END) END  + '
			' + CASE WHEN @B_Pagado IS NULL  THEN '' ELSE 'and cab.B_Pagado = @B_Pagado' END + '
			' + CASE WHEN @F_FecIni IS NULL THEN '' ELSE 'and DATEDIFF(DAY, @F_FecIni, pagban.D_FecPago) >= 0' END + '
			' + CASE WHEN @F_FecFin IS NULL	THEN '' ELSE 'and DATEDIFF(DAY, pagban.D_FecPago, @F_FecFin) >= 0' END + '
		GROUP BY mat.I_MatAluID, cab.I_ObligacionAluID, mat.C_CodAlu, mat.C_RcCod, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, 
			mat.N_Grado, mat.C_CodFac, mat.T_FacDesc, mat.C_CodEsc, mat.T_EscDesc, mat.T_DenomProg, mat.B_Ingresante, mat.I_CredDesaprob,
			mat.I_Anio, mat.T_Periodo, pro.T_ProcesoDesc, cab.I_MontoOblig, cab.D_FecVencto, cab.B_Pagado, cab.D_FecCre, cab.D_FecMod
		' + CASE WHEN @B_MontoPagadoDiff IS NULL OR @B_MontoPagadoDiff = 0 THEN '' ELSE 'HAVING NOT cab.I_MontoOblig = SUM(pagpro.I_MontoPagado)' END + '
		ORDER BY mat.T_FacDesc, mat.T_DenomProg, mat.T_ApePaterno, mat.T_ApeMaterno';
	
	SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_Periodo INT = NULL, 
		@C_CodFac VARCHAR(2), @C_CodEsc VARCHAR(2), @C_RcCod VARCHAR(3) = NULL , @B_Ingresante BIT = NULL, @B_Pagado BIT = NULL, @F_FecIni DATE = NULL, @F_FecFin DATE = NULL';  
	
	EXECUTE sp_executesql @SQLString, @ParmDefinition, 
		@Pregrado = @Pregrado,
		@Maestria = @Maestria,
		@Doctorado = @Doctorado,
		@I_Anio = @I_Anio,
		@I_Periodo = @I_Periodo,
		@C_CodFac = @C_CodFac,
		@C_CodEsc = @C_CodEsc,
		@C_RcCod = @C_RcCod,
		@B_Ingresante = @B_Ingresante,
		@B_Pagado = @B_Pagado,
		@F_FecIni = @F_FecIni,
		@F_FecFin = @F_FecFin
/*
EXEC USP_S_ListadoEstadoObligaciones
@B_EsPregrado = 0,
@I_Anio = 2021,
@I_Periodo = 19,
@C_CodFac = NULL,
@C_CodEsc = NULL,
@C_RcCod = NULL,
@B_Ingresante = 1,
@B_ObligacionGenerada = 1,
@B_Pagado = 1,
@F_FecIni = NULL,
@F_FecFin = NULL,
@B_MontoPagadoDiff = NULL
GO
*/
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores]
GO

CREATE PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores]
@I_Anio INT,
@B_EsPregrado BIT,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Pregrado char(1) = '1',
			@Maestria char(1) = '2',
			@Doctorado char(1) = '3'

	DECLARE @SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500)

	SET @SQLString = N'SELECT 
			ISNULL(C_CodClasificador, '''') AS C_CodClasificador, 
			T_ClasificadorDesc, 
			ISNULL([1], 0) AS Enero,
			ISNULL([2], 0) AS Febrero,
			ISNULL([3], 0) AS Marzo,
			ISNULL([4], 0) AS Abril,
			ISNULL([5], 0) AS Mayo,
			ISNULL([6], 0) AS Junio,
			ISNULL([7], 0) AS Julio,
			ISNULL([8], 0) AS Agosto,
			ISNULL([9], 0) AS Setiembre,
			ISNULL([10], 0) AS Octubre,
			ISNULL([11], 0) AS Noviembre,
			ISNULL([12], 0) AS Diciembre
		FROM
		(
			SELECT cl.C_CodClasificador, cl.T_ClasificadorDesc, MONTH(pagban.D_FecPago) AS I_Month, SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
			FROM dbo.TR_PagoBanco pagban
			INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagpro.B_Anulado = 0 
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
			INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
			INNER JOIN dbo.TI_ConceptoPago conpag ON conpag.I_ConcPagID = det.I_ConcPagID
			INNER JOIN dbo.VW_MatriculaAlumno mat ON mat.I_MatAluID = cab.I_MatAluID
			LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = conpag.T_Clasificador
			WHERE mat.B_Habilitado = 1 AND pagban.B_Anulado = 0 AND YEAR(pagban.D_FecPago) = @I_Anio AND ' +
				CASE WHEN @B_EsPregrado = 1 THEN 'mat.N_Grado = @Pregrado' ELSE 'mat.N_Grado IN (@Maestria, @Doctorado)' END + '
				' + CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND pagban.I_EntidadFinanID = @I_EntidadFinanID' END + '
				' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND pagpro.I_CtaDepositoID = @I_CtaDepositoID' END + '
			GROUP BY cl.C_CodClasificador, cl.T_ClasificadorDesc, MONTH(pagban.D_FecPago)
		) p
		PIVOT
		(
			SUM(p.I_MontoTotal) FOR p.I_Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
		) AS pvt
		ORDER BY T_ClasificadorDesc'

	SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT'

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@Pregrado = @Pregrado,
		@Maestria= @Maestria,
		@Doctorado = @Doctorado,
		@I_Anio = @I_Anio,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID
	
/*
EXEC USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores 
	@I_Anio = 2021, 
	@B_EsPregrado = 0, 
	@I_EntidadFinanID = NULL,
	@I_CtaDepositoID = NULL
GO
*/
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia]
GO

CREATE PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia]
@I_Anio INT,
@B_EsPregrado BIT,
@I_EntidadFinanID INT = NULL,
@I_CtaDepositoID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Pregrado CHAR(1) = '1',
			@Maestria CHAR(1) = '2',
			@Doctorado CHAR(1) = '3',
			@C_CodDependencia NVARCHAR(20) = CASE WHEN @B_EsPregrado = 1 THEN 'C_CodFac' ELSE 'C_CodEsc' END,
			@T_Dependencia NVARCHAR(20) = CASE WHEN @B_EsPregrado = 1 THEN 'T_FacDesc' ELSE 'T_EscDesc' END

	DECLARE @SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500)

	SET @SQLString = N'
		SELECT 
			' + @C_CodDependencia  + ' AS C_CodDependencia, 
			' + @T_Dependencia + ' AS T_Dependencia,  
			ISNULL([1], 0) AS Enero,
			ISNULL([2], 0) AS Febrero,
			ISNULL([3], 0) AS Marzo,
			ISNULL([4], 0) AS Abril,
			ISNULL([5], 0) AS Mayo,
			ISNULL([6], 0) AS Junio,
			ISNULL([7], 0) AS Julio,
			ISNULL([8], 0) AS Agosto,
			ISNULL([9], 0) AS Setiembre,
			ISNULL([10], 0) AS Octubre,
			ISNULL([11], 0) AS Noviembre,
			ISNULL([12], 0) AS Diciembre
		FROM
		(
			SELECT mat.' + @C_CodDependencia + ', mat.' + @T_Dependencia + ', MONTH(pagban.D_FecPago) AS I_Month, SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
			FROM dbo.TR_PagoBanco pagban
			INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagpro.B_Anulado = 0 
			INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
			INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
			INNER JOIN dbo.TI_ConceptoPago conpag ON conpag.I_ConcPagID = det.I_ConcPagID
			INNER JOIN dbo.VW_MatriculaAlumno mat ON mat.I_MatAluID = cab.I_MatAluID
			LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = conpag.T_Clasificador
			WHERE mat.B_Habilitado = 1 AND pagban.B_Anulado = 0 AND YEAR(pagban.D_FecPago) = @I_Anio AND ' + 
				CASE WHEN @B_EsPregrado = 1 THEN 'mat.N_Grado = @Pregrado' ELSE 'mat.N_Grado IN (@Maestria, @Doctorado)' END + '
				' + CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND pagban.I_EntidadFinanID = @I_EntidadFinanID' END + '
				' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND pagpro.I_CtaDepositoID = @I_CtaDepositoID' END + '
			GROUP BY mat.' + @C_CodDependencia + ', mat.' + @T_Dependencia + ', MONTH(pagban.D_FecPago)
		) p
		PIVOT
		(
			SUM(p.I_MontoTotal) FOR p.I_Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
		) AS pvt
		ORDER BY 2'
	
	SET @ParmDefinition = N'@Pregrado CHAR(1), @Maestria CHAR(1), @Doctorado CHAR(1), @I_Anio INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT'

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@Pregrado = @Pregrado,
		@Maestria= @Maestria,
		@Doctorado = @Doctorado,
		@I_Anio = @I_Anio,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID

/*
EXEC USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia 
	@I_Anio = 2021, 
	@B_EsPregrado = 1, 
	@I_EntidadFinanID = NULL,
	@I_CtaDepositoID = NULL
GO
*/
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ReportePagoObligacionesPregrado')
	DROP PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPregrado]
GO

CREATE PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPregrado]
@I_TipoReporte int,
@C_CodFac	varchar(2) = NULL,
@D_FechaIni date,
@D_FechaFin date,
@I_EntidadFinanID int = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Pregrado char(1) = '1'

	--@I_TipoReporte: 1: Pagos agrupados por facultad.
	if (@I_TipoReporte = 1) begin
		select mat.T_FacDesc, mat.C_CodFac, SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
		from dbo.TR_PagoBanco pagban
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @Pregrado
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)
		group by mat.T_FacDesc, mat.C_CodFac
		order by mat.T_FacDesc
	end

	--@I_TipoReporte: 2: Pagos agrupados por concepto.
	if (@I_TipoReporte = 2) begin
		select conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc, SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
		from dbo.TR_PagoBanco pagban
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @Pregrado
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)
		group by conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
	end

	--@I_TipoReporte: 2: Pagos agrupados por concepto según para una facultad.
	if (@I_TipoReporte = 3) begin
		select mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc, 
			COUNT(pagban.I_PagoBancoID) AS I_Cantidad,
			SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
		from dbo.TR_PagoBanco pagban
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado = @Pregrado
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0 
			and mat.C_CodFac = @C_CodFac
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)
		group by mat.T_FacDesc, mat.C_CodFac, conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
		order by mat.T_FacDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
	end
	/*
	EXEC USP_S_ReportePagoObligacionesPregrado 
		@I_TipoReporte = 3,
		@C_CodFac = 'AD',
		@D_FechaIni = '20210101', 
		@D_FechaFin = '20211231',
		@I_EntidadFinanID = NULL
	*/
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ReportePagoObligacionesPosgrado')
	DROP PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPosgrado]
GO

CREATE PROCEDURE [dbo].[USP_S_ReportePagoObligacionesPosgrado]
@I_TipoReporte int,
@C_CodEsc	varchar(2) = NULL,
@D_FechaIni date,
@D_FechaFin date,
@I_EntidadFinanID int = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Maestria char(1) = '2',
			@Doctorado char(1) = '3'

	--@I_TipoReporte: 1: Pagos agrupados por maestría y doctorado.
	if (@I_TipoReporte = 1) begin
		select mat.T_EscDesc, mat.C_CodEsc,  SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
		from dbo.TR_PagoBanco pagban
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)
		group by mat.T_EscDesc, mat.C_CodEsc
		order by mat.T_EscDesc DESC
	end

	--@I_TipoReporte: 2: Pagos agrupados por concepto.
	if (@I_TipoReporte = 2) begin
		select conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc, SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
		from dbo.TR_PagoBanco pagban
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)
		group by conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
		order by cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
	end

	--@I_TipoReporte: 2: Pagos agrupados por concepto según maestría o doctorado.
	if (@I_TipoReporte = 3) begin
		select mat.T_EscDesc, mat.C_CodEsc, conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc, 
			COUNT(pagban.I_PagoBancoID) AS I_Cantidad,
			SUM(pagpro.I_MontoPagado) AS I_MontoTotal 
		from dbo.TR_PagoBanco pagban
		inner join dbo.TRI_PagoProcesadoUnfv pagpro on pagban.I_PagoBancoID = pagpro.I_PagoBancoID
		inner join dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluDetID = pagpro.I_ObligacionAluDetID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
		inner join dbo.TR_ObligacionAluCab cab ON cab.I_ObligacionAluID = det.I_ObligacionAluID AND cab.B_Habilitado = 1 AND cab.B_Eliminado = 0
		inner join dbo.TI_ConceptoPago conpag on conpag.I_ConcPagID = det.I_ConcPagID
		inner join dbo.VW_MatriculaAlumno mat on mat.I_MatAluID = cab.I_MatAluID
		left join dbo.VW_Clasificadores cl on cl.C_ClasificConceptoCod = conpag.T_Clasificador
		where pagban.B_Anulado = 0 and pagpro.B_Anulado = 0 and mat.N_Grado IN (@Maestria, @Doctorado)
			and datediff(day, @D_FechaIni, pagban.D_FecPago) >= 0 and datediff(day, pagban.D_FecPago, @D_FechaFin) >= 0 
			and mat.C_CodEsc = @C_CodEsc
			and pagban.I_EntidadFinanID = ISNULL(@I_EntidadFinanID, pagban.I_EntidadFinanID)
		group by mat.T_EscDesc, mat.C_CodEsc, conpag.I_ConceptoID, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
		order by mat.T_EscDesc, cl.C_CodClasificador, conpag.T_ConceptoPagoDesc
	end
	/*
	EXEC USP_S_ReportePagoObligacionesPosgrado 
		@I_TipoReporte = 3,
		@C_CodEsc = 'MG',
		@D_FechaIni = '20210101', 
		@D_FechaFin = '20211231',
		@I_EntidadFinanID = NULL
	*/
END
GO














/************************************** PROCEDIMIENTOS MATRICULA 2021 **********************************/
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarCuotasPagos_X_Periodo')
	DROP PROCEDURE [dbo].[USP_S_ListarCuotasPagos_X_Periodo]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarCuotasPagos_X_Periodo]
@C_CodAlu VARCHAR(10),
@I_Anio INT,
@I_PeriodoID INT
AS
/*
exec USP_S_ListarCuotasPagos_X_Periodo '2021006114',2021, 19
go
*/
BEGIN
	SET NOCOUNT ON;
	SELECT 
		vw.C_CodAlu, vw.T_ApePaterno, vw.T_ApeMaterno, vw.T_Nombre, vw.C_RcCod, vw.T_DenomProg, 
		vw.T_ProcesoDesc, vw.I_Anio, vw.T_Periodo, vw.D_FecVencto, 
		CASE WHEN (vw.C_RcCod = '064' AND vw.B_Pagado = 0 AND vw.I_MontoPagadoActual = 40) THEN CAST(1 AS BIT) ELSE vw.B_Pagado END AS B_Pagado,
		vw.I_MontoOblig, 
		null AS D_FecPago, 
		'' as C_CodOperacion, 
		'' as C_NumeroCuenta, 
		'' as T_EntidadDesc 
	FROM dbo.VW_CuotasPago_General vw
	WHERE vw.C_CodAlu = @C_CodAlu AND vw.I_Anio = @I_Anio AND vw.I_Periodo = @I_PeriodoID AND vw.I_Prioridad = 1
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarIngresos_X_CuotasPagos')
	DROP PROCEDURE [dbo].[USP_S_ListarIngresos_X_CuotasPagos]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarIngresos_X_CuotasPagos]
@C_CodAlu VARCHAR(10),
@I_Anio INT,
@I_PeriodoID INT
AS
/*
exec USP_S_ListarIngresos_X_CuotasPagos '2021006114',2021, 19
go
*/
BEGIN
	SET NOCOUNT ON;
	SELECT vw.I_ObligacionAluID, pagban.I_MontoPago + pagban.I_InteresMora AS I_MontoPago, pagban.D_FecPago, pagban.C_CodOperacion, cta.C_NumeroCuenta, ef.T_EntidadDesc FROM dbo.VW_CuotasPago_General vw
	INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = vw.I_ObligacionAluID AND det.B_Habilitado = 1 AND det.B_Eliminado = 0
	INNER JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluDetID = det.I_ObligacionAluDetID AND pagpro.B_Anulado = 0
	INNER JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
	INNER JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
	WHERE vw.C_CodAlu = @C_CodAlu AND vw.I_Anio = @I_Anio AND vw.I_Periodo = @I_PeriodoID AND vw.I_Prioridad = 1
	GROUP BY vw.I_ObligacionAluID, pagban.I_MontoPago + pagban.I_InteresMora, pagban.D_FecPago, pagban.C_CodOperacion, cta.C_NumeroCuenta, ef.T_EntidadDesc
	ORDER BY pagban.D_FecPago
END
GO
/************************************** PROCEDIMIENTOS MATRICULA 2021 **********************************/



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas_X_Cuenta')
	DROP VIEW [dbo].[VW_PagoTasas_X_Cuenta]
GO

CREATE VIEW [dbo].[VW_PagoTasas_X_Cuenta]
AS
SELECT tu.I_TasaUnfvID, ef.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, tu.C_CodTasa, 
	tu.T_ConceptoPagoDesc, tu.M_Monto, cd.C_NumeroCuenta, s.C_CodServicio, s.T_DescServ 
FROM TI_TasaUnfv_CtaDepoServicio t
INNER JOIN TI_CtaDepo_Servicio td  on td.I_CtaDepoServicioID = t.I_CtaDepoServicioID
INNER JOIN TI_TasaUnfv tu on tu.I_TasaUnfvID = t.I_TasaUnfvID
INNER JOIN TC_CuentaDeposito cd on cd.I_CtaDepositoID = td.I_CtaDepositoID
INNER JOIN TC_EntidadFinanciera ef on ef.I_EntidadFinanID = cd.I_EntidadFinanID
INNER JOIN TC_Servicios s on s.I_ServicioID = td.I_ServicioID
WHERE t.B_Habilitado = 1 AND t.B_Eliminado = 0 AND
	td.B_Habilitado = 1 AND td.B_Eliminado = 0 AND
	tu.B_Habilitado = 1 AND tu.B_Eliminado = 0 AND
	s.B_Habilitado = 1 AND s.B_Eliminado = 0
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoTasas')
	DROP VIEW [dbo].[VW_PagoTasas]
GO

CREATE VIEW [dbo].[VW_PagoTasas]
AS
	SELECT pag.I_EntidadFinanID, ef.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, t.C_CodTasa, t.T_ConceptoPagoDesc, 
		tu.T_Clasificador, cl.C_CodClasificador, cl.T_ClasificadorDesc, t.M_Monto, 
		pag.C_CodOperacion, pag.C_CodDepositante, pag.T_NomDepositante, pag.D_FecPago, pr.I_MontoPagado, pag.D_FecCre
	FROM dbo.TR_PagoBanco pag
	INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = pag.I_PagoBancoID
	INNER JOIN dbo.TI_TasaUnfv t ON t.I_TasaUnfvID = pr.I_TasaUnfvID
	INNER JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pag.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = pr.I_CtaDepositoID
	INNER JOIN dbo.TI_TasaUnfv tu ON tu.I_TasaUnfvID = pr.I_TasaUnfvID
	LEFT JOIN dbo.VW_Clasificadores cl ON cl.C_ClasificConceptoCod = tu.T_Clasificador
	WHERE pag.B_Anulado = 0 AND pr.B_Anulado = 0 AND t.B_Eliminado = 0 AND ef.B_Eliminado = 0 AND tu.B_Eliminado = 0
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarEntidadesFinancieras')
	DROP PROCEDURE [dbo].[USP_S_ListarEntidadesFinancieras]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarEntidadesFinancieras]
AS
BEGIN
	SELECT I_EntidadFinanID, T_EntidadDesc, B_Habilitado FROM dbo.TC_EntidadFinanciera
	WHERE B_Eliminado = 0
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarPagoTasas')
	DROP PROCEDURE [dbo].[USP_S_ListarPagoTasas]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarPagoTasas]
@I_EntidadFinanID	INT = NULL,
@C_CodOperacion		VARCHAR(50) = NULL,
@C_CodDepositante	VARCHAR(20) = NULL,
@T_NomDepositante	VARCHAR(200) = NULL,
@D_FechaInicio		DATETIME = NULL,
@D_FechaFin			DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQLString NVARCHAR(2000),
			@SQLParmString NVARCHAR(2000) = '',
			@ParmDefinition NVARCHAR(500)

	SET @SQLString = N'SELECT t.T_EntidadDesc, t.C_CodTasa, t.T_ConceptoPagoDesc, t.M_Monto, 
		t.C_CodOperacion, t.C_CodDepositante, t.T_NomDepositante, t.D_FecPago, I_MontoPagado
	FROM dbo.VW_PagoTasas t '

	IF (@I_EntidadFinanID IS NOT NULL) BEGIN
		SET @SQLParmString = 'WHERE t.I_EntidadFinanID = @I_EntidadFinanID '
	END

	IF (@C_CodOperacion IS NOT NULL) BEGIN
		SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.C_CodOperacion = @C_CodOperacion '
	END

	IF (@C_CodDepositante IS NOT NULL) BEGIN
		SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.C_CodDepositante = @C_CodDepositante '
	END

	IF (@T_NomDepositante IS NOT NULL) BEGIN
		SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 't.T_NomDepositante LIKE ''%''+@T_NomDepositante+''%'' '
	END

	IF (@D_FechaInicio IS NOT NULL) BEGIN
		SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 'DATEDIFF(DAY, t.D_FecPago, @D_FechaInicio) <= 0 '
	END

	IF (@D_FechaFin IS NOT NULL) BEGIN
		SET @SQLParmString = CASE WHEN LEN(@SQLParmString) = 0 THEN 'WHERE ' ELSE @SQLParmString + 'AND ' END + 'DATEDIFF(DAY, t.D_FecPago, @D_FechaFin) >= 0 '
	END

	SET @ParmDefinition = N'@I_EntidadFinanID INT = NULL, @C_CodOperacion VARCHAR(50), @C_CodDepositante VARCHAR(20), @T_NomDepositante VARCHAR(200), 
		@D_FechaInicio DATETIME, @D_FechaFin DATETIME'

	SET @SQLString = @SQLString + @SQLParmString

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@C_CodOperacion = @C_CodOperacion,
		@C_CodDepositante = @C_CodDepositante,
		@T_NomDepositante = @T_NomDepositante,
		@D_FechaInicio = @D_FechaInicio,
		@D_FechaFin = @D_FechaFin
/*
EXEC USP_S_ListarPagoTasas 
	@I_EntidadFinanID = 2,
	@C_CodOperacion = '999586',
	@C_CodDepositante = NULL,
	@T_NomDepositante = NULL,
	@D_FechaInicio = '20210901',
	@D_FechaFin = '20210930'
GO
*/
END
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_PagoBancoObligaciones')
	DROP VIEW [dbo].[VW_PagoBancoObligaciones]
GO

CREATE VIEW [dbo].[VW_PagoBancoObligaciones]
AS
	SELECT b.I_PagoBancoID, e.I_EntidadFinanID, e.T_EntidadDesc, cd.I_CtaDepositoID, cd.C_NumeroCuenta, b.C_CodOperacion, b.C_CodDepositante, m.I_MatAluID, m.C_CodAlu, b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, 
		b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc AS T_Condicion, b.T_Observacion, ISNULL(SUM(p.I_MontoPagado), 0) AS I_MontoProcesado
	FROM TR_PagoBanco b
	LEFT JOIN dbo.TRI_PagoProcesadoUnfv p ON p.I_PagoBancoID = b.I_PagoBancoID AND p.B_Anulado = 0
	LEFT JOIN dbo.TR_ObligacionAluDet d ON d.I_ObligacionAluDetID = p.I_ObligacionAluDetID AND d.B_Habilitado = 1 AND d.B_Eliminado = 0
	LEFT JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = d.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
	LEFT JOIN dbo.VW_MatriculaAlumno m ON m.I_MatAluID = c.I_MatAluID
	INNER JOIN dbo.TC_EntidadFinanciera e ON e.I_EntidadFinanID = b.I_EntidadFinanID
	INNER JOIN dbo.TC_CuentaDeposito cd ON cd.I_CtaDepositoID = b.I_CtaDepositoID
	INNER JOIN dbo.TC_CatalogoOpcion cn ON cn.I_OpcionID = b.I_CondicionPagoID
	WHERE b.I_TipoPagoID = 133
	GROUP BY b.I_PagoBancoID, e.I_EntidadFinanID, cd.I_CtaDepositoID, cd.C_NumeroCuenta, e.T_EntidadDesc, b.C_CodOperacion, b.C_CodDepositante, m.I_MatAluID, m.C_CodAlu, 
		b.T_NomDepositante, m.T_Nombre, m.T_ApePaterno, m.T_ApeMaterno, 
		b.D_FecPago, b.I_MontoPago, b.I_InteresMora, b.T_LugarPago, b.D_FecCre, b.I_CondicionPagoID, cn.T_OpcionDesc, b.T_Observacion
GO





IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ResumenAnualPagoDeObligaciones_X_Dia')
	DROP PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dia]
GO

CREATE PROCEDURE [dbo].[USP_S_ResumenAnualPagoDeObligaciones_X_Dia]
@I_Anio				INT,
@I_EntidadFinanID	INT = NULL,
@I_CtaDepositoID	INT = NULL,
@I_CondicionPagoID	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PagoObligacion INT = 133 
	
	DECLARE @SQLString NVARCHAR(4000),
			@ParmDefinition NVARCHAR(500)

	SET @SQLString = N'
		SELECT
			I_Dia,
			ISNULL([1], 0) AS Enero,
			ISNULL([2], 0) AS Febrero,
			ISNULL([3], 0) AS Marzo,
			ISNULL([4], 0) AS Abril,
			ISNULL([5], 0) AS Mayo,
			ISNULL([6], 0) AS Junio,
			ISNULL([7], 0) AS Julio,
			ISNULL([8], 0) AS Agosto,
			ISNULL([9], 0) AS Setiembre,
			ISNULL([10], 0) AS Octubre,
			ISNULL([11], 0) AS Noviembre,
			ISNULL([12], 0) AS Diciembre
		FROM
		(
		SELECT MONTH(b.D_FecPago) AS I_Month, DAY(b.D_FecPago) AS I_Dia, SUM(b.I_MontoPago + b.I_InteresMora) AS I_MontoTotal
		FROM dbo.TR_PagoBanco b 
		INNER JOIN dbo.TC_CatalogoOpcion cn ON cn.I_OpcionID = b.I_CondicionPagoID
		WHERE b.B_Anulado = 0 AND Year(b.D_FecPago) = @I_Anio AND b.I_TipoPagoID = @I_TipoPagoID ' +
			CASE WHEN @I_EntidadFinanID IS NULL THEN '' ELSE 'AND b.I_EntidadFinanID = @I_EntidadFinanID' END + '
			' + CASE WHEN @I_CtaDepositoID IS NULL THEN '' ELSE 'AND b.I_CtaDepositoID = @I_CtaDepositoID' END + '
			' + CASE WHEN @I_CondicionPagoID IS NULL THEN '' ELSE 'AND b.I_CondicionPagoID = @I_CondicionPagoID' END + '
		GROUP BY MONTH(b.D_FecPago), DAY(b.D_FecPago), MONTH(b.D_FecPago)
		) p
		PIVOT
		(
			SUM(p.I_MontoTotal) 
			FOR p.I_Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
		) AS pvt'

	SET @ParmDefinition = N'@I_TipoPagoID INT, @I_Anio INT, @I_EntidadFinanID INT, @I_CtaDepositoID INT, @I_CondicionPagoID INT'
	
	EXECUTE sp_executesql @SQLString, @ParmDefinition,
		@I_TipoPagoID = @PagoObligacion,
		@I_Anio = @I_Anio,
		@I_EntidadFinanID = @I_EntidadFinanID,
		@I_CtaDepositoID = @I_CtaDepositoID,
		@I_CondicionPagoID = @I_CondicionPagoID
/*
EXEC USP_S_ResumenAnualPagoDeObligaciones_X_Dia 
	@I_Anio = 2021,
	@I_EntidadFinanID = 1,
	@I_CtaDepositoID = NULL,
	@I_CondicionPagoID = NULL
GO
*/
END
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_AsignarPagoDetalleObligacion')
	DROP PROCEDURE [dbo].[USP_AsignarPagoDetalleObligacion]
GO


CREATE PROCEDURE [dbo].[USP_AsignarPagoDetalleObligacion]
@I_FilaActualDet INT,
@I_CantRegistrosDet INT,
@I_SaldoPendiente DECIMAL(15,2),
@I_MontoPago DECIMAL(15,2) OUTPUT,
@B_Pagado BIT OUTPUT,
@I_MontoAPagar DECIMAL(5,2) OUTPUT,
@I_NuevoSaldoPend DECIMAL(15,2) OUTPUT,
@I_PagoDemas DECIMAL(15,2) OUTPUT,
@B_PagoDemas BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF (@I_MontoPago >= @I_SaldoPendiente) BEGIN
		SET @B_Pagado = 1

		SET @I_MontoAPagar = @I_SaldoPendiente

		SET @I_NuevoSaldoPend = 0

		SET @I_PagoDemas = CASE WHEN (@I_FilaActualDet = @I_CantRegistrosDet) THEN @I_MontoPago - @I_SaldoPendiente ELSE 0 END
						
		SET @B_PagoDemas = CASE WHEN (@I_PagoDemas > 0) THEN 1 ELSE 0 END

		SET @I_MontoPago = CASE WHEN (@I_FilaActualDet = @I_CantRegistrosDet) THEN 0 ELSE @I_MontoPago - @I_SaldoPendiente END
	END
	ELSE BEGIN
		SET @B_Pagado = 0

		SET @I_MontoAPagar = @I_MontoPago

		SET @I_NuevoSaldoPend = @I_SaldoPendiente - @I_MontoPago

		SET @I_PagoDemas = 0

		SET @B_PagoDemas = 0

		SET @I_MontoPago = 0
	END
END
GO

