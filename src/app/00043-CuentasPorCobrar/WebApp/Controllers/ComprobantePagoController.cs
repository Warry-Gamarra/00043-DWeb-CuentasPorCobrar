using ClosedXML.Excel;
using DocumentFormat.OpenXml.EMMA;
using DocumentFormat.OpenXml.Office2010.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.DataSets;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    public class ComprobantePagoController : Controller
    {
        private SelectModel _selectModel;
        private IComprobantePagoServiceFacade _comprobantePagoServiceFacade;
        private IGeneralServiceFacade generalServiceFacade;
        private ITipoComprobanteServiceFacade _tipoComprobanteServiceFacade;
        private ISerieComprobanteServiceFacade _serieComprobanteServiceFacade;
        private IEstadoComprobanteServiceFacade _estadoComprobanteServiceFacade;

        public ComprobantePagoController()
        {
            _selectModel = new SelectModel();
            _comprobantePagoServiceFacade = new ComprobantePagoServiceFacade();
            generalServiceFacade = new GeneralServiceFacade();
            _tipoComprobanteServiceFacade = new TipoComprobanteServiceFacade();
            _serieComprobanteServiceFacade = new SerieComprobanteServiceFacade();
            _estadoComprobanteServiceFacade = new EstadoComprobanteServiceFacade();
        }

        [HttpGet]
        [Route("operaciones/comprobantes-de-pago")]
        public ActionResult Index(ConsultaComprobantePagoViewModel model)
        {
            ViewBag.Title = "Comprobantes de Pago";

            if (model.buscar)
            {
                model.resultado = _comprobantePagoServiceFacade.ListarComprobantesPagoBanco(model);
            }

            ViewBag.EntidadesFinancieras = new SelectList(_selectModel.GetEntidadesFinancieras(), "Value", "TextDisplay", model.entidadFinanciera);

            ViewBag.CtaDeposito = new SelectList(
                model.entidadFinanciera.HasValue ? _selectModel.GetCtasDeposito(model.entidadFinanciera.Value) : new List<SelectViewModel>(), "Value", "TextDisplay", model.idCtaDeposito);

            ViewBag.TipoPago = new SelectList(generalServiceFacade.Listar_TiposPago(), "Value", "TextDisplay");

            ViewBag.TiposComprobante = new SelectList(_tipoComprobanteServiceFacade.ListarTiposComprobante(false), "Value", "TextDisplay");

            ViewBag.EstadosComprobante = new SelectList(_estadoComprobanteServiceFacade.ListarEstadosComprobante(false), "Value", "TextDisplay");

            ViewBag.EstadosGeneracionComprobante = new SelectList(generalServiceFacade.Listar_EstadoGeneracionComprobante(), "Value", "TextDisplay");

            return View(model);
        }

        [HttpGet]
        public ActionResult DescargarExcel(ConsultaComprobantePagoViewModel model)
        {
            if (model.buscar)
            {
                model.resultado = _comprobantePagoServiceFacade.ListarComprobantesPagoBanco(model);
            }
            else
            {
                return RedirectToAction("Index", "ComprobantePago");
            }

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Comprobantes");

                worksheet.Columns("A:B").Width = 14;
                worksheet.Column("C").Width = 15;
                worksheet.Columns("D:F").Width = 14;
                worksheet.Column("G").Width = 35;
                worksheet.Column("H").Width = 20;
                worksheet.Column("I").Width = 14;
                worksheet.Column("J").Width = 20;
                worksheet.Column("K").Width = 15;
                worksheet.Column("L").Width = 14;
                worksheet.Column("M").Width = 20;
                worksheet.Column("N").Width = 14;

                int currentRow = 1;

                #region Header
                worksheet.Cell(currentRow, 1).Value = "Comprobante";
                worksheet.Cell(currentRow, 2).Value = "Tipo comprobante";
                worksheet.Cell(currentRow, 3).Value = "Tipo pago";
                worksheet.Cell(currentRow, 4).Value = "Código de operación";
                worksheet.Cell(currentRow, 5).Value = "Código interno (BCP)";
                worksheet.Cell(currentRow, 6).Value = "Código de depositante";
                worksheet.Cell(currentRow, 7).Value = "Nombre de depositante";
                worksheet.Cell(currentRow, 8).Value = "Fecha de pago";
                worksheet.Cell(currentRow, 9).Value = "Total pagado";
                worksheet.Cell(currentRow, 10).Value = "Banco";
                worksheet.Cell(currentRow, 11).Value = "Número de cuenta";
                worksheet.Cell(currentRow, 12).Value = "Estado";
                worksheet.Cell(currentRow, 13).Value = "Fecha de emisión";
                worksheet.Cell(currentRow, 14).Value = "Pago gravado";
                #endregion

                currentRow++;

                #region Body
                foreach (var item in model.resultado)
                {
                    worksheet.Cell(currentRow, 1).SetValue<string>(item.comprobantePago);
                    worksheet.Cell(currentRow, 2).SetValue<string>(item.tipoComprobanteDesc);
                    worksheet.Cell(currentRow, 3).SetValue<string>(item.tipoPago.ToString());
                    worksheet.Cell(currentRow, 4).SetValue<string>(item.codOperacion);
                    worksheet.Cell(currentRow, 5).SetValue<string>(item.codigoInterno);
                    worksheet.Cell(currentRow, 6).SetValue<string>(item.codDepositante);
                    worksheet.Cell(currentRow, 7).SetValue<string>(item.nomDepositante);
                    worksheet.Cell(currentRow, 8).SetValue<DateTime>(item.fecPago);
                    worksheet.Cell(currentRow, 9).SetValue<Decimal>(item.montoTotal);
                    worksheet.Cell(currentRow, 10).SetValue<string>(item.entidadDesc);
                    worksheet.Cell(currentRow, 11).SetValue<string>(item.numeroCuenta);
                    worksheet.Cell(currentRow, 12).SetValue<string>(item.estadoComprobanteDesc);
                    worksheet.Cell(currentRow, 13).SetValue<DateTime?>(item.fechaEmision);
                    worksheet.Cell(currentRow, 14).SetValue<string>(item.gravadoDesc);

                    currentRow++;
                }
                #endregion

                worksheet.Range(worksheet.Cell(2, 8), worksheet.Cell(currentRow, 8)).Style.DateFormat.Format = FormatosDateTime.BASIC_DATETIME;
                worksheet.Range(worksheet.Cell(2, 9), worksheet.Cell(currentRow, 9)).Style.NumberFormat.Format = FormatosDecimal.BASIC_DECIMAL;
                worksheet.Range(worksheet.Cell(2, 13), worksheet.Cell(currentRow, 13)).Style.DateFormat.Format = FormatosDateTime.BASIC_DATETIME;

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);

                    var content = stream.ToArray();

                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Consulta Comprobantes de Pago.xlsx");
                }
            }
        }

        [HttpGet]
        public ActionResult InformacioPago(int id)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(id);

            ViewBag.Title = "Comprobante de Pago";

            ViewBag.TieneComprobante = model.First().comprobanteID.HasValue;

            ViewBag.PagoBancoID = id;

            ViewBag.ComboTipoComprobante = new SelectList(_tipoComprobanteServiceFacade.ListarTiposComprobante(true), "Value", "TextDisplay");

            ViewBag.ComboSerieComprobante = new SelectList(_serieComprobanteServiceFacade.ListarSeriesComprobante(true), "Value", "TextDisplay");

            return PartialView("_InformacioPago", model);
        }

        [HttpPost]
        public JsonResult GenerarNumeroComprobante(int pagoBancoId, int tipoComprobanteID, int serieID, bool esGravado, bool esNuevoRegistro, string ruc, string direccion)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(pagoBancoId);

            int[] pagosBancoId = model.Select(x => x.pagoBancoID).ToArray();

            var resultado = _comprobantePagoServiceFacade.GenerarNumeroComprobante(pagosBancoId, tipoComprobanteID, serieID, esGravado, esNuevoRegistro, ruc, direccion, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }

        [HttpPost]
        public JsonResult GenerarSoloArchivo(int pagoBancoId)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(pagoBancoId);

            int[] pagosBancoId = model.Select(x => x.pagoBancoID).ToArray();

            var resultado = _comprobantePagoServiceFacade.GenerarSoloArchivo(pagosBancoId, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }

        [HttpGet]
        public ActionResult GeneracionGrupal()
        {
            ViewBag.Title = "Generar Comprobantes de Pago";

            var listaTipoComprobante = _tipoComprobanteServiceFacade.ListarTiposComprobante(true, true);

            ViewBag.ComboTipoComprobante = new SelectList(listaTipoComprobante, "Value", "TextDisplay");

            ViewBag.ComboSerieComprobante = new SelectList(_serieComprobanteServiceFacade.ListarSeriesComprobante(true), "Value", "TextDisplay");

            return PartialView("_GeneracionGrupal");
        }

        [HttpPost]
        public JsonResult GenerarNumeroComprobanteGrupal(ConsultaComprobantePagoViewModel model, int tipoComprobanteID, int serieID, bool esGravado)
        {
            var resultado = _comprobantePagoServiceFacade.GenerarNumeroComprobante(model, tipoComprobanteID, serieID, esGravado, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }

        [HttpPost]
        public JsonResult GeneracionArchivosGrupal(ConsultaComprobantePagoViewModel model)
        {
            var resultado = _comprobantePagoServiceFacade.GenerarSoloArchivo(model, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }

        [HttpPost]
        public async Task<JsonResult> VerificarEstadoComprobantes()
        {
            var resultado = await _comprobantePagoServiceFacade.VerificarEstadoComprobantes(WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }

        [HttpPost]
        public JsonResult DarBaja(int pagoBancoId)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(pagoBancoId);

            int[] pagosBancoId = model.Select(x => x.pagoBancoID).ToArray();

            var resultado = _comprobantePagoServiceFacade.DarBajarComprobante(pagosBancoId, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }
    }
}