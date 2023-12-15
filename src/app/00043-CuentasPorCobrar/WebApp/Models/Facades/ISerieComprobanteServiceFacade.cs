using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface ISerieComprobanteServiceFacade
    {
        IEnumerable<SelectViewModel> ListarSeriesComprobante(bool soloHabilitados);

        IEnumerable<SerieComprobanteModel> ListarSeriesComprobante();

        Response GrabarSerieComprobante(SerieComprobanteModel model, int userID);

        Response ActualizarEstadoSerieComprobante(int serieComprobanteID, bool estaHabilitado, int userID);

        Response EliminarEstadoSerieComprobante(int serieComprobanteID);
    }
}
