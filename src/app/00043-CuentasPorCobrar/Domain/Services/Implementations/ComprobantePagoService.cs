using Data;
using Data.Procedures;
using Data.Views;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.CodeDom;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ComprobantePagoService : IComprobantePagoService
    {
        public IEnumerable<ComprobantePagoDTO> ListarComprobantesPagoBanco(TipoPago? tipoPago, int? idEntidadFinanciera, int? ctaDeposito, 
            string codOperacion, string codigoInterno, string codDepositante, string nomDepositante, DateTime? fechaInicio, DateTime? fechaFinal,
            int? tipoComprobanteID, bool? estadoGeneracion, int? estadoComprobanteID)
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
                .GetAll(tipoPagoID, idEntidadFinanciera, ctaDeposito, codOperacion, codigoInterno, codDepositante, nomDepositante, fechaInicio, fechaFinal,
                tipoComprobanteID, estadoGeneracion, estadoComprobanteID)
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
                    lugarPago = x.T_LugarPago,
                    condicionPago = x.T_Condicion,
                    tipoPago = x.I_TipoPagoID == 133 ? TipoPago.Obligacion : TipoPago.Tasa,
                    comprobanteID = x.I_ComprobanteID,
                    numeroSerie = x.I_NumeroSerie,
                    numeroComprobante = x.I_NumeroComprobante,
                    fechaEmision = x.D_FechaEmision,
                    esGravado = x.B_EsGravado,
                    tipoComprobanteCod = x.C_TipoComprobanteCod,
                    tipoComprobanteDesc = x.T_TipoComprobanteDesc,
                    inicial = x.T_Inicial,
                    estadoComprobanteCod = x.C_EstadoComprobanteCod,
                    estadoComprobanteDesc = x.T_EstadoComprobanteDesc
                });

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
                    lugarPago = x.T_LugarPago,
                    condicionPago = x.T_Condicion,
                    tipoPago = x.I_TipoPagoID == 133 ? TipoPago.Obligacion : TipoPago.Tasa,
                    comprobanteID = x.I_ComprobanteID,
                    numeroSerie = x.I_NumeroSerie,
                    numeroComprobante = x.I_NumeroComprobante,
                    fechaEmision = x.D_FechaEmision,
                    esGravado = x.B_EsGravado,
                    tipoComprobanteCod = x.C_TipoComprobanteCod,
                    tipoComprobanteDesc = x.T_TipoComprobanteDesc,
                    inicial = x.T_Inicial,
                    estadoComprobanteCod = x.C_EstadoComprobanteCod,
                    estadoComprobanteDesc = x.T_EstadoComprobanteDesc,
                    concepto = x.T_Concepto,
                    cantidad = x.I_Cantidad
                }); ;

            return result;
        }

        public Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, int currentUserID)
        {
            ResponseData result;

            var generarComprobantePago = new USP_I_GrabarComprobantePago()
            {
                I_TipoComprobanteID = tipoComprobanteID,
                I_SerieID = serieID,
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

        public Response GenerarTXTDigiFlow(int[] pagosBancoID)
        {
            IEnumerable<ComprobantePagoDTO> comprobantePagoDTO;
            Response response;

            try
            {
                comprobantePagoDTO = this.ObtenerComprobantePagoBanco(pagosBancoID[0]);

                var memoryStream = new MemoryStream();

                var writer = new StreamWriter(memoryStream, Encoding.Default);

                string inicialTipoComprobante = comprobantePagoDTO.First().inicial;

                string numeroSerie = comprobantePagoDTO.First().numeroSerie.Value.ToString("D4");

                string numeroComprobante = comprobantePagoDTO.First().numeroComprobante.Value.ToString("D8");

                string nombreArchivo = String.Format("{0}{1}_{2}.txt", inicialTipoComprobante, numeroSerie, numeroComprobante);

                DateTime fechaEmision = comprobantePagoDTO.First().fechaEmision.Value;

                DateTime fechaPago = comprobantePagoDTO.First().fecPago;

                decimal montoPagado = comprobantePagoDTO.Sum(x => x.montoPagado + x.interesMoratorio);

                decimal igv = Digiflow.IGV;

                decimal montoIGV = comprobantePagoDTO.First().esGravado.Value ? Math.Round((montoPagado * igv) / (1 + igv), 2) : 0;

                decimal montoNeto = comprobantePagoDTO.First().esGravado.Value ? montoPagado - montoIGV : montoPagado;

                string filaCodEmpresa = "A;CODI_EMPR;;1";
                writer.WriteLine(filaCodEmpresa);

                string filaTipoDTE = String.Format("A;TipoDTE;;{0}", comprobantePagoDTO.First().tipoComprobanteCod);
                writer.WriteLine(filaTipoDTE);

                string filaSerie = String.Format("A;Serie;;{0}{1}", inicialTipoComprobante, numeroSerie);
                writer.WriteLine(filaSerie);

                string filaCorrelativo = String.Format("A;Correlativo;;{0}", numeroComprobante);
                writer.WriteLine(filaCorrelativo);

                string filaFechaEmision = String.Format("A;FchEmis;;{0}", fechaEmision.ToString(FormatosDateTime.BASIC_DATE3));
                writer.WriteLine(filaFechaEmision);

                string filaHoraEmision = String.Format("A;HoraEmision;;{0}", fechaEmision.ToString(FormatosDateTime.BASIC_TIME));
                writer.WriteLine(filaHoraEmision);

                string filaTipoMoneda = "A;TipoMoneda;;PEN";
                writer.WriteLine(filaTipoMoneda);

                #region EMISOR
                string filaRUCEmisor = "A;RUTEmis;;20170934289";
                writer.WriteLine(filaRUCEmisor);

                string filaTipoRUCEmisor = "A;TipoRucEmis;;6";
                writer.WriteLine(filaTipoRUCEmisor);

                string filaNombreComercial = "A;NomComer;;UNIVERSIDAD NACIONAL FEDERICO VILLARREAL";
                writer.WriteLine(filaNombreComercial);

                string filaRazonSocial = "A;RznSocEmis;;UNIVERSIDAD NACIONAL FEDERICO VILLARREAL";
                writer.WriteLine(filaRazonSocial);

                string filaCodigoLocalAnexo = "A;CodigoLocalAnexo;;";
                writer.WriteLine(filaCodigoLocalAnexo);

                string filaUbigeoEmisor = "A;ComuEmis;;150136";
                writer.WriteLine(filaUbigeoEmisor);

                string filaDireccionEmisor = "A;DirEmis;;CALLE CARLOS GONZALES 285,SAN MIGUEL";
                writer.WriteLine(filaDireccionEmisor);
                #endregion

                #region RECEPTOR
                string filaTipoRutReceptor = "A;TipoRutReceptor;;-";
                writer.WriteLine(filaTipoRutReceptor);

                string filaRutReceptor = String.Format("A;RUTRecep;;{0}", comprobantePagoDTO.First().codDepositante);
                writer.WriteLine(filaRutReceptor);

                string filaRazonSocialReceptor = String.Format("A;RznSocRecep;;{0}", comprobantePagoDTO.First().nomDepositante);
                writer.WriteLine(filaRazonSocialReceptor);
                #endregion

                #region TOTALES
                string filaMontoNeto = String.Format("A;MntNeto;;{0}", montoNeto.ToString(FormatosDecimal.BASIC_DECIMAL));
                writer.WriteLine(filaMontoNeto);

                string filaMontoExe = "A;MntExe;;0";
                writer.WriteLine(filaMontoExe);

                string filaMontoExo = "A;MntExo;;0";
                writer.WriteLine(filaMontoExo);

                string filaMontoTotal = String.Format("A;MntTotal;;{0}", montoPagado.ToString(FormatosDecimal.BASIC_DECIMAL));
                writer.WriteLine(filaMontoTotal);
                #endregion

                #region LEYENDA
                string filaCodigoLeyenda = "A;CodigoLeyenda;;";
                writer.WriteLine(filaCodigoLeyenda);
                #endregion

                #region OTROS CONCEPTOS SUNAT
                string filaTipoOperacion = "A;TipoOperacion;;0101";
                writer.WriteLine(filaTipoOperacion);
                #endregion

                #region IMPUESTOS/RETENCIONES
                string filaCodigoImpuesto = "A2;CodigoImpuesto;1;1000";
                writer.WriteLine(filaCodigoImpuesto);

                string filaMontoImpuesto = String.Format("A2;MontoImpuesto;1;{0}", montoIGV.ToString(FormatosDecimal.BASIC_DECIMAL));
                writer.WriteLine(filaMontoImpuesto);

                string filaTasaImpuesto = String.Format("A2;TasaImpuesto;1;{0}", (igv * 100).ToString(FormatosDecimal.BASIC_DECIMAL));
                writer.WriteLine(filaTasaImpuesto);

                string filaMontoImpuestoBase = String.Format("A2;MontoImpuestoBase;1;{0}", montoNeto.ToString(FormatosDecimal.BASIC_DECIMAL));
                writer.WriteLine(filaMontoImpuestoBase);
                #endregion

                #region INFORMACIÓN DE FORMA DE PAGO
                if (comprobantePagoDTO.First().tipoComprobanteCod == CodigoTipoComprobante.FACTURA)
                {
                    string filaFormaPago = "A;FormaPago;;Contado";
                    writer.WriteLine(filaFormaPago);
                }
                #endregion

                #region DETALLE
                int fila = 1;

                foreach (var item in comprobantePagoDTO)
                {
                    string filaNroLinDet = String.Format("B;NroLinDet;{0};1", fila);
                    writer.WriteLine(filaNroLinDet);

                    string filaQtyItem = String.Format("B;QtyItem;{0};", fila, item.cantidad.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaQtyItem);

                    string filaUnmdItem = String.Format("B;UnmdItem;{0};NIU", fila);
                    writer.WriteLine(filaUnmdItem);

                    string filaNmbItem = String.Format("B;NmbItem;{0};{1}", fila, item.concepto);
                    writer.WriteLine(filaNmbItem);

                    var montoPagadoItem = (item.montoPagado + item.interesMoratorio);

                    var soloIGV = 0;

                    string filaPrcItem = String.Format("B;PrcItem;{0};{1}", fila, montoPagadoItem.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaPrcItem);

                    string filaPrcItemSinIgv = String.Format("B;PrcItemSinIgv;{0};{1}", fila, montoPagadoItem.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaPrcItemSinIgv);

                    string filaMontoItem = String.Format("B;MontoItem;{0};{1}", fila, montoPagadoItem.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaMontoItem);

                    string filaIndExe = String.Format("B;IndExe;{0};10", fila);
                    writer.WriteLine(filaIndExe);

                    string filaCodigoTipoIgv = String.Format("B;CodigoTipoIgv;{0};1000", fila);
                    writer.WriteLine(filaCodigoTipoIgv);

                    string filaTasaIgv = String.Format("B;TasaIgv;{0};{1}", fila, (igv * 100).ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaTasaIgv);

                    string filaImpuestoIgv = String.Format("B;ImpuestoIgv;{0};{1}", fila, soloIGV.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaImpuestoIgv);

                    string filaMontoBaseImp = String.Format("B;MontoBaseImp;{0};6.36", fila);
                    writer.WriteLine(filaMontoBaseImp);

                    fila++;
                }
                #endregion

                #region DATOS ADICIONALES
                int numeroDatoAdicional = 1;

                string filaFechaPago = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaFechaPago);

                string filaFechaPagoValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, fechaPago.ToString(FormatosDateTime.BASIC_DATE3));
                writer.WriteLine(filaFechaPagoValor);

                numeroDatoAdicional++;

                string filaBanco = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaBanco);

                string filaBancoValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, comprobantePagoDTO.First().entidadDesc);
                writer.WriteLine(filaBancoValor);

                numeroDatoAdicional++;

                string filaCuentaBancaria = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaCuentaBancaria);

                string filaCuentaBancariaValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, comprobantePagoDTO.First().numeroCuenta);
                writer.WriteLine(filaCuentaBancariaValor);

                numeroDatoAdicional++;

                string filaCodOperacion = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaCodOperacion);

                string filaCodOperacionValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, comprobantePagoDTO.First().codOperacion);
                writer.WriteLine(filaCodOperacionValor);

                numeroDatoAdicional++;

                if  (comprobantePagoDTO.First().entidadFinanID == Bancos.BCP_ID)
                {
                    string filaCodInterno = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                    writer.WriteLine(filaCodInterno);

                    string filaCodInternoValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, comprobantePagoDTO.First().codigoInterno);
                    writer.WriteLine(filaCodInternoValor);

                    numeroDatoAdicional++;
                }
                #endregion

                writer.Flush();

                memoryStream.Seek(0, SeekOrigin.Begin);

                string directorioGuardado = Digiflow.DIRECTORIO;

                using (FileStream fileStream = new FileStream(Path.Combine(directorioGuardado, nombreArchivo), FileMode.Create))
                {
                    memoryStream.CopyTo(fileStream);
                }

                response = new Response() {
                    Value = true,
                    Message = "Generación de número de comprobante y archivo TXT exitoso."
                };
            }
            catch (Exception ex)
            {
                response = new Response() { 
                    Message = "Se generó un número de comprobante, pero ocurrió un error al generar el TXT. Error: [" + ex.Message + "]"
                };
            }

            return response;
        }

        public Response VerificarEstadoComprobantes(int currentUserID)
        {
            var listaErrores = new List<UpdateComprobanteStatus>();
            UpdateComprobanteStatus update;

            Response response;

            try
            {
                string directorioBase = Digiflow.DIRECTORIO;

                string directorioComprobanteCorrecto = Path.Combine(directorioBase, Digiflow.CARPETA_CORRECTO);

                string directorioComprobanteError = Path.Combine(directorioBase, Digiflow.CARPETA_ERROR);

                string[] comprobantesCorrectos = Directory.GetFiles(directorioComprobanteCorrecto, "*.txt");

                foreach (var item in comprobantesCorrectos)
                {
                    string nombreArchivo = Path.GetFileNameWithoutExtension(item);

                    string[] comprobante = nombreArchivo.Split('_');

                    try
                    {
                        int numeroSerie = int.Parse(comprobante[0].Length == 4 ? comprobante[0] : comprobante[0].Substring(comprobante[0].Length - 4));

                        int numeroComprobante = int.Parse(comprobante[1]);

                        update = this.ActualizarEstadoComprobante(numeroSerie, numeroComprobante, EstadoComprobante.PROCESADO, currentUserID);

                        update.fileName = nombreArchivo;
                    }
                    catch (Exception ex)
                    {
                        update = new UpdateComprobanteStatus()
                        {
                            fileName = nombreArchivo,
                            message = ex.Message 
                        };
                    }

                    if (!update.success)
                    {
                        listaErrores.Add(update);
                    }
                }

                string[] comprobantesErroneos = Directory.GetFiles(directorioComprobanteError, "*.txt");

                foreach(var item in comprobantesErroneos)
                {
                    string nombreArchivo = Path.GetFileNameWithoutExtension(item);

                    string[] comprobante = nombreArchivo.Split('_');

                    try
                    {
                        int numeroSerie = int.Parse(comprobante[0].Length == 4 ? comprobante[0] : comprobante[0].Substring(comprobante[0].Length - 4));

                        int numeroComprobante = int.Parse(comprobante[1]);

                        update = this.ActualizarEstadoComprobante(numeroSerie, numeroComprobante, EstadoComprobante.ERROR, currentUserID);

                        update.fileName = nombreArchivo;
                    }
                    catch (Exception ex)
                    {
                        update = new UpdateComprobanteStatus()
                        {
                            fileName = nombreArchivo,
                            message = ex.Message
                        };
                    }

                    if (!update.success)
                    {
                        listaErrores.Add(update);
                    }
                }

                response = new Response() {
                    Value = listaErrores.Count() == 0,
                    Message = listaErrores.Count() == 0 ? "Comprobación correcta." : "No se lograron actualizar \"" + listaErrores.Count().ToString() + "\" comprobantes."
                };
            }
            catch (Exception ex)
            {
                response = new Response() {
                    Message = ex.Message
                };
            }

            return response;
        }

        public UpdateComprobanteStatus ActualizarEstadoComprobante(int numeroSerie, int numeroComprobante, string estadoComprobante, int userID)
        {
            var actualizar = new USP_U_ActualizarEstadoComprobantePago()
            { 
                I_NumeroSerie = numeroSerie,
                I_NumeroComprobante = numeroComprobante,
                C_EstadoComprobanteCod = estadoComprobante,
                UserID = userID
            };

            var result = actualizar.Execute();

            return new UpdateComprobanteStatus() { success = result.Value, message = result.Message };
        }
    }
}
