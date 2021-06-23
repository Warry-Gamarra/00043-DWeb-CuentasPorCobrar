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

        public IEnumerable<SelectViewModel> Listar_TipoEstudios()
        {
            var lista = generalService.Listar_TipoEstudios();

            var result = lista.Select(x => new SelectViewModel() { Value = x.ToString(), TextDisplay = x.ToString() });

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_Horas()
        {
            var lista = generalService.Listar_Horas();

            var result = lista.Select(x => new SelectViewModel() {
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

        public IEnumerable<SelectViewModel> Listar_ReportesPregrado()
        {
            var lista = new List<SelectViewModel>();

            lista.Add(new SelectViewModel() { Value = "1", TextDisplay = "Reporte de Facultades" });

            lista.Add(new SelectViewModel() { Value = "2", TextDisplay = "Reporte de Conceptos de Pago" });

            lista.Add(new SelectViewModel() { Value = "3", TextDisplay = "Reporte Conceptos por Facultad" });

            return lista;
        }

        public IEnumerable<SelectViewModel> Listar_ReportesPosgrado()
        {
            var lista = new List<SelectViewModel>();

            lista.Add(new SelectViewModel() { Value = "1", TextDisplay = "Reporte en Posgrado" });

            lista.Add(new SelectViewModel() { Value = "2", TextDisplay = "Reporte de Conceptos de Pago" });

            lista.Add(new SelectViewModel() { Value = "3", TextDisplay = "Reporte Conceptos por Grado" });

            return lista;
        }
    }
}