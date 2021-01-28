using Domain.DTO;
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
    [Route("mantenimiento/dependencia/{action}")]
    public class DependenciaController : Controller
    {
        public readonly DependenciaModel _dependenciaModel;
        public DependenciaController()
        {
            _dependenciaModel = new DependenciaModel();
        }

        [HttpGet]
        public ActionResult Index()
        {
            ViewBag.Title = "Dependencias";
            var model = _dependenciaModel.Find();

            return View(model);
        }

        [Route("mantenimiento/dependencia/nuevo")]
        [HttpGet]
        public ActionResult New()
        {
            var model = _dependenciaModel.Find();

            return PartialView(model);
        }

        [Route("mantenimiento/dependencia/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            var model = _dependenciaModel.Find();

            return PartialView(model);
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _dependenciaModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("", ""));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult Save(DependenciaViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _dependenciaModel.Save(model, WebSecurity.CurrentUserId);
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
            return PartialView("_MsgPartialWR",result);
        }

    }
}