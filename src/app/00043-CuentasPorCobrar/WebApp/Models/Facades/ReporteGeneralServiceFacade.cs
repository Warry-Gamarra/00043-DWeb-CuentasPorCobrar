using Domain.Entities;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ReporteGeneralServiceFacade : IReporteGeneralServiceFacade
    {
        IReporteGeneralService reporteGeneralService;
        IEntidadRecaudadora entidadRecaudadoraService;

        public ReporteGeneralServiceFacade()
        {
            reporteGeneralService = new ReporteGeneralService();
            entidadRecaudadoraService = new EntidadRecaudadora();
        }

        public ReporteResumenAnualPagoObligaciones_X_Dia ReporteResumenAnualPagoObligaciones_X_Dia(int anio, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID)
        {
            var lista = reporteGeneralService.ResumenAnualPagoDeObligaciones_X_Dia(anio, entidadFinanID, ctaDepositoID, condicionPagoID);

            string nombreEntidadFinanc = entidadFinanID.HasValue ? entidadRecaudadoraService.Find(entidadFinanID.Value).Nombre : null;

            var result = new ReporteResumenAnualPagoObligaciones_X_Dia(anio, nombreEntidadFinanc, null, lista);

            return result;
        }
    }
}