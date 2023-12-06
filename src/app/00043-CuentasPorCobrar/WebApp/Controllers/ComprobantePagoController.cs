using DocumentFormat.OpenXml.EMMA;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    public class ComprobantePagoController : Controller
    {
        private SelectModel _selectModel;
        private IComprobantePagoServiceFacade _comprobantePagoServiceFacade;

        public ComprobantePagoController()
        {
            _selectModel = new SelectModel();
            _comprobantePagoServiceFacade = new ComprobantePagoServiceFacade();
        }

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

            return View(model);
        }

        public ActionResult InformacioPago(int id)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(id);

            ViewBag.Title = "Comprobante de Pago";

            ViewBag.TieneComprobante = model.First().comprobantePagoID.HasValue;

            ViewBag.PagoBancoID = id;

            return PartialView("_InformacioPago", model);
        }

        [HttpPost]
        public JsonResult GenerarNumeroComprobante(int pagoBancoId, int tipoComprobanteID, int numeroSerie, bool esGravado)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(pagoBancoId);

            int[] pagosBancoId = model.Select(x => x.pagoBancoID).ToArray();

            var resultado = _comprobantePagoServiceFacade.GenerarNumeroComprobante(pagosBancoId, tipoComprobanteID, numeroSerie, esGravado, WebSecurity.CurrentUserId);

            var jsonResponse = Json(resultado, JsonRequestBehavior.AllowGet);

            return jsonResponse;
        }
    }
}