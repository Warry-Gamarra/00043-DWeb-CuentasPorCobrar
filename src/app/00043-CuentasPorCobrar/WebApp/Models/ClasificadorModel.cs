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
    public class ClasificadorModel
    {
        private readonly IClasificadores _clasificadores;

        public ClasificadorModel()
        {
            _clasificadores = new ClasificadorDeIngreso();
        }

        public List<ClasificadorViewModel> Find(string anio)
        {
            var result = new List<ClasificadorViewModel>();

            foreach (var item in _clasificadores.Find(anio))
            {
                result.Add(new ClasificadorViewModel(item));
            }

            return result;
        }

        public ClasificadorRegistrarViewModel Find(int clasificadorId)
        {
            return new ClasificadorRegistrarViewModel(_clasificadores.Find(clasificadorId));
        }

        public Response ChangeState(int clasificadorId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _clasificadores.ChangeState(clasificadorId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }


        public Response Save(ClasificadorRegistrarViewModel clasificadorViewModel, int currentUserId)
        {
            ClasificadorDeIngreso clasificadorDeIngreso = new ClasificadorDeIngreso()
            {
                Id = clasificadorViewModel.Id.HasValue ? clasificadorViewModel.Id.Value : 0,
                CodClasificador = clasificadorViewModel.CodClasificador,
                Descripcion = clasificadorViewModel.Descripcion,
                CodigoUnfv = clasificadorViewModel.CodigoEquivalente,
                AnioEjercicio = clasificadorViewModel.AnioEjercicio,
                Habilitado = true,
                FecUpdated = DateTime.Now
            };

            Response result = _clasificadores.Save(clasificadorDeIngreso, currentUserId, (clasificadorDeIngreso.Id == 0 ? SaveOption.Insert : SaveOption.Update));

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