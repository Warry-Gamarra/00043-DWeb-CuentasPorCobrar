using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface ITipoComprobanteServiceFacade
    {
        IEnumerable<SelectViewModel> ListarTiposComprobante(bool soloHabilitados);

        IEnumerable<TipoComprobanteModel> ListarTiposComprobante();

        Response GrabarTipoComprobante(TipoComprobanteModel model, int userID);

        Response ActualizarEstadoTipoComprobante(int tipoComprobanteID, bool estaHabilitado, int userID, string returnUrl);

        Response EliminarEstadoTipoComprobante(int tipoComprobanteID);
    }
}