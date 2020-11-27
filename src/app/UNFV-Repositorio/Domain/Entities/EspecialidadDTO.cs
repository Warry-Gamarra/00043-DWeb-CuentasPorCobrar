using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class EspecialidadDTO
    {
        public string CodEsp { get; set; }
        public string CodEsc { get; set; }
        public string CodFac { get; set; }
        public string EspDesc { get; set; }
        public string EspAbrev { get; set; }
        public bool Habilitado { get; set; }
    }
}
