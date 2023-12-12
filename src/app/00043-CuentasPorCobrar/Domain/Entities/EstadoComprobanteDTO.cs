using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class EstadoComprobanteDTO
    {
        public int estadoComprobanteID { get; set; }

        public string estadoComprobanteCod { get; set; }

        public string estadoComprobanteDesc { get; set; }

        public bool estaHabilitado { get; set; }
    }
}
