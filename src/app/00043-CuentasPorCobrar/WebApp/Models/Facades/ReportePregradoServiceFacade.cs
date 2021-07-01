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
    public class ReportePregradoServiceFacade : IReportePregradoServiceFacade
    {
        IReportePregradoService reporteService;

        public ReportePregradoServiceFacade()
        {
            reporteService = new ReportePregradoService();
        }

        public ReportePagosPorFacultadViewModel ReportePagosPorFacultad(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReportePagosPorFacultad(fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReportePagosPorFacultadViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Pregrado.First(x => x.Key.Equals(1)).Value
            };

            return reporte;
        }

        public ReportePagosPorConceptoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReportePagosPorConcepto(fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReportePagosPorConceptoViewModel(pagos)
            {
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Pregrado.First(x => x.Key.Equals(2)).Value
            };

            return reporte;
        }

        public ReporteConceptosPorUnaFacultadViewModel ReporteConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            var pagos = reporteService.ReporteConceptosPorUnaFacultad(codFac, fechaInicio, fechaFin, idEntidanFinanc);

            var reporte = new ReporteConceptosPorUnaFacultadViewModel(pagos)
            {
                Facultad = pagos.Count() > 0 ? pagos.FirstOrDefault().T_FacDesc : "",
                FechaInicio = fechaInicio.ToString(FormatosDateTime.BASIC_DATE),
                FechaFin = fechaFin.ToString(FormatosDateTime.BASIC_DATE),
                Titulo = Reportes.Pregrado.First(x => x.Key.Equals(3)).Value
            };

            return reporte;
        }
    }
}