using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ComprobantePagoServiceFacade : IComprobantePagoServiceFacade
    {
        private IComprobantePagoService comprobantePagoService;
        
        public ComprobantePagoServiceFacade()
        {
            comprobantePagoService = new ComprobantePagoService();
        }

        public IEnumerable<ComprobantePagoModel> ListarComprobantesPagoBanco(ConsultaComprobantePagoViewModel filtro)
        {
            var resultado = comprobantePagoService.ListarComprobantesPagoBanco(filtro.tipoPago, filtro.entidadFinanciera, filtro.idCtaDeposito,
                filtro.codOperacion, filtro.codInterno, filtro.codDepositante, filtro.fechaInicio, filtro.fechaFin)
                .Select(x => new ComprobantePagoModel() { 
                    pagoBancoID = x.pagoBancoID,
                    entidadDesc = x.entidadDesc,
                    numeroCuenta = x.numeroCuenta,
                    codOperacion = x.codOperacion,
                    codigoInterno = x.codigoInterno,
                    codDepositante = x.codDepositante,
                    nomDepositante = x.nomDepositante,
                    fecPago = x.fecPago,
                    montoPagado = x.montoPagado,
                    interesMoratorio = x.interesMoratorio,
                    lugarPago = x.lugarPago,
                    condicionPago = x.condicionPago,
                    tipoPago = x.tipoPago
                });

            return resultado;
        }
    }
}