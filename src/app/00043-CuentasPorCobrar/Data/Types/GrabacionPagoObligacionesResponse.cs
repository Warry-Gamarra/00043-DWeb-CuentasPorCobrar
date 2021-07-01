using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Types
{
    public class GrabacionPagoObligacionesResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public IEnumerable<DataPagoObligacionesResult> resultList { get; set; }
    }
}
