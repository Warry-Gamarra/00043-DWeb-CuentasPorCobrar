using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using WebApp.ViewModels;
using WebMatrix.WebData;

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
                filtro.codOperacion, filtro.codInterno, filtro.codDepositante, filtro.nomDepositante, filtro.fechaInicio, filtro.fechaFin,
                filtro.tipoComprobanteID, filtro.estadoGeneracion, filtro.estadoComprobanteID)
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
                    comprobanteID = x.comprobanteID,
                    numeroSerie = x.numeroSerie,
                    numeroComprobante = x.numeroComprobante,
                    fechaEmision = x.fechaEmision,
                    esGravado = x.esGravado,
                    tipoComprobanteCod = x.tipoComprobanteCod,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    inicial = x.inicial,
                    estadoComprobanteCod = x.estadoComprobanteCod,
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
                    comprobanteID = x.comprobanteID,
                    numeroSerie = x.numeroSerie,
                    numeroComprobante = x.numeroComprobante,
                    fechaEmision = x.fechaEmision,
                    esGravado = x.esGravado,
                    tipoComprobanteCod = x.tipoComprobanteCod,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    inicial = x.inicial,
                    estadoComprobanteCod = x.estadoComprobanteCod,
                    estadoComprobanteDesc = x.estadoComprobanteDesc
                });

            return resultado;
        }

        public Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, bool esNuevoRegistro, int currentUserID)
        {
            Response resultadoGeneracionNumComprobante;
            Response resultadoGeneracionTXT;
            Response resultado;

            try
            {
                var comprobanteDTO = _comprobantePagoService.ObtenerComprobantePagoBanco(pagosBancoID[0]);

                if (comprobanteDTO.Where(x => x.comprobanteID.HasValue).Count() == 0 || (!esNuevoRegistro && comprobanteDTO.First().estadoComprobanteCod == EstadoComprobante.ERROR))
                {
                    resultadoGeneracionNumComprobante = _comprobantePagoService.GenerarNumeroComprobante(pagosBancoID, tipoComprobanteID, serieID, esGravado, esNuevoRegistro, currentUserID);

                    if (resultadoGeneracionNumComprobante.Value)
                    {
                        resultadoGeneracionTXT = _comprobantePagoService.GenerarTXTDigiFlow(pagosBancoID);

                        resultado = resultadoGeneracionTXT;
                    }
                    else
                    {
                        resultado = resultadoGeneracionNumComprobante;
                    }
                }
                else
                {
                    resultado = new Response() {
                        Message = "Este registro ya tiene un comprobante registrado."
                    };
                }
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

        public Response GenerarNumeroComprobante(ConsultaComprobantePagoViewModel filtro, int tipoComprobanteID, int serieID, bool esGravado, int currentUserID)
        {
            var listaPagos = _comprobantePagoService.ListarComprobantesPagoBanco(filtro.tipoPago, filtro.entidadFinanciera, filtro.idCtaDeposito,
                filtro.codOperacion, filtro.codInterno, filtro.codDepositante, filtro.nomDepositante, filtro.fechaInicio, filtro.fechaFin,
                filtro.tipoComprobanteID, filtro.estadoGeneracion, filtro.estadoComprobanteID)
                .GroupBy(x => new { x.codOperacion, x.codDepositante, x.fecPago, x.entidadFinanID });

            var cantRegistros = listaPagos.Count();

            var cantGeneracionCorrecta = 0;

            bool esNuevoRegistro = true;

            foreach (var pago in listaPagos)
            {
                var pagosBancoId = pago.Select(x => x.pagoBancoID).ToArray();

                var resultado = this.GenerarNumeroComprobante(pagosBancoId, tipoComprobanteID, serieID, esGravado, esNuevoRegistro, currentUserID);

                if (resultado.Value)
                {
                    cantGeneracionCorrecta++;
                }
            }

            var resultadoGeneral = new Response();

            resultadoGeneral.Value = (cantRegistros == cantGeneracionCorrecta);

            resultadoGeneral.Message = resultadoGeneral.Value ? "La generación de archivo TXT correcto." :
                    String.Format("Se {0} \"{1}\" {2} TXT de \"{3}\" {4}.",
                    cantGeneracionCorrecta == 1 ? "generó" : "generaron",
                    cantGeneracionCorrecta,
                    cantGeneracionCorrecta == 1 ? "archivo" : "archivos",
                    cantRegistros,
                    cantRegistros == 1 ? "pago" : "pagos");

            return resultadoGeneral;
        }

        public async Task<Response> VerificarEstadoComprobantes(int currentUserID)
        {
            Response resultado;

            try
            {
                resultado = await Task.Run(() => _comprobantePagoService.VerificarEstadoComprobantes(currentUserID));
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