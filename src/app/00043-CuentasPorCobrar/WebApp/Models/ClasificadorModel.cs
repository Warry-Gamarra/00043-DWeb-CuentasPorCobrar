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
        private readonly IClasificadorEquivalencia _clasificadorEquivalencia;

        public ClasificadorModel()
        {
            _clasificadores = new ClasificadorPresupuestal();
            _clasificadorEquivalencia = new ClasificadorEquivalencia();
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

        public Response Save(ClasificadorRegistrarViewModel clasificadorViewModel, int currentUserId)
        {
            ClasificadorPresupuestal clasificadorPresupuestal = new ClasificadorPresupuestal()
            {
                Id = clasificadorViewModel.Id.HasValue ? clasificadorViewModel.Id.Value : 0,
                TipoTransCod = clasificadorViewModel.TipoTransaccion.ToString(),
                GenericaCod = clasificadorViewModel.Generica.ToString(),
                SubGeneCod = clasificadorViewModel.SubGenerica.HasValue ? clasificadorViewModel.SubGenerica.Value.ToString() : null,
                EspecificaCod = clasificadorViewModel.Especifica.HasValue ? clasificadorViewModel.Especifica.Value.ToString() : null,
                Descripcion = clasificadorViewModel.Descripcion.ToUpper(),
                DescripDetalle = clasificadorViewModel.DescripDetalle.ToUpper(),
                Habilitado = true,
                FecUpdated = DateTime.Now
            };

            Response result = _clasificadores.Save(clasificadorPresupuestal, currentUserId, (clasificadorPresupuestal.Id == 0 ? SaveOption.Insert : SaveOption.Update));

            if (result.Value)
            {
                if (result.Value)
                {

                }
                result.Success(false);
            }
            else
            {
                result.Error(true);
            }
            return result;
        }


        public List<ClasificadorEquivalenciaViewModel> FindEquivalencias(int clasificadorId)
        {
            List<ClasificadorEquivalenciaViewModel> result = new List<ClasificadorEquivalenciaViewModel>();

            foreach (var item in _clasificadorEquivalencia.Find(clasificadorId))
            {
                result.Add(new ClasificadorEquivalenciaViewModel()
                {
                    ClasificadorId = item.ClasificadorId,
                    ClasificadorEquivId = item.ClasificadorEquivId,
                    ConceptoEquivDesc = item.ConceptoEquivDesc,
                    ConceptoEquivCod = item.ConceptoEquivCod,
                    Habilitado = item.Habilitado
                });
            }

            return result;
        }

        public List<ClasificadorEquivalenciaViewModel> FindEquivalencias(string anio)
        {
            List<ClasificadorEquivalenciaViewModel> result = new List<ClasificadorEquivalenciaViewModel>();

            foreach (var item in _clasificadorEquivalencia.Find(anio))
            {
                result.Add(new ClasificadorEquivalenciaViewModel()
                {
                    ClasificadorId = item.ClasificadorId,
                    ClasificadorEquivId = item.ClasificadorEquivId,
                    ConceptoEquivDesc = item.ConceptoEquivDesc,
                    ConceptoEquivCod = item.ConceptoEquivCod,
                    Habilitado = item.Habilitado
                });
            }

            return result;
        }

        public List<ClasificadorEquivalenciaViewModel> FindEquivalencias(int clasificadorId, string anio)
        {
            List<ClasificadorEquivalenciaViewModel> result = new List<ClasificadorEquivalenciaViewModel>();

            foreach (var item in _clasificadorEquivalencia.Find(clasificadorId, anio))
            {
                result.Add(new ClasificadorEquivalenciaViewModel()
                {
                    ClasificadorId = item.ClasificadorId,
                    ClasificadorEquivId = item.ClasificadorEquivId,
                    ConceptoEquivDesc = item.ConceptoEquivDesc,
                    ConceptoEquivCod = item.ConceptoEquivCod,
                    Habilitado = item.Habilitado
                });
            }

            return result;
        }


        public Response SaveEquivalencia(ClasificadorEquivalenciaViewModel model, int anio, int currentUserId, bool saveAnio)
        {
            ClasificadorEquivalencia clasificadorEquivalencia = new ClasificadorEquivalencia
            {
                ClasificadorEquivId = model.ClasificadorEquivId ?? 0,
                ConceptoEquivCod = model.ConceptoEquivCod,
                ClasificadorId = model.ClasificadorId,
            };

            Response result = _clasificadorEquivalencia.Save(clasificadorEquivalencia, currentUserId, (model.ClasificadorEquivId.HasValue ? SaveOption.Update : SaveOption.Insert));

            if (result.Value && saveAnio)
            {
                result = SaveEquivalenciaAnio(int.Parse(result.CurrentID), anio.ToString(), true, currentUserId);
            }

            return result;
        }

        public Response SaveEquivalenciaAnio(int equivalenciaId, string anio, bool currentState, int currentUserId)
        {
            ClasificadorEquivalencia clasificadorEquivalencia = new ClasificadorEquivalencia()
            {
                ClasificadorEquivId = equivalenciaId,
                Habilitado = currentState
            };

            var clasificadorEquivalenciaAnio = _clasificadorEquivalencia.Find(anio).Where(x => x.ClasificadorEquivId == equivalenciaId);

            Response result = _clasificadorEquivalencia.SaveAnio(clasificadorEquivalencia, anio, currentUserId, (clasificadorEquivalenciaAnio.Count() == 0 ? SaveOption.Insert : SaveOption.Update));

            return result;
        }


        public Response SaveEquivalenciaAnio(ClonarEquivalenciasClasificadorViewModel model, int currentUserId)
        {

            Response result = new Response();

            var clasificadoresEquivalenciaAnioDestino = _clasificadorEquivalencia.Find(model.AnioDestino);
            var clasificadoresEquivalenciaAnioOrigen = _clasificadorEquivalencia.Find(model.AnioOrigen);

            foreach (var item in clasificadoresEquivalenciaAnioDestino)
            {
                ClasificadorEquivalencia clasificadorEquivalencia = new ClasificadorEquivalencia()
                {
                    ClasificadorEquivId = item.ClasificadorEquivId,
                    Habilitado = false
                };

                result = _clasificadorEquivalencia.SaveAnio(clasificadorEquivalencia, model.AnioDestino, currentUserId, SaveOption.Update);
            }


            foreach (var item in clasificadoresEquivalenciaAnioOrigen)
            {
                ClasificadorEquivalencia clasificadorEquivalencia = new ClasificadorEquivalencia()
                {
                    ClasificadorEquivId = item.ClasificadorEquivId,
                    Habilitado = item.Habilitado
                };

                result = _clasificadorEquivalencia.SaveAnio(clasificadorEquivalencia, model.AnioDestino, currentUserId, (clasificadoresEquivalenciaAnioDestino.FirstOrDefault(x => x.ClasificadorEquivId == item.ClasificadorEquivId) == null ? SaveOption.Insert : SaveOption.Update));
            }

            if (result.Value)
            {
                result.Message = "Equivalencias de clasificadores copiados correctamente";
                result.Success(false);
            }
            else
            {
                result.Error(false);
            }

            return result;
        }
    }
}