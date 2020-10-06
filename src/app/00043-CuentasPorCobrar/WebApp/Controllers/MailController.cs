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
    public class MailController : Controller
    {
        public readonly MailApplicationModel _mailApplicationModel;

        public MailController()
        {
            _mailApplicationModel = new MailApplicationModel();
        }

        // GET: Mail
        public ActionResult Index()
        {
            ViewBag.Title = "Correos";
            var model = _mailApplicationModel.Find();
            return View();
        }


        public ActionResult Add()
        {
            ViewBag.Title = "Agregar Cuenta";

            return PartialView("_CorreoRegistrarCuenta");
        }


        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Cuenta";
            var model = _mailApplicationModel.Find(id);

            return PartialView("_CorreoRegistrarCuenta", model);
        }


        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _mailApplicationModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("",""));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(MailApplicationViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _mailApplicationModel.Save(model, WebSecurity.CurrentUserId);
            }
            else
            {
                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos");
            }

            return PartialView("_MsgPartialWR", result);
        }

    }
}