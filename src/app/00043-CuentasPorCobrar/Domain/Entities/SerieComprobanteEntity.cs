using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class SerieComprobanteEntity
    {
        public int? serieID { get; set; }

        public int numeroSerie { get; set; }

        public int finNumeroComprobante { get; set; }

        public int diasAnterioresPermitido { get; set; }
    }
}
