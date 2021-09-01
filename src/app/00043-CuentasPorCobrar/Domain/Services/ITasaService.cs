using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ITasaService
    {
        IEnumerable<TasaDTO> listar_TasasHabilitadas();

        ImportacionPagoResponse Grabar_Pago_Tasas(List<PagoTasaEntity> dataPagoTasas, string observacion, int currentUserID);
    }
}
