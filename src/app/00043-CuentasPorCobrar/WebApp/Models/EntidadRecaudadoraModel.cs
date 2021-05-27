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
    public class EntidadRecaudadoraModel
    {
        private readonly IEntidadRecaudadora _entidadRecaudadora;
        public EntidadRecaudadoraModel()
        {
            _entidadRecaudadora = new EntidadRecaudadora();
        }

        public List<EntidadRecaudadoraViewModel> Find()
        {
            List<EntidadRecaudadoraViewModel> result = new List<EntidadRecaudadoraViewModel>();

            foreach (var item in _entidadRecaudadora.Find())
            {
                result.Add(new EntidadRecaudadoraViewModel(item));
            }

            return result;
        }

        public List<EntidadRecaudadoraViewModel> Find(bool enabled)
        {
            List<EntidadRecaudadoraViewModel> result = new List<EntidadRecaudadoraViewModel>();

            foreach (var item in _entidadRecaudadora.Find().Where(x => x.Habilitado == enabled))
            {
                result.Add(new EntidadRecaudadoraViewModel(item));
            }

            return result;
        }

        public EntidadRecaudadoraRegistroViewModel Find(int entidadFinancieraId)
        {
            return new EntidadRecaudadoraRegistroViewModel(_entidadRecaudadora.Find(entidadFinancieraId));
        }

        public Response ChangeState(int entidadFinancieraId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _entidadRecaudadora.ChangeState(entidadFinancieraId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }


        public Response Save(EntidadRecaudadoraRegistroViewModel model, int currentUserId)
        {
            EntidadRecaudadora entidadFinanciera = new EntidadRecaudadora()
            {
                Id = model.Id.HasValue ? model.Id.Value : 0,
                Nombre = model.NombreEntidad,
                Habilitado = model.Habilitado,
                ArchivosEntidad = model.HabilitarArchivos,
                FechaActualiza =  DateTime.Now
            };

            Response result = _entidadRecaudadora.Save(entidadFinanciera, currentUserId, (entidadFinanciera.Id == 0 ? SaveOption.Insert : SaveOption.Update));

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
            Response result = _entidadRecaudadora.HabilitarArchivos(entidadFinancieraId, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }

    }
}