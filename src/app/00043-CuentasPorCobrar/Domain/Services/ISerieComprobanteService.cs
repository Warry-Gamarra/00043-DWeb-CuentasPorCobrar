using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ISerieComprobanteService
    {
        IEnumerable<SerieComprobanteDTO> ListarSeriesComprobante(bool soloHabilitados);

        Response GrabarSerieComprobante(SerieComprobanteEntity entity, SaveOption saveOption, int userID);

        Response ActualizarEstadoSerieComprobante(int serieID, bool estaHabilitado, int userID);

        Response EliminarSerieComprobante(int serieID);
    }
}
