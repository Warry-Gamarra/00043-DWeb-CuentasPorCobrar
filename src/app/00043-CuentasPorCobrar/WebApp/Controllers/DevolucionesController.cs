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
    public class DevolucionesController : Controller
    {
        // GET: Devoluciones
        private readonly EntidadRecaudadoraModel _entidadRecaudadora;
        private readonly DevolucionPagoModel _devolucionPagoModel;
        private readonly SelectModel _selectModels;

        public DevolucionesController()
        {
            _entidadRecaudadora = new EntidadRecaudadoraModel();
            _devolucionPagoModel = new DevolucionPagoModel();
            _selectModels = new SelectModel();
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

            return PartialView("_RegistrarDevolucionPago", new RegistrarDevolucionPagoViewModel());
        }

        [Route("operaciones/devolucion-pagos/{id}/editar")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Nueva devolución de pago";

            var model = _devolucionPagoModel.Find(id);
            ViewBag.EntidadRecaudadora = new SelectList(_entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad", model.EntidadRecaudadora);
            ViewBag.Mensaje = "Ingrese los datos del pago de referencia para la devolución";
            ViewBag.Color = "secondary";

            return PartialView("_RegistrarDevolucionPago", model);
        }

        [HttpGet]
        public ActionResult BuscarPagoDevolucion(int entidadId, string codreferencia)
        {
            var model = new DatosPagoViewModel();

            if (model.PagoId == 0)
            {
                ViewBag.Mensaje = "No se encontró ningún pago para el codigo ingresado";
                ViewBag.Color = "danger";
            }
            else
            {
                ViewBag.Mensaje = "Ingrese los datos del pago de referencia para la devolución";
                ViewBag.Color = "secondary";
            }

            return PartialView("_ResultadoBusquedaPago", model);
        }

        public JsonResult ChangeState(int devolucionId)
        {
            var result = _devolucionPagoModel.AnularDevolucion(devolucionId, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(RegistrarDevolucionPagoViewModel model)
        {
            Response result = new Response();

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