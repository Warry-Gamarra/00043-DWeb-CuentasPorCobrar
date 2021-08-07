using Data.Procedures;
using Data.Tables;
using Data.Types;
using Data.Views;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public static class Mapper
    {
        public static MatriculaObsEntity MatriculaEntity_To_MatriculaObsEntity(MatriculaEntity matricula, bool B_Success, string T_Message)
        {
            var dataMatriculaObs = new MatriculaObsEntity()
            {
                C_CodRC = matricula.C_CodRC,
                C_CodAlu = matricula.C_CodAlu,
                I_Anio = matricula.I_Anio,
                C_Periodo = matricula.C_Periodo,
                C_EstMat = matricula.C_EstMat,
                C_Ciclo = matricula.C_Ciclo,
                B_Ingresante = matricula.B_Ingresante,
                I_CredDesaprob = matricula.I_CredDesaprob,
                B_Success = B_Success,
                T_Message = T_Message
            };

            return dataMatriculaObs;
        }

        public static DataTable MatriculaEntity_To_DataTable(List<MatriculaEntity> dataMatriculas)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_CodRC");
            dataTable.Columns.Add("C_CodAlu");
            dataTable.Columns.Add("I_Anio");
            dataTable.Columns.Add("C_Periodo");
            dataTable.Columns.Add("C_EstMat");
            dataTable.Columns.Add("C_Ciclo");
            dataTable.Columns.Add("B_Ingresante");
            dataTable.Columns.Add("I_CredDesaprob");

            dataMatriculas.ForEach(x => dataTable.Rows.Add(
                x.C_CodRC,
                x.C_CodAlu,
                x.I_Anio,
                x.C_Periodo,
                x.C_EstMat,
                x.C_Ciclo,
                x.B_Ingresante,
                x.I_CredDesaprob
            ));

            return dataTable;
        }

        public static MatriculaObsEntity DataMatriculaResult_To_MatriculaObsEntity(DataMatriculaResult result)
        {
            var matriculaObs = new MatriculaObsEntity()
            {
                C_CodRC = result.C_CodRC,
                C_CodAlu = result.C_CodAlu,
                I_Anio = result.I_Anio,
                C_Periodo = result.C_Periodo,
                C_EstMat = result.C_EstMat,
                C_Ciclo = result.C_Ciclo,
                B_Ingresante = result.B_Ingresante,
                I_CredDesaprob = result.I_CredDesaprob,
                B_Success = result.B_Success,
                T_Message = result.T_Message
            };

            return matriculaObs;
        }

        public static MatriculaDTO MatriculaDTO_To_VW_MatriculaAlumno(VW_MatriculaAlumno matriculaAlumno)
        {
            var matriculaDTO = new MatriculaDTO()
            {
                I_MatAluID = matriculaAlumno.I_MatAluID,
                C_CodAlu = matriculaAlumno.C_CodAlu,
                C_RcCod = matriculaAlumno.C_RcCod,
                T_Nombre = matriculaAlumno.T_Nombre,
                T_ApePaterno = matriculaAlumno.T_ApePaterno,
                T_ApeMaterno = matriculaAlumno.T_ApeMaterno,
                N_Grado = matriculaAlumno.N_Grado,
                I_Anio = matriculaAlumno.I_Anio,
                I_Periodo = matriculaAlumno.I_Periodo,
                C_CodFac = matriculaAlumno.C_CodFac,
                T_FacDesc = matriculaAlumno.T_FacDesc,
                C_CodEsc = matriculaAlumno.C_CodEsc,
                T_EscDesc = matriculaAlumno.T_EscDesc,
                C_EstMat = matriculaAlumno.C_EstMat,
                C_Ciclo = matriculaAlumno.C_Ciclo,
                B_Ingresante = matriculaAlumno.B_Ingresante,
                I_CredDesaprob = matriculaAlumno.I_CredDesaprob,
                B_Habilitado = matriculaAlumno.B_Habilitado,
                C_Periodo = matriculaAlumno.C_Periodo,
                T_Periodo = matriculaAlumno.T_Periodo,
                T_DenomProg = matriculaAlumno.T_DenomProg,
                C_CodModIng = matriculaAlumno.C_CodModIng,
                T_ModIngDesc = matriculaAlumno.T_ModIngDesc,
                B_TieneMultaPorNoVotar = matriculaAlumno.B_TieneMultaPorNoVotar
            };

            return matriculaDTO;
        }

        public static ObligacionDetalleDTO VW_DetalleObligaciones_To_ObligacionDetalleDTO(VW_DetalleObligaciones detalleObligaciones)
        {
            var obligacionDetalleDTO = new ObligacionDetalleDTO()
            {
                I_ObligacionAluID = detalleObligaciones.I_ObligacionAluID,
                I_ProcesoID = detalleObligaciones.I_ProcesoID,
                N_CodBanco = detalleObligaciones.N_CodBanco ?? "",
                C_CodAlu = detalleObligaciones.C_CodAlu,
                C_CodRc = detalleObligaciones.C_RcCod,
                C_CodFac = detalleObligaciones.C_CodFac,
                T_Nombre = detalleObligaciones.T_Nombre,
                T_ApePaterno = detalleObligaciones.T_ApePaterno,
                T_ApeMaterno = detalleObligaciones.T_ApeMaterno ?? "",
                I_Anio = detalleObligaciones.I_Anio,
                I_Periodo = detalleObligaciones.I_Periodo,
                C_Periodo = detalleObligaciones.C_Periodo,
                T_Periodo = detalleObligaciones.T_Periodo,
                T_ProcesoDesc = detalleObligaciones.T_ProcesoDesc,
                T_ConceptoDesc = detalleObligaciones.T_ConceptoDesc,
                T_CatPagoDesc = detalleObligaciones.T_CatPagoDesc,
                I_Monto = detalleObligaciones.I_Monto,
                B_Pagado = detalleObligaciones.B_Pagado,
                D_FecVencto = detalleObligaciones.D_FecVencto,
                I_Prioridad = detalleObligaciones.I_Prioridad,
                C_Moneda = detalleObligaciones.C_Moneda,
                I_TipoObligacion = detalleObligaciones.I_TipoObligacion,
                I_Nivel = detalleObligaciones.I_Nivel,
                C_Nivel = detalleObligaciones.C_Nivel,
                T_Nivel = detalleObligaciones.T_Nivel,
                I_TipoAlumno = detalleObligaciones.I_TipoAlumno,
                C_TipoAlumno = detalleObligaciones.C_TipoAlumno,
                T_TipoAlumno = detalleObligaciones.T_TipoAlumno
            };

            return obligacionDetalleDTO;
        }

        public static CuotaPagoDTO VW_CuotaPago_To_CuotaPagoDTO(VW_CuotasPago cuotaPago)
        {
            var cuotaPagoDTO = new CuotaPagoDTO()
            {
                I_NroOrden = cuotaPago.I_NroOrden,
                I_ObligacionAluID = cuotaPago.I_ObligacionAluID,
                I_ProcesoID = cuotaPago.I_ProcesoID,
                N_CodBanco = cuotaPago.N_CodBanco ?? "",
                C_CodAlu = cuotaPago.C_CodAlu,
                C_CodRc = cuotaPago.C_RcCod,
                C_CodFac = cuotaPago.C_CodFac,
                C_CodEsc = cuotaPago.C_CodEsc,
                T_Nombre = cuotaPago.T_Nombre,
                T_ApePaterno = cuotaPago.T_ApePaterno,
                T_ApeMaterno = cuotaPago.T_ApeMaterno ?? "",
                I_Anio = cuotaPago.I_Anio,
                I_Periodo = cuotaPago.I_Periodo,
                C_Periodo = cuotaPago.C_Periodo,
                T_Periodo = cuotaPago.T_Periodo,
                T_ProcesoDesc = cuotaPago.T_ProcesoDesc,
                D_FecVencto = cuotaPago.D_FecVencto,
                I_Prioridad = cuotaPago.I_Prioridad,
                C_Moneda = cuotaPago.C_Moneda,
                C_Nivel = cuotaPago.C_Nivel,
                C_TipoAlumno = cuotaPago.C_TipoAlumno,
                I_MontoOblig = cuotaPago.I_MontoOblig,
                I_MontoPagadoActual = cuotaPago.I_MontoPagadoActual,
                B_Pagado = cuotaPago.B_Pagado,
                D_FecCre = cuotaPago.D_FecCre,
                C_CodServicio = cuotaPago.C_CodServicio,
                T_FacDesc = cuotaPago.T_FacDesc,
                T_DenomProg = cuotaPago.T_DenomProg
            };

            return cuotaPagoDTO;
        }

        public static CatalogoOpcionEntity TC_CatalogoOpcion_To_CatalogoOpcionEntity(TC_CatalogoOpcion catalogoOpcion)
        {
            var catalogoOpcionEntity = new CatalogoOpcionEntity()
            {
                I_OpcionID = catalogoOpcion.I_OpcionID,
                T_OpcionCod = catalogoOpcion.T_OpcionCod,
                T_OpcionDesc = catalogoOpcion.T_OpcionDesc,
                B_Habilitado = catalogoOpcion.B_Habilitado
            };

            return catalogoOpcionEntity;
        }

        public static Proceso USP_S_Procesos_To_Proceso(USP_S_Procesos uspProceso)
        {
            var proceso = new Proceso()
            {
                I_ProcesoID = uspProceso.I_ProcesoID,
                I_CatPagoID = uspProceso.I_CatPagoID,
                T_CatPagoDesc = uspProceso.T_CatPagoDesc,
                C_PeriodoCod = uspProceso.C_PeriodoCod,
                T_PeriodoDesc = uspProceso.T_PeriodoDesc,
                T_ProcesoDesc = uspProceso.T_ProcesoDesc,
                I_Periodo = uspProceso.I_Periodo,
                I_Anio = uspProceso.I_Anio,
                D_FecVencto = uspProceso.D_FecVencto,
                I_Prioridad = uspProceso.I_Prioridad,
                N_CodBanco = uspProceso.N_CodBanco,
                B_Obligacion = uspProceso.B_Obligacion,
                I_Nivel = uspProceso.I_Nivel,
                C_Nivel = uspProceso.C_Nivel,
                I_TipoAlumno = uspProceso.I_TipoAlumno,
                T_TipoAlumno = uspProceso.T_TipoAlumno,
                C_TipoAlumno = uspProceso.C_TipoAlumno
            };

            return proceso;
        }

        public static DataTable PagoObligacionEntity_To_DataTable(List<PagoObligacionEntity> dataPagoObligaciones)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_CodOperacion");
            dataTable.Columns.Add("T_NomDepositante");
            dataTable.Columns.Add("C_Referencia");
            dataTable.Columns.Add("D_FecPago").DataType = typeof(DateTime);
            dataTable.Columns.Add("I_Cantidad");
            dataTable.Columns.Add("C_Moneda");
            dataTable.Columns.Add("I_MontoPago");
            dataTable.Columns.Add("I_InteresMora");
            dataTable.Columns.Add("T_LugarPago");
            dataTable.Columns.Add("C_CodAlu");
            dataTable.Columns.Add("C_CodRc");
            dataTable.Columns.Add("I_ProcesoID");
            dataTable.Columns.Add("D_FecVencto").DataType = typeof(DateTime);
            dataTable.Columns.Add("I_EntidadFinanID");
            dataTable.Columns.Add("I_CtaDepositoID").AllowDBNull = true;
            dataTable.Columns.Add("T_InformacionAdicional").AllowDBNull = true;

            dataPagoObligaciones.ForEach(x => dataTable.Rows.Add(
                x.C_CodOperacion,
                x.T_NomDepositante,
                x.C_Referencia,
                x.D_FecPago,
                x.I_Cantidad,
                x.C_Moneda,
                x.I_MontoPago,
                x.I_InteresMora,
                x.T_LugarPago,
                x.C_CodAlu,
                x.C_CodRc,
                x.I_ProcesoID,
                x.D_FecVencto,
                x.I_EntidadFinanID,
                x.I_CtaDepositoID,
                x.T_InformacionAdicional
            ));

            return dataTable;
        }

        public static CtaDepoProceso VW_CtaDepositoProceso_To_CtaDepoProceso(VW_CtaDepositoProceso vwCtaDepositoProceso)
        {
            var ctaDepoProceso = new CtaDepoProceso()
            {
                I_CtaDepoProID = vwCtaDepositoProceso.I_CtaDepoProID,
                I_EntidadFinanID = vwCtaDepositoProceso.I_EntidadFinanID,
                T_EntidadDesc = vwCtaDepositoProceso.T_EntidadDesc,
                I_CtaDepositoID = vwCtaDepositoProceso.I_CtaDepositoID,
                C_NumeroCuenta = vwCtaDepositoProceso.C_NumeroCuenta,
                T_DescCuenta = vwCtaDepositoProceso.T_DescCuenta,
                I_ProcesoID = vwCtaDepositoProceso.I_ProcesoID,
                T_ProcesoDesc = vwCtaDepositoProceso.T_ProcesoDesc,
                I_Prioridad = vwCtaDepositoProceso.I_Prioridad,
                I_Anio = vwCtaDepositoProceso.I_Anio,
                I_Periodo = vwCtaDepositoProceso.I_Periodo,
                C_Periodo = vwCtaDepositoProceso.C_Periodo,
                T_PeriodoDesc = vwCtaDepositoProceso.T_PeriodoDesc,
                I_Nivel = vwCtaDepositoProceso.I_Nivel,
                C_Nivel = vwCtaDepositoProceso.C_Nivel,
                B_Habilitado = vwCtaDepositoProceso.B_Habilitado
            };

            return ctaDepoProceso;
        }

        public static MultaNoVotarSinRegistrarEntity AlumnoMultaNoVotarEntity_To_MultaNoVotarSinRegistrarEntity(AlumnoMultaNoVotarEntity alumnoMultaNoVotarEntity, bool B_Success, string T_Message)
        {
            var multaNoVotarSinRegistrar = new MultaNoVotarSinRegistrarEntity()
            {
                C_CodRC = alumnoMultaNoVotarEntity.C_CodRC,
                C_CodAlu = alumnoMultaNoVotarEntity.C_CodAlu,
                I_Anio = alumnoMultaNoVotarEntity.I_Anio,
                C_Periodo = alumnoMultaNoVotarEntity.C_Periodo,
                B_Success = B_Success,
                T_Message = T_Message
            };

            return multaNoVotarSinRegistrar;
        }

        public static DataTable AlumnoMultaNoVotarEntity_To_DataTable(List<AlumnoMultaNoVotarEntity> alumnosMultaNoVotarEntity)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("I_Anio");
            dataTable.Columns.Add("C_Periodo");
            dataTable.Columns.Add("C_CodRC");
            dataTable.Columns.Add("C_CodAlu");

            alumnosMultaNoVotarEntity.ForEach(x => dataTable.Rows.Add(
                x.I_Anio,
                x.C_Periodo,
                x.C_CodAlu,
                x.C_CodRC
            ));

            return dataTable;
        }

        public static MultaNoVotarSinRegistrarEntity MultaNoVotarResult_To_MultaNoVotarSinRegistrarEntity(MultaNoVotarResult result)
        {
            var multaNoVotarSinRegistrar = new MultaNoVotarSinRegistrarEntity()
            {
                I_Anio = result.I_Anio,
                C_Periodo = result.C_Periodo,
                C_CodAlu = result.C_CodAlu,
                C_CodRC = result.C_CodRC,
                B_Success = result.B_Success,
                T_Message = result.T_Message
            };

            return multaNoVotarSinRegistrar;
        }

        public static PagoPregradoPorFacultadDTO USP_S_ReportePagoObligacionesPregrado_To_PagoPregradoPorFacultadDTO(USP_S_ReportePagoObligacionesPregrado sp)
        {
            var result = new PagoPregradoPorFacultadDTO()
            {
                T_FacDesc = sp.T_FacDesc,
                C_CodFac = sp.C_CodFac,
                I_MontoTotal = sp.I_MontoTotal
            };

            return result;
        }

        public static PagoPregradoPorConceptoDTO USP_S_ReportePagoObligacionesPregrado_To_PagoPregradoPorConceptoDTO(USP_S_ReportePagoObligacionesPregrado sp)
        {
            var result = new PagoPregradoPorConceptoDTO()
            {
                I_ConceptoID = sp.I_ConceptoID,
                C_CodClasificador = sp.C_CodClasificador,
                T_ConceptoPagoDesc = sp.T_ConceptoPagoDesc,
                I_MontoTotal = sp.I_MontoTotal
            };

            return result;
        }

        public static ConceptoPregradoPorFacultadDTO USP_S_ReportePagoObligacionesPregrado_To_ConceptoPregradoPorFacultadDTO(USP_S_ReportePagoObligacionesPregrado sp)
        {
            var result = new ConceptoPregradoPorFacultadDTO()
            {
                T_FacDesc = sp.T_FacDesc,
                C_CodFac = sp.C_CodFac,
                I_ConceptoID = sp.I_ConceptoID,
                C_CodClasificador = sp.C_CodClasificador,
                T_ConceptoPagoDesc = sp.T_ConceptoPagoDesc,
                I_Cantidad = sp.I_Cantidad,
                I_MontoTotal = sp.I_MontoTotal
            };

            return result;
        }

        public static TasaDTO VW_Tasas_To_TasaDTO(VW_Tasas tasa)
        {
            var result = new TasaDTO()
            {
                I_TasaUnfvID = tasa.I_TasaUnfvID,
                C_CodTasa = tasa.C_CodTasa,
                T_ConceptoPagoDesc = tasa.T_ConceptoPagoDesc,
                I_MontoTasa = tasa.I_MontoTasa,
                T_clasificador = tasa.T_clasificador,
                B_Habilitado = tasa.B_Habilitado
            };

            return result;
        }

        public static ObligacionAluCabEntity TR_ObligacionAluCab_To_ObligacionAluCabEntity(TR_ObligacionAluCab obligacionAluCab)
        {
            var result = new ObligacionAluCabEntity()
            {
                I_ObligacionAluID = obligacionAluCab.I_ObligacionAluID,
                I_ProcesoID = obligacionAluCab.I_ProcesoID,
                I_MatAluID = obligacionAluCab.I_MatAluID,
                C_Moneda = obligacionAluCab.C_Moneda,
                I_MontoOblig = obligacionAluCab.I_MontoOblig,
                D_FecVencto = obligacionAluCab.D_FecVencto,
                B_Pagado = obligacionAluCab.B_Pagado,
                B_Habilitado = obligacionAluCab.B_Habilitado,
                B_Eliminado = obligacionAluCab.B_Eliminado,
                I_UsuarioCre = obligacionAluCab.I_UsuarioCre,
                D_FecCre = obligacionAluCab.D_FecCre,
                I_UsuarioMod = obligacionAluCab.I_UsuarioMod,
                D_FecMod = obligacionAluCab.D_FecMod
            };

            return result;
        }

        public static PagoPosgradoPorGradodDTO USP_S_ReportePagoObligacionesPosgrado_To_PagoPosgradoPorGradodDTO(USP_S_ReportePagoObligacionesPosgrado sp)
        {
            var result = new PagoPosgradoPorGradodDTO()
            {
                T_EscDesc = sp.T_EscDesc,
                C_CodEsc = sp.C_CodEsc,
                I_MontoTotal = sp.I_MontoTotal
            };

            return result;
        }

        public static PagoPosgradoPorConceptoDTO USP_S_ReportePagoObligacionesPosgrado_To_PagoPosgradoPorConceptoDTO(USP_S_ReportePagoObligacionesPosgrado sp)
        {
            var result = new PagoPosgradoPorConceptoDTO()
            {
                I_ConceptoID = sp.I_ConceptoID,
                C_CodClasificador = sp.C_CodClasificador,
                T_ConceptoPagoDesc = sp.T_ConceptoPagoDesc,
                I_MontoTotal = sp.I_MontoTotal
            };

            return result;
        }

        public static ConceptoPosgradoPorGradoDTO USP_S_ReportePagoObligacionesPosgrado_To_ConceptoPosgradoPorGradoDTO(USP_S_ReportePagoObligacionesPosgrado sp)
        {
            var result = new ConceptoPosgradoPorGradoDTO()
            {
                T_EscDesc = sp.T_EscDesc,
                C_CodEsc = sp.C_CodEsc,
                I_ConceptoID = sp.I_ConceptoID,
                C_CodClasificador = sp.C_CodClasificador,
                T_ConceptoPagoDesc = sp.T_ConceptoPagoDesc,
                I_Cantidad = sp.I_Cantidad,
                I_MontoTotal = sp.I_MontoTotal
            };

            return result;
        }

        public static ArchivoImportadoDTO TR_ImportacionArchivo_To_ArchivoImportadoDTO(TR_ImportacionArchivo archivoImpportado)
        {
            var result = new ArchivoImportadoDTO()
            {
                I_ImportacionID = archivoImpportado.I_ImportacionID,
                T_NomArchivo = archivoImpportado.T_NomArchivo,
                T_UrlArchivo = archivoImpportado.T_UrlArchivo,
                I_CantFilas = archivoImpportado.I_CantFilas,
                I_EntidadID = archivoImpportado.I_EntidadID,
                I_TipoArchivo = archivoImpportado.I_TipoArchivo,
                B_Eliminado = archivoImpportado.B_Eliminado,
                I_UsuarioCre = archivoImpportado.I_UsuarioCre,
                D_FecCre = archivoImpportado.D_FecCre,
                I_UsuarioMod = archivoImpportado.I_UsuarioMod,
                D_FecMod = archivoImpportado.D_FecMod,
                UserName = archivoImpportado.UserName,
                T_EntidadDesc = archivoImpportado.T_EntidadDesc
            };

            return result;
        }

        public static ResumenAnualPagoDeObligaciones_X_ClasificadorDTO USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores_To_ResumenAnualPagoDeObligaciones_X_ClasificadorDTO(USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores sp)
        {
            var result = new ResumenAnualPagoDeObligaciones_X_ClasificadorDTO()
            {
                C_CodClasificador = sp.C_CodClasificador,
                T_ClasificadorDesc = sp.T_ClasificadorDesc,
                Enero = sp.Enero,
                Febrero = sp.Febrero,
                Marzo = sp.Marzo,
                Abril = sp.Abril,
                Mayo = sp.Mayo,
                Junio = sp.Junio,
                Julio = sp.Julio,
                Agosto = sp.Agosto,
                Setiembre = sp.Setiembre,
                Octubre = sp.Octubre,
                Noviembre = sp.Noviembre,
                Diciembre = sp.Diciembre
            };

            return result;
        }

        public static ResumenAnualPagoDeObligaciones_X_DependenciaDTO USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia_To_ResumenAnualPagoDeObligaciones_X_DependenciaDTO(USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia sp)
        {
            var result = new ResumenAnualPagoDeObligaciones_X_DependenciaDTO()
            {
                C_CodDependencia = sp.C_CodDependencia,
                T_Dependencia = sp.T_Dependencia,
                Enero = sp.Enero,
                Febrero = sp.Febrero,
                Marzo = sp.Marzo,
                Abril = sp.Abril,
                Mayo = sp.Mayo,
                Junio = sp.Junio,
                Julio = sp.Julio,
                Agosto = sp.Agosto,
                Setiembre = sp.Setiembre,
                Octubre = sp.Octubre,
                Noviembre = sp.Noviembre,
                Diciembre = sp.Diciembre
            };

            return result;
        }

        public static EstadoObligacionDTO USP_S_ListadoEstadoObligaciones_To_EstadoObligacionDTO(USP_S_ListadoEstadoObligaciones sp)
        {
            var result = new EstadoObligacionDTO()
            {
                I_MatAluID = sp.I_MatAluID,
                I_ObligacionAluID = sp.I_ObligacionAluID,
                C_CodAlu = sp.C_CodAlu,
                C_RcCod = sp.C_RcCod,
                T_Nombre = sp.T_Nombre,
                T_ApePaterno = sp.T_ApePaterno,
                T_ApeMaterno = sp.T_ApeMaterno,
                N_Grado = sp.N_Grado,
                T_FacDesc = sp.T_FacDesc,
                T_EscDesc = sp.T_EscDesc,
                T_DenomProg = sp.T_DenomProg,
                B_Ingresante = sp.B_Ingresante,
                I_CredDesaprob = sp.I_CredDesaprob,
                I_Anio = sp.I_Anio,
                T_Periodo = sp.T_Periodo,
                T_ProcesoDesc = sp.T_ProcesoDesc,
                I_MontoOblig = sp.I_MontoOblig,
                D_FecVencto = sp.D_FecVencto,
                B_Pagado = sp.B_Pagado,
                I_MontoPagadoActual = sp.I_MontoPagadoActual
            };

            return result;
        }
    }
}
