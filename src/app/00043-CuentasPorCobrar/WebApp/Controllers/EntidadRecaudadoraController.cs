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
    [Authorize(Roles = RoleNames.ADMINISTRADOR)]
    public class EntidadRecaudadoraController : Controller
    {
        public readonly EntidadRecaudadoraModel _entidadRecaudadora;
        public readonly CuentaDepositoModel _cuentaDeposito;
        public readonly SelectModel _selectModels;

        public EntidadRecaudadoraController()
        {
            _entidadRecaudadora = new EntidadRecaudadoraModel();
            _selectModels = new SelectModel();
            _cuentaDeposito = new CuentaDepositoModel();
        }


        [Route("mantenimiento/entidades-recaudadoras")]
        public ActionResult Index()
        {
            ViewBag.Title = "Entidades Recaudadoras";
            var model = _entidadRecaudadora.Find();

            return View(model);
        }

        [Route("mantenimiento/entidades-recaudadoras/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar entidad recaudadora";

            return PartialView("_RegistrarEntidadFinanciera", new EntidadRecaudadoraRegistroViewModel());
        }

        [Route("mantenimiento/entidades-recaudadoras/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar entidad recaudadora";

            return PartialView("_RegistrarEntidadFinanciera", _entidadRecaudadora.Find(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _entidadRecaudadora.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "EntidadRecaudadora"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Save(EntidadRecaudadoraRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _entidadRecaudadora.Save(model, WebSecurity.CurrentUserId);
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
            var result = _entidadRecaudadora.HabilitarArchivos(RowID, WebSecurity.CurrentUserId, Url.Action("Banco", "EstructuraArchivo", new { id = RowID }));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [Route("mantenimiento/entidades-recaudadoras/{id}/{banco}/numeros-de-cuenta")]
        public ActionResult CuentasDeposito(int id, string banco)
        {
            ViewBag.Title = $"Números de cuenta: { banco }";

            return PartialView("_CuentasBanco",_cuentaDeposito.Find().Where(x => x.EntidadFinancieraId == id));
        }

    }
}