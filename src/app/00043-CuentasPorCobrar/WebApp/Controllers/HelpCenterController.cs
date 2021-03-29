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
    [Route("ayuda/{action}")]
    public class HelpCenterController : Controller
    {
        private readonly ManualUsuarioModel _manualUsuarioModel;

        public HelpCenterController()
        {
            _manualUsuarioModel = new ManualUsuarioModel();
        }

        // GET: HelpCenter
        public ActionResult Index()
        {
            return RedirectToAction("Manual", "HelpCenter");
        }

        [Route("ayuda/manual-usuario")]
        public ActionResult Manual()
        {
            ViewBag.Title = "Manual de usuario";
            return View(_manualUsuarioModel.ObtenerManualesPorUsuario(WebSecurity.CurrentUserId));
        }


        [Authorize(Roles = "Administrador")]
        [Route("mantenimiento/ayuda/manuales-listado")]
        public ActionResult Manage()
        {
            ViewBag.Title = "Documentación";

            return View("ManualesListado", _manualUsuarioModel.ObtenerManuales());
        }


        [Authorize(Roles = "Administrador")]
        [Route("mantenimiento/ayuda/manuales/nuevo")]
        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo Documento";

            return PartialView("_ManualesRegistrar", new UserManualViewModel());
        }


        [Authorize(Roles = "Administrador")]
        [Route("mantenimiento/ayuda/manuales/editar/{id}")]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Documento";

            return PartialView("_ManualesRegistrar", _manualUsuarioModel.ObtenerManualUsuario(id));
        }


        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _manualUsuarioModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "HelpCenter"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public ActionResult Save(UserManualViewModel model)
        {
            var result = new Response();

            if (ModelState.IsValid)
            {
                result = _manualUsuarioModel.Save(model, WebSecurity.CurrentUserId);
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

                result.Error("Ha ocurrido un error con el envio de datos. " + details);
            }

            return PartialView("_MsgPartialWR", result);
        }


    }
}