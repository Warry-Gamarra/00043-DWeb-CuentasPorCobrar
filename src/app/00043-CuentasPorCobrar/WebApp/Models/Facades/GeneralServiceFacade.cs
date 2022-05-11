using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class GeneralServiceFacade : IGeneralServiceFacade
    {
        IGeneralService generalService;

        public GeneralServiceFacade()
        {
            generalService = new GeneralService();
        }

        public IEnumerable<SelectViewModel> Listar_Anios()
        {
            var lista = generalService.Listar_Anios();

            var result = lista.Select(a => new SelectViewModel() { Value = a.ToString(), TextDisplay = a.ToString() });

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_TipoEstudios(int? DependenciaID)
        {
            IEnumerable<TipoEstudio> lista;

            if (!DependenciaID.HasValue)
                lista = generalService.Listar_TipoEstudios();
            else if (DependenciaID == DependenciaEUPG.ID)
                lista = generalService.Listar_TipoEstudios().Where(x => x.Equals(TipoEstudio.Posgrado));
            else
                lista = generalService.Listar_TipoEstudios().Where(x => x.Equals(TipoEstudio.Pregrado));

            var result = lista.Select(x => new SelectViewModel() { Value = x.ToString(), TextDisplay = x.ToString() });

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_Horas()
        {
            var lista = generalService.Listar_Horas();

            var result = lista.Select(x => new SelectViewModel()
            {
                Value = x.ToString(),
                TextDisplay = x.ToString("D2")
            });

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_Minutos()
        {
            var lista = generalService.Listar_Minutos();

            var result = lista.Select(x => new SelectViewModel()
            {
                Value = x.ToString(),
                TextDisplay = x.ToString("D2")
            });

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_TipoReporteObligaciones()
        {
            var lista = Reportes.Listar().Select(
                x => new SelectViewModel()
                {
                    Value = x.Key,
                    TextDisplay = x.Value
                });

            return lista;
        }

        public IEnumerable<SelectViewModel> Listar_TipoAlumno()
        {
            var lista = new List<SelectViewModel>();

            lista.Add(new SelectViewModel() { Value = true.ToString(), TextDisplay = "Ingresante" });

            lista.Add(new SelectViewModel() { Value = false.ToString(), TextDisplay = "Regular" });

            return lista;

        }

        public IEnumerable<SelectViewModel> Listar_CondicionExistenciaObligaciones()
        {
            var lista = new List<SelectViewModel>();

            lista.Add(new SelectViewModel() { Value = true.ToString(), TextDisplay = "Obligaciones generadas" });

            lista.Add(new SelectViewModel() { Value = false.ToString(), TextDisplay = "Obligaciones sin generar" });

            return lista;

        }

        public IEnumerable<SelectViewModel> Listar_CondicionPagoObligacion()
        {
            var lista = new List<SelectViewModel>();

            lista.Add(new SelectViewModel() { Value = true.ToString(), TextDisplay = "Obligaciones pagadas" });

            lista.Add(new SelectViewModel() { Value = false.ToString(), TextDisplay = "Obligaciones pendientes de pago" });

            return lista;

        }

        public IEnumerable<SelectViewModel> Listar_TiposPago()
        {
            var lista = new List<SelectViewModel>();

            lista = Enum.GetValues(typeof(TipoPago)).Cast<TipoPago>().Select(x =>
                    new SelectViewModel()
                    {
                        Value = x.ToString(),
                        TextDisplay = x.ToString()
                    }               
                ).ToList();

            return lista;

        }

    }
}