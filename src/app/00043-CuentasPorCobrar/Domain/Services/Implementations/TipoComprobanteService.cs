using Data.Tables;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class TipoComprobanteService : ITipoComprobanteService
    {
        public IEnumerable<TipoComprobanteDTO> ListarTiposComprobante(bool soloHabilitados)
        {
            var lista = TC_TipoComprobante.GetAll();

            if (soloHabilitados )
            {
                lista = lista.Where(x => x.B_Habilitado);
            }

            var result = lista.Select(x => Mapper.TC_TipoComprobante_To_TipoComprobanteDTO(x));

            return result;
        }
    }
}
