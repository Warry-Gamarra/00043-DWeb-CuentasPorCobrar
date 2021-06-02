using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IDevolucionPago
    {
        List<DevolucionPago> Find();
        DevolucionPago Find(int devolucionPagoId);
        Response Save(DevolucionPago devolucionPago, int currentUserId, SaveOption saveOption);
        Response AnularDevolucion(int pagoProcesadoId, int currentUserId);
    }
}
