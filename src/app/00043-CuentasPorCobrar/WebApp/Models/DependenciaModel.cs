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

        public List<DependenciaViewModel> Find(int annexeId)
        {
            var result = new List<DependenciaViewModel>();


            return result;
        }

        public Response ChangeState(int annexeId, bool stateValue, string returnUrl)
        {
            var result = new Response();


            return result;
        }

        public Response Save(DependenciaViewModel annexeViewModel, int currentUserId)
        {
            var result = new Response();


            return result;
        }

        internal object ChangeState(int rowID, bool b_habilitado, int currentUserId, string v)
        {
            throw new NotImplementedException();
        }
    }
}