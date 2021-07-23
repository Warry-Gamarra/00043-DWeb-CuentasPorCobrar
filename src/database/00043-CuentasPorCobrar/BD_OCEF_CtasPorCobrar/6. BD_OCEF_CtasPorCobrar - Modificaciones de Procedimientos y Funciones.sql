USE BD_OCEF_CtasPorCobrar
GO

alter table dbo.TR_PagoBanco add T_Observacion varchar(250)
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
			select @I_MatAluID= I_MatAluID, @C_CodRc = C_CodRc, @C_CodAlu = C_CodAlu, @C_EstMat = C_EstMat, @C_CodModIng = C_CodModIng, 
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

					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
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
					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
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

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
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
select * from dbo.TR_ObligacionAluCab --4134
select * from dbo.TR_ObligacionAluDet --43240

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

					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select @I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
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
					insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
					select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
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

							insert dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre)
							select cab.I_ObligacionAluID, p.I_ConcPagID, p.M_Monto, 0, p.D_FecVencto, 1, 0, @I_UsuarioCre, @D_CurrentDate from @Tmp_Procesos p
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
go
--24 seg , 26, 33
*/
END
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ValidarCodOperacion')
	DROP PROCEDURE [dbo].[USP_S_ValidarCodOperacion]
GO



CREATE PROCEDURE [dbo].[USP_S_ValidarCodOperacion]
@C_CodOperacion VARCHAR(50),
--@I_ProcesoID INT,
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
			--INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = p.I_PagoBancoID AND pr.B_Anulado = 0
			--INNER JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = pr.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
			WHERE p.B_Anulado = 0 AND p.I_EntidadFinanID = @I_BcoComercio AND --c.I_MatAluID = @I_MatAluID AND 
				C_CodOperacion = @C_CodOperacion) THEN 0 ELSE 1 END
	END

	IF (@I_EntidadFinanID = @I_BcoCredito) BEGIN
		SET @B_Correct = CASE WHEN EXISTS(SELECT p.I_PagoBancoID FROM dbo.TR_PagoBanco p
			--INNER JOIN dbo.TRI_PagoProcesadoUnfv pr ON pr.I_PagoBancoID = p.I_PagoBancoID AND pr.B_Anulado = 0
			--INNER JOIN dbo.TR_ObligacionAluCab c ON c.I_ObligacionAluID = pr.I_ObligacionAluID AND c.B_Habilitado = 1 AND c.B_Eliminado = 0
			WHERE p.B_Anulado = 0 AND p.I_EntidadFinanID = @I_BcoCredito AND --c.I_MatAluID = @I_MatAluID AND
				DATEDIFF(HOUR, p.D_FecPago, @D_FecPago) = 0 AND C_CodOperacion = @C_CodOperacion) THEN 0 ELSE 1 END
		--SET @B_Correct = 1
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
	I_CtaDepositoID		int
)
GO



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_I_GrabarPagoObligaciones')
	DROP PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
GO

