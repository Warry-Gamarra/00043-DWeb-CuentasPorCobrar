using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface ITasaServiceFacade
    {
        IEnumerable<SelectViewModel> listarTasas();

        IEnumerable<PagoTasaModel> listarPagoTasas(int? idEntidadFinanciera, int? idCtaDeposito, string codOperacion, DateTime? fechaInicio, DateTime? fechaFinal);
    }
}