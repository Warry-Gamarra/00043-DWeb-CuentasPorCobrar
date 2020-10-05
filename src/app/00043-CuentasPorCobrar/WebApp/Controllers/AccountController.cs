using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class AccountController : Controller
    {
        private ActionResult RedirectToLocal(string returnUrl)
        {
            if (Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }
            else
            {
                return RedirectToAction("Dashboard", "Home");
            }
        }

        [AllowAnonymous]
        public ActionResult Index()
        {
            return RedirectToAction("Login");
        }

        [AllowAnonymous]
        public ActionResult Login(string returnUrl)
        {
            if (User.Identity.IsAuthenticated)
            {
                return RedirectToAction("Index", "Home");
            }

            if (!Roles.RoleExists("Administrador"))
                Roles.CreateRole("Administrador");

            //Creamos el usuario
            if (!WebSecurity.UserExists("administrador"))
            {
                WebSecurity.CreateUserAndAccount("administrador", "admin@OCBU", new { B_CambiaPassword = false, B_Habilitado = true });

                if (!Roles.GetRolesForUser("administrador").Contains("Administrador"))
                    Roles.AddUsersToRoles(new[] { "administrador" }, new[] { "Administrador" });
            }

            ViewBag.ReturnUrl = returnUrl;
            return View();
        }

        public ActionResult LogOut()
        {
            WebSecurity.Logout();

            return RedirectToAction("Login", "Account");
        }


        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginViewModel model, string returnUrl)
        {
            if (User.Identity.IsAuthenticated)
            {
                WebSecurity.Logout();
            }

            if (WebSecurity.UserExists(model.UserName))
            {
                //if (!Roles.IsUserInRole(model.UserName, "Operador de Cafetería"))
                //{
                //    var usuario = BL_Users.ObtenerEstadoUsuario(model.UserName);
                //    if (usuario.habilitado)
                //    {
                if (ModelState.IsValid && WebSecurity.Login(model.UserName, model.Password, persistCookie: model.RememberMe))
                {
                    //if (usuario.actualizaPassword)
                    //{
                    //    return RedirectToAction("ActualizarPassword", "Account");
                    //}
                    //else
                    //{
                        return RedirectToLocal(returnUrl);
                    //}
                }
                ModelState.AddModelError("", "La contraseña es incorrecta.");
                return View(model);
                //    }
                //    ModelState.AddModelError("", "La cuenta se encuentra deshabilitada temporalmente. Si el problema persiste comuníquese con el administrador del sistema.");
                //    return View(model);
                //}
                //ModelState.AddModelError("", "La cuenta de usuario no tiene permisos para accesder a este módulo.");
                //return View(model);
            }
            ModelState.AddModelError("", "El nombre de usuario no existe.");
            return View(model);
        }


        [AllowAnonymous]
        public ActionResult RecuperarPassword()
        {
            return PartialView("_ResetPassword");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        [AllowAnonymous]
        public ActionResult RecuperarPassword(ResetPasswordViewModel model)
        {
            var result = new Response();

            if (WebSecurity.UserExists(model.UserName))
            {
                var s_token = WebSecurity.GeneratePasswordResetToken(model.UserName);
                //result = BL_Accounts.SendPasswordTokenMail(model, Url.Action("ResetPassword", "Account", new { token = s_token }, "http"));

                result.CurrentID = "display:none;";
            }
            else
            {
                ResponseModel.Warning(result, "El usuario ingresado no existe.", false);
            }

            return PartialView("_MsgPartial", result);
        }


        [AllowAnonymous]
        public ActionResult ResetPassword(string token)
        {
            int TokenOwnerID = WebSecurity.GetUserIdFromPasswordResetToken(token);

            if (TokenOwnerID != -1)
            {
                ViewBag.Token = token;
                //ViewBag.Usuario = BL_Users.ObtenerUsuarios(TokenOwnerID).usuario;
                return View();
            }
            else
            {
                return RedirectToAction("Index", "Home", new { area = "" });
            }

        }


        [HttpPost]
        [AllowAnonymous]
        public ActionResult TokenResetPassword(string ReturnToken, ChangePasswordViewModel model)
        {
            var result = new Response();

            int TokenOwnerID = WebSecurity.GetUserIdFromPasswordResetToken(ReturnToken);

            if (TokenOwnerID != 0)
            {
                try
                {
                    //result = BL_Accounts.ResetPassword(TokenOwnerID, ReturnToken, model.NewPassword, true, Url.Action("Index", "Home", new { area = "" }, "http"));
                    result.CurrentID = "display:none;";
                }
                catch (Exception ex)
                {
                    ResponseModel.Error(result, ex.Message, false);
                }
            }
            else
            {
                ResponseModel.Error(result, 
                    "No se encontró ninguna coincidencia para el enlace generado. Intente solicitar uno nuevo", 
                    false);

            }

            return PartialView("_MsgModalBodyPartial", result);
        }

    }
}