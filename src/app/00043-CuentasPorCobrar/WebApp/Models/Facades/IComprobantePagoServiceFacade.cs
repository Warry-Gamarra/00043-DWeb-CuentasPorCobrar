using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IComprobantePagoServiceFacade
    {
        IEnumerable<ComprobantePagoModel> ListarComprobantesPagoBanco(ConsultaComprobantePagoViewModel filtro);

        IEnumerable<ComprobantePagoModel> ObtenerComprobantePagoBanco(int pagoBancoID);

        Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, bool esNuevoRegistro, string ruc, string direccion, int currentUserID);

        Response GenerarNumeroComprobante(ConsultaComprobantePagoViewModel filtro, int tipoComprobanteID, int serieID, bool esGravado, int currentUserID);

        Task<Response> VerificarEstadoComprobantes(int currentUserID);

        Response GenerarSoloArchivo(int[] pagosBancoID, int currentUserID);

        Response GenerarSoloArchivo(ConsultaComprobantePagoViewModel filtro, int currentUserID);

        Response DarBajarComprobante(int[] comprobanteID, int currentUserID);
    }
}
