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
    public class ReportePosgradoServiceFacade : IReportePosgradoServiceFacade
    {
        IReportePosgradoService reporteService;

        public ReportePosgradoServiceFacade()
        {
            reporteService = new ReportePosgradoService();
        }

        public ReportePagosPorGradodViewModel ReportePagosPorGrado(DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReportePagosPorGrado(fechaInicio, fechaFin);

            var reporte = new ReportePagosPorGradodViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTIme.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTIme.BASIC_DATE),
                Titulo = "Reporte de Pagos en Posgrado"
            };

            return reporte;
        }

        public ReportePagosPorConceptoPosgradoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReportePagosPorConcepto(fechaInicio, fechaFin);

            var reporte = new ReportePagosPorConceptoPosgradoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTIme.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTIme.BASIC_DATE),
                Titulo = "Reporte de Pagos por Conceptos"
            };

            return reporte;
        }

        public ReporteConceptosPorGradoViewModel ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReporteConceptosPorGrado(codEsc, fechaInicio, fechaFin);

            var reporte = new ReporteConceptosPorGradoViewModel(pagos)
            {
                Grado = pagos.Count() > 0 ? pagos.FirstOrDefault().T_EscDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTIme.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTIme.BASIC_DATE),
                Titulo = "Reporte de Pagos por Posgrado"
            };

            return reporte;
        }
    }
}