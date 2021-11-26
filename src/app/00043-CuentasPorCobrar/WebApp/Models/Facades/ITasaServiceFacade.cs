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

        IEnumerable<TasaViewModel> listarTodoTasas();

        IEnumerable<PagoTasaModel> listarPagoTasas(int? idEntidadFinanciera, int? idCtaDeposito, string codOperacion, DateTime? fechaInicio, DateTime? fechaFinal,
            string codDepositante);
    }
}