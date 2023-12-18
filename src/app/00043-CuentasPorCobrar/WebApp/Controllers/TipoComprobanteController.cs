using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.Models.Facades;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    public class TipoComprobanteController : Controller
    {
        private ITipoComprobanteServiceFacade _serviceFacade;

        public TipoComprobanteController()
        {
            _serviceFacade = new TipoComprobanteServiceFacade();
        }


        [Route("mantenimiento/tipo-comprobante")]
        public ActionResult Index()
        {
            ViewBag.Title = "Tipos de Comprobante";

            var model = _serviceFacade.ListarTiposComprobante();

            return View(model);
        }

        [Route("mantenimiento/tipo-comprobante/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Tipo de Comprobante";
            
            return PartialView("_RegistrarTipoComprobante", new TipoComprobanteModel());
        }

        [Route("mantenimiento/tipo-comprobante/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Tipo de Comprobante";

            var model = _serviceFacade.ListarTiposComprobante()
                .Where(x => x.tipoComprobanteID.Value == id)
                .FirstOrDefault();

            return PartialView("_RegistrarTipoComprobante", model);
        }

        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _serviceFacade.ActualizarEstadoTipoComprobante(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "TipoComprobante"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Eliminar(int id)
        {
            var result = _serviceFacade.EliminarTipoComprobante(id);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(TipoComprobanteModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _serviceFacade.GrabarTipoComprobante(model, WebSecurity.CurrentUserId);
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