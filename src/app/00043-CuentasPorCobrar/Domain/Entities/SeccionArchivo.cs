using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class SeccionArchivo
    {
        public int SecArchivoID { get; set; }
        public string SecArchivoDesc { get; set; }
        public int FilaInicio { get; set; }
        public int FilaFin { get; set; }
        public bool Habilitado { get; set; }
        public int TipArchivoEntFinanID { get; set; }
        public int TipoSeccionID { get; set; }

        public string TipoArchivDesc { get; set; }
        public bool ArchivoEntrada { get; set; }
        public string EntidadDesc { get; set; }
        public int EntidadFinanID { get; set; }
        public int TipoArchivoID { get; set; }
    }
}
