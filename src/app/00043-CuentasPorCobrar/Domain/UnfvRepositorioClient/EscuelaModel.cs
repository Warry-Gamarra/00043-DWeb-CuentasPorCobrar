using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.UnfvRepositorioClient
{
    public class EscuelaModel
    {
        public string CodEsc { get; set; }
        public string CodFac { get; set; }
        public string EscDesc { get; set; }
        public string EscAbrev { get; set; }
        public bool Habilitado { get; set; }
    }
}
