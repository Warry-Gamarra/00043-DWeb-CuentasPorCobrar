using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IReportePosgradoServiceFacade
    {
        ReportePagosPorGradodViewModel ReportePagosPorGrado(DateTime fechaInicio, DateTime fechaFin);

        ReportePagosPorConceptoPosgradoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin);

        ReporteConceptosPorGradoViewModel ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin);
    }
}