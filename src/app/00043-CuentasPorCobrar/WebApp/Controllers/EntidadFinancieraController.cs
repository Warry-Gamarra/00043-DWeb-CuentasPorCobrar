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
    public class EntidadFinancieraController : Controller
    {
        public readonly EntidadFinancieraModel _entidadFinanciera;
        public readonly SelectModels _selectModels;

        public EntidadFinancieraController()
        {
            _entidadFinanciera = new EntidadFinancieraModel();
            _selectModels = new SelectModels();
        }


        [Route("mantenimiento/entidades-financieras")]
        public ActionResult Index()
        {
            ViewBag.Title = "Entidades Financieras";
            var model = _entidadFinanciera.Find();

            return View(model);
        }

        [Route("mantenimiento/entidades-financieras/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Entidad Financiera";

            return PartialView("_RegistrarEntidadFinanciera", new EntidadFinancieraRegistroViewModel());
        }

        [Route("mantenimiento/entidades-financieras/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Clasificador";

            return PartialView("_RegistrarEntidadFinanciera", _entidadFinanciera.Find(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _entidadFinanciera.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("", ""));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(EntidadFinancieraRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _entidadFinanciera.Save(model, WebSecurity.CurrentUserId);
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