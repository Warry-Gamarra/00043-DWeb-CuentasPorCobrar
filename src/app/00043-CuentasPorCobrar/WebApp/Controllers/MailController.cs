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
    [Route("Mantenimiento/correo-aplicacion/{action}")]
    public class MailController : Controller
    {
        public readonly CorreoAplicacionModel _correoAplicacionModel;

        public MailController()
        {
            _correoAplicacionModel = new CorreoAplicacionModel();
        }

        [Route("Mantenimiento/correo-aplicacion")]
        public ActionResult Index()
        {
            ViewBag.Title = "Correos";
            var model = _correoAplicacionModel.Find();
            return View("Correos", model);
        }


        //[Route("Mantenimiento/correo-aplicacion/nuevo")]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Cuenta";

            return PartialView("_CorreoRegistrarCuenta");
        }


        [Route("Mantenimiento/correo-aplicacion/editar/{id}")]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Cuenta";
            var model = _correoAplicacionModel.Find(id);

            return PartialView("_CorreoRegistrarCuenta", model);
        }


        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _correoAplicacionModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("",""));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(CorreoAplicacionViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _correoAplicacionModel.Save(model, WebSecurity.CurrentUserId);
            }
            else
            {
                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos");
            }

            return PartialView("_MsgPartialWR", result);
        }

    }
}