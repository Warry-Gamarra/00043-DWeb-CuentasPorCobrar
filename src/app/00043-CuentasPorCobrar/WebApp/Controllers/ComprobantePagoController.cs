using DocumentFormat.OpenXml.EMMA;
using DocumentFormat.OpenXml.Office2010.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
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
    }
}