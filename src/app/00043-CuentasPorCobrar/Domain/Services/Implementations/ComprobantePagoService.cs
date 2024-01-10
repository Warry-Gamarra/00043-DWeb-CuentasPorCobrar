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
                    serieID = x.I_SerieID,
                    numeroSerie = x.I_NumeroSerie,
                    numeroComprobante = x.I_NumeroComprobante,
                    fechaEmision = x.D_FechaEmision,
                    esGravado = x.B_EsGravado,
                    ruc = x.T_Ruc,
                    direccion = x.T_Direccion,
                    tipoComprobanteID = x.I_TipoComprobanteID,
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
                    serieID = x.I_SerieID,
                    numeroSerie = x.I_NumeroSerie,
                    numeroComprobante = x.I_NumeroComprobante,
                    fechaEmision = x.D_FechaEmision,
                    esGravado = x.B_EsGravado,
                    ruc = x.T_Ruc,
                    direccion = x.T_Direccion,
                    tipoComprobanteID = x.I_TipoComprobanteID,
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

        public Response GenerarNumeroComprobante(int[] pagosBancoID, int tipoComprobanteID, int serieID, bool esGravado, string ruc, string direccion, int currentUserID)
        {
            ResponseData result;

            var generarComprobantePago = new USP_I_GrabarComprobantePago()
            {
                I_TipoComprobanteID = tipoComprobanteID,
                I_SerieID = serieID,
                B_EsGravado = esGravado,
                T_Ruc = ruc,
                T_Direccion = direccion,
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

        public Response GenerarTXTDigiFlow(int[] pagosBancoID, int currentUserID)
        {
            IEnumerable<ComprobantePagoDTO> comprobantePagoDTO;
            Response response;

            comprobantePagoDTO = this.ObtenerComprobantePagoBanco(pagosBancoID[0]);

            try
            {
                var memoryStream = new MemoryStream();

                var writer = new StreamWriter(memoryStream, Encoding.Default);

                string inicialTipoComprobante = comprobantePagoDTO.First().inicial;

                string numeroSerie = inicialTipoComprobante.Length > 0 ? comprobantePagoDTO.First().numeroSerie.Value.ToString("D" + (4 - inicialTipoComprobante.Length)) : comprobantePagoDTO.First().numeroSerie.Value.ToString("D4");

                string numeroComprobante = comprobantePagoDTO.First().numeroComprobante.Value.ToString("D8");

                string nombreArchivo = String.Format("{0}-{1}-{2}{3}.txt", Digiflow.RUC_UNFV, numeroSerie, inicialTipoComprobante, numeroComprobante);

                DateTime fechaEmision = comprobantePagoDTO.First().fechaEmision.Value;

                DateTime fechaPago = comprobantePagoDTO.First().fecPago;

                decimal montoPagado = comprobantePagoDTO.Sum(x => x.montoPagado + x.interesMoratorio);

                decimal igv = comprobantePagoDTO.First().esGravado.Value ? Digiflow.IGV : 0;

                decimal montoIGV = comprobantePagoDTO.First().esGravado.Value ? Math.Round((montoPagado * Digiflow.IGV) / (1 + Digiflow.IGV), 2) : 0;

                decimal montoNeto = comprobantePagoDTO.First().esGravado.Value ? montoPagado - montoIGV : montoPagado;

                string codigoImpuesto = comprobantePagoDTO.First().esGravado.Value ? "1000" : "9998";

                string codigoTipoAfectacion = comprobantePagoDTO.First().esGravado.Value ? "10" : "30";

                string codigoTipoOperacion = "0101";

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
                string filaRUCEmisor = String.Format("A;RUTEmis;;{0}", Digiflow.RUC_UNFV);
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
                string tipoRutReceptor, rutReceptor, dirReceptor;

                if (comprobantePagoDTO.First().tipoComprobanteCod == CodigoTipoComprobante.FACTURA)
                {
                    tipoRutReceptor = "6";
                    rutReceptor = comprobantePagoDTO.First().ruc;
                    dirReceptor = comprobantePagoDTO.First().direccion;
                }
                else
                {
                    tipoRutReceptor = "-";
                    rutReceptor = comprobantePagoDTO.First().codDepositante == null || comprobantePagoDTO.First().codDepositante.Length == 0 ? "-" : comprobantePagoDTO.First().codDepositante;
                    dirReceptor = String.IsNullOrEmpty(comprobantePagoDTO.First().direccion) ? "-" : comprobantePagoDTO.First().direccion;
                }

                string filaTipoRutReceptor = String.Format("A;TipoRutReceptor;;{0}", tipoRutReceptor);
                writer.WriteLine(filaTipoRutReceptor);

                string filaRutReceptor = String.Format("A;RUTRecep;;{0}", rutReceptor);
                writer.WriteLine(filaRutReceptor);

                string nomDepositante = comprobantePagoDTO.First().nomDepositante == null || comprobantePagoDTO.First().nomDepositante.Length == 0 ? "-" : comprobantePagoDTO.First().nomDepositante;

                string filaRazonSocialReceptor = String.Format("A;RznSocRecep;;{0}", nomDepositante);
                writer.WriteLine(filaRazonSocialReceptor);

                string filaDirReceptor = String.Format("A;DirRecep;;{0}", dirReceptor);
                writer.WriteLine(filaDirReceptor);
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
                string filaCodigoLeyenda = "A;CodigoLeyenda;;1002";
                writer.WriteLine(filaCodigoLeyenda);
                #endregion

                #region OTROS CONCEPTOS SUNAT
                string filaTipoOperacion = String.Format("A;TipoOperacion;;{0}", codigoTipoOperacion);
                writer.WriteLine(filaTipoOperacion);
                #endregion

                #region IMPUESTOS/RETENCIONES
                string filaCodigoImpuesto = String.Format("A2;CodigoImpuesto;1;{0}", codigoImpuesto);
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
                decimal montoPagadoItem;
                decimal montoSinIGV;
                decimal precioUnitarioItem;
                decimal montoIGVUnitarioItem;
                decimal precioUnitarioItemSinIGV;

                foreach (var item in comprobantePagoDTO)
                {
                    string filaNroLinDet = String.Format("B;NroLinDet;{0};1", fila);
                    writer.WriteLine(filaNroLinDet);

                    string filaQtyItem = String.Format("B;QtyItem;{0};{1}", fila, item.cantidad == 0 ? "1.00" : item.cantidad.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaQtyItem);

                    string filaUnmdItem = String.Format("B;UnmdItem;{0};NIU", fila);
                    writer.WriteLine(filaUnmdItem);

                    string filaNmbItem = String.Format("B;NmbItem;{0};{1}", fila, String.IsNullOrEmpty(item.concepto) ? "-" : item.concepto);
                    writer.WriteLine(filaNmbItem);

                    montoPagadoItem = (item.montoPagado + item.interesMoratorio);

                    precioUnitarioItem = Math.Round(montoPagadoItem / item.cantidad, 2);

                    montoIGVUnitarioItem = comprobantePagoDTO.First().esGravado.Value ? Math.Round((montoPagadoItem * Digiflow.IGV) / (1 + Digiflow.IGV), 2) : 0;

                    precioUnitarioItemSinIGV = comprobantePagoDTO.First().esGravado.Value ? precioUnitarioItem - montoIGVUnitarioItem : montoPagadoItem;

                    montoSinIGV = precioUnitarioItemSinIGV * item.cantidad;

                    string filaPrcItem = String.Format("B;PrcItem;{0};{1}", fila, precioUnitarioItem.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaPrcItem);

                    string filaPrcItemSinIgv = String.Format("B;PrcItemSinIgv;{0};{1}", fila, precioUnitarioItemSinIGV.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaPrcItemSinIgv);

                    string filaMontoItem = String.Format("B;MontoItem;{0};{1}", fila, montoSinIGV.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaMontoItem);

                    string filaIndExe = String.Format("B;IndExe;{0};{1}", fila, codigoTipoAfectacion);
                    writer.WriteLine(filaIndExe);

                    string filaCodigoTipoIgv = String.Format("B;CodigoTipoIgv;{0};{1}", fila, codigoImpuesto);
                    writer.WriteLine(filaCodigoTipoIgv);

                    string filaTasaIgv = String.Format("B;TasaIgv;{0};{1}", fila, (igv * 100).ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaTasaIgv);

                    string filaImpuestoIgv = String.Format("B;ImpuestoIgv;{0};{1}", fila, (montoPagadoItem - montoSinIGV).ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaImpuestoIgv);

                    string filaMontoBaseImp = String.Format("B;MontoBaseImp;{0};{1}", fila, montoSinIGV.ToString(FormatosDecimal.BASIC_DECIMAL));
                    writer.WriteLine(filaMontoBaseImp);

                    string filaCodigoProductoSunat = String.Format("B;CodigoProductoSunat;{0};", fila);
                    writer.WriteLine(filaCodigoProductoSunat);

                    fila++;
                }
                #endregion

                #region DATOS ADICIONALES
                int numeroDatoAdicional = 1;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};03", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};OF. TESORERÍA", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};02", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};04", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                writer.WriteLine(String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional));
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                writer.WriteLine(String.Format("E;DescripcionAdicsunat;{0};-", numeroDatoAdicional));

                numeroDatoAdicional++;

                string filaFechaPago = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaFechaPago);
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                string filaFechaPagoValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, fechaPago.ToString(FormatosDateTime.BASIC_DATE3));
                writer.WriteLine(filaFechaPagoValor);

                numeroDatoAdicional++;

                string filaCodOperacion = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaCodOperacion);
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                string filaCodOperacionValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, comprobantePagoDTO.First().codOperacion);
                writer.WriteLine(filaCodOperacionValor);

                numeroDatoAdicional++;

                string filaCuentaBancaria = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                writer.WriteLine(filaCuentaBancaria);
                writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                string filaCuentaBancariaValor = String.Format("E;DescripcionAdicsunat;{0};{1} / {2}", numeroDatoAdicional, comprobantePagoDTO.First().entidadDesc, comprobantePagoDTO.First().numeroCuenta);
                writer.WriteLine(filaCuentaBancariaValor);

                numeroDatoAdicional++;

                if  (comprobantePagoDTO.First().entidadFinanID == Bancos.BCP_ID)
                {
                    string filaCodInterno = String.Format("E;TipoAdicSunat;{0};01", numeroDatoAdicional);
                    writer.WriteLine(filaCodInterno);
                    writer.WriteLine(String.Format("E;NmrLineasAdicSunat;{0};{1}", numeroDatoAdicional, numeroDatoAdicional.ToString("D2")));
                    string filaCodInternoValor = String.Format("E;DescripcionAdicsunat;{0};{1}", numeroDatoAdicional, comprobantePagoDTO.First().codigoInterno);
                    writer.WriteLine(filaCodInternoValor);
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
                    Message = "Generación de archivo TXT exitoso."
                };
            }
            catch(DirectoryNotFoundException)
            {
                response = new Response()
                {
                    Message = "Ocurrió un error al generar el TXT. Error: [No se encuentra el directorio para almacenar el archivo.]"
                };

                this.ActualizarEstadoComprobante(comprobantePagoDTO.First().numeroSerie.Value, comprobantePagoDTO.First().numeroComprobante.Value, EstadoComprobante.NOFILE, currentUserID);
            }
            catch (UnauthorizedAccessException)
            {
                response = new Response()
                {
                    Message = "Ocurrió un error al generar el TXT. Error: [No se tienen permisos para acceder al directorio.]"
                };

                this.ActualizarEstadoComprobante(comprobantePagoDTO.First().numeroSerie.Value, comprobantePagoDTO.First().numeroComprobante.Value, EstadoComprobante.NOFILE, currentUserID);
            }
            catch (Exception ex)
            {
                response = new Response() { 
                    Message = "Ocurrió un error al generar el TXT. Error: [" + ex.Message + "]"
                };

                this.ActualizarEstadoComprobante(comprobantePagoDTO.First().numeroSerie.Value, comprobantePagoDTO.First().numeroComprobante.Value, EstadoComprobante.NOFILE, currentUserID);
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

                    string[] comprobante = nombreArchivo.Split('-');

                    try
                    {
                        int numeroSerie = int.Parse(comprobante[1]);

                        int numeroComprobante = int.Parse(comprobante[2].Length == 8 ? comprobante[2] : comprobante[2].Substring(comprobante[2].Length - 8));

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

                    string[] comprobante = nombreArchivo.Split('-');

                    try
                    {
                        int numeroSerie = int.Parse(comprobante[1]);

                        int numeroComprobante = int.Parse(comprobante[2].Length == 8 ? comprobante[2] : comprobante[2].Substring(comprobante[2].Length - 8));

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

        public Response DarBajarComprobante(int comprobanteID, int currentUserID)
        {
            ResponseData result;

            try
            {
                var sp = new USP_U_DarBajaComprobante()
                {
                    I_ComprobanteID = comprobanteID,
                    UserID = currentUserID
                };

                result = sp.Execute();
            }
            catch (Exception ex)
            {
                result = new ResponseData()
                {
                    Message = ex.Message
                };
            }

            return new Response(result);
        }
    }
}
