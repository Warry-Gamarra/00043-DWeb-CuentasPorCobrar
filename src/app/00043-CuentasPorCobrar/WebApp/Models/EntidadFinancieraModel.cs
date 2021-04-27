using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Domain.Helpers;
using Domain.Entities;
using Domain.Services;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class EntidadFinancieraModel
    {
        private readonly IEntidadFinanciera _entidadFinanciera;
        public EntidadFinancieraModel()
        {
            _entidadFinanciera = new EntidadFinanciera();
        }

        public List<EntidadFinancieraViewModel> Find()
        {
            List<EntidadFinancieraViewModel> result = new List<EntidadFinancieraViewModel>();

            foreach (var item in _entidadFinanciera.Find())
            {
                result.Add(new EntidadFinancieraViewModel(item));
            }

            return result;
        }

        public List<EntidadFinancieraViewModel> Find(bool enabled)
        {
            List<EntidadFinancieraViewModel> result = new List<EntidadFinancieraViewModel>();

            foreach (var item in _entidadFinanciera.Find().Where(x => x.Habilitado == enabled))
            {
                result.Add(new EntidadFinancieraViewModel(item));
            }

            return result;
        }

        public EntidadFinancieraRegistroViewModel Find(int entidadFinancieraId)
        {
            return new EntidadFinancieraRegistroViewModel(_entidadFinanciera.Find(entidadFinancieraId));
        }

        public Response ChangeState(int entidadFinancieraId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _entidadFinanciera.ChangeState(entidadFinancieraId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }


        public Response Save(EntidadFinancieraRegistroViewModel model, int currentUserId)
        {
            EntidadFinanciera entidadFinanciera = new EntidadFinanciera()
            {
                Id = model.Id.HasValue ? model.Id.Value : 0,
                Nombre = model.NombreEntidad,
                Habilitado = model.Habilitado,
                ArchivosEntidad = model.HabilitarArchivos,
                FechaActualiza =  DateTime.Now
            };

            Response result = _entidadFinanciera.Save(entidadFinanciera, currentUserId, (entidadFinanciera.Id == 0 ? SaveOption.Insert : SaveOption.Update));

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


        public Response HabilitarArchivos(int entidadFinancieraId, int currentUserId, string returnUrl)
        {
            Response result = _entidadFinanciera.HabilitarArchivos(entidadFinancieraId, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }

    }
}