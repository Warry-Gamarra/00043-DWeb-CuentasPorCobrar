using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ReportePregradoServiceFacade : IReportePregradoServiceFacade
    {
        IReportePregradoService reporteService;

        private string dateFormat = "dd/MM/yyyy";

        public ReportePregradoServiceFacade()
        {
            reporteService = new ReportePregradoService();
        }

        public ReportePagosPorFacultadViewModel ReportePagosPorFacultad(DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReportePagosPorFacultad(fechaInicio, fechaFin);

            var reporte = new ReportePagosPorFacultadViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(dateFormat),
                FechaFin = fechaFin.ToString(dateFormat),
                Titulo = "Reporte de Pagos por Facultades"
            };

            return reporte;
        }

        public ReportePagosPorConceptoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReportePagosPorConcepto(fechaInicio, fechaFin);

            var reporte = new ReportePagosPorConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(dateFormat),
                FechaFin = fechaFin.ToString(dateFormat),
                Titulo = "Reporte de Pagos por Conceptos"
            };

            return reporte;
        }

        public ReporteConceptosPorUnaFacultadViewModel ReporteConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin)
        {
            var pagos = reporteService.ReporteConceptosPorUnaFacultad(codFac, fechaInicio, fechaFin);

            var reporte = new ReporteConceptosPorUnaFacultadViewModel(pagos)
            {
                Facultad = pagos.Count() > 0 ? pagos.FirstOrDefault().T_FacDesc : "",
                FechaInicio = fechaInicio.ToString(dateFormat),
                FechaFin = fechaFin.ToString(dateFormat),
                Titulo = "Reporte de Pagos por Facultad"
            };

            return reporte;
        }
    }
}