using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ReporteServiceFacade : IReporteServiceFacade
    {
        IReporteUnfvService reporteService;
        IEntidadRecaudadora entidadRecaudadoraService;
        ICuentaDeposito cuentaDeposito;

        public ReporteServiceFacade()
        {
            entidadRecaudadoraService = new EntidadRecaudadora();
            cuentaDeposito = new CuentaDeposito();
        }

        public ReportePagosUnfvGeneralViewModel ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio)
        {
            GetReporteService(tipoEstudio);

            var pagos = reporteService.ReporteGeneral(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReportePagosUnfvGeneralViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos de ***",
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReportePagosUnfvPorConceptoViewModel ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio)
        {
            GetReporteService(tipoEstudio);

            var pagos = reporteService.ReportePorConceptos(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReportePagosUnfvPorConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pago por Conceptos",
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReportePorDependenciaYConceptoViewModel ReportePorDependenciaYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio)
        {
            GetReporteService(tipoEstudio);

            var pagos = reporteService.ReportePorDependenciaYConcepto(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReportePorDependenciaYConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos por ***",//Grado o Facultad
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReporteConceptosPorDependenciaViewModel ReporteConceptosPorDependencia(string codDep, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito, TipoEstudio tipoEstudio)
        {
            GetReporteService(tipoEstudio);

            var pagos = reporteService.ReporteConceptosPorDependencia(codDep, fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReporteConceptosPorDependenciaViewModel(pagos)
            {
                Dependencia = pagos.Count() > 0 ? pagos.FirstOrDefault().T_DependenciaDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pago de Conceptos por ***",//Grado o Facultad
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReporteResumenAnualPagoObligaciones_X_Clasificadores ResumenAnualPagoOblig_X_Clasificadores(int anio, TipoEstudio tipoEstudio, int? entidadFinanID, int? ctaDepositoID)
        {
            GetReporteService(tipoEstudio);

            var lista = reporteService.ResumenAnualPagoOblig_X_Clasificadores(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Clasificadores(anio, tipoEstudio, nombreEntidadFinanc, null, lista);

            return result;
        }

        public ReporteResumenAnualPagoObligaciones_X_Dependencias ResumenAnualPagoOblig_X_Dependencias(int anio, TipoEstudio tipoEstudio, int? entidadFinanID, int? ctaDepositoID)
        {
            GetReporteService(tipoEstudio);

            var lista = reporteService.ResumenAnualPagoOblig_X_Dependencia(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Dependencias(anio, tipoEstudio, nombreEntidadFinanc, null, lista);

            return result;
        }

        public IEnumerable<EstadoObligacionViewModel> EstadoObligacionAlumnos(ConsultaObligacionEstudianteViewModel parametro)
        {
            GetReporteService(parametro.tipoEstudio);

            var lista = reporteService.EstadoObligacionAlumnos(parametro.anio.Value, parametro.periodo, parametro.codFac, parametro.codEsc, parametro.codRc, parametro.esIngresante, parametro.estaPagado, parametro.obligacionGenerada,
                parametro.fechaInicio, parametro.fechaFin, parametro.codAlumno, parametro.nomAlumno, parametro.apePaternoAlumno, parametro.apeMaternoAlumno, parametro.dependencia);

            var result = lista.Select(x => Mapper.EstadoObligacionDTO_To_EstadoObligacionViewModel(x));

            return result;
        }

        private void GetReporteService(TipoEstudio tipoEstudio)
        {
            if (reporteService == null)
            {
                switch (tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        reporteService = new ReportePregradoService();
                        break;

                    case TipoEstudio.Posgrado:
                        reporteService = new ReportePosgradoService();
                        break;

                    case TipoEstudio.Segunda_Especialidad:
                        reporteService = new ReporteSegundaEspecialidadService();
                        break;

                    case TipoEstudio.Residentado:
                        reporteService = new ReporteResidentadoService();
                        break;

                    default:
                        throw new NotImplementedException();
                }
            }
        }
    }
}