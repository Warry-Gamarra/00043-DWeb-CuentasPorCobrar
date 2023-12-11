using DocumentFormat.OpenXml.EMMA;
using DocumentFormat.OpenXml.Office2010.Excel;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
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

        public ComprobantePagoController()
        {
            _selectModel = new SelectModel();
            _comprobantePagoServiceFacade = new ComprobantePagoServiceFacade();
            generalServiceFacade = new GeneralServiceFacade();
            _tipoComprobanteServiceFacade = new TipoComprobanteServiceFacade();
            _serieComprobanteServiceFacade = new SerieComprobanteServiceFacade();
        }

        [HttpGet]
        public ActionResult Index(ConsultaComprobantePagoViewModel model)
        {
            ViewBag.Title = "Consulta de Pagos en Banco";

            if (model.buscar)
            {
                model.resultado = _comprobantePagoServiceFacade.ListarComprobantesPagoBanco(model);
            }

            ViewBag.EntidadesFinancieras = new SelectList(_selectModel.GetEntidadesFinancieras(), "Value", "TextDisplay", model.entidadFinanciera);

            ViewBag.CtaDeposito = new SelectList(
                model.entidadFinanciera.HasValue ? _selectModel.GetCtasDeposito(model.entidadFinanciera.Value) : new List<SelectViewModel>(), "Value", "TextDisplay", model.idCtaDeposito);

            ViewBag.TipoPago = new SelectList(generalServiceFacade.Listar_TiposPago(), "Value", "TextDisplay");

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
        public JsonResult GenerarNumeroComprobante(int pagoBancoId, int tipoComprobanteID, int serieID, bool esGravado)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(pagoBancoId);

            int[] pagosBancoId = model.Select(x => x.pagoBancoID).ToArray();

            var resultado = _comprobantePagoServiceFacade.GenerarNumeroComprobante(pagosBancoId, tipoComprobanteID, serieID, esGravado, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }

        [HttpGet]
        public ActionResult GeneracionGrupal()
        {
            ViewBag.Title = "Generar Comprobantes de Pago";

            ViewBag.ComboTipoComprobante = new SelectList(_tipoComprobanteServiceFacade.ListarTiposComprobante(true), "Value", "TextDisplay");

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
    }
}