CREATE PROCEDURE [dbo].[USP_I_GrabarPagoObligaciones]
(
	 @Tbl_Pagos	[dbo].[type_dataPago]	READONLY
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
		T_ErrorMessage		varchar(250)
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
		C_Referencia, D_FecPago, D_FecVencto, I_Cantidad, C_Moneda, I_MontoOblig, I_MontoPago, I_InteresMora, T_LugarPago, I_EntidadFinanID, I_CtaDepositoID, B_Pagado)
	SELECT m.I_ProcesoID, m.I_ObligacionAluID, p.C_CodOperacion, p.C_CodAlu, p.T_NomDepositante,
		p.C_Referencia, p.D_FecPago, p.D_FecVencto, p.I_Cantidad, p.C_Moneda, m.I_MontoOblig, p.I_MontoPago, p.I_InteresMora, p.T_LugarPago, p.I_EntidadFinanID, I_CtaDepositoID, m.B_Pagado
	FROM @Tbl_Pagos p
	LEFT JOIN Matriculados m ON m.C_CodAlu = p.C_CodAlu AND m.C_CodRc = p.C_CodRc AND 
		m.I_ProcesoID = p.I_ProcesoID AND DATEDIFF(DAY, m.D_FecVencto, p.D_FecVencto) = 0

	DECLARE @I_FilaActual		int = 1,
			@I_CantRegistros	int = (select count(id) from @Tmp_PagoObligacion),
			@I_ConcPagID		int,
			@I_SaldoPagado		decimal(15,2),
			@I_SaldoPendiente	decimal(15,2),
			@I_SaldoAPagar		decimal(15,2),
			@I_PagoDemas		decimal(15,2),
			@B_PagoDemas		bit,
			@B_Pagado			bit,
			-----------------------------------------------------------
			@I_PagoBancoID		int,
			@I_ProcesoID		int,
			@I_ObligacionAluID	int,
			@C_CodOperacion		varchar(50),
			@C_CodDepositante	varchar(20),
			@T_NomDepositante	varchar(200),
			@C_Referencia		varchar(50),
			@D_FecPago			datetime,
			@D_FecVencto		datetime,
			@I_Cantidad			int,
			@C_Moneda			varchar(3),
			@I_MontoOblig		decimal(15,2),
			@I_MontoPago		decimal(15,2),
			@I_InteresMora		decimal(15,2),
			@T_LugarPago		varchar(250),
			@I_EntidadFinanID	int,
			@I_CtaDepositoID	int,
			@B_ObligPagada		bit,
			@B_ExisteError		bit,
			@B_CodOpeCorrecto	bit
	
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
				@I_MontoOblig = I_MontoOblig,
				@I_MontoPago = I_MontoPago, 
				@I_InteresMora = I_InteresMora,
				@T_LugarPago= T_LugarPago,
				@I_EntidadFinanID = I_EntidadFinanID,
				@I_CtaDepositoID = I_CtaDepositoID,
				@B_ObligPagada = B_Pagado
			FROM @Tmp_PagoObligacion WHERE id = @I_FilaActual

		IF (@I_ObligacionAluID IS NULL) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'No existe obligaciones para este alumno.' WHERE id = @I_FilaActual
		END

		IF (@B_ExisteError = 0) AND (@B_ObligPagada = 1) BEGIN
			SET @B_ExisteError = 1
			UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'Esta obligación ya ha sido pagada con anterioridad.' WHERE id = @I_FilaActual
		END

		--IF (@B_ExisteError = 0) AND NOT (@I_MontoOblig = @I_MontoPago) BEGIN
		--	SET @B_ExisteError = 1
		--	UPDATE @Tmp_PagoObligacion SET B_Success = 0, T_ErrorMessage = 'El monto pagado no coincide con el monto de la obligación generada.' WHERE id = @I_FilaActual
		--END

		IF  (@B_ExisteError = 0) BEGIN
			EXEC USP_S_ValidarCodOperacion @C_CodOperacion, @I_EntidadFinanID, @D_FecPago, @B_CodOpeCorrecto OUTPUT

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

		IF (@B_ExisteError = 0) BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				IF (@I_CtaDepositoID IS NULL) BEGIN
					SET @I_CtaDepositoID = (SELECT cta.I_CtaDepositoID FROM dbo.TI_CtaDepo_Proceso cta
						INNER JOIN dbo.TC_CuentaDeposito c ON c.I_CtaDepositoID = cta.I_CtaDepositoID
						WHERE cta.B_Habilitado = 1 AND cta.B_Eliminado = 0 AND 
							cta.I_ProcesoID = @I_ProcesoID and c.I_EntidadFinanID = @I_EntidadFinanID)
				END

				INSERT dbo.TR_PagoBanco(C_CodOperacion, C_CodDepositante, T_NomDepositante, C_Referencia, D_FecPago, I_Cantidad, 
					C_Moneda, I_MontoPago, T_LugarPago, B_Anulado, I_UsuarioCre, D_FecCre, I_EntidadFinanID)
				VALUES(@C_CodOperacion, @C_CodDepositante, @T_NomDepositante, @C_Referencia, @D_FecPago, @I_Cantidad, 
					@C_Moneda, (@I_MontoPago + @I_InteresMora), @T_LugarPago, 0, @UserID, @D_FecRegistro, @I_EntidadFinanID)

				SET @I_PagoBancoID = SCOPE_IDENTITY()

				SET @I_SaldoPagado = ISNULL((SELECT SUM(pr.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pr
					WHERE pr.B_Anulado = 0 AND pr.I_ObligacionAluID = @I_ObligacionAluID), 0)
	
				SET @I_SaldoPendiente = @I_MontoOblig - @I_SaldoPagado

				--Pago incompleto
				SET @I_SaldoAPagar = @I_SaldoPendiente - @I_MontoPago

				SET @I_SaldoAPagar = CASE WHEN @I_SaldoAPagar > 0 THEN @I_SaldoAPagar ELSE 0 END

				SET @B_Pagado = CASE WHEN @I_SaldoAPagar = 0 THEN 1 ELSE 0 END

				--Pago excedente
				SET @I_PagoDemas = @I_MontoPago - @I_SaldoPendiente
					
				SET @I_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN @I_PagoDemas ELSE 0 END

				SET @B_PagoDemas = CASE WHEN @I_PagoDemas > 0 THEN 1 ELSE 0 END

				INSERT dbo.TRI_PagoProcesadoUnfv(I_PagoBancoID, I_ObligacionAluID, I_MontoPagado, I_SaldoAPagar, I_PagoDemas,
					B_PagoDemas, D_FecCre, I_UsuarioCre, B_Anulado, I_CtaDepositoID)
				VALUES(@I_PagoBancoID, @I_ObligacionAluID, @I_MontoPago, @I_SaldoAPagar, @I_PagoDemas, 
					@B_PagoDemas, @D_FecRegistro, @UserID, 0, @I_CtaDepositoID)


				IF (@B_Pagado = 1)
				BEGIN
					UPDATE dbo.TR_ObligacionAluCab SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
					WHERE I_ObligacionAluID = @I_ObligacionAluID
			
					UPDATE dbo.TR_ObligacionAluDet SET B_Pagado = @B_Pagado, I_UsuarioMod = @UserID, D_FecMod = @D_FecRegistro
					WHERE I_ObligacionAluID = @I_ObligacionAluID
				END

				IF (@I_InteresMora > 0) BEGIN
					SET @I_ConcPagID = (SELECT c.I_ConcPagID FROM dbo.TI_ConceptoPago c WHERE c.B_Eliminado = 0 AND c.I_ProcesoID = @I_ProcesoID AND ISNULL(c.B_Mora, 0) = 1)

					INSERT dbo.TR_ObligacionAluDet(I_ObligacionAluID, I_ConcPagID, I_Monto, B_Pagado, D_FecVencto, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecMod)
					VALUES (@I_ObligacionAluID, @I_ConcPagID, @I_InteresMora, 1, @D_FecVencto, 1, 0, @UserID, @D_FecRegistro)
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





IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_DetalleObligaciones')
	DROP VIEW [dbo].[VW_DetalleObligaciones]
GO


CREATE VIEW [dbo].[VW_DetalleObligaciones]
AS
SELECT 
	cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, 
	pro.T_ProcesoDesc, ISNULL(cp.T_ConceptoPagoDesc, con.T_ConceptoDesc) AS T_ConceptoDesc, cat.T_CatPagoDesc, det.I_Monto, det.B_Pagado, cab.D_FecVencto, pro.I_Prioridad,
	cab.C_Moneda, cp.I_TipoObligacion, cat.I_Nivel, niv.T_OpcionCod AS C_Nivel, niv.T_OpcionDesc AS T_Nivel, cat.I_TipoAlumno, tipal.T_OpcionCod AS C_TipoAlumno, tipal.T_OpcionDesc AS T_TipoAlumno
FROM dbo.VW_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0 
INNER JOIN dbo.TR_ObligacionAluDet det ON det.I_ObligacionAluID = cab.I_ObligacionAluID AND det.B_Eliminado = 0
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
	cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.C_CodEsc, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,
	niv.T_OpcionCod AS C_Nivel, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,
	cab.B_Pagado, cab.D_FecCre,	ISNULL(srv.C_CodServicio, '') AS C_CodServicio, mat.T_FacDesc, mat.T_DenomProg,
	ISNULL((SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro where pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual
	--pagban.C_CodOperacion, pagban.D_FecPago, pagban.T_LugarPago,
	--ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc,
FROM dbo.VW_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
--LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0
--LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
--LEFT JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
--LEFT JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
GO



IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'VW_CuotasPago_General')
	DROP VIEW [dbo].[VW_CuotasPago_General]
GO

CREATE VIEW [dbo].[VW_CuotasPago_General]
AS
SELECT 
	ROW_NUMBER() OVER(PARTITION BY mat.C_CodAlu ORDER BY mat.C_CodAlu, pro.I_Anio, pro.I_Periodo, pro.I_Prioridad, cab.D_FecVencto) AS I_NroOrden,
	cab.I_ObligacionAluID, pro.I_ProcesoID, pro.N_CodBanco, mat.C_CodAlu, mat.C_RcCod, mat.C_CodFac, mat.C_CodEsc, mat.T_Nombre, mat.T_ApePaterno, mat.T_ApeMaterno, mat.I_Anio, mat.I_Periodo, 
	per.T_OpcionCod AS C_Periodo, per.T_OpcionDesc AS T_Periodo, pro.T_ProcesoDesc, cab.D_FecVencto, pro.I_Prioridad, cab.C_Moneda,
	niv.T_OpcionCod AS C_Nivel, tipal.T_OpcionCod AS C_TipoAlumno, cab.I_MontoOblig,
	cab.B_Pagado, cab.D_FecCre, ISNULL(srv.C_CodServicio, '') AS C_CodServicio, mat.T_FacDesc, mat.T_DenomProg,
	ISNULL((SELECT SUM(pagpro.I_MontoPagado) FROM dbo.TRI_PagoProcesadoUnfv pagpro where pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0), 0) AS I_MontoPagadoActual
	--pagban.C_CodOperacion, pagban.D_FecPago, pagban.T_LugarPago
	--ISNULL(cta.C_NumeroCuenta, '') AS C_NumeroCuenta, ISNULL(ef.T_EntidadDesc, '') AS T_EntidadDesc,
FROM dbo.VW_MatriculaAlumno mat
INNER JOIN dbo.TR_ObligacionAluCab cab ON cab.I_MatAluID = mat.I_MatAluID AND cab.B_Eliminado = 0
INNER JOIN dbo.TC_Proceso pro ON pro.I_ProcesoID = cab.I_ProcesoID AND pro.B_Eliminado = 0
INNER JOIN dbo.TC_CategoriaPago cat ON cat.I_CatPagoID = pro.I_CatPagoID AND cat.B_Eliminado = 0
LEFT JOIN dbo.TC_Servicios srv ON srv.I_ServicioID = cat.I_ServicioID AND srv.B_Eliminado = 0
INNER JOIN dbo.TC_CatalogoOpcion per ON per.I_ParametroID = 5 AND per.I_OpcionID = mat.I_Periodo
INNER JOIN dbo.TC_CatalogoOpcion niv ON niv.I_ParametroID = 2 AND niv.I_OpcionID = cat.I_Nivel
INNER JOIN dbo.TC_CatalogoOpcion tipal ON tipal.I_ParametroID = 1 AND tipal.I_OpcionID = cat.I_TipoAlumno
--LEFT JOIN dbo.TRI_PagoProcesadoUnfv pagpro ON pagpro.I_ObligacionAluID = cab.I_ObligacionAluID AND pagpro.B_Anulado = 0
--LEFT JOIN dbo.TR_PagoBanco pagban ON pagban.I_PagoBancoID = pagpro.I_PagoBancoID AND pagban.B_Anulado = 0
--LEFT JOIN dbo.TC_CuentaDeposito cta ON cta.I_CtaDepositoID = pagpro.I_CtaDepositoID
--LEFT JOIN dbo.TC_EntidadFinanciera ef ON ef.I_EntidadFinanID = pagban.I_EntidadFinanID
GO




IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'USP_S_ListarCuotasPagos_X_Periodo')
	DROP PROCEDURE [dbo].[USP_S_ListarCuotasPagos_X_Periodo]
GO

CREATE PROCEDURE [dbo].[USP_S_ListarCuotasPagos_X_Periodo]
@C_CodAlu VARCHAR(10),
@I_Anio INT,
@I_PeriodoID INT
AS
BEGIN
	SET NOCOUNT ON
	SELECT 
		vw.C_CodAlu, vw.T_ApePaterno, vw.T_ApeMaterno, vw.T_Nombre, vw.C_RcCod, vw.T_DenomProg, 
		vw.T_ProcesoDesc, vw.I_Anio, vw.T_Periodo, vw.D_FecVencto, vw.B_Pagado, 
		vw.I_MontoOblig, 
		null AS D_FecPago, 
		'' as C_CodOperacion, 
		'' as C_NumeroCuenta, 
		'' as T_EntidadDesc 
		--vw.D_FecPago, vw.C_CodOperacion, vw.C_NumeroCuenta, vw.T_EntidadDesc 
	FROM dbo.VW_CuotasPago_General vw
	WHERE vw.C_CodAlu = @C_CodAlu AND vw.I_Anio = @I_Anio AND vw.I_Periodo = @I_PeriodoID AND vw.I_Prioridad = 1
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


select * from dbo.TRI_PagoProcesadoUnfv where I_MontoPagado = 40

