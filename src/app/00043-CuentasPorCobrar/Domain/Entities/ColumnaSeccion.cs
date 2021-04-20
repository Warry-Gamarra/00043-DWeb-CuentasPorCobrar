using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ColumnaSeccion
    {
        public int ColSecID { get; set; }
        public string ColSecDesc { get; set; }
        public int ColumnaInicio { get; set; }
        public int ColumnaFin { get; set; }
        public bool Habilitado { get; set; }
        public int SecArchivoID { get; set; }
        public int CampoPagoID { get; set; }
        public string CampoPagoDesc { get; set; }
        public string CampoPagoNom { get; set; }
        public string TablaPagoNom { get; set; }

        public string SecArchivoDesc { get; set; }
        public int TipArchivoEntFinanID { get; set; }

    }
}
