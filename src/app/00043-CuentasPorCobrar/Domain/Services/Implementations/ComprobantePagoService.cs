using Data.Views;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ComprobantePagoService : IComprobantePagoService
    {
        public IEnumerable<ComprobantePagoDTO> ListarComprobantesPagoBanco(TipoPago? tipoPago, int? idEntidadFinanciera, int? ctaDeposito, 
            string codOperacion, string codigoInterno, string codDepositante, DateTime? fechaInicio, DateTime? fechaFinal)
        {
            IEnumerable<ComprobantePagoDTO> listaPagoBancoObligaciones = null;
            IEnumerable<ComprobantePagoDTO> listaPagoBancoTasas = null;

            if (!tipoPago.HasValue || tipoPago.Value.Equals(TipoPago.Obligacion))
            {
                listaPagoBancoObligaciones = VW_PagoBancoObligaciones
                    .GetAll(idEntidadFinanciera, ctaDeposito, codOperacion, codDepositante, fechaInicio, fechaFinal, null, null, null, null, codigoInterno, null)
                    .Select(x => new ComprobantePagoDTO() {
                        pagoBancoID = x.I_PagoBancoID,
                        entidadDesc = x.T_EntidadDesc,
                        numeroCuenta = x.C_NumeroCuenta,
                        codOperacion = x.C_CodOperacion,
                        codigoInterno = x.C_CodigoInterno,
                        codDepositante = x.C_CodAlu,
                        nomDepositante = String.Format("{0} {1}, {2}", x.T_ApePaterno ?? "", x.T_ApeMaterno ?? "", x.T_Nombre ?? ""),
                        fecPago = x.D_FecPago.Value,
                        montoPagado = x.I_MontoPago,
                        interesMoratorio = x.I_InteresMora,
                        lugarPago = x.T_LugarPago,
                        condicionPago = x.T_Condicion,
                        tipoPago = TipoPago.Obligacion
                    });
            }

            if (!tipoPago.HasValue || tipoPago.Value.Equals(TipoPago.Tasa))
            {
                listaPagoBancoTasas = VW_PagoTasas
                    .GetAll(idEntidadFinanciera, ctaDeposito, codOperacion, fechaInicio, fechaFinal, codDepositante, null, codigoInterno)
                    .Select(x => new ComprobantePagoDTO() {
                        pagoBancoID = x.I_PagoBancoID,
                        entidadDesc = x.T_EntidadDesc,
                        numeroCuenta = x.C_NumeroCuenta,
                        codOperacion = x.C_CodOperacion,
                        codigoInterno = x.C_CodigoInterno,
                        codDepositante = x.C_CodDepositante,
                        nomDepositante = x.T_NomDepositante,
                        fecPago = x.D_FecPago,
                        montoPagado = x.I_MontoPagado,
                        interesMoratorio = x.I_InteresMoratorio,
                        condicionPago = x.T_Condicion,
                        tipoPago = TipoPago.Tasa
                    });
            }

            if (listaPagoBancoObligaciones != null && listaPagoBancoTasas != null)
            {
                return listaPagoBancoObligaciones.Concat(listaPagoBancoTasas);
            }
            else
            {
                if (listaPagoBancoObligaciones != null)
                {
                    return listaPagoBancoObligaciones;
                }
                else if (listaPagoBancoTasas != null)
                {
                    return listaPagoBancoTasas;
                }
                else
                {
                    return new List<ComprobantePagoDTO>();
                }
            }
        }
    }
}
