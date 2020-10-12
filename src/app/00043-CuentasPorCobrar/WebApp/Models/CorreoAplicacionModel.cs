using Domain.DTO;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class CorreoAplicacionModel
    {
        private readonly ICorreoAplicacion _correoAplicacion;
        public CorreoAplicacionModel()
        {
            _correoAplicacion = new CorreoAplicacion();
        }

        public List<CorreoAplicacionViewModel> Find()
        {
            List<CorreoAplicacionViewModel> result = new List<CorreoAplicacionViewModel>();

            foreach (var item in _correoAplicacion.Find())
            {
                result.Add(new CorreoAplicacionViewModel(item));
            }

            return result;
        }

        public CorreoAplicacionViewModel Find(int mailId)
        {
            return new CorreoAplicacionViewModel(_correoAplicacion.Find(mailId));
        }

        public Response ChangeState(int corcorreoAplicacionId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _correoAplicacion.ChangeState(corcorreoAplicacionId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }

        public Response Save(CorreoAplicacionViewModel correoAplicacionViewModel, int currentUserId)
        {
            CorreoAplicacion correoAplicacion = new CorreoAplicacion
            {
                Id = correoAplicacionViewModel.MailId.HasValue ? correoAplicacionViewModel.MailId.Value : 0,
                Address = correoAplicacionViewModel.MailAddress,
                Password = correoAplicacionViewModel.Password,
                SecurityType = correoAplicacionViewModel.SecurityType,
                Port = correoAplicacionViewModel.PortNumber,
                HostName = correoAplicacionViewModel.HostName,
                FecUpdated = DateTime.Now
            };

            Response result = _correoAplicacion.Save(correoAplicacion, currentUserId, (correoAplicacion.Id == 0 ? SaveOption.Insert: SaveOption.Update));

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(true);
            }
            return result;
        }
    }
}