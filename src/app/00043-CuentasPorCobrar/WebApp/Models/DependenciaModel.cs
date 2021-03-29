using Domain.Helpers;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class DependenciaModel
    {
        private readonly IDependencia _dependencia;

        public DependenciaModel()
        {
            _dependencia = new Dependencia();
        }

        public List<DependenciaViewModel> Find()
        {
            var result = new List<DependenciaViewModel>();

            foreach (var item in _dependencia.Find())
            {
                result.Add(new DependenciaViewModel(item));
            }

            return result;
        }

        public DependenciaRegistroViewModel Find(int dependenciaId)
        {
            var model = _dependencia.Find(dependenciaId);

            return new DependenciaRegistroViewModel(model);
        }

        public Response ChangeState(int depemdemciaId, bool stateValue, int currentUserId, string returnUrl)
        {
            Response result = _dependencia.ChangeState(depemdemciaId, stateValue, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }

        public Response Save(DependenciaRegistroViewModel model, int currentUserId)
        {
            Dependencia dependencia = new Dependencia()
            {
                Id = model.DependenciaID,
                Descripcion = model.DependDesc,
                Codigo = model.CodDep,
                CodigoPl = model.CodDepPL,
                Abreviatura = model.DependAbrev,
            };

            Response result = _dependencia.Save(dependencia, currentUserId, (model.DependenciaID.HasValue ? SaveOption.Update : SaveOption.Insert));

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