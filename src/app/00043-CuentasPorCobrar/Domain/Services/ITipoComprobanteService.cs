using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ITipoComprobanteService
    {
        IEnumerable<TipoComprobanteDTO> ListarTiposComprobante(bool soloHabilitados);

        Response GrabarTipoComprobante(TipoComprobanteEntity entity, SaveOption saveOption, int userID);

        Response ActualizarEstadoTipoComprobante(int tipoComprobanteID, bool estaHabilitado, int userID);

        Response EliminarTipoComprobante(int tipoComprobanteID);
    }
}
