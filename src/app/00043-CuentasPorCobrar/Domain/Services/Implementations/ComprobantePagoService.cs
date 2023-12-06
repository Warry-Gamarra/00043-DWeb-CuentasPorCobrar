using Data;
using Data.Procedures;
using Data.Views;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ComprobantePagoService : IComprobantePagoService
    {
        public IEnumerable<ComprobantePagoDTO> ListarComprobantesPagoBanco(TipoPago? tipoPago, int? idEntidadFinanciera, int? ctaDeposito, 
            string codOperacion, string codigoInterno, string codDepositante, string nomDepositante, DateTime? fechaInicio, DateTime? fechaFinal)
        {
            int? tipoPagoID = null;

            if (tipoPago.HasValue)
            {
                switch (tipoPago.Value)
                {
                    case TipoPago.Obligacion:
                        tipoPagoID = 133;
                        break;

                    case TipoPago.Tasa:
                        tipoPagoID = 134;
                        break;
                }
            }

            var result = USP_S_ListarComprobantePago
                .GetAll(tipoPagoID, idEntidadFinanciera, ctaDeposito, codOperacion, codigoInterno, codDepositante, nomDepositante, fechaInicio, fechaFinal)
                .Select(x => new ComprobantePagoDTO() {
                    pagoBancoID = x.I_PagoBancoID,
                    entidadFinanID = x.I_EntidadFinanID,
                    entidadDesc = x.T_EntidadDesc,
                    numeroCuenta = x.C_NumeroCuenta,
                    codOperacion = x.C_CodOperacion,
                    codigoInterno = x.C_CodigoInterno,
                    codDepositante = x.C_CodDepositante,
                    nomDepositante = x.T_NomDepositante,
                    fecPago = x.D_FecPago,
                    montoPagado = x.I_MontoPago,
                    interesMoratorio = x.I_InteresMora,
                    condicionPago = x.T_Condicion,
                    tipoPago = x.I_TipoPagoID == 133 ? TipoPago.Obligacion : TipoPago.Tasa,
                    comprobantePagoID = x.I_ComprobantePagoID,
                    numeroSerie = x.I_NumeroSerie,
                    numeroComprobante = x.I_NumeroComprobante,
                    fechaEmision = x.D_FechaEmision,
                    esGravado = x.B_EsGravado,
                    tipoComprobanteDesc = x.T_TipoComprobanteDesc,
                    estadoComprobanteDesc = x.T_EstadoComprobanteDesc
                }); ;

            return result;
        }

        public IEnumerable<ComprobantePagoDTO> ObtenerComprobantePagoBanco(int pagoBancoID)
        {
            var result = USP_S_ObtenerComprobantePago.GetAll(pagoBancoID)
                .Select(x => new ComprobantePagoDTO() {
                    pagoBancoID = x.I_PagoBancoID,
                    entidadFinanID = x.I_EntidadFinanID,
                    entidadDesc = x.T_EntidadDesc,
                    numeroCuenta = x.C_NumeroCuenta,
                    codOperacion = x.C_CodOperacion,
                    codigoInterno = x.C_CodigoInterno,
                    codDepositante = x.C_CodDepositante,
                    nomDepositante = x.T_NomDepositante,
                    fecPago = x.D_FecPago,
                    montoPagado = x.I_MontoPago,
                    interesMoratorio = x.I_InteresMora,
                    condicionPago = x.T_Condicion,
                    tipoPago = x.I_TipoPagoID == 133 ? TipoPago.Obligacion : TipoPago.Tasa,
                    comprobantePagoID = x.I_ComprobantePagoID,
                    numeroSerie = x.I_NumeroSerie,
                    numeroComprobante = x.I_NumeroComprobante,
                    fechaEmision = x.D_FechaEmision,
                    esGravado = x.B_EsGravado,
                    tipoComprobanteDesc = x.T_TipoComprobanteDesc,
                    estadoComprobanteDesc = x.T_EstadoComprobanteDesc
                }); ;

            return result;
        }

        public Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int numeroSerie, bool esGravado, int currentUserID)
        {
            ResponseData result;

            var generarComprobantePago = new USP_I_GrabarComprobantePago()
            {
                I_TipoComprobanteID = tipoComprobanteID,
                I_NumeroSerie = numeroSerie,
                B_EsGravado = esGravado,
                UserID = currentUserID
            };

            DataTable dataTable = new DataTable();
            
            dataTable.Columns.Add("ID");

            foreach (int id in pagosBancoID)
            {
                dataTable.Rows.Add(id);
            }
            
            result = generarComprobantePago.Execute(dataTable);

            return new Response(result);
        }
    }
}
