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

        IEnumerable<PagoTasaModel> listarPagoTasas(ConsultaPagoTasasViewModel model);

        PagoTasaModel ObtenerPagoTasa(int I_PagoBancoID);

        Response Grabar_TasaUnfv(RegistrarTasaViewModel model, int currentUserId);

        RegistrarTasaViewModel ObtenerTasaUnfv(int id);

        Response ChangeState(int conceptoId, bool currentState, int currentUserId, string returnUrl);

        int[] ObtenerCtaDepositoIDs(int tasaUnfvID);

        int[] ObtenerServicioIDs(int tasaUnfvID);
    }
}