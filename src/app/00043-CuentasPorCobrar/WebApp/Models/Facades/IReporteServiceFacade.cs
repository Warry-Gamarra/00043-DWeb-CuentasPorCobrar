using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IReporteServiceFacade
    {
        ReportePagosGeneralesPorFecha ReportePagosGeneralesPorFecha(DateTime fechaInicio, DateTime fechaFin);

        ReportePagosPorFacultadYFechaViewModel ReportePagosPorFacultadYFechaViewModel(string codFac, DateTime fechaInicio, DateTime fechaFin);
    }
}