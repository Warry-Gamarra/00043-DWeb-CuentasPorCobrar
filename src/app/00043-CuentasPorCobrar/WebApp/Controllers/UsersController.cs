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
    [Route("mantenimiento/usuarios/{action}")]
    public class UsersController : Controller
    {
        public readonly UsersModel _usersModel;
        public readonly SelectModel _selectControl;
        public readonly DependenciaModel _dependenciaModel;

        public UsersController()
        {
            _usersModel = new UsersModel();
            _selectControl = new SelectModel();
            _dependenciaModel = new DependenciaModel();
        }

        // GET: Users
        [HttpGet]
        [Route("mantenimiento/usuarios")]
        public ActionResult Index()
        {
            ViewBag.Title = "Usuarios";
            var model = _usersModel.Find();

            return View("Users", model);
        }


        [Route("mantenimiento/usuarios/ver/{id}")]
        public ActionResult Show(int id)
        {
            ViewBag.Title = "Detalle Usuario";
            var model = _usersModel.Find(id);

            return PartialView("_DetailUser", model);
        }

        [Route("mantenimiento/usuarios/nuevo")]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Usuario";
            ViewBag.Roles = new SelectList(_selectControl.GetRoles(), dataValueField: "Value", dataTextField: "TextDisplay");
            ViewBag.Dependencias = new SelectList(_dependenciaModel.Find(enabled: true), dataValueField: "DependenciaID", dataTextField: "DependDesc");
                 
            UserRegisterViewModel model = new UserRegisterViewModel();
            return PartialView("_RegisterUser", model);
        }

        [Route("mantenimiento/usuarios/editar/{id}")]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Usuario";
            ViewBag.Roles = new SelectList(_selectControl.GetRoles(), dataValueField: "Value", dataTextField: "TextDisplay");
            ViewBag.Dependencias = new SelectList(_dependenciaModel.Find(enabled: true), dataValueField: "DependenciaID", dataTextField: "DependDesc");

            var model = _usersModel.Find(id);

            return PartialView("_RegisterUser", model);
        }


        [HttpPost]
        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _usersModel.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "Users"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(UserRegisterViewModel model)
        {
            Response result = new Response();
            ViewBag.Roles = new SelectList(_selectControl.GetRoles(), dataValueField: "Value", dataTextField: "TextDisplay");

            if (ModelState.IsValid)
            {
                result = _usersModel.Save(model, WebSecurity.CurrentUserId, Url.Action("Login", "Account", null, "http"));
            }
            else
            {
                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos");
            }

            return PartialView("_MsgPartialWR", result);
        }

    }
}