using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class DevolucionesController : Controller
    {
        // GET: Devoluciones
        private readonly EntidadRecaudadoraModel _entidadRecaudadora;
        private readonly DevolucionPagoModel _devolucionPagoModel;
        private readonly PagosModel _pagosModel;
        private readonly SelectModel _selectModels;

        public DevolucionesController()
        {
            _entidadRecaudadora = new EntidadRecaudadoraModel();
            _devolucionPagoModel = new DevolucionPagoModel();
            _selectModels = new SelectModel();
            _pagosModel = new PagosModel();
        }

        [Route("operaciones/devolucion-pagos")]
        public ActionResult Index(int? anio)
        {
            anio = anio ?? DateTime.Now.Year;
            ViewBag.Title = "Devolución de pagos";
            ViewBag.Anios = new SelectList(_selectModels.GetAnios(1990), "Value", "TextDisplay", anio);

            var model = _devolucionPagoModel.Find().Where(x => x.FecAprobacion.Value.Year == anio.Value);

            return View(model);
        }

        [Route("operaciones/devolucion-pagos/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Nueva devolución de pago";
            ViewBag.EntidadRecaudadora = new SelectList(_entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");
            ViewBag.Mensaje = "Ingrese los datos del pago de referencia para la devolución";
            ViewBag.Color = "secondary";

            return PartialView("_NuevoDevolucionPago");
        }

        [Route("operaciones/devolucion-pagos/{id}/editar")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar devolución de pago";

            var model = _devolucionPagoModel.Find(id);

            return PartialView("_RegistroDevolucionPago", model);
        }

        [HttpGet]
        public ActionResult BuscarPagoDevolucion(int entidadId, string codreferencia)
        {
            var pagoDevuleto = _devolucionPagoModel.Find(entidadId, codreferencia);
            string entidadRecaudadora = _entidadRecaudadora.Find(entidadId).NombreEntidad;
            if (pagoDevuleto.Count > 0)
            {
                return PartialView("_MsgPartial", new Response()
                {
                    Color = "warning",
                    Icon = "exclamation-circle",
                    CurrentID = "display:none;",
                    Message = $"El pago {codreferencia} en la entidad recaudadora {entidadRecaudadora} ya se presenta una devolución."
                });
            }
            else
            {
                var model = _pagosModel.BuscarPagoRegistrado(entidadId, codreferencia);
                ViewBag.CodigoOperacion = codreferencia;
                ViewBag.EntidadRecaudadora = entidadRecaudadora;

                return PartialView("_ResultadoBusquedaPago", model);
            }
        }

        public JsonResult Anular(int devolucionId)
        {
            var result = _devolucionPagoModel.AnularDevolucion(devolucionId, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult RegistrarDevolucion(int pagoId)
        {
            ViewBag.Title = "Nueva devolución de pago";
            var model = new RegistrarDevolucionPagoViewModel();

            model.DatosPago = _pagosModel.ObtenerDatosPago(pagoId);

            return PartialView("_RegistroDevolucionPago", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistrarDevolucionPagoViewModel model, string txtFecAprueba, string txtFecDevuelve)
        {
            Response result = new Response();

            if (!string.IsNullOrEmpty(txtFecAprueba)) model.FecAprueba = DateTime.Parse(txtFecAprueba);
            if (!string.IsNullOrEmpty(txtFecDevuelve)) model.FecDevuelve = DateTime.Parse(txtFecDevuelve);

            if (ModelState.IsValid)
            {
                result = _devolucionPagoModel.Save(model, WebSecurity.CurrentUserId);
            }
            else
            {
                string details = "";
                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += error.ErrorMessage + " / ";
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos. " + details);
            }
            return PartialView("_MsgPartialWR", result);
        }
    }
}