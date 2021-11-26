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
            var lista = tasaService.listar_Tasas();

            IEnumerable<SelectViewModel> result = null;

            if (lista != null)
            {
                result = lista.Where(t => t.B_Habilitado).Select(t => new SelectViewModel()
                {
                    Value = t.I_TasaUnfvID.ToString(),
                    TextDisplay = String.Format("{0} - {1} (S/. {2})", t.C_CodTasa, t.T_ConceptoPagoDesc, t.I_MontoTasa)
                });
            }

            return result;
        }

        public IEnumerable<TasaViewModel> listarTodoTasas()
        {
            var lista = tasaService.listar_Tasas();

            IEnumerable<TasaViewModel> result = null;

            if (lista != null)
            {
                result = lista.Select(t => new TasaViewModel()
                {
                    I_TasaUnfvID = t.I_TasaUnfvID,
                    C_CodTasa = t.C_CodTasa,
                    T_clasificador = t.T_clasificador,
                    T_ConceptoPagoDesc = t.T_ConceptoPagoDesc,
                    I_MontoTasa = t.I_MontoTasa,
                    B_Habilitado = t.B_Habilitado
                });
            }

            return result;
        }

        public IEnumerable<PagoTasaModel> listarPagoTasas(int? idEntidadFinanciera, int? idCtaDeposito, string codOperacion, DateTime? fechaInicio, DateTime? fechaFinal,
            string codDepositante)
        {
            var lista = tasaService.Listar_Pago_Tasas(idEntidadFinanciera, idCtaDeposito, codOperacion, fechaInicio, fechaFinal, codDepositante);

            var result = lista.Select(x => Mapper.PagoTasaDTO_To_PagoTasaModel(x));

            return result;
        }
    }
}