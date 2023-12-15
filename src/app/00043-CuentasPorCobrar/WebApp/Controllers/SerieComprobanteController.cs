using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;
using WebApp.Models;
using WebMatrix.WebData;
using Domain.Helpers;

namespace WebApp.Controllers
{
    public class SerieComprobanteController : Controller
    {
        private ISerieComprobanteServiceFacade _serviceFacade;

        public SerieComprobanteController()
        {
            _serviceFacade = new SerieComprobanteServiceFacade();
        }


        //[Route("mantenimiento/serie-comprobante")]
        public ActionResult Index()
        {
            ViewBag.Title = "Series de Comprobante";

            var model = _serviceFacade.ListarSeriesComprobante();

            return View(model);
        }

        [Route("mantenimiento/serie-comprobante/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Serie de Comprobante";

            return PartialView("_RegistrarSerieComprobante", new SerieComprobanteModel());
        }

        [Route("mantenimiento/serie-comprobante/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Serie de Comprobante";

            var model = _serviceFacade.ListarSeriesComprobante()
                .Where(x => x.serieID.Value == id);

            return PartialView("_RegistrarSerieComprobante", model);
        }

        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _serviceFacade.ActualizarEstadoSerieComprobante(RowID, B_habilitado, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Eliminar(int RowID)
        {
            var result = _serviceFacade.EliminarEstadoSerieComprobante(RowID);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(SerieComprobanteModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _serviceFacade.GrabarSerieComprobante(model, WebSecurity.CurrentUserId);
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