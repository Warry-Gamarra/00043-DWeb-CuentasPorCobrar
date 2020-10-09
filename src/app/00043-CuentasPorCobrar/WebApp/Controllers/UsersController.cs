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
    [Route("Mantenimiento/usuarios/{action}")]
    public class UsersController : Controller
    {
        public readonly UsersModel _usersModel;
        public readonly SelectModels _selectControl;

        public UsersController()
        {
            _usersModel = new UsersModel();
            _selectControl = new SelectModels();
        }

        // GET: Users
        [HttpGet]
        [Route("Mantenimiento/usuarios")]
        public ActionResult Index()
        {
            ViewBag.Title = "Usuarios";
            var model = _usersModel.Find();

            return View("Users", model);
        }


        [Route("Mantenimiento/usuarios/ver/{id}")]
        public ActionResult Show(int id)
        {
            ViewBag.Title = "Detalle Usuario";
            var model = _usersModel.Find(id);

            return PartialView("_DetailUser", model);
        }

        [Route("Mantenimiento/usuarios/nuevo")]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Usuario";
            ViewBag.Roles = new SelectList(_selectControl.GetRoles(), dataValueField: "Value", dataTextField: "TextDisplay");

            UserRegisterViewModel model = new UserRegisterViewModel();
            return PartialView("_RegisterUser", model);
        }

        [Route("Mantenimiento/usuarios/editar/{id}")]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Usuario";
            ViewBag.Roles = new SelectList(_selectControl.GetRoles(), dataValueField: "Value", dataTextField: "TextDisplay");

            var model = _usersModel.Find(id);

            return PartialView("_RegisterUser", model);
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
            ViewBag.Roles = new SelectList(_selectControl.GetRoles(), dataValueField: "Value", dataTextField: "TextDisplay");

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