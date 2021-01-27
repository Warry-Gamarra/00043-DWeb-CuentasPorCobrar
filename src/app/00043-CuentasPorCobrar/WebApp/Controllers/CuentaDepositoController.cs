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
    public class CuentaDepositoController : Controller
    {
        public readonly CuentaDepositoModel _cuentaDeposito;
        public readonly EntidadFinancieraModel _entidadFinanciera;

        public CuentaDepositoController()
        {
            _cuentaDeposito = new CuentaDepositoModel();
            _entidadFinanciera = new EntidadFinancieraModel();
        }


        [Route("configuracion/cuentas-deposito")]
        public ActionResult Index()
        {
            ViewBag.Title = "Cuentas de depósito";

            return View(_cuentaDeposito.Find());
        }

        [Route("configuracion/cuentas-deposito/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Cuenta de Depósito";
            ViewBag.EntidadFinanciera = new SelectList(_entidadFinanciera.Find(), "Id", "NombreEntidad");

            return PartialView("_RegistrarCuentaDeposito", new CuentaDepositoRegistroViewModel());
        }

        [Route("configuracion/cuentas-deposito/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Cuenta de Depósito";
            ViewBag.EntidadFinanciera = new SelectList(_entidadFinanciera.Find(), "Id", "NombreEntidad");

            return PartialView("_RegistrarCuentaDeposito", _cuentaDeposito.Find(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _cuentaDeposito.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "CuentaDeposito"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult Save(CuentaDepositoRegistroViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _cuentaDeposito.Save(model, WebSecurity.CurrentUserId);
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