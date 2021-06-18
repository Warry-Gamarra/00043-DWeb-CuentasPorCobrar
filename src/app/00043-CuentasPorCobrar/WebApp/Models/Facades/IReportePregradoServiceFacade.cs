using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IReportePregradoServiceFacade
    {
        ReportePagosPorFacultadViewModel ReportePagosPorFacultad(DateTime fechaInicio, DateTime fechaFin);

        ReportePagosPorConceptoViewModel ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin);

        ReporteConceptosPorUnaFacultadViewModel ReporteConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin);
    }
}