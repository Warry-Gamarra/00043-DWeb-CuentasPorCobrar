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
            _clasificadores = new ClasificadorPresupuestal();
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
            ClasificadorPresupuestal clasificadorPresupuestal = new ClasificadorPresupuestal()
            {
                Id = clasificadorViewModel.Id.HasValue ? clasificadorViewModel.Id.Value : 0,
                TipoTransCod = clasificadorViewModel.TipoTransaccion.ToString(),
                GenericaCod = clasificadorViewModel.Generica.ToString(),
                SubGeneCod = clasificadorViewModel.SubGenerica.HasValue ? clasificadorViewModel.SubGenerica.Value.ToString(): null,
                EspecificaCod = clasificadorViewModel.Especifica.HasValue ? clasificadorViewModel.Especifica.Value.ToString() : null,
                Descripcion = clasificadorViewModel.Descripcion.ToUpper(),
                DescripDetalle = clasificadorViewModel.DescripDetalle.ToUpper(),
                CodigoUnfv = clasificadorViewModel.CodigoEquivalente,
                //AnioEjercicio = clasificadorViewModel.AnioEjercicio,
                Habilitado = true,
                FecUpdated = DateTime.Now
            };

            Response result = _clasificadores.Save(clasificadorPresupuestal, currentUserId, (clasificadorPresupuestal.Id == 0 ? SaveOption.Insert : SaveOption.Update));

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