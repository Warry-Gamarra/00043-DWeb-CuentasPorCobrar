using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IReporteGeneralServiceFacade
    {
        ReporteResumenAnualPagoObligaciones_X_Dia ReporteResumenAnualPagoObligaciones_X_Dia(int anio, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID);

        ReporteCantidadDePagosRegistrados_X_Dia ReporteCantidadDePagosRegistrados_X_Dia(int anio, int tipoPago, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID);
    }
}