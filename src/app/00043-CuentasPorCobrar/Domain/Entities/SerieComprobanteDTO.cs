using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class SerieComprobanteDTO
    {
        public int serieID { get; set; }

        public string numeroSerie { get; set; }

        public bool estaHabilitado { get; set; }
    }
}
