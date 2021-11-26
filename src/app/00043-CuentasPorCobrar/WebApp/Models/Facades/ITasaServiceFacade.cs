using Domain.Helpers;
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
            string codDepositante, string nomDepositante);

        Response Grabar_TasaUnfv(RegistrarTasaViewModel model, int currentUserId);

        RegistrarTasaViewModel ObtenerTasaUnfv(int id);

        Response ChangeState(int conceptoId, bool currentState, int currentUserId, string returnUrl);
    }
}