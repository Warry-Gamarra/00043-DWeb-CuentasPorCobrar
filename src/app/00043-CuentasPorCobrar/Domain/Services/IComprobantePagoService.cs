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
            string codOperacion, string codigoInterno, string codDepositante, string nomDepositante, DateTime? fechaInicio, DateTime? fechaFinal,
            int? tipoComprobanteID, bool? estadoGeneracion, int? estadoComprobanteID);

        IEnumerable<ComprobantePagoDTO> ObtenerComprobantePagoBanco(int pagoBancoID, int? comprobanteID);

        Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, string ruc, string direccion, int currentUserID);

        Response GenerarTXTDigiFlow(int[] pagosBancoID, int currentUserID);

        Response VerificarEstadoComprobantes(int currentUserID);

        UpdateComprobanteStatus ActualizarEstadoComprobante(int numeroSerie, int numeroComprobante, string estadoComprobante, int userID);

        Response DarBajarComprobante(int comprobanteID, DateTime fecBaja, string motivoBaja, int currentUserID);
    }
}
