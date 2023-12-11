using Data.Tables;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class SerieComprobanteService : ISerieComprobanteService
    {
        public IEnumerable<SerieComprobanteDTO> ListarSeriesComprobante(bool soloHabilitados)
        {
            var files = TC_SerieComprobante.GetAll();

            if (soloHabilitados)
            {
                files = files.Where(x => x.B_Habilitado);
            }

            var result = files.Select(x => Mapper.TC_SerieComprobante_To_SerieComprobanteDTO(x));

            return result;
        }
    }
}
