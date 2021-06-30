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

        public ReportePagosPorGradodViewModel ReportePagosPorGrado(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReportePagosPorGrado(fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReportePagosPorGradodViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Posgrado.First(x => x.Key.Equals(1)).Value
            };

            return reporte;
        }

        public ReportePagosPorConceptoPosgradoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReportePagosPorConcepto(fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReportePagosPorConceptoPosgradoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Posgrado.First(x => x.Key.Equals(2)).Value
            };

            return reporte;
        }

        public ReporteConceptosPorGradoViewModel ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReporteConceptosPorGrado(codEsc, fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReporteConceptosPorGradoViewModel(pagos)
            {
                Grado = pagos.Count() > 0 ? pagos.FirstOrDefault().T_EscDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Posgrado.First(x => x.Key.Equals(3)).Value
            };

            return reporte;
        }
    }
}