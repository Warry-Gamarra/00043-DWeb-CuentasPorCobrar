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
    public class EntidadFinancieraController : Controller
    {
        public readonly EntidadFinancieraModel _entidadFinanciera;
        public readonly CuentaDepositoModel _cuentaDeposito;
        public readonly SelectModels _selectModels;

        public EntidadFinancieraController()
        {
            _entidadFinanciera = new EntidadFinancieraModel();
            _selectModels = new SelectModels();
            _cuentaDeposito = new CuentaDepositoModel();
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
            ViewBag.Title = "Agregar entidad financiera";

            return PartialView("_RegistrarEntidadFinanciera", new EntidadFinancieraRegistroViewModel());
        }

        [Route("mantenimiento/entidades-financieras/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar entidad financiera";

            return PartialView("_RegistrarEntidadFinanciera", _entidadFinanciera.Find(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _entidadFinanciera.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "EntidadFinanciera"));

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

        public JsonResult HabilitarArchivos(int RowID)
        {
            var result = _entidadFinanciera.HabilitarArchivos(RowID, WebSecurity.CurrentUserId, Url.Action("Banco", "EstructuraArchivo", new { id = RowID }));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [Route("mantenimiento/entidades-financieras/{id}/{banco}/numeros-de-cuenta")]
        public ActionResult CuentasDeposito(int id, string banco)
        {
            ViewBag.Title = $"Números de cuenta: { banco }";

            return PartialView("_CuentasBanco",_cuentaDeposito.Find().Where(x => x.EntidadFinancieraId == id));
        }

    }
}