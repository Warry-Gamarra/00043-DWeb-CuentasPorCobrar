using Domain.DTO;
using Domain.Entities;
using Domain.Services;
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
        private readonly IUser _users;

        public AccountController()
        {
            _users = new User();
        }


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
                WebSecurity.CreateUserAndAccount("administrador", "admin@OCEF", new { B_CambiaPassword = false, B_Habilitado = true, B_Eliminado = false });

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

            var usuarioResponse = _users.GetUserState(model.UserName);
            if (string.IsNullOrEmpty(usuarioResponse.Message))
            {
                if (ModelState.IsValid && WebSecurity.Login(model.UserName, model.Password, persistCookie: model.RememberMe))
                {
                    return RedirectToLocal(returnUrl);
                }
                else
                {
                    ModelState.AddModelError("", "El nombre de usuario o la contraseña son incorrectos.");
                }
            }
            ModelState.AddModelError("", usuarioResponse.Message);
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


        public ActionResult Perfil()
        {
            return PartialView("_Perfil");
        }


        public ActionResult CambiarPassword()
        {
            return PartialView("_ChangePassword");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CambiarPassword(ChangePasswordViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                try
                {
                    result.Value = WebSecurity.ChangePassword(User.Identity.Name, model.CurrentPassword, model.NewPassword);

                }
                catch (Exception ex)
                {
                    result.Value = false;
                    result.Message = ex.Message;
                }

                if (result.Value)
                {
                    ResponseModel.Success(result, "Contraseña actualizada correctamente.", false);
                }
                else
                {
                    if (string.IsNullOrEmpty(result.Message))
                    {
                        ResponseModel.Error(result, "La valor ingresado en contraseña actual no corresponde a la contraseña actual", true);
                    }
                    else
                    {
                        ResponseModel.Error(result, false);
                    }
                }

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

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos" + details);

            }

            return PartialView("_MsgPartial", result);
        }



        [Authorize(Roles = "Administrador")]
        public ActionResult AdminResetPassword(int id)
        {
            var model = _users.Get(id);
            return PartialView("_AdminResetPassword", model);
        }


        //[HttpPost]
        //[Authorize(Roles = "Administrador")]
        //public ActionResult GrabarAdminResetPassword(UsuarioViewModel model, int rbtnTipReset, string NewPass, bool chkSendMail)
        //{
        //    var result = new ResponseViewModel();

        //    if (WebSecurity.UserExists(model.usuario))
        //    {
        //        string s_token = WebSecurity.GeneratePasswordResetToken(model.usuario);
        //        string newpass = "ocrh@unfv";

        //        switch (rbtnTipReset)
        //        {
        //            case 1:
        //                newpass = RandomPassword.Generate(8, RandomPassword.PASSWORD_CHARS_ALPHANUMERIC);
        //                break;
        //            case 2:
        //                newpass = string.IsNullOrEmpty(NewPass) ? newpass : NewPass;
        //                break;
        //            default:
        //                break;
        //        }

        //        if (!chkSendMail)
        //        {
        //            model.correo = "";
        //        }

        //        result = BL_Accounts.ResetPassword(WebSecurity.GetUserIdFromPasswordResetToken(s_token), s_token, newpass, chkSendMail, Url.Action("ResetPassword", "Account", new { token = s_token }, "http"));

        //        result.CurrentID = "display:none;";
        //    }
        //    else
        //    {
        //        result.color = "danger";
        //        result.icon = "fa-times-circle";
        //        result.message = "No pudo identificarse al usuario.";
        //        result.CurrentID = "display:none;";
        //    }

        //    return PartialView("_MsgModalBodyPartial", result);
        //}


    }
}