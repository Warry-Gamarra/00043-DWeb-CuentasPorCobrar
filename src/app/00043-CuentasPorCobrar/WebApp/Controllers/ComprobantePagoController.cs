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

            ViewBag.CodDepositante = model.First().codDepositante;

            ViewBag.NombreDepositante = model.First().nomDepositante;

            ViewBag.TotalPagado = model.Sum(x => x.montoTotal).ToString(FormatosDecimal.BASIC_DECIMAL);

            ViewBag.FechaPago = model.First().fecPago.ToString(FormatosDateTime.BASIC_DATETIME);

            ViewBag.CodOperacion = model.First().codOperacion;

            ViewBag.EntidadFinanciera = model.First().entidadDesc;

            ViewBag.TieneComprobante = model.First().comprobantePagoID.HasValue;

            ViewBag.PagoBancoID = id;

            return PartialView("_InformacioPago", model);
        }

        [HttpPost]
        public ActionResult GenerarNumeroComprobante(int id)
        {
            var model = _comprobantePagoServiceFacade.ObtenerComprobantePagoBanco(id);

            int[] pagosRelacionados = model.Select(x => x.pagoBancoID).ToArray();

            return PartialView("_GenerarNumeroComprobante", model);
        }
    }
}