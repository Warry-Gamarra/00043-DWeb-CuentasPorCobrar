using Data.Tables;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class EstadoComprobanteService : IEstadoComprobanteService
    {
        public IEnumerable<EstadoComprobanteDTO> ListarEstadosComprobante(bool soloHabilitados)
        {
            var lista = TC_EstadoComprobante.GetAll();

            if (soloHabilitados)
            {
                lista = lista.Where(x => x.B_Habilitado);
            }

            var result = lista.Select(x => Mapper.TC_EstadoComprobante_To_EstadoComprobanteDTO(x));

            return result;
        }
    }
}
