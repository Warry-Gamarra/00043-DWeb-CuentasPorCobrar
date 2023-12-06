using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ComprobantePagoServiceFacade : IComprobantePagoServiceFacade
    {
        private IComprobantePagoService _comprobantePagoService;
        
        public ComprobantePagoServiceFacade()
        {
            _comprobantePagoService = new ComprobantePagoService();
        }

        public IEnumerable<ComprobantePagoModel> ListarComprobantesPagoBanco(ConsultaComprobantePagoViewModel filtro)
        {
            var resultado = _comprobantePagoService.ListarComprobantesPagoBanco(filtro.tipoPago, filtro.entidadFinanciera, filtro.idCtaDeposito,
                filtro.codOperacion, filtro.codInterno, filtro.codDepositante, filtro.nomDepositante, filtro.fechaInicio, filtro.fechaFin)
                .Select(x => new ComprobantePagoModel() { 
                    pagoBancoID = x.pagoBancoID,
                    entidadFinanID = x.entidadFinanID,
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
                    tipoPago = x.tipoPago,
                    comprobantePagoID = x.comprobantePagoID,
                    numeroSerie = x.numeroSerie,
                    numeroComprobante = x.numeroComprobante,
                    fechaEmision = x.fechaEmision,
                    esGravado = x.esGravado,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    estadoComprobanteDesc = x.estadoComprobanteDesc
                });

            return resultado;
        }

        public IEnumerable<ComprobantePagoModel> ObtenerComprobantePagoBanco(int pagoBancoID)
        {
            var resultado = _comprobantePagoService.ObtenerComprobantePagoBanco(pagoBancoID)
                .Select(x => new ComprobantePagoModel() {
                    pagoBancoID = x.pagoBancoID,
                    entidadFinanID = x.entidadFinanID,
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
                    tipoPago = x.tipoPago,
                    comprobantePagoID = x.comprobantePagoID,
                    numeroSerie = x.numeroSerie,
                    numeroComprobante = x.numeroComprobante,
                    fechaEmision = x.fechaEmision,
                    esGravado = x.esGravado,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    estadoComprobanteDesc = x.estadoComprobanteDesc
                });

            return resultado;
        }

        public Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, int currentUserID)
        {
            Response resultado;

            try
            {
                resultado = _comprobantePagoService.GenerarNumeroComprobante(pagosBancoID, tipoComprobanteID, serieID, esGravado, currentUserID);
            }
            catch (Exception ex)
            {
                resultado = new Response()
                {
                    Message = ex.Message
                };
            }

            return resultado;
        }
    }
}