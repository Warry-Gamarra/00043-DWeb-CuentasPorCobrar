using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Views;
using Domain.Entities;

namespace Domain.Services.Implementations
{
    public class TasaService : ITasaService
    {
        public IEnumerable<TasaDTO> listar_TasasHabilitadas()
        {
            var lista = VW_Tasas.GetHabilitados();

            IEnumerable<TasaDTO> result = null;

            if (lista != null)
            {
                result = lista.Select(t => Mapper.VW_Tasas_To_TasaDTO(t));
            }

            return result;
        }
    }
}
