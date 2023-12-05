using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IComprobantePagoService
    {
        IEnumerable<ComprobantePagoDTO> ListarComprobantesPagoBanco(TipoPago? tipoPago, int? idEntidadFinanciera, int? ctaDeposito,
            string codOperacion, string codigoInterno, string codDepositante, string nomDepositante, DateTime? fechaInicio, DateTime? fechaFinal);

        IEnumerable<ComprobantePagoDTO> ObtenerComprobantePagoBanco(int pagoBancoID);
    }
}
