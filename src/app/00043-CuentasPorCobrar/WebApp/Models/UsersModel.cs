using Domain.Helpers;
using Domain.Services;
using Domain.Entities;
using Helpers = Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;
using CL_CustomMail;
using System.Configuration;

namespace WebApp.Models
{

    public class UsersModel
    {
        private readonly IUser _user;
        private readonly CorreoAplicacion _correoAplicacion;
        private readonly string appName;

        public UsersModel()
        {
            _user = new User();
            _correoAplicacion = new CorreoAplicacion();
            appName = ConfigurationManager.AppSettings["AppName"];
        }

        public List<UserViewModel> Find()
        {
            List<UserViewModel> result = new List<UserViewModel>();

            foreach (var item in _user.Find())
            {
                result.Add(new UserViewModel(item));
            }

            return result;
        }

        public UserRegisterViewModel Find(int userId)
        {
            return new UserRegisterViewModel(_user.Get(userId));
        }

        public Helpers.Response GetUserState(string username)
        {
            return _user.GetUserState(username);
        }


        public Helpers.Response ChangeState(int userId, bool stateValue, int currentUserId, string returnUrl)
        {
            User userRegister = new User()
            {
                UserId = userId,
                Enabled = stateValue
            };

            Helpers.Response result = _user.ChangeState(userRegister, currentUserId);
            result.Action = returnUrl;

            if (result.Value)
            {
                ResponseModel.Success(result, string.Empty, false);
            }
            else
            {
                ResponseModel.Error(result);
            }

            return result;
        }

        public Helpers.Response Save(UserRegisterViewModel userRegisterViewModel, int currentUserId, string urlLink = "")
        {
            User user = new User()
            {
                UserId = userRegisterViewModel.UserId,
                UserName = userRegisterViewModel.UserName,
                Person = new Persona()
                {
                    Id = userRegisterViewModel.PersonId,
                    Nombre = userRegisterViewModel.PersonName,
                    correo = userRegisterViewModel.Email,
                },
                Rol = new RolAplicacion()
                {
                    Id = userRegisterViewModel.RoleId,
                },
                Dependencia = new Dependencia()
                {
                    Id = userRegisterViewModel.DependenciaId
                }
            };

            Helpers.Response result = _user.Save(user, currentUserId, userRegisterViewModel.UserId.HasValue ? SaveOption.Update : SaveOption.Insert);

            if (result.Value)
            {
                if (string.IsNullOrEmpty(urlLink))
                {
                    result.Success(false);
                }
                else
                {
                    return SendMailNewAccount(user, result.CurrentID, urlLink);
                }
            }
            else
            {
                result.Error(true);
            }

            return result;
        }


        private Helpers.Response SendMailNewAccount(User usuario, string newPassword, string link)
        {
            var result = new Helpers.Response();

            var correo = _correoAplicacion.Find().SingleOrDefault(x => x.Enabled);

            if (!string.IsNullOrEmpty(usuario.Person.correo) && correo != null)
            {
                ServerSettings _settings = new ServerSettings() { hostName = correo.HostName, port = correo.Port, sllEnabled = true };
                From_Credentials _from = new From_Credentials() { addressFrom = correo.Address, passwordFrom = correo.Password };

                To_Information _to = new To_Information();

                _to.addressesTo.Add(usuario.Person.correo);
                _to.fileAttachedPath = "";
                _to.MailSubject = "OCEF - " + appName + " - Creación de cuenta de usuario";


                BodyComponents _component = new BodyComponents();

                _component.urlLogo = "";
                _component.urlHeaderImgBg = "";
                _component.h1HeaderTitle = "Oficina Central de Economico Financiero";
                _component.h2HeaderTitle = "Oficina de Tesorería";
                _component.subjectText = appName + " - Creación de cuenta de usuario";
                _component.mainContent.Title = "Estimado(a): " + usuario.Person.Nombre;
                _component.mainContent.Text = "<p>Le ha sido habilitada una cuenta de usuario en el sistema con la siguiente información: </p>" +
                                                "<ul>" +
                                                    "<li>Usuario      : <b>" + usuario.UserName + "</b></li>" +
                                                    "<li>Contraseña   : <b>" + newPassword + "</b></li>" +
                                                "</ul><br />" +
                                             "<p><b>NOTA:</b> Al ingresar el sistema por primera vez procure cambiar esta contraseña por una más facil de recordar.</p>"; ;
                _component.Column1.Title = "";
                _component.Column1.Text = "";
                _component.Column2.Title = "";
                _component.Column2.Text = "";
                _component.ImgContent1.Title = "";
                _component.ImgContent1.Text = "";
                _component.ImgContent1.Image = "";
                _component.ImgContent2.Title = "";
                _component.ImgContent2.SubTitle = "";
                _component.ImgContent2.Text = "";
                _component.ImgContent2.Image = "";
                _component.actionButton.Title = "Ir a la aplicación";
                _component.actionButton.Text = link;
                _component.footerAddress = "";
                _component.footerPhone = "";
                _component.footerEmail = "";

                CustomMail target = new CustomMail(_component, true);

                var responseMail = target.SendMail(_settings, _from, _to, target.MailBody, target.IsHtml);

                result = new Helpers.Response()
                {
                    Value = responseMail.IsDone,
                    Message = responseMail.Message
                };

                if (result.Value)
                {
                    result.Message = "La cuenta de usuario fue generada y los datos de la cuenta e instrucciones enviadas al correo electrónico " + usuario.Person.correo;
                    result.Icon = "fa fa-check-circle";
                    result.Color = "success";
                    result.CurrentID = "display: none;";
                }
                else
                {
                    string detalle = result.Message;

                    result.Message = "La cuenta de usuario ha sido creada pero ocurrió un error al intentar en enviar el correo electrónico. <br /><br />" + detalle;
                    result.Icon = "fa fa-exclamation-circle";
                    result.Color = "warning";
                    result.CurrentID = "display: show;";
                }

            }
            else
            {
                result.Message = "<p><b>Creación de usuario </b></p>&nbsp;<br />" +
                                 "<p class=\"text-justify\">El usuario <b>" + usuario.UserName + "</b> no tiene una cuenta de correo registrada, no ha indicado una dirección a la cual enviar la nueva contraseña o no se ha encontrado un correo habilitado para realizar esta acción..<br />Por favor, tome nota de la contraseña y entréguela al usuario correspondiente.</p>" +
                                 "<ul class=\"pull-left\">" +
                                    "<li class=\"text-left\">El Nombre de usuario es: <b>" + usuario.UserName + "</b></li>" +
                                    "<li class=\"text-left\">La Contraseña es: <b>" + newPassword + "</b> </li>" +
                                 "</ul>";
                result.Icon = "fa fa-exclamation-circle";
                result.Color = "warning";
                result.CurrentID = "display: none;";
            }

            return result;
        }

    }
}