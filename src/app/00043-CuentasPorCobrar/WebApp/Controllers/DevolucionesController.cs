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
    public class DevolucionController : Controller
    {
        // GET: Devoluciones
        public readonly EntidadRecaudadoraModel _entidadRecaudadora;
        public readonly DevolucionPagoModel _devolucionPagoModel;

        public DevolucionController()
        {
            _entidadRecaudadora = new EntidadRecaudadoraModel();
            _devolucionPagoModel = new DevolucionPagoModel();
        }

        [Route("operaciones/devolucion-pagos")]
        public ActionResult Index()
        {
            ViewBag.Title = "Devolución de pagos";
            var model = new List<DevolucionesViewModel>();

            return View(model);
        }

        [Route("operaciones/devolucion-pagos/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Nueva devolución de pago";
            ViewBag.EntidadRecaudadora = new SelectList(_entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad");

            return PartialView("_RegistrarDevolucionPago", new RegistrarDevolucionPagoViewModel());
        }

        [Route("operaciones/devolucion-pagos/{id}/editar")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Nueva devolución de pago";

            var model = _devolucionPagoModel.Find(id);
            ViewBag.EntidadRecaudadora = new SelectList(_entidadRecaudadora.Find(enabled: true), "Id", "NombreEntidad", model.EntidadRecaudadora);

            return PartialView("_RegistrarDevolucionPago", model);
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