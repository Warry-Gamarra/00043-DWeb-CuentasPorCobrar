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
        private ISerieComprobanteService _serieComprobanteService;
        private IEstadoComprobanteService _estadoComprobanteService;
        
        public ComprobantePagoServiceFacade()
        {
            _comprobantePagoService = new ComprobantePagoService();
            _serieComprobanteService = new SerieComprobanteService();
            _estadoComprobanteService = new EstadoComprobanteService();
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
                    serieID = x.serieID,
                    numeroSerie = x.numeroSerie,
                    numeroComprobante = x.numeroComprobante,
                    fechaEmision = x.fechaEmision,
                    esGravado = x.esGravado,
                    ruc = x.ruc,
                    direccion = x.direccion,
                    tipoComprobanteID = x.tipoComprobanteID,
                    tipoComprobanteCod = x.tipoComprobanteCod,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    inicial = x.inicial,
                    estadoComprobanteCod = x.estadoComprobanteCod,
                    estadoComprobanteDesc = x.estadoComprobanteDesc
                });

            return resultado;
        }

        public IEnumerable<ComprobantePagoModel> ObtenerComprobantePagoBanco(int pagoBancoID, int? comprobanteID)
        {
            var resultado = _comprobantePagoService.ObtenerComprobantePagoBanco(pagoBancoID, comprobanteID)
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
                    serieID = x.serieID,
                    numeroSerie = x.numeroSerie,
                    numeroComprobante = x.numeroComprobante,
                    fechaEmision = x.fechaEmision,
                    esGravado = x.esGravado,
                    ruc = x.ruc,
                    direccion = x.direccion,
                    tipoComprobanteID = x.tipoComprobanteID,
                    tipoComprobanteCod = x.tipoComprobanteCod,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    inicial = x.inicial,
                    estadoComprobanteCod = x.estadoComprobanteCod,
                    estadoComprobanteDesc = x.estadoComprobanteDesc,
                    concepto = x.concepto,
                    cantidad = x.cantidad
                });

            return resultado;
        }

        public Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, bool esNuevoRegistro, string ruc, string direccion,
             int currentUserID)
        {
            Response resultadoGeneracionNumComprobante;
            Response resultadoGeneracionTXT;
            Response resultado;

            try
            {
                var comprobanteDTO = _comprobantePagoService.ObtenerComprobantePagoBanco(pagosBancoID[0], null);

                if (comprobanteDTO.Where(x => x.comprobanteID.HasValue).Count() == 0 || (!esNuevoRegistro && comprobanteDTO.First().estadoComprobanteCod == EstadoComprobante.ERROR))
                {
                    resultadoGeneracionNumComprobante = _comprobantePagoService.GenerarNumeroComprobante(pagosBancoID, tipoComprobanteID, serieID, esGravado, ruc, direccion, currentUserID);

                    if (resultadoGeneracionNumComprobante.Value)
                    {
                        resultadoGeneracionTXT = _comprobantePagoService.GenerarTXTDigiFlow(pagosBancoID, currentUserID);

                        resultado = resultadoGeneracionTXT;

                        resultado.Message = String.Format("{0} {1}", resultadoGeneracionNumComprobante.Message, resultadoGeneracionTXT.Message);
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
            var serie = _serieComprobanteService.ListarSeriesComprobante(false).Where(s => s.serieID == serieID).First();

            DateTime fechaActual = DateTime.Now;

            DateTime fechaLimite = fechaActual.AddDays(-1 * serie.diasAnterioresPermitido);

            if (!filtro.fechaInicio.HasValue && !filtro.fechaFin.HasValue)
            {
                filtro.fechaDesde = fechaLimite.ToString(FormatosDateTime.BASIC_DATE);

                filtro.fechaHasta = fechaActual.ToString(FormatosDateTime.BASIC_DATE);
            }
            else
            {
                if (filtro.fechaInicio.HasValue)
                {
                    if (filtro.fechaInicio.Value.Date < fechaLimite.Date)
                    {
                        filtro.fechaDesde = fechaLimite.ToString(FormatosDateTime.BASIC_DATE);
                    }
                }
                else
                {
                    filtro.fechaDesde = fechaLimite.ToString(FormatosDateTime.BASIC_DATE);
                }
            }
            
            var listaPagos = _comprobantePagoService.ListarComprobantesPagoBanco(filtro.tipoPago, filtro.entidadFinanciera, filtro.idCtaDeposito,
                filtro.codOperacion, filtro.codInterno, filtro.codDepositante, filtro.nomDepositante, filtro.fechaInicio, filtro.fechaFin,
                filtro.tipoComprobanteID, false, null)
                .GroupBy(x => new { x.codOperacion, x.codDepositante, x.fecPago, x.entidadFinanID });

            var cantRegistros = listaPagos.Count();

            var resultadoGeneral = new Response();

            if (cantRegistros > 0)
            {
                var cantGeneracionCorrecta = 0;

                bool esNuevoRegistro = true;

                foreach (var pago in listaPagos)
                {
                    var pagosBancoId = pago.Select(x => x.pagoBancoID).ToArray();

                    var resultado = this.GenerarNumeroComprobante(pagosBancoId, tipoComprobanteID, serieID, esGravado, esNuevoRegistro, null, null, currentUserID);

                    if (resultado.Value)
                    {
                        cantGeneracionCorrecta++;
                    }
                }

                resultadoGeneral.Value = (cantRegistros == cantGeneracionCorrecta);

                resultadoGeneral.Message = resultadoGeneral.Value ? "Generación de archivo(s) TXT correcto." :
                        String.Format("Se {0} \"{1}\" {2} TXT de \"{3}\" {4}.",
                        cantGeneracionCorrecta == 1 ? "generó" : "generaron",
                        cantGeneracionCorrecta,
                        cantGeneracionCorrecta == 1 ? "archivo" : "archivos",
                        cantRegistros,
                        cantRegistros == 1 ? "pago" : "pagos");
            }
            else
            {
                resultadoGeneral.Message = "No se encontraron pagos ó los pagos están fuera de fecha. Por favor recargue la página.";
            }

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

        public Response GenerarSoloArchivo(int[] pagosBancoID, int currentUserID)
        {
            Response resultado;

            try
            {
                var comprobanteDTO = _comprobantePagoService.ObtenerComprobantePagoBanco(pagosBancoID[0], null);

                if (comprobanteDTO != null && comprobanteDTO.Count() > 0 && comprobanteDTO.First().estadoComprobanteCod == EstadoComprobante.NOFILE)
                {
                    resultado = _comprobantePagoService.GenerarTXTDigiFlow(pagosBancoID, currentUserID);   
                    
                    if (resultado.Value)
                    {
                        _comprobantePagoService.ActualizarEstadoComprobante(comprobanteDTO.First().numeroSerie.Value, 
                            comprobanteDTO.First().numeroComprobante.Value, EstadoComprobante.PENDIENTE, currentUserID);

                        resultado.Message = "El archivo se generó correctamente.";
                    }
                }
                else
                {
                    resultado = new Response()
                    {
                        Message = "Ocurrió un error al validar él estado del pago. Por favor recargué la página e intente nuevamente."
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

        public Response GenerarSoloArchivo(ConsultaComprobantePagoViewModel filtro, int currentUserID)
        {
            int estadoComprobanteID = _estadoComprobanteService.ListarEstadosComprobante(false)
                .First(x => x.estadoComprobanteCod == EstadoComprobante.NOFILE).estadoComprobanteID;

            var listaPagos = _comprobantePagoService.ListarComprobantesPagoBanco(filtro.tipoPago, filtro.entidadFinanciera, filtro.idCtaDeposito,
                filtro.codOperacion, filtro.codInterno, filtro.codDepositante, filtro.nomDepositante, filtro.fechaInicio, filtro.fechaFin,
                filtro.tipoComprobanteID, true, estadoComprobanteID)
                .GroupBy(x => new { x.codOperacion, x.codDepositante, x.fecPago, x.entidadFinanID });

            var cantRegistros = listaPagos.Count();

            var resultadoGeneral = new Response();

            if (cantRegistros > 0)
            {
                var cantGeneracionCorrecta = 0;

                foreach (var pago in listaPagos)
                {
                    var pagosBancoId = pago.Select(x => x.pagoBancoID).ToArray();

                    var serie = _serieComprobanteService.ListarSeriesComprobante(false).Where(s => s.serieID == pago.First().serieID.Value).First();

                    var fechaActual = DateTime.Now;

                    var fechaLimite = fechaActual.AddDays(-1 * serie.diasAnterioresPermitido);

                    if (pago.First().fecPago.Date >= fechaLimite.Date && pago.First().fecPago.Date <= fechaActual.Date)
                    {
                        var resultado = this.GenerarSoloArchivo(pagosBancoId, currentUserID);

                        if (resultado.Value)
                        {
                            cantGeneracionCorrecta++;
                        }
                    }
                }

                resultadoGeneral.Value = (cantRegistros == cantGeneracionCorrecta);

                resultadoGeneral.Message = resultadoGeneral.Value ? "Generación de archivo(s) TXT correcto." :
                        String.Format("Se {0} \"{1}\" {2} TXT de \"{3}\" {4}.",
                        cantGeneracionCorrecta == 1 ? "generó" : "generaron",
                        cantGeneracionCorrecta,
                        cantGeneracionCorrecta == 1 ? "archivo" : "archivos",
                        cantRegistros,
                        cantRegistros == 1 ? "pago" : "pagos");
            }
            else
            {
                resultadoGeneral.Message = "No se encontraron pagos. Por favor recargue la página.";
            }

            return resultadoGeneral;
        }

        public Response DarBajarComprobante(int comprobanteID, DateTime fecBaja, string motivoBaja, int currentUserID)
        {
            Response resultado;

            try
            {
                var comprobanteDTO = _comprobantePagoService.ObtenerComprobantePagoBanco(0, comprobanteID);

                if (comprobanteDTO != null && comprobanteDTO.Count() > 0 && comprobanteDTO.First().comprobanteID.HasValue)
                {
                    resultado = _comprobantePagoService.DarBajarComprobante(comprobanteID, fecBaja, motivoBaja, currentUserID);
                }
                else
                {
                    resultado = new Response()
                    {
                        Message = "Ocurrió un error al obtener los datos del pago. Por favor recargué la página e intente nuevamente."
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
    }
}