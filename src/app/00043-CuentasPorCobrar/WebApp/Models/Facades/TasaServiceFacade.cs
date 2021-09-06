using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class TasaServiceFacade : ITasaServiceFacade
    {
        ITasaService tasaService;

        public TasaServiceFacade()
        {
            tasaService = new TasaService();
        }

        public IEnumerable<SelectViewModel> listarTasas()
        {
            var lista = tasaService.listar_TasasHabilitadas();

            IEnumerable<SelectViewModel> result = null;

            if (lista != null)
            {
                result = lista.Select(t => new SelectViewModel()
                {
                    Value = t.I_TasaUnfvID.ToString(),
                    TextDisplay = String.Format("{0} - {1} (S/. {2})", t.C_CodTasa, t.T_ConceptoPagoDesc, t.I_MontoTasa)
                });
            }

            return result;
        }

        public IEnumerable<PagoTasaModel> listarPagoTasas(int? idEntidadFinanciera, string codOperacion, DateTime? fechaInicio, DateTime? fechaFinal)
        {
            var lista = tasaService.Listar_Pago_Tasas(idEntidadFinanciera, codOperacion, fechaInicio, fechaFinal);

            var result = lista.Select(x => Mapper.PagoTasaDTO_To_PagoTasaModel(x));

            return result;
        }
    }
}