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
    public class ReportePregradoServiceFacade : IReporteServiceFacade
    {
        IReportePregradoService reporteService;
        IEntidadRecaudadora entidadRecaudadoraService;
        ICuentaDeposito cuentaDeposito;

        public ReportePregradoServiceFacade()
        {
            reporteService = new ReportePregradoService();
            entidadRecaudadoraService = new EntidadRecaudadora();
            cuentaDeposito = new CuentaDeposito();
        }

        public ReportePagosPregradoGeneralViewModel ReporteGeneral(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReporteGeneral(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReportePagosPregradoGeneralViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos de Pregrado",
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReportePagosPregradoPorConceptoViewModel ReportePorConceptos(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReportePorConceptos(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReportePagosPregradoPorConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pago por Conceptos",
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReportePorFacultadYConceptoViewModel ReportePorFacultadYConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReportePorFacultadYConcepto(fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReportePorFacultadYConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pagos por Facultad",
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReporteConceptosPorFacultadViewModel ReporteConceptosPorFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            var pagos = reporteService.ReporteConceptosPorFacultad(codFac, fechaInicio, fechaFin, idEntidanFinanc, ctaDeposito);

            string nombreEntidadFinanc = idEntidanFinanc.HasValue ? entidadRecaudadoraService.Find(idEntidanFinanc.Value).Nombre : null;

            string numeroCuenta = ctaDeposito.HasValue ? cuentaDeposito.Find(ctaDeposito.Value).C_NumeroCuenta : null;

            var reporte = new ReporteConceptosPorFacultadViewModel(pagos)
            {
                Facultad = pagos.Count() > 0 ? pagos.FirstOrDefault().T_FacDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = "Reporte de Pago de Conceptos por Facultad",
                nombreEntidadFinanc = nombreEntidadFinanc,
                numeroCuenta = numeroCuenta
            };

            return reporte;
        }

        public ReporteResumenAnualPagoObligaciones_X_Clasificadores ResumenAnualPagoOblig_X_Clasificadores(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = reporteService.ResumenAnualPagoOblig_X_Clasificadores(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Clasificadores(anio, TipoEstudio.Pregrado, nombreEntidadFinanc, null, lista);

            return result;
        }

        public ReporteResumenAnualPagoObligaciones_X_Dependencias ResumenAnualPagoOblig_X_Dependencias(int anio, int? entidadFinanID, int? ctaDepositoID)
        {
            var lista = reporteService.ResumenAnualPagoOblig_X_Dependencia(anio, entidadFinanID, ctaDepositoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Dependencias(anio, TipoEstudio.Pregrado, nombreEntidadFinanc, null, lista);

            return result;
        }

        public IEnumerable<EstadoObligacionViewModel> EstadoObligacionAlumnos(ConsultaObligacionEstudianteViewModel parametro)
        {
            var lista = reporteService.EstadoObligacionAlumnos(parametro.anio.Value, parametro.periodo, parametro.codFac, parametro.codEsc, parametro.codRc, parametro.esIngresante, parametro.estaPagado, parametro.obligacionGenerada,
                parametro.fechaInicio, parametro.fechaFin, parametro.codAlumno, parametro.nomAlumno, parametro.apePaternoAlumno, parametro.apeMaternoAlumno, parametro.dependencia);

            var result = lista.Select(x => Mapper.EstadoObligacionDTO_To_EstadoObligacionViewModel(x));

            return result;
        }
    }
}