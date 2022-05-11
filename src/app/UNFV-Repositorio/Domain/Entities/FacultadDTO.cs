using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class FacultadDTO
    {
        public string CodFac { get; set; }
        public string FacDesc { get; set; }
        public string FacAbrev { get; set; }
        public int? DependenciaID { get; set; }
        public bool Habilitado { get; set; }
    }
}
