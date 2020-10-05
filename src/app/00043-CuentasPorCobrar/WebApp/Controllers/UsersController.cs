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
    public class UsersController : Controller
    {
        public readonly UsersModel _usersModel;

        public UsersController()
        {
            _usersModel = new UsersModel();
        }

        // GET: Users
        [HttpGet]
        public ActionResult Index()
        {
            ViewBag.Title = "Usuarios";
            var model = _usersModel.Find();

            return View();
        }

        public ActionResult Add()
        {
            ViewBag.Title = "Agregar Usuario";

            return PartialView("_CorreoRegistrarCuenta");
        }


        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Usuario";
            var model = _usersModel.Find(id);

            return PartialView("_CorreoRegistrarCuenta", model);
        }


        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _usersModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("", ""));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(UserRegisterViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _usersModel.Save(model, WebSecurity.CurrentUserId);
            }
            else
            {
                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos");
            }

            return PartialView("_MsgPartialWR", result);
        }

    }
}