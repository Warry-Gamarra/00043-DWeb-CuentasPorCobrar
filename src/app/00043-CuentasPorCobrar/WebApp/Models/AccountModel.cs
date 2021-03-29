using CL_CustomMail;
using Helpers = Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Domain.Entities;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Models
{
    public class AccountModel
    {
        private readonly User _user;
        private readonly CorreoAplicacion _correoAplicacion;

        public AccountModel()
        {
            _user = new User();
            _correoAplicacion = new CorreoAplicacion();
        }


        public Helpers.Response SendPasswordTokenMail(ResetPasswordViewModel model, string link)
        {
            var result = new Helpers.Response();

            var usuario = _user.Find().Find(x => x.UserName == model.UserName);
            var correo = _correoAplicacion.Find().SingleOrDefault(x => x.Enabled);

            if (!string.IsNullOrEmpty(usuario.Person.correo) && correo != null)
            {

                ServerSettings _settings = new ServerSettings() { hostName = correo.HostName, port = correo.Port, sllEnabled = true };
                From_Credentials _from = new From_Credentials() { addressFrom = correo.Address, passwordFrom = correo.Password };

                To_Information _to = new To_Information();

                _to.addressesTo.Add(usuario.Person.correo);
                _to.fileAttachedPath = "";
                _to.MailSubject = "OCEF - Restablecimiento de contraseña - Token de verificación";


                BodyComponents _component = new BodyComponents();

                _component.urlLogo = "https://unfvpe-my.sharepoint.com/personal/desarrollo_ceuci_unfv_edu_pe/_layouts/15/guestaccess.aspx?docid=1b894f118cca14633a3f5f25894c3383a&authkey=AfDpUW9qeUtxeWLEWtFChQ4";
                _component.urlHeaderImgBg = "https://unfvpe-my.sharepoint.com/personal/desarrollo_ceuci_unfv_edu_pe/_layouts/15/guestaccess.aspx?docid=064ec5cc25b0c4fd79a91633510de3fdb&authkey=AdaPspODafSuu6h58WLzDTY";
                _component.subjectText = "Restablecimiento de contraseña - Token de verificación";
                _component.h1HeaderTitle = "Oficina Central de Economico Financiero";
                _component.h2HeaderTitle = "Oficina de Tesorería";
                _component.mainContent.Title = "Estimado(a): " + usuario.Person.Nombre;
                _component.mainContent.Text = "<p>Se ha generado una solicitud para la recuperación de la contraseña de su usuario " + model.UserName + 
                                                "</p><p>Para acceder a la aplicación y obtener una nueva contraseña presione el boton que aparece en la parte inferior del mensaje. Si usted no ha realizado ninguna solicitud ignore el mensaje </p>";
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
                    result.Message = "La solicitud fue generada y las instrucciones para la recuperación enviada al correo electrónico " + usuario.Person.correo;
                    result.Icon = "fa fa-check-circle";
                    result.Color = "success";
                }
                else
                {
                    string detalle = result.Message;
                    result.Message = "Ocurrió un error al intentar en enviar el correo electrónico. " + detalle;
                    result.Icon = "fa fa-times-circle";
                    result.Color = "danger";
                }
            }
            else
            {
                result.Message = "<b>Ha ocurrido un error en el proceso</b>&nbsp;<br />" +
                                 "<p class=\"text-justify\">El usuario <b>" + usuario.UserName + "</b> no tiene una cuenta de correo registrada en la aplicación o no se ha encontrado un correo habilitado para realizar esta acción.<br />Por favor, comuníquese con el administrador para el restablecimiento de la contraseña.</p>";
                result.Icon = "fa fa-exclamation-circle";
                result.Color = "warning";
            }
            return result;
        }


        public Helpers.Response ResetPassword(int UserID, string token, string newpass, bool send, string link)
        {
            var result = new Helpers.Response();

            if (WebSecurity.ResetPassword(token, newpass))
            {
                var usuario = _user.Get(UserID);

                if (send)
                {
                    var correo = _correoAplicacion.Find().SingleOrDefault(x => x.Enabled);

                    if (!string.IsNullOrEmpty(usuario.Person.correo) && correo != null)
                    {
                        ServerSettings _settings = new ServerSettings() { hostName = correo.HostName, port = correo.Port, sllEnabled = true };
                        From_Credentials _from = new From_Credentials() { addressFrom = correo.Address, passwordFrom = correo.Password };

                        To_Information _to = new To_Information();

                        _to.addressesTo.Add(usuario.Person.correo);
                        _to.fileAttachedPath = "";
                        _to.MailSubject = "OCEF - Restablecimiento de contraseña de usuario";


                        BodyComponents _component = new BodyComponents();

                        _component.urlLogo = "https://unfvpe-my.sharepoint.com/personal/desarrollo_ceuci_unfv_edu_pe/_layouts/15/guestaccess.aspx?docid=1b894f118cca14633a3f5f25894c3383a&authkey=AfDpUW9qeUtxeWLEWtFChQ4";
                        _component.urlHeaderImgBg = "https://unfvpe-my.sharepoint.com/personal/desarrollo_ceuci_unfv_edu_pe/_layouts/15/guestaccess.aspx?docid=064ec5cc25b0c4fd79a91633510de3fdb&authkey=AdaPspODafSuu6h58WLzDTY";
                        _component.h1HeaderTitle = "Oficina Central de Economico Financiero";
                        _component.h2HeaderTitle = "Oficina de Tesorería";
                        _component.subjectText = "Restablecimiento de contraseña - Nueva Contraseña";
                        _component.mainContent.Title = "Nueva contraseña para el usuario: " + usuario.UserName;
                        _component.mainContent.Text = "<p>Se ha reestablecido la contraseña de manera exitosa.</p><p>La nueva contraseña es: " + newpass + " </p>";
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
                            result.Message = "La contraseña ha sido modificada y enviada el correo electrónico " + usuario.Person.correo;
                            result.Icon = "fa fa-check-circle";
                            result.Color = "success";
                        }
                        else
                        {
                            string detalle = result.Message;

                            result.Message = "La contraseña fue modificada, pero ocurrió un error al intentar en enviar el correo electrónico. <br /><br />" + detalle;
                            result.Icon = "fa fa-exclamation-circle";
                            result.Color = "warning";
                        }

                    }
                    else
                    {
                        result.Message = "<p><b>Restablecimiento de contraseña - Nueva Contraseña</b></p>&nbsp;<br />" +
                                         "<p class=\"text-justify\">El usuario <b>" + usuario.UserName + "</b> no tiene una cuenta de correo registrada, no ha indicado una dirección a la cual enviar la nueva contraseña o no se ha encontrado un correo habilitado para realizar esta acción..<br />Por favor, tome nota de la contraseña y entréguela al usuario correspondiente.</p>" +
                                         "<ul class=\"pull-left\">" +
                                            "<li class=\"text-left\">El Nombre de usuario es: <b>" + usuario.UserName + "</b></li>" +
                                            "<li class=\"text-left\">La nueva contraseña es: <b>" + newpass + "</b> </li>" +
                                         "</ul>";
                        result.Icon = "fa fa-exclamation-circle";
                        result.Color = "warning";
                    }
                }
                else
                {
                    result.Message = "<p><b>Restablecimiento de contraseña - Nueva Contraseña</b></p>&nbsp;<br />" +
                                     "<p class=\"text-justify\">Ha decidido no enviar la contraseña por correo al usuario " + usuario.UserName + ".<br />Por favor, tome nota de la contraseña y entréguela al usuario correspondiente.</p>" +
                                     "<ul class=\"pull-left\">" +
                                        "<li class=\"text-left\">El Nombre de usuario es: <b>" + usuario.UserName + "</b></li>" +
                                        "<li class=\"text-left\">La nueva contraseña es: <b>" + newpass + "</b> </li>" +
                                     "</ul>";
                    result.Icon = "fa fa-exclamation-circle";
                    result.Color = "warning";
                }

            }
            else
            {
                string detalle = result.Message;
                result.Message = "Ocurrió un error al cambiar la contraseña. La contraseña no pudo ser modificada. <br /><br />" + detalle;
                result.Icon = "fa fa-times-circle";
                result.Color = "danger";
            }

            return result;
        }

    }
